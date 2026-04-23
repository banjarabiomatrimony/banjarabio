# Razorpay Billing – BanjaraBio (App Instance)

**Source template:** [RAZORPAY_BILLING_MASTER_TEMPLATE.md](./RAZORPAY_BILLING_MASTER_TEMPLATE.md)

---

## 1. App Identification

| Field | Value |
|-------|-------|
| **App Name** | BanjaraBio |
| **Package / Bundle ID** | `com.avishio.banjarabio` |
| **Supabase Project Ref** | *(your project ref)* |
| **App Slug** | `banjara` |
| **Razorpay Account** | Shared (1 account for all apps) |

---

## 2. Payment Types (BanjaraBio)

| Plan Type ID | Display Name | Amount (₹) | Amount (Paise) | Duration | Description |
|--------------|--------------|------------|----------------|----------|-------------|
| `biodata_unlock` | Biodata Unlock | 199 | 19900 | one-time | One-time PDF/biodata unlock |
| `subscription_monthly` | Monthly | TBD | TBD | monthly | *(add when needed)* |
| `subscription_yearly` | Yearly | TBD | TBD | yearly | *(add when needed)* |

---

## 3. Receipt & Notes (BanjaraBio)

| Field | Format | Example |
|-------|--------|---------|
| **Receipt** | `banjara_{user_id_slice}_{timestamp}` | `banjara_a1b2c3d4_1739123456` |
| **Notes** | `{"user_id": "...", "plan_type": "biodata_unlock", "app": "banjarabio"}` | |

---

## 4. Current Implementation

- **Supabase feature:** `09b_razorpay_billing.sql` (run after `09_payments.sql`)
- **Edge Function:** `create-razorpay-order` – receipt prefix `banjara_`
- **RPC:** `fn_process_payment` with `create_order`, `verify_payment`
- **Plan config:** `SubscriptionConfig` → `biodata_unlock` @ ₹199
- **Setup guide:** [RAZORPAY_SETUP.md](./RAZORPAY_SETUP.md)

---

*Instance of RAZORPAY_BILLING_MASTER_TEMPLATE for BanjaraBio*
