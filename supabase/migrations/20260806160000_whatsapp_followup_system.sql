-- =============================================================
-- Migration: whatsapp_followup_system
-- Purpose: Automated WhatsApp follow-up log tracking and match digest RPC
-- Created: 2026-08-06
-- =============================================================

CREATE TABLE IF NOT EXISTS public.whatsapp_notification_logs (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    phone_number TEXT,
    intent_id UUID REFERENCES public.user_browse_intents(id) ON DELETE SET NULL,
    matched_profile_ids UUID[],
    status TEXT NOT NULL DEFAULT 'queued', -- queued, sent, failed
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- Index for fast lookup of recent follow-ups per user
CREATE INDEX IF NOT EXISTS idx_wa_logs_user_recent 
ON public.whatsapp_notification_logs(user_id, created_at DESC);

-- Enable RLS
ALTER TABLE public.whatsapp_notification_logs ENABLE ROW LEVEL SECURITY;

-- Service role & owner read/write policies
CREATE POLICY "Users can read own whatsapp notification logs"
ON public.whatsapp_notification_logs FOR SELECT
USING (auth.uid() = user_id);

CREATE POLICY "Service role full access on whatsapp notification logs"
ON public.whatsapp_notification_logs FOR ALL
USING (auth.jwt() ->> 'role' = 'service_role');

-- RPC: Get weekly match digests for relative users who haven't received a WhatsApp notification in the last 7 days
CREATE OR REPLACE FUNCTION public.fn_get_relative_match_digests(
    p_limit INT DEFAULT 50
)
RETURNS TABLE (
    user_id UUID,
    phone_number TEXT,
    relation TEXT,
    target_gender TEXT,
    district TEXT,
    matching_profile_ids UUID[],
    match_count INT,
    sample_profile_names TEXT
)
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
BEGIN
    RETURN QUERY
    WITH recent_notified_users AS (
        SELECT DISTINCT wnl.user_id
        FROM public.whatsapp_notification_logs wnl
        WHERE wnl.created_at >= (NOW() - INTERVAL '7 days')
    ),
    active_intents AS (
        SELECT 
            ubi.id AS intent_id,
            ubi.user_id,
            ubi.relation,
            ubi.target_gender,
            ubi.district,
            p.phone AS user_phone
        FROM public.user_browse_intents ubi
        JOIN public.profiles p ON p.id = ubi.user_id
        WHERE ubi.created_at >= (NOW() - INTERVAL '60 days')
          AND ubi.user_id NOT IN (SELECT rnu.user_id FROM recent_notified_users rnu)
    ),
    matched_profiles AS (
        SELECT 
            ai.user_id,
            ai.relation,
            ai.target_gender,
            ai.district,
            ai.user_phone,
            ARRAY_AGG(cp.id) AS matched_ids,
            COUNT(cp.id)::INT AS total_matches,
            STRING_AGG(cp.full_name, ', ') AS sample_names
        FROM active_intents ai
        JOIN public.profiles cp ON cp.gender = ai.target_gender
        WHERE cp.is_active = true
          AND cp.created_at >= (NOW() - INTERVAL '7 days')
          AND (
              ai.district IS NULL 
              OR ai.district = '' 
              OR LOWER(ai.district) = LOWER(cp.district)
          )
        GROUP BY ai.user_id, ai.relation, ai.target_gender, ai.district, ai.user_phone
        HAVING COUNT(cp.id) > 0
    )
    SELECT 
        mp.user_id,
        mp.user_phone AS phone_number,
        mp.relation,
        mp.target_gender,
        mp.district,
        mp.matched_ids AS matching_profile_ids,
        mp.total_matches AS match_count,
        mp.sample_names AS sample_profile_names
    FROM matched_profiles mp
    LIMIT p_limit;
END;
$$;

GRANT EXECUTE ON FUNCTION public.fn_get_relative_match_digests(INT) TO service_role;
