-- 💎 Phase 8: Advanced Scale Hardening
-- 1. Fix "Hidden N+1" in conversations_view
-- 2. Partitioning Preparation for high-growth tables
-- [1] RE-OPTIMIZED CONVERSATIONS VIEW
-- Instead of subqueries in the CASE, we use a LEFT JOIN on primary photos.
-- This reduces query complexity from O(N * Subqueries) to O(N).
CREATE OR REPLACE VIEW public.conversations_view AS
SELECT c.*,
    -- Determine "Other" Participant details without subqueries
    CASE
        WHEN c.participant_one_id = p.id THEN p2.id
        ELSE p.id
    END as other_participant_id,
    CASE
        WHEN c.participant_one_id = p.id THEN p2.full_name
        ELSE p.full_name
    END as other_participant_name,
    -- Efficiently get the primary photo via the pre-fetched join
    COALESCE(ph1.public_url, ph2.public_url) as other_participant_image_url
FROM public.conversations c
    JOIN public.profiles p ON (
        c.participant_one_id = p.id
        OR c.participant_two_id = p.id
    )
    JOIN public.profiles p2 ON (
        (
            c.participant_one_id = p2.id
            AND c.participant_two_id = p.id
        )
        OR (
            c.participant_two_id = p2.id
            AND c.participant_one_id = p.id
        )
    ) -- JOIN to photos for participant one
    LEFT JOIN public.photos ph1 ON (
        ph1.profile_id = p2.id
        AND ph1.is_primary = true
        AND ph1.is_approved = true
    ) -- JOIN to photos for participant two (if p is the other)
    LEFT JOIN public.photos ph2 ON (
        ph2.profile_id = p.id
        AND ph2.is_primary = true
        AND ph2.is_approved = true
    )
WHERE p.user_id = auth.uid()
    AND p2.id != p.id;
-- [2] DATA PRUNING POLICY
-- Profile views grow exponentially. Pruning 90-day old views keeps the index hot in RAM.
CREATE OR REPLACE FUNCTION public.fn_prune_old_stats() RETURNS VOID AS $$ BEGIN
DELETE FROM public.profile_views
WHERE last_viewed_at < NOW() - INTERVAL '90 days';
END;
$$ LANGUAGE plpgsql;
-- [3] PARTITIONING TEMPLATES (Documentation only, requires Supabase Dashboard/CLI to execute Partitioned Table Conversion)
-- Recommendation: 
-- 1. ALTER TABLE public.messages RENAME TO messages_old;
-- 2. CREATE TABLE public.messages (LIKE messages_old INCLUDING ALL) PARTITION BY RANGE (created_at);
-- 3. CREATE TABLE messages_2026_03 PARTITION OF public.messages FOR VALUES FROM ('2026-03-01') TO ('2026-04-01');