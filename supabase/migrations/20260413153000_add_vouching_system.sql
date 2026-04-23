-- Migration: Add Community Vouching System
-- Created: 2026-04-13
-- 1. Create the vouches table
CREATE TABLE IF NOT EXISTS vouches (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  vouch_id UUID NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
  vouched_id UUID NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
  relation TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  UNIQUE(vouch_id, vouched_id)
);
-- 2. Add columns to profiles
ALTER TABLE profiles
ADD COLUMN IF NOT EXISTS vouch_count INTEGER DEFAULT 0;
ALTER TABLE profiles
ADD COLUMN IF NOT EXISTS is_community_trusted BOOLEAN DEFAULT FALSE;
-- 3. Create/Update the automation trigger
CREATE OR REPLACE FUNCTION fn_on_vouch_change() RETURNS TRIGGER AS $$ BEGIN IF (TG_OP = 'INSERT') THEN
UPDATE profiles
SET vouch_count = vouch_count + 1,
  is_community_trusted = (vouch_count + 1 >= 5)
WHERE id = NEW.vouched_id;
ELSIF (TG_OP = 'DELETE') THEN
UPDATE profiles
SET vouch_count = vouch_count - 1,
  is_community_trusted = (vouch_count - 1 >= 5)
WHERE id = OLD.vouched_id;
END IF;
RETURN NULL;
END;
$$ LANGUAGE plpgsql;
DROP TRIGGER IF EXISTS tr_on_vouch_change ON vouches;
CREATE TRIGGER tr_on_vouch_change
AFTER
INSERT
  OR DELETE ON vouches FOR EACH ROW EXECUTE FUNCTION fn_on_vouch_change();