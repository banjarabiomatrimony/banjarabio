-- Last run: 2025-02-12 — Update when re-run in Supabase SQL Editor
-- =====================================================
-- 04. REVIEWER DATA FEATURE
-- Seeds 3 tester accounts for manual QA (create in auth.users first):
--   tester@banjarabio.com      → General: sees ALL profiles
--   tester_boy@banjarabio.com → Boy: sees only tester_girl
--   tester_girl@banjarabio.com → Girl: sees only tester_boy
-- ⚠️ Run AFTER 01_profiles and 08_subscriptions.
-- Idempotent: safe to re-run (ON CONFLICT updates).
-- =====================================================

DO $$
DECLARE
    r RECORD;
BEGIN
    FOR r IN (
        SELECT id, email FROM auth.users
        WHERE email IN ('tester@banjarabio.com', 'tester_boy@banjarabio.com', 'tester_girl@banjarabio.com')
    ) LOOP
        IF r.email = 'tester_boy@banjarabio.com' THEN
            INSERT INTO public.profiles (
                user_id, email, phone_number, full_name, surname, gotra, age, gender, height,
                education, profession, state, district, taluka, village, marriage_readiness,
                is_premium, profile_completion, is_verified, trust_score, is_active
            ) VALUES (
                r.id, r.email, '+919876543211', 'Rahul Sharma', 'Sharma', 'Pandey', 28, 'Male', '5''10"',
                'MBA', 'Software Engineer', 'Maharashtra', 'Nagpur', 'Nagpur', 'Civil Lines', 'Ready for marriage',
                TRUE, 100, TRUE, 95, TRUE
            ) ON CONFLICT (user_id) DO UPDATE SET
                is_premium = TRUE, profile_completion = 100, trust_score = 95, is_active = TRUE;
        ELSE
            -- tester@ and tester_girl@ (both Female)
            INSERT INTO public.profiles (
                user_id, email, phone_number, full_name, surname, gotra, age, gender, height,
                education, profession, state, district, taluka, village, marriage_readiness,
                is_premium, profile_completion, is_verified, trust_score, is_active
            ) VALUES (
                r.id, r.email, '+919876543210', 'Priya Rathod', 'Rathod', 'Chauhan', 25, 'Female', '5''4"',
                'MBA', 'Marketing Lead', 'Maharashtra', 'Nagpur', 'Nagpur', 'Dharampeth', 'Ready for marriage',
                TRUE, 100, TRUE, 95, TRUE
            ) ON CONFLICT (user_id) DO UPDATE SET
                is_premium = TRUE, profile_completion = 100, trust_score = 95, is_active = TRUE;
        END IF;

        INSERT INTO public.subscriptions (user_id, plan_type, status, started_at)
        VALUES (r.id, 'platinum', 'active', NOW())
        ON CONFLICT (user_id) DO UPDATE SET status = 'active', plan_type = 'platinum';

        RAISE NOTICE 'Tester profile seeded for %', r.email;
    END LOOP;
END $$;
