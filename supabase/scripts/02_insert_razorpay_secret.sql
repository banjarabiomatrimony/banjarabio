-- Run this AFTER the migration. Replace YOUR_RAZORPAY_KEY_SECRET with value from assets/env.json
-- Supabase Dashboard: SQL Editor → New query → Paste & run

INSERT INTO private.razorpay_config (key, value)
VALUES ('key_secret', 'YOUR_RAZORPAY_KEY_SECRET')
ON CONFLICT (key) DO UPDATE SET value = EXCLUDED.value, updated_at = NOW();
