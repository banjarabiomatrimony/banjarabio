-- =============================================================
-- Migration: 20260813190000_rls_audit_remediation.sql
-- Purpose: P0 Security — Enable RLS on all client-accessible tables
--          that were missing ENABLE ROW LEVEL SECURITY statements.
--
-- IMPORTANT NOTES:
-- • profiles.user_id = auth.uid() (auth UUID)
-- • profiles.id = profile UUID (used as FK in photos, profile_shares, etc.)
-- • Tables using profile IDs need subquery to verify ownership via profiles.user_id
-- • All statements are idempotent (IF EXISTS / IF NOT EXISTS)
-- =============================================================

-- ─────────────────────────────────────────────────────────────
-- 1. ENABLE RLS on all unprotected tables
-- ─────────────────────────────────────────────────────────────
ALTER TABLE IF EXISTS public.profiles                ENABLE ROW LEVEL SECURITY;
ALTER TABLE IF EXISTS public.subscriptions           ENABLE ROW LEVEL SECURITY;
ALTER TABLE IF EXISTS public.bookmarks               ENABLE ROW LEVEL SECURITY;
ALTER TABLE IF EXISTS public.daily_rewards            ENABLE ROW LEVEL SECURITY;
ALTER TABLE IF EXISTS public.referrals               ENABLE ROW LEVEL SECURITY;
ALTER TABLE IF EXISTS public.referral_stats          ENABLE ROW LEVEL SECURITY;
ALTER TABLE IF EXISTS public.success_stories         ENABLE ROW LEVEL SECURITY;
ALTER TABLE IF EXISTS public.verification_requests   ENABLE ROW LEVEL SECURITY;
ALTER TABLE IF EXISTS public.user_references         ENABLE ROW LEVEL SECURITY;
ALTER TABLE IF EXISTS public.profile_shares          ENABLE ROW LEVEL SECURITY;
ALTER TABLE IF EXISTS public.photos                  ENABLE ROW LEVEL SECURITY;
ALTER TABLE IF EXISTS public.messages                ENABLE ROW LEVEL SECURITY;

-- ─────────────────────────────────────────────────────────────
-- 2. PROFILES — public read, owner write (user_id = auth.uid())
-- ─────────────────────────────────────────────────────────────
DO $$ BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_policies WHERE tablename = 'profiles' AND policyname = 'profiles_select_public'
  ) THEN
    CREATE POLICY "profiles_select_public" ON public.profiles
      FOR SELECT USING (true);
  END IF;
END $$;

DO $$ BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_policies WHERE tablename = 'profiles' AND policyname = 'profiles_insert_own'
  ) THEN
    CREATE POLICY "profiles_insert_own" ON public.profiles
      FOR INSERT WITH CHECK (auth.uid() = user_id);
  END IF;
END $$;

DO $$ BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_policies WHERE tablename = 'profiles' AND policyname = 'profiles_update_own'
  ) THEN
    CREATE POLICY "profiles_update_own" ON public.profiles
      FOR UPDATE USING (auth.uid() = user_id)
      WITH CHECK (auth.uid() = user_id);
  END IF;
END $$;

DO $$ BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_policies WHERE tablename = 'profiles' AND policyname = 'profiles_delete_own'
  ) THEN
    CREATE POLICY "profiles_delete_own" ON public.profiles
      FOR DELETE USING (auth.uid() = user_id);
  END IF;
END $$;

-- ─────────────────────────────────────────────────────────────
-- 3. SUBSCRIPTIONS — owner read (user_id = auth.uid())
--    Insert policy already exists from security_remediation
-- ─────────────────────────────────────────────────────────────
DO $$ BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_policies WHERE tablename = 'subscriptions' AND policyname = 'subscriptions_select_own'
  ) THEN
    CREATE POLICY "subscriptions_select_own" ON public.subscriptions
      FOR SELECT USING (auth.uid() = user_id);
  END IF;
END $$;

-- ─────────────────────────────────────────────────────────────
-- 4. BOOKMARKS — owner only (user_id = auth.uid())
-- ─────────────────────────────────────────────────────────────
DO $$ BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_policies WHERE tablename = 'bookmarks' AND policyname = 'bookmarks_select_own'
  ) THEN
    CREATE POLICY "bookmarks_select_own" ON public.bookmarks
      FOR SELECT USING (auth.uid() = user_id);
  END IF;
END $$;

DO $$ BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_policies WHERE tablename = 'bookmarks' AND policyname = 'bookmarks_insert_own'
  ) THEN
    CREATE POLICY "bookmarks_insert_own" ON public.bookmarks
      FOR INSERT WITH CHECK (auth.uid() = user_id);
  END IF;
END $$;

