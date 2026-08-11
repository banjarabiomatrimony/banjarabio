-- 🔍 [BanjaraBio] Add explicit gender filter to fn_get_filtered_feed
-- Required for Pathway A: Relative Browse Mode.
-- When a relative/visitor is searching on behalf of someone, they have no
-- own profile. The existing auto-detection (opposite gender from own profile)
-- returns NULL, showing mixed results. This param allows the Flutter app
-- to pass the explicit target gender from the intake form.
--
-- Backward compatible: existing callers that don't pass p_gender get NULL,
-- which falls through to the existing auto-detection logic.

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
DECLARE v_user_id UUID := auth.uid();
v_own_profile profiles %ROWTYPE;
v_target_gender TEXT;
BEGIN -- 1. Get current user context (Handle NULL for guests)
IF v_user_id IS NOT NULL THEN
SELECT * INTO v_own_profile
FROM profiles
WHERE user_id = v_user_id;
END IF;

-- 2. Determine target gender logic
-- Priority: explicit p_gender param > auto-detect from own profile > NULL (show all)
IF p_gender IS NOT NULL THEN
    v_target_gender := p_gender;
ELSIF v_own_profile.gender IS NOT NULL THEN
    IF LOWER(TRIM(v_own_profile.gender)) = 'male' THEN
        v_target_gender := 'Female';
    ELSE
        v_target_gender := 'Male';
    END IF;
END IF;

-- 3. Execute efficient query
RETURN QUERY
SELECT p.*
FROM profiles p
WHERE p.is_active = true
    -- Handle Guest Mode: Don't filter out self if v_user_id is NULL
    AND (
        v_user_id IS NULL
        OR p.user_id != v_user_id
    )
    AND (
        v_target_gender IS NULL
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
SET search_path = public,
    extensions;
