-- ════════════════════════════════════════════════════════════════════════════
-- Migration: 20260901180000_smart_feed_ranking_and_sort_modes.sql
-- Description: Automated Smart Relevance Ranking & Dynamic Sort Modes for fn_get_filtered_feed
--              - 'smart' (default): Multi-factor scoring (Premium + Verified + Location + Gotra + Completion + Recency)
--              - 'near_me': District & State proximity prioritization
--              - 'verified': VIP Verified & Trust Score prioritization
--              - 'active': Recently updated/active prioritization
--              - 'latest': Classic created_at DESC fallback
-- ════════════════════════════════════════════════════════════════════════════

-- 1. Drop existing 9-argument overload to ensure clean signature resolution
DROP FUNCTION IF EXISTS public.fn_get_filtered_feed(
    integer,
    timestamp with time zone,
    text,
    integer,
    integer,
    text,
    text,
    text,
    text
);

-- 2. Create updated 10-argument function with p_sort_by parameter
CREATE OR REPLACE FUNCTION public.fn_get_filtered_feed(
        p_limit integer DEFAULT 20,
        p_last_created_at timestamp with time zone DEFAULT NULL::timestamp with time zone,
        p_search_query text DEFAULT NULL::text,
        p_min_age integer DEFAULT NULL::integer,
        p_max_age integer DEFAULT NULL::integer,
        p_state text DEFAULT NULL::text,
        p_district text DEFAULT NULL::text,
        p_taluka text DEFAULT NULL::text,
        p_gender text DEFAULT NULL::text,
        p_sort_by text DEFAULT 'smart'::text
    ) RETURNS SETOF profiles LANGUAGE plpgsql SECURITY DEFINER AS $$
DECLARE
    v_user_id UUID := auth.uid();
    v_own_profile profiles%ROWTYPE;
    v_target_gender TEXT := NULL;
    v_clean_gender TEXT := NULL;
    v_clean_sort TEXT := LOWER(TRIM(COALESCE(p_sort_by, 'smart')));
