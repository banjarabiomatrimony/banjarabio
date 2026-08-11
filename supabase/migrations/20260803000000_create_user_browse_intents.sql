-- Migration: Create user_browse_intents table and logging RPC
-- Description: Stores pre-auth relative search intents post-login for CRM, WhatsApp follow-ups, and analytics.

CREATE TABLE IF NOT EXISTS public.user_browse_intents (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    relation TEXT,
    target_gender TEXT,
    state TEXT,
    district TEXT,
    created_at TIMESTAMPTZ NOT NULL DEFAULT timezone('utc'::text, now())
);

-- Index for analytics queries
CREATE INDEX IF NOT EXISTS idx_user_browse_intents_user_id ON public.user_browse_intents(user_id);
CREATE INDEX IF NOT EXISTS idx_user_browse_intents_created_at ON public.user_browse_intents(created_at DESC);

-- RLS Security
ALTER TABLE public.user_browse_intents ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can insert their own intents"
    ON public.user_browse_intents
    FOR INSERT
    WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can view their own intents"
    ON public.user_browse_intents
    FOR SELECT
    USING (auth.uid() = user_id);

-- RPC Gateway Function for Intent Logging
CREATE OR REPLACE FUNCTION public.fn_log_user_browse_intent(
    p_relation TEXT,
    p_target_gender TEXT DEFAULT NULL,
    p_state TEXT DEFAULT NULL,
    p_district TEXT DEFAULT NULL
)
RETURNS VOID
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
    v_user_id UUID := auth.uid();
BEGIN
    IF v_user_id IS NULL THEN
        RAISE EXCEPTION 'Not authenticated';
    END IF;

    INSERT INTO public.user_browse_intents (
        user_id,
        relation,
        target_gender,
        state,
        district
    ) VALUES (
        v_user_id,
        p_relation,
        p_target_gender,
        p_state,
        p_district
    );
END;
$$;
