-- =====================================================
-- Email System: Logs Table, Preferences & pg_cron Schedules
-- =====================================================

-- 1. Email Logs Table (for analytics and debugging)
CREATE TABLE IF NOT EXISTS public.email_logs (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  email_type TEXT NOT NULL,
  recipients TEXT[] NOT NULL,
  provider TEXT,
  success BOOLEAN DEFAULT false,
  message_id TEXT,
  error TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_email_logs_type ON public.email_logs(email_type);
CREATE INDEX IF NOT EXISTS idx_email_logs_created ON public.email_logs(created_at DESC);

-- RLS: Only service-role can access email logs
ALTER TABLE public.email_logs ENABLE ROW LEVEL SECURITY;

-- 2. Email Preferences Table (opt-in/opt-out per user)
CREATE TABLE IF NOT EXISTS public.email_preferences (
  user_id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
  daily_recommendations BOOLEAN DEFAULT true,
  weekly_digest BOOLEAN DEFAULT true,
  monthly_digest BOOLEAN DEFAULT true,
  match_alerts BOOLEAN DEFAULT true,
  interest_alerts BOOLEAN DEFAULT true,
  local_profiles BOOLEAN DEFAULT true,
  offers BOOLEAN DEFAULT true,
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

ALTER TABLE public.email_preferences ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Users manage own email prefs" ON public.email_preferences;
CREATE POLICY "Users manage own email prefs" ON public.email_preferences FOR ALL
USING (auth.uid() = user_id);

-- Auto-create preferences row when a profile is created
CREATE OR REPLACE FUNCTION public.fn_auto_create_email_prefs()
RETURNS TRIGGER AS $$
BEGIN
  INSERT INTO public.email_preferences (user_id)
  VALUES (NEW.user_id)
  ON CONFLICT (user_id) DO NOTHING;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

DROP TRIGGER IF EXISTS tr_auto_create_email_prefs ON public.profiles;
CREATE TRIGGER tr_auto_create_email_prefs
AFTER INSERT ON public.profiles
FOR EACH ROW EXECUTE FUNCTION public.fn_auto_create_email_prefs();

-- =====================================================
-- 3. pg_cron Scheduled Jobs
-- =====================================================

-- Daily Match Picks Email (every day at 9:00 AM IST = 3:30 AM UTC)
SELECT cron.schedule(
  'daily-match-email',
  '30 3 * * *',
  $$
  SELECT net.http_post(
    url := (SELECT decrypted_secret FROM vault.decrypted_secrets WHERE name = 'supabase_url') || '/functions/v1/send-email',
    headers := jsonb_build_object(
      'Content-Type', 'application/json',
      'Authorization', 'Bearer ' || (SELECT decrypted_secret FROM vault.decrypted_secrets WHERE name = 'supabase_service_role_key')
    ),
    body := jsonb_build_object('type', 'daily_recommendation', 'to', 'batch', 'data', '{}'::jsonb)
  );
  $$
);

-- Weekly Digest Email (every Sunday at 10:00 AM IST = 4:30 AM UTC)
SELECT cron.schedule(
  'weekly-digest-email',
  '30 4 * * 0',
  $$
  SELECT net.http_post(
    url := (SELECT decrypted_secret FROM vault.decrypted_secrets WHERE name = 'supabase_url') || '/functions/v1/send-email',
    headers := jsonb_build_object(
      'Content-Type', 'application/json',
      'Authorization', 'Bearer ' || (SELECT decrypted_secret FROM vault.decrypted_secrets WHERE name = 'supabase_service_role_key')
    ),
    body := jsonb_build_object('type', 'weekly_digest', 'to', 'batch', 'data', '{}'::jsonb)
  );
  $$
);

-- Monthly Digest Email (1st of every month at 10:00 AM IST = 4:30 AM UTC)
SELECT cron.schedule(
  'monthly-digest-email',
  '30 4 1 * *',
  $$
  SELECT net.http_post(
    url := (SELECT decrypted_secret FROM vault.decrypted_secrets WHERE name = 'supabase_url') || '/functions/v1/send-email',
    headers := jsonb_build_object(
      'Content-Type', 'application/json',
      'Authorization', 'Bearer ' || (SELECT decrypted_secret FROM vault.decrypted_secrets WHERE name = 'supabase_service_role_key')
    ),
    body := jsonb_build_object('type', 'monthly_digest', 'to', 'batch', 'data', '{}'::jsonb)
  );
  $$
);
