-- 📜 [BanjaraBio] STAFF PORTAL CORE INFRASTRUCTURE
-- Purpose: Restore missing RPCs and tables for telecaller operations
-- Version: 1.0
-- Date: 2026-04-08

-- =====================================================
-- 1. 🏗️ TABLES & TABLES
-- =====================================================

-- 💬 WhatsApp Engagement Templates
CREATE TABLE IF NOT EXISTS public.whatsapp_templates (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name TEXT NOT NULL,
    category TEXT NOT NULL CHECK (category IN ('welcome', 'follow_up', 'verification', 'premium_pitch', 're_engage', 'general')),
    message_template TEXT NOT NULL,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- 📞 Interaction History (Call Logs)
CREATE TABLE IF NOT EXISTS public.call_logs (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    telecaller_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
    profile_id UUID NOT NULL, -- Link to profiles.id
    action_type TEXT NOT NULL CHECK (action_type IN ('call', 'whatsapp')),
    outcome TEXT, -- 'connected', 'busy', 'not_answered', 'follow_up', 'converted', 'not_interested'
    notes TEXT,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- 🛡️ Enable RLS
ALTER TABLE public.whatsapp_templates ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.call_logs ENABLE ROW LEVEL SECURITY;

-- 📜 RLS Policies: Staff/Admin can read templates, Staff can manage their own logs
DROP POLICY IF EXISTS "Staff can view templates" ON public.whatsapp_templates;
CREATE POLICY "Staff can view templates" ON public.whatsapp_templates
    FOR SELECT TO authenticated USING (true);

DROP POLICY IF EXISTS "Staff can view their own logs" ON public.call_logs;
CREATE POLICY "Staff can view their own logs" ON public.call_logs
    FOR SELECT TO authenticated USING (telecaller_id = auth.uid());

DROP POLICY IF EXISTS "Staff can insert their own logs" ON public.call_logs;
CREATE POLICY "Staff can insert their own logs" ON public.call_logs
    FOR INSERT TO authenticated WITH CHECK (telecaller_id = auth.uid());

-- =====================================================
-- 2. 🛡️ RBAC HELPERS
-- =====================================================

CREATE OR REPLACE FUNCTION public.fn_is_admin(p_user_id UUID) 
RETURNS BOOLEAN AS $$
  SELECT EXISTS (SELECT 1 FROM public.profiles WHERE user_id = p_user_id AND role = 'admin');
$$ LANGUAGE sql SECURITY DEFINER;

CREATE OR REPLACE FUNCTION public.fn_is_staff(p_user_id UUID) 
RETURNS BOOLEAN AS $$
  SELECT EXISTS (SELECT 1 FROM public.profiles WHERE user_id = p_user_id AND role = 'staff');
$$ LANGUAGE sql SECURITY DEFINER;

-- =====================================================
-- 3. 🚀 MASTER STAFF RPC (fn_staff_actions)
-- =====================================================

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

    -- Optional: Check if user has 'staff' or 'admin' role
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
                'follow_up', (SELECT count(*) FROM public.profiles WHERE assigned_to = v_staff_id AND (call_status = 'follow_up' OR call_status = 'busy' OR call_status = 'not_answered')),
                'converted', (SELECT count(*) FROM public.profiles WHERE assigned_to = v_staff_id AND call_status = 'converted'),
                'calls_today', (SELECT count(*) FROM public.call_logs WHERE telecaller_id = v_staff_id AND created_at::date = CURRENT_DATE),
                'updated_today', (SELECT count(*) FROM public.profiles WHERE assigned_to = v_staff_id AND updated_at::date = CURRENT_DATE)
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
            INSERT INTO public.call_logs (telecaller_id, profile_id, action_type, outcome, notes)
            VALUES (
                v_staff_id, 
                (p_payload->>'profile_id')::UUID, 
                (p_payload->>'action_type')::TEXT, 
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

        ELSE
            RAISE EXCEPTION 'Unknown staff action: %', action;
    END CASE;

    RETURN v_result;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Grant Execution
GRANT EXECUTE ON FUNCTION public.fn_staff_actions(TEXT, JSONB) TO authenticated;

-- =====================================================
-- 4. 🧬 SEED DATA (Templates)
-- =====================================================

INSERT INTO public.whatsapp_templates (name, category, message_template) VALUES
('Welcome & Verify', 'welcome', 'Namaste {name}! I am calling from BanjaraBio Matrimony. I see your profile is {completion}% complete. Can we help you finish it for better matches? 🙏'),
('New Matches available', 'follow_up', 'Hi {name}, we found 3 new profiles matching your preferences! Your profile has {views} recent views. Open the app to check them out: https://banjarabio.app'),
('Premium Benefits', 'premium_pitch', 'Hello {name}, did you know premium members get 10x more responses? I can help you with a special discount today!'),
('Daily Follow-up', 're_engage', 'Namaste {name}, just checking in to see if you had any trouble using the app. We are here to help you find your perfect match!');
