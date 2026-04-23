-- 🛡️ Phase 10: Infrastructure Rate Limiting
-- Protect the primary database from massive request bursts (10M DAU peaks)
-- 1. CONFIGURE ROLE-BASED RATE LIMITS (PostgREST level)
-- We set a smaller statement timeout for high-traffic anonymous/authenticated roles
-- to prevent long-running read queries from exhausting the connection pool.
ALTER ROLE authenticated
SET statement_timeout = '5s';
ALTER ROLE anon
SET statement_timeout = '3s';
-- 2. LIMIT CONCURRENT TRANSACTIONS PER USER
-- (Note: This depends on the specific Postgres extensions or PgBouncer/Supavisor config)
-- Recommendation: Configure Supavisor at the Dashboard level to 'Transaction Mode'.
-- 3. SCALE-SAFE BURST PROTECTION
-- Create a high-performance logging table for rate-limit violations (for monitoring)
CREATE UNLOGGED TABLE IF NOT EXISTS public.rate_limit_logs (
    id BIGINT GENERATED ALWAYS AS IDENTITY,
    user_id UUID,
    endpoint TEXT,
    violated_at TIMESTAMPTZ DEFAULT NOW()
);
-- Optimize for write-speed (UNLOGGED means no WAL overhead, safe for transient logs)
CREATE INDEX IF NOT EXISTS idx_rate_limit_logs_time ON public.rate_limit_logs(violated_at DESC);