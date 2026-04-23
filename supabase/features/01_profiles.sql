-- Last run: 2025-02-12 — Update when re-run in Supabase SQL Editor
-- =====================================================
-- 01. PROFILES FEATURE
-- Handles core user identity and bio data.
-- =====================================================
-- Enable extensions
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
-- =====================================================
-- TABLE: profiles
-- =====================================================
CREATE TABLE IF NOT EXISTS public.profiles (
  -- Keys
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
  -- Contact
  phone_number TEXT UNIQUE,
  email TEXT,
  -- Personal
  full_name TEXT NOT NULL,
  surname TEXT NOT NULL,
  gotra TEXT,
  age INTEGER NOT NULL CHECK (
    age >= 18
    AND age <= 100
  ),
  date_of_birth DATE,
  gender TEXT NOT NULL DEFAULT 'Female' CHECK (gender IN ('Male', 'Female', 'Other')),
  height TEXT NOT NULL,
  complexion TEXT,
  blood_group TEXT,
  marital_status TEXT DEFAULT 'Never Married',
  -- Birth
  birth_place TEXT,
  birth_time TEXT,
  -- Professional
  education TEXT NOT NULL,
  education_details TEXT,
  profession TEXT NOT NULL,
  job_details TEXT,
  company TEXT,
  annual_income TEXT,
  -- Location
  state TEXT,
  district TEXT,
  taluka TEXT,
  village TEXT,
  current_location TEXT NOT NULL DEFAULT '',
  permanent_location TEXT,
  native_place TEXT,
  -- Family
  father_name TEXT,
  father_occupation TEXT,
  mother_name TEXT,
  mother_occupation TEXT,
  siblings_count INTEGER DEFAULT 0,
  sister_count INTEGER DEFAULT 0,
  brother_count INTEGER DEFAULT 0,
  siblings_data JSONB DEFAULT '[]',
  family_type TEXT,
  family_status TEXT,
  -- Status & Bio
  marriage_readiness TEXT DEFAULT 'Ready for marriage',
  about_self TEXT,
  partner_expectations TEXT,
  expectation TEXT,
  -- System Flags
  is_premium BOOLEAN DEFAULT FALSE,
  profile_completion INTEGER DEFAULT 0 CHECK (
    profile_completion >= 0
    AND profile_completion <= 100
  ),
  is_verified BOOLEAN DEFAULT FALSE,
  trust_score INTEGER DEFAULT 0 CHECK (
    trust_score >= 0
    AND trust_score <= 100
  ),
  is_active BOOLEAN DEFAULT TRUE,
  is_pdf_unlocked BOOLEAN DEFAULT FALSE,
  is_admin BOOLEAN DEFAULT FALSE,
  email_verified BOOLEAN DEFAULT FALSE,
  phone_verified BOOLEAN DEFAULT FALSE,
  -- Timestamps
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW(),
  -- [Scaling] 10M DAU Support Columns
  fcm_token TEXT,
  search_vector tsvector,
  CONSTRAINT profiles_user_id_unique UNIQUE (user_id)
);
-- Migrations: Add columns for existing DBs (idempotent)
ALTER TABLE public.profiles
ADD COLUMN IF NOT EXISTS email_verified BOOLEAN DEFAULT FALSE;
ALTER TABLE public.profiles
ADD COLUMN IF NOT EXISTS phone_verified BOOLEAN DEFAULT FALSE;
-- =====================================================
-- INDEXES (Production: feed query = is_active + gender + created_at)
-- =====================================================
CREATE INDEX IF NOT EXISTS idx_profiles_user_id ON public.profiles(user_id);
CREATE INDEX IF NOT EXISTS idx_profiles_phone_number ON public.profiles(phone_number);
CREATE INDEX IF NOT EXISTS idx_profiles_surname ON public.profiles(surname);
CREATE INDEX IF NOT EXISTS idx_profiles_gender ON public.profiles(gender);
CREATE INDEX IF NOT EXISTS idx_profiles_created_at ON public.profiles(created_at);
CREATE INDEX IF NOT EXISTS idx_profiles_fts ON public.profiles USING GIN(search_vector);
-- Feed discovery: is_active=true, opposite gender, ORDER BY created_at DESC
CREATE INDEX IF NOT EXISTS idx_profiles_feed_discovery ON public.profiles(is_active, gender, created_at DESC NULLS LAST)
WHERE is_active = true;
-- =====================================================
-- RLS (ROW LEVEL SECURITY)
-- =====================================================
ALTER TABLE public.profiles ENABLE ROW LEVEL SECURITY;
-- Select policy: Anyone seen active profiles
DROP POLICY IF EXISTS "profiles_select_active" ON public.profiles;
CREATE POLICY "profiles_select_active" ON public.profiles FOR
SELECT USING (is_active = true);
-- Insert policy: Users can create their own profile
DROP POLICY IF EXISTS "profiles_insert_own" ON public.profiles;
CREATE POLICY "profiles_insert_own" ON public.profiles FOR
INSERT WITH CHECK (auth.uid() = user_id);
-- Update policy: Users can update their own profile
DROP POLICY IF EXISTS "profiles_update_own" ON public.profiles;
CREATE POLICY "profiles_update_own" ON public.profiles FOR
UPDATE USING (auth.uid() = user_id);
-- =====================================================
-- TIMESTAMP TRIGGER
-- =====================================================
CREATE OR REPLACE FUNCTION public.fn_update_timestamp() RETURNS TRIGGER AS $$ BEGIN NEW.updated_at = NOW();
RETURN NEW;
END;
$$ LANGUAGE plpgsql;
DROP TRIGGER IF EXISTS tr_profiles_update_timestamp ON public.profiles;
CREATE TRIGGER tr_profiles_update_timestamp BEFORE
UPDATE ON public.profiles FOR EACH ROW EXECUTE FUNCTION public.fn_update_timestamp();

