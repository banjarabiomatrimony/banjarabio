-- Migration: 20260815000000_permanent_partition_and_resilient_notification_fix.sql
-- Purpose: 
-- 1. Permanently fix partitioned tables by creating 2026, 2027, 2028 and catch-all DEFAULT partitions for notification_queue, messages, profile_views, and usage_tracking.
-- 2. Make all notification trigger functions fully resilient with exception guards so core profile creation / messaging transactions NEVER fail.
-- 3. Enhance automated maintenance routine to auto-provision future partitions and purge stale queues.

-- ============================================================================
-- 1. NOTIFICATION QUEUE PARTITIONS & DEFAULT SAFETY NET
-- ============================================================================
DO $$
BEGIN
    -- Check if notification_queue is partitioned
    IF EXISTS (
        SELECT 1 FROM pg_partitioned_table pt
        JOIN pg_class c ON c.oid = pt.partrelid
        WHERE c.relname = 'notification_queue'
    ) THEN
        -- Year 2026 partition
        IF NOT EXISTS (SELECT 1 FROM pg_class WHERE relname = 'notification_queue_y2026') THEN
            CREATE TABLE public.notification_queue_y2026 PARTITION OF public.notification_queue
                FOR VALUES FROM ('2026-01-01 00:00:00+00') TO ('2027-01-01 00:00:00+00');
        END IF;

        -- Year 2027 partition
        IF NOT EXISTS (SELECT 1 FROM pg_class WHERE relname = 'notification_queue_y2027') THEN
            CREATE TABLE public.notification_queue_y2027 PARTITION OF public.notification_queue
                FOR VALUES FROM ('2027-01-01 00:00:00+00') TO ('2028-01-01 00:00:00+00');
        END IF;

        -- Year 2028 partition
        IF NOT EXISTS (SELECT 1 FROM pg_class WHERE relname = 'notification_queue_y2028') THEN
            CREATE TABLE public.notification_queue_y2028 PARTITION OF public.notification_queue
                FOR VALUES FROM ('2028-01-01 00:00:00+00') TO ('2029-01-01 00:00:00+00');
        END IF;

        -- Catch-all DEFAULT partition (Guarantees error 23514 can NEVER occur for any timestamp)
        IF NOT EXISTS (SELECT 1 FROM pg_class WHERE relname = 'notification_queue_default') THEN
            CREATE TABLE public.notification_queue_default PARTITION OF public.notification_queue DEFAULT;
        END IF;
    END IF;
EXCEPTION WHEN OTHERS THEN
    RAISE NOTICE 'Partition setup for notification_queue notice: %', SQLERRM;
END $$;

-- Enable RLS on newly created partitions if needed
DO $$
BEGIN
    IF EXISTS (SELECT 1 FROM pg_class WHERE relname = 'notification_queue_y2026') THEN
        ALTER TABLE public.notification_queue_y2026 ENABLE ROW LEVEL SECURITY;
    END IF;
    IF EXISTS (SELECT 1 FROM pg_class WHERE relname = 'notification_queue_y2027') THEN
        ALTER TABLE public.notification_queue_y2027 ENABLE ROW LEVEL SECURITY;
    END IF;
    IF EXISTS (SELECT 1 FROM pg_class WHERE relname = 'notification_queue_y2028') THEN
        ALTER TABLE public.notification_queue_y2028 ENABLE ROW LEVEL SECURITY;
    END IF;
    IF EXISTS (SELECT 1 FROM pg_class WHERE relname = 'notification_queue_default') THEN
        ALTER TABLE public.notification_queue_default ENABLE ROW LEVEL SECURITY;
    END IF;
EXCEPTION WHEN OTHERS THEN NULL;
END $$;

-- ============================================================================
-- 2. PERMANENT CATCH-ALL DEFAULT PARTITIONS FOR ALL OTHER PARTITIONED TABLES
-- ============================================================================
DO $$
BEGIN
    -- Messages DEFAULT partition
    IF EXISTS (
        SELECT 1 FROM pg_partitioned_table pt
        JOIN pg_class c ON c.oid = pt.partrelid
        WHERE c.relname = 'messages'
    ) AND NOT EXISTS (SELECT 1 FROM pg_class WHERE relname = 'messages_default') THEN
        CREATE TABLE public.messages_default PARTITION OF public.messages DEFAULT;
        ALTER TABLE public.messages_default ENABLE ROW LEVEL SECURITY;
    END IF;

    -- Profile Views DEFAULT partition
    IF EXISTS (
        SELECT 1 FROM pg_partitioned_table pt
        JOIN pg_class c ON c.oid = pt.partrelid
        WHERE c.relname = 'profile_views'
    ) AND NOT EXISTS (SELECT 1 FROM pg_class WHERE relname = 'profile_views_default') THEN
        CREATE TABLE public.profile_views_default PARTITION OF public.profile_views DEFAULT;
        ALTER TABLE public.profile_views_default ENABLE ROW LEVEL SECURITY;
    END IF;

    -- Usage Tracking DEFAULT partition
    IF EXISTS (
        SELECT 1 FROM pg_partitioned_table pt
        JOIN pg_class c ON c.oid = pt.partrelid
        WHERE c.relname = 'usage_tracking'
    ) AND NOT EXISTS (SELECT 1 FROM pg_class WHERE relname = 'usage_tracking_default') THEN
        CREATE TABLE public.usage_tracking_default PARTITION OF public.usage_tracking DEFAULT;
        ALTER TABLE public.usage_tracking_default ENABLE ROW LEVEL SECURITY;
    END IF;
