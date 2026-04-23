-- Last run: 2025-02-12 — Update when re-run in Supabase SQL Editor
-- =====================================================
-- 09b. RAZORPAY BILLING FEATURE (standalone)
-- Adds Razorpay order creation, payment verification, PDF unlock.
-- Depends on: 09_payments (payments table, base fn_process_payment)
-- =====================================================
-- HMAC verification for Razorpay signature
CREATE EXTENSION IF NOT EXISTS pgcrypto;
-- =====================================================
-- Razorpay secret storage
-- =====================================================
CREATE SCHEMA IF NOT EXISTS private;
CREATE TABLE IF NOT EXISTS private.razorpay_config (
    key TEXT PRIMARY KEY,
    value TEXT NOT NULL,
    updated_at TIMESTAMPTZ DEFAULT NOW()
);
-- Update timestamp on config change
CREATE OR REPLACE FUNCTION private.fn_razorpay_config_updated_at() RETURNS TRIGGER AS $$ BEGIN NEW.updated_at = NOW();
RETURN NEW;
END;
$$ LANGUAGE plpgsql;
DROP TRIGGER IF EXISTS tr_razorpay_config_updated_at ON private.razorpay_config;
CREATE TRIGGER tr_razorpay_config_updated_at BEFORE
UPDATE ON private.razorpay_config FOR EACH ROW EXECUTE FUNCTION private.fn_razorpay_config_updated_at();
-- DO NOT put real secrets here. This file is committed to VCS.
-- Insert key_secret AFTER running this migration:
--   1. Run: ./scripts/setup_razorpay.sh  (reads from assets/env.json)
--   2. Or manually: supabase/scripts/02_insert_razorpay_secret.sql
--      Replace YOUR_RAZORPAY_KEY_SECRET with value from assets/env.json
-- =====================================================
-- PDF unlock: fn_apply_pdf_unlock sets app.bypass_pdf_unlock (transaction-local)
-- before UPDATE so fn_protect_profile_system_fields allows is_pdf_unlocked.
-- =====================================================
CREATE OR REPLACE FUNCTION private.fn_apply_pdf_unlock(p_user_id UUID) RETURNS VOID AS $$ BEGIN PERFORM set_config('app.bypass_pdf_unlock', '1', true);
-- true = transaction-local
UPDATE public.profiles
SET is_pdf_unlocked = TRUE,
    updated_at = NOW()
WHERE user_id = p_user_id;
PERFORM set_config('app.bypass_pdf_unlock', '0', true);
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;
-- =====================================================
-- Add app_slug for multi-app payment tracking (existing DBs)
-- =====================================================
ALTER TABLE public.payments
ADD COLUMN IF NOT EXISTS app_slug TEXT DEFAULT 'banjara';
-- =====================================================
-- Extend fn_process_payment with Razorpay actions
-- (create_order, verify_payment)
-- =====================================================
CREATE OR REPLACE FUNCTION public.fn_process_payment(action TEXT, payload JSONB) RETURNS JSONB AS $$
DECLARE v_user_id UUID := auth.uid();
v_result JSONB;
v_secret TEXT;
v_order_id TEXT;
v_payment_id TEXT;
v_signature TEXT;
v_plan_type TEXT;
v_amount INT;
v_app_slug TEXT;
v_is_test BOOLEAN;
v_expected_sig TEXT;
BEGIN IF v_user_id IS NULL THEN RAISE EXCEPTION 'Not authenticated';
END IF;
CASE
    action
    WHEN 'create_order' THEN v_result := jsonb_build_object(
        'id',
        'amount_only',
        'amount',
        (payload->>'amount')::INTEGER,
        'currency',
        COALESCE(payload->>'currency', 'INR'),
        'plan_type',
        payload->>'plan_type'
    );
WHEN 'verify_payment' THEN v_order_id := payload->>'razorpay_order_id';
v_payment_id := payload->>'razorpay_payment_id';
v_signature := payload->>'razorpay_signature';
v_plan_type := COALESCE(payload->>'plan_type', 'biodata_unlock');
v_amount := (payload->>'amount')::INTEGER;
v_app_slug := COALESCE(payload->>'app_slug', 'banjara');
v_is_test := COALESCE((payload->>'is_test')::BOOLEAN, FALSE);
IF v_order_id IS NULL
OR v_payment_id IS NULL
OR v_signature IS NULL THEN RAISE EXCEPTION 'Missing razorpay_order_id, razorpay_payment_id, or razorpay_signature';
END IF;
-- 1. Prevent duplicate PDF unlock
IF v_plan_type = 'biodata_unlock' THEN IF EXISTS (
    SELECT 1
    FROM public.profiles
    WHERE user_id = v_user_id
        AND is_pdf_unlocked = TRUE
) THEN -- Check if this specific order was already processed (idempotency)
IF NOT EXISTS (
    SELECT 1
    FROM public.payments
    WHERE razorpay_order_id = v_order_id
) THEN RAISE EXCEPTION 'PDF already unlocked for this user';
END IF;
END IF;
END IF;
-- 2. Prevent duplicate subscription or downgrade
IF v_plan_type IN ('silver', 'gold', 'platinum') THEN
DECLARE v_current_plan TEXT;
v_current_status TEXT;
v_expires_at TIMESTAMPTZ;
BEGIN
SELECT plan_type,
    status,
    expires_at INTO v_current_plan,
    v_current_status,
    v_expires_at
