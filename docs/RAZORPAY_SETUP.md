# Razorpay Payment Setup (BanjaraBio)

Configures Razorpay for **biodata unlock** (₹199) and **subscription** flows. Uses shared billing template (`lib/shared/billing/`).

## Prerequisites

- Razorpay account (Key ID + Key Secret)
- Supabase project
- `lib/shared/billing` + `BanjaraBillingConfig` registered in `main.dart`

## 1. App Configuration

### env.json

Copy `assets/env.json.example` → `assets/env.json`, then fill in your keys:

```bash
cp assets/env.json.example assets/env.json
# Edit assets/env.json with your RAZORPAY_KEY_ID and RAZORPAY_KEY_SECRET
```

**Important:** `env.json` is in `.gitignore` – never commit real secrets. Key ID: client (Razorpay Checkout). Key Secret: **server only** (Edge Function, DB).

### main.dart

```dart
await AppSupabaseClient.initialize();
RazorpayBillingRegistry.register(BanjaraBillingConfig());
```

## 2. Database

**Your workflow:** Run in Supabase Dashboard → SQL Editor (after `09_payments.sql`):
- `supabase/features/09b_razorpay_billing.sql`

Then add Key Secret (from `assets/env.json` → `RAZORPAY_KEY_SECRET`, or run `./scripts/setup_razorpay.sh`):

```sql
-- See supabase/scripts/02_insert_razorpay_secret.sql
INSERT INTO private.razorpay_config (key, value)
VALUES ('key_secret', 'YOUR_RAZORPAY_KEY_SECRET')
ON CONFLICT (key) DO UPDATE SET value = EXCLUDED.value, updated_at = NOW();
```

## 3. Edge Function

```bash
supabase secrets set RAZORPAY_KEY_ID="rzp_test_xxxxx"
supabase secrets set RAZORPAY_KEY_SECRET="your_secret"
supabase functions deploy create-razorpay-order --no-verify-jwt
```

**Note:** `--no-verify-jwt` bypasses gateway JWT verification so the request reaches the function. The function still validates auth via `getUser()` and returns 401 if unauthenticated. Use `./scripts/setup_razorpay.sh` to deploy with the correct flags.

**Important:** Secrets are for **Edge Functions** (Project Settings → Edge Functions → Secrets, or `supabase secrets set`). Do not confuse with Vault Secrets.

Receipt format: `{app_slug}_{user_id_slice}_{timestamp}` (e.g. `banjara_a1b2c3d4_1739...`).

### 3.1 Webhook (recommended – fallback when client callback fails)

If the client callback does not fire (e.g. Android + UPI), the webhook records the payment and unlocks the PDF. User can tap **Refresh** in the SnackBar to load the updated state.

**One-liner (after SQL + Dashboard setup):**
```bash
./scripts/setup_razorpay_webhook.sh
# Or with secret: ./scripts/setup_razorpay_webhook.sh "your_webhook_secret"
```

**Manual steps:**
1. Run `supabase/features/09c_razorpay_webhook.sql` in Supabase SQL Editor
2. Razorpay Dashboard → Webhooks → Add webhook:
   - URL: `https://icvmuktbpxglsmyvebwf.supabase.co/functions/v1/razorpay-webhook` (replace project ref if different)
   - Event: `payment.captured`
   - Copy the **webhook secret** shown after creating
3. Supabase secrets and deploy:
   ```bash
   supabase secrets set RAZORPAY_WEBHOOK_SECRET="your_webhook_secret"
   supabase functions deploy razorpay-webhook
   ```

## 4. Flow

| Step | Component | Action |
|------|-----------|--------|
| 1 | Flutter → Edge Function | Create order (amount, plan_type, app_slug) |
| 2 | Flutter → Razorpay SDK | Open checkout (order_id + amount) |
| 3 | User pays | Razorpay returns order_id, payment_id, signature |
| 4 | Flutter → RPC `verify_payment` | Verify HMAC, insert payment, set `is_pdf_unlocked` |

## 5. App Entry Points

- **Biodata unlock**: `BiodataPdfScreenRiverpod`, `BiodataEditorScreen` → `RazorpayRepository().startPayment(PlanType.biodata_unlock)`
- **Subscription**: `SubscriptionScreen` → `RazorpayRepository().startPayment(planType)`

## 6. Troubleshooting

| Error | Fix |
|-------|-----|
| `Invalid action` / `sync_pdf_unlock` → `Invalid action` | Run `09b_razorpay_billing.sql` in SQL Editor (full file) so `fn_process_payment` includes `sync_pdf_unlock`, or run `supabase db push` |
| `Razorpay secret not configured` | INSERT into `private.razorpay_config` |
| `Failed to create order` | Deploy Edge Function, set secrets |
| `Invalid payment signature` | Same Key Secret in `razorpay_config` and Razorpay Dashboard |
| `Razorpay billing config not registered` | Call `RazorpayBillingRegistry.register()` in main.dart |
| `RPC fallback SUCCESS \| amount_only` | Edge Function not deployed or secrets missing. Check logs for `Edge Function response \| status=`. Deploy: `supabase functions deploy create-razorpay-order --no-verify-jwt` |
| `401 Invalid JWT` on Edge Function | Gateway rejects JWT before function. Redeploy with `--no-verify-jwt`: `supabase functions deploy create-razorpay-order --no-verify-jwt` |
| Payment succeeds but PDF stays locked | Client callback may not fire (Android + UPI). Deploy webhook (3.1) and tap **Refresh** after payment |

## See Also

- [RAZORPAY_MANUAL_STEPS.md](./RAZORPAY_MANUAL_STEPS.md) – **Step-by-step manual setup** (run after code changes)
- [RAZORPAY_BILLING_MASTER_TEMPLATE.md](./RAZORPAY_BILLING_MASTER_TEMPLATE.md) – Reusable template for N apps
- [RAZORPAY_APP_BANJARABIO.md](./RAZORPAY_APP_BANJARABIO.md) – BanjaraBio instance
