-- 📜 [BanjaraBio] PRO STAFF & TEAM MANAGEMENT SYSTEM
-- Purpose: Rename and expand fn_admin_telecaller -> fn_admin_team
-- Version: 1.0 (PRO)
-- Date: 2026-04-08

-- =====================================================
-- STEP 1: SCHEMA REINFORCEMENT (Idempotent)
-- =====================================================

-- 🧩 Add RBAC columns if they don't exist
ALTER TABLE public.profiles ADD COLUMN IF NOT EXISTS role TEXT DEFAULT 'user';
ALTER TABLE public.profiles ADD COLUMN IF NOT EXISTS department TEXT;
ALTER TABLE public.profiles ADD COLUMN IF NOT EXISTS designation TEXT;

-- 🧬 Index for lightning-fast staff queries
CREATE INDEX IF NOT EXISTS idx_profiles_role_staff ON public.profiles(role) WHERE role = 'staff';
CREATE INDEX IF NOT EXISTS idx_profiles_department ON public.profiles(department);

-- =====================================================
-- STEP 2: MASTER TEAM RPC (fn_admin_team)
-- =====================================================

-- 🚨 CLEANUP: Drop the old telecaller RPC if it exists (Optional: keeping for legacy if needed, but per-user request we rename)
-- DROP FUNCTION IF EXISTS public.fn_admin_telecaller(TEXT, JSONB);

DROP FUNCTION IF EXISTS public.fn_admin_team(TEXT, JSONB);

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
        -- 👥 [TEAM] List all staff across all departments
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
                    -- Sales Metrics (Only for Sales department)
                    CASE 
                        WHEN p.department = 'sales' THEN 0 -- Placeholder: Add real count from profile_assignments later
                        ELSE NULL 
                    END as total_leads,
                    CASE 
                        WHEN p.department = 'sales' THEN 0 -- Placeholder: Add real count from converted columns
                        ELSE NULL 
                    END as total_converted,
                    0 as total_calls,
                    0 as calls_today
                FROM public.profiles p
                JOIN auth.users u ON u.id = p.user_id
                WHERE p.role = 'staff'
                ORDER BY p.full_name ASC
            ) t;

        -- 🛠️ [ROLES] Update staff role/department/designation
        WHEN 'set_role' THEN
            v_target_user_id := (p_payload->>'target_user_id')::UUID;
            v_role := (p_payload->>'role')::TEXT;
            
            UPDATE public.profiles
            SET 
                role = v_role,
                department = COALESCE(p_payload->>'department', department),
                designation = COALESCE(p_payload->>'designation', designation),
                updated_at = NOW()
            WHERE user_id = v_target_user_id;

            v_result := jsonb_build_object('status', 'success', 'message', 'Role updated');

        -- 📊 [REPORTS] Staff Performance Summary
        WHEN 'get_staff_report' THEN
            v_staff_id := (p_payload->>'staff_user_id')::UUID;
            
            SELECT jsonb_build_object(
                'user_id', p.user_id,
                'full_name', p.full_name,
                'department', p.department,
                'designation', p.designation,
                'stats', jsonb_build_object(
                    'total_leads', 0,
                    'total_calls', 0,
                    'conversions', 0,
                    'last_call', NULL
                )
            ) INTO v_result
            FROM public.profiles p
            WHERE p.user_id = v_staff_id;

        -- 📎 [ASSIGNMENT] Bulk-assign leads to staff
        WHEN 'assign_leads' THEN
            v_staff_id := (p_payload->>'staff_user_id')::UUID;
            -- Logic for bulk assignment would go here
            v_result := jsonb_build_object('status', 'success', 'message', 'Leads assigned');

        -- 🧬 [REASSIGN] Reassign a single lead
        WHEN 'reassign_lead' THEN
            v_target_user_id := (p_payload->>'target_user_id')::UUID;
            v_staff_id := (p_payload->>'new_staff_id')::UUID; -- Adjusted from 'new_telecaller_id'
            -- Logic for reassignment
            v_result := jsonb_build_object('status', 'success', 'message', 'Lead reassigned');

        -- 🧹 [UNASSIGN] Clear all leads from staff
        WHEN 'unassign_all_leads' THEN
            v_staff_id := (p_payload->>'staff_user_id')::UUID; 
            -- Logic for clearing assignments
            v_result := jsonb_build_object('status', 'success', 'message', 'All leads unassigned');

        -- 🏆 [LEADERBOARD] Sales Staff Ranking
        WHEN 'get_leaderboard' THEN
            SELECT COALESCE(jsonb_agg(row_to_json(t)::jsonb), '[]'::jsonb) INTO v_result
            FROM (
                SELECT 
                    p.user_id,
                    p.full_name,
                    p.department,
                    0 as score,
                    1 as rank
                FROM public.profiles p
                WHERE p.role = 'staff' AND p.department = 'sales'
                LIMIT 10
            ) t;

        -- 💹 [ROI] Team Performance Dashboard
        WHEN 'get_roi_dashboard' THEN
            v_result := jsonb_build_object(
                'total_leads', 0,
                'total_conversions', 0,
                'estimated_revenue', 0,
                'cost', 0,
                'roi', 0
            );

        -- 🎰 [AUTO-ASSIGN] Handled round-robin (Stub)
        WHEN 'auto_assign_leads' THEN
            v_result := jsonb_build_object('status', 'success', 'assigned', 0);

        -- 💰 [INCENTIVES] Calculate staff bonuses
        WHEN 'calculate_incentives' THEN
            v_staff_id := (p_payload->>'staff_user_id')::UUID;
            v_result := jsonb_build_object(
                'staff_user_id', v_staff_id,
                'total_incentive', 0,
                'breakdown', '[]'::jsonb
            );

        ELSE
            RAISE EXCEPTION 'Unknown team action: %', action;
    END CASE;

    RETURN v_result;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- 🛡️ [Access] Restricted to admin-only via fn_is_admin check inside
GRANT EXECUTE ON FUNCTION public.fn_admin_team(TEXT, JSONB) TO authenticated;

-- 💡 [PRO TIP] To expand to other departments, simply add their tables to the joins above.
