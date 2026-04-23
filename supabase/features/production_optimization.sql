-- Last run: 2025-02-12 — Update when re-run in Supabase SQL Editor
-- ============================================================================
-- PRODUCTION OPTIMIZATION SUITE
-- For 10M+ users, Free Supabase → Pro migration path, backend-agnostic design
-- Run after all feature files (01–15). Idempotent.
-- ============================================================================

-- ============================================================================
-- 1. CHAT & MESSAGES
-- ============================================================================

DROP INDEX IF EXISTS idx_messages_order;
CREATE INDEX IF NOT EXISTS idx_messages_conv_created
  ON public.messages(conversation_id, created_at DESC NULLS LAST);

CREATE INDEX IF NOT EXISTS idx_conversations_p1_lookup
  ON public.conversations(participant_one_id);
CREATE INDEX IF NOT EXISTS idx_conversations_p2_lookup
  ON public.conversations(participant_two_id);

-- ============================================================================
-- 2. PROFILE VIEWS (Who Viewed Me / I Viewed)
-- ============================================================================

DROP INDEX IF EXISTS idx_profile_views_time;
CREATE INDEX IF NOT EXISTS idx_profile_views_viewed_desc
  ON public.profile_views(viewed_id, last_viewed_at DESC NULLS LAST);
CREATE INDEX IF NOT EXISTS idx_profile_views_viewer_desc
  ON public.profile_views(viewer_id, last_viewed_at DESC NULLS LAST);

-- ============================================================================
-- 3. PROFILES (Discovery feed)
-- ============================================================================

CREATE INDEX IF NOT EXISTS idx_profiles_active_updated
  ON public.profiles(is_active, updated_at DESC NULLS LAST)
  WHERE is_active = true;

-- ============================================================================
-- 4. PAYMENTS & SUBSCRIPTIONS
-- ============================================================================

CREATE INDEX IF NOT EXISTS idx_payments_order_fast
  ON public.payments(razorpay_order_id)
  WHERE razorpay_order_id IS NOT NULL;

CREATE INDEX IF NOT EXISTS idx_subscriptions_user_active
  ON public.subscriptions(user_id, status)
  WHERE status = 'active';

-- ============================================================================
-- 5. USAGE TRACKING (Date-range queries)
-- ============================================================================

CREATE INDEX IF NOT EXISTS idx_usage_tracking_user_date
  ON public.usage_tracking(user_id, date DESC);

-- ============================================================================
-- 6. ANALYZE (Update statistics for query planner)
-- Run periodically or after bulk imports.
-- ============================================================================

ANALYZE public.profiles;
ANALYZE public.payments;
ANALYZE public.subscriptions;
ANALYZE public.bookmarks;
ANALYZE public.profile_shares;
ANALYZE public.messages;
ANALYZE public.conversations;

-- ============================================================================
-- 7. PG_STAT_STATEMENTS (Optional - requires extension enable in Dashboard)
-- Helps identify slow queries. Enable via: Extensions → pg_stat_statements
-- ============================================================================

CREATE EXTENSION IF NOT EXISTS pg_stat_statements;
