# Razorpay Billing – Master Template (1 Account, N Apps)

**Purpose:** Reusable billing template for using a single Razorpay account across multiple apps. Copy this template per app and fill the placeholders.

---

## 1. App Identification

| Field | Value |
|-------|-------|
| **App Name** | `{{APP_NAME}}` |
| **Package / Bundle ID** | `{{BUNDLE_ID}}` |
| **Supabase Project Ref** | `{{SUPABASE_REF}}` |
| **Razorpay Account** | Shared (1 account for all apps) |

---

## 2. Razorpay Credentials (Shared)

| Secret | Where Used | Notes |
|--------|-------------|-------|
| **RAZORPAY_KEY_ID** | Flutter app (Checkout), Edge Function | Public; safe in env.json |
| **RAZORPAY_KEY_SECRET** | Edge Function, DB `private.razorpay_config` | Never expose in client |

**Same credentials** for all apps. Use Razorpay **Notes** and **Receipt** to identify which app and plan.

---

## 3. Payment Types (Per App)

Define all billable items for this app:

| Plan Type ID | Display Name | Amount (₹) | Amount (Paise) | Duration | Description |
|--------------|--------------|------------|----------------|----------|--------------|
| `{{PLAN_ID_1}}` | `{{PLAN_NAME_1}}` | `{{AMOUNT_1}}` | `{{PAISE_1}}` | `{{DURATION_1}}` | `{{DESC_1}}` |
| `{{PLAN_ID_2}}` | `{{PLAN_NAME_2}}` | `{{AMOUNT_2}}` | `{{PAISE_2}}` | `{{DURATION_2}}` | `{{DESC_2}}` |
| `{{PLAN_ID_3}}` | `{{PLAN_NAME_3}}` | `{{AMOUNT_3}}` | `{{PAISE_3}}` | `{{DURATION_3}}` | `{{DESC_3}}` |

**Examples:**
- `subscription_monthly` – Monthly subscription
- `subscription_yearly` – Yearly subscription  
- `one_time_unlock` – One-time feature unlock
- `biodata_unlock` – Biodata/PDF unlock (one-time)

---

## 4. Receipt & Notes Convention (Multi-App Tracking)

Use a consistent format so Razorpay Dashboard and webhooks can identify app and plan:

| Field | Format | Example |
|-------|--------|---------|
| **Receipt** | `{app_slug}_{user_id_prefix}_{timestamp}` | `banjara_a1b2c3d4_1739123456` |
| **Notes** | `user_id`, `plan_type`, `app` | `{"user_id": "uuid", "plan_type": "biodata_unlock", "app": "banjarabio"}` |

**App slug** = short identifier (e.g. `banjara`, `app2`, `app3`).

---

## 5. Backend Components (Reusable)

### 5.1 Database (Per App)

- `private.razorpay_config` – store `key_secret` (same value across apps using this account)
- `fn_process_payment` – supports `create_order`, `verify_payment`, `record_payment`, `get_history`
- `payments` table – `plan_type`, `user_id`, `razorpay_order_id`, etc.

### 5.2 Edge Function (Per App / Per Supabase Project)

- **Name:** `create-razorpay-order`
- **Secrets:** `RAZORPAY_KEY_ID`, `RAZORPAY_KEY_SECRET`
- **Input:** `{ amount, currency?, plan_type }`
- **Output:** `{ id: order_id, amount, currency, plan_type }`
- **Receipt format:** `{APP_SLUG}_{user_id_slice}_{Date.now()}`

### 5.3 Flutter Repository Pattern

- `RazorpayRepository.startPayment(planType)` 
- Calls Edge Function → Opens Checkout → On success → `verify_payment` RPC
- Store `_pendingAmount`, `_pendingPlanType` for verification payload

---

## 6. App-Specific Config (Fill Per App)

```yaml
# RAZORPAY_APP_CONFIG (add to app's config or env)
app_name: "{{APP_NAME}}"
app_slug: "{{APP_SLUG}}"           # e.g. banjara, app2
razorpay_key_id: "rzp_xxx"        # Same for all apps
razorpay_key_secret: "xxx"        # Same for all apps (server-only)

payment_types:
  - id: "{{PLAN_ID_1}}"
    name: "{{PLAN_NAME_1}}"
    amount_rupees: {{AMOUNT_1}}
    duration: "{{DURATION_1}}"
  - id: "{{PLAN_ID_2}}"
    name: "{{PLAN_NAME_2}}"
    amount_rupees: {{AMOUNT_2}}
    duration: "{{DURATION_2}}"
```

---

## 7. Checklist (Per New App)

- [ ] Copy this template → `docs/RAZORPAY_APP_{{APP_SLUG}}.md`
- [ ] Fill App Identification (Section 1)
- [ ] Fill Payment Types (Section 3)
- [ ] Set Receipt/Notes convention with app_slug (Section 4)
- [ ] Run DB migration (`09_payments_razorpay_actions.sql`)
- [ ] Insert `key_secret` into `private.razorpay_config`
- [ ] Deploy Edge Function with same Razorpay secrets
- [ ] Update Edge Function receipt prefix to `{app_slug}_`
- [ ] Add plan types to app's `PlanType` enum / config
- [ ] Add `SubscriptionConfig.getFeatures()` cases for each plan

---

## 8. Razorpay Dashboard (1 Account)

- **Subscriptions** / **Plans:** Create plans per app if needed, or use one-time orders
- **Settlements:** Single dashboard; filter by receipt prefix or notes
- **Webhooks (optional):** Use `notes.app` to route events per app

---

*Template version: 1.0 | Last updated: 2025-02*
