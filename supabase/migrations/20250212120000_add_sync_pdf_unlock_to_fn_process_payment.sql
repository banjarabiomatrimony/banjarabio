-- =====================================================
-- Add sync_pdf_unlock action to fn_process_payment
-- Run after 09_payments and 09b_razorpay_billing base.
-- idempotent: CREATE OR REPLACE updates existing function.
-- =====================================================

CREATE OR REPLACE FUNCTION public.fn_process_payment(
    action TEXT,
    payload JSONB
) RETURNS JSONB AS $$
DECLARE
    v_user_id UUID := auth.uid();
    v_result JSONB;
    v_secret TEXT;
    v_order_id TEXT;
    v_payment_id TEXT;
    v_signature TEXT;
    v_plan_type TEXT;
    v_amount INT;
    v_app_slug TEXT;
    v_expected_sig TEXT;
BEGIN
    IF v_user_id IS NULL THEN RAISE EXCEPTION 'Not authenticated'; END IF;

    CASE action
        WHEN 'create_order' THEN
            v_result := jsonb_build_object(
                'id', 'amount_only',
                'amount', (payload->>'amount')::INTEGER,
                'currency', COALESCE(payload->>'currency', 'INR'),
                'plan_type', payload->>'plan_type'
            );

        WHEN 'verify_payment' THEN
            v_order_id := payload->>'razorpay_order_id';
            v_payment_id := payload->>'razorpay_payment_id';
            v_signature := payload->>'razorpay_signature';
            v_plan_type := COALESCE(payload->>'plan_type', 'biodata_unlock');
            v_amount := (payload->>'amount')::INTEGER;
            v_app_slug := COALESCE(payload->>'app_slug', 'banjara');

            IF v_order_id IS NULL OR v_payment_id IS NULL OR v_signature IS NULL THEN
                RAISE EXCEPTION 'Missing razorpay_order_id, razorpay_payment_id, or razorpay_signature';
            END IF;

            SELECT value INTO v_secret FROM private.razorpay_config WHERE key = 'key_secret';
            IF v_secret IS NULL OR v_secret = '' THEN
                RAISE EXCEPTION 'Razorpay secret not configured. Run: INSERT INTO private.razorpay_config (key, value) VALUES (''key_secret'', ''your_razorpay_key_secret'');';
            END IF;

            v_expected_sig := encode(
                hmac(v_order_id || '|' || v_payment_id, v_secret, 'sha256'),
                'hex'
            );

            IF v_expected_sig != v_signature THEN
                RAISE EXCEPTION 'Invalid payment signature';
            END IF;

            INSERT INTO public.payments (
                user_id, amount, currency, status,
                razorpay_order_id, razorpay_payment_id, razorpay_signature,
                plan_type, plan_duration, app_slug
            ) VALUES (
                v_user_id, v_amount, 'INR', 'captured',
                v_order_id, v_payment_id, v_signature,
                v_plan_type,
                CASE WHEN v_plan_type = 'biodata_unlock' THEN NULL ELSE 0 END,
                v_app_slug
            )
            ON CONFLICT (razorpay_order_id) DO NOTHING;

            IF v_plan_type = 'biodata_unlock' THEN
                PERFORM private.fn_apply_pdf_unlock(v_user_id);
            ELSIF v_plan_type IN ('silver', 'gold', 'platinum') THEN
                UPDATE public.subscriptions
                SET plan_type = v_plan_type, status = 'active', updated_at = NOW()
                WHERE user_id = v_user_id;
            END IF;

            v_result := jsonb_build_object('status', 'verified', 'plan_type', v_plan_type);

        WHEN 'sync_pdf_unlock' THEN
            IF EXISTS (
                SELECT 1 FROM public.payments
                WHERE user_id = v_user_id AND plan_type = 'biodata_unlock' AND status = 'captured'
            ) THEN
                PERFORM private.fn_apply_pdf_unlock(v_user_id);
                v_result := jsonb_build_object('status', 'sync_applied', 'message', 'PDF unlock re-applied');
            ELSE
                v_result := jsonb_build_object('status', 'no_payment', 'message', 'No biodata_unlock payment found');
            END IF;

        WHEN 'record_payment' THEN
            INSERT INTO public.payments (user_id, amount, status, razorpay_order_id, plan_type, plan_duration)
            VALUES (v_user_id, (payload->>'amount')::INTEGER, payload->>'status', payload->>'order_id', payload->>'plan', (payload->>'duration')::INTEGER)
            RETURNING jsonb_build_object('id', id) INTO v_result;

        WHEN 'update_status' THEN
            UPDATE public.payments SET status = payload->>'status', razorpay_payment_id = payload->>'payment_id'
            WHERE razorpay_order_id = payload->>'order_id' AND user_id = v_user_id;
            v_result := jsonb_build_object('status', 'success');

        WHEN 'get_history' THEN
            SELECT jsonb_agg(t) INTO v_result FROM (
                SELECT * FROM public.payments WHERE user_id = v_user_id ORDER BY created_at DESC LIMIT 50
            ) t;

        ELSE RAISE EXCEPTION 'Invalid action';
    END CASE;

    RETURN v_result;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

GRANT EXECUTE ON FUNCTION public.fn_process_payment(TEXT, JSONB) TO authenticated;
