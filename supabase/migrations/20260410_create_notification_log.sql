-- Notification log table for tracking all push delivery across User, Staff, and Admin roles.
-- Supports audit trail, delivery status tracking, and read receipts.

CREATE TABLE IF NOT EXISTS public.notification_log (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  target_user_id UUID REFERENCES auth.users(id) ON DELETE SET NULL,
  target_role TEXT NOT NULL DEFAULT 'user',
  event_type TEXT NOT NULL,
  title TEXT,
  body TEXT,
  data JSONB DEFAULT '{}',
  delivery_status TEXT NOT NULL DEFAULT 'sent',
  triggered_by_user_id UUID REFERENCES auth.users(id) ON DELETE SET NULL,
  read_at TIMESTAMPTZ,
  created_at TIMESTAMPTZ DEFAULT now()
);

-- Indexes for common query patterns
CREATE INDEX IF NOT EXISTS idx_notification_log_target_user ON public.notification_log(target_user_id);
CREATE INDEX IF NOT EXISTS idx_notification_log_target_role ON public.notification_log(target_role);
CREATE INDEX IF NOT EXISTS idx_notification_log_event_type ON public.notification_log(event_type);
CREATE INDEX IF NOT EXISTS idx_notification_log_created_at ON public.notification_log(created_at DESC);

-- RLS: Users can only read their own notification logs
ALTER TABLE public.notification_log ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can read own notifications"
  ON public.notification_log
  FOR SELECT
  USING (auth.uid() = target_user_id);

-- Admins and staff can read all notifications for their role
CREATE POLICY "Admins can read admin notifications"
  ON public.notification_log
  FOR SELECT
  USING (
    target_role = 'admin'
    AND EXISTS (
      SELECT 1 FROM public.profiles
      WHERE user_id = auth.uid() AND role = 'admin'
    )
  );

CREATE POLICY "Staff can read staff notifications"
  ON public.notification_log
  FOR SELECT
  USING (
    target_role = 'staff'
    AND EXISTS (
      SELECT 1 FROM public.profiles
      WHERE user_id = auth.uid() AND role = 'staff'
    )
  );

-- Service role can insert (used by Edge Functions)
CREATE POLICY "Service role can insert"
  ON public.notification_log
  FOR INSERT
  WITH CHECK (true);

-- Users can update read_at for their own notifications
CREATE POLICY "Users can mark own notifications as read"
  ON public.notification_log
  FOR UPDATE
  USING (auth.uid() = target_user_id)
  WITH CHECK (auth.uid() = target_user_id);
