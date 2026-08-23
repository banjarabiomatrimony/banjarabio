-- 🔍 [BanjaraBio] Harden fn_get_filtered_feed gender filtering and opposite-gender auto-detection
-- Fixes issue where:
-- 1. Explicit empty string / 'all' was treated as non-NULL, corrupting target gender matching.
-- 2. Ensures multi-alias support ('Male', 'Men', 'Groom', 'M' -> target 'Female'; 'Female', 'Women', 'Bride', 'F' -> target 'Male').
-- 3. In the profile query, candidate matching checks both exact value and common aliases.

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
        ELSE
            v_target_gender := NULL;
        END IF;
    END IF;

    -- 4. Execute efficient query
    RETURN QUERY
    SELECT p.*
    FROM profiles p
    WHERE p.is_active = true
        -- Handle Guest Mode: Don't filter out self if v_user_id is NULL
        AND (
            v_user_id IS NULL
            OR p.user_id != v_user_id
        )
        -- Robust Gender Matching
        AND (
            v_target_gender IS NULL
            OR (
                LOWER(v_target_gender) IN ('female', 'women', 'bride', 'f') 
                AND LOWER(TRIM(p.gender)) IN ('female', 'women', 'bride', 'f')
            )
            OR (
                LOWER(v_target_gender) IN ('male', 'men', 'groom', 'm') 
                AND LOWER(TRIM(p.gender)) IN ('male', 'men', 'groom', 'm')
            )
            OR LOWER(TRIM(p.gender)) = LOWER(v_target_gender)
        )
        -- Index-optimized cursor pagination
        AND (
            p_last_created_at IS NULL
            OR p.created_at < p_last_created_at
        )
        -- ILIKE search (pg_trgm GIN indexes accelerate these)
        AND (
            p_search_query IS NULL
            OR (
                p.full_name ILIKE ('%' || p_search_query || '%')
                OR p.surname ILIKE ('%' || p_search_query || '%')
            )
        )
        -- O(1) Block Check via Composite Index
        AND (
            v_user_id IS NULL
            OR NOT EXISTS (
                SELECT 1
                FROM user_blocks ub
                WHERE ub.blocker_id = v_user_id
                    AND ub.blocked_id = p.user_id
            )
        )
        -- Additional Fast Facets
        AND (
            p_min_age IS NULL
            OR p.age >= p_min_age
        )
        AND (
            p_max_age IS NULL
            OR p.age <= p_max_age
        )
        AND (
            p_state IS NULL
            OR p.state = p_state
        )
        AND (
            p_district IS NULL
            OR p.district = p_district
        )
        AND (
            p_taluka IS NULL
            OR p.taluka = p_taluka
        )
    ORDER BY p.created_at DESC
    LIMIT p_limit;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER
SET search_path = public, extensions;
