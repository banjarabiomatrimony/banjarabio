-- =============================================================
-- Migration: 20260813181500_fix_vouch_count_null_and_config.sql
-- Purpose: 
--  1. Fix NULL trap in fn_on_vouch_change by using COALESCE(vouch_count, 0)
--  2. Add fallback to private.notification_settings for email_system cron jobs
-- Created: 2026-08-13
-- =============================================================

-- 1. Fix fn_on_vouch_change (safely handles NULL vouch_count)
CREATE OR REPLACE FUNCTION public.fn_on_vouch_change() 
RETURNS TRIGGER AS $$ 
BEGIN 
    IF (TG_OP = 'INSERT') THEN
        UPDATE public.profiles
        SET vouch_count = COALESCE(vouch_count, 0) + 1,
            is_community_trusted = (COALESCE(vouch_count, 0) + 1 >= 5)
        WHERE id = NEW.vouched_id;
    ELSIF (TG_OP = 'DELETE') THEN
        UPDATE public.profiles
        SET vouch_count = GREATEST(COALESCE(vouch_count, 0) - 1, 0),
            is_community_trusted = (GREATEST(COALESCE(vouch_count, 0) - 1, 0) >= 5)
        WHERE id = OLD.vouched_id;
    END IF;
    RETURN NULL;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Re-attach trigger
DROP TRIGGER IF EXISTS tr_on_vouch_change ON public.vouches;
CREATE TRIGGER tr_on_vouch_change
AFTER INSERT OR DELETE ON public.vouches 
FOR EACH ROW EXECUTE FUNCTION public.fn_on_vouch_change();

-- Backfill: Fix any legacy profiles where vouch_count is NULL
UPDATE public.profiles
SET vouch_count = 0
WHERE vouch_count IS NULL;

-- 2. Ensure private.notification_settings has vault fallback for email cron
-- (Prevents email system cron failures if Vault extension is disabled)
DO $$
BEGIN
    IF EXISTS (SELECT 1 FROM cron.job WHERE jobname = 'daily-match-email') THEN
        PERFORM cron.unschedule('daily-match-email');
    END IF;
    IF EXISTS (SELECT 1 FROM cron.job WHERE jobname = 'weekly-digest-email') THEN
        PERFORM cron.unschedule('weekly-digest-email');
    END IF;
    IF EXISTS (SELECT 1 FROM cron.job WHERE jobname = 'monthly-digest-email') THEN
        PERFORM cron.unschedule('monthly-digest-email');
    END IF;
END $$;

-- Reschedule Daily Match Email with fallback lookup
SELECT cron.schedule(
  'daily-match-email',
  '30 3 * * *',
  $$
  SELECT net.http_post(
    url := COALESCE(
      (SELECT decrypted_secret FROM vault.decrypted_secrets WHERE name = 'supabase_url'),
      (SELECT value FROM private.notification_settings WHERE key = 'supabase_url')
    ) || '/functions/v1/send-email',
    headers := jsonb_build_object(
      'Content-Type', 'application/json',
      'Authorization', 'Bearer ' || COALESCE(
        (SELECT decrypted_secret FROM vault.decrypted_secrets WHERE name = 'supabase_service_role_key'),
        (SELECT value FROM private.notification_settings WHERE key = 'service_role_key')
      )
    ),
    body := jsonb_build_object('type', 'daily_recommendation', 'to', 'batch', 'data', '{}'::jsonb)
  );
  $$
);

-- Reschedule Weekly Digest Email with fallback lookup
SELECT cron.schedule(
  'weekly-digest-email',
  '30 4 * * 0',
  $$
  SELECT net.http_post(
    url := COALESCE(
      (SELECT decrypted_secret FROM vault.decrypted_secrets WHERE name = 'supabase_url'),
      (SELECT value FROM private.notification_settings WHERE key = 'supabase_url')
    ) || '/functions/v1/send-email',
    headers := jsonb_build_object(
      'Content-Type', 'application/json',
      'Authorization', 'Bearer ' || COALESCE(
        (SELECT decrypted_secret FROM vault.decrypted_secrets WHERE name = 'supabase_service_role_key'),
        (SELECT value FROM private.notification_settings WHERE key = 'service_role_key')
      )
    ),
    body := jsonb_build_object('type', 'weekly_digest', 'to', 'batch', 'data', '{}'::jsonb)
  );
  $$
);

-- Reschedule Monthly Digest Email with fallback lookup
SELECT cron.schedule(
  'monthly-digest-email',
  '30 4 1 * *',
  $$
  SELECT net.http_post(
    url := COALESCE(
      (SELECT decrypted_secret FROM vault.decrypted_secrets WHERE name = 'supabase_url'),
      (SELECT value FROM private.notification_settings WHERE key = 'supabase_url')
    ) || '/functions/v1/send-email',
    headers := jsonb_build_object(
      'Content-Type', 'application/json',
      'Authorization', 'Bearer ' || COALESCE(
        (SELECT decrypted_secret FROM vault.decrypted_secrets WHERE name = 'supabase_service_role_key'),
        (SELECT value FROM private.notification_settings WHERE key = 'service_role_key')
      )
    ),
    body := jsonb_build_object('type', 'monthly_digest', 'to', 'batch', 'data', '{}'::jsonb)
  );
  $$
);
