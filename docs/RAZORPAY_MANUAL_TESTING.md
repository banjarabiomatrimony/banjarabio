# Razorpay Manual Testing Guide

Filter logs with `[RAZORPAY]` for payment flow debugging.

---

## Debug Log Prefix

All payment-related logs use the prefix **`[RAZORPAY]`**. Run in debug mode and watch the console:

```text
[RAZORPAY] startPayment > planType=biodata_unlock
[RAZORPAY] startPayment > amount=19900 paise (199.0 INR)
[RAZORPAY] _createOrderRpc > Edge Function SUCCESS | orderId=order_xxx
[RAZORPAY] _openCheckout > Opening Razorpay SDK
[RAZORPAY] _handlePaymentSuccess > orderId=... paymentId=...
[RAZORPAY] _handlePaymentSuccess > verify_payment SUCCESS
```

---

## Test Flow 1: Biodata PDF Unlock (₹199)

| Step | Action | Expected logs | Pass? |
|------|--------|----------------|-------|
| 1 | Open Biodata PDF screen (locked) | – | ☐ |
| 2 | Tap "Pay ₹199 to Unlock Full PDF" | `[RAZORPAY] BiodataPdfScreenRiverpod > User tapped Pay to unlock` | ☐ |
| 3 | – | `[RAZORPAY] startPayment > planType=biodata_unlock` | ☐ |
| 4 | – | `[RAZORPAY] startPayment > amount=19900 paise` | ☐ |
| 5 | Razorpay checkout opens | `[RAZORPAY] _openCheckout > Opening Razorpay SDK` | ☐ |
| 6 | Pay with test card (4111 1111 1111 1111) | – | ☐ |
| 7 | Payment success | `[RAZORPAY] _handlePaymentSuccess > verify_payment SUCCESS` | ☐ |
| 8 | PDF unlocks | `[RAZORPAY] BiodataPdfScreenRiverpod > Payment SUCCESS` | ☐ |

**Error case:** Cancel Razorpay → `[RAZORPAY] _handlePaymentError > code=2 | message=...`

---

## Test Flow 2: Biodata Editor "Unlock now"

| Step | Action | Expected logs | Pass? |
|------|--------|----------------|-------|
| 1 | Open Biodata Editor, select premium template | – | ☐ |
| 2 | Tap "Unlock now" | `[RAZORPAY] BiodataEditorScreen > User tapped Unlock now` | ☐ |
| 3 | Complete payment | `[RAZORPAY] _handlePaymentSuccess > verify_payment SUCCESS` | ☐ |
| 4 | Toast "Payment successful! Templates unlocked." | `[RAZORPAY] BiodataEditorScreen > Payment SUCCESS` | ☐ |

---

## Test Flow 3: Subscription Screen

| Step | Action | Expected logs | Pass? |
|------|--------|----------------|-------|
| 1 | Open Subscription screen | – | ☐ |
| 2 | Tap a plan (Silver/Gold/Platinum) | `[RAZORPAY] SubscriptionScreen > User tapped upgrade | planType=silver` | ☐ |
| 3 | Complete payment | `[RAZORPAY] _handlePaymentSuccess > verify_payment SUCCESS` | ☐ |
| 4 | Toast + navigate back | `[RAZORPAY] SubscriptionScreen > Payment SUCCESS` | ☐ |

---

## Failure Diagnostics

| Log pattern | Likely cause |
|-------------|--------------|
| `createOrder FAILED` | Edge Function not deployed, wrong secrets, or network |
| `verify_payment FAILED` | Key Secret mismatch in `private.razorpay_config` |
| `_handlePaymentError > code=2` | User cancelled |
| `User not authenticated` | Not logged in |
| `A payment is already in progress` | Overlapping payment attempts |

---

## Running Tests

```bash
# Unit + widget tests
flutter test

# Specific Razorpay tests
flutter test test/shared/billing/razorpay_billing_constants_test.dart
flutter test test/core/config/banjara_billing_config_test.dart
flutter test test/features/payment/widgets/biodata_pdf_screen_riverpod_test.dart
```