DO $$ BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_policies WHERE tablename = 'bookmarks' AND policyname = 'bookmarks_delete_own'
  ) THEN
    CREATE POLICY "bookmarks_delete_own" ON public.bookmarks
      FOR DELETE USING (auth.uid() = user_id);
  END IF;
END $$;

-- ─────────────────────────────────────────────────────────────
-- 5. DAILY_REWARDS — owner only (user_id = auth.uid())
-- ─────────────────────────────────────────────────────────────
DO $$ BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_policies WHERE tablename = 'daily_rewards' AND policyname = 'daily_rewards_select_own'
  ) THEN
    CREATE POLICY "daily_rewards_select_own" ON public.daily_rewards
      FOR SELECT USING (auth.uid() = user_id);
  END IF;
END $$;

DO $$ BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_policies WHERE tablename = 'daily_rewards' AND policyname = 'daily_rewards_insert_own'
  ) THEN
    CREATE POLICY "daily_rewards_insert_own" ON public.daily_rewards
      FOR INSERT WITH CHECK (auth.uid() = user_id);
  END IF;
END $$;

DO $$ BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_policies WHERE tablename = 'daily_rewards' AND policyname = 'daily_rewards_update_own'
  ) THEN
    CREATE POLICY "daily_rewards_update_own" ON public.daily_rewards
      FOR UPDATE USING (auth.uid() = user_id);
  END IF;
END $$;

-- ─────────────────────────────────────────────────────────────
-- 6. REFERRALS — referrer_id is auth.uid(), referred_user_id is auth.uid()
-- ─────────────────────────────────────────────────────────────
DO $$ BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_policies WHERE tablename = 'referrals' AND policyname = 'referrals_select_own'
  ) THEN
    CREATE POLICY "referrals_select_own" ON public.referrals
      FOR SELECT USING (auth.uid() = referrer_id OR auth.uid() = referred_user_id);
  END IF;
END $$;

DO $$ BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_policies WHERE tablename = 'referrals' AND policyname = 'referrals_insert_own'
  ) THEN
    CREATE POLICY "referrals_insert_own" ON public.referrals
      FOR INSERT WITH CHECK (auth.uid() = referrer_id);
  END IF;
END $$;

-- ─────────────────────────────────────────────────────────────
-- 7. REFERRAL_STATS — owner read only (user_id = auth.uid())
-- ─────────────────────────────────────────────────────────────
DO $$ BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_policies WHERE tablename = 'referral_stats' AND policyname = 'referral_stats_select_own'
  ) THEN
    CREATE POLICY "referral_stats_select_own" ON public.referral_stats
      FOR SELECT USING (auth.uid() = user_id);
  END IF;
END $$;

-- ─────────────────────────────────────────────────────────────
-- 8. SUCCESS_STORIES — public read, owner insert (user_id = auth.uid())
-- ─────────────────────────────────────────────────────────────
DO $$ BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_policies WHERE tablename = 'success_stories' AND policyname = 'success_stories_select_public'
  ) THEN
    CREATE POLICY "success_stories_select_public" ON public.success_stories
      FOR SELECT USING (true);
  END IF;
END $$;

DO $$ BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_policies WHERE tablename = 'success_stories' AND policyname = 'success_stories_insert_own'
  ) THEN
    CREATE POLICY "success_stories_insert_own" ON public.success_stories
      FOR INSERT WITH CHECK (auth.uid() = user_id);
  END IF;
END $$;

-- ─────────────────────────────────────────────────────────────
-- 9. VERIFICATION_REQUESTS — owner only (user_id = auth.uid())
-- ─────────────────────────────────────────────────────────────
DO $$ BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_policies WHERE tablename = 'verification_requests' AND policyname = 'verification_requests_select_own'
  ) THEN
    CREATE POLICY "verification_requests_select_own" ON public.verification_requests
      FOR SELECT USING (auth.uid() = user_id);
  END IF;
END $$;

DO $$ BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_policies WHERE tablename = 'verification_requests' AND policyname = 'verification_requests_insert_own'
  ) THEN
    CREATE POLICY "verification_requests_insert_own" ON public.verification_requests
      FOR INSERT WITH CHECK (auth.uid() = user_id);
  END IF;
END $$;

DO $$ BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_policies WHERE tablename = 'verification_requests' AND policyname = 'verification_requests_update_own'
  ) THEN
    CREATE POLICY "verification_requests_update_own" ON public.verification_requests
      FOR UPDATE USING (auth.uid() = user_id);
  END IF;
END $$;

-- ─────────────────────────────────────────────────────────────
-- 10. USER_REFERENCES — owner only (user_id = auth.uid())
-- ─────────────────────────────────────────────────────────────
DO $$ BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_policies WHERE tablename = 'user_references' AND policyname = 'user_references_select_own'
  ) THEN
    CREATE POLICY "user_references_select_own" ON public.user_references
      FOR SELECT USING (auth.uid() = user_id);
  END IF;
