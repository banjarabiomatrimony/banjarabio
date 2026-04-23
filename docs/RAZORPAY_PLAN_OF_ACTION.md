# Razorpay Feature – Plan of Action

---

## Current state (what you have now)

### Original feature files (before Razorpay changes)

| # | File | Purpose |
|---|------|---------|
| 00 | 00_database_reset.sql | |
| 01 | 01_profiles.sql | |
| 02 | 02_photos.sql | |
| 03 | 03_verification.sql | |
| 04 | 04_reviewer_data.sql | |
| 05 | 05_bookmarks.sql | |
| 06 | 06_shares.sql | |
| 07 | 07_blocks_reports.sql | |
| 08 | 08_subscriptions.sql | |
| 09 | 09_payments.sql | Base payments table + fn_process_payment (record, update_status, get_history) |
| 10 | 10_admin_data.sql | Admin & security |
| 11 | 11_storage.sql | |
| 12 | 12_usage_tracking.sql | |
| 13 | 13_referrals_and_rewards.sql | |
| 14 | 14_automated_match_trigger.sql | |
| 15 | 15_chat_and_notifications.sql | |
| – | production_optimization.sql | |

### What was changed (my mistake)

1. **Removed:** `09_payments_razorpay_actions.sql` (it was the Razorpay extension of 09)
2. **Added:** `10_razorpay_billing.sql` → **conflict:** you already have `10_admin_data.sql` – two files with prefix "10"

---

## Why `09_payments_razorpay_actions.sql` was removed (explanation)

**Reason:** To make Razorpay a single, separate feature file and avoid mixing it with other payments logic.

**What went wrong:**

- `09_payments_razorpay_actions.sql` was an add-on for `09_payments.sql` (like a "09b").
- It was replaced by `10_razorpay_billing.sql` so Razorpay would be standalone.
- But `10` was already used by `10_admin_data.sql`, which created duplicate numbering and confusion.

**Correct approach:** Razorpay should stay as an extension of 09, not reuse the number 10.

---

## Proposed plan of action

### Step 1: Fix numbering (no two "10" files)

| Action | Detail |
|--------|--------|
| **Remove** | `10_razorpay_billing.sql` (wrong number) |
| **Add** | `09b_razorpay_billing.sql` – Razorpay as a clear extension of 09, no conflict with 10 |

**Naming logic:**  
- 09 = base payments  
- 09b = Razorpay extension (b for “billing”)  
- 10 = admin (unchanged)

### Step 2: Razorpay feature contents (unchanged)

- `private.razorpay_config` table  
- `pgcrypto` extension  
- Extended `fn_process_payment` with `create_order` and `verify_payment`  
- All existing logic stays; only filename changes

### Step 3: Execution order

1. `09_payments.sql`
2. `09b_razorpay_billing.sql`
3. Then 10, 11, 12, etc., as before

### Step 4: Docs update

- Update `SUPABASE_RAZORPAY_FEATURE_GUIDE.md` and other Razorpay docs to use `09b_razorpay_billing.sql` instead of `10_razorpay_billing.sql`.

### Step 5: Supabase setup (after SQL is correct)

1. Run `09b_razorpay_billing.sql` in Query Editor (after `09_payments.sql`)
2. Insert `key_secret` into `private.razorpay_config`
3. Set Supabase secrets (`RAZORPAY_KEY_ID`, `RAZORPAY_KEY_SECRET`)
4. Deploy:  
   `supabase functions deploy create-razorpay-order`

---

## Final feature layout (proposed)

```
00_database_reset.sql
01_profiles.sql
...
09_payments.sql
09b_razorpay_billing.sql   ← Razorpay only (runs after 09)
10_admin_data.sql
11_storage.sql
...
15_chat_and_notifications.sql
production_optimization.sql
```

- No conflict with 10  
- Razorpay clearly separated  
- Clear run order: 09 → 09b → 10 → …

---

## Summary

| Question | Answer |
|----------|--------|
| Why was 09_payments_razorpay_actions removed? | To consolidate Razorpay into one file, but it was put as "10" which conflicted with 10_admin_data. |
| Fix? | Recreate as `09b_razorpay_billing.sql` (Razorpay extension of 09) and remove `10_razorpay_billing.sql`. |
| What happens to 09_payments.sql? | No change; it stays as-is. |
| What happens to 10_admin_data.sql? | No change; it stays as-is. |

---

---

## ✅ Executed

- Created `09b_razorpay_billing.sql`
- Removed `10_razorpay_billing.sql`
- Updated all docs
- **Supabase secrets set** (RAZORPAY_KEY_ID, RAZORPAY_KEY_SECRET)
- **Edge Function deployed** (`create-razorpay-order`)

**You still need to do manually:**
1. Run `09b_razorpay_billing.sql` in Supabase Dashboard → SQL Editor (after 09_payments)
2. Run: `INSERT INTO private.razorpay_config (key, value) VALUES ('key_secret', 'YOUR_SECRET') ON CONFLICT (key) DO UPDATE SET value = EXCLUDED.value;`
