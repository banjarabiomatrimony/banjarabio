-- Migration: Add admin_update_profile action to fn_admin_actions
-- This allows admins to edit any user's profile, bypassing RLS.
CREATE OR REPLACE FUNCTION public.fn_admin_actions(action TEXT, p_payload JSONB) RETURNS JSONB AS $$
DECLARE v_admin_id UUID := auth.uid();
v_result JSONB;
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
            -- Financial (Payments) - Dividing by 100.0 for Rupees. EXCLUDING test payments from calculations.
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
            -- Engagement (Usage Tracking & Chat)
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
        SELECT vr.id,
            vr.user_id,
            vr.verification_type,
            vr.status,
            vr.payload,
            vr.rejection_reason,
            vr.admin_notes,
            vr.verified_at,
            vr.created_at,
            vr.updated_at,
            jsonb_build_object('full_name', p.full_name, 'email', p.email) AS profiles
        FROM public.verification_requests vr
            LEFT JOIN public.profiles p ON p.user_id = vr.user_id
        WHERE vr.status = 'pending'
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
UPDATE public.verification_requests
SET status = (p_payload->>'status')::TEXT,
    admin_notes = COALESCE(p_payload->>'notes', admin_notes),
    rejection_reason = COALESCE(p_payload->>'rejection_reason', rejection_reason),
    updated_at = NOW()
WHERE id = (p_payload->>'request_id')::UUID;
v_result := jsonb_build_object('status', 'success');
WHEN 'update_reference_status' THEN
UPDATE public.user_references
SET status = (p_payload->>'status')::TEXT
WHERE id = (p_payload->>'reference_id')::UUID;
v_result := jsonb_build_object('status', 'success');
WHEN 'toggle_premium' THEN
UPDATE public.profiles
SET is_premium = (p_payload->>'is_premium')::BOOLEAN,
    updated_at = NOW()
WHERE user_id = (p_payload->>'target_user_id')::UUID;
v_result := jsonb_build_object('status', 'success');
WHEN 'manual_verification' THEN
UPDATE public.profiles
SET email_verified = COALESCE(
        (p_payload->>'verify_email')::BOOLEAN,
        email_verified
    ),
    phone_verified = COALESCE(
        (p_payload->>'verify_phone')::BOOLEAN,
        phone_verified
    ),
    updated_at = NOW()
WHERE user_id = (p_payload->>'target_user_id')::UUID;
v_result := jsonb_build_object('status', 'success');
-- =====================================================
-- NEW: Admin Update Profile (bypasses RLS for admin)
-- =====================================================
WHEN 'admin_update_profile' THEN
UPDATE public.profiles
SET full_name = COALESCE(p_payload->>'full_name', full_name),
    surname = COALESCE(p_payload->>'surname', surname),
    gotra = COALESCE(p_payload->>'gotra', gotra),
    age = COALESCE((p_payload->>'age')::INTEGER, age),
    date_of_birth = COALESCE((p_payload->>'date_of_birth')::DATE, date_of_birth),
    gender = COALESCE(p_payload->>'gender', gender),
    height = COALESCE(p_payload->>'height', height),
    complexion = COALESCE(p_payload->>'complexion', complexion),
    blood_group = COALESCE(p_payload->>'blood_group', blood_group),
    marital_status = COALESCE(p_payload->>'marital_status', marital_status),
    education = COALESCE(p_payload->>'education', education),
    education_details = COALESCE(p_payload->>'education_details', education_details),
    profession = COALESCE(p_payload->>'profession', profession),
    job_details = COALESCE(p_payload->>'job_details', job_details),
    company = COALESCE(p_payload->>'company', company),
    annual_income = COALESCE(p_payload->>'annual_income', annual_income),
    state = COALESCE(p_payload->>'state', state),
    district = COALESCE(p_payload->>'district', district),
    taluka = COALESCE(p_payload->>'taluka', taluka),
    village = COALESCE(p_payload->>'village', village),
    current_location = COALESCE(p_payload->>'current_location', current_location),
    permanent_location = COALESCE(
        p_payload->>'permanent_location',
        permanent_location
    ),
    native_place = COALESCE(p_payload->>'native_place', native_place),
    birth_place = COALESCE(p_payload->>'birth_place', birth_place),
    birth_time = COALESCE(p_payload->>'birth_time', birth_time),
    father_name = COALESCE(p_payload->>'father_name', father_name),
    father_occupation = COALESCE(p_payload->>'father_occupation', father_occupation),
    mother_name = COALESCE(p_payload->>'mother_name', mother_name),
    mother_occupation = COALESCE(p_payload->>'mother_occupation', mother_occupation),
    siblings_count = COALESCE(
        (p_payload->>'siblings_count')::INTEGER,
        siblings_count
    ),
    sister_count = COALESCE(
        (p_payload->>'sister_count')::INTEGER,
        sister_count
    ),
    brother_count = COALESCE(
        (p_payload->>'brother_count')::INTEGER,
        brother_count
    ),
    siblings_data = COALESCE((p_payload->'siblings_data')::JSONB, siblings_data),
    family_type = COALESCE(p_payload->>'family_type', family_type),
    family_status = COALESCE(p_payload->>'family_status', family_status),
    marriage_readiness = COALESCE(
        p_payload->>'marriage_readiness',
        marriage_readiness
    ),
    about_self = COALESCE(p_payload->>'about_self', about_self),
    partner_expectations = COALESCE(
        p_payload->>'partner_expectations',
        partner_expectations
    ),
    expectation = COALESCE(p_payload->>'expectation', expectation),
    profile_created_by = COALESCE(
        p_payload->>'profile_created_by',
        profile_created_by
    ),
    is_active = COALESCE((p_payload->>'is_active')::BOOLEAN, is_active),
    updated_at = NOW()
WHERE user_id = (p_payload->>'target_user_id')::UUID;
v_result := jsonb_build_object('status', 'success');
WHEN 'get_creators' THEN
SELECT COALESCE(jsonb_agg(row_to_json(t)::jsonb), '[]'::jsonb) INTO v_result
FROM (
        SELECT *
        FROM public.creators
        ORDER BY created_at DESC
    ) t;
WHEN 'add_creator' THEN
INSERT INTO public.creators (
        name,
        promo_code,
        commission_pct,
        instagram_handle
    )
VALUES (
        (p_payload->>'name')::TEXT,
        upper(trim((p_payload->>'promo_code')::TEXT)),
        COALESCE((p_payload->>'commission_pct')::DECIMAL, 0.10),
        (p_payload->>'instagram_handle')::TEXT
    )
RETURNING jsonb_build_object('id', id) INTO v_result;
WHEN 'update_creator' THEN
UPDATE public.creators
SET name = COALESCE((p_payload->>'name')::TEXT, name),
    commission_pct = COALESCE(
        (p_payload->>'commission_pct')::DECIMAL,
        commission_pct
    ),
    instagram_handle = COALESCE(
        (p_payload->>'instagram_handle')::TEXT,
        instagram_handle
    ),
    is_active = COALESCE((p_payload->>'is_active')::BOOLEAN, is_active),
    updated_at = NOW()
WHERE id = (p_payload->>'id')::UUID;
v_result := jsonb_build_object('status', 'success');
ELSE RAISE EXCEPTION 'Invalid admin action: %',
action;
END CASE
;
RETURN v_result;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;
GRANT EXECUTE ON FUNCTION public.fn_admin_actions(TEXT, JSONB) TO authenticated;