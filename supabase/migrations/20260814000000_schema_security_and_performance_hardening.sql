-- ============================================================================
-- Migration: 20260814000000_schema_security_and_performance_hardening.sql
-- Purpose: Resolve Supabase Security & Performance Advisor lints
--   1. Add covering indexes for unindexed foreign keys
--   2. Fix mutable search_path on SECURITY DEFINER functions
--   3. Revoke unnecessary anon EXECUTE privileges on internal/admin RPCs
--   4. Optimize RLS policies to use subquery InitPlans (select auth.uid())
-- ============================================================================

-- ----------------------------------------------------------------------------
-- 1. Unindexed Foreign Keys Optimization
-- ----------------------------------------------------------------------------
CREATE INDEX IF NOT EXISTS idx_search_match_notifications_intent_id 
  ON public.search_match_notifications(intent_id);

CREATE INDEX IF NOT EXISTS idx_whatsapp_notification_logs_intent_id 
  ON public.whatsapp_notification_logs(intent_id);

-- ----------------------------------------------------------------------------
-- 2. Function Search Path Hardening (Mitigate search_path hijacking)
-- ----------------------------------------------------------------------------
DO $$
BEGIN
  IF EXISTS (SELECT 1 FROM pg_proc WHERE proname = 'fn_on_vouch_change') THEN
    ALTER FUNCTION public.fn_on_vouch_change() SET search_path = public, pg_temp;
  END IF;

  IF EXISTS (SELECT 1 FROM pg_proc WHERE proname = 'fn_get_relative_match_digests') THEN
    ALTER FUNCTION public.fn_get_relative_match_digests(integer) SET search_path = public, pg_temp;
  END IF;

  IF EXISTS (SELECT 1 FROM pg_proc WHERE proname = 'fn_match_browse_intents_for_new_profile') THEN
    ALTER FUNCTION public.fn_match_browse_intents_for_new_profile(uuid) SET search_path = public, pg_temp;
  END IF;
END $$;