-- FTS TRIGGER logic (Scaling)
CREATE OR REPLACE FUNCTION public.fn_profiles_generate_search_vector() 
RETURNS TRIGGER AS $$
BEGIN
  NEW.search_vector := 
    setweight(to_tsvector('simple', COALESCE(NEW.full_name, '')), 'A') ||
    setweight(to_tsvector('simple', COALESCE(NEW.surname, '')), 'A') ||
    setweight(to_tsvector('simple', COALESCE(NEW.gotra, '')), 'B') ||
    setweight(to_tsvector('simple', COALESCE(NEW.village, '')), 'C') ||
    setweight(to_tsvector('simple', COALESCE(NEW.district, '')), 'D');
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS tr_profiles_update_search_vector ON public.profiles;
CREATE TRIGGER tr_profiles_update_search_vector
BEFORE INSERT OR UPDATE OF full_name, surname, gotra, village, district
ON public.profiles
FOR EACH ROW EXECUTE FUNCTION public.fn_profiles_generate_search_vector();
-- =====================================================
-- MASTER RPC FUNCTION: fn_manage_profile
-- =====================================================
CREATE OR REPLACE FUNCTION public.fn_manage_profile(action TEXT, payload JSONB) RETURNS JSONB AS $$
DECLARE v_user_id UUID := auth.uid();
v_result JSONB;
BEGIN IF v_user_id IS NULL THEN RAISE EXCEPTION 'Not authenticated';
END IF;
CASE
  action
  WHEN 'update_bio' THEN
  UPDATE public.profiles
  SET about_self = COALESCE(payload->>'about_self', about_self),
    partner_expectations = COALESCE(
      payload->>'partner_expectations',
      partner_expectations
    ),
    expectation = COALESCE(payload->>'expectation', expectation),
    updated_at = NOW()
  WHERE user_id = v_user_id;
v_result := jsonb_build_object('status', 'success', 'message', 'Bio updated');
WHEN 'update_personal' THEN
UPDATE public.profiles
SET full_name = COALESCE(payload->>'full_name', full_name),
  surname = COALESCE(payload->>'surname', surname),
  age = (payload->>'age')::INTEGER,
  gender = COALESCE(payload->>'gender', gender),
  updated_at = NOW()
WHERE user_id = v_user_id;
v_result := jsonb_build_object(
  'status',
  'success',
  'message',
  'Personal data updated'
);
WHEN 'set_active' THEN
UPDATE public.profiles
SET is_active = (payload->>'is_active')::BOOLEAN,
  updated_at = NOW()
WHERE user_id = v_user_id;
v_result := jsonb_build_object(
  'status',
  'success',
  'is_active',
  payload->>'is_active'
);
WHEN 'delete_account' THEN -- Call the deletion function (defined in safety/reset later or as standalone)
-- For now, a clean wipe of the profile
DELETE FROM public.profiles
WHERE user_id = v_user_id;
v_result := jsonb_build_object(
  'status',
  'success',
  'message',
  'Profile deleted'
);
ELSE RAISE EXCEPTION 'Invalid action: %',
action;
END CASE
;
RETURN v_result;
EXCEPTION
WHEN OTHERS THEN RETURN jsonb_build_object('status', 'error', 'message', SQLERRM);
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;
GRANT EXECUTE ON FUNCTION public.fn_manage_profile(TEXT, JSONB) TO authenticated;