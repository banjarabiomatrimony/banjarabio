# Supabase Query Editor – Ready-to-Run Checklist

## 📅 Last run timestamp (per file)

Every `.sql` file has a **`Last run: YYYY-MM-DD`** comment at the top. When you run a query in the Supabase SQL Editor:

1. Update that date (and time if you want) after re-running.
2. This helps when you have 50+ saved queries: you can tell which version is current.
3. Makes it obvious when you changed and re-ran a specific file.

Example: `-- Last run: 2025-02-12 — Update when re-run in Supabase SQL Editor`

## ✅ All files are idempotent (safe to re-run)

| File | Idempotency | Notes |
|------|-------------|-------|
| 01–03 | ✅ | CREATE IF NOT EXISTS, DROP IF EXISTS, CREATE OR REPLACE |
| 04 | ✅ | ON CONFLICT DO UPDATE; run **after** 08 |
| 05–15 | ✅ | Same pattern |
| production_optimization | ✅ | CREATE INDEX IF NOT EXISTS, ANALYZE |

## ⚠️ Do NOT run

- **00_database_reset.sql** – Deletes all data. Only for full reset.

## Run order (copy-paste)

```
01_profiles.sql
02_photos.sql
03_verification.sql
05_bookmarks.sql
06_shares.sql
07_blocks_reports.sql
08_subscriptions.sql
04_reviewer_data.sql
09_payments.sql
09b_razorpay_billing.sql
09c_razorpay_webhook.sql
10_admin_data.sql
11_storage.sql
12_usage_tracking.sql
13_referrals_and_rewards.sql
14_automated_match_trigger.sql
15_chat_and_notifications.sql
production_optimization.sql
```

Then run (replace secret):

```sql
INSERT INTO private.razorpay_config (key, value) 
VALUES ('key_secret', 'your_razorpay_key_secret')
ON CONFLICT (key) DO UPDATE SET value = EXCLUDED.value, updated_at = NOW();
```
