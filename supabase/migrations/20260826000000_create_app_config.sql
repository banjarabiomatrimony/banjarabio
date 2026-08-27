-- =============================================================
-- Migration: app_config
-- Purpose: Universal In-App Update & Dynamic Remote Configuration
-- Features:
--  1. Remote version gating (min_version, latest_version, force_update)
--  2. Auto-Sync RPC (fn_sync_app_version): Automatically advances
--     latest_version when a newly published build boots up.
-- =============================================================

-- 1. Create app_config table
CREATE TABLE IF NOT EXISTS public.app_config (
    id TEXT PRIMARY KEY DEFAULT 'global',
    min_version TEXT NOT NULL DEFAULT '1.3.0',
    latest_version TEXT NOT NULL DEFAULT '1.3.3',
    force_update BOOLEAN NOT NULL DEFAULT FALSE,
    title TEXT DEFAULT 'New Update Available',
    message TEXT DEFAULT 'Please update to the latest version for the best matchmaking experience.',
    release_notes JSONB DEFAULT '["⚡ 3x Faster Biodata Generation", "🎨 Premium Themes Added", "🔒 Security Enhancements"]'::jsonb,
    play_store_url TEXT DEFAULT 'market://details?id=com.avishio.banjarabio',
    ios_store_url TEXT DEFAULT '',
    maintenance_mode BOOLEAN NOT NULL DEFAULT FALSE,
    maintenance_message TEXT DEFAULT 'We are undergoing scheduled maintenance. Please check back shortly.',
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- 2. Enable Row Level Security (RLS)
ALTER TABLE public.app_config ENABLE ROW LEVEL SECURITY;

-- 3. Public Read Policy (Allow anonymous & authenticated users to check version)
DROP POLICY IF EXISTS "Allow public read access to app_config" ON public.app_config;
CREATE POLICY "Allow public read access to app_config"
    ON public.app_config FOR SELECT
    TO anon, authenticated
    USING (true);

-- 4. Admin / Service Role Full Access Policy
DROP POLICY IF EXISTS "Service role full access on app_config" ON public.app_config;
CREATE POLICY "Service role full access on app_config"
    ON public.app_config FOR ALL
    USING (auth.jwt() ->> 'role' = 'service_role');

-- 5. Auto-update timestamp trigger
CREATE OR REPLACE FUNCTION public.fn_app_config_update_timestamp()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS tr_app_config_update_timestamp ON public.app_config;
CREATE TRIGGER tr_app_config_update_timestamp
    BEFORE UPDATE ON public.app_config
    FOR EACH ROW EXECUTE FUNCTION public.fn_app_config_update_timestamp();

-- 6. RPC: Auto-Sync App Version (Self-Advancing Version Heartbeat)
-- Automatically advances latest_version if the booting client has a higher SemVer.
CREATE OR REPLACE FUNCTION public.fn_sync_app_version(
    p_current_version TEXT
)
RETURNS JSONB
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
    v_latest TEXT;
    v_updated BOOLEAN := FALSE;
    v_curr_clean TEXT;
    v_latest_clean TEXT;
BEGIN
    -- Strip build numbers (e.g., '1.3.3+41' -> '1.3.3')
    v_curr_clean := regexp_replace(p_current_version, '\+.*$', '');

    -- Fetch current latest_version
    SELECT latest_version INTO v_latest FROM public.app_config WHERE id = 'global';

    IF v_latest IS NULL THEN
        INSERT INTO public.app_config (id, min_version, latest_version, force_update)
        VALUES ('global', v_curr_clean, v_curr_clean, false);
        RETURN jsonb_build_object('success', true, 'action', 'initialized', 'version', v_curr_clean);
    END IF;

    v_latest_clean := regexp_replace(v_latest, '\+.*$', '');

    -- Compare version arrays (PostgreSQL native array comparison, e.g. {1,3,4} > {1,3,3})
    BEGIN
        IF string_to_array(v_curr_clean, '.')::int[] > string_to_array(v_latest_clean, '.')::int[] THEN
            UPDATE public.app_config
            SET latest_version = v_curr_clean,
                updated_at = NOW()
            WHERE id = 'global';
            v_updated := TRUE;
        END IF;
    EXCEPTION WHEN OTHERS THEN
        -- Fallback string comparison if non-integer semver
        IF v_curr_clean > v_latest_clean THEN
            UPDATE public.app_config
            SET latest_version = v_curr_clean,
                updated_at = NOW()
            WHERE id = 'global';
            v_updated := TRUE;
        END IF;
    END;

    RETURN jsonb_build_object(
        'success', true,
        'updated', v_updated,
        'latest_version', CASE WHEN v_updated THEN v_curr_clean ELSE v_latest END
    );
END;
$$;

-- Allow anon and authenticated clients to report version heartbeat
GRANT EXECUTE ON FUNCTION public.fn_sync_app_version(TEXT) TO anon, authenticated, service_role;

-- 7. Insert Initial Seed Configuration
INSERT INTO public.app_config (
    id,
    min_version,
    latest_version,
    force_update,
    title,
    message,
    release_notes,
    play_store_url
)
VALUES (
    'global',
    '1.3.0',
    '1.3.3',
    false,
    'Exciting New Update Available! 🚀',
    'We have introduced instant biodata generation, new match preview cards, and performance improvements.',
    '["⚡ 3x Faster Biodata Generation", "🎨 10 Brand New Premium Biodata Themes", "🔒 Enhanced Privacy Controls & Vouch Security"]'::jsonb,
    'market://details?id=com.avishio.banjarabio'
)
ON CONFLICT (id) DO NOTHING;
