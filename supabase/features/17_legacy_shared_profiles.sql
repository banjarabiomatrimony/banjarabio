-- Last run: 2026-02-28 — Update when re-run in Supabase SQL Editor
-- =====================================================
-- 17. LEGACY SHARED PROFILES TABLE
-- This is a legacy table from the earlier sharing implementation.
-- The current system uses `profile_shares` (06_shares.sql) and
-- the `shared_profiles_view` (also in 06_shares.sql).
-- Retained for backward compatibility and data preservation.
-- =====================================================
-- =====================================================
-- TABLE: shared_profiles (LEGACY)
-- =====================================================
CREATE TABLE IF NOT EXISTS public.shared_profiles (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    shared_by_user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    profile_id UUID NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
    shared_to_phone TEXT,
    message TEXT,
    is_viewed BOOLEAN DEFAULT FALSE,
    shared_at TIMESTAMPTZ DEFAULT NOW()
);
-- INDEXES
CREATE INDEX IF NOT EXISTS idx_shared_profiles_user ON public.shared_profiles(shared_by_user_id);
CREATE INDEX IF NOT EXISTS idx_shared_profiles_profile ON public.shared_profiles(profile_id);
-- RLS
ALTER TABLE public.shared_profiles ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS "Users manage own shared profiles" ON public.shared_profiles;
CREATE POLICY "Users manage own shared profiles" ON public.shared_profiles FOR ALL USING (auth.uid() = shared_by_user_id);