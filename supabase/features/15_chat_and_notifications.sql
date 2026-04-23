-- Last run: 2025-02-13 — Update when re-run in Supabase SQL Editor
-- =====================================================
-- 15. CHAT AND NOTIFICATIONS
-- Implementation of real-time messaging, conversation management, and profile view tracking.
-- =====================================================
-- =====================================================
-- UPDATING PROFILES TABLE
-- =====================================================
ALTER TABLE public.profiles
ADD COLUMN IF NOT EXISTS fcm_token TEXT;
--- =====================================================
-- TABLE: conversations
-- Tracks mutual matches and chat metadata.
-- =====================================================
CREATE TABLE IF NOT EXISTS public.conversations (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    participant_one_id UUID NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
    participant_two_id UUID NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
    p1_user_id UUID REFERENCES auth.users(id), -- [Scaling]
    p2_user_id UUID REFERENCES auth.users(id), -- [Scaling]
    last_message_text TEXT,
    last_message_at TIMESTAMPTZ DEFAULT NOW(),
    unread_count_one INTEGER DEFAULT 0,
    unread_count_two INTEGER DEFAULT 0,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW(),
    -- Ensure UNIQUE pair (order-independent)
    CONSTRAINT unique_conversation_pair UNIQUE (participant_one_id, participant_two_id),
    CONSTRAINT participants_must_be_different CHECK (participant_one_id != participant_two_id)
);

-- Index for User-ID based lookups (O(1) RLS)
CREATE INDEX IF NOT EXISTS idx_conversations_p1_user ON public.conversations(p1_user_id);
CREATE INDEX IF NOT EXISTS idx_conversations_p2_user ON public.conversations(p2_user_id);

-- =====================================================
-- VIEW: conversations_view (O(1) Optimized for 10M DAU)
-- =====================================================
CREATE OR REPLACE VIEW public.conversations_view AS
SELECT c.*,
    -- [Scaling] Specialized "Other participant" lookup
    CASE 
        WHEN c.p1_user_id = auth.uid() THEN c.participant_two_id 
        ELSE c.participant_one_id 
    END AS other_participant_id,
    p.full_name AS other_participant_name,
    ph.public_url AS other_participant_image_url
FROM public.conversations c
JOIN public.profiles p ON p.id = (
    CASE 
        WHEN c.p1_user_id = auth.uid() THEN c.participant_two_id 
        ELSE c.participant_one_id 
    END
)
LEFT JOIN LATERAL (
    SELECT public_url FROM public.photos 
    WHERE profile_id = p.id AND is_primary = true 
    LIMIT 1
) ph ON TRUE
WHERE c.p1_user_id = auth.uid() OR c.p2_user_id = auth.uid();

-- INDEXES (Conversation list ordered by last message)
CREATE INDEX IF NOT EXISTS idx_conversations_p1 ON public.conversations(participant_one_id);
CREATE INDEX IF NOT EXISTS idx_conversations_p2 ON public.conversations(participant_two_id);
CREATE INDEX IF NOT EXISTS idx_conversations_last_message ON public.conversations(last_message_at DESC NULLS LAST);

-- RLS
ALTER TABLE public.conversations ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS "Users can view own conversations" ON public.conversations;
CREATE POLICY "Users can view own conversations" ON public.conversations FOR SELECT 
USING ((SELECT auth.uid()) = p1_user_id OR (SELECT auth.uid()) = p2_user_id);

-- =====================================================
-- TABLE: messages (Partitioned by created_at)
-- =====================================================
CREATE TABLE IF NOT EXISTS public.messages (
    id UUID NOT NULL DEFAULT gen_random_uuid(),
    conversation_id UUID NOT NULL REFERENCES public.conversations(id) ON DELETE CASCADE,
    sender_id UUID NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
    message_text TEXT NOT NULL,
    is_read BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    p1_user_id UUID REFERENCES auth.users(id), -- [Scaling]
    p2_user_id UUID REFERENCES auth.users(id), -- [Scaling]
    PRIMARY KEY (id, created_at)
) PARTITION BY RANGE (created_at);