-- ----------------------------------------------------------------------------
-- 3. Revoke Anon Role Execution on Internal / State-Modifying Functions
-- ----------------------------------------------------------------------------
DO $$
BEGIN
  -- Internal trigger/event functions
  IF EXISTS (SELECT 1 FROM pg_proc WHERE proname = 'fn_on_vouch_change') THEN
    REVOKE EXECUTE ON FUNCTION public.fn_on_vouch_change() FROM anon, public;
  END IF;
  IF EXISTS (SELECT 1 FROM pg_proc WHERE proname = 'fn_match_browse_intents_for_new_profile') THEN
    REVOKE EXECUTE ON FUNCTION public.fn_match_browse_intents_for_new_profile(uuid) FROM anon, public;
  END IF;

  -- Authenticated user actions (should not be callable by unauthenticated anon)
  IF EXISTS (SELECT 1 FROM pg_proc WHERE proname = 'fn_reset_selfie_verification') THEN
    REVOKE EXECUTE ON FUNCTION public.fn_reset_selfie_verification() FROM anon;
  END IF;
  IF EXISTS (SELECT 1 FROM pg_proc WHERE proname = 'fn_delete_own_account') THEN
    REVOKE EXECUTE ON FUNCTION public.fn_delete_own_account() FROM anon;
  END IF;
  IF EXISTS (SELECT 1 FROM pg_proc WHERE proname = 'fn_claim_daily_reward') THEN
    REVOKE EXECUTE ON FUNCTION public.fn_claim_daily_reward() FROM anon;
  END IF;
  IF EXISTS (SELECT 1 FROM pg_proc WHERE proname = 'fn_initialize_subscription') THEN
    REVOKE EXECUTE ON FUNCTION public.fn_initialize_subscription() FROM anon;
  END IF;
  IF EXISTS (SELECT 1 FROM pg_proc WHERE proname = 'fn_manage_bookmarks') THEN
    REVOKE EXECUTE ON FUNCTION public.fn_manage_bookmarks(text, jsonb) FROM anon;
  END IF;
  IF EXISTS (SELECT 1 FROM pg_proc WHERE proname = 'fn_manage_chat') THEN
    REVOKE EXECUTE ON FUNCTION public.fn_manage_chat(text, jsonb) FROM anon;
  END IF;
  IF EXISTS (SELECT 1 FROM pg_proc WHERE proname = 'fn_manage_photos') THEN
    REVOKE EXECUTE ON FUNCTION public.fn_manage_photos(text, jsonb) FROM anon;
  END IF;
  IF EXISTS (SELECT 1 FROM pg_proc WHERE proname = 'fn_manage_profile') THEN
    REVOKE EXECUTE ON FUNCTION public.fn_manage_profile(text, jsonb) FROM anon;
  END IF;
  IF EXISTS (SELECT 1 FROM pg_proc WHERE proname = 'fn_manage_safety') THEN
    REVOKE EXECUTE ON FUNCTION public.fn_manage_safety(text, jsonb) FROM anon;
  END IF;
  IF EXISTS (SELECT 1 FROM pg_proc WHERE proname = 'fn_manage_shares') THEN
    REVOKE EXECUTE ON FUNCTION public.fn_manage_shares(text, jsonb) FROM anon;
  END IF;
  IF EXISTS (SELECT 1 FROM pg_proc WHERE proname = 'fn_manage_subscription') THEN
    REVOKE EXECUTE ON FUNCTION public.fn_manage_subscription(text, jsonb) FROM anon;
  END IF;
  IF EXISTS (SELECT 1 FROM pg_proc WHERE proname = 'fn_manage_verification') THEN
    REVOKE EXECUTE ON FUNCTION public.fn_manage_verification(text, jsonb) FROM anon;
  END IF;
  IF EXISTS (SELECT 1 FROM pg_proc WHERE proname = 'fn_process_payment') THEN
    REVOKE EXECUTE ON FUNCTION public.fn_process_payment(text, jsonb) FROM anon;
  END IF;
  IF EXISTS (SELECT 1 FROM pg_proc WHERE proname = 'fn_process_referral') THEN
    REVOKE EXECUTE ON FUNCTION public.fn_process_referral(text, jsonb) FROM anon;
  END IF;
  IF EXISTS (SELECT 1 FROM pg_proc WHERE proname = 'fn_register_creator_referral') THEN
    REVOKE EXECUTE ON FUNCTION public.fn_register_creator_referral(text) FROM anon;
  END IF;
  IF EXISTS (SELECT 1 FROM pg_proc WHERE proname = 'fn_upsert_device_token') THEN
    REVOKE EXECUTE ON FUNCTION public.fn_upsert_device_token(text, text, text) FROM anon;
  END IF;
  IF EXISTS (SELECT 1 FROM pg_proc WHERE proname = 'fn_validate_coupon') THEN
    REVOKE EXECUTE ON FUNCTION public.fn_validate_coupon(text) FROM anon;
  END IF;
END $$;

-- ----------------------------------------------------------------------------
-- 4. Auth RLS InitPlan Performance Hardening
-- Replace raw auth.uid() calls with (select auth.uid()) for query-level caching
-- ----------------------------------------------------------------------------

-- Table: user_browse_intents
DO $$
BEGIN
  IF EXISTS (SELECT 1 FROM information_schema.tables WHERE table_schema = 'public' AND table_name = 'user_browse_intents') THEN
    DROP POLICY IF EXISTS "Users can insert their own intents" ON public.user_browse_intents;
    CREATE POLICY "Users can insert their own intents"
      ON public.user_browse_intents FOR INSERT
      TO authenticated
      WITH CHECK ((select auth.uid()) = user_id);

    DROP POLICY IF EXISTS "Users can view their own intents" ON public.user_browse_intents;
    CREATE POLICY "Users can view their own intents"
      ON public.user_browse_intents FOR SELECT
      TO authenticated
      USING ((select auth.uid()) = user_id);
  END IF;
