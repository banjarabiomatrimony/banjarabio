# Razorpay – Run Steps

## Status

| Step | Status | Action |
|------|--------|--------|
| 1. env.json | ✅ Done | Has RAZORPAY_KEY_ID, RAZORPAY_KEY_SECRET |
| 2. main.dart | ✅ Done | RazorpayBillingRegistry.register(BanjaraBillingConfig()) |
| 3. DB migration | ⏳ Manual | Run SQL below |
| 4. Insert key_secret | ⏳ Manual | Run SQL below |
| 5. Supabase secrets | ⏳ Manual | Dashboard or CLI |
| 6. Edge Function deploy | ⏳ Manual | Dashboard or CLI |

---

## Run in Supabase Dashboard (SQL Editor)

**Step 3 + 4:** Copy and run in order.

### Migration (creates razorpay_config, fn_process_payment)

```sql
-- From supabase/features/09b_razorpay_billing.sql
```

Paste the full contents of that file:

1. **Supabase Dashboard** → **SQL Editor** → **New query**
2. Open `supabase/features/09b_razorpay_billing.sql`
3. Copy all, paste, run (run `09_payments.sql` first if not already done)

### Insert key_secret (uses your secret from env.json)

```sql
-- Replace YOUR_SECRET with RAZORPAY_KEY_SECRET from assets/env.json
INSERT INTO private.razorpay_config (key, value)
VALUES ('key_secret', 'YOUR_SECRET')
ON CONFLICT (key) DO UPDATE SET value = EXCLUDED.value, updated_at = NOW();
```

---

## Supabase CLI (if installed)

```bash
# Link project first
supabase link --project-ref icvmuktbpxglsmyvebwf

# DB migration
supabase db push

# Secrets (from env.json)
supabase secrets set RAZORPAY_KEY_ID="<from env.json>" RAZORPAY_KEY_SECRET="<from env.json>"

# Deploy Edge Function
supabase functions deploy create-razorpay-order
```

---

## Or run the helper script

```bash
./scripts/setup_razorpay.sh
```

This prints the SQL to run and, if Supabase CLI is installed, runs migration, secrets, and deploy.
