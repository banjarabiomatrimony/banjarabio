-- =============================================================
-- Migration: user_devices
-- Purpose: Store FCM tokens at auth level (not profile level)
--          so ALL logged-in users (including Search Users without
--          a full profile) can receive push notifications.
-- =============================================================

-- 1. Create user_devices table
CREATE TABLE IF NOT EXISTS public.user_devices (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    fcm_token TEXT,
    platform TEXT DEFAULT 'android',
    app_version TEXT,
    last_active_at TIMESTAMPTZ DEFAULT NOW(),
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW(),
    CONSTRAINT user_devices_user_id_unique UNIQUE (user_id)
);

-- 2. Indexes
CREATE INDEX IF NOT EXISTS idx_user_devices_user_id ON public.user_devices(user_id);
CREATE INDEX IF NOT EXISTS idx_user_devices_fcm_token ON public.user_devices(fcm_token) WHERE fcm_token IS NOT NULL;
CREATE INDEX IF NOT EXISTS idx_user_devices_last_active ON public.user_devices(last_active_at DESC);

-- 3. RLS
ALTER TABLE public.user_devices ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can read own device"
    ON public.user_devices FOR SELECT
    USING (auth.uid() = user_id);

CREATE POLICY "Users can upsert own device"
    ON public.user_devices FOR INSERT
    WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update own device"
    ON public.user_devices FOR UPDATE
    USING (auth.uid() = user_id);

CREATE POLICY "Service role full access on user_devices"
    ON public.user_devices FOR ALL
    USING (auth.jwt() ->> 'role' = 'service_role');

-- 4. Auto-updated timestamp trigger
CREATE OR REPLACE FUNCTION public.fn_user_devices_update_timestamp()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS tr_user_devices_update_timestamp ON public.user_devices;
CREATE TRIGGER tr_user_devices_update_timestamp
    BEFORE UPDATE ON public.user_devices
    FOR EACH ROW EXECUTE FUNCTION public.fn_user_devices_update_timestamp();

-- 5. Auto-create device row on auth.users insert
CREATE OR REPLACE FUNCTION public.fn_auto_create_user_device()
RETURNS TRIGGER AS $$
BEGIN
    INSERT INTO public.user_devices (user_id)
    VALUES (NEW.id)
    ON CONFLICT (user_id) DO NOTHING;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

DROP TRIGGER IF EXISTS tr_auto_create_user_device ON auth.users;
CREATE TRIGGER tr_auto_create_user_device
    AFTER INSERT ON auth.users
    FOR EACH ROW EXECUTE FUNCTION public.fn_auto_create_user_device();

-- 6. Backfill: Copy existing FCM tokens from profiles to user_devices
INSERT INTO public.user_devices (user_id, fcm_token)
SELECT p.user_id, p.fcm_token
FROM public.profiles p
WHERE p.user_id IS NOT NULL
ON CONFLICT (user_id) DO UPDATE
SET fcm_token = EXCLUDED.fcm_token,
    updated_at = NOW();

-- 7. Backfill: Create device rows for auth users who have NO profile
INSERT INTO public.user_devices (user_id)
SELECT u.id
FROM auth.users u
LEFT JOIN public.user_devices ud ON ud.user_id = u.id
WHERE ud.id IS NULL
ON CONFLICT (user_id) DO NOTHING;

-- 8. RPC: Upsert device token (called from Flutter)
CREATE OR REPLACE FUNCTION public.fn_upsert_device_token(
    p_fcm_token TEXT,
    p_platform TEXT DEFAULT 'android',
    p_app_version TEXT DEFAULT NULL
)
RETURNS VOID
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
    v_user_id UUID := auth.uid();
BEGIN
    IF v_user_id IS NULL THEN
        RAISE EXCEPTION 'Not authenticated';
    END IF;

    INSERT INTO public.user_devices (user_id, fcm_token, platform, app_version, last_active_at)
    VALUES (v_user_id, p_fcm_token, p_platform, p_app_version, NOW())
    ON CONFLICT (user_id) DO UPDATE
    SET fcm_token = p_fcm_token,
        platform = COALESCE(p_platform, public.user_devices.platform),
        app_version = COALESCE(p_app_version, public.user_devices.app_version),
        last_active_at = NOW(),
        updated_at = NOW();
END;
$$;

GRANT EXECUTE ON FUNCTION public.fn_upsert_device_token(TEXT, TEXT, TEXT) TO authenticated;