EXCEPTION WHEN OTHERS THEN
    RAISE NOTICE 'Partition setup for other tables notice: %', SQLERRM;
END $$;

-- ============================================================================
-- 3. FAULT-TOLERANT, RESILIENT INTENT MATCH NOTIFICATION TRIGGER
-- ============================================================================
CREATE OR REPLACE FUNCTION public.fn_match_browse_intents_for_new_profile(p_profile_id UUID) 
RETURNS INT 
LANGUAGE plpgsql 
SECURITY DEFINER 
SET search_path = public, pg_temp
AS $$
DECLARE 
    v_profile RECORD;
    v_matched_count INT := 0;
BEGIN 
    -- Fetch the target profile
    SELECT id,
        full_name,
        surname,
        age,
        gender,
        district,
        state,
        is_active INTO v_profile
    FROM public.profiles
    WHERE id = p_profile_id;

    IF v_profile IS NULL OR v_profile.is_active = false THEN 
        RETURN 0;
    END IF;

    -- Resilient notification queuing: Protected by sub-transaction
    BEGIN
        INSERT INTO public.notification_queue (
            recipient_user_id,
            title,
            body,
            data,
            created_at
        )
        SELECT DISTINCT ubi.user_id,
            'तुमच्या नातेवाईकासाठी नवीन स्थळ! 🚩',
            COALESCE(v_profile.full_name, 'उमेदवार') || ' (' || v_profile.age || ' वर्षे' || CASE
                WHEN v_profile.district IS NOT NULL
                AND v_profile.district <> '' THEN ', ' || v_profile.district
                ELSE ''
            END || ') बंजाराबायो ॲपवर उपलब्ध आहे. आताच पहा.',
            jsonb_build_object(
                'type',
                'intent_match',
                'profile_id',
                v_profile.id::TEXT,
                'relation',
                ubi.relation
            ),
            NOW()
        FROM public.user_browse_intents ubi
        WHERE ubi.target_gender = v_profile.gender
            AND ubi.created_at >= (NOW() - INTERVAL '60 days')
            AND (
                ubi.district IS NULL
                OR ubi.district = ''
                OR LOWER(ubi.district) = LOWER(v_profile.district)
            );

        GET DIAGNOSTICS v_matched_count = ROW_COUNT;
    EXCEPTION WHEN OTHERS THEN
        -- Graceful degradation: never crash profile creation on notification queue errors
        RAISE WARNING 'fn_match_browse_intents_for_new_profile warning (non-fatal): %', SQLERRM;
        RETURN 0;
    END;

    RETURN v_matched_count;
END;
$$;

-- Revoke public execution for security
REVOKE ALL ON FUNCTION public.fn_match_browse_intents_for_new_profile(uuid) FROM PUBLIC;
REVOKE ALL ON FUNCTION public.fn_match_browse_intents_for_new_profile(uuid) FROM anon;
GRANT EXECUTE ON FUNCTION public.fn_match_browse_intents_for_new_profile(uuid) TO service_role, authenticated, postgres;

-- ============================================================================
-- 4. FAULT-TOLERANT CHAT MESSAGE NOTIFICATION TRIGGER
-- ============================================================================
CREATE OR REPLACE FUNCTION public.fn_queue_message_notification()
RETURNS TRIGGER 
LANGUAGE plpgsql 
SECURITY DEFINER 
SET search_path = public, pg_temp
AS $$
DECLARE
    v_recipient_user_id UUID;
    v_sender_name TEXT;
BEGIN
    BEGIN
        IF NEW.sender_id IN (SELECT id FROM public.profiles WHERE user_id = NEW.p1_user_id) THEN
            v_recipient_user_id := NEW.p2_user_id;
        ELSE
            v_recipient_user_id := NEW.p1_user_id;
        END IF;

        SELECT full_name INTO v_sender_name FROM public.profiles WHERE id = NEW.sender_id;

        INSERT INTO public.notification_queue (recipient_user_id, title, body, data, created_at)
        VALUES (
            v_recipient_user_id,
            'New Message',
            COALESCE(v_sender_name, 'User') || ': ' || LEFT(COALESCE(NEW.message_text, ''), 50),
            jsonb_build_object('type', 'chat', 'conversation_id', NEW.conversation_id),
            NOW()
        );
    EXCEPTION WHEN OTHERS THEN
        RAISE WARNING 'fn_queue_message_notification warning (non-fatal): %', SQLERRM;
    END;

    RETURN NEW;
