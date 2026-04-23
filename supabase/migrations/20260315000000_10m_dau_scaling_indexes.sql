-- 🏛️ 10M DAU SCALING INDEXES
-- Purpose: Optimize fuzzy search and faceted filtering for massive user lists.
-- 1. Enable pg_trgm for fast fuzzy matching
CREATE EXTENSION IF NOT EXISTS pg_trgm;
-- 2. GIN Indexes for Sub-second Text Search
-- B-Tree indexes fail on leading wildcards (e.g. %query%). GIN + trigram handles this at O(log N).
CREATE INDEX IF NOT EXISTS idx_profiles_name_trgm ON public.profiles USING gin (full_name gin_trgm_ops);
CREATE INDEX IF NOT EXISTS idx_profiles_surname_trgm ON public.profiles USING gin (surname gin_trgm_ops);
CREATE INDEX IF NOT EXISTS idx_profiles_education_trgm ON public.profiles USING gin (education gin_trgm_ops);
CREATE INDEX IF NOT EXISTS idx_profiles_profession_trgm ON public.profiles USING gin (profession gin_trgm_ops);
-- 3. Optimized Location Facets
-- Common filters like State/District benefit from multi-column indexes for specific discovery flows.
CREATE INDEX IF NOT EXISTS idx_profiles_location_facet ON public.profiles(state, district, taluka)
WHERE is_active = true;
-- 4. Safety Layer: Efficient Block Checks
-- Ensures the NOT EXISTS check in the feed RPC is instantaneous.
-- (Primary Key and Unique constraints already handle some of this, but explicit B-Tree ensures sorting for merge joins)
CREATE INDEX IF NOT EXISTS idx_user_blocks_composite ON public.user_blocks(blocker_id, blocked_id);
-- 5. Statistics Update
ANALYZE public.profiles;
ANALYZE public.user_blocks;