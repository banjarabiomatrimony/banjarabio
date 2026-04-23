-- Last run: 2025-02-12 — Update when re-run in Supabase SQL Editor
-- =====================================================
-- 06. SHARES FEATURE
-- Handles profile sharing and auto-matching.
-- =====================================================
-- =====================================================
-- TABLE: profile_shares
-- ====================================================CREATE TABLE IF NOT EXISTS public.profile_shares (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  sharer_id UUID NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
  recipient_id UUID REFERENCES public.profiles(id) ON DELETE SET NULL,
  sharer_user_id UUID REFERENCES auth.users(id), -- [Scaling: O(1) RLS]
  recipient_user_id UUID REFERENCES auth.users(id), -- [Scaling: O(1) RLS]
  shared_profile_id UUID NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
  recipient_name TEXT,
  recipient_relation TEXT,
  sharing_method TEXT NOT NULL DEFAULT 'in_app' CHECK (sharing_method IN ('whatsapp', 'in_app', 'link')),
  status TEXT NOT NULL DEFAULT 'pending' CHECK (status IN ('pending', 'viewed', 'interested', 'rejected', 'new', 'matched')),
  view_count INTEGER DEFAULT 0,
  viewed_at TIMESTAMPTZ,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- INDEXES (Auto-match: sharer↔recipient lookup)
CREATE INDEX IF NOT EXISTS idx_profile_shares_sharer ON public.profile_shares(sharer_id);
CREATE INDEX IF NOT EXISTS idx_profile_shares_recipient ON public.profile_shares(recipient_id);
CREATE INDEX IF NOT EXISTS idx_profile_shares_sharer_user ON public.profile_shares(sharer_user_id);
CREATE INDEX IF NOT EXISTS idx_profile_shares_recipient_user ON public.profile_shares(recipient_user_id);

CREATE INDEX IF NOT EXISTS idx_profile_shares_match_lookup ON public.profile_shares(sharer_id, recipient_id, sharing_method)
WHERE sharing_method = 'in_app' AND recipient_id IS NOT NULL;

-- RLS (Optimized for 10M DAU)
ALTER TABLE public.profile_shares ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS "Users manage own shares" ON public.profile_shares;
CREATE POLICY "Users manage own shares" ON public.profile_shares FOR ALL 
USING ((SELECT auth.uid()) = sharer_user_id OR (SELECT auth.uid()) = recipient_user_id);

-- =====================================================
-- TRIGGERS: Auto-Match & ID Sync
-- =====================================================
CREATE OR REPLACE FUNCTION public.fn_sync_share_user_ids()
RETURNS TRIGGER AS $$
BEGIN
  SELECT user_id INTO NEW.sharer_user_id FROM public.profiles WHERE id = NEW.sharer_id;
  IF NEW.recipient_id IS NOT NULL THEN
    SELECT user_id INTO NEW.recipient_user_id FROM public.profiles WHERE id = NEW.recipient_id;
  END IF;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

DROP TRIGGER IF EXISTS tr_sync_share_user_ids ON public.profile_shares;
CREATE TRIGGER tr_sync_share_user_ids
BEFORE INSERT ON public.profile_shares
FOR EACH ROW EXECUTE FUNCTION public.fn_sync_share_user_ids();

CREATE OR REPLACE FUNCTION public.fn_auto_match_shares() RETURNS TRIGGER AS $$
DECLARE reverse_match_id UUID;
BEGIN IF NEW.status = 'matched' THEN RETURN NEW;
END IF;
IF NEW.sharing_method != 'in_app' THEN RETURN NEW;
END IF;
IF NEW.recipient_id IS NULL THEN RETURN NEW;
END IF;
SELECT id INTO reverse_match_id
FROM public.profile_shares
WHERE sharer_id = NEW.recipient_id
  AND recipient_id = NEW.sharer_id
  AND sharing_method = 'in_app'
  AND status != 'matched'
LIMIT 1;
IF reverse_match_id IS NOT NULL THEN NEW.status := 'matched';
UPDATE public.profile_shares
SET status = 'matched',
  updated_at = NOW()
WHERE id = reverse_match_id;
END IF;
RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;
DROP TRIGGER IF EXISTS tr_auto_match_shares ON public.profile_shares;
CREATE TRIGGER tr_auto_match_shares BEFORE
INSERT
  OR
UPDATE OF status ON public.profile_shares FOR EACH ROW EXECUTE FUNCTION public.fn_auto_match_shares();
-- =====================================================
-- VIEW: shared_profiles_view (API contract for ProfileShare)
-- =====================================================
DROP VIEW IF EXISTS public.shared_profiles_view CASCADE;
CREATE OR REPLACE VIEW public.shared_profiles_view AS
SELECT ps.id AS share_id,
  ps.sharer_id,
  ps.recipient_id,
  ps.shared_profile_id,
  ps.recipient_name,
  ps.recipient_relation,
  ps.sharing_method,
  ps.status,
  ps.view_count,
  ps.viewed_at,
  ps.created_at AS share_created_at,
  ps.updated_at AS share_updated_at,
  sp.full_name AS sharer_name,
  rp.full_name AS recipient_profile_name,
  p.full_name AS shared_profile_name,
  p.surname AS shared_profile_surname,
  p.age AS shared_profile_age,
  p.gender AS shared_profile_gender,
  p.education AS shared_profile_education,
  p.profession AS shared_profile_job,
  p.height AS shared_profile_height,
  p.marital_status AS shared_profile_marital_status,
  p.is_verified AS shared_profile_is_verified,
  p.is_premium AS shared_profile_is_premium,
  (
    SELECT public_url
    FROM public.photos
    WHERE profile_id = p.id
      AND is_primary = true
    LIMIT 1
  ) AS shared_profile_image
FROM public.profile_shares ps
  JOIN public.profiles p ON ps.shared_profile_id = p.id
  JOIN public.profiles sp ON ps.sharer_id = sp.id
  LEFT JOIN public.profiles rp ON ps.recipient_id = rp.id;
-- =====================================================
-- MASTER RPC FUNCTION: fn_manage_shares
-- =====================================================
CREATE OR REPLACE FUNCTION public.fn_manage_shares(action TEXT, payload JSONB) RETURNS JSONB AS $$
DECLARE v_user_id UUID := auth.uid();
v_profile_id UUID;
v_result JSONB;
BEGIN IF v_user_id IS NULL THEN RAISE EXCEPTION 'Not authenticated';
END IF;
SELECT id INTO v_profile_id
FROM public.profiles
WHERE user_id = v_user_id;
CASE
  action
  WHEN 'create_share' THEN -- Split logic based on whether we have a recipient (in-app) or not (external)
  IF (payload->>'recipient_id') IS NULL THEN
  INSERT INTO public.profile_shares (
      sharer_id,
      shared_profile_id,
      sharing_method,
      recipient_name,
      recipient_relation
    )
  VALUES (
      v_profile_id,
      (payload->>'profile_id')::UUID,
      COALESCE(payload->>'method', 'link'),
      payload->>'recipient_name',
      payload->>'recipient_relation'
    ) ON CONFLICT (sharer_id, shared_profile_id)
  WHERE (recipient_id IS NULL) DO
  UPDATE
  SET sharing_method = EXCLUDED.sharing_method,
    recipient_name = EXCLUDED.recipient_name,
    recipient_relation = EXCLUDED.recipient_relation,
    updated_at = NOW()
  RETURNING jsonb_build_object('id', id) INTO v_result;
ELSE
INSERT INTO public.profile_shares (
    sharer_id,
    recipient_id,
    shared_profile_id,
    sharing_method,
    recipient_name,
    recipient_relation
  )
VALUES (
    v_profile_id,
    (payload->>'recipient_id')::UUID,
    (payload->>'profile_id')::UUID,
    COALESCE(payload->>'method', 'in_app'),
    payload->>'recipient_name',
    payload->>'recipient_relation'
  ) ON CONFLICT (sharer_id, recipient_id, shared_profile_id)
WHERE (recipient_id IS NOT NULL) DO
UPDATE
SET sharing_method = EXCLUDED.sharing_method,
  recipient_name = EXCLUDED.recipient_name,
  recipient_relation = EXCLUDED.recipient_relation,
  updated_at = NOW()
RETURNING jsonb_build_object('id', id) INTO v_result;
END IF;
WHEN 'update_status' THEN
UPDATE public.profile_shares
SET status = payload->>'status',
  view_count = view_count + CASE
    WHEN payload->>'status' = 'viewed' THEN 1
    ELSE 0
  END,
  viewed_at = CASE
    WHEN payload->>'status' = 'viewed' THEN NOW()
    ELSE viewed_at
  END,
  updated_at = NOW()
WHERE id = (payload->>'share_id')::UUID
  AND (
    sharer_id = v_profile_id
    OR recipient_id = v_profile_id
  );
v_result := jsonb_build_object(
  'status',
  'success',
  'new_status',
  payload->>'status'
);
ELSE RAISE EXCEPTION 'Invalid action';
END CASE
;
RETURN v_result;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;
GRANT EXECUTE ON FUNCTION public.fn_manage_shares(TEXT, JSONB) TO authenticated;