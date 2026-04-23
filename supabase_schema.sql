-- WARNING: This schema is for context only and is not meant to be run.
-- Table order and constraints may not be valid for execution.

-- =====================================================
-- 00. COMPLETE DATABASE RESET
-- ⚠️ WARNING: THIS DELETES ALL DATA! 
-- =====================================================

-- =====================================================
-- STEP 1: DROP ALL TRIGGERS
-- =====================================================
DROP TRIGGER IF EXISTS tr_profiles_update_timestamp ON profiles;
DROP TRIGGER IF EXISTS tr_subscriptions_update_timestamp ON subscriptions;
DROP TRIGGER IF EXISTS tr_payments_update_timestamp ON payments;
DROP TRIGGER IF EXISTS tr_usage_tracking_update_timestamp ON usage_tracking;
DROP TRIGGER IF EXISTS tr_profile_shares_update_timestamp ON profile_shares;
DROP TRIGGER IF EXISTS tr_new_user_subscription ON auth.users;

-- =====================================================
-- STEP 2: DROP ALL FUNCTIONS
-- =====================================================
DROP FUNCTION IF EXISTS fn_update_timestamp() CASCADE;
DROP FUNCTION IF EXISTS fn_initialize_subscription() CASCADE;
DROP FUNCTION IF EXISTS fn_profile_shares_update_timestamp() CASCADE;

-- =====================================================
-- STEP 3: DROP ALL TABLES (in dependency order)
-- =====================================================
DROP TABLE IF EXISTS photos CASCADE;
DROP TABLE IF EXISTS bookmarks CASCADE;
DROP TABLE IF EXISTS profile_shares CASCADE;
DROP TABLE IF EXISTS usage_tracking CASCADE;
DROP TABLE IF EXISTS payments CASCADE;
DROP TABLE IF EXISTS subscriptions CASCADE;
DROP TABLE IF EXISTS profiles CASCADE;

-- =====================================================
-- 01. PROFILES TABLE
-- =====================================================
CREATE TABLE IF NOT EXISTS profiles (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
  phone_number TEXT UNIQUE,
  email TEXT,
  full_name TEXT NOT NULL,
  surname TEXT NOT NULL,
  age INTEGER NOT NULL CHECK (age >= 18 AND age <= 100),
  date_of_birth DATE,
  gender TEXT NOT NULL DEFAULT 'Female' CHECK (gender IN ('Male', 'Female', 'Other')),
  height TEXT NOT NULL,
  complexion TEXT,
  blood_group TEXT,
  marital_status TEXT DEFAULT 'Never Married',
  birth_place TEXT,
  birth_time TEXT,
  education TEXT NOT NULL,
  education_details TEXT,
  profession TEXT NOT NULL,
  job_details TEXT,
  company TEXT,
  annual_income TEXT,
  state TEXT,
  district TEXT,
  taluka TEXT,
  village TEXT,
  current_location TEXT NOT NULL DEFAULT '',
  permanent_location TEXT,
  native_place TEXT,
  father_name TEXT,
  father_occupation TEXT,
  mother_name TEXT,
  mother_occupation TEXT,
  siblings_count INTEGER DEFAULT 0,
  sister_count INTEGER DEFAULT 0,
  brother_count INTEGER DEFAULT 0,
  siblings_data JSONB DEFAULT '[]',
  family_type TEXT,
  family_status TEXT,
  marriage_readiness TEXT DEFAULT 'Ready for marriage',
  about_self TEXT,
  partner_expectations TEXT,
  expectation TEXT,
  is_premium BOOLEAN DEFAULT FALSE,
  profile_completion INTEGER DEFAULT 0 CHECK (profile_completion >= 0 AND profile_completion <= 100),
  is_verified BOOLEAN DEFAULT FALSE,
  trust_score INTEGER DEFAULT 0 CHECK (trust_score >= 0 AND trust_score <= 100),
  is_active BOOLEAN DEFAULT TRUE,
  is_pdf_unlocked BOOLEAN DEFAULT FALSE,
  gotra TEXT,
  vouch_count INTEGER DEFAULT 0, -- [NEW] Social Proof Count
  is_community_trusted BOOLEAN DEFAULT FALSE, -- [NEW] Badge Status
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW(),
  CONSTRAINT profiles_user_id_unique UNIQUE (user_id)
);

-- =====================================================
-- 02. PHOTOS TABLE
-- =====================================================
CREATE TABLE IF NOT EXISTS photos (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  profile_id UUID NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
  storage_path TEXT NOT NULL,
  public_url TEXT NOT NULL,
  semantic_label TEXT,
  is_primary BOOLEAN DEFAULT TRUE,
  is_approved BOOLEAN DEFAULT TRUE,
  uploaded_at TIMESTAMPTZ DEFAULT NOW()
);

-- =====================================================
-- 03. BOOKMARKS TABLE
-- =====================================================
CREATE TABLE IF NOT EXISTS bookmarks (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  profile_id UUID NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  UNIQUE(user_id, profile_id)
);

