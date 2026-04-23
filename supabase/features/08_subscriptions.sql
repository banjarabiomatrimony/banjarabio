-- Last run: 2025-02-12 — Update when re-run in Supabase SQL Editor
-- =====================================================
-- 08. SUBSCRIPTIONS FEATURE
-- Handles user plan types and automated initialization.
-- =====================================================
-- =====================================================
-- TABLE: subscriptions
-- =====================================================
CREATE TABLE IF NOT EXISTS public.subscriptions (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    plan_type TEXT NOT NULL DEFAULT 'free' CHECK (
        plan_type IN ('free', 'silver', 'gold', 'platinum')
    ),
    status TEXT NOT NULL DEFAULT 'active' CHECK (
        status IN ('active', 'expired', 'cancelled', 'pending')
    ),
    started_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    expires_at TIMESTAMPTZ,
    razorpay_subscription_id TEXT,
    auto_renew BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW(),
    UNIQUE(user_id)
);
-- INDEXES (Premium check on every profile view - critical path)
CREATE INDEX IF NOT EXISTS idx_subscriptions_user_id ON public.subscriptions(user_id);
CREATE INDEX IF NOT EXISTS idx_subscriptions_status ON public.subscriptions(status);
CREATE INDEX IF NOT EXISTS idx_subscriptions_user_active ON public.subscriptions(user_id, status)
WHERE status = 'active';
-- RLS
ALTER TABLE public.subscriptions ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS "Users view own subscription" ON public.subscriptions;
CREATE POLICY "Users view own subscription" ON public.subscriptions FOR
SELECT USING (auth.uid() = user_id);
DROP POLICY IF EXISTS "System insert subscriptions" ON public.subscriptions;
CREATE POLICY "System insert subscriptions" ON public.subscriptions FOR
INSERT WITH CHECK (true);
-- =====================================================
-- TRIGGER: Auto-Init Free Subscription
-- =====================================================
CREATE OR REPLACE FUNCTION public.fn_initialize_subscription() RETURNS TRIGGER AS $$ BEGIN
INSERT INTO public.subscriptions (user_id, plan_type, status, started_at)
VALUES (NEW.id, 'free', 'active', NOW()) ON CONFLICT (user_id) DO NOTHING;
RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;
DROP TRIGGER IF EXISTS tr_new_user_subscription ON auth.users;
CREATE TRIGGER tr_new_user_subscription
AFTER
INSERT ON auth.users FOR EACH ROW EXECUTE FUNCTION public.fn_initialize_subscription();
-- =====================================================
-- MASTER RPC FUNCTION: fn_manage_subscription
-- =====================================================
CREATE OR REPLACE FUNCTION public.fn_manage_subscription(action TEXT, payload JSONB) RETURNS JSONB AS $$
DECLARE v_user_id UUID := auth.uid();
v_result JSONB;
BEGIN IF v_user_id IS NULL THEN RAISE EXCEPTION 'Not authenticated';
END IF;
CASE
    action
    WHEN 'get_status' THEN
    SELECT jsonb_build_object(
            'plan',
            plan_type,
            'status',
            status,
            'expires_at',
            expires_at
        ) INTO v_result
    FROM public.subscriptions
    WHERE user_id = v_user_id;
WHEN 'cancel_auto_renew' THEN
UPDATE public.subscriptions
SET auto_renew = false
WHERE user_id = v_user_id;
v_result := jsonb_build_object(
    'status',
    'success',
    'message',
    'Auto-renew cancelled'
);
WHEN 'init_free_plan' THEN
INSERT INTO public.subscriptions (user_id, plan_type, status, started_at)
VALUES (v_user_id, 'free', 'active', NOW()) ON CONFLICT (user_id) DO NOTHING
RETURNING jsonb_build_object(
        'id',
        id,
        'plan_type',
        plan_type,
        'status',
        status
    ) INTO v_result;
WHEN 'renew_plan' THEN
UPDATE public.subscriptions
SET status = COALESCE((payload->>'status')::TEXT, status),
    updated_at = NOW()
WHERE user_id = v_user_id;
v_result := jsonb_build_object(
    'status',
    'success',
    'message',
    'Subscription updated'
);
WHEN 'update_status' THEN
UPDATE public.subscriptions
SET status = (payload->>'status')::TEXT,
    updated_at = NOW()
WHERE user_id = v_user_id;
v_result := jsonb_build_object('status', 'success', 'message', 'Status updated');
WHEN 'cancel_plan' THEN
UPDATE public.subscriptions
SET status = 'cancelled',
    auto_renew = false,
    updated_at = NOW()
WHERE user_id = v_user_id;
v_result := jsonb_build_object(
    'status',
    'success',
    'message',
    'Subscription cancelled'
);
ELSE RAISE EXCEPTION 'Invalid action';
END CASE
;
RETURN v_result;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;
GRANT EXECUTE ON FUNCTION public.fn_manage_subscription(TEXT, JSONB) TO authenticated;
-- =====================================================
-- TRIGGER: Sync Premium Status to Profiles
-- Ensures profiles.is_premium is always in sync with subscriptions table.
-- =====================================================
CREATE OR REPLACE FUNCTION public.fn_sync_premium_status() RETURNS TRIGGER AS $$ BEGIN -- We allow the profile update even if protected by RLS because this is SECURITY DEFINER
UPDATE public.profiles
SET is_premium = (
        NEW.plan_type != 'free'
        AND NEW.status = 'active'
    ),
    updated_at = NOW()
WHERE user_id = NEW.user_id;
RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;
DROP TRIGGER IF EXISTS tr_sync_premium_status ON public.subscriptions;
CREATE TRIGGER tr_sync_premium_status
AFTER
INSERT
    OR
UPDATE OF plan_type,
    status ON public.subscriptions FOR EACH ROW EXECUTE FUNCTION public.fn_sync_premium_status();