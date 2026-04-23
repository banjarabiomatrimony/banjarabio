-- 🚀 [BanjaraBio] ADD staff action: update_lead_profile
-- Purpose: Allow staff/telecallers to update lead profiles directly via RPC

-- We need to replace the entire function to add the CASE action
CREATE OR REPLACE FUNCTION public.fn_staff_actions(action TEXT, p_payload JSONB)
RETURNS JSONB AS $$
DECLARE
    v_staff_id UUID := auth.uid();
    v_result JSONB;
BEGIN
    -- 🛡️ SECURITY CHECK
    IF v_staff_id IS NULL THEN 
        RAISE EXCEPTION 'Not authenticated'; 
    END IF;

    -- Check if user has 'staff' or 'admin' role
    IF NOT (public.fn_is_staff(v_staff_id) OR public.fn_is_admin(v_staff_id)) THEN 
        RAISE EXCEPTION 'Unauthorized: staff access required'; 
    END IF;

    -- 🚀 ACTION DISPATCHER
    CASE action
        -- 📈 [DASHBOARD] Get summary metrics for me
        WHEN 'get_my_summary' THEN
            SELECT jsonb_build_object(
                'total_assigned', (SELECT count(*) FROM public.profiles WHERE assigned_to = v_staff_id),
                'not_called', (SELECT count(*) FROM public.profiles WHERE assigned_to = v_staff_id AND call_status = 'not_called'),
                'follow_up', (SELECT count(*) FROM public.profiles WHERE assigned_to = v_staff_id AND call_status = 'follow_up'),
                'converted', (SELECT count(*) FROM public.profiles WHERE assigned_to = v_staff_id AND call_status = 'converted'),
                'calls_today', (SELECT count(*) FROM public.call_logs WHERE telecaller_id = v_staff_id AND created_at::date = CURRENT_DATE)
            ) INTO v_result;

        -- 👥 [LEADS] Fetch my assigned leads with pagination
        WHEN 'get_my_leads' THEN
            SELECT COALESCE(jsonb_agg(row_to_json(t)::jsonb), '[]'::jsonb) INTO v_result
            FROM (
                SELECT 
                    id, user_id, full_name, surname, age, gender, 
                    village, profile_completion, call_status, 
                    phone_number, assigned_to, updated_at
                FROM public.profiles 
                WHERE assigned_to = v_staff_id
                ORDER BY updated_at DESC
                LIMIT COALESCE((p_payload->>'limit')::INT, 100)
                OFFSET COALESCE((p_payload->>'offset')::INT, 0)
            ) t;

        -- 💬 [WHATSAPP] Get templates for interaction
        WHEN 'get_whatsapp_templates' THEN
             SELECT COALESCE(jsonb_agg(row_to_json(t)::jsonb), '[]'::jsonb) INTO v_result
             FROM (SELECT * FROM public.whatsapp_templates ORDER BY category, name) t;

        -- 📄 [LEAD DATA] Fetch specific lead data for templates
        WHEN 'get_lead_for_template' THEN
             SELECT row_to_json(t)::jsonb INTO v_result
             FROM (
                SELECT 
                    full_name as name,
                    profile_completion as completion,
                    (SELECT count(*) FROM public.profile_views WHERE viewed_id = p.id) as views
                FROM public.profiles p
                WHERE id = (p_payload->>'profile_id')::UUID
             ) t;

        -- 📞 [LOG] Record call interaction
        WHEN 'log_call' THEN
            INSERT INTO public.call_logs (telecaller_id, profile_id, action, outcome, notes)
            VALUES (
                v_staff_id, 
                (p_payload->>'profile_id')::UUID, 
                COALESCE((p_payload->>'action')::TEXT, 'call'), 
                (p_payload->>'outcome')::TEXT,
                (p_payload->>'notes')::TEXT
            );
            
            -- Update profile status if outcome provided
            IF p_payload->>'outcome' IS NOT NULL THEN
                UPDATE public.profiles 
                SET 
                    call_status = (p_payload->>'outcome')::TEXT, 
                    last_called_at = NOW(),
                    updated_at = NOW()
                WHERE id = (p_payload->>'profile_id')::UUID;
            END IF;
            
            v_result := jsonb_build_object('status', 'success');

        -- 🚀 [SAVE] Update lead profile (Direct Staff Save)
        WHEN 'update_lead_profile' THEN
            -- 🛡️ SECURITY: Verify the lead is assigned to the caller OR caller is admin
            IF NOT (public.fn_is_admin(v_staff_id)) THEN
                IF NOT EXISTS (
                    SELECT 1 FROM public.profiles 
                    WHERE user_id = (p_payload->>'target_user_id')::UUID 
                    AND assigned_to = v_staff_id
                ) THEN
                    RAISE EXCEPTION 'Unauthorized: lead not assigned to you';
                END IF;
            END IF;

            -- PERFORM UPDATE
            UPDATE public.profiles
            SET
                full_name = COALESCE(p_payload->>'full_name', full_name),
                surname = COALESCE(p_payload->>'surname', surname),
                age = COALESCE((p_payload->>'age')::INT, age),
                gender = COALESCE(p_payload->>'gender', gender),
                phone_number = COALESCE(p_payload->>'phone_number', phone_number),
                date_of_birth = COALESCE((p_payload->>'date_of_birth')::DATE, date_of_birth),
                height = COALESCE(p_payload->>'height', height),
                complexion = COALESCE(p_payload->>'complexion', complexion),
                blood_group = COALESCE(p_payload->>'blood_group', blood_group),
                marital_status = COALESCE(p_payload->>'marital_status', marital_status),
                birth_place = COALESCE(p_payload->>'birth_place', birth_place),
                birth_time = COALESCE(p_payload->>'birth_time', birth_time),
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
                permanent_location = COALESCE(p_payload->>'permanent_location', permanent_location),
                native_place = COALESCE(p_payload->>'native_place', native_place),
                father_name = COALESCE(p_payload->>'father_name', father_name),
                father_occupation = COALESCE(p_payload->>'father_occupation', father_occupation),
                mother_name = COALESCE(p_payload->>'mother_name', mother_name),
                mother_occupation = COALESCE(p_payload->>'mother_occupation', mother_occupation),
                siblings_count = COALESCE((p_payload->>'siblings_count')::INT, siblings_count),
                sister_count = COALESCE((p_payload->>'sister_count')::INT, sister_count),
                brother_count = COALESCE((p_payload->>'brother_count')::INT, brother_count),
                family_type = COALESCE(p_payload->>'family_type', family_type),
                family_status = COALESCE(p_payload->>'family_status', family_status),
                marriage_readiness = COALESCE(p_payload->>'marriage_readiness', marriage_readiness),
                about_self = COALESCE(p_payload->>'about_self', about_self),
                partner_expectations = COALESCE(p_payload->>'partner_expectations', partner_expectations),
                expectation = COALESCE(p_payload->>'expectation', expectation),
                is_active = COALESCE((p_payload->>'is_active')::BOOLEAN, is_active),
                is_disabled = COALESCE((p_payload->>'is_disabled')::BOOLEAN, is_disabled),
                whatsapp_opt_in = COALESCE((p_payload->>'whatsapp_opt_in')::BOOLEAN, whatsapp_opt_in),
                gotra = COALESCE(p_payload->>'gotra', gotra),
                siblings_data = COALESCE((p_payload->'siblings_data')::JSONB, siblings_data),
                updated_at = NOW()
            WHERE user_id = (p_payload->>'target_user_id')::UUID;

            v_result := jsonb_build_object('status', 'success');

        ELSE
            RAISE EXCEPTION 'Unknown staff action: %', action;
    END CASE;

    RETURN v_result;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;