-- =====================================================
-- 04. PROFILE_SHARES TABLE
-- =====================================================
CREATE TABLE IF NOT EXISTS profile_shares (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  sharer_id UUID NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
  recipient_id UUID REFERENCES profiles(id) ON DELETE SET NULL,
  shared_profile_id UUID NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
  recipient_name TEXT,
  recipient_relation TEXT,
  sharing_method TEXT NOT NULL DEFAULT 'in_app' CHECK (sharing_method IN ('whatsapp', 'in_app', 'link')),
  status TEXT NOT NULL DEFAULT 'pending' CHECK (status IN ('pending', 'viewed', 'interested', 'rejected', 'new', 'matched')),
  view_count INTEGER DEFAULT 0,
  viewed_at TIMESTAMPTZ,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- =====================================================
-- 05. SUBSCRIPTIONS TABLE
-- =====================================================
CREATE TABLE IF NOT EXISTS subscriptions (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  plan_type TEXT NOT NULL DEFAULT 'free' CHECK (plan_type IN ('free', 'silver', 'gold', 'platinum')),
  status TEXT NOT NULL DEFAULT 'active' CHECK (status IN ('active', 'expired', 'cancelled', 'pending')),
  started_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  expires_at TIMESTAMPTZ,
  razorpay_subscription_id TEXT,
  auto_renew BOOLEAN DEFAULT FALSE,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW(),
  UNIQUE(user_id)
);

-- =====================================================
-- 06. PAYMENTS TABLE
-- =====================================================
CREATE TABLE IF NOT EXISTS payments (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  subscription_id UUID REFERENCES subscriptions(id) ON DELETE SET NULL,
  amount INTEGER NOT NULL CHECK (amount > 0),
  currency TEXT NOT NULL DEFAULT 'INR',
  status TEXT NOT NULL CHECK (status IN ('created', 'authorized', 'captured', 'failed', 'refunded')),
  razorpay_order_id TEXT UNIQUE,
  razorpay_payment_id TEXT,
  razorpay_signature TEXT,
  plan_type TEXT NOT NULL,
  plan_duration INTEGER,
  metadata JSONB,
  notes TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- =====================================================
-- 07. USAGE_TRACKING TABLE
-- =====================================================
CREATE TABLE IF NOT EXISTS usage_tracking (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  date DATE NOT NULL DEFAULT CURRENT_DATE,
  month DATE DEFAULT DATE_TRUNC('month', CURRENT_DATE),
  profile_views INTEGER DEFAULT 0 CHECK (profile_views >= 0),
  shares_count INTEGER DEFAULT 0 CHECK (shares_count >= 0),
  bookmarks_count INTEGER DEFAULT 0 CHECK (bookmarks_count >= 0),
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW(),
  UNIQUE(user_id, date)
);

-- =====================================================
-- 09. VERIFICATION REQUESTS
-- =====================================================
CREATE TABLE IF NOT EXISTS verification_requests (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
  verification_type TEXT NOT NULL CHECK (verification_type IN ('selfie', 'govt_id', 'community_id', 'video_bio')),
  status TEXT NOT NULL DEFAULT 'pending' CHECK (status IN ('pending', 'approved', 'rejected')),
  payload JSONB DEFAULT '{}',
  rejection_reason TEXT,
  verified_at TIMESTAMPTZ,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW(),
  UNIQUE(user_id, verification_type)
);

-- =====================================================
-- 11. USER BLOCKS
-- =====================================================
CREATE TABLE IF NOT EXISTS user_blocks (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  blocker_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
  blocked_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  UNIQUE(blocker_id, blocked_id),
  CONSTRAINT no_self_block CHECK (blocker_id != blocked_id)
);

-- =====================================================
-- 12. USER REPORTS
-- =====================================================
CREATE TABLE IF NOT EXISTS user_reports (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  reporter_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
  reported_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
  reason TEXT NOT NULL,
  details TEXT,
  status TEXT DEFAULT 'pending' CHECK (status IN ('pending', 'reviewed', 'action_taken')),
  created_at TIMESTAMPTZ DEFAULT NOW(),
  CONSTRAINT no_self_report CHECK (reporter_id != reported_id)
);
-- =====================================================
-- 13. REFERRALS & REWARDS
-- =====================================================
CREATE TABLE IF NOT EXISTS referrals (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    referrer_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    referred_user_id UUID UNIQUE REFERENCES auth.users(id) ON DELETE CASCADE,
    status TEXT DEFAULT 'pending' CHECK (status IN ('pending', 'completed')),
    created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS referral_stats (
    user_id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
    referral_count INTEGER DEFAULT 0,
    rewards_earned INTEGER DEFAULT 0,
    last_reward_at TIMESTAMPTZ,
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Function to handle referral rewards
CREATE OR REPLACE FUNCTION fn_on_referral_completed()
RETURNS TRIGGER AS $$
BEGIN
    -- Increment referral count for the referrer
    INSERT INTO referral_stats (user_id, referral_count)
    VALUES (NEW.referrer_id, 1)
    ON CONFLICT (user_id) 
    DO UPDATE SET referral_count = referral_stats.referral_count + 1, updated_at = NOW();

    -- Check for milestone: 3 referrals = 1 month Premium
    IF (SELECT referral_count FROM referral_stats WHERE user_id = NEW.referrer_id) % 3 = 0 THEN
        -- Grant 30 days premium
        update subscriptions 
        set expires_at = COALESCE(expires_at, NOW()) + INTERVAL '30 days',
            plan_type = 'premium',
            status = 'active',
            updated_at = NOW()
        where user_id = NEW.referrer_id;
        
        -- Log reward
        UPDATE referral_stats 
        SET rewards_earned = rewards_earned + 1, last_reward_at = NOW()
        WHERE user_id = NEW.referrer_id;
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER tr_referral_completed
AFTER UPDATE OF status ON referrals
FOR EACH ROW WHEN (NEW.status = 'completed')
EXECUTE FUNCTION fn_on_referral_completed();

-- =====================================================
-- 11. AUTOMATED MATCH DETECTION (Appended from queries/05_match_trigger.sql)
-- =====================================================

-- FIX: Update check constraint first (important if table already existed)
ALTER TABLE profile_shares DROP CONSTRAINT IF EXISTS profile_shares_status_check;
ALTER TABLE profile_shares ADD CONSTRAINT profile_shares_status_check 
  CHECK (status IN ('pending', 'viewed', 'interested', 'rejected', 'new', 'matched'));

CREATE OR REPLACE FUNCTION fn_auto_match_shares()
RETURNS TRIGGER AS $$
DECLARE
    reverse_match_id UUID;
BEGIN
    -- 1. If we are already marking as matched, just proceed.
    -- This prevents infinite recursion when the trigger updates the mutual record.
    IF NEW.status = 'matched' THEN
        RETURN NEW;
    END IF;

    -- Only check for In-App sharing
    IF NEW.sharing_method != 'in_app' THEN
        RETURN NEW;
    END IF;

    -- Look for a reverse share: 
    -- 1. Where the current recipient has shared THEIR profile with the current sharer
    -- 2. and the status is not already 'matched'
    SELECT id INTO reverse_match_id
    FROM profile_shares
    WHERE sharer_id = NEW.recipient_id
      AND recipient_id = NEW.sharer_id
      AND sharing_method = 'in_app'
      AND status != 'matched'
    LIMIT 1;

    -- If mutual interest exists
    IF reverse_match_id IS NOT NULL THEN
        -- Mark this new share as matched
        NEW.status := 'matched';
        NEW.updated_at := NOW();

        -- Mark the existing reverse share as matched
        UPDATE profile_shares
        SET status = 'matched',
            updated_at = NOW()
        WHERE id = reverse_match_id;
        
        RAISE NOTICE 'MATCH CREATED between % and %', NEW.sharer_id, NEW.recipient_id;
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Create the trigger
DROP TRIGGER IF EXISTS tr_auto_match_shares ON profile_shares;
CREATE TRIGGER tr_auto_match_shares
    BEFORE INSERT OR UPDATE OF status, sharing_method, recipient_id
    ON profile_shares
    FOR EACH ROW
    EXECUTE FUNCTION fn_auto_match_shares();

-- =====================================================
-- 14. VOUCHING & SOCIAL PROOF
-- =====================================================

CREATE TABLE IF NOT EXISTS vouches (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  vouch_id UUID NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
  vouched_id UUID NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
  relation TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  UNIQUE(vouch_id, vouched_id)
);

-- Denormalized fields in profiles
-- ALTER TABLE profiles ADD COLUMN IF NOT EXISTS vouch_count INTEGER DEFAULT 0;
-- ALTER TABLE profiles ADD COLUMN IF NOT EXISTS is_community_trusted BOOLEAN DEFAULT FALSE;

-- Trigger to automate vouch counts and badge status
CREATE OR REPLACE FUNCTION fn_on_vouch_change()
RETURNS TRIGGER AS $$
BEGIN
  IF (TG_OP = 'INSERT') THEN
    UPDATE profiles SET vouch_count = vouch_count + 1 WHERE id = NEW.vouched_id;
    -- Threshold for "Community Trusted" Badge
    UPDATE profiles SET is_community_trusted = (vouch_count >= 5) WHERE id = NEW.vouched_id;
  ELSIF (TG_OP = 'DELETE') THEN
    UPDATE profiles SET vouch_count = vouch_count - 1 WHERE id = OLD.vouched_id;
    UPDATE profiles SET is_community_trusted = (vouch_count >= 5) WHERE id = OLD.vouched_id;
  END IF;
  RETURN NULL;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER tr_on_vouch_change
AFTER INSERT OR DELETE ON vouches
FOR EACH ROW EXECUTE FUNCTION fn_on_vouch_change();
