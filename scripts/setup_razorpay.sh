#!/bin/bash
# Razorpay setup: DB migration, secrets, Edge Function deploy
# Run from project root. Requires: supabase CLI, assets/env.json

set -e
cd "$(dirname "$0")/.."

echo "=== 1. env.json ==="
if [ ! -f assets/env.json ]; then
  echo "ERROR: assets/env.json not found"
  exit 1
fi
# Parse minified or pretty-printed env.json
KEY_ID=$(python3 -c "import json; print(json.load(open('assets/env.json')).get('RAZORPAY_KEY_ID',''))" 2>/dev/null || true)
KEY_SECRET=$(python3 -c "import json; print(json.load(open('assets/env.json')).get('RAZORPAY_KEY_SECRET',''))" 2>/dev/null || true)
if [ -z "$KEY_ID" ] || [ -z "$KEY_SECRET" ]; then
  echo "ERROR: RAZORPAY_KEY_ID or RAZORPAY_KEY_SECRET missing in env.json"
  exit 1
fi
echo "Found Razorpay keys in env.json"

echo ""
echo "=== 2. Razorpay features (09b, 09c) ==="
echo "Run in Supabase Dashboard → SQL Editor (after 09_payments.sql):"
echo "  supabase/features/09b_razorpay_billing.sql"
echo "  supabase/features/09c_razorpay_webhook.sql  (for webhook fallback)"
if command -v supabase &>/dev/null; then
  echo "Note: supabase db push uses supabase/migrations/. This project uses supabase/features/ + Query Editor."
  echo "Copy the feature file content and run in Query Editor."
else
  echo "Supabase CLI not found. Run feature manually:"
  echo "  - Supabase Dashboard → SQL Editor"
  echo "  - Copy/paste from supabase/features/09b_razorpay_billing.sql (after 09_payments)"
fi

echo ""
echo "=== 3. Insert key_secret into private.razorpay_config ==="
echo "Run this SQL in Supabase Dashboard → SQL Editor:"
echo ""
echo "INSERT INTO private.razorpay_config (key, value)"
echo "VALUES ('key_secret', '$KEY_SECRET')"
echo "ON CONFLICT (key) DO UPDATE SET value = EXCLUDED.value, updated_at = NOW();"
echo ""

if command -v supabase &>/dev/null; then
  echo "Attempting to run via supabase db execute..."
  supabase db execute "INSERT INTO private.razorpay_config (key, value) VALUES ('key_secret', '$KEY_SECRET') ON CONFLICT (key) DO UPDATE SET value = EXCLUDED.value, updated_at = NOW();" 2>/dev/null && echo "Inserted." || echo "Run the SQL above manually in Dashboard."
fi

echo ""
echo "=== 4. Supabase secrets ==="
if command -v supabase &>/dev/null; then
  supabase secrets set RAZORPAY_KEY_ID="$KEY_ID" RAZORPAY_KEY_SECRET="$KEY_SECRET"
  echo "Secrets set"
else
  echo "Supabase CLI not found. Set secrets manually in Dashboard → Project Settings → Edge Functions"
fi

echo ""
echo "=== 5. Deploy Edge Functions ==="
if command -v supabase &>/dev/null; then
  supabase functions deploy create-razorpay-order --no-verify-jwt
  echo "create-razorpay-order deployed (verify_jwt=false for gateway)"
  echo ""
  echo "=== 6. Webhook (recommended for Android/UPI reliability) ==="
  echo "Run: ./scripts/setup_razorpay_webhook.sh"
  echo "  - Requires: 09c_razorpay_webhook.sql run in SQL Editor"
  echo "  - Requires: Webhook created in Razorpay Dashboard (payment.captured)"
  echo "  - URL: https://icvmuktbpxglsmyvebwf.supabase.co/functions/v1/razorpay-webhook"
else
  echo "Supabase CLI not found. Deploy via: supabase functions deploy create-razorpay-order --no-verify-jwt"
fi

echo ""
echo "=== Done ==="
echo "main.dart already has RazorpayBillingRegistry.register(BanjaraBillingConfig())"