BEGIN
    -- 1. Get current user context (Handle NULL for guests / relative browse)
    IF v_user_id IS NOT NULL THEN
        SELECT * INTO v_own_profile
        FROM profiles
        WHERE user_id = v_user_id;
    END IF;

    -- 2. Clean input parameter
    IF p_gender IS NOT NULL
        AND TRIM(p_gender) != ''
        AND LOWER(TRIM(p_gender)) != 'all' THEN
        v_clean_gender := TRIM(p_gender);
    END IF;

    -- 3. Determine target gender logic
    IF v_clean_gender IS NOT NULL THEN
        v_target_gender := v_clean_gender;
    ELSIF v_own_profile.gender IS NOT NULL AND TRIM(v_own_profile.gender) != '' THEN
        IF LOWER(TRIM(v_own_profile.gender)) IN ('male', 'men', 'groom', 'm', 'man') THEN
            v_target_gender := 'Female';
        ELSIF LOWER(TRIM(v_own_profile.gender)) IN ('female', 'women', 'bride', 'f', 'woman') THEN
            v_target_gender := 'Male';
        END IF;
    END IF;

    -- 4. Execute query with Strict Column Projection and Dynamic Smart Ranking
    RETURN QUERY
    SELECT p.id,
        p.user_id,
        p.phone_number,
        p.email,
        p.full_name,
        p.surname,
        p.age,
        p.date_of_birth,
        p.gender,
        p.height,
        p.complexion,
        p.blood_group,
        p.marital_status,
        NULL::text AS birth_place,
        NULL::text AS birth_time,
        p.education,
        p.education_details,
        p.profession,
        p.job_details,
        p.company,
        p.annual_income,
        p.state,
        p.district,
        p.taluka,
        p.village,
        p.current_location,
        p.permanent_location,
        p.native_place,
        NULL::text AS father_name,
        NULL::text AS father_occupation,
        NULL::text AS mother_name,
        NULL::text AS mother_occupation,
        NULL::integer AS siblings_count,
        NULL::integer AS sister_count,
        NULL::integer AS brother_count,
        NULL::text AS family_type,
        NULL::text AS family_status,
        p.marriage_readiness,
        NULL::text AS about_self,
        NULL::text AS partner_expectations,
        NULL::text AS expectation,
        p.is_premium,
        p.profile_completion,
        p.is_verified,
        p.trust_score,
        p.is_active,
        p.created_at,
        p.updated_at,
        NULL::jsonb AS siblings_data,
        p.is_pdf_unlocked,
        p.is_admin,
        p.gotra,
        NULL::text AS fcm_token,
        p.email_verified,
        p.phone_verified,
        p.referral_code,
        p.has_followed_instagram,
        p.profile_created_by,
        p.is_disabled,
        NULL::tsvector AS search_vector,
        p.whatsapp_opt_in,
        p.special_discount,
        p.special_discount_expires_at,
        p.role,
        NULL::uuid AS assigned_to,
        NULL::timestamp with time zone AS last_called_at,
        NULL::text AS call_status,
        NULL::integer AS lead_score,
        NULL::boolean AS opted_out_calls,
        NULL::text AS department,
        NULL::text AS designation,
        p.vouch_count,
        p.is_community_trusted
    FROM profiles p
    WHERE p.is_active = true
        AND (
            v_user_id IS NULL
            OR p.user_id != v_user_id
        )
        AND (
            v_target_gender IS NULL
            OR (
                LOWER(v_target_gender) IN ('female', 'women', 'bride', 'f', 'woman')
                AND LOWER(TRIM(p.gender)) IN ('female', 'women', 'bride', 'f', 'woman')
            )
            OR (
                LOWER(v_target_gender) IN ('male', 'men', 'groom', 'm', 'man')
                AND LOWER(TRIM(p.gender)) IN ('male', 'men', 'groom', 'm', 'man')
            )
            OR LOWER(TRIM(p.gender)) = LOWER(TRIM(v_target_gender))
        )
        AND (
            p_last_created_at IS NULL
            OR p.created_at < p_last_created_at
        )
        AND (
            p_search_query IS NULL
            OR TRIM(p_search_query) = ''
            OR p.full_name ILIKE '%' || TRIM(p_search_query) || '%'
            OR p.surname ILIKE '%' || TRIM(p_search_query) || '%'
            OR p.gotra ILIKE '%' || TRIM(p_search_query) || '%'
            OR p.native_place ILIKE '%' || TRIM(p_search_query) || '%'
            OR p.village ILIKE '%' || TRIM(p_search_query) || '%'
            OR p.district ILIKE '%' || TRIM(p_search_query) || '%'
        )
        AND (
            v_user_id IS NULL
            OR NOT EXISTS (
                SELECT 1
                FROM user_blocks ub
                WHERE ub.blocker_id = v_user_id
                    AND ub.blocked_id = p.user_id
            )
        )
        AND (
            p_min_age IS NULL
            OR COALESCE(
                p.age,
                GREATEST(
                    18,
                    EXTRACT(
                        YEAR
                        FROM age(CURRENT_DATE, p.date_of_birth)
                    )::INT
                )
            ) >= p_min_age
        )
        AND (
            p_max_age IS NULL
            OR COALESCE(
                p.age,
                GREATEST(
                    18,
                    EXTRACT(
                        YEAR
                        FROM age(CURRENT_DATE, p.date_of_birth)
                    )::INT
                )
            ) <= p_max_age
        )
        AND (
            p_state IS NULL
            OR TRIM(p_state) = ''
            OR LOWER(TRIM(p.state)) = LOWER(TRIM(p_state))
        )
        AND (
            p_district IS NULL
            OR TRIM(p_district) = ''
            OR LOWER(TRIM(p.district)) = LOWER(TRIM(p_district))
        )
        AND (
            p_taluka IS NULL
            OR TRIM(p_taluka) = ''
            OR LOWER(TRIM(p.taluka)) = LOWER(TRIM(p_taluka))
        )
    ORDER BY
        CASE
            WHEN v_clean_sort = 'latest' THEN
                0
            WHEN v_clean_sort = 'active' THEN
                EXTRACT(EPOCH FROM COALESCE(p.updated_at, p.created_at))::BIGINT
            WHEN v_clean_sort = 'verified' THEN
                (CASE WHEN p.is_verified THEN 1000 ELSE 0 END)
                + (CASE WHEN p.is_community_trusted THEN 500 ELSE 0 END)
                + (COALESCE(p.trust_score, 0) * 5)
                + (CASE WHEN p.is_premium THEN 200 ELSE 0 END)
            WHEN v_clean_sort = 'near_me' THEN
                (CASE WHEN v_own_profile.district IS NOT NULL AND LOWER(TRIM(p.district)) = LOWER(TRIM(v_own_profile.district)) THEN 1000 ELSE 0 END)
                + (CASE WHEN v_own_profile.state IS NOT NULL AND LOWER(TRIM(p.state)) = LOWER(TRIM(v_own_profile.state)) THEN 400 ELSE 0 END)
                + (CASE WHEN p.is_premium THEN 150 ELSE 0 END)
                + (CASE WHEN p.is_verified THEN 100 ELSE 0 END)
            ELSE -- Default 'smart'
                (CASE WHEN p.is_premium THEN 400 ELSE 0 END)
                + (CASE WHEN p.is_verified THEN 200 ELSE 0 END)
                + (CASE WHEN p.is_community_trusted THEN 150 ELSE 0 END)
                + (CASE WHEN v_own_profile.district IS NOT NULL AND LOWER(TRIM(p.district)) = LOWER(TRIM(v_own_profile.district)) THEN 300
                        WHEN v_own_profile.state IS NOT NULL AND LOWER(TRIM(p.state)) = LOWER(TRIM(v_own_profile.state)) THEN 100
                        ELSE 0 END)
                + (CASE WHEN v_own_profile.gotra IS NOT NULL AND p.gotra IS NOT NULL AND LOWER(TRIM(p.gotra)) != LOWER(TRIM(v_own_profile.gotra)) THEN 150 ELSE 0 END)
                + (CASE WHEN p.profile_completion >= 80 THEN 100
                        WHEN p.profile_completion >= 50 THEN 50
                        ELSE 0 END)
                + (COALESCE(p.trust_score, 0) * 2)
                + (CASE WHEN p.updated_at >= NOW() - INTERVAL '3 days' THEN 150
                        WHEN p.updated_at >= NOW() - INTERVAL '14 days' THEN 80
                        WHEN p.updated_at >= NOW() - INTERVAL '30 days' THEN 30
                        ELSE 0 END)
        END DESC,
        p.created_at DESC
    LIMIT p_limit;
END;
$$;

-- 3. High-performance composite index for filtered feed execution
CREATE INDEX IF NOT EXISTS idx_profiles_smart_feed
ON public.profiles (is_active, gender, is_premium DESC, is_verified DESC, created_at DESC)
WHERE is_active = true;