FROM public.subscriptions
WHERE user_id = v_user_id;
IF v_current_status = 'active'
AND (
    v_expires_at IS NULL
    OR v_expires_at > NOW()
) THEN -- Define tier ranks: platinum=3, gold=2, silver=1, free=0
DECLARE v_target_rank INT := CASE
        WHEN v_plan_type = 'platinum' THEN 3
        WHEN v_plan_type = 'gold' THEN 2
        ELSE 1
    END;
v_current_rank INT := CASE
    WHEN v_current_plan = 'platinum' THEN 3
    WHEN v_current_plan = 'gold' THEN 2
    WHEN v_current_plan = 'silver' THEN 1
    ELSE 0
END;
BEGIN -- If target is same or lower than current active, and not idempotency, block
IF v_target_rank <= v_current_rank
AND NOT EXISTS (
    SELECT 1
    FROM public.payments
    WHERE razorpay_order_id = v_order_id
) THEN RAISE EXCEPTION 'User already has an active % or higher plan',
v_current_plan;
END IF;
END;
END IF;
END;
END IF;
SELECT value INTO v_secret
FROM private.razorpay_config
WHERE key = 'key_secret';
IF v_secret IS NULL
OR v_secret = '' THEN RAISE EXCEPTION 'Razorpay secret not configured. Run: INSERT INTO private.razorpay_config (key, value) VALUES (''key_secret'', ''your_razorpay_key_secret'');';
END IF;
v_expected_sig := encode(
    hmac(
        v_order_id || '|' || v_payment_id,
        v_secret,
        'sha256'
    ),
    'hex'
);
IF v_expected_sig != v_signature THEN RAISE EXCEPTION 'Invalid payment signature';
END IF;
-- Idempotency: if webhook already recorded payment, skip INSERT and ensure profile/unlock is applied
INSERT INTO public.payments (
        user_id,
        amount,
        currency,
        status,
        razorpay_order_id,
        razorpay_payment_id,
        razorpay_signature,
        plan_type,
        plan_duration,
        app_slug
    )
VALUES (
        v_user_id,
        v_amount,
        'INR',
        'captured',
        v_order_id,
        v_payment_id,
        v_signature,
        v_plan_type,
        CASE
            WHEN v_plan_type = 'biodata_unlock' THEN NULL
            ELSE 0
        END,
        v_app_slug,
        v_is_test
    ) ON CONFLICT (razorpay_order_id) DO NOTHING;
-- Always apply profile/subscription update (idempotent; safe if webhook already did it)
IF v_plan_type = 'biodata_unlock' THEN PERFORM private.fn_apply_pdf_unlock(v_user_id);
ELSIF v_plan_type IN ('silver', 'gold', 'platinum') THEN -- Upsert: create row if missing (edge case: user signed up before subscription trigger)
INSERT INTO public.subscriptions (user_id, plan_type, status, started_at)
VALUES (v_user_id, v_plan_type, 'active', NOW()) ON CONFLICT (user_id) DO
UPDATE
SET plan_type = v_plan_type,
    status = 'active',
    updated_at = NOW();
END IF;
v_result := jsonb_build_object('status', 'verified', 'plan_type', v_plan_type);
WHEN 'sync_pdf_unlock' THEN -- Fallback: re-apply unlock when verify_payment succeeded but profile fetch still shows locked
-- (e.g. replication lag, or fn_apply_pdf_unlock ran but client read stale)
IF EXISTS (
    SELECT 1
    FROM public.payments
    WHERE user_id = v_user_id
        AND plan_type = 'biodata_unlock'
        AND status = 'captured'
) THEN PERFORM private.fn_apply_pdf_unlock(v_user_id);
v_result := jsonb_build_object(
    'status',
    'sync_applied',
    'message',
    'PDF unlock re-applied'
);
ELSE v_result := jsonb_build_object(
    'status',
    'no_payment',
    'message',
    'No biodata_unlock payment found'
);
END IF;
WHEN 'record_payment' THEN
INSERT INTO public.payments (
        user_id,
        amount,
        status,
        razorpay_order_id,
        plan_type,
        plan_duration
    )
VALUES (
        v_user_id,
        (payload->>'amount')::INTEGER,
        payload->>'status',
        payload->>'order_id',
        payload->>'plan',
        (payload->>'duration')::INTEGER
    )
RETURNING jsonb_build_object('id', id) INTO v_result;
WHEN 'update_status' THEN
UPDATE public.payments
SET status = payload->>'status',
    razorpay_payment_id = payload->>'payment_id'
WHERE razorpay_order_id = payload->>'order_id'
    AND user_id = v_user_id;
v_result := jsonb_build_object('status', 'success');
WHEN 'get_history' THEN
SELECT jsonb_agg(t) INTO v_result
FROM (
        SELECT *
        FROM public.payments
        WHERE user_id = v_user_id
        ORDER BY created_at DESC
        LIMIT 50
    ) t;
ELSE RAISE EXCEPTION 'Invalid action';
END CASE
;
RETURN v_result;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;
GRANT EXECUTE ON FUNCTION public.fn_process_payment(TEXT, JSONB) TO authenticated;