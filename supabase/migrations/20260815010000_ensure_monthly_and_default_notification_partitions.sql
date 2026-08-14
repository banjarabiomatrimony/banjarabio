-- Migration: 20260815010000_ensure_monthly_and_default_notification_partitions.sql
-- Purpose: Create non-overlapping monthly partitions for 2026, annual partitions for 2027-2028, and a catch-all DEFAULT partition for notification_queue.

-- 1. Non-overlapping monthly partitions for remaining 2026 months
DO $$ BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_class WHERE relname = 'notification_queue_2026_08') THEN
        CREATE TABLE public.notification_queue_2026_08 PARTITION OF public.notification_queue
            FOR VALUES FROM ('2026-08-01 00:00:00+00') TO ('2026-09-01 00:00:00+00');
    END IF;
EXCEPTION WHEN OTHERS THEN RAISE NOTICE '2026_08 notice: %', SQLERRM;
END $$;

DO $$ BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_class WHERE relname = 'notification_queue_2026_09') THEN
        CREATE TABLE public.notification_queue_2026_09 PARTITION OF public.notification_queue
            FOR VALUES FROM ('2026-09-01 00:00:00+00') TO ('2026-10-01 00:00:00+00');
    END IF;
EXCEPTION WHEN OTHERS THEN RAISE NOTICE '2026_09 notice: %', SQLERRM;
END $$;

DO $$ BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_class WHERE relname = 'notification_queue_2026_10') THEN
        CREATE TABLE public.notification_queue_2026_10 PARTITION OF public.notification_queue
            FOR VALUES FROM ('2026-10-01 00:00:00+00') TO ('2026-11-01 00:00:00+00');
    END IF;
EXCEPTION WHEN OTHERS THEN RAISE NOTICE '2026_10 notice: %', SQLERRM;
END $$;

DO $$ BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_class WHERE relname = 'notification_queue_2026_11') THEN
        CREATE TABLE public.notification_queue_2026_11 PARTITION OF public.notification_queue
            FOR VALUES FROM ('2026-11-01 00:00:00+00') TO ('2026-12-01 00:00:00+00');
    END IF;
EXCEPTION WHEN OTHERS THEN RAISE NOTICE '2026_11 notice: %', SQLERRM;
END $$;

DO $$ BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_class WHERE relname = 'notification_queue_2026_12') THEN
        CREATE TABLE public.notification_queue_2026_12 PARTITION OF public.notification_queue
            FOR VALUES FROM ('2026-12-01 00:00:00+00') TO ('2027-01-01 00:00:00+00');
    END IF;
EXCEPTION WHEN OTHERS THEN RAISE NOTICE '2026_12 notice: %', SQLERRM;
END $$;

-- 2. Annual Partitions for 2027 and 2028
DO $$ BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_class WHERE relname = 'notification_queue_y2027') THEN
        CREATE TABLE public.notification_queue_y2027 PARTITION OF public.notification_queue
            FOR VALUES FROM ('2027-01-01 00:00:00+00') TO ('2028-01-01 00:00:00+00');
    END IF;
EXCEPTION WHEN OTHERS THEN RAISE NOTICE 'y2027 notice: %', SQLERRM;
END $$;

DO $$ BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_class WHERE relname = 'notification_queue_y2028') THEN
        CREATE TABLE public.notification_queue_y2028 PARTITION OF public.notification_queue
            FOR VALUES FROM ('2028-01-01 00:00:00+00') TO ('2029-01-01 00:00:00+00');
    END IF;
EXCEPTION WHEN OTHERS THEN RAISE NOTICE 'y2028 notice: %', SQLERRM;
END $$;

-- 3. Catch-all DEFAULT partition (Guarantees error 23514 can NEVER occur)
DO $$ BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_class WHERE relname = 'notification_queue_default') THEN
        CREATE TABLE public.notification_queue_default PARTITION OF public.notification_queue DEFAULT;
    END IF;
EXCEPTION WHEN OTHERS THEN RAISE NOTICE 'default partition notice: %', SQLERRM;
END $$;

-- 4. Enable Row Level Security on all partitions
DO $$ BEGIN
    ALTER TABLE IF EXISTS public.notification_queue_2026_08 ENABLE ROW LEVEL SECURITY;
    ALTER TABLE IF EXISTS public.notification_queue_2026_09 ENABLE ROW LEVEL SECURITY;
    ALTER TABLE IF EXISTS public.notification_queue_2026_10 ENABLE ROW LEVEL SECURITY;
    ALTER TABLE IF EXISTS public.notification_queue_2026_11 ENABLE ROW LEVEL SECURITY;
    ALTER TABLE IF EXISTS public.notification_queue_2026_12 ENABLE ROW LEVEL SECURITY;
    ALTER TABLE IF EXISTS public.notification_queue_y2027 ENABLE ROW LEVEL SECURITY;
    ALTER TABLE IF EXISTS public.notification_queue_y2028 ENABLE ROW LEVEL SECURITY;
    ALTER TABLE IF EXISTS public.notification_queue_default ENABLE ROW LEVEL SECURITY;
EXCEPTION WHEN OTHERS THEN NULL;
END $$;