-- RLS for messages (Optimized)
ALTER TABLE public.messages ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS "Users can view own messages" ON public.messages;
CREATE POLICY "Users can view own messages" ON public.messages FOR SELECT 
USING ((SELECT auth.uid()) = p1_user_id OR (SELECT auth.uid()) = p2_user_id);

DROP POLICY IF EXISTS "Users can insert messages in own chats" ON public.messages;
CREATE POLICY "Users can insert messages in own chats" ON public.messages FOR INSERT 
WITH CHECK (
    ((SELECT auth.uid()) = p1_user_id OR (SELECT auth.uid()) = p2_user_id)
    AND sender_id IN (SELECT id FROM public.profiles WHERE user_id = auth.uid())
);

-- =====================================================
-- TABLE: profile_views (Partitioned by last_viewed_at)
-- =====================================================
CREATE TABLE IF NOT EXISTS public.profile_views (
    id UUID NOT NULL DEFAULT gen_random_uuid(),
    viewer_id UUID NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
    viewed_id UUID NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
    view_count INTEGER DEFAULT 1,
    last_viewed_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    created_at TIMESTAMPTZ DEFAULT NOW(),
    PRIMARY KEY (id, last_viewed_at)
) PARTITION BY RANGE (last_viewed_at);

CREATE INDEX IF NOT EXISTS idx_profile_views_viewed ON public.profile_views(viewed_id, last_viewed_at DESC NULLS LAST);
CREATE INDEX IF NOT EXISTS idx_profile_views_viewer ON public.profile_views(viewer_id, last_viewed_at DESC NULLS LAST);

-- RLS for profile_views
ALTER TABLE public.profile_views ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS "Viewers can see their history" ON public.profile_views;
CREATE POLICY "Viewers can see their history" ON public.profile_views FOR SELECT 
USING ((SELECT auth.uid()) = (SELECT user_id FROM public.profiles WHERE id = viewer_id));

DROP POLICY IF EXISTS "Profile owners can see who viewed them" ON public.profile_views;
CREATE POLICY "Profile owners can see who viewed them" ON public.profile_views FOR SELECT 
USING ((SELECT auth.uid()) = (SELECT user_id FROM public.profiles WHERE id = viewed_id));

-- =====================================================
-- TRIGGER: Create Conversation on Match & ID Sync
-- =====================================================
CREATE OR REPLACE FUNCTION public.fn_sync_conversation_user_ids()
RETURNS TRIGGER AS $$
BEGIN
  SELECT user_id INTO NEW.p1_user_id FROM public.profiles WHERE id = NEW.participant_one_id;
  SELECT user_id INTO NEW.p2_user_id FROM public.profiles WHERE id = NEW.participant_two_id;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

DROP TRIGGER IF EXISTS tr_sync_conversation_user_ids ON public.conversations;
CREATE TRIGGER tr_sync_conversation_user_ids
BEFORE INSERT ON public.conversations
FOR EACH ROW EXECUTE FUNCTION public.fn_sync_conversation_user_ids();

CREATE OR REPLACE FUNCTION public.fn_sync_message_user_ids()
RETURNS TRIGGER AS $$
BEGIN
  SELECT p1_user_id, p2_user_id INTO NEW.p1_user_id, NEW.p2_user_id 
  FROM public.conversations WHERE id = NEW.conversation_id;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

DROP TRIGGER IF EXISTS tr_sync_message_user_ids ON public.messages;
CREATE TRIGGER tr_sync_message_user_ids
BEFORE INSERT ON public.messages
FOR EACH ROW EXECUTE FUNCTION public.fn_sync_message_user_ids();

