-- Last run: 2025-02-12 — Update when re-run in Supabase SQL Editor
-- =====================================================
-- 09c. RAZORPAY WEBHOOK (fallback when client callback fails)
-- Webhook handler calls this via service_role to record payment.
-- Depends on: 09b_razorpay_billing
-- =====================================================

-- Drop old 5-param version if exists (signature changed to add p_app_slug)
DROP FUNCTION IF EXISTS public.fn_webhook_razorpay_payment_captured(UUID, TEXT, TEXT, INT, TEXT);

-- Function for webhook Edge Function to record payment (no user context).
-- Callable ONLY via service_role (Edge Function with SUPABASE_SERVICE_ROLE_KEY).
-- Uses ON CONFLICT for race safety when client verify_payment runs concurrently.
CREATE OR REPLACE FUNCTION public.fn_webhook_razorpay_payment_captured(
  p_user_id UUID,
  p_order_id TEXT,
  p_payment_id TEXT,
  p_amount INT,
  p_plan_type TEXT,
  p_app_slug TEXT DEFAULT 'banjara'
) RETURNS JSONB AS $$
DECLARE
  v_inserted_id UUID;
BEGIN
  -- Idempotency: INSERT with ON CONFLICT to handle race with client verify_payment
  INSERT INTO public.payments (
    user_id, amount, currency, status,
    razorpay_order_id, razorpay_payment_id, razorpay_signature,
    plan_type, plan_duration, app_slug
  ) VALUES (
    p_user_id, p_amount, 'INR', 'captured',
    p_order_id, p_payment_id, 'webhook_verified',
    p_plan_type,
    CASE WHEN p_plan_type = 'biodata_unlock' THEN NULL ELSE 0 END,
    p_app_slug
  )
  ON CONFLICT (razorpay_order_id) DO NOTHING
  RETURNING id INTO v_inserted_id;

  -- Only apply unlock/subscription if we inserted (conflict = client already did it)
    IF v_inserted_id IS NOT NULL THEN
    IF p_plan_type = 'biodata_unlock' THEN
      PERFORM private.fn_apply_pdf_unlock(p_user_id);
    ELSIF p_plan_type IN ('silver', 'gold', 'platinum') THEN
      INSERT INTO public.subscriptions (user_id, plan_type, status, started_at)
      VALUES (p_user_id, p_plan_type, 'active', NOW())
      ON CONFLICT (user_id) DO UPDATE SET
          plan_type = p_plan_type, status = 'active', updated_at = NOW();
    END IF;
    RETURN jsonb_build_object('status', 'verified', 'plan_type', p_plan_type);
  ELSE
    RETURN jsonb_build_object('status', 'already_recorded', 'plan_type', p_plan_type);
  END IF;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Only service_role can call (Edge Function uses service role key)
REVOKE ALL ON FUNCTION public.fn_webhook_razorpay_payment_captured FROM PUBLIC;
GRANT EXECUTE ON FUNCTION public.fn_webhook_razorpay_payment_captured TO service_role;
