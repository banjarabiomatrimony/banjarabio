-- =============================================================
-- Migration: relative_browse_intent_crm
-- Purpose: Match new candidate profiles against stored relative search intents
--          and queue notifications for relative users.
-- Created: 2026-08-03
-- =============================================================
CREATE OR REPLACE FUNCTION public.fn_match_browse_intents_for_new_profile(p_profile_id UUID) RETURNS INT LANGUAGE plpgsql SECURITY DEFINER AS $$
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
        user_id,
        title,
        body,
        payload,
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
-- Trigger function
CREATE OR REPLACE FUNCTION public.tr_fn_on_profile_match_intents() RETURNS TRIGGER LANGUAGE plpgsql SECURITY DEFINER AS $$ BEGIN IF (
        TG_OP = 'INSERT'
        AND NEW.is_active = true
    )
    OR (
        TG_OP = 'UPDATE'
        AND NEW.is_active = true
        AND (
            OLD.is_active = false
            OR OLD.is_active IS NULL
        )
    ) THEN PERFORM public.fn_match_browse_intents_for_new_profile(NEW.id);
END IF;
RETURN NEW;
END;
$$;
DROP TRIGGER IF EXISTS tr_on_profile_match_intents ON public.profiles;
CREATE TRIGGER tr_on_profile_match_intents
AFTER
INSERT
    OR
UPDATE OF is_active ON public.profiles FOR EACH ROW EXECUTE FUNCTION public.tr_fn_on_profile_match_intents();