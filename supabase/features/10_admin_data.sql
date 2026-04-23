-- Last run: 2025-02-12 — Update when re-run in Supabase SQL Editor
-- =====================================================
-- 10. ADMIN & SECURITY FEATURE
-- Handles admin roles and system flag protection.
-- =====================================================
-- =====================================================
-- FUNCTION: Check if Admin
-- =====================================================
-- Returns true if user has is_admin on profile, or if auth email is admin@banjarabio.com
CREATE OR REPLACE FUNCTION public.fn_is_admin(p_user_id UUID) RETURNS BOOLEAN AS $$ BEGIN -- 1. Profile-based admin
  IF EXISTS (
    SELECT 1
    FROM public.profiles
    WHERE user_id = p_user_id
      AND is_admin = true
  ) THEN RETURN true;
END IF;
-- 2. Fallback: admin by email (for users without profile yet)
IF EXISTS (
  SELECT 1
  FROM auth.users
  WHERE id = p_user_id
    AND LOWER(TRIM(email)) = 'admin@banjarabio.com'
) THEN RETURN true;
END IF;
RETURN false;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;
-- =====================================================
-- RPC: fn_admin_actions (Admin-only operations)
-- =====================================================
CREATE OR REPLACE FUNCTION public.fn_admin_actions(action TEXT, p_payload JSONB) RETURNS JSONB AS $$
DECLARE v_admin_id UUID := auth.uid();
v_result JSONB;
v_target_user_id UUID;
v_notif_title TEXT;
v_notif_body TEXT;
v_notif_data JSONB;
v_status TEXT;
BEGIN IF v_admin_id IS NULL THEN RAISE EXCEPTION 'Not authenticated';
END IF;
IF NOT public.fn_is_admin(v_admin_id) THEN RAISE EXCEPTION 'Unauthorized: admin access required';
END IF;
CASE
  action
  WHEN 'get_admin_stats' THEN
  SELECT jsonb_build_object(
      -- Demographics
      'total_auth_users',
      (
        SELECT count(*)
        FROM auth.users
      ),
      'total_profiles',
      (
        SELECT count(*)
        FROM public.profiles
      ),
      'men_count',
      (
        SELECT count(*)
        FROM public.profiles
        WHERE gender = 'Male'
      ),
      'women_count',
      (
        SELECT count(*)
        FROM public.profiles
        WHERE gender = 'Female'
      ),
      -- Financial
      'revenue_total',
      (
        SELECT COALESCE(SUM(amount) / 100.0, 0)
        FROM public.payments
        WHERE status = 'captured'
          AND is_test = false
      ),
      'revenue_monthly',
      (
        SELECT COALESCE(SUM(amount) / 100.0, 0)
        FROM public.payments
        WHERE status = 'captured'
          AND is_test = false
          AND created_at >= date_trunc('month', now())
      ),
      'revenue_today',
      (
        SELECT COALESCE(SUM(amount) / 100.0, 0)
        FROM public.payments
        WHERE status = 'captured'
          AND is_test = false
          AND created_at >= date_trunc('day', now())
      ),
      'revenue_pdf',
      (
        SELECT COALESCE(SUM(amount) / 100.0, 0)
        FROM public.payments
        WHERE status = 'captured'
          AND is_test = false
          AND plan_type = 'biodata_unlock'
      ),
      'revenue_subscription',
      (
        SELECT COALESCE(SUM(amount) / 100.0, 0)
        FROM public.payments
        WHERE status = 'captured'
          AND is_test = false
          AND plan_type IN ('silver', 'gold', 'platinum')
      ),
      'premium_men',
      (
        SELECT count(*)
        FROM public.profiles
        WHERE is_premium = true
          AND gender = 'Male'
      ),
      'premium_women',
      (
        SELECT count(*)
        FROM public.profiles
        WHERE is_premium = true
          AND gender = 'Female'
      ),
      -- Engagement
      'dau_today',
      (
        SELECT count(DISTINCT user_id)
        FROM public.usage_tracking
        WHERE date = CURRENT_DATE
      ),
      'total_profile_views',
      (
        SELECT COALESCE(SUM(profile_views), 0)
        FROM public.usage_tracking
      ),
      'total_messages',
      (
        SELECT count(*)
        FROM public.messages
      ),
      'total_conversations',
      (
        SELECT count(*)
        FROM public.conversations
      ),
      -- Safety & Health
      'pending_reports',
      (
        SELECT count(*)
        FROM public.user_reports
        WHERE status = 'pending'
      ),
      'total_blocks',
      (
        SELECT count(*)
        FROM public.user_blocks
      ),
      'pending_verifications',
      (
        SELECT count(*)
        FROM public.verification_requests
        WHERE status = 'pending'
      ),
      'pending_references',
      (
        SELECT count(*)
        FROM public.user_references
        WHERE status = 'pending'
      ),
      -- Growth
      'completed_referrals',
      (
        SELECT count(*)
        FROM public.referrals
        WHERE status = 'completed'
      ),
      'total_creators',
      (
        SELECT count(*)
        FROM public.creators
        WHERE is_active = true
      )
    ) INTO v_result;
