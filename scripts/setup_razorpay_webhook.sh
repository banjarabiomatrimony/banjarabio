#!/bin/bash
# Razorpay Webhook Setup: SQL, secrets, deploy
# Run AFTER: (1) Razorpay Dashboard → Webhooks → Add webhook, (2) Copy the webhook secret
#
# Webhook URL: https://icvmuktbpxglsmyvebwf.supabase.co/functions/v1/razorpay-webhook
# Event: payment.captured
#
# Usage: ./scripts/setup_razorpay_webhook.sh [WEBHOOK_SECRET]

set -e
cd "$(dirname "$0")/.."

WEBHOOK_SECRET="${1:-}"

# Read from env.json if not passed as argument
if [ -z "$WEBHOOK_SECRET" ] && [ -f assets/env.json ]; then
  WEBHOOK_SECRET=$(python3 -c "import json; print(json.load(open('assets/env.json')).get('RAZORPAY_WEBHOOK_SECRET',''))" 2>/dev/null || true)
fi

echo "=== Razorpay Webhook Setup ==="
echo ""

# Step 1: SQL
echo "1. Run supabase/features/09c_razorpay_webhook.sql in Supabase SQL Editor"
echo "   Dashboard → SQL Editor → New query → Paste → Run"
echo ""

# Step 2: Secret
if [ -z "$WEBHOOK_SECRET" ]; then
  echo "2. Webhook secret required."
  echo "   Add to assets/env.json: RAZORPAY_WEBHOOK_SECRET"
  echo "   Or: Razorpay Dashboard → Webhooks → Your webhook → Secret"
  echo ""
  read -p "   Paste RAZORPAY_WEBHOOK_SECRET: " WEBHOOK_SECRET
  if [ -z "$WEBHOOK_SECRET" ]; then
    echo "ERROR: Webhook secret cannot be empty"
    exit 1
  fi
else
  echo "2. Using secret from env.json"
fi

echo ""
if command -v supabase &>/dev/null; then
  echo "3. Setting secret and deploying razorpay-webhook..."
  supabase secrets set RAZORPAY_WEBHOOK_SECRET="$WEBHOOK_SECRET"
  supabase functions deploy razorpay-webhook
  echo ""
  echo "=== Done ==="
  echo "Webhook is live. Test with a payment - if client callback fails (e.g. UPI),"
  echo "Razorpay will still call the webhook and unlock the PDF. User can tap Refresh."
else
  echo "Supabase CLI not found. Run manually:"
  echo "  supabase secrets set RAZORPAY_WEBHOOK_SECRET=\"<your-secret>\""
  echo "  supabase functions deploy razorpay-webhook"
  exit 1
fi
