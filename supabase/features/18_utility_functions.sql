-- Last run: 2026-02-28 — Update when re-run in Supabase SQL Editor
-- =====================================================
-- 18. UTILITY FUNCTIONS
-- Backend-only utility functions for account management,
-- subscription maintenance, and data helpers.
-- =====================================================
-- =====================================================
-- FUNCTION: fn_delete_own_account
-- Allows authenticated users to delete their own account
-- and all associated data (profiles, photos, etc cascade).
-- =====================================================
CREATE OR REPLACE FUNCTION public.fn_delete_own_account() RETURNS JSONB AS $$
DECLARE v_user_id UUID := auth.uid();
BEGIN IF v_user_id IS NULL THEN RAISE EXCEPTION 'Not authenticated';
END IF;
-- Delete profile (cascades to photos, bookmarks, shares, etc.)
DELETE FROM public.profiles
WHERE user_id = v_user_id;
-- Delete subscription
DELETE FROM public.subscriptions
WHERE user_id = v_user_id;
-- Delete usage tracking
DELETE FROM public.usage_tracking
WHERE user_id = v_user_id;
-- Delete verification requests
DELETE FROM public.verification_requests
WHERE user_id = v_user_id;
-- Delete user references
DELETE FROM public.user_references
WHERE user_id = v_user_id;
-- Delete blocks (both directions)
DELETE FROM public.user_blocks
WHERE blocker_id = v_user_id
    OR blocked_id = v_user_id;
-- Delete reports by this user
DELETE FROM public.user_reports
WHERE reporter_id = v_user_id;
-- Delete referrals
DELETE FROM public.referrals
WHERE referrer_id = v_user_id
    OR referred_user_id = v_user_id;
-- Delete referral stats
DELETE FROM public.referral_stats
WHERE user_id = v_user_id;
-- Finally delete auth user (this is the nuclear option)
-- Note: auth.users deletion should be handled by Supabase Admin API
-- or the auth.admin.deleteUser() method in Edge Functions.
RETURN jsonb_build_object(
    'status',
    'success',
    'message',
    'Account data deleted'
);
EXCEPTION
WHEN OTHERS THEN RETURN jsonb_build_object('status', 'error', 'message', SQLERRM);
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;
GRANT EXECUTE ON FUNCTION public.fn_delete_own_account() TO authenticated;
-- =====================================================
-- FUNCTION: check_expired_subscriptions
-- Checks and expires subscriptions past their expiry date.
-- Intended to be called by a Supabase cron job or
-- pg_cron extension on a schedule (e.g., daily).
-- =====================================================
CREATE OR REPLACE FUNCTION public.check_expired_subscriptions() RETURNS JSONB AS $$
DECLARE v_count INTEGER;
BEGIN -- Mark expired subscriptions
UPDATE public.subscriptions
SET status = 'expired',
    updated_at = NOW()
WHERE status = 'active'
    AND expires_at IS NOT NULL
    AND expires_at < NOW();
GET DIAGNOSTICS v_count = ROW_COUNT;
-- Sync premium status for expired users
UPDATE public.profiles
SET is_premium = FALSE,
    updated_at = NOW()
WHERE user_id IN (
        SELECT user_id
        FROM public.subscriptions
        WHERE status = 'expired'
            AND updated_at >= NOW() - INTERVAL '1 minute'
    )
    AND is_premium = TRUE;
RETURN jsonb_build_object(
    'status',
    'success',
    'expired_count',
    v_count,
    'checked_at',
    NOW()
);
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;
-- Allow anon and authenticated for cron/edge function invocation
GRANT EXECUTE ON FUNCTION public.check_expired_subscriptions() TO authenticated;
-- =====================================================
-- FUNCTION: get_user_surname
-- Returns the surname for a given user UUID.
-- Used by admin/internal processes.
-- =====================================================
CREATE OR REPLACE FUNCTION public.get_user_surname(user_uuid UUID) RETURNS TEXT AS $$
DECLARE v_surname TEXT;
BEGIN
SELECT surname INTO v_surname
FROM public.profiles
WHERE user_id = user_uuid;
RETURN COALESCE(v_surname, '');
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;
GRANT EXECUTE ON FUNCTION public.get_user_surname(UUID) TO authenticated;