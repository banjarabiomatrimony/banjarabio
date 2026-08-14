-- Migration: Partition Archival & Automated Eviction Policy
-- Ensures tables are properly partitioned into 2027 and establishes automated pruning routines.

-- 1. Ensure 2027 partitions exist for high-volume partitioned tables
CREATE TABLE IF NOT EXISTS public.usage_tracking_y2027 PARTITION OF public.usage_tracking
    FOR VALUES FROM ('2027-01-01') TO ('2028-01-01');

CREATE TABLE IF NOT EXISTS public.profile_views_y2027 PARTITION OF public.profile_views
    FOR VALUES FROM ('2027-01-01 00:00:00+00') TO ('2028-01-01 00:00:00+00');

CREATE TABLE IF NOT EXISTS public.messages_y2027 PARTITION OF public.messages
    FOR VALUES FROM ('2027-01-01 00:00:00+00') TO ('2028-01-01 00:00:00+00');

-- 2. Maintenance & Eviction Stored Procedure
CREATE OR REPLACE FUNCTION public.fn_maintain_partitions_and_evict_stale_data()
RETURNS jsonb
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public, pg_temp
AS $$
DECLARE
  v_usage_deleted INT := 0;
  v_whatsapp_logs_deleted INT := 0;
  v_next_year INT := EXTRACT(YEAR FROM CURRENT_DATE)::INT + 1;
  v_sql TEXT;
BEGIN
  -- 2.1 Evict usage_tracking records older than 90 days
  DELETE FROM public.usage_tracking
  WHERE date < (CURRENT_DATE - INTERVAL '90 days');
  GET DIAGNOSTICS v_usage_deleted = ROW_COUNT;

  -- 2.2 Evict processed WhatsApp notification logs older than 60 days
  IF EXISTS (SELECT 1 FROM information_schema.tables WHERE table_schema = 'public' AND table_name = 'whatsapp_notification_logs') THEN
    DELETE FROM public.whatsapp_notification_logs
    WHERE created_at < (NOW() - INTERVAL '60 days');
    GET DIAGNOSTICS v_whatsapp_logs_deleted = ROW_COUNT;
  END IF;

  -- 2.3 Dynamically ensure partitions exist for next year
  v_sql := format('CREATE TABLE IF NOT EXISTS public.usage_tracking_y%s PARTITION OF public.usage_tracking FOR VALUES FROM (''%s-01-01'') TO (''%s-01-01'')',
                  v_next_year, v_next_year, v_next_year + 1);
  EXECUTE v_sql;

  v_sql := format('CREATE TABLE IF NOT EXISTS public.profile_views_y%s PARTITION OF public.profile_views FOR VALUES FROM (''%s-01-01 00:00:00+00'') TO (''%s-01-01 00:00:00+00'')',
                  v_next_year, v_next_year, v_next_year + 1);
  EXECUTE v_sql;

  v_sql := format('CREATE TABLE IF NOT EXISTS public.messages_y%s PARTITION OF public.messages FOR VALUES FROM (''%s-01-01 00:00:00+00'') TO (''%s-01-01 00:00:00+00'')',
                  v_next_year, v_next_year, v_next_year + 1);
  EXECUTE v_sql;

  RETURN jsonb_build_object(
    'ok', true,
    'usage_records_evicted', v_usage_deleted,
    'whatsapp_logs_evicted', v_whatsapp_logs_deleted,
    'next_year_partitioned', v_next_year,
    'executed_at', NOW()
  );
END;
$$;

-- Revoke anon access to maintenance procedure
REVOKE ALL ON FUNCTION public.fn_maintain_partitions_and_evict_stale_data() FROM PUBLIC;
REVOKE ALL ON FUNCTION public.fn_maintain_partitions_and_evict_stale_data() FROM anon;
GRANT EXECUTE ON FUNCTION public.fn_maintain_partitions_and_evict_stale_data() TO service_role, postgres;

-- 3. Register weekly maintenance cron job (Every Sunday at 03:00 UTC)
DO $$
BEGIN
  IF EXISTS (SELECT 1 FROM pg_extension WHERE extname = 'pg_cron') THEN
    PERFORM cron.unschedule(jobid) 
    FROM cron.job 
    WHERE command LIKE '%fn_maintain_partitions_and_evict_stale_data%';

    PERFORM cron.schedule(
      'weekly_partition_maintenance_and_eviction',
      '0 3 * * 0',
      'SELECT public.fn_maintain_partitions_and_evict_stale_data();'
    );
  END IF;
END $$;
