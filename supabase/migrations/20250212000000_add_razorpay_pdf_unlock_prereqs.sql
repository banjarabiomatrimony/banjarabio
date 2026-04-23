-- =====================================================
-- Prerequisites for fn_process_payment verify_payment/sync_pdf_unlock
-- Run before 20250212120000. Creates private schema, razorpay_config,
-- and fn_apply_pdf_unlock so fn_process_payment can call it.
-- =====================================================

CREATE EXTENSION IF NOT EXISTS pgcrypto;

CREATE SCHEMA IF NOT EXISTS private;

CREATE TABLE IF NOT EXISTS private.razorpay_config (
  key TEXT PRIMARY KEY,
  value TEXT NOT NULL,
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- app_slug for multi-app payment tracking (if payments exists)
DO $$
BEGIN
  IF EXISTS (SELECT 1 FROM information_schema.tables WHERE table_schema = 'public' AND table_name = 'payments') THEN
    ALTER TABLE public.payments ADD COLUMN IF NOT EXISTS app_slug TEXT DEFAULT 'banjara';
  END IF;
END $$;

-- PDF unlock: fn_apply_pdf_unlock sets app.bypass_pdf_unlock (transaction-local)
-- before UPDATE so fn_protect_profile_system_fields allows is_pdf_unlocked.
CREATE OR REPLACE FUNCTION private.fn_apply_pdf_unlock(p_user_id UUID)
RETURNS VOID AS $$
BEGIN
  PERFORM set_config('app.bypass_pdf_unlock', '1', true);
  UPDATE public.profiles
  SET is_pdf_unlocked = TRUE, updated_at = NOW()
  WHERE user_id = p_user_id;
  PERFORM set_config('app.bypass_pdf_unlock', '0', true);
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;
