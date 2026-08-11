-- =============================================================
-- Migration: secure_vouches_notifications
-- Purpose: Enable RLS on public.vouches and public.notification_queue
--          and apply appropriate access policies.
-- Created: 2026-06-09
-- =============================================================

-- 1. Enable RLS
ALTER TABLE public.vouches ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.notification_queue ENABLE ROW LEVEL SECURITY;

-- 2. Vouches Policies

-- SELECT: Anyone can view vouches (needed for profile browsing)
DROP POLICY IF EXISTS "vouches_select_public" ON public.vouches;
CREATE POLICY "vouches_select_public" ON public.vouches
  FOR SELECT
  USING (true);

-- INSERT: Only authenticated users can vouch, and only as themselves
DROP POLICY IF EXISTS "vouches_insert_own" ON public.vouches;
CREATE POLICY "vouches_insert_own" ON public.vouches
  FOR INSERT
  WITH CHECK (
    vouch_id IN (SELECT id FROM public.profiles WHERE user_id = auth.uid())
  );

-- DELETE: Only the voucher can remove their own vouch
DROP POLICY IF EXISTS "vouches_delete_own" ON public.vouches;
CREATE POLICY "vouches_delete_own" ON public.vouches
  FOR DELETE
  USING (
    vouch_id IN (SELECT id FROM public.profiles WHERE user_id = auth.uid())
  );

-- 3. Notification Queue Policy
-- Deny all public/client access. Triggers (SECURITY DEFINER) and
-- service_role bypass RLS automatically.
DROP POLICY IF EXISTS "Deny all public access to notification_queue" ON public.notification_queue;
CREATE POLICY "Deny all public access to notification_queue" ON public.notification_queue
  FOR ALL
  USING (false);
