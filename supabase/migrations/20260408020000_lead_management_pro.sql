-- 📜 [BanjaraBio] ADVANCED LEAD MANAGEMENT & INVENTORY SYSTEM
-- Purpose: Add granular lead inventory tracking and manual assignment logic
-- Version: 1.1
-- Date: 2026-04-08

CREATE OR REPLACE FUNCTION public.fn_admin_team(action TEXT, p_payload JSONB)
RETURNS JSONB AS $$
DECLARE
    v_admin_id UUID := auth.uid();
    v_result JSONB;
    v_staff_id UUID;
    v_target_user_id UUID;
    v_role TEXT;
BEGIN
    -- 1. 🛡️ SECURITY CHECK
    IF v_admin_id IS NULL THEN 
        RAISE EXCEPTION 'Not authenticated'; 
    END IF;
    
    IF NOT public.fn_is_admin(v_admin_id) THEN 
        RAISE EXCEPTION 'Unauthorized: admin access required'; 
    END IF;

    -- 2. 🚀 ACTION DISPATCHER
    CASE action
        -- 👥 [TEAM] List all staff across all departments with live metrics
        WHEN 'get_team' THEN
            SELECT COALESCE(jsonb_agg(row_to_json(t)::jsonb), '[]'::jsonb) INTO v_result
            FROM (
                SELECT 
                    p.user_id,
                    p.full_name,
                    p.phone_number,
                    p.department,
                    p.designation,
                    p.role,
                    u.email,
                    (SELECT COUNT(*) FROM public.profiles WHERE assigned_to = p.user_id) as total_leads,
                    (SELECT COUNT(*) FROM public.profiles WHERE assigned_to = p.user_id AND call_status = 'converted') as total_converted,
                    (SELECT COUNT(*) FROM public.call_logs WHERE telecaller_id = p.user_id) as total_calls,
                    (SELECT COUNT(*) FROM public.call_logs WHERE telecaller_id = p.user_id AND created_at::date = CURRENT_DATE) as calls_today
                FROM public.profiles p
                JOIN auth.users u ON u.id = p.user_id
                WHERE p.role = 'staff'
                ORDER BY p.full_name ASC
            ) t;

        -- 📊 [INVENTORY] Get counts of unassigned profiles by stage
        WHEN 'get_lead_inventory' THEN
            SELECT jsonb_build_object(
                'total_unassigned', (SELECT count(*) FROM public.profiles WHERE assigned_to IS NULL AND (role IS NULL OR role = 'user')),
                'incomplete', (SELECT count(*) FROM public.profiles WHERE assigned_to IS NULL AND (role IS NULL OR role = 'user') AND profile_completion < 80),
                'no_contact', (SELECT count(*) FROM public.profiles WHERE assigned_to IS NULL AND (role IS NULL OR role = 'user') AND (phone_number IS NULL OR email IS NULL)),
                'no_photo', (SELECT count(*) FROM public.profiles p WHERE assigned_to IS NULL AND (role IS NULL OR role = 'user') AND NOT EXISTS (SELECT 1 FROM public.photos WHERE profile_id = p.id)),
                'unsubscribed', (SELECT count(*) FROM public.profiles WHERE assigned_to IS NULL AND (role IS NULL OR role = 'user') AND is_premium = false)
            ) INTO v_result;

        -- 📎 [MANUAL ASSIGN] Granular bulk assignment
        WHEN 'manual_assign' THEN
            v_staff_id := (p_payload->>'staff_user_id')::UUID;
            IF v_staff_id IS NULL THEN RAISE EXCEPTION 'staff_user_id is required'; END IF;

            WITH targets AS (
                SELECT user_id 
                FROM public.profiles p
                WHERE assigned_to IS NULL 
                AND (role IS NULL OR role = 'user')
                AND (
                    CASE (p_payload->>'stage')
                        WHEN 'incomplete' THEN profile_completion < 80
                        WHEN 'no_contact' THEN (phone_number IS NULL OR email IS NULL)
                        WHEN 'no_photo' THEN NOT EXISTS (SELECT 1 FROM public.photos WHERE profile_id = p.id)
                        WHEN 'unsubscribed' THEN is_premium = false
                        ELSE true -- 'all' or default
                    END
                )
                AND (
                    p_payload->>'gender' IS NULL 
                    OR p_payload->>'gender' = 'Both' 
                    OR gender = (p_payload->>'gender')
                )
                ORDER BY created_at ASC
                LIMIT COALESCE((p_payload->>'limit')::INT, 10)
            )
            UPDATE public.profiles
            SET assigned_to = v_staff_id, updated_at = NOW()
            WHERE user_id IN (SELECT user_id FROM targets);

            GET DIAGNOSTICS v_target_user_id = ROW_COUNT; -- Borrowing variable for count
            v_result := jsonb_build_object('status', 'success', 'assigned', v_target_user_id);

        -- 🎰 [AUTO-ASSIGN] Handled round-robin
        WHEN 'auto_assign_leads' THEN
            DECLARE
                v_unassigned_ids UUID[];
                v_staff_ids UUID[];
                v_num_staff INT;
                v_assigned_count INT := 0;
            BEGIN
                SELECT ARRAY(SELECT user_id FROM public.profiles WHERE (role IS NULL OR role = 'user') AND assigned_to IS NULL ORDER BY created_at ASC) INTO v_unassigned_ids;
                SELECT ARRAY(SELECT user_id FROM public.profiles WHERE role = 'staff' AND department = 'sales') INTO v_staff_ids;
                v_num_staff := array_length(v_staff_ids, 1);
                
                IF v_num_staff > 0 AND array_length(v_unassigned_ids, 1) > 0 THEN
                    FOR i IN 1..array_length(v_unassigned_ids, 1) LOOP
                        UPDATE public.profiles 
                        SET assigned_to = v_staff_ids[((i-1) % v_num_staff) + 1], updated_at = NOW()
                        WHERE user_id = v_unassigned_ids[i];
                        v_assigned_count := v_assigned_count + 1;
                    END LOOP;
                END IF;
                v_result := jsonb_build_object('status', 'success', 'assigned', v_assigned_count);
            END;

        -- 🛠️ [ROLES] Update staff role/department/designation
        WHEN 'set_role' THEN
            v_target_user_id := (p_payload->>'target_user_id')::UUID;
            UPDATE public.profiles
            SET 
                role = (p_payload->>'role')::TEXT,
                department = COALESCE(p_payload->>'department', department),
                designation = COALESCE(p_payload->>'designation', designation),
                updated_at = NOW()
            WHERE user_id = v_target_user_id;
            v_result := jsonb_build_object('status', 'success');

        -- 📊 [REPORTS] Staff Performance Summary
        WHEN 'get_staff_report' THEN
            v_staff_id := (p_payload->>'staff_user_id')::UUID;
            SELECT jsonb_build_object(
                'user_id', p.user_id,
                'full_name', p.full_name,
                'department', p.department,
                'designation', p.designation,
                'stats', jsonb_build_object(
                    'total_leads', (SELECT count(*) FROM public.profiles WHERE assigned_to = p.user_id),
                    'total_calls', (SELECT count(*) FROM public.call_logs WHERE telecaller_id = p.user_id),
                    'conversions', (SELECT count(*) FROM public.profiles WHERE assigned_to = p.user_id AND call_status = 'converted'),
                    'last_call', (SELECT MAX(created_at) FROM public.call_logs WHERE telecaller_id = p.user_id)
                )
            ) INTO v_result
            FROM public.profiles p
            WHERE p.user_id = v_staff_id;

        -- 🧬 [REASSIGN] Reassign a single lead
        WHEN 'reassign_lead' THEN
            UPDATE public.profiles
            SET assigned_to = (p_payload->>'new_staff_id')::UUID, updated_at = NOW()
            WHERE user_id = (p_payload->>'target_user_id')::UUID;
            v_result := jsonb_build_object('status', 'success');

        -- 🧹 [UNASSIGN] Clear all leads from staff
        WHEN 'unassign_all_leads' THEN
            UPDATE public.profiles
            SET assigned_to = NULL, updated_at = NOW()
            WHERE assigned_to = (p_payload->>'staff_user_id')::UUID;
            v_result := jsonb_build_object('status', 'success');

        -- 🏆 [LEADERBOARD] Sales Staff Ranking
        WHEN 'get_leaderboard' THEN
            SELECT COALESCE(jsonb_agg(row_to_json(t)::jsonb), '[]'::jsonb) INTO v_result
            FROM (
                SELECT 
                    p.user_id,
                    p.full_name,
                    p.department,
                    (SELECT COUNT(*) FROM public.profiles WHERE assigned_to = p.user_id AND call_status = 'converted') as score,
                    RANK() OVER (ORDER BY (SELECT COUNT(*) FROM public.profiles WHERE assigned_to = p.user_id AND call_status = 'converted') DESC) as rank
                FROM public.profiles p
                WHERE p.role = 'staff' AND p.department = 'sales'
                LIMIT 10
            ) t;

        ELSE
            RAISE EXCEPTION 'Unknown team action: %', action;
    END CASE;

    RETURN v_result;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;
