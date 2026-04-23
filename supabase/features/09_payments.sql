-- Last run: 2025-02-12 — Update when re-run in Supabase SQL Editor
-- =====================================================
-- 09. PAYMENTS FEATURE
-- Handles Razorpay transactions and premium sync.
-- =====================================================

-- =====================================================
-- TABLE: payments
-- =====================================================
CREATE TABLE IF NOT EXISTS public.payments (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  subscription_id UUID REFERENCES public.subscriptions(id) ON DELETE SET NULL,
  amount INTEGER NOT NULL CHECK (amount > 0),
  currency TEXT NOT NULL DEFAULT 'INR',
  status TEXT NOT NULL CHECK (status IN ('created', 'authorized', 'captured', 'failed', 'refunded')),
  razorpay_order_id TEXT UNIQUE,
  razorpay_payment_id TEXT,
  razorpay_signature TEXT,
  plan_type TEXT NOT NULL,
  plan_duration INTEGER,
  app_slug TEXT DEFAULT 'banjara',
  metadata JSONB,
  notes TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- INDEXES (get_history: user_id + created_at DESC)
CREATE INDEX IF NOT EXISTS idx_payments_user_id ON public.payments(user_id);
CREATE INDEX IF NOT EXISTS idx_payments_status ON public.payments(status);
CREATE INDEX IF NOT EXISTS idx_payments_user_created
  ON public.payments(user_id, created_at DESC NULLS LAST);

-- RLS
ALTER TABLE public.payments ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Users view own payments" ON public.payments;
CREATE POLICY "Users view own payments" ON public.payments FOR SELECT USING (auth.uid() = user_id);

DROP POLICY IF EXISTS "Users insert own payments" ON public.payments;
CREATE POLICY "Users insert own payments" ON public.payments FOR INSERT WITH CHECK (auth.uid() = user_id);

-- =====================================================
-- TRIGGER: Sync Premium Status
-- =====================================================
-- Only set is_premium for paid plans (silver/gold/platinum); free users stay false.
CREATE OR REPLACE FUNCTION public.fn_sync_premium_status()
RETURNS TRIGGER AS $$
BEGIN
  UPDATE public.profiles
  SET is_premium = (NEW.status = 'active' AND NEW.plan_type IN ('silver', 'gold', 'platinum'))
  WHERE user_id = NEW.user_id;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

DROP TRIGGER IF EXISTS tr_sync_premium_on_subscription ON public.subscriptions;
CREATE TRIGGER tr_sync_premium_on_subscription
  AFTER INSERT OR UPDATE OF status ON public.subscriptions
  FOR EACH ROW EXECUTE FUNCTION public.fn_sync_premium_status();

-- =====================================================
-- MASTER RPC FUNCTION: fn_process_payment
-- =====================================================
CREATE OR REPLACE FUNCTION public.fn_process_payment(
    action TEXT,
    payload JSONB
) RETURNS JSONB AS $$
DECLARE
    v_user_id UUID := auth.uid();
    v_result JSONB;
BEGIN
    IF v_user_id IS NULL THEN RAISE EXCEPTION 'Not authenticated'; END IF;

    CASE action
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
