# Razorpay 100% Setup – Manual Steps

Follow these steps **in order** to finish Razorpay configuration. All code changes are done; you only need to run migrations and deploy.

---

## Step 1: Run SQL migrations in Supabase

**Option A – Supabase CLI (recommended):**
```bash
supabase db push
```
This applies `supabase/migrations/` including `sync_pdf_unlock` for `fn_process_payment`. **Requires** `09_payments` and `09b_razorpay_billing.sql` base already applied (run Option B first if this is a fresh DB).

**Option B – Manual SQL Editor:**
1. Open **Supabase Dashboard** → **SQL Editor** → **New query**
2. Run these files **in order** (if not already applied):
   - `supabase/features/09_payments.sql` (creates `payments` table with `app_slug`)
   - `supabase/features/09b_razorpay_billing.sql` (adds `app_slug` column, updates `fn_process_payment` with `create_order`, `verify_payment`, **`sync_pdf_unlock`**)
   - `supabase/features/09c_razorpay_webhook.sql` (updates `fn_webhook_razorpay_payment_captured` with `p_app_slug`)

3. **Insert Razorpay secret** (if not done):
   ```sql
   INSERT INTO private.razorpay_config (key, value)
   VALUES ('key_secret', 'YOUR_RAZORPAY_KEY_SECRET')
   ON CONFLICT (key) DO UPDATE SET value = EXCLUDED.value, updated_at = NOW();
   ```
   Replace `YOUR_RAZORPAY_KEY_SECRET` with the value from `assets/env.json`.

---

## Step 2: Configure `assets/env.json`

Ensure `assets/env.json` contains:

```json
{
  "RAZORPAY_KEY_ID": "rzp_test_xxxxx",
  "RAZORPAY_KEY_SECRET": "your_key_secret",
  "RAZORPAY_WEBHOOK_SECRET": "your_webhook_secret"
}
```

- **RAZORPAY_KEY_ID**: Used by the app for Razorpay Checkout
- **RAZORPAY_KEY_SECRET**: Used by Edge Functions and DB for verification
- **RAZORPAY_WEBHOOK_SECRET**: From Razorpay Dashboard after creating the webhook

---

## Step 3: Set Supabase secrets

From project root:

```bash
supabase secrets set RAZORPAY_KEY_ID="<from env.json>"
supabase secrets set RAZORPAY_KEY_SECRET="<from env.json>"
supabase secrets set RAZORPAY_WEBHOOK_SECRET="<from env.json>"
```

Or run:

```bash
./scripts/setup_razorpay.sh
./scripts/setup_razorpay_webhook.sh
```

---

## Step 4: Deploy Edge Functions

```bash
# create-razorpay-order (order creation)
supabase functions deploy create-razorpay-order --no-verify-jwt

# razorpay-webhook (fallback when client callback fails)
supabase functions deploy razorpay-webhook
```

`--no-verify-jwt` bypasses gateway JWT checks; the function still checks auth via `getUser()`.

---

## Step 5: Create Razorpay webhook (Dashboard)

1. Open **Razorpay Dashboard** → **Webhooks** → **Add webhook**
2. **URL**: `https://<project-ref>.supabase.co/functions/v1/razorpay-webhook`
   - Replace `<project-ref>` with your Supabase project ref (e.g. `icvmuktbpxglsmyvebwf`)
3. **Event**: `payment.captured`
4. Create and copy the **Webhook secret**
5. Add to Supabase secrets and deploy:
   ```bash
   supabase secrets set RAZORPAY_WEBHOOK_SECRET="<from step 4>"
   supabase functions deploy razorpay-webhook
   ```

---

## Step 6: Verify setup

1. **DB**: Run `SELECT * FROM private.razorpay_config WHERE key = 'key_secret';` – should return a row.
2. **Edge Function**: Run `./scripts/setup_razorpay.sh` and confirm it completes.
3. **App**: Run a test payment (biodata unlock). After payment, tap **Refresh** if the client callback fails (e.g. UPI), since the webhook will record the payment.

---

## Quick checklist

| Check | Command / Action |
|-------|------------------|
| `razorpay_config` has secret | `SELECT * FROM private.razorpay_config;` |
| `payments` has `app_slug` column | `\d payments` |
| `fn_webhook_razorpay_payment_captured` has `p_app_slug` | `\df fn_webhook_razorpay_payment_captured` |
| Edge Function deployed | `supabase functions list` |
| Webhook secret set | `supabase secrets list` (or Dashboard → Edge Functions → Secrets) |
| Webhook created in Razorpay | Razorpay Dashboard → Webhooks |

---

## Troubleshooting

| Error | Fix |
|-------|-----|
| `Razorpay secret not configured` | Run INSERT into `private.razorpay_config` (Step 1) |
| `401 Invalid JWT` on Edge Function | Redeploy with `--no-verify-jwt` |
| `Failed to create order` | Deploy Edge Function, set secrets |
| `Invalid payment signature` | Same Key Secret in `razorpay_config` and Razorpay Dashboard |
| Payment succeeds but PDF locked | Client callback may not fire (Android/UPI). Deploy webhook and tap Refresh |
| `sync_pdf_unlock` → `Invalid action` | Run `09b_razorpay_billing.sql` in SQL Editor (full file) so `fn_process_payment` includes `sync_pdf_unlock`, or run `supabase db push` |
| `Order missing user_id` in webhook | Order was created without `notes.user_id`; ensure Edge Function is used for order creation |

---

## One-liner (after SQL + Dashboard webhook)

```bash
./scripts/setup_razorpay.sh && ./scripts/setup_razorpay_webhook.sh
```
