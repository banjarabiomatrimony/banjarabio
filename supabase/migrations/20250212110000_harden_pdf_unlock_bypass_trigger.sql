-- =====================================================
-- Harden fn_protect_profile_system_fields for NULL/empty bypass check
-- Treats NULL and empty app.bypass_pdf_unlock as "not set" (block direct updates)
-- =====================================================

CREATE OR REPLACE FUNCTION public.fn_protect_profile_system_fields()
RETURNS TRIGGER AS $$
BEGIN
  IF NOT public.fn_is_admin(auth.uid()) THEN
    NEW.is_admin := OLD.is_admin;
    NEW.is_premium := OLD.is_premium;
    NEW.trust_score := OLD.trust_score;
    NEW.is_verified := OLD.is_verified;
    -- Allow is_pdf_unlocked when fn_apply_pdf_unlock sets app.bypass_pdf_unlock (transaction-local)
    -- COALESCE handles NULL; NULLIF+TRIM handles empty; treat anything != '1' as not bypass
    IF COALESCE(NULLIF(TRIM(current_setting('app.bypass_pdf_unlock', true)), ''), '0') != '1' THEN
      NEW.is_pdf_unlocked := OLD.is_pdf_unlocked;
    END IF;
    NEW.user_id := OLD.user_id;
  END IF;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;
