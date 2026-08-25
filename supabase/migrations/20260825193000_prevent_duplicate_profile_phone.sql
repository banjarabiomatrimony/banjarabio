-- ============================================================================
-- 📱 [BanjaraBio] Prevent Duplicate Profile Phone Numbers & Availability Check
-- ============================================================================

-- 1. Helper function to normalize phone numbers (IMMUTABLE for index use)
CREATE OR REPLACE FUNCTION public.fn_normalize_phone(p_phone TEXT)
RETURNS TEXT AS $$
DECLARE
    v_cleaned TEXT;
BEGIN
    IF p_phone IS NULL OR trim(p_phone) = '' THEN
        RETURN NULL;
    END IF;
    v_cleaned := regexp_replace(p_phone, '\D', '', 'g');
    IF length(v_cleaned) >= 10 THEN
        RETURN RIGHT(v_cleaned, 10);
    END IF;
    RETURN v_cleaned;
END;
$$ LANGUAGE plpgsql IMMUTABLE;

-- 2. Partial unique index on normalized 10-digit phone number
CREATE UNIQUE INDEX IF NOT EXISTS idx_profiles_normalized_phone
ON public.profiles (public.fn_normalize_phone(phone_number))
WHERE phone_number IS NOT NULL AND trim(phone_number) != '';

-- 3. Security Definer RPC for checking phone number availability
CREATE OR REPLACE FUNCTION public.fn_check_phone_available(
    p_phone TEXT,
    p_exclude_user_id UUID DEFAULT NULL
)
RETURNS BOOLEAN AS $$
DECLARE
    v_norm TEXT;
    v_exists BOOLEAN;
BEGIN
    v_norm := public.fn_normalize_phone(p_phone);
    IF v_norm IS NULL OR length(v_norm) < 10 THEN
        -- If phone is empty or incomplete, don't flag as taken
        RETURN TRUE;
    END IF;

    SELECT EXISTS (
        SELECT 1
        FROM public.profiles
        WHERE public.fn_normalize_phone(phone_number) = v_norm
          AND (p_exclude_user_id IS NULL OR user_id != p_exclude_user_id)
    ) INTO v_exists;

    RETURN NOT v_exists;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER
SET search_path = public, extensions;

-- Allow anon & authenticated users to verify phone availability before profile creation
REVOKE ALL ON FUNCTION public.fn_check_phone_available(TEXT, UUID) FROM PUBLIC;
GRANT EXECUTE ON FUNCTION public.fn_check_phone_available(TEXT, UUID) TO anon, authenticated;
