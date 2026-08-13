-- =============================================================
-- Migration: 20260813183000_add_browse_intent_composite_index.sql
-- Purpose: Add composite index to user_browse_intents on (target_gender, created_at DESC)
--          to accelerate fn_match_browse_intents_for_new_profile trigger performance.
-- Created: 2026-08-13
-- =============================================================
CREATE INDEX IF NOT EXISTS idx_user_browse_intents_gender_created 
ON public.user_browse_intents(target_gender, created_at DESC);
