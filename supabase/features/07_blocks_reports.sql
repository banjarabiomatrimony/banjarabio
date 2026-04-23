-- Last run: 2025-02-12 — Update when re-run in Supabase SQL Editor
-- =====================================================
-- 07. SAFETY FEATURE (BLOCKS & REPORTS)
-- Handles user blocking and reporting (UGC Safety).
-- =====================================================

-- =====================================================
-- TABLE: user_blocks
-- =====================================================
CREATE TABLE IF NOT EXISTS public.user_blocks (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  blocker_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
  blocked_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  UNIQUE(blocker_id, blocked_id),
  CONSTRAINT no_self_block CHECK (blocker_id != blocked_id)
);

-- =====================================================
-- TABLE: user_reports
-- =====================================================
CREATE TABLE IF NOT EXISTS public.user_reports (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  reporter_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
  reported_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
  reason TEXT NOT NULL,
  details TEXT,
  status TEXT DEFAULT 'pending' CHECK (status IN ('pending', 'reviewed', 'action_taken')),
  created_at TIMESTAMPTZ DEFAULT NOW(),
  CONSTRAINT no_self_report CHECK (reporter_id != reported_id)
);

-- INDEXES (Block check on every feed load - critical)
CREATE INDEX IF NOT EXISTS idx_user_blocks_blocker ON public.user_blocks(blocker_id);
CREATE INDEX IF NOT EXISTS idx_user_blocks_blocked ON public.user_blocks(blocked_id);
CREATE INDEX IF NOT EXISTS idx_user_reports_reported ON public.user_reports(reported_id);

-- RLS
ALTER TABLE public.user_blocks ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.user_reports ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Users manage own blocks" ON public.user_blocks;
CREATE POLICY "Users manage own blocks" ON public.user_blocks FOR ALL USING (auth.uid() = blocker_id);

DROP POLICY IF EXISTS "Users create reports" ON public.user_reports;
CREATE POLICY "Users create reports" ON public.user_reports FOR INSERT WITH CHECK (auth.uid() = reporter_id);

DROP POLICY IF EXISTS "Users view own reports" ON public.user_reports;
CREATE POLICY "Users view own reports" ON public.user_reports FOR SELECT USING (auth.uid() = reporter_id);

-- =====================================================
-- MASTER RPC FUNCTION: fn_manage_safety
-- =====================================================
CREATE OR REPLACE FUNCTION public.fn_manage_safety(
    action TEXT,
    payload JSONB
) RETURNS JSONB AS $$
DECLARE
    v_user_id UUID := auth.uid();
    v_target_id UUID;
    v_result JSONB;
BEGIN
    IF v_user_id IS NULL THEN RAISE EXCEPTION 'Not authenticated'; END IF;
    v_target_id := (payload->>'target_id')::UUID;

    CASE action
        WHEN 'block' THEN
            INSERT INTO public.user_blocks (blocker_id, blocked_id) VALUES (v_user_id, v_target_id)
            ON CONFLICT (blocker_id, blocked_id) DO NOTHING;
            v_result := jsonb_build_object('status', 'success', 'message', 'User blocked');

        WHEN 'unblock' THEN
            DELETE FROM public.user_blocks WHERE blocker_id = v_user_id AND blocked_id = v_target_id;
            v_result := jsonb_build_object('status', 'success', 'message', 'User unblocked');

        WHEN 'report' THEN
            INSERT INTO public.user_reports (reporter_id, reported_id, reason, details)
            VALUES (v_user_id, v_target_id, payload->>'reason', payload->>'details');
            v_result := jsonb_build_object('status', 'success', 'message', 'Report submitted');

        ELSE RAISE EXCEPTION 'Invalid action';
    END CASE;

    RETURN v_result;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

GRANT EXECUTE ON FUNCTION public.fn_manage_safety(TEXT, JSONB) TO authenticated;
