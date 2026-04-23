-- Migration 20260408040000_security_remediation.sql
-- Migration to address Supabase Lint Security Gaps

-- 1. Security Definer Views (security_definer_view)
ALTER VIEW public.conversations_view SET (security_invoker = on);
ALTER VIEW public.shared_profiles_view SET (security_invoker = on);

-- 2. Missing Row Level Security (rls_disabled_in_public)
ALTER TABLE IF EXISTS public.coupons ENABLE ROW LEVEL SECURITY;
ALTER TABLE IF EXISTS public.rate_limit_logs ENABLE ROW LEVEL SECURITY;
ALTER TABLE IF EXISTS public.profile_views_y2025 ENABLE ROW LEVEL SECURITY;
ALTER TABLE IF EXISTS public.profile_views_y2026 ENABLE ROW LEVEL SECURITY;
ALTER TABLE IF EXISTS public.notification_queue_m03 ENABLE ROW LEVEL SECURITY;
ALTER TABLE IF EXISTS public.notification_queue_m04 ENABLE ROW LEVEL SECURITY;
ALTER TABLE IF EXISTS public.messages_y2025 ENABLE ROW LEVEL SECURITY;
ALTER TABLE IF EXISTS public.messages_y2026 ENABLE ROW LEVEL SECURITY;
ALTER TABLE IF EXISTS public.usage_tracking_y2025 ENABLE ROW LEVEL SECURITY;
ALTER TABLE IF EXISTS public.usage_tracking_y2026 ENABLE ROW LEVEL SECURITY;

-- 3. Extraneous RLS Enabled without explicit Policies (rls_enabled_no_policy)
-- By default, RLS with no policies denies all traffic. We explicitly define a deny-all policy
-- or allow service-role access to clear the linting warnings and make the intention clear.
CREATE POLICY "Deny all public access to creator_commissions" ON public.creator_commissions FOR ALL USING (false);
CREATE POLICY "Deny all public access to creator_referrals" ON public.creator_referrals FOR ALL USING (false);
CREATE POLICY "Deny all public access to email_logs" ON public.email_logs FOR ALL USING (false);

-- 4. Permissive Insert Policies (rls_policy_always_true)
-- Subscriptions insert policy allows anyone to insert. 
-- We will replace the existing permissive insert policies with safer ones.
DROP POLICY IF EXISTS "System insert subscriptions" ON public.subscriptions;
DROP POLICY IF EXISTS "subscriptions_insert_system" ON public.subscriptions;
CREATE POLICY "System insert subscriptions restricted" ON public.subscriptions 
FOR INSERT TO authenticated WITH CHECK (auth.uid() = user_id OR public.fn_is_admin(auth.uid()));

-- 5. Extensions Location (extension_in_public)
-- Move pg_trgm to extensions schema
CREATE SCHEMA IF NOT EXISTS extensions;
ALTER EXTENSION pg_trgm SET SCHEMA extensions;

-- 6. Mutable Function Search Paths (function_search_path_mutable)
-- We will use a DO block to dynamically set search_path = public for all functions in the public and private schemas 
-- that do not currently have a search_path set. This avoids having to write explicit ALTER statements for 40+ functions.

DO $$
DECLARE
    func_rec record;
    alter_stmt text;
BEGIN
    FOR func_rec IN 
        SELECT 
            n.nspname AS schema_name, 
            p.proname AS function_name, 
            pg_get_function_identity_arguments(p.oid) AS function_args
        FROM pg_proc p
        JOIN pg_namespace n ON p.pronamespace = n.oid
        WHERE n.nspname IN ('public', 'private')
          AND p.prokind = 'f' -- strictly functions
    LOOP
        alter_stmt := format('ALTER FUNCTION %I.%I(%s) SET search_path = %I', 
                             func_rec.schema_name, 
                             func_rec.function_name, 
                             func_rec.function_args,
                             func_rec.schema_name); -- We set search_path to the function's own schema
        
        BEGIN
            EXECUTE alter_stmt;
        EXCEPTION WHEN OTHERS THEN
            -- Ignore errors where we might not have permission (though we are superuser typically)
            RAISE NOTICE 'Failed to alter function %: %', func_rec.function_name, SQLERRM;
        END;
    END LOOP;
END
$$;
