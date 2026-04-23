# Supabase Razorpay Feature – Clear Guide

Your workflow: **Update `supabase/features/` → Run in Supabase Query Editor**

---

## 1. Feature Files Layout

| File | Purpose | Runs after |
|------|---------|------------|
| `09_payments.sql` | Base: `payments` table, basic `fn_process_payment` (record_payment, update_status, get_history) | 08_subscriptions |
| **`09b_razorpay_billing.sql`** | **Razorpay only:** `private.razorpay_config`, extends `fn_process_payment` with `create_order` + `verify_payment` | 09_payments |

---

## 2. What `09b_razorpay_billing.sql` Contains (Razorpay-only)

- `CREATE EXTENSION IF NOT EXISTS pgcrypto` (for HMAC)
- `CREATE SCHEMA/TABLE private.razorpay_config` (stores key_secret)
- `CREATE OR REPLACE FUNCTION fn_process_payment` with:
  - Original actions: `record_payment`, `update_status`, `get_history`
  - Razorpay actions: `create_order`, `verify_payment`
- `GRANT EXECUTE` for authenticated

Nothing from other features is touched; only Razorpay-related schema and RPC changes.

---

## 3. Execution Order (Query Editor)

Run in this order:

1. `09_payments.sql` (creates `payments` table and base `fn_process_payment`)
2. `09b_razorpay_billing.sql` (adds Razorpay config and extends `fn_process_payment`)

If you run all features in numeric order, this order is correct.

---

## 4. After Running `09b_razorpay_billing.sql`

**No secrets are in the SQL file** (security). Insert your Razorpay Key Secret once:

- **Option A:** Run `./scripts/setup_razorpay.sh` (reads from `assets/env.json`)
- **Option B:** Manual – `supabase/scripts/02_insert_razorpay_secret.sql` (replace placeholder with value from `assets/env.json` → `RAZORPAY_KEY_SECRET`)

---

## 5. Edge Function (Separate from Features)

Features = SQL only. Edge Function = Deno/TypeScript.

- **File:** `supabase/functions/create-razorpay-order/index.ts`
- **Deploy:** `supabase functions deploy create-razorpay-order`
- **Secrets:** Set `RAZORPAY_KEY_ID` and `RAZORPAY_KEY_SECRET` in Supabase Dashboard (Project Settings → Edge Functions)

---

## 6. How to Apply (Your Workflow)

1. Open **Supabase Dashboard** → **SQL Editor** → **New query**
2. Copy all content from `supabase/features/09b_razorpay_billing.sql`
3. Paste and run
4. Run the `INSERT INTO private.razorpay_config` (section 4 above)

---

## 7. Summary

1. Razorpay logic lives in **`09b_razorpay_billing.sql`** (features).
2. Run **`09_payments.sql`** first, then **`09b_razorpay_billing.sql`**.
3. Insert `key_secret` into `private.razorpay_config` once.
4. Deploy Edge Function and set its secrets.
