-- =====================================================
-- 00. COMPLETE DATABASE RESET
-- =====================================================
--
-- ⛔ DANGER: IF YOU RUN THIS, ENTIRE DATABASE WILL BE DELETED!
-- ⛔ ALL DATA LOST — NO UNDO — IRREVERSIBLE!
-- ⛔ Run ONLY if you want a complete fresh start.
--
-- =====================================================
-- =====================================================
-- STEP 1: DROP ALL TRIGGERS
-- =====================================================
DROP TRIGGER IF EXISTS tr_profiles_update_timestamp ON public.profiles;
DROP TRIGGER IF EXISTS tr_subscriptions_update_timestamp ON public.subscriptions;
DROP TRIGGER IF EXISTS tr_payments_update_timestamp ON public.payments;
DROP TRIGGER IF EXISTS tr_usage_tracking_update_timestamp ON public.usage_tracking;
DROP TRIGGER IF EXISTS tr_profile_shares_update_timestamp ON public.profile_shares;
DROP TRIGGER IF EXISTS tr_new_user_subscription ON auth.users;
DROP TRIGGER IF EXISTS tr_sync_score_on_verification ON public.verification_requests;
DROP TRIGGER IF EXISTS tr_sync_score_on_reference ON public.user_references;
DROP TRIGGER IF EXISTS tr_sync_score_on_profile_complete ON public.profiles;
DROP TRIGGER IF EXISTS tr_auto_match_shares ON public.profile_shares;
DROP TRIGGER IF EXISTS tr_protect_profile_system_fields ON public.profiles;
DROP TRIGGER IF EXISTS tr_sync_premium_on_subscription ON public.subscriptions;
DROP TRIGGER IF EXISTS tr_create_chat_on_match ON public.profile_shares;
-- =====================================================
-- STEP 2: DROP ALL FUNCTIONS
-- =====================================================
DROP FUNCTION IF EXISTS public.fn_webhook_razorpay_payment_captured(UUID, TEXT, TEXT, INT, TEXT, TEXT) CASCADE;
DROP FUNCTION IF EXISTS public.fn_process_payment(TEXT, JSONB) CASCADE;
DROP FUNCTION IF EXISTS private.fn_apply_pdf_unlock(UUID) CASCADE;
DROP FUNCTION IF EXISTS private.fn_razorpay_config_updated_at() CASCADE;
DROP FUNCTION IF EXISTS public.fn_update_timestamp() CASCADE;
DROP FUNCTION IF EXISTS public.fn_initialize_subscription() CASCADE;
DROP FUNCTION IF EXISTS public.fn_profile_shares_update_timestamp() CASCADE;
DROP FUNCTION IF EXISTS public.fn_calculate_trust_score(UUID) CASCADE;
DROP FUNCTION IF EXISTS public.fn_trigger_sync_trust_score() CASCADE;
DROP FUNCTION IF EXISTS public.fn_auto_match_shares() CASCADE;
DROP FUNCTION IF EXISTS public.fn_delete_own_account() CASCADE;
DROP FUNCTION IF EXISTS public.fn_admin_actions(TEXT, JSONB) CASCADE;
DROP FUNCTION IF EXISTS public.fn_is_admin(UUID) CASCADE;
DROP FUNCTION IF EXISTS public.fn_protect_profile_system_fields() CASCADE;
DROP FUNCTION IF EXISTS public.fn_sync_premium_status() CASCADE;
DROP FUNCTION IF EXISTS public.fn_track_usage(TEXT, INTEGER) CASCADE;
DROP FUNCTION IF EXISTS public.fn_create_chat_on_match() CASCADE;
DROP FUNCTION IF EXISTS public.fn_manage_chat(TEXT, JSONB) CASCADE;
DROP FUNCTION IF EXISTS public.check_expired_subscriptions() CASCADE;
DROP FUNCTION IF EXISTS public.get_user_surname(UUID) CASCADE;
-- =====================================================
-- STEP 3: DROP ALL VIEWS
-- =====================================================
DROP VIEW IF EXISTS public.shared_profiles_view CASCADE;
DROP VIEW IF EXISTS public.conversations_view CASCADE;
-- =====================================================
-- STEP 4: DROP ALL TABLES (in dependency order)
-- =====================================================
DROP TRIGGER IF EXISTS tr_referral_completed ON public.referrals;
DROP FUNCTION IF EXISTS public.fn_process_referral(TEXT, JSONB) CASCADE;
DROP TABLE IF EXISTS public.shared_profiles CASCADE;
DROP TABLE IF EXISTS public.referrals CASCADE;
DROP TABLE IF EXISTS public.referral_stats CASCADE;
DROP FUNCTION IF EXISTS public.fn_on_referral_completed() CASCADE;
DROP TABLE IF EXISTS public.messages CASCADE;
DROP TABLE IF EXISTS public.conversations CASCADE;
DROP TABLE IF EXISTS public.profile_views CASCADE;
DROP TABLE IF EXISTS public.user_reports CASCADE;
DROP TABLE IF EXISTS public.user_blocks CASCADE;
DROP TABLE IF EXISTS public.verification_requests CASCADE;
DROP TABLE IF EXISTS public.user_references CASCADE;
DROP TABLE IF EXISTS public.photos CASCADE;
DROP TABLE IF EXISTS public.bookmarks CASCADE;
DROP TABLE IF EXISTS public.profile_shares CASCADE;
DROP TABLE IF EXISTS public.usage_tracking CASCADE;
DROP TABLE IF EXISTS public.payments CASCADE;
DROP TABLE IF EXISTS public.subscriptions CASCADE;
DROP TABLE IF EXISTS public.profiles CASCADE;
-- Razorpay config (private schema; safe to skip if 09b never run)
DO $$ BEGIN DROP TABLE IF EXISTS private.razorpay_config CASCADE;
EXCEPTION
WHEN undefined_schema THEN NULL;
END $$;
-- =====================================================
-- STEP 5: VERIFY CLEANUP
-- =====================================================
SELECT 'Tables remaining:' AS status;
SELECT table_name
FROM information_schema.tables
WHERE table_schema = 'public'
  AND table_type = 'BASE TABLE';