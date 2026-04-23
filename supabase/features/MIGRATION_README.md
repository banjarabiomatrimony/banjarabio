# Supabase → Backend Migration Guide

This schema is designed for **scalability** and **easy migration** to another backend.

## Design Principles

1. **RPC-as-API**: Each `fn_manage_*` RPC maps 1:1 to an API endpoint. Replace `supabase.rpc('fn_manage_profile', {...})` with `POST /api/profile` returning the same JSON shape.

2. **PostgreSQL-native**: Optimized for Postgres (JSONB, plpgsql, SECURITY DEFINER). Migrating to **another Postgres** (RDS, Neon, etc.) is trivial. Migrating to MySQL/Mongo requires rewriting functions.

3. **Explicit Contracts**: Each RPC has `action` + `payload` → `JSONB` result. Same contract for any backend.

4. **Migration path**:
   - **Supabase Pro / another Postgres**: Copy SQL, update connection. Minimal changes.
   - **Any backend (Node/Go/Python)**: Implement RPC logic as REST/GraphQL; keep same request/response shape. Database can stay Postgres or change.

## Migration Checklist

| Component | Supabase | Replace With |
|-----------|----------|--------------|
| Auth | `auth.uid()` | JWT `sub` claim |
| RPC | `supabase.rpc()` | REST/GraphQL endpoint |
| Storage | `supabase.storage` | S3/GCS + CDN |
| Realtime | `supabase.channel()` | WebSocket/SSE |
| Edge Functions | `supabase.functions.invoke` | Your API |

## Run Order (Query Editor)

**Order (04 runs after 08 – it depends on subscriptions):**

1. `01_profiles` → `02_photos` → `03_verification` → `05_bookmarks` → `06_shares` → `07_blocks_reports` → `08_subscriptions`
2. `04_reviewer_data` (requires 01 + 08)
3. `09_payments` → `09b_razorpay_billing` → `09c_razorpay_webhook` → `10_admin_data` → `11_storage` → `12_usage_tracking` → `13_referrals_and_rewards` → `14_automated_match_trigger` → `15_chat_and_notifications`
4. `production_optimization.sql`
5. Insert Razorpay secret (see 09b comments)

**All files are idempotent** – safe to re-run.
