-- Last run: 2025-02-12 — Update when re-run in Supabase SQL Editor
-- =====================================================
-- 03. VERIFICATION & TRUST FEATURE
-- Handles identity verification and trust score sync.
-- =====================================================

-- =====================================================
-- TABLE: verification_requests
-- =====================================================
CREATE TABLE IF NOT EXISTS public.verification_requests (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
  verification_type TEXT NOT NULL CHECK (verification_type IN ('selfie', 'govt_id', 'community_id', 'video_bio')),
  status TEXT NOT NULL DEFAULT 'pending' CHECK (status IN ('pending', 'approved', 'rejected')),
  payload JSONB DEFAULT '{}',
  rejection_reason TEXT,
  admin_notes TEXT,
  verified_at TIMESTAMPTZ,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW(),
  UNIQUE(user_id, verification_type)
);

-- Add admin_notes for existing DBs (idempotent)
ALTER TABLE public.verification_requests ADD COLUMN IF NOT EXISTS admin_notes TEXT;

-- =====================================================
-- TABLE: user_references
-- =====================================================
CREATE TABLE IF NOT EXISTS public.user_references (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
  reference_type TEXT NOT NULL CHECK (reference_type IN ('internal', 'external')),
  referenced_user_id UUID REFERENCES auth.users(id),
  name TEXT NOT NULL,
  phone_number TEXT NOT NULL,
  status TEXT NOT NULL DEFAULT 'pending' CHECK (status IN ('pending', 'verified', 'rejected')),
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- INDEXES (Trust score: user_id + verification_type + status)
CREATE INDEX IF NOT EXISTS idx_verification_requests_user_type
  ON public.verification_requests(user_id, verification_type, status);
CREATE INDEX IF NOT EXISTS idx_user_references_user_status
  ON public.user_references(user_id, status);

-- RLS
ALTER TABLE public.verification_requests ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.user_references ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Users can manage own requests" ON public.verification_requests;
CREATE POLICY "Users can manage own requests" ON public.verification_requests FOR ALL USING (auth.uid() = user_id);

DROP POLICY IF EXISTS "Users can manage own references" ON public.user_references;
CREATE POLICY "Users can manage own references" ON public.user_references FOR ALL USING (auth.uid() = user_id);

-- =====================================================
-- FUNCTION: Trust Score Calculation
-- =====================================================
CREATE OR REPLACE FUNCTION public.fn_calculate_trust_score(p_user_id UUID)
RETURNS INTEGER AS $$
DECLARE
  v_score INTEGER := 0;
  v_p_complete BOOLEAN;
  v_email_v BOOLEAN;
  v_phone_v BOOLEAN;
BEGIN
  -- 1. Profile Completion
  SELECT (profile_completion >= 100) INTO v_p_complete FROM public.profiles WHERE user_id = p_user_id;
  
  -- 2. Auth Confirmation
  SELECT (email_confirmed_at IS NOT NULL), (phone_confirmed_at IS NOT NULL)
  INTO v_email_v, v_phone_v FROM auth.users WHERE id = p_user_id;

  -- Logic
  IF v_phone_v THEN v_score := v_score + 10; END IF;
  IF v_email_v THEN v_score := v_score + 10; END IF;
  IF v_p_complete THEN v_score := v_score + 10; END IF;

  -- Manual Verifications
  IF EXISTS (SELECT 1 FROM verification_requests WHERE user_id = p_user_id AND verification_type = 'selfie' AND status = 'approved') THEN v_score := v_score + 15; END IF;
  IF EXISTS (SELECT 1 FROM verification_requests WHERE user_id = p_user_id AND verification_type = 'govt_id' AND status = 'approved') THEN v_score := v_score + 20; END IF;
  IF EXISTS (SELECT 1 FROM verification_requests WHERE user_id = p_user_id AND verification_type = 'community_id' AND status = 'approved') THEN v_score := v_score + 15; END IF;
  IF EXISTS (SELECT 1 FROM verification_requests WHERE user_id = p_user_id AND verification_type = 'video_bio' AND status = 'approved') THEN v_score := v_score + 10; END IF;
  IF EXISTS (SELECT 1 FROM user_references WHERE user_id = p_user_id AND status = 'verified') THEN v_score := v_score + 10; END IF;

  UPDATE public.profiles SET trust_score = v_score, is_verified = (v_score >= 80) WHERE user_id = p_user_id;
  RETURN v_score;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- =====================================================
-- MASTER RPC FUNCTION: fn_manage_verification
-- =====================================================
CREATE OR REPLACE FUNCTION public.fn_manage_verification(
    action TEXT,
    p_payload JSONB
) RETURNS JSONB AS $$
DECLARE
    v_user_id UUID := auth.uid();
    v_result JSONB;
BEGIN
    IF v_user_id IS NULL THEN RAISE EXCEPTION 'Not authenticated'; END IF;

    CASE action
        WHEN 'submit_request' THEN
            INSERT INTO public.verification_requests (user_id, verification_type, payload)
            VALUES (v_user_id, p_payload->>'type', COALESCE(p_payload->'payload', p_payload->'data', '{}'::jsonb))
            ON CONFLICT (user_id, verification_type) DO UPDATE SET 
              payload = EXCLUDED.payload, status = 'pending', updated_at = NOW();
            v_result := jsonb_build_object('status', 'success', 'message', 'Request submitted');

        WHEN 'add_reference' THEN
            INSERT INTO public.user_references (user_id, reference_type, name, phone_number)
            VALUES (v_user_id, p_payload->>'type', p_payload->>'name', p_payload->>'phone');
            v_result := jsonb_build_object('status', 'success', 'message', 'Reference added');

        WHEN 'update_status' THEN
            -- Admin function to update request status
            UPDATE public.verification_requests 
            SET status = p_payload->>'status', admin_notes = p_payload->>'notes', updated_at = NOW()
            WHERE id = (p_payload->>'request_id')::UUID;
            v_result := jsonb_build_object('status', 'success', 'message', 'Verification updated');

        WHEN 'recalc_score' THEN
            PERFORM public.fn_calculate_trust_score(v_user_id);
            v_result := jsonb_build_object('status', 'success', 'score', (SELECT trust_score FROM public.profiles WHERE user_id = v_user_id));

        ELSE RAISE EXCEPTION 'Invalid action';
    END CASE;

    RETURN v_result;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

GRANT EXECUTE ON FUNCTION public.fn_manage_verification(TEXT, JSONB) TO authenticated;
