-- 🎂 [BanjaraBio] Sync Profile Age from Date of Birth & Backfill Existing Profiles
-- 1. Create trigger function to auto-calculate and keep `age` synced from `date_of_birth` (clamped to >= 18 per profiles_age_check constraint)
-- 2. Backfill existing profiles where age is NULL, 0, or default 18 with true calculated age from DOB
-- 3. Enhance fn_get_filtered_feed age filter with COALESCE fallback

CREATE OR REPLACE FUNCTION fn_sync_profile_age()
RETURNS TRIGGER AS $$
DECLARE
    v_calculated_age INT;
BEGIN
    -- If date_of_birth is provided
    IF NEW.date_of_birth IS NOT NULL THEN
        v_calculated_age := GREATEST(18, EXTRACT(YEAR FROM age(CURRENT_DATE, NEW.date_of_birth))::INT);
        -- If age is missing, 0, or NULL, or if DOB changed and age was not explicitly updated
        IF NEW.age IS NULL OR NEW.age <= 0 OR (TG_OP = 'UPDATE' AND OLD.date_of_birth IS DISTINCT FROM NEW.date_of_birth AND OLD.age = NEW.age) THEN
            NEW.age := v_calculated_age;
        ELSIF NEW.age < 18 THEN
            NEW.age := 18;
        END IF;
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Attach trigger to profiles table
DROP TRIGGER IF EXISTS trg_sync_profile_age ON profiles;
CREATE TRIGGER trg_sync_profile_age
    BEFORE INSERT OR UPDATE ON profiles
    FOR EACH ROW
    EXECUTE FUNCTION fn_sync_profile_age();

-- Backfill existing profiles with GREATEST(18, calculated_age) to respect profiles_age_check
UPDATE profiles
SET age = GREATEST(18, EXTRACT(YEAR FROM age(CURRENT_DATE, date_of_birth))::INT)
WHERE date_of_birth IS NOT NULL
  AND (age IS NULL OR age <= 0 OR (age = 18 AND EXTRACT(YEAR FROM age(CURRENT_DATE, date_of_birth))::INT > 18));

-- Update fn_get_filtered_feed with DOB age fallback
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
    WHERE (
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
$$ LANGUAGE plpgsql SECURITY DEFINER;