CREATE OR REPLACE FUNCTION public.fn_create_chat_on_match() RETURNS TRIGGER AS $$
DECLARE v_p1 UUID;
v_p2 UUID;
BEGIN IF NEW.status = 'matched'
AND (
    OLD.status IS NULL
    OR OLD.status != 'matched'
) THEN -- Sort IDs to maintain unique pair (p1 < p2)
IF NEW.sharer_id < NEW.recipient_id THEN v_p1 := NEW.sharer_id;
v_p2 := NEW.recipient_id;
ELSE v_p1 := NEW.recipient_id;
v_p2 := NEW.sharer_id;
END IF;
INSERT INTO public.conversations (participant_one_id, participant_two_id)
VALUES (v_p1, v_p2) ON CONFLICT (participant_one_id, participant_two_id) DO NOTHING;
END IF;
RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

DROP TRIGGER IF EXISTS tr_create_chat_on_match ON public.profile_shares;
CREATE TRIGGER tr_create_chat_on_match
AFTER
UPDATE OF status ON public.profile_shares FOR EACH ROW EXECUTE FUNCTION public.fn_create_chat_on_match();

-- =====================================================
-- TABLE: notification_queue (New: Batching System)
-- =====================================================
CREATE TABLE IF NOT EXISTS public.notification_queue (
    id UUID NOT NULL DEFAULT gen_random_uuid(),
    recipient_user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    title TEXT NOT NULL,
    body TEXT NOT NULL,
    data JSONB DEFAULT '{}',
    status TEXT DEFAULT 'pending' CHECK (status IN ('pending', 'processing', 'sent', 'failed')),
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    processed_at TIMESTAMPTZ,
    PRIMARY KEY (id, created_at)
) PARTITION BY RANGE (created_at);

-- Queue message notification Trigger
CREATE OR REPLACE FUNCTION public.fn_queue_message_notification()
RETURNS TRIGGER AS $$
DECLARE
    v_recipient_user_id UUID;
    v_sender_name TEXT;
BEGIN
    IF NEW.sender_id IN (SELECT id FROM public.profiles WHERE user_id = NEW.p1_user_id) THEN
        v_recipient_user_id := NEW.p2_user_id;
    ELSE
        v_recipient_user_id := NEW.p1_user_id;
    END IF;
    SELECT full_name INTO v_sender_name FROM public.profiles WHERE id = NEW.sender_id;
    INSERT INTO public.notification_queue (recipient_user_id, title, body, data)
    VALUES (v_recipient_user_id, 'New Message', v_sender_name || ': ' || LEFT(NEW.message_text, 50), jsonb_build_object('type', 'chat', 'conversation_id', NEW.conversation_id));
    RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

DROP TRIGGER IF EXISTS tr_queue_message_notification ON public.messages;
CREATE TRIGGER tr_queue_message_notification
AFTER INSERT ON public.messages
FOR EACH ROW EXECUTE FUNCTION public.fn_queue_message_notification();

-- =====================================================
-- MASTER RPC: fn_manage_chat
-- =====================================================
CREATE OR REPLACE FUNCTION public.fn_manage_chat(action TEXT, payload JSONB) RETURNS JSONB AS $$
DECLARE v_user_id UUID := auth.uid();
v_profile_id UUID;
v_conversation_id UUID;
v_result JSONB;
v_other_profile_id UUID;
v_p1 UUID;
v_p2 UUID;
BEGIN IF v_user_id IS NULL THEN RAISE EXCEPTION 'Not authenticated';
END IF;
SELECT id INTO v_profile_id
FROM public.profiles
WHERE user_id = v_user_id;
CASE
    action
    WHEN 'get_or_create_conversation' THEN
    SELECT id INTO v_other_profile_id
    FROM public.profiles
    WHERE user_id = (payload->>'other_user_id')::UUID;
