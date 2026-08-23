-- 🛡️ [BanjaraBio] Restore dropped security filters in fn_get_filtered_feed
-- FIXES (REGRESSION from 20260823150000):
--   1. Restores `p.is_active = true` filter — inactive/deactivated profiles were leaking into feed
--   2. Restores `user_blocks` exclusion — blocked users were reappearing in blocker's feed
--   3. Adds `SET search_path = public, extensions` to SECURITY DEFINER — prevents search_path injection
--   4. Retains all improvements from the age-sync migration (COALESCE DOB fallback, expanded search)

CREATE OR REPLACE FUNCTION fn_get_filtered_feed(
        p_limit INT DEFAULT 20,
        p_last_created_at TIMESTAMPTZ DEFAULT NULL,
        p_search_query TEXT DEFAULT NULL,
        p_min_age INT DEFAULT NULL,
        p_max_age INT DEFAULT NULL,
        p_state TEXT DEFAULT NULL,
        p_district TEXT DEFAULT NULL,
        p_taluka TEXT DEFAULT NULL,
        p_gender TEXT DEFAULT NULL
    ) RETURNS SETOF profiles AS $$
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
    -- Priority: explicit clean p_gender param > auto-detect from own profile > NULL (show all)
    IF v_clean_gender IS NOT NULL THEN
        v_target_gender := v_clean_gender;
    ELSIF v_own_profile.gender IS NOT NULL AND TRIM(v_own_profile.gender) != '' THEN
        IF LOWER(TRIM(v_own_profile.gender)) IN ('male', 'men', 'groom', 'm', 'man') THEN
            v_target_gender := 'Female';
        ELSIF LOWER(TRIM(v_own_profile.gender)) IN ('female', 'women', 'bride', 'f', 'woman') THEN
            v_target_gender := 'Male';
        END IF;
    END IF;

    -- 4. Execute single-pass SQL query using database indexes
    RETURN QUERY
    SELECT p.*
    FROM profiles p
    WHERE p.is_active = true
    AND (
        -- User exclusion: Never show current user's own profile
        v_user_id IS NULL OR p.user_id != v_user_id
    )
    AND (
        -- Gender filter: Handles aliases and case-insensitivity
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
        -- Cursor pagination: strictly fetch older profiles
        p_last_created_at IS NULL OR p.created_at < p_last_created_at
    )
    AND (
        -- Search filter: Search by Name, Surname, Gotra, Native Place, Village, or District
        p_search_query IS NULL OR TRIM(p_search_query) = ''
        OR p.full_name ILIKE '%' || TRIM(p_search_query) || '%'
        OR p.surname ILIKE '%' || TRIM(p_search_query) || '%'
        OR p.gotra ILIKE '%' || TRIM(p_search_query) || '%'
        OR p.native_place ILIKE '%' || TRIM(p_search_query) || '%'
        OR p.village ILIKE '%' || TRIM(p_search_query) || '%'
        OR p.district ILIKE '%' || TRIM(p_search_query) || '%'
    )
    AND (
        -- 🛡️ RESTORED: Block check — O(1) via composite index
        v_user_id IS NULL
        OR NOT EXISTS (
            SELECT 1
            FROM user_blocks ub
            WHERE ub.blocker_id = v_user_id
                AND ub.blocked_id = p.user_id
        )
    )
    AND (
        -- Age range filtering with COALESCE DOB fallback
        p_min_age IS NULL
        OR COALESCE(p.age, GREATEST(18, EXTRACT(YEAR FROM age(CURRENT_DATE, p.date_of_birth))::INT)) >= p_min_age
    )
    AND (
        p_max_age IS NULL
        OR COALESCE(p.age, GREATEST(18, EXTRACT(YEAR FROM age(CURRENT_DATE, p.date_of_birth))::INT)) <= p_max_age
    )
    AND (
        -- Geography filters
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
$$ LANGUAGE plpgsql SECURITY DEFINER
SET search_path = public, extensions;
