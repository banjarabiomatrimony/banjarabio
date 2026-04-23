-- =====================================================
-- Real-time Email triggers (New Match, New Interest, New Local Profile)
-- =====================================================

-- 1. New Match Trigger (Immediate)
CREATE OR REPLACE FUNCTION public.fn_email_trigger_new_match()
RETURNS TRIGGER AS $$
DECLARE
    user_a_email TEXT;
    user_b_email TEXT;
    user_a_name TEXT;
    user_b_name TEXT;
    user_a_district TEXT;
    user_b_district TEXT;
BEGIN
    -- Only trigger when status changes to 'matched'
    IF NEW.status = 'matched' AND (OLD.status IS NULL OR OLD.status <> 'matched') THEN
        
        -- Get info for both users
        SELECT email, full_name, district INTO user_a_email, user_a_name, user_a_district FROM public.profiles WHERE user_id = NEW.sender_id;
        SELECT email, full_name, district INTO user_b_email, user_b_name, user_b_district FROM public.profiles WHERE user_id = NEW.receiver_id;

        -- Notify User A
        IF user_a_email IS NOT NULL AND EXISTS (SELECT 1 FROM public.email_preferences WHERE user_id = NEW.sender_id AND match_alerts = true) THEN
            PERFORM net.http_post(
                url := (SELECT decrypted_secret FROM vault.decrypted_secrets WHERE name = 'supabase_url') || '/functions/v1/send-email',
                headers := jsonb_build_object(
                    'Content-Type', 'application/json',
                    'Authorization', 'Bearer ' || (SELECT decrypted_secret FROM vault.decrypted_secrets WHERE name = 'supabase_service_role_key')
                ),
                body := jsonb_build_object(
                    'type', 'new_match',
                    'to', user_a_email,
                    'data', jsonb_build_object('matchName', user_b_name, 'matchDistrict', user_b_district)
                )
            );
        END IF;

        -- Notify User B
        IF user_b_email IS NOT NULL AND EXISTS (SELECT 1 FROM public.email_preferences WHERE user_id = NEW.receiver_id AND match_alerts = true) THEN
            PERFORM net.http_post(
                url := (SELECT decrypted_secret FROM vault.decrypted_secrets WHERE name = 'supabase_url') || '/functions/v1/send-email',
                headers := jsonb_build_object(
                    'Content-Type', 'application/json',
                    'Authorization', 'Bearer ' || (SELECT decrypted_secret FROM vault.decrypted_secrets WHERE name = 'supabase_service_role_key')
                ),
                body := jsonb_build_object(
                    'type', 'new_match',
                    'to', user_b_email,
                    'data', jsonb_build_object('matchName', user_a_name, 'matchDistrict', user_a_district)
                )
            );
        END IF;
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

DROP TRIGGER IF EXISTS tr_email_new_match ON public.profile_shares;
CREATE TRIGGER tr_email_new_match
AFTER UPDATE ON public.profile_shares
FOR EACH ROW EXECUTE FUNCTION public.fn_email_trigger_new_match();


-- 2. New Interest Trigger (Immediate Bookmark)
CREATE OR REPLACE FUNCTION public.fn_email_trigger_new_interest()
RETURNS TRIGGER AS $$
DECLARE
    receiver_email TEXT;
    receiver_user_id UUID;
BEGIN
    -- receiver_id in bookmarks table? Let's check table name and schema
    -- Guessing table "bookmarks" or "profile_bookmarks"
    -- Based on implementation_plan: bookmarks
    
    -- Get receiver info (the person being bookmarked)
    SELECT u.email, u.user_id INTO receiver_email, receiver_user_id 
    FROM public.profiles u 
    WHERE u.user_id = NEW.receiver_id;

    IF receiver_email IS NOT NULL AND EXISTS (SELECT 1 FROM public.email_preferences WHERE user_id = receiver_user_id AND interest_alerts = true) THEN
        PERFORM net.http_post(
            url := (SELECT decrypted_secret FROM vault.decrypted_secrets WHERE name = 'supabase_url') || '/functions/v1/send-email',
            headers := jsonb_build_object(
                'Content-Type', 'application/json',
                'Authorization', 'Bearer ' || (SELECT decrypted_secret FROM vault.decrypted_secrets WHERE name = 'supabase_service_role_key')
            ),
            body := jsonb_build_object(
                'type', 'new_interest',
                'to', receiver_email,
                'data', '{}'::jsonb
            )
        );
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Note: Ensure bookmarks table exists or adjust name
-- Trigger will be added after I verify table name


-- 3. New Local Profile Alert (On Profile Creation)
CREATE OR REPLACE FUNCTION public.fn_email_trigger_new_local_profile()
RETURNS TRIGGER AS $$
BEGIN
    -- Notify other users in the same district
    -- To avoid spamming, we limit it to users who have opted in and are in the same district
    -- For now, this logic is handled in batch mode daily, but we can fire one-off for very relevant ones
    -- Skipping immediate trigger for local profiles to avoid bombarding users during many signups
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;