IF v_other_profile_id IS NULL THEN RAISE EXCEPTION 'Other user profile not found';
END IF;
IF v_other_profile_id = v_profile_id THEN RAISE EXCEPTION 'Cannot chat with yourself';
END IF;
-- Verify matched (either direction)
IF NOT EXISTS (
    SELECT 1
    FROM public.profile_shares
    WHERE sharing_method = 'in_app'
        AND status = 'matched'
        AND (
            (
                sharer_id = v_profile_id
                AND recipient_id = v_other_profile_id
            )
            OR (
                sharer_id = v_other_profile_id
                AND recipient_id = v_profile_id
            )
        )
) THEN RAISE EXCEPTION 'You must be matched to start a conversation';
END IF;
IF v_profile_id < v_other_profile_id THEN v_p1 := v_profile_id;
v_p2 := v_other_profile_id;
ELSE v_p1 := v_other_profile_id;
v_p2 := v_profile_id;
END IF;
INSERT INTO public.conversations (participant_one_id, participant_two_id)
VALUES (v_p1, v_p2) ON CONFLICT (participant_one_id, participant_two_id) DO NOTHING;
SELECT row_to_json(cv)::jsonb INTO v_result
FROM public.conversations_view cv
WHERE cv.participant_one_id = v_p1
    AND cv.participant_two_id = v_p2
LIMIT 1;
WHEN 'send_message' THEN v_conversation_id := (payload->>'conversation_id')::UUID;
-- Insert message
INSERT INTO public.messages (conversation_id, sender_id, message_text)
VALUES (
        v_conversation_id,
        v_profile_id,
        payload->>'message_text'
    )
RETURNING jsonb_build_object('id', id, 'created_at', created_at) INTO v_result;
-- Update conversation metadata
UPDATE public.conversations
SET last_message_text = payload->>'message_text',
    last_message_at = NOW(),
    updated_at = NOW(),
    unread_count_one = unread_count_one + CASE
        WHEN participant_two_id = v_profile_id THEN 1
        ELSE 0
    END,
    unread_count_two = unread_count_two + CASE
        WHEN participant_one_id = v_profile_id THEN 1
        ELSE 0
    END
WHERE id = v_conversation_id;
WHEN 'mark_as_read' THEN v_conversation_id := (payload->>'conversation_id')::UUID;
-- Update local messages
UPDATE public.messages
SET is_read = TRUE
WHERE conversation_id = v_conversation_id
    AND sender_id != v_profile_id;
-- Reset unread count
UPDATE public.conversations
SET unread_count_one = CASE
        WHEN participant_one_id = v_profile_id THEN 0
        ELSE unread_count_one
    END,
    unread_count_two = CASE
        WHEN participant_two_id = v_profile_id THEN 0
        ELSE unread_count_two
    END
WHERE id = v_conversation_id;
v_result := jsonb_build_object('status', 'success');
WHEN 'track_view' THEN
INSERT INTO public.profile_views (viewer_id, viewed_id)
VALUES (v_profile_id, (payload->>'viewed_id')::UUID) ON CONFLICT (viewer_id, viewed_id) DO
UPDATE
SET view_count = public.profile_views.view_count + 1,
    last_viewed_at = NOW();
v_result := jsonb_build_object('status', 'success');
ELSE RAISE EXCEPTION 'Invalid action';
END CASE
;
RETURN v_result;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;
GRANT EXECUTE ON FUNCTION public.fn_manage_chat(TEXT, JSONB) TO authenticated;

-- Batch Retrieval RPC
CREATE OR REPLACE FUNCTION public.fn_get_notification_batch(
    p_batch_size INT DEFAULT 100
) RETURNS JSONB AS $$
DECLARE
    v_batch JSONB;
BEGIN
    WITH batch AS (
        SELECT id, created_at
        FROM public.notification_queue
        WHERE status = 'pending'
        ORDER BY created_at ASC
        LIMIT p_batch_size
        FOR UPDATE SKIP LOCKED
    )
    UPDATE public.notification_queue n
    SET status = 'processing', processed_at = NOW()
    FROM batch
    WHERE n.id = batch.id AND n.created_at = batch.created_at
    RETURNING jsonb_build_object(
        'id', n.id,
        'recipient_user_id', n.recipient_user_id,
        'title', n.title,
        'body', n.body,
        'data', n.data,
        'fcm_token', (SELECT fcm_token FROM public.profiles WHERE user_id = n.recipient_user_id)
    ) INTO v_batch;

    RETURN jsonb_agg(v_batch);
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;
-- EOF