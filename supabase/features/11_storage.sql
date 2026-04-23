-- Last run: 2025-02-13 — Update when re-run in Supabase SQL Editor
-- =====================================================
-- 11. STORAGE FEATURE
-- Handles bucket policies for media management.
-- =====================================================

-- =====================================================
-- INSTRUCTIONS (Run in Storage Bucket Settings)
-- =====================================================
-- 1. Create Bucket: 'profile-photos' (Public: YES)
-- 2. Create Bucket: 'verification-docs' (Public: NO)

-- =====================================================
-- STORAGE POLICIES
-- =====================================================

-- Public Read for profile-photos
DROP POLICY IF EXISTS "Public Read" ON storage.objects;
CREATE POLICY "Public Read" ON storage.objects FOR SELECT USING (bucket_id = 'profile-photos');

-- Authenticated Upload to own folder
DROP POLICY IF EXISTS "Own Folder Upload" ON storage.objects;
CREATE POLICY "Own Folder Upload" ON storage.objects FOR INSERT WITH CHECK (
  bucket_id = 'profile-photos' 
  AND auth.role() = 'authenticated'
  AND (storage.foldername(name))[1] = auth.uid()::text
);

-- Own Folder Management (Update/Delete)
DROP POLICY IF EXISTS "Own Folder Manage" ON storage.objects;
CREATE POLICY "Own Folder Manage" ON storage.objects FOR ALL USING (
  bucket_id = 'profile-photos' 
  AND (storage.foldername(name))[1] = auth.uid()::text
);

-- =====================================================
-- verification-docs (Private: ID proofs, selfies, video bios)
-- =====================================================

-- Authenticated upload to own folder only (path: userId/...)
DROP POLICY IF EXISTS "Verification Docs Upload" ON storage.objects;
CREATE POLICY "Verification Docs Upload" ON storage.objects
  FOR INSERT WITH CHECK (
    bucket_id = 'verification-docs'
    AND auth.role() = 'authenticated'
    AND (storage.foldername(name))[1] = auth.uid()::text
  );

-- Users read own; admins read all (for getSignedUrl in admin dashboard)
DROP POLICY IF EXISTS "Verification Docs Read" ON storage.objects;
CREATE POLICY "Verification Docs Read" ON storage.objects
  FOR SELECT USING (
    bucket_id = 'verification-docs'
    AND (
      (storage.foldername(name))[1] = auth.uid()::text
      OR public.fn_is_admin(auth.uid())
    )
  );
