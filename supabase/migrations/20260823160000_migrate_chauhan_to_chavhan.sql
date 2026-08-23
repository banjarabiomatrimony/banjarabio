-- ⚔️ [BanjaraBio] Standardize Chauhan surname and gotra spelling to Chavhan
-- 1. Backfill all existing profile rows in profiles table

-- Backfill surname
UPDATE profiles
SET surname = 'Chavhan'
WHERE LOWER(TRIM(surname)) = 'chauhan';

-- Backfill gotra
UPDATE profiles
SET gotra = REPLACE(gotra, 'Chauhan', 'Chavhan')
WHERE gotra ILIKE '%Chauhan%';
