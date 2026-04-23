-- Last run: 2025-02-12 — Update when re-run in Supabase SQL Editor
-- =====================================================
-- 05. BOOKMARKS FEATURE
-- Handles saved/favorite profiles.
-- =====================================================

-- =====================================================
-- TABLE: bookmarks
-- =====================================================
CREATE TABLE IF NOT EXISTS public.bookmarks (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  profile_id UUID NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  UNIQUE(user_id, profile_id)
);

-- INDEXES (user_id for "my bookmarks"; profile_id for "who bookmarked me")
CREATE INDEX IF NOT EXISTS idx_bookmarks_user_id ON public.bookmarks(user_id);
CREATE INDEX IF NOT EXISTS idx_bookmarks_profile_id ON public.bookmarks(profile_id);
CREATE INDEX IF NOT EXISTS idx_bookmarks_user_created
  ON public.bookmarks(user_id, created_at DESC);

-- RLS
ALTER TABLE public.bookmarks ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "bookmarks_manage_own" ON public.bookmarks;
CREATE POLICY "bookmarks_manage_own" ON public.bookmarks FOR ALL 
USING (auth.uid() = user_id);

-- =====================================================
-- MASTER RPC FUNCTION: fn_manage_bookmarks
-- =====================================================
CREATE OR REPLACE FUNCTION public.fn_manage_bookmarks(
    action TEXT,
    payload JSONB
) RETURNS JSONB AS $$
DECLARE
    v_user_id UUID := auth.uid();
    v_profile_id UUID;
    v_result JSONB;
BEGIN
    IF v_user_id IS NULL THEN RAISE EXCEPTION 'Not authenticated'; END IF;

    v_profile_id := (payload->>'profile_id')::UUID;

    CASE action
        WHEN 'add' THEN
            INSERT INTO public.bookmarks (user_id, profile_id) 
            VALUES (v_user_id, v_profile_id)
            ON CONFLICT (user_id, profile_id) DO NOTHING;
            v_result := jsonb_build_object('status', 'success', 'is_bookmarked', true);

        WHEN 'remove' THEN
            DELETE FROM public.bookmarks WHERE user_id = v_user_id AND profile_id = v_profile_id;
            v_result := jsonb_build_object('status', 'success', 'is_bookmarked', false);

        WHEN 'toggle' THEN
            IF EXISTS (SELECT 1 FROM public.bookmarks WHERE user_id = v_user_id AND profile_id = v_profile_id) THEN
                DELETE FROM public.bookmarks WHERE user_id = v_user_id AND profile_id = v_profile_id;
                v_result := jsonb_build_object('status', 'success', 'is_bookmarked', false);
            ELSE
                INSERT INTO public.bookmarks (user_id, profile_id) VALUES (v_user_id, v_profile_id);
                v_result := jsonb_build_object('status', 'success', 'is_bookmarked', true);
            END IF;

        WHEN 'clear_all' THEN
            DELETE FROM public.bookmarks WHERE user_id = v_user_id;
            v_result := jsonb_build_object('status', 'success', 'message', 'All bookmarks cleared');

        ELSE RAISE EXCEPTION 'Invalid action';
    END CASE;

    RETURN v_result;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

GRANT EXECUTE ON FUNCTION public.fn_manage_bookmarks(TEXT, JSONB) TO authenticated;
