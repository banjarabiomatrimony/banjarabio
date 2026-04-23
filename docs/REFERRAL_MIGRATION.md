# Referral Feature – Riverpod Migration (Parallel)

Migration in progress. **Old implementation is unchanged** until 100% validated.

---

## [REFERRAL] Debug Logs

The new Riverpod screen includes `[REFERRAL]` logs for manual testing. See **`docs/REFERRAL_MANUAL_TESTING_GUIDE.md`** for log prefixes, example flows, and step-by-step scenarios.

---

## Current State

| Route | Screen | Status |
|-------|--------|--------|
| `/referral-invite` | `ReferralInviteScreen` | **OLD** (setState) – used by Settings |
| `/referral-invite-riverpod` | `ReferralInviteScreenRiverpod` | **NEW** (Riverpod) – for testing |

---

## How to Test the New Screen

1. Run the app in debug.
2. Navigate to **Settings**.
3. To test the **new** Riverpod screen, temporarily change the "Invite a Relative" tap target in Settings:
   ```dart
   // In settings_screen.dart, line ~286:
   onTap: () => Navigator.pushNamed(context, AppRoutes.referralInviteRiverpod),
   ```
4. Or navigate manually: `Navigator.pushNamed(context, AppRoutes.referralInviteRiverpod)`.

---

## When 100% Done

1. Change `referralInvite` route in `app_routes.dart`:
   ```dart
   referralInvite: (context) => const ReferralInviteScreenRiverpod(),
   ```
2. Remove the `referralInviteRiverpod` route constant and map entry.
3. Delete `lib/presentation/referral_screen/referral_invite_screen.dart` (old).
4. Rename `ReferralInviteScreenRiverpod` → `ReferralInviteScreen` if desired, or keep the name.
5. Update any imports that referenced the old screen.

---

## Files (New Only)

- `lib/features/referral/providers/referral_invite_notifier.dart`
- `lib/presentation/referral_screen/referral_invite_screen_riverpod.dart`
- `test/features/referral/providers/referral_invite_notifier_test.dart`
- `test/features/referral/widgets/referral_invite_screen_riverpod_test.dart`

## Files (Unchanged)

- `lib/presentation/referral_screen/referral_invite_screen.dart` (old)
- `lib/core/repositories/referral_repository.dart`
- `lib/core/models/referral_stats_model.dart`
