-- Last run: 2025-02-13 — Update when re-run in Supabase SQL Editor
-- =====================================================
-- 14. AUTOMATED MATCH TRIGGER (Optional one-time backfill)
-- NOTE: Auto-match logic lives in 06_shares.sql.
-- Run this ONLY to fix existing mutual shares that weren't auto-matched.
-- =====================================================

-- Ensure status check exists (idempotent)
DO $$
BEGIN
  ALTER TABLE public.profile_shares DROP CONSTRAINT IF EXISTS profile_shares_status_check;
  ALTER TABLE public.profile_shares ADD CONSTRAINT profile_shares_status_check 
    CHECK (status IN ('pending', 'viewed', 'interested', 'rejected', 'new', 'matched'));
EXCEPTION WHEN duplicate_object THEN NULL;
END $$;

-- One-time backfill: match existing mutual in_app shares
UPDATE public.profile_shares s1
SET status = 'matched', updated_at = NOW()
FROM public.profile_shares s2
WHERE s1.sharing_method = 'in_app'
  AND s2.sharing_method = 'in_app'
  AND s1.sharer_id = s2.recipient_id
  AND s1.recipient_id = s2.sharer_id
  AND s1.status != 'matched'
  AND s1.id != s2.id;