WHEN 'get_payments_list' THEN
SELECT COALESCE(jsonb_agg(row_to_json(t)::jsonb), '[]'::jsonb) INTO v_result
FROM (
    SELECT p.*,
      p.amount / 100.0 as amount_rupees,
      CASE
        WHEN p.plan_type = 'biodata_unlock' THEN 'PDF'
        ELSE 'Subscription'
      END as category,
      jsonb_build_object('full_name', pr.full_name, 'email', pr.email) AS profiles
    FROM public.payments p
      LEFT JOIN public.profiles pr ON pr.user_id = p.user_id
    ORDER BY p.created_at DESC
    LIMIT GREATEST(
        1, LEAST(200, COALESCE((p_payload->>'limit')::INT, 100))
      ) OFFSET GREATEST(0, COALESCE((p_payload->>'offset')::INT, 0))
  ) t;
WHEN 'get_pending_verifications' THEN
SELECT COALESCE(jsonb_agg(row_to_json(t)::jsonb), '[]'::jsonb) INTO v_result
FROM (
    SELECT vr.*,
      jsonb_build_object('full_name', p.full_name, 'email', p.email) AS profiles
    FROM public.verification_requests vr
      LEFT JOIN public.profiles p ON p.user_id = vr.user_id
    WHERE vr.status IN ('pending', 'on_hold')
    ORDER BY vr.created_at DESC
  ) t;
WHEN 'get_pending_references' THEN
SELECT COALESCE(jsonb_agg(row_to_json(t)::jsonb), '[]'::jsonb) INTO v_result
FROM (
    SELECT ur.*,
      jsonb_build_object('full_name', p.full_name) AS profiles
    FROM public.user_references ur
      LEFT JOIN public.profiles p ON p.user_id = ur.user_id
    WHERE ur.status = 'pending'
    ORDER BY ur.created_at DESC
  ) t;
WHEN 'get_all_profiles' THEN
SELECT COALESCE(jsonb_agg(row_to_json(t)::jsonb), '[]'::jsonb) INTO v_result
FROM (
    SELECT *
    FROM public.profiles
    WHERE (
        p_payload->>'search_query' IS NULL
        OR TRIM(COALESCE(p_payload->>'search_query', '')) = ''
        OR full_name ILIKE '%' || TRIM(p_payload->>'search_query') || '%'
        OR email ILIKE '%' || TRIM(p_payload->>'search_query') || '%'
        OR phone_number ILIKE '%' || TRIM(p_payload->>'search_query') || '%'
      )
      AND (
        p_payload->>'gender' IS NULL
        OR LOWER(TRIM(gender)) = LOWER(TRIM((p_payload->>'gender')::TEXT))
      )
      AND (
        p_payload->>'is_premium' IS NULL
        OR is_premium = (p_payload->>'is_premium')::BOOLEAN
      )
    ORDER BY created_at DESC
  ) t;
WHEN 'update_verification_status' THEN
SELECT user_id INTO v_target_user_id
FROM public.verification_requests
WHERE id = (p_payload->>'request_id')::UUID;
UPDATE public.verification_requests
SET status = (p_payload->>'status')::TEXT,
  admin_notes = COALESCE(p_payload->>'notes', admin_notes),
  rejection_reason = CASE
    WHEN (p_payload->>'status') IN ('approved', 'pending') THEN COALESCE(p_payload->>'rejection_reason', NULL)
    ELSE COALESCE(p_payload->>'rejection_reason', rejection_reason)
  END,
  updated_at = NOW()
WHERE id = (p_payload->>'request_id')::UUID;
IF v_target_user_id IS NOT NULL THEN PERFORM public.fn_calculate_trust_score(v_target_user_id);
v_notif_title := CASE
  WHEN (p_payload->>'status') = 'approved' THEN 'Verification Approved! ✅'
  WHEN (p_payload->>'status') = 'rejected' THEN 'Verification Rejected ❌'
  WHEN (p_payload->>'status') = 'on_hold' THEN 'Verification On Hold 📂'
  ELSE 'Verification Updated'
END;
v_notif_body := CASE
  WHEN (p_payload->>'status') = 'approved' THEN 'Your profile has been successfully verified. You now have a verified badge!'
  WHEN (p_payload->>'status') = 'rejected' THEN 'Your verification request was rejected: ' || COALESCE(
    p_payload->>'rejection_reason',
    'Please check details.'
  )
  WHEN (p_payload->>'status') = 'on_hold' THEN 'Your verification is on hold. Reason: ' || COALESCE(
    p_payload->>'notes',
    'Please wait for further updates.'
  )
  ELSE 'There was an update to your verification status.'
END;
v_notif_data := jsonb_build_object(
  'type',
  'verification_update',
  'status',
  p_payload->>'status',
  'route',
  '/profile'
);
PERFORM public.fn_trigger_push_notification(
  v_target_user_id,
  v_notif_title,
  v_notif_body,
  v_notif_data
);
END IF;
v_result := jsonb_build_object('status', 'success');
WHEN 'update_reference_status' THEN
UPDATE public.user_references
SET status = (p_payload->>'status')::TEXT
WHERE id = (p_payload->>'reference_id')::UUID
RETURNING user_id INTO v_target_user_id;
v_status := (p_payload->>'status')::TEXT;
PERFORM public.fn_trigger_push_notification(
  v_target_user_id,
  CASE
    WHEN v_status = 'verified' THEN 'Reference Verified! ✅'
    ELSE 'Reference Update'
  END,
  CASE
    WHEN v_status = 'verified' THEN 'One of your references has been verified.'
    ELSE 'An update occurred on your reference.'
  END,
  jsonb_build_object('type', 'reference_update', 'status', v_status)
);
v_result := jsonb_build_object('status', 'success');
ELSE RAISE EXCEPTION 'Unknown action: %',
action;
END CASE
;
RETURN v_result;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;