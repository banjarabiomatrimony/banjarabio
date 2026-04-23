# 🏗️ Supabase Architectural Documentation

This document provides a comprehensive overview of the consolidated Supabase backend for the **BanjaraBio** project. It details the "Atomic Feature" design and the "One Query, One Feature" RPC pattern.

---

## 🏛️ Core Philosophy: "Atomic Feature Modules"

The backend is organized into **13 Granular Feature Files** located in `supabase/features/`. Each file is a self-contained unit that handles three things:
1.  **Schema**: Tables, Indexes, and Constraints.
2.  **Security**: Row Level Security (RLS) policies.
3.  **Logic**: Pl/pgSQL Functions and Master RPCs.

### Why atomic?
- **Isolation**: Modifying the "Photos" logic will never accidentally break the "Payments" table.
- **Portability**: If you move to a different backend, you can clearly see the exact requirements (tables + logic) for each UI screen.
- **Performance**: High-density Pl/pgSQL functions reduce round-trips between Flutter and Supabase.

---

## 🚀 The RPC Pattern: "One Query per Feature"

Each feature file implements a **Master RPC Function** (e.g., `fn_manage_profile`). Instead of performing many individual CRUD calls from Flutter, you send an `action` and a `payload`.

### Benefits:
- **Transaction Safety**: Complex operations (like deleting a photo and setting a new primary) happen in a single SQL transaction.
- **Backend-Agnostic Migration**: Your Flutter code stays clean. If you switch backends, you only replace one RPC call with one API call.

---

## 📂 Feature Glossary

| # | File | Feature | Purpose |
| :--- | :--- | :--- | :--- |
| **01** | `profiles.sql` | **Profile Management** | Core user identity, bio, and family details. |
| **02** | `photos.sql` | **Media Gallery** | Profile images and primary photo logic. |
| **03** | `verification.sql`| **Trust & Safety** | Identity verification requests and dynamic Trust Score calculation. |
| **04** | `reviewer_data.sql`| **Testing Support** | Seeding protocol for App Store reviewer accounts. |
| **05** | `bookmarks.sql` | **Saved Profiles** | Save/Remove interest in other profiles. |
| **06** | `shares.sql` | **Sharing & Matching**| Profile sharing logic and automatic "Matched" status. |
| **07** | `blocks_reports.sql`| **UGC Safety** | Blocking and reporting systems for user safety. |
| **08** | `subscriptions.sql`| **Plan Management** | Plan types (Free, Gold, etc.) and auto-initialization. |
| **09** | `payments.sql` | **Transactions** | Razorpay integration and automated premium status syncing. |
| **10** | `admin_data.sql` | **Admin Controls** | Protection of system fields and admin role definitions. |
| **11** | `storage.sql` | **Cloud Storage** | Global bucket policies for media objects. |
| **12** | `usage_tracking.sql`| **Usage Analytics** | Tracking daily quotas for views, shares, and bookmarks. |
| **00** | `database_reset.sql`| **Maintenance** | **NUCLEAR OPTION**: Resets all tables and data for fresh starts. |

---

## 🛠️ Flutter Alignment (Repository Layer)

The SQL architecture is designed to match your existing Dart Repositories in `lib/core/repositories/`.

### Mapping Strategy:
- **`ProfileRepository`**: Utilizes `fn_manage_profile`.
- **`PhotoRepository`**: Utilizes `fn_manage_photos`.
- **`TrustScoreRepository`**: Utilizes `fn_manage_verification`.

#### Example Call Pattern:
```dart
// Flutter side
final response = await supabase.rpc('fn_manage_profile', params: {
  'action': 'set_active',
  'payload': {'is_active': true}
});
```

---

## 🔄 Database Idempotency (CI/CD Ready)

All feature scripts are designed to be **idempotent**, meaning they can be re-run multiple times without causing errors or duplicate data.

| Action | How it is Handled in Scripts | Commands Used |
| :--- | :--- | :--- |
| **Add Data** | Prevents duplicate errors for seed data and Master RPCs. | `INSERT ... ON CONFLICT` |
| **Change Data** | Updates existing records (like tester accounts) to match the latest script. | `DO UPDATE SET` |
| **Change Table** | Ensures structures exist without creating duplicates. | `CREATE TABLE IF NOT EXISTS` |
| **RLS Policies** | Cleans up existing policies before recreating them. | `DROP POLICY IF EXISTS` |
| **Indexes** | Creates indexes only if they don't already exist. | `CREATE INDEX IF NOT EXISTS` |
| **Functions** | Replaces old logic with the latest version in the script. | `CREATE OR REPLACE FUNCTION` |
| **Triggers** | Cleans up triggers before re-binding them to the table. | `DROP TRIGGER IF EXISTS` |

---

## ⚙️ Maintenance & Growth

### 1. Adding a new column
Update the `CREATE TABLE` in the relevant feature file and your `supabase_schema.sql` (context file). Use a standard `ALTER TABLE` to apply it to production.

### 2. Modifying Logic
Update the function in the feature file and re-run the entire file in the Supabase SQL Editor. The `CREATE OR REPLACE FUNCTION` command will safely update the logic.

### 3. Safety Warning
**Never** run `00_database_reset.sql` on a production database. It will delete all user data.

---

*Last Updated: February 6, 2026*
