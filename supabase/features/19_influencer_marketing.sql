-- =====================================================
-- 19. INFLUENCER MARKETING SYSTEM
-- Handles creator management, referral tracking, and commissions.
-- =====================================================
-- 1. Creators Table
CREATE TABLE IF NOT EXISTS public.creators (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name TEXT NOT NULL,
    promo_code TEXT NOT NULL UNIQUE,
    commission_pct DECIMAL NOT NULL DEFAULT 0.10,
    instagram_handle TEXT,
    total_referrals INTEGER DEFAULT 0,
    total_conversions INTEGER DEFAULT 0,
    total_commission_earned DECIMAL DEFAULT 0,
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);
-- 2. Creator Referrals Table
CREATE TABLE IF NOT EXISTS public.creator_referrals (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    creator_id UUID NOT NULL REFERENCES public.creators(id) ON DELETE CASCADE,
    referred_user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    status TEXT NOT NULL DEFAULT 'pending' CHECK (status IN ('pending', 'converted', 'expired')),
    created_at TIMESTAMPTZ DEFAULT NOW(),
    UNIQUE(referred_user_id) -- Only one creator referral per user (first touch)
);
-- 3. Creator Commissions Table
CREATE TABLE IF NOT EXISTS public.creator_commissions (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    creator_id UUID NOT NULL REFERENCES public.creators(id) ON DELETE CASCADE,
    user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    payment_id UUID NOT NULL REFERENCES public.payments(id) ON DELETE CASCADE,
    amount DECIMAL NOT NULL,
    commission_earned DECIMAL NOT NULL,
    created_at TIMESTAMPTZ DEFAULT NOW()
);
-- Indexes
CREATE INDEX IF NOT EXISTS idx_creators_promo_code ON public.creators(promo_code);
CREATE INDEX IF NOT EXISTS idx_creator_referrals_creator ON public.creator_referrals(creator_id);
CREATE INDEX IF NOT EXISTS idx_creator_commissions_creator ON public.creator_commissions(creator_id);
-- RLS
ALTER TABLE public.creators ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.creator_referrals ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.creator_commissions ENABLE ROW LEVEL SECURITY;
-- Policies
CREATE POLICY "Admins view all creators" ON public.creators FOR
SELECT USING (
        EXISTS (
            SELECT 1
            FROM public.profiles
            WHERE user_id = auth.uid()
                AND is_admin = true
        )
    );
CREATE POLICY "Admins manage creators" ON public.creators FOR ALL USING (
    EXISTS (
        SELECT 1
        FROM public.profiles
        WHERE user_id = auth.uid()
            AND is_admin = true
    )
);
-- RPC: Register Referral
CREATE OR REPLACE FUNCTION public.fn_register_creator_referral(p_promo_code TEXT) RETURNS JSONB LANGUAGE plpgsql SECURITY DEFINER
SET search_path = public AS $$
DECLARE v_creator_id UUID;
v_uid UUID := auth.uid();
BEGIN IF v_uid IS NULL THEN RETURN jsonb_build_object('ok', false, 'error', 'unauthenticated');
END IF;
SELECT id INTO v_creator_id
FROM public.creators
WHERE promo_code = upper(trim(p_promo_code))
    AND is_active = true;
IF v_creator_id IS NULL THEN RETURN jsonb_build_object('ok', false, 'error', 'invalid_promo_code');
END IF;
-- Insert referral (ignore if already referred by someone else due to UNIQUE constraint)
INSERT INTO public.creator_referrals (creator_id, referred_user_id)
VALUES (v_creator_id, v_uid) ON CONFLICT (referred_user_id) DO NOTHING;
-- Increment total referrals
UPDATE public.creators
SET total_referrals = total_referrals + 1
WHERE id = v_creator_id;
RETURN jsonb_build_object('ok', true);
END;
$$;
-- Trigger: Award Commission on Payment
CREATE OR REPLACE FUNCTION public.fn_on_creator_conversion() RETURNS TRIGGER AS $$
DECLARE v_referral_id UUID;
v_creator_id UUID;
v_comm_pct DECIMAL;
v_days_diff INTEGER;
v_commission_amt DECIMAL;
BEGIN -- We only care about successful subscription payments
IF NEW.status != 'captured'
OR NEW.plan_type NOT IN ('silver', 'gold', 'platinum') THEN RETURN NEW;
END IF;
-- Check if user has a pending referral
SELECT id,
    creator_id,
    (
        EXTRACT(
            EPOCH
            FROM (NOW() - created_at)
        ) / 86400
    )::INTEGER INTO v_referral_id,
    v_creator_id,
    v_days_diff
FROM public.creator_referrals
WHERE referred_user_id = NEW.user_id
    AND status = 'pending';
-- If referral exists AND within 7 days
IF v_referral_id IS NOT NULL
AND v_days_diff <= 7 THEN
SELECT commission_pct INTO v_comm_pct
FROM public.creators
WHERE id = v_creator_id;
v_commission_amt := NEW.amount * v_comm_pct;
-- Record commission
INSERT INTO public.creator_commissions (
        creator_id,
        user_id,
        payment_id,
        amount,
        commission_earned
    )
VALUES (
        v_creator_id,
        NEW.user_id,
        NEW.id,
        NEW.amount,
        v_commission_amt
    );
-- Update referral status
UPDATE public.creator_referrals
SET status = 'converted'
WHERE id = v_referral_id;
-- Update creator stats
UPDATE public.creators
SET total_conversions = total_conversions + 1,
    total_commission_earned = total_commission_earned + v_commission_amt
WHERE id = v_creator_id;
END IF;
RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;
DROP TRIGGER IF EXISTS tr_creator_conversion ON public.payments;
CREATE TRIGGER tr_creator_conversion
AFTER
INSERT
    OR
UPDATE OF status ON public.payments FOR EACH ROW EXECUTE FUNCTION public.fn_on_creator_conversion();
GRANT EXECUTE ON FUNCTION public.fn_register_creator_referral(TEXT) TO authenticated;