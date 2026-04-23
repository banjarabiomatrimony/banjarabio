# Trust Score Feature – Riverpod Migration

Mirrors Payment/Referral/Bookmark migration pattern. Old implementation kept until 100% validated.

---

## Structure

```
lib/features/trust_score/
├── repository/
│   ├── trust_score_repository.dart      # Abstract interface
│   └── trust_score_repository_impl.dart # Delegates to core
└── providers/
    └── trust_score_providers.dart       # trustScoreRepositoryProvider
```

---

## Routes

| Route | Screen | Purpose |
|-------|--------|---------|
| `/trust-score-screen` | TrustScoreScreen | **Old** – keep until migration done |
| `/trust-score-screen-riverpod` | TrustScoreScreenRiverpod | **New** – migration testing |

---

## How to Test the Riverpod Screen

**Option A – Temporarily swap in My Profile:**
In `my_profile_screen.dart`, change the Trust Score navigation from:
```dart
AppRoutes.trustScore
```
to:
```dart
AppRoutes.trustScoreRiverpod
```

**Option B – Add a debug entry:**
Navigate via `Navigator.pushNamed(context, AppRoutes.trustScoreRiverpod)` from any screen (e.g. Settings dev section).

---

## Files (New)

- `lib/features/trust_score/repository/trust_score_repository.dart`
- `lib/features/trust_score/repository/trust_score_repository_impl.dart`
- `lib/features/trust_score/providers/trust_score_providers.dart`
- `lib/presentation/trust_score_screen/trust_score_screen_riverpod.dart`
- `test/features/trust_score/providers/trust_score_providers_test.dart`
- `test/features/trust_score/repository/trust_score_repository_impl_test.dart`
- `test/features/trust_score/widgets/trust_score_screen_riverpod_test.dart`
- `docs/TRUST_SCORE_MIGRATION.md`
- `docs/TRUST_SCORE_MANUAL_TESTING_GUIDE.md`

## Migration Steps (When 100% Validated)

1. Swap route: point `trustScore` to `TrustScoreScreenRiverpod`
2. Remove old `TrustScoreScreen` and `trustScoreRiverpod` route
3. Verification flows that use `TrustScoreRepository` directly can later inject via `trustScoreRepositoryProvider`
