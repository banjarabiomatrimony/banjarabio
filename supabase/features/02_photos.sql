-- Last run: 2025-02-12 — Update when re-run in Supabase SQL Editor
-- =====================================================
-- 02. PHOTOS FEATURE
-- Handles profile images and primary photo logic.
-- =====================================================

-- =====================================================
-- TABLE: photos
-- =====================================================
CREATE TABLE IF NOT EXISTS public.photos (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  profile_id UUID NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
  storage_path TEXT NOT NULL,
  public_url TEXT NOT NULL,
  semantic_label TEXT,
  is_primary BOOLEAN DEFAULT TRUE,
  is_approved BOOLEAN DEFAULT TRUE,
  uploaded_at TIMESTAMPTZ DEFAULT NOW()
);

-- =====================================================
-- INDEXES (Primary photo lookup: profile_id + is_primary)
-- =====================================================
CREATE INDEX IF NOT EXISTS idx_photos_profile_id ON public.photos(profile_id);
CREATE INDEX IF NOT EXISTS idx_photos_is_primary ON public.photos(is_primary);
CREATE INDEX IF NOT EXISTS idx_photos_profile_primary
  ON public.photos(profile_id, is_primary)
  WHERE is_primary = true;

-- =====================================================
-- RLS (ROW LEVEL SECURITY)
-- =====================================================
ALTER TABLE public.photos ENABLE ROW LEVEL SECURITY;

-- Select policy: Anyone can see photos (linked to active profiles)
DROP POLICY IF EXISTS "photos_select_public" ON public.photos;
CREATE POLICY "photos_select_public" ON public.photos FOR SELECT 
USING (true);

-- Insert/Update/Delete: Users can manage photos for their own profile
DROP POLICY IF EXISTS "photos_manage_own" ON public.photos;
CREATE POLICY "photos_manage_own" ON public.photos FOR ALL
USING (
  EXISTS (
    SELECT 1 FROM public.profiles 
    WHERE profiles.id = photos.profile_id 
    AND profiles.user_id = auth.uid()
  )
)
WITH CHECK (
  EXISTS (
    SELECT 1 FROM public.profiles 
    WHERE profiles.id = photos.profile_id 
    AND profiles.user_id = auth.uid()
  )
);

-- =====================================================
-- MASTER RPC FUNCTION: fn_manage_photos
-- =====================================================
CREATE OR REPLACE FUNCTION public.fn_manage_photos(
    action TEXT,
    payload JSONB
) RETURNS JSONB AS $$
DECLARE
    v_user_id UUID := auth.uid();
    v_profile_id UUID;
    v_photo_id UUID;
    v_result JSONB;
BEGIN
    IF v_user_id IS NULL THEN
        RAISE EXCEPTION 'Not authenticated';
    END IF;

    -- Get profile_id for the user
    SELECT id INTO v_profile_id FROM public.profiles WHERE user_id = v_user_id;
    
    IF v_profile_id IS NULL THEN
        RAISE EXCEPTION 'Profile not found';
    END IF;

    CASE action
        WHEN 'set_primary' THEN
            v_photo_id := (payload->>'photo_id')::UUID;
            
            -- Set all other photos for this profile to NOT primary
            UPDATE public.photos SET is_primary = false WHERE profile_id = v_profile_id;
            
            -- Set the target photo to primary
            UPDATE public.photos SET is_primary = true WHERE id = v_photo_id AND profile_id = v_profile_id;
            
            v_result := jsonb_build_object('status', 'success', 'message', 'Primary photo updated');

        WHEN 'delete_photo' THEN
            v_photo_id := (payload->>'photo_id')::UUID;
            
            DELETE FROM public.photos WHERE id = v_photo_id AND profile_id = v_profile_id;
            
            -- If we deleted the primary photo, set the latest remaining as primary
            IF NOT EXISTS (SELECT 1 FROM public.photos WHERE profile_id = v_profile_id AND is_primary = true) THEN
                UPDATE public.photos 
                SET is_primary = true 
                WHERE id = (SELECT id FROM public.photos WHERE profile_id = v_profile_id ORDER BY uploaded_at DESC LIMIT 1);
            END IF;

            v_result := jsonb_build_object('status', 'success', 'message', 'Photo record deleted');

        ELSE
            RAISE EXCEPTION 'Invalid action: %', action;
    END CASE;

    RETURN v_result;
EXCEPTION
    WHEN OTHERS THEN
        RETURN jsonb_build_object('status', 'error', 'message', SQLERRM);
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

GRANT EXECUTE ON FUNCTION public.fn_manage_photos(TEXT, JSONB) TO authenticated;
