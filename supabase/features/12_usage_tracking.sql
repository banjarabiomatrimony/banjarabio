-- Last run: 2025-02-13 — Update when re-run in Supabase SQL Editor
-- =====================================================
-- 12. USAGE TRACKING FEATURE
-- Handles daily quotas and tracking metrics.
-- =====================================================
-- =====================================================
-- TABLE: usage_tracking (UNIQUE user_id, date = index for upsert)
-- =====================================================
CREATE TABLE IF NOT EXISTS public.usage_tracking (
    id UUID NOT NULL DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    date DATE NOT NULL DEFAULT CURRENT_DATE,
    month DATE DEFAULT DATE_TRUNC('month', CURRENT_DATE),
    profile_views INTEGER DEFAULT 0 CHECK (profile_views >= 0),
    shares_count INTEGER DEFAULT 0 CHECK (shares_count >= 0),
    bookmarks_count INTEGER DEFAULT 0 CHECK (bookmarks_count >= 0),
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW(),
    PRIMARY KEY (id, date)
) PARTITION BY RANGE (date);

-- Index for date-range analytics
CREATE INDEX IF NOT EXISTS idx_usage_tracking_user_date_part ON public.usage_tracking(user_id, date DESC);
-- RLS
ALTER TABLE public.usage_tracking ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS "Users manage own usage" ON public.usage_tracking;
CREATE POLICY "Users manage own usage" ON public.usage_tracking FOR ALL USING (auth.uid() = user_id);
-- =====================================================
-- MASTER RPC FUNCTION: fn_track_usage
-- =====================================================
CREATE OR REPLACE FUNCTION public.fn_track_usage(
        metric TEXT,
        -- 'profile_views' | 'shares_count' | 'bookmarks_count'
        increment INTEGER DEFAULT 1
    ) RETURNS JSONB AS $$
DECLARE v_user_id UUID := auth.uid();
BEGIN IF v_user_id IS NULL THEN RAISE EXCEPTION 'Not authenticated';
END IF;
INSERT INTO public.usage_tracking (
        user_id,
        date,
        profile_views,
        shares_count,
        bookmarks_count
    )
VALUES (
        v_user_id,
        CURRENT_DATE,
        CASE
            WHEN metric = 'profile_views' THEN increment
            ELSE 0
        END,
        CASE
            WHEN metric = 'shares_count' THEN increment
            ELSE 0
        END,
        CASE
            WHEN metric = 'bookmarks_count' THEN increment
            ELSE 0
        END
    ) ON CONFLICT (user_id, date) DO
UPDATE
SET profile_views = public.usage_tracking.profile_views + (
        CASE
            WHEN metric = 'profile_views' THEN increment
            ELSE 0
        END
    ),
    shares_count = public.usage_tracking.shares_count + (
        CASE
            WHEN metric = 'shares_count' THEN increment
            ELSE 0
        END
    ),
    bookmarks_count = public.usage_tracking.bookmarks_count + (
        CASE
            WHEN metric = 'bookmarks_count' THEN increment
            ELSE 0
        END
    ),
    updated_at = NOW();
RETURN jsonb_build_object(
    'status',
    'success',
    'metric',
    metric,
    'increment',
    increment
);
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;
GRANT EXECUTE ON FUNCTION public.fn_track_usage(TEXT, INTEGER) TO authenticated;

-- =====================================================
-- MAINTENANCE: fn_prune_old_tracking_data
-- =====================================================
CREATE OR REPLACE FUNCTION public.fn_prune_old_tracking_data(
    p_retention_days INT DEFAULT 180
) RETURNS JSONB AS $$
DECLARE
    v_pruned_usage INT;
BEGIN
    DELETE FROM public.usage_tracking
    WHERE date < (CURRENT_DATE - p_retention_days);
    GET DIAGNOSTICS v_pruned_usage = ROW_COUNT;

    RETURN jsonb_build_object(
        'status', 'success',
        'pruned_usage_rows', v_pruned_usage,
        'timestamp', NOW()
    );
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;