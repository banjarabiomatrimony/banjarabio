-- =============================================================
-- Migration: Search Match Notifier Supporting Schema
-- Purpose: RPC + notification log + pg_cron schedule for automated
--          match notifications to Search Users every 3 days
-- =============================================================

-- 1. Notification log to track sent notifications (prevents duplicates)
CREATE TABLE IF NOT EXISTS public.search_match_notifications (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    intent_id UUID REFERENCES public.user_browse_intents(id) ON DELETE SET NULL,
    match_count INTEGER DEFAULT 0,
    status TEXT DEFAULT 'sent',
    created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_search_match_notif_user ON public.search_match_notifications(user_id, created_at DESC);

ALTER TABLE public.search_match_notifications ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Service role manages search_match_notifications"
    ON public.search_match_notifications FOR ALL
    USING (auth.jwt() ->> 'role' = 'service_role');

-- 2. RPC: Find eligible users for match notifications
CREATE OR REPLACE FUNCTION public.fn_get_search_match_candidates(
    p_notify_interval_days INTEGER DEFAULT 3,
    p_limit INTEGER DEFAULT 100
)
RETURNS TABLE (
    user_id UUID,
    intent_id UUID,
    relation TEXT,
    target_gender TEXT,
    district TEXT,
    state TEXT,
    fcm_token TEXT,
    match_count BIGINT,
    last_intent_at TIMESTAMPTZ
)
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
    v_cutoff TIMESTAMPTZ := NOW() - (p_notify_interval_days || ' days')::INTERVAL;
BEGIN
    RETURN QUERY
    WITH latest_intents AS (
        SELECT DISTINCT ON (bi.user_id)
            bi.user_id,
            bi.id AS intent_id,
            bi.relation,
            bi.target_gender,
            bi.district,
            bi.state,
            bi.created_at AS intent_at
        FROM public.user_browse_intents bi
        WHERE bi.created_at > NOW() - INTERVAL '60 days'
        ORDER BY bi.user_id, bi.created_at DESC
    ),
    last_notifications AS (
        SELECT DISTINCT ON (smn.user_id)
            smn.user_id,
            smn.created_at AS last_notified_at
        FROM public.search_match_notifications smn
        ORDER BY smn.user_id, smn.created_at DESC
    )
    SELECT
        li.user_id,
        li.intent_id,
        li.relation,
        li.target_gender,
        li.district,
        li.state,
        ud.fcm_token,
        (
            SELECT COUNT(*)
            FROM public.profiles p
            WHERE p.is_active = true
            AND p.created_at > COALESCE(ln.last_notified_at, v_cutoff)
            AND (li.target_gender IS NULL OR p.gender = li.target_gender)
            AND (li.state IS NULL OR p.state = li.state)
            AND (li.district IS NULL OR p.district = li.district)
        ) AS match_count,
        li.intent_at AS last_intent_at
    FROM latest_intents li
    JOIN public.user_devices ud ON ud.user_id = li.user_id
    LEFT JOIN last_notifications ln ON ln.user_id = li.user_id
    WHERE
        ud.fcm_token IS NOT NULL
        AND (ln.last_notified_at IS NULL OR ln.last_notified_at < v_cutoff)
    AND EXISTS (
        SELECT 1 FROM public.profiles p
        WHERE p.is_active = true
        AND p.created_at > COALESCE(ln.last_notified_at, v_cutoff)
        AND (li.target_gender IS NULL OR p.gender = li.target_gender)
    )
    ORDER BY match_count DESC
    LIMIT p_limit;
END;
$$;

-- 3. pg_cron: Schedule every 3 days at 10:00 AM IST (04:30 UTC)
SELECT cron.schedule(
    'search-match-notifier',
    '0 4 */3 * *',
    $$
    SELECT net.http_post(
        url := (SELECT value FROM private.notification_settings WHERE key = 'supabase_url')
              || '/functions/v1/search-match-notifier',
        headers := jsonb_build_object(
            'Content-Type', 'application/json',
            'Authorization', 'Bearer ' || (SELECT value FROM private.notification_settings WHERE key = 'service_role_key')
        ),
        body := '{}'::jsonb
    );
    $$
);
