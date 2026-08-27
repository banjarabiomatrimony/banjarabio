-- ════════════════════════════════════════════════════════════════════════════
-- Migration: 20260827180000_optimize_feed_strict_projection.sql
-- Description: Strict Column Projection for fn_get_filtered_feed to reduce
--              feed payload size by ~70% and optimize low-end mobile deserialization.
-- ════════════════════════════════════════════════════════════════════════════

-- 1. Drop legacy 8-argument overload to avoid ambiguous resolution
DROP FUNCTION IF EXISTS public.fn_get_filtered_feed(integer, timestamp with time zone, text, integer, integer, text, text, text);

-- 2. Create single unified, optimized 9-argument function
CREATE OR REPLACE FUNCTION public.fn_get_filtered_feed(
    p_limit integer DEFAULT 20,
    p_last_created_at timestamp with time zone DEFAULT NULL::timestamp with time zone,
    p_search_query text DEFAULT NULL::text,
    p_min_age integer DEFAULT NULL::integer,
    p_max_age integer DEFAULT NULL::integer,
    p_state text DEFAULT NULL::text,
    p_district text DEFAULT NULL::text,
    p_taluka text DEFAULT NULL::text,
    p_gender text DEFAULT NULL::text
)
RETURNS SETOF profiles
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
    v_user_id UUID := auth.uid();
    v_own_profile profiles%ROWTYPE;
    v_target_gender TEXT := NULL;
    v_clean_gender TEXT := NULL;
BEGIN
    -- 1. Get current user context (Handle NULL for guests)
    IF v_user_id IS NOT NULL THEN
        SELECT * INTO v_own_profile
        FROM profiles
        WHERE user_id = v_user_id;
    END IF;

    -- 2. Clean input parameter
    IF p_gender IS NOT NULL AND TRIM(p_gender) != '' AND LOWER(TRIM(p_gender)) != 'all' THEN
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

    -- 4. Execute single-pass SQL query with Strict Column Projection
    RETURN QUERY
    SELECT 
        p.id,
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
        v_user_id IS NULL OR p.user_id != v_user_id
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
        p_last_created_at IS NULL OR p.created_at < p_last_created_at
    )
    AND (
        p_search_query IS NULL OR TRIM(p_search_query) = ''
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
        OR COALESCE(p.age, GREATEST(18, EXTRACT(YEAR FROM age(CURRENT_DATE, p.date_of_birth))::INT)) >= p_min_age
    )
    AND (
        p_max_age IS NULL
        OR COALESCE(p.age, GREATEST(18, EXTRACT(YEAR FROM age(CURRENT_DATE, p.date_of_birth))::INT)) <= p_max_age
    )
    AND (
        p_state IS NULL OR TRIM(p_state) = '' OR LOWER(TRIM(p.state)) = LOWER(TRIM(p_state))
    )
    AND (
        p_district IS NULL OR TRIM(p_district) = '' OR LOWER(TRIM(p.district)) = LOWER(TRIM(p_district))
    )
    AND (
        p_taluka IS NULL OR TRIM(p_taluka) = '' OR LOWER(TRIM(p.taluka)) = LOWER(TRIM(p_taluka))
    )
    ORDER BY p.created_at DESC
    LIMIT p_limit;
END;
$$;
