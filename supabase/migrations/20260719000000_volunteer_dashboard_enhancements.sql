-- Migration: Upgrade fn_volunteer_actions with call logging and work log tracking

CREATE OR REPLACE FUNCTION public.fn_volunteer_actions(action text, p_payload jsonb)
RETURNS jsonb
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
    v_volunteer_id UUID := auth.uid();
    v_result       JSONB;
    v_search_query TEXT;
    v_clean_search TEXT;
    v_new_user_id  UUID;
BEGIN
    -- Auth gate
    IF v_volunteer_id IS NULL THEN
        RAISE EXCEPTION 'Not authenticated';
    END IF;
    IF NOT (public.fn_is_volunteer(v_volunteer_id) OR public.fn_is_admin(v_volunteer_id)) THEN
        RAISE EXCEPTION 'Unauthorized: volunteer access required';
    END IF;

    v_search_query := TRIM(COALESCE(p_payload->>'search_query', ''));
    v_clean_search := REGEXP_REPLACE(v_search_query, '^BB[MF]?-', '', 'i');

    CASE action
    -- ==================================================================
    -- search_profiles: Find existing profiles by name / phone / BB-ID
    -- ==================================================================
    WHEN 'search_profiles' THEN
        SELECT COALESCE(jsonb_agg(row_to_json(t)::jsonb), '[]'::jsonb)
          INTO v_result
          FROM (
            SELECT id, user_id, full_name, surname, age, gender,
                   phone_number, village, district, state,
                   profile_completion, call_status, last_called_at, updated_at
              FROM public.profiles
             WHERE v_search_query <> ''
               AND (
                   full_name ILIKE '%' || v_search_query || '%'
                OR surname   ILIKE '%' || v_search_query || '%'
                OR phone_number ILIKE '%' || v_search_query || '%'
                OR id::TEXT  ILIKE v_clean_search || '%'
               )
             ORDER BY updated_at DESC
             LIMIT COALESCE((p_payload->>'limit')::INT, 50)
             OFFSET COALESCE((p_payload->>'offset')::INT, 0)
          ) t;

    -- ==================================================================
    -- get_profile_detail: Full profile data for correction screen
    -- ==================================================================
    WHEN 'get_profile_detail' THEN
        SELECT row_to_json(p)::jsonb
          INTO v_result
          FROM public.profiles p
         WHERE id = (p_payload->>'profile_id')::UUID;

        IF v_result IS NULL THEN
            RAISE EXCEPTION 'Profile not found';
        END IF;

    -- ==================================================================
    -- register_user: Create a brand-new profile (offline registrations)
    -- ==================================================================
    WHEN 'register_user' THEN
        -- Duplicate check by phone
        IF EXISTS (
            SELECT 1 FROM public.profiles
             WHERE phone_number = (p_payload->>'phone_number')::TEXT
        ) THEN
            RAISE EXCEPTION 'Phone number already registered';
        END IF;

        -- Generate a UUID for the new profile
        v_new_user_id := extensions.uuid_generate_v4();

        INSERT INTO public.profiles (
            id, full_name, surname, age, gender,
            phone_number, date_of_birth,
            education, profession, job_details, company, annual_income,
            state, district, taluka, village,
            father_name, father_occupation,
            mother_name, mother_occupation,
            brother_count, sister_count, family_type,
            gotra, marital_status,
            height, complexion, blood_group,
            about_self, partner_expectations,
            profile_created_by,
            profile_completion,
            role, created_at, updated_at,
            assigned_to
        ) VALUES (
            v_new_user_id,
            COALESCE(p_payload->>'full_name', ''),
            p_payload->>'surname',
            (p_payload->>'age')::INT,
            COALESCE(p_payload->>'gender', 'Male'),
            p_payload->>'phone_number',
            (p_payload->>'date_of_birth')::DATE,
            p_payload->>'education',
            p_payload->>'profession',
            p_payload->>'job_details',
            p_payload->>'company',
            p_payload->>'annual_income',
            p_payload->>'state',
            p_payload->>'district',
            p_payload->>'taluka',
            p_payload->>'village',
            p_payload->>'father_name',
            p_payload->>'father_occupation',
            p_payload->>'mother_name',
            p_payload->>'mother_occupation',
            COALESCE((p_payload->>'brother_count')::INT, 0),
            COALESCE((p_payload->>'sister_count')::INT, 0),
            p_payload->>'family_type',
            p_payload->>'gotra',
            COALESCE(p_payload->>'marital_status', 'Never Married'),
            p_payload->>'height',
            p_payload->>'complexion',
            p_payload->>'blood_group',
            p_payload->>'about_self',
            p_payload->>'partner_expectations',
            'Volunteer',
            30,
            'user',
            NOW(), NOW(),
            v_volunteer_id
        );

        -- Insert call log entry to track volunteer work
        INSERT INTO public.call_logs (
            id, telecaller_id, profile_id, action, outcome, notes, created_at
        ) VALUES (
            extensions.uuid_generate_v4(),
            v_volunteer_id,
            v_new_user_id,
            'Registration',
            'Success',
            'Registered profile ' || COALESCE(p_payload->>'full_name', '') || ' ' || COALESCE(p_payload->>'surname', '') || '.',
            NOW()
        );

        v_result := jsonb_build_object(
            'status', 'success',
            'profile_id', v_new_user_id::TEXT,
            'message', 'Profile registered successfully'
        );

    -- ==================================================================
    -- update_user_profile: Correct / enrich an existing profile
    -- ==================================================================
    WHEN 'update_user_profile' THEN
        IF NOT EXISTS (
            SELECT 1 FROM public.profiles
             WHERE id = (p_payload->>'target_profile_id')::UUID
        ) THEN
            RAISE EXCEPTION 'Profile not found';
        END IF;

        UPDATE public.profiles
           SET full_name          = COALESCE(NULLIF(p_payload->>'full_name', ''),          full_name),
               surname            = COALESCE(NULLIF(p_payload->>'surname', ''),            surname),
               age                = COALESCE((p_payload->>'age')::INT,                     age),
               gender             = COALESCE(NULLIF(p_payload->>'gender', ''),             gender),
               phone_number       = COALESCE(NULLIF(p_payload->>'phone_number', ''),       phone_number),
               date_of_birth      = COALESCE((p_payload->>'date_of_birth')::DATE,          date_of_birth),
               education          = COALESCE(NULLIF(p_payload->>'education', ''),          education),
               profession         = COALESCE(NULLIF(p_payload->>'profession', ''),         profession),
               job_details        = COALESCE(NULLIF(p_payload->>'job_details', ''),        job_details),
               company            = COALESCE(NULLIF(p_payload->>'company', ''),            company),
               annual_income      = COALESCE(NULLIF(p_payload->>'annual_income', ''),      annual_income),
               state              = COALESCE(NULLIF(p_payload->>'state', ''),              state),
               district           = COALESCE(NULLIF(p_payload->>'district', ''),           district),
               taluka             = COALESCE(NULLIF(p_payload->>'taluka', ''),             taluka),
               village            = COALESCE(NULLIF(p_payload->>'village', ''),            village),
               father_name        = COALESCE(NULLIF(p_payload->>'father_name', ''),        father_name),
               father_occupation  = COALESCE(NULLIF(p_payload->>'father_occupation', ''),  father_occupation),
               mother_name        = COALESCE(NULLIF(p_payload->>'mother_name', ''),        mother_name),
               mother_occupation  = COALESCE(NULLIF(p_payload->>'mother_occupation', ''),  mother_occupation),
               brother_count      = COALESCE((p_payload->>'brother_count')::INT,           brother_count),
               sister_count       = COALESCE((p_payload->>'sister_count')::INT,            sister_count),
               family_type        = COALESCE(NULLIF(p_payload->>'family_type', ''),        family_type),
               gotra              = COALESCE(NULLIF(p_payload->>'gotra', ''),              gotra),
               marital_status     = COALESCE(NULLIF(p_payload->>'marital_status', ''),     marital_status),
               height             = COALESCE(NULLIF(p_payload->>'height', ''),             height),
               complexion         = COALESCE(NULLIF(p_payload->>'complexion', ''),         complexion),
               blood_group        = COALESCE(NULLIF(p_payload->>'blood_group', ''),        blood_group),
               about_self         = COALESCE(NULLIF(p_payload->>'about_self', ''),         about_self),
               partner_expectations = COALESCE(NULLIF(p_payload->>'partner_expectations', ''), partner_expectations),
               updated_at         = NOW(),
               assigned_to        = COALESCE(assigned_to, v_volunteer_id)
         WHERE id = (p_payload->>'target_profile_id')::UUID;

        -- Insert call log entry to track volunteer work
        INSERT INTO public.call_logs (
            id, telecaller_id, profile_id, action, outcome, notes, created_at
        ) VALUES (
            extensions.uuid_generate_v4(),
            v_volunteer_id,
            (p_payload->>'target_profile_id')::UUID,
            'Correction',
            'Success',
            'Corrected profile details.',
            NOW()
        );

        v_result := jsonb_build_object('status', 'success', 'message', 'Profile updated');

    -- ==================================================================
    -- log_call: Log telecalling work and update lead call status
    -- ==================================================================
    WHEN 'log_call' THEN
        INSERT INTO public.call_logs (
            id, telecaller_id, profile_id, action, outcome, notes, created_at
        ) VALUES (
            extensions.uuid_generate_v4(),
            v_volunteer_id,
            (p_payload->>'profile_id')::UUID,
            'Call',
            COALESCE(p_payload->>'outcome', 'Connected'),
            p_payload->>'notes',
            NOW()
        );

        UPDATE public.profiles
           SET call_status = COALESCE(p_payload->>'outcome', 'Connected'),
               last_called_at = NOW(),
               assigned_to = COALESCE(assigned_to, v_volunteer_id)
         WHERE id = (p_payload->>'profile_id')::UUID;

        v_result := jsonb_build_object('status', 'success', 'message', 'Call logged successfully');

    -- ==================================================================
    -- get_my_call_logs: Fetch calling history for current volunteer
    -- ==================================================================
    WHEN 'get_my_call_logs' THEN
        SELECT COALESCE(jsonb_agg(row_to_json(t)::jsonb), '[]'::jsonb)
          INTO v_result
          FROM (
            SELECT c.id, c.profile_id, c.action, c.outcome, c.notes, c.created_at,
                   p.full_name as profile_name, p.surname as profile_surname,
                   p.phone_number as profile_phone_number
              FROM public.call_logs c
              LEFT JOIN public.profiles p ON c.profile_id = p.id
             WHERE c.telecaller_id = v_volunteer_id
             ORDER BY c.created_at DESC
             LIMIT 50
          ) t;

    -- ==================================================================
    -- get_my_registrations: Fetch recent registrations by current volunteer
    -- ==================================================================
    WHEN 'get_my_registrations' THEN
        SELECT COALESCE(jsonb_agg(row_to_json(t)::jsonb), '[]'::jsonb)
          INTO v_result
          FROM (
            SELECT id, full_name, surname, phone_number, created_at, state, district, taluka
              FROM public.profiles
             WHERE profile_created_by = 'Volunteer'
               AND assigned_to = v_volunteer_id
             ORDER BY created_at DESC
             LIMIT 50
          ) t;

    -- ==================================================================
    -- get_my_stats: Personalized volunteer activity counts
    -- ==================================================================
    WHEN 'get_my_stats' THEN
        SELECT jsonb_build_object(
            'registered_today', (
                SELECT count(*) FROM public.call_logs
                 WHERE telecaller_id = v_volunteer_id
                   AND action = 'Registration'
                   AND created_at::date = CURRENT_DATE
            ),
            'corrected_today', (
                SELECT count(*) FROM public.call_logs
                 WHERE telecaller_id = v_volunteer_id
                   AND action = 'Correction'
                   AND created_at::date = CURRENT_DATE
            ),
            'called_today', (
                SELECT count(*) FROM public.call_logs
                 WHERE telecaller_id = v_volunteer_id
                   AND action = 'Call'
                   AND created_at::date = CURRENT_DATE
            ),
            'total_registered', (
                SELECT count(*) FROM public.call_logs
                 WHERE telecaller_id = v_volunteer_id
                   AND action = 'Registration'
            ),
            'total_corrected', (
                SELECT count(*) FROM public.call_logs
                 WHERE telecaller_id = v_volunteer_id
                   AND action = 'Correction'
            ),
            'total_called', (
                SELECT count(*) FROM public.call_logs
                 WHERE telecaller_id = v_volunteer_id
                   AND action = 'Call'
            )
        ) INTO v_result;

    ELSE
        RAISE EXCEPTION 'Unknown volunteer action: %', action;
    END CASE;

    RETURN v_result;
END;
$$;
