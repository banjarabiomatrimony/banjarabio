-- Last run: 2025-02-13 — Update when re-run in Supabase SQL Editor
-- =====================================================
-- 13. REFERRALS & REWARDS
-- Depends on: 08_subscriptions, 01_profiles
-- =====================================================
-- Add referral_code to profiles (idempotent)
ALTER TABLE public.profiles
ADD COLUMN IF NOT EXISTS referral_code TEXT UNIQUE;
CREATE TABLE IF NOT EXISTS public.referrals (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  referrer_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  referred_user_id UUID UNIQUE REFERENCES auth.users(id) ON DELETE CASCADE,
  status TEXT DEFAULT 'pending' CHECK (status IN ('pending', 'completed')),
  created_at TIMESTAMPTZ DEFAULT NOW()
);
CREATE TABLE IF NOT EXISTS public.referral_stats (
  user_id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
  referral_count INTEGER DEFAULT 0,
  rewards_earned INTEGER DEFAULT 0,
  last_reward_at TIMESTAMPTZ,
  updated_at TIMESTAMPTZ DEFAULT NOW()
);
CREATE INDEX IF NOT EXISTS idx_referrals_referrer ON public.referrals(referrer_id);
CREATE INDEX IF NOT EXISTS idx_referrals_status ON public.referrals(status);
-- RLS
ALTER TABLE public.referrals ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.referral_stats ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS "Users view own referrals" ON public.referrals;
CREATE POLICY "Users view own referrals" ON public.referrals FOR
SELECT USING (
    referrer_id = auth.uid()
    OR referred_user_id = auth.uid()
  );
DROP POLICY IF EXISTS "Users view own referral stats" ON public.referral_stats;
CREATE POLICY "Users view own referral stats" ON public.referral_stats FOR
SELECT USING (user_id = auth.uid());
-- RPC: generate_code | redeem_code | complete_referral
-- Flutter calls supabase.rpc('fn_process_referral', { action, payload })
CREATE OR REPLACE FUNCTION public.fn_process_referral(action TEXT, payload JSONB DEFAULT '{}') RETURNS JSONB LANGUAGE plpgsql SECURITY DEFINER
SET search_path = public AS $$
DECLARE v_uid UUID;
v_code TEXT;
v_referrer_id UUID;
v_referred_id UUID;
v_ref_id UUID;
v_row RECORD;
BEGIN v_uid := auth.uid();
IF v_uid IS NULL THEN RETURN jsonb_build_object('ok', false, 'error', 'unauthenticated');
END IF;
CASE
  action
  WHEN 'generate_code' THEN -- Generate unique code BANJARA-XXXX (4 alphanumeric)
  LOOP v_code := 'BANJARA-' || upper(substr(md5(gen_random_uuid()::text), 1, 4));
IF NOT EXISTS (
  SELECT 1
  FROM public.profiles
  WHERE referral_code = v_code
) THEN EXIT;
END IF;
END LOOP;
UPDATE public.profiles
SET referral_code = v_code
WHERE user_id = v_uid;
RETURN jsonb_build_object('ok', true, 'code', v_code);
WHEN 'redeem_code' THEN v_code := payload->>'code';
IF v_code IS NULL
OR trim(v_code) = '' THEN RETURN jsonb_build_object('ok', false, 'error', 'code_required');
END IF;
SELECT p.user_id INTO v_referrer_id
FROM public.profiles p
WHERE p.referral_code = upper(trim(v_code));
IF v_referrer_id IS NULL THEN RETURN jsonb_build_object('ok', false, 'error', 'invalid_code');
END IF;
IF v_referrer_id = v_uid THEN RETURN jsonb_build_object('ok', false, 'error', 'self_referral');
END IF;
-- Prevent duplicate referral for this user
IF EXISTS (
  SELECT 1
  FROM public.referrals
  WHERE referred_user_id = v_uid
) THEN RETURN jsonb_build_object('ok', false, 'error', 'already_referred');
END IF;
-- Insert as pending. Will be completed by trigger on profile completion.
INSERT INTO public.referrals (referrer_id, referred_user_id, status)
VALUES (v_referrer_id, v_uid, 'pending');
RETURN jsonb_build_object('ok', true);
WHEN 'complete_referral' THEN v_referred_id := (payload->>'referred_user_id')::UUID;
IF v_referred_id IS NULL THEN RETURN jsonb_build_object(
  'ok',
  false,
  'error',
  'referred_user_id_required'
);
END IF;
-- referral_id can be UUID or code string
IF payload->>'referral_id' ~ '^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}$' THEN v_ref_id := (payload->>'referral_id')::UUID;
-- Existing referral row (from deep link / invite)
SELECT referrer_id INTO v_referrer_id
FROM public.referrals
WHERE id = v_ref_id;
IF v_referrer_id IS NULL THEN RETURN jsonb_build_object('ok', false, 'error', 'referral_not_found');
END IF;
IF v_referrer_id = v_referred_id THEN RETURN jsonb_build_object('ok', false, 'error', 'self_referral');
END IF;
IF EXISTS (
  SELECT 1
  FROM public.referrals
  WHERE referred_user_id = v_referred_id
)
AND (
  SELECT referred_user_id
  FROM public.referrals
  WHERE id = v_ref_id
) IS DISTINCT
FROM v_referred_id THEN RETURN jsonb_build_object('ok', false, 'error', 'already_referred');
END IF;
-- Insert as pending.
INSERT INTO public.referrals (referrer_id, referred_user_id, status)
VALUES (v_referrer_id, v_referred_id, 'pending');
END IF;
RETURN jsonb_build_object('ok', true);
ELSE RETURN jsonb_build_object('ok', false, 'error', 'unknown_action');
END CASE
;
END;
$$;
GRANT EXECUTE ON FUNCTION public.fn_process_referral(TEXT, JSONB) TO authenticated;
-- Reward: 3 referrals = 1 month Gold (use gold - matches subscriptions.plan_type)
CREATE OR REPLACE FUNCTION public.fn_on_referral_completed() RETURNS TRIGGER AS $$
DECLARE v_count INT;
BEGIN -- Reward Rreferree (New User) immediately - 30 days Gold
UPDATE public.subscriptions
SET expires_at = COALESCE(expires_at, NOW()) + INTERVAL '30 days',
  plan_type = 'gold',
  status = 'active',
  updated_at = NOW()
WHERE user_id = NEW.referred_user_id;
-- Reward Referrer (Old User)
INSERT INTO public.referral_stats (user_id, referral_count)
VALUES (NEW.referrer_id, 1) ON CONFLICT (user_id) DO
UPDATE
SET referral_count = public.referral_stats.referral_count + 1,
  updated_at = NOW();
SELECT referral_count INTO v_count
FROM public.referral_stats
WHERE user_id = NEW.referrer_id;
-- Every referral gives 30 days Gold to referrer as well
UPDATE public.subscriptions
SET expires_at = COALESCE(expires_at, NOW()) + INTERVAL '30 days',
  plan_type = 'gold',
  status = 'active',
  updated_at = NOW()
WHERE user_id = NEW.referrer_id;
UPDATE public.referral_stats
SET rewards_earned = rewards_earned + 1,
  last_reward_at = NOW()
WHERE user_id = NEW.referrer_id;
RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;
-- Trigger to complete referral when profile reaches 100%
CREATE OR REPLACE FUNCTION public.fn_complete_referral_on_profile_completion() RETURNS TRIGGER AS $$ BEGIN IF NEW.profile_completion >= 100
  AND OLD.profile_completion < 100 THEN
UPDATE public.referrals
SET status = 'completed'
WHERE referred_user_id = NEW.user_id
  AND status = 'pending';
END IF;
RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;
DROP TRIGGER IF EXISTS tr_complete_referral_on_profile_completion ON public.profiles;
CREATE TRIGGER tr_complete_referral_on_profile_completion
AFTER
UPDATE OF profile_completion ON public.profiles FOR EACH ROW EXECUTE FUNCTION public.fn_complete_referral_on_profile_completion();
DROP TRIGGER IF EXISTS tr_referral_completed ON public.referrals;
CREATE TRIGGER tr_referral_completed
AFTER
UPDATE OF status ON public.referrals FOR EACH ROW
  WHEN (
    NEW.status = 'completed'
    AND OLD.status = 'pending'
  ) EXECUTE FUNCTION public.fn_on_referral_completed();