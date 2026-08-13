-- =============================================================
-- Migration: 20260813180000_fix_notification_queue_columns.sql
-- Purpose: Fix column name mismatch in fn_match_browse_intents_for_new_profile
--          (recipient_user_id instead of user_id, data instead of payload)
-- Created: 2026-08-13
-- =============================================================
CREATE OR REPLACE FUNCTION public.fn_match_browse_intents_for_new_profile(p_profile_id UUID) 
RETURNS INT LANGUAGE plpgsql SECURITY DEFINER AS $$
DECLARE v_profile RECORD;
v_matched_count INT := 0;
BEGIN -- Fetch the target profile
SELECT id,
    full_name,
    surname,
    age,
    gender,
    district,
    state,
    is_active INTO v_profile
FROM public.profiles
WHERE id = p_profile_id;

IF v_profile IS NULL
OR v_profile.is_active = false THEN RETURN 0;
END IF;

-- Match against active user_browse_intents logged in the last 60 days
-- Insert notification into notification_queue for each matching relative user
INSERT INTO public.notification_queue (
        recipient_user_id,
        title,
        body,
        data,
        created_at
    )
SELECT DISTINCT ubi.user_id,
    'तुमच्या नातेवाईकासाठी नवीन स्थळ! 🚩',
    COALESCE(v_profile.full_name, 'उमेदवार') || ' (' || v_profile.age || ' वर्षे' || CASE
        WHEN v_profile.district IS NOT NULL
        AND v_profile.district <> '' THEN ', ' || v_profile.district
        ELSE ''
    END || ') बंजाराबायो ॲपवर उपलब्ध आहे. आताच पहा.',
    jsonb_build_object(
        'type',
        'intent_match',
        'profile_id',
        v_profile.id::TEXT,
        'relation',
        ubi.relation
    ),
    NOW()
FROM public.user_browse_intents ubi
WHERE ubi.target_gender = v_profile.gender
    AND ubi.created_at >= (NOW() - INTERVAL '60 days')
    AND (
        ubi.district IS NULL
        OR ubi.district = ''
        OR LOWER(ubi.district) = LOWER(v_profile.district)
    );

GET DIAGNOSTICS v_matched_count = ROW_COUNT;
RETURN v_matched_count;
END;
$$;