END $$;

-- Table: user_devices
DO $$
BEGIN
  IF EXISTS (SELECT 1 FROM information_schema.tables WHERE table_schema = 'public' AND table_name = 'user_devices') THEN
    DROP POLICY IF EXISTS "Users can read own device" ON public.user_devices;
    CREATE POLICY "Users can read own device"
      ON public.user_devices FOR SELECT
      TO authenticated
      USING (user_id = (select auth.uid()));

    DROP POLICY IF EXISTS "Users can upsert own device" ON public.user_devices;
    CREATE POLICY "Users can upsert own device"
      ON public.user_devices FOR INSERT
      TO authenticated
      WITH CHECK (user_id = (select auth.uid()));

    DROP POLICY IF EXISTS "Users can update own device" ON public.user_devices;
    CREATE POLICY "Users can update own device"
      ON public.user_devices FOR UPDATE
      TO authenticated
      USING (user_id = (select auth.uid()))
      WITH CHECK (user_id = (select auth.uid()));
  END IF;
END $$;

-- Table: whatsapp_notification_logs
DO $$
BEGIN
  IF EXISTS (SELECT 1 FROM information_schema.tables WHERE table_schema = 'public' AND table_name = 'whatsapp_notification_logs') THEN
    DROP POLICY IF EXISTS "Users can read own whatsapp notification logs" ON public.whatsapp_notification_logs;
    CREATE POLICY "Users can read own whatsapp notification logs"
      ON public.whatsapp_notification_logs FOR SELECT
      TO authenticated
      USING (user_id = (select auth.uid()));
  END IF;
END $$;

-- Table: bookmarks
DO $$
BEGIN
  IF EXISTS (SELECT 1 FROM information_schema.tables WHERE table_schema = 'public' AND table_name = 'bookmarks') THEN
    DROP POLICY IF EXISTS "bookmarks_select_own" ON public.bookmarks;
    CREATE POLICY "bookmarks_select_own"
      ON public.bookmarks FOR SELECT
      TO authenticated
      USING (user_id = (select auth.uid()));

    DROP POLICY IF EXISTS "bookmarks_insert_own" ON public.bookmarks;
    CREATE POLICY "bookmarks_insert_own"
      ON public.bookmarks FOR INSERT
      TO authenticated
      WITH CHECK (user_id = (select auth.uid()));

    DROP POLICY IF EXISTS "bookmarks_delete_own" ON public.bookmarks;
    CREATE POLICY "bookmarks_delete_own"
      ON public.bookmarks FOR DELETE
      TO authenticated
      USING (user_id = (select auth.uid()));
  END IF;
END $$;

-- Table: daily_rewards
DO $$
BEGIN
  IF EXISTS (SELECT 1 FROM information_schema.tables WHERE table_schema = 'public' AND table_name = 'daily_rewards') THEN
    DROP POLICY IF EXISTS "daily_rewards_select_own" ON public.daily_rewards;
    CREATE POLICY "daily_rewards_select_own"
      ON public.daily_rewards FOR SELECT
      TO authenticated
      USING (user_id = (select auth.uid()));

    DROP POLICY IF EXISTS "daily_rewards_insert_own" ON public.daily_rewards;
    CREATE POLICY "daily_rewards_insert_own"
      ON public.daily_rewards FOR INSERT
      TO authenticated
      WITH CHECK (user_id = (select auth.uid()));

    DROP POLICY IF EXISTS "daily_rewards_update_own" ON public.daily_rewards;
    CREATE POLICY "daily_rewards_update_own"
      ON public.daily_rewards FOR UPDATE
      TO authenticated
      USING (user_id = (select auth.uid()))
      WITH CHECK (user_id = (select auth.uid()));
  END IF;
