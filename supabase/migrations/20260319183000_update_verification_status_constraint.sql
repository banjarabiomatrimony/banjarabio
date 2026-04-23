-- 20260319183000_update_verification_status_constraint.sql
-- Update verification_requests status constraint to allow 'on_hold'

-- 1. Drop the old constraint
ALTER TABLE public.verification_requests 
DROP CONSTRAINT IF EXISTS verification_requests_status_check;

-- 2. Add the new constraint with 'on_hold'
ALTER TABLE public.verification_requests 
ADD CONSTRAINT verification_requests_status_check 
CHECK (status IN ('pending', 'approved', 'rejected', 'on_hold'));

-- 3. Update comments/notice
COMMENT ON COLUMN public.verification_requests.status IS 'Status of the verification: pending, approved, rejected, or on_hold';

DO $$ 
BEGIN 
    RAISE NOTICE 'Verification status constraint updated to include on_hold.'; 
END $$;