END $$;

DO $$ BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_policies WHERE tablename = 'user_references' AND policyname = 'user_references_insert_own'
  ) THEN
    CREATE POLICY "user_references_insert_own" ON public.user_references
      FOR INSERT WITH CHECK (auth.uid() = user_id);
  END IF;
END $$;

-- ─────────────────────────────────────────────────────────────
-- 11. PROFILE_SHARES — sharer_id/recipient_id are profile IDs (not auth IDs).
--     Ownership verified via profiles table subquery.
-- ─────────────────────────────────────────────────────────────
DO $$ BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_policies WHERE tablename = 'profile_shares' AND policyname = 'profile_shares_select_own'
  ) THEN
    CREATE POLICY "profile_shares_select_own" ON public.profile_shares
      FOR SELECT USING (
        auth.uid() IN (
          SELECT p.user_id FROM public.profiles p
          WHERE p.id = profile_shares.sharer_id OR p.id = profile_shares.recipient_id
        )
      );
  END IF;
END $$;

DO $$ BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_policies WHERE tablename = 'profile_shares' AND policyname = 'profile_shares_insert_own'
  ) THEN
    CREATE POLICY "profile_shares_insert_own" ON public.profile_shares
      FOR INSERT WITH CHECK (
        auth.uid() = (SELECT p.user_id FROM public.profiles p WHERE p.id = profile_shares.sharer_id)
      );
  END IF;
END $$;

DO $$ BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_policies WHERE tablename = 'profile_shares' AND policyname = 'profile_shares_delete_own'
  ) THEN
    CREATE POLICY "profile_shares_delete_own" ON public.profile_shares
      FOR DELETE USING (
        auth.uid() = (SELECT p.user_id FROM public.profiles p WHERE p.id = profile_shares.sharer_id)
      );
  END IF;
END $$;

-- ─────────────────────────────────────────────────────────────
-- 12. PHOTOS — profile_id is a profile UUID (not auth UUID).
--     Public read (profile photos visible to all users).
--     Write restricted to profile owner via profiles.user_id lookup.
-- ─────────────────────────────────────────────────────────────
DO $$ BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_policies WHERE tablename = 'photos' AND policyname = 'photos_select_public'
  ) THEN
    CREATE POLICY "photos_select_public" ON public.photos
      FOR SELECT USING (true);
  END IF;
END $$;

DO $$ BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_policies WHERE tablename = 'photos' AND policyname = 'photos_insert_own'
  ) THEN
    CREATE POLICY "photos_insert_own" ON public.photos
      FOR INSERT WITH CHECK (
        auth.uid() = (SELECT p.user_id FROM public.profiles p WHERE p.id = photos.profile_id)
      );
  END IF;
END $$;

DO $$ BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_policies WHERE tablename = 'photos' AND policyname = 'photos_update_own'
  ) THEN
    CREATE POLICY "photos_update_own" ON public.photos
      FOR UPDATE USING (
        auth.uid() = (SELECT p.user_id FROM public.profiles p WHERE p.id = photos.profile_id)
      );
  END IF;
END $$;

DO $$ BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_policies WHERE tablename = 'photos' AND policyname = 'photos_delete_own'
  ) THEN
    CREATE POLICY "photos_delete_own" ON public.photos
      FOR DELETE USING (
        auth.uid() = (SELECT p.user_id FROM public.profiles p WHERE p.id = photos.profile_id)
      );
  END IF;
END $$;

-- ─────────────────────────────────────────────────────────────
-- 13. MESSAGES — accessed via conversation_id stream.
--     sender_id is auth.uid(). No receiver_id column.
--     Read: users in the conversation. Write: sender only.
-- ─────────────────────────────────────────────────────────────
DO $$ BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_policies WHERE tablename = 'messages' AND policyname = 'messages_select_participant'
  ) THEN
    CREATE POLICY "messages_select_participant" ON public.messages
      FOR SELECT USING (
        EXISTS (
          SELECT 1 FROM public.conversations c
          WHERE c.id = messages.conversation_id
            AND (c.participant_one_id = auth.uid() OR c.participant_two_id = auth.uid())
        )
      );
  END IF;
END $$;

DO $$ BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_policies WHERE tablename = 'messages' AND policyname = 'messages_insert_own'
  ) THEN
    CREATE POLICY "messages_insert_own" ON public.messages
      FOR INSERT WITH CHECK (auth.uid() = sender_id);
  END IF;
END $$;

DO $$ BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_policies WHERE tablename = 'messages' AND policyname = 'messages_update_own'
  ) THEN
    CREATE POLICY "messages_update_own" ON public.messages
      FOR UPDATE USING (auth.uid() = sender_id);
  END IF;
END $$;