END $$;

-- Table: referrals
DO $$
BEGIN
  IF EXISTS (SELECT 1 FROM information_schema.tables WHERE table_schema = 'public' AND table_name = 'referrals') THEN
    DROP POLICY IF EXISTS "referrals_select_own" ON public.referrals;
    CREATE POLICY "referrals_select_own"
      ON public.referrals FOR SELECT
      TO authenticated
      USING (referrer_id = (select auth.uid()) OR referred_user_id = (select auth.uid()));

    DROP POLICY IF EXISTS "referrals_insert_own" ON public.referrals;
    CREATE POLICY "referrals_insert_own"
      ON public.referrals FOR INSERT
      TO authenticated
      WITH CHECK (referrer_id = (select auth.uid()));
  END IF;
END $$;

-- Table: referral_stats
DO $$
BEGIN
  IF EXISTS (SELECT 1 FROM information_schema.tables WHERE table_schema = 'public' AND table_name = 'referral_stats') THEN
    DROP POLICY IF EXISTS "referral_stats_select_own" ON public.referral_stats;
    CREATE POLICY "referral_stats_select_own"
      ON public.referral_stats FOR SELECT
      TO authenticated
      USING (user_id = (select auth.uid()));
  END IF;
END $$;

-- Table: profile_shares
DO $$
BEGIN
  IF EXISTS (SELECT 1 FROM information_schema.tables WHERE table_schema = 'public' AND table_name = 'profile_shares') THEN
    DROP POLICY IF EXISTS "profile_shares_select_own" ON public.profile_shares;
    CREATE POLICY "profile_shares_select_own"
      ON public.profile_shares FOR SELECT
      TO authenticated
      USING ((select auth.uid()) IN (SELECT p.user_id FROM profiles p WHERE p.id = profile_shares.sharer_id OR p.id = profile_shares.recipient_id));

    DROP POLICY IF EXISTS "profile_shares_insert_own" ON public.profile_shares;
    CREATE POLICY "profile_shares_insert_own"
      ON public.profile_shares FOR INSERT
      TO authenticated
      WITH CHECK ((select auth.uid()) = (SELECT p.user_id FROM profiles p WHERE p.id = profile_shares.sharer_id));

    DROP POLICY IF EXISTS "profile_shares_delete_own" ON public.profile_shares;
    CREATE POLICY "profile_shares_delete_own"
      ON public.profile_shares FOR DELETE
      TO authenticated
      USING ((select auth.uid()) = (SELECT p.user_id FROM profiles p WHERE p.id = profile_shares.sharer_id));
  END IF;
END $$;

-- Table: photos
DO $$
BEGIN
  IF EXISTS (SELECT 1 FROM information_schema.tables WHERE table_schema = 'public' AND table_name = 'photos') THEN
    DROP POLICY IF EXISTS "photos_insert_own" ON public.photos;
    CREATE POLICY "photos_insert_own"
      ON public.photos FOR INSERT
      TO authenticated
      WITH CHECK ((select auth.uid()) = (SELECT p.user_id FROM profiles p WHERE p.id = photos.profile_id));

    DROP POLICY IF EXISTS "photos_update_own" ON public.photos;
    CREATE POLICY "photos_update_own"
      ON public.photos FOR UPDATE
      TO authenticated
      USING ((select auth.uid()) = (SELECT p.user_id FROM profiles p WHERE p.id = photos.profile_id))
      WITH CHECK ((select auth.uid()) = (SELECT p.user_id FROM profiles p WHERE p.id = photos.profile_id));

    DROP POLICY IF EXISTS "photos_delete_own" ON public.photos;
    CREATE POLICY "photos_delete_own"
      ON public.photos FOR DELETE
      TO authenticated
      USING ((select auth.uid()) = (SELECT p.user_id FROM profiles p WHERE p.id = photos.profile_id));
  END IF;
END $$;
