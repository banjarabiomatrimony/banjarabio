-- 20260312000000_notification_triggers.sql
-- Enable pg_net extension if not already enabled
CREATE EXTENSION IF NOT EXISTS pg_net SCHEMA extensions;
-- Configuration table in private schema
CREATE SCHEMA IF NOT EXISTS private;
CREATE TABLE IF NOT EXISTS private.notification_settings (
    id BIGINT PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
    key TEXT UNIQUE NOT NULL,
    value TEXT NOT NULL
);
-- Seed defaults (User will need to update these via Supabase Dashboard or I can try to set them if I have access)
-- Note: These are placeholders. 
INSERT INTO private.notification_settings (key, value)
VALUES (
        'supabase_url',
        'https://icvmuktbpxglsmyvebwf.supabase.co'
    ),
    (
        'service_role_key',
        'PLACEHOLDER_SERVICE_ROLE_KEY'
    ) ON CONFLICT (key) DO NOTHING;
-- Function to handle sending push notifications via Edge Function
CREATE OR REPLACE FUNCTION public.fn_trigger_push_notification(
        p_user_id UUID,
        p_title TEXT,
        p_body TEXT,
        p_data JSONB DEFAULT '{}'::jsonb
    ) RETURNS VOID AS $$
DECLARE v_fcm_token TEXT;
v_payload JSONB;
v_url TEXT;
v_key TEXT;
BEGIN -- Get FCM token for the user
SELECT fcm_token INTO v_fcm_token
FROM public.profiles
WHERE user_id = p_user_id;
-- Get configuration
SELECT value INTO v_url
FROM private.notification_settings
WHERE key = 'supabase_url';
SELECT value INTO v_key
FROM private.notification_settings
WHERE key = 'service_role_key';
IF v_fcm_token IS NOT NULL
AND v_url IS NOT NULL
AND v_key != 'PLACEHOLDER_SERVICE_ROLE_KEY' THEN v_payload := jsonb_build_object(
    'fcm_token',
    v_fcm_token,
    'title',
    p_title,
    'body',
    p_body,
    'data',
    p_data
);
-- Perform async HTTP POST to Supabase Edge Function
PERFORM net.http_post(
    url := v_url || '/functions/v1/send-push-notification',
    headers := jsonb_build_object(
        'Content-Type',
        'application/json',
        'Authorization',
        'Bearer ' || v_key
    ),
    body := v_payload
);
END IF;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;
-- 1. Trigger for New Messages
CREATE OR REPLACE FUNCTION public.fn_on_new_message_notify() RETURNS TRIGGER AS $$
DECLARE v_recipient_user_id UUID;
v_sender_name TEXT;
BEGIN -- 🧬 PRO SCALE: Single-pass lookup for Recipient UserID and Sender Name
-- This reduces DB context switches from 3 to 1.
SELECT rp.user_id,
    sp.full_name INTO v_recipient_user_id,
    v_sender_name
FROM public.conversations c
    JOIN public.profiles sp ON sp.id = NEW.sender_id
    JOIN public.profiles rp ON rp.id = (
        CASE
            WHEN c.participant_one_id = NEW.sender_id THEN c.participant_two_id
            ELSE c.participant_one_id
        END
    )
WHERE c.id = NEW.conversation_id;
-- Trigger notification for recipient
IF v_recipient_user_id IS NOT NULL THEN PERFORM public.fn_trigger_push_notification(
    v_recipient_user_id,
    'New Message from ' || COALESCE(v_sender_name, 'Someone'),
    NEW.message_text,
    jsonb_build_object(
        'type',
        'new_message',
        'conversation_id',
        NEW.conversation_id,
        'route',
        '/chat_screen?conversationId=' || NEW.conversation_id
    )
);
END IF;
RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;
-- Drop existing trigger if exists
DROP TRIGGER IF EXISTS tr_on_new_message ON public.messages;
CREATE TRIGGER tr_on_new_message
AFTER
INSERT ON public.messages FOR EACH ROW EXECUTE FUNCTION public.fn_on_new_message_notify();
-- 2. Trigger for Profile Shares and Matches
CREATE OR REPLACE FUNCTION public.fn_on_profile_share_notify() RETURNS TRIGGER AS $$
DECLARE v_sharer_name TEXT;
v_recipient_user_id UUID;
v_sharer_user_id UUID;
BEGIN -- Handle NEW Match (Status = 'matched')
IF (
    TG_OP = 'UPDATE'
    AND NEW.status = 'matched'
    AND OLD.status != 'matched'
)
OR (
    TG_OP = 'INSERT'
    AND NEW.status = 'matched'
) THEN -- Notify Sharer
SELECT full_name INTO v_sharer_name
FROM public.profiles
WHERE id = NEW.recipient_id;
SELECT user_id INTO v_sharer_user_id
FROM public.profiles
WHERE id = NEW.sharer_id;
IF v_sharer_user_id IS NOT NULL THEN PERFORM public.fn_trigger_push_notification(
    v_sharer_user_id,
    'It''s a Match! 😍',
    'You and ' || COALESCE(v_sharer_name, 'someone') || ' liked each other.',
    jsonb_build_object(
        'type',
        'new_match',
        'profile_id',
        NEW.recipient_id,
        'route',
        '/profile_details?id=' || NEW.recipient_id
    )
);
END IF;
-- Notify Recipient
SELECT full_name INTO v_sharer_name
FROM public.profiles
WHERE id = NEW.sharer_id;
SELECT user_id INTO v_recipient_user_id
FROM public.profiles
WHERE id = NEW.recipient_id;
IF v_recipient_user_id IS NOT NULL THEN PERFORM public.fn_trigger_push_notification(
    v_recipient_user_id,
    'It''s a Match! 😍',
    'You and ' || COALESCE(v_sharer_name, 'someone') || ' liked each other.',
    jsonb_build_object(
        'type',
        'new_match',
        'profile_id',
        NEW.sharer_id,
        'route',
        '/profile_details?id=' || NEW.sharer_id
    )
);
END IF;
-- Handle NEW Share (Status = 'pending' or 'new')
ELSIF (
    TG_OP = 'INSERT'
    AND NEW.recipient_id IS NOT NULL
) THEN
SELECT full_name INTO v_sharer_name
FROM public.profiles
WHERE id = NEW.sharer_id;
SELECT user_id INTO v_recipient_user_id
FROM public.profiles
WHERE id = NEW.recipient_id;
IF v_recipient_user_id IS NOT NULL THEN PERFORM public.fn_trigger_push_notification(
    v_recipient_user_id,
    'New Profile Recommendation 🌟',
    COALESCE(v_sharer_name, 'Someone') || ' shared a biodata with you.',
    jsonb_build_object(
        'type',
        'new_profile_share',
        'share_id',
        NEW.id,
        'route',
        '/received_shares'
    )
);
END IF;
END IF;
RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;
-- Drop existing trigger if exists
DROP TRIGGER IF EXISTS tr_on_profile_share ON public.profile_shares;
CREATE TRIGGER tr_on_profile_share
AFTER
INSERT
    OR
UPDATE ON public.profile_shares FOR EACH ROW EXECUTE FUNCTION public.fn_on_profile_share_notify();