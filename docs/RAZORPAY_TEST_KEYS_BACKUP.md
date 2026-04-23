# Razorpay Test Keys (Backup)

> ⚠️ These are TEST/SANDBOX keys. Do NOT use in production.

## Test Keys
```
RAZORPAY_KEY_ID:     rzp_test_RlAOuGGXSxvL66
RAZORPAY_KEY_SECRET: 2cwRmmNzqj3Bzpn0muOgO62U
```

## Live Keys (currently in use)
```
RAZORPAY_KEY_ID:     rzp_live_Rlw34MEmvHMQte
RAZORPAY_KEY_SECRET: HYNmEFQ8GQc1CwwqnL6P121g
```

## Switching Back to Test Mode
If you need to switch back to test keys for development:
1. Replace keys in `assets/env.json`
2. Run: `supabase secrets set RAZORPAY_KEY_ID="rzp_test_RlAOuGGXSxvL66" RAZORPAY_KEY_SECRET="2cwRmmNzqj3Bzpn0muOgO62U"`
3. Update DB: `UPDATE private.razorpay_config SET value = '2cwRmmNzqj3Bzpn0muOgO62U', updated_at = NOW() WHERE key = 'key_secret';`