END;
$$;

-- ============================================================================
-- 5. UPGRADED AUTOMATED PARTITION MAINTENANCE & PRUNING PROCEDURE
-- ============================================================================
CREATE OR REPLACE FUNCTION public.fn_maintain_partitions_and_evict_stale_data()
RETURNS jsonb
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public, pg_temp
AS $$
DECLARE
  v_usage_deleted INT := 0;
  v_whatsapp_logs_deleted INT := 0;
  v_notif_queue_deleted INT := 0;
  v_next_year INT := EXTRACT(YEAR FROM CURRENT_DATE)::INT + 1;
  v_sql TEXT;
BEGIN
  -- 5.1 Evict usage_tracking records older than 90 days
  IF EXISTS (SELECT 1 FROM information_schema.tables WHERE table_schema = 'public' AND table_name = 'usage_tracking') THEN
    DELETE FROM public.usage_tracking
    WHERE date < (CURRENT_DATE - INTERVAL '90 days');
    GET DIAGNOSTICS v_usage_deleted = ROW_COUNT;
  END IF;

  -- 5.2 Evict processed WhatsApp notification logs older than 60 days
  IF EXISTS (SELECT 1 FROM information_schema.tables WHERE table_schema = 'public' AND table_name = 'whatsapp_notification_logs') THEN
    DELETE FROM public.whatsapp_notification_logs
    WHERE created_at < (NOW() - INTERVAL '60 days');
    GET DIAGNOSTICS v_whatsapp_logs_deleted = ROW_COUNT;
  END IF;

  -- 5.3 Evict processed/sent notification_queue items older than 30 days
  IF EXISTS (SELECT 1 FROM information_schema.tables WHERE table_schema = 'public' AND table_name = 'notification_queue') THEN
    DELETE FROM public.notification_queue
    WHERE created_at < (NOW() - INTERVAL '30 days')
      AND (status IN ('sent', 'failed') OR processed_at IS NOT NULL);
    GET DIAGNOSTICS v_notif_queue_deleted = ROW_COUNT;
  END IF;

  -- 5.4 Dynamically ensure future partitions exist
  BEGIN
    v_sql := format('CREATE TABLE IF NOT EXISTS public.usage_tracking_y%s PARTITION OF public.usage_tracking FOR VALUES FROM (''%s-01-01'') TO (''%s-01-01'')',
                    v_next_year, v_next_year, v_next_year + 1);
    EXECUTE v_sql;

    v_sql := format('CREATE TABLE IF NOT EXISTS public.profile_views_y%s PARTITION OF public.profile_views FOR VALUES FROM (''%s-01-01 00:00:00+00'') TO (''%s-01-01 00:00:00+00'')',
                    v_next_year, v_next_year, v_next_year + 1);
    EXECUTE v_sql;

    v_sql := format('CREATE TABLE IF NOT EXISTS public.messages_y%s PARTITION OF public.messages FOR VALUES FROM (''%s-01-01 00:00:00+00'') TO (''%s-01-01 00:00:00+00'')',
                    v_next_year, v_next_year, v_next_year + 1);
    EXECUTE v_sql;

    v_sql := format('CREATE TABLE IF NOT EXISTS public.notification_queue_y%s PARTITION OF public.notification_queue FOR VALUES FROM (''%s-01-01 00:00:00+00'') TO (''%s-01-01 00:00:00+00'')',
                    v_next_year, v_next_year, v_next_year + 1);
    EXECUTE v_sql;
  EXCEPTION WHEN OTHERS THEN
    RAISE WARNING 'Auto-partition provision warning: %', SQLERRM;
  END;

  RETURN jsonb_build_object(
    'ok', true,
    'usage_records_evicted', v_usage_deleted,
    'whatsapp_logs_evicted', v_whatsapp_logs_deleted,
    'notification_queue_evicted', v_notif_queue_deleted,
    'next_year_partitioned', v_next_year,
    'executed_at', NOW()
  );
END;
$$;

-- Revoke anon access and grant to service_role / postgres
REVOKE ALL ON FUNCTION public.fn_maintain_partitions_and_evict_stale_data() FROM PUBLIC;
REVOKE ALL ON FUNCTION public.fn_maintain_partitions_and_evict_stale_data() FROM anon;
GRANT EXECUTE ON FUNCTION public.fn_maintain_partitions_and_evict_stale_data() TO service_role, postgres;
