# Trust Score Feature – Manual Testing Guide

This guide covers manual testing for the Trust Score screen (Riverpod migration in progress).

---

## Prerequisites

- **Logged-in user** with a profile
- **Network connection**
- **Debug build** for `[TRUST_SCORE]` logs

---

## [TRUST_SCORE] Debug Logs (Debug Build Only)

When running a **debug build**, Trust Score actions emit `[TRUST_SCORE]` logs.

| Log prefix | Meaning |
|------------|---------|
| `TrustScoreScreenRiverpod > _loadTrustScore` | Loading score/status/profile; SUCCESS or FAILED |
| `TrustScoreScreenRiverpod > _handleVerifyItem` | User tapped a verification item |
| `TrustScoreScreenRiverpod > _showShareCard` | User opened share bottom sheet |

**Example – load success:**
```
[TRUST_SCORE] TrustScoreScreenRiverpod > _loadTrustScore > Loading
[TRUST_SCORE] TrustScoreScreenRiverpod > _loadTrustScore > SUCCESS | score=50
```

**Example – load failure:**
```
[TRUST_SCORE] TrustScoreScreenRiverpod > _loadTrustScore > FAILED | score=true, status=false, profile=true
```

**Example – user taps Verify:**
```
[TRUST_SCORE] TrustScoreScreenRiverpod > _handleVerifyItem > mobile
```

**Where to see logs:** Run `flutter run` and filter terminal by `[TRUST_SCORE]`.

---

## Opening the Riverpod Screen

To test `TrustScoreScreenRiverpod`, navigate to it:

1. **Temporary route swap:** In `my_profile_screen.dart`, change the Trust Score tap target from `AppRoutes.trustScore` to `AppRoutes.trustScoreRiverpod`
2. Or add a debug button that calls `Navigator.pushNamed(context, AppRoutes.trustScoreRiverpod)`

---

## 1. View Trust Score

### 1.1 Initial load

1. Navigate to Trust Score (My Profile → Trust Score, or via swapped route)
2. **Expected:** Loading spinner, then score card showing "Your Trust Score" with value (0–100)
3. **Expected:** Verification list (Mobile, Email, Live Selfie, etc.)
4. **Expected:** Share icon in app bar
5. **Expected:** Log: `[TRUST_SCORE] TrustScoreScreenRiverpod > _loadTrustScore > SUCCESS | score=N`

### 1.2 Share bottom sheet

1. Tap the Share icon in the app bar
2. **Expected:** Bottom sheet with score, user name, "Share to Social Media" button
3. **Expected:** Log: `[TRUST_SCORE] TrustScoreScreenRiverpod > _showShareCard > Opening share sheet`
4. Tap "Share to Social Media" – native share sheet opens

---

## 2. Verification Item Navigation

### 2.1 Tap "Start" / "Verify" on an item

1. Tap any unverified item (e.g. Mobile Number)
2. **Expected:** Navigate to corresponding verification flow
3. **Expected:** Log: `[TRUST_SCORE] TrustScoreScreenRiverpod > _handleVerifyItem > mobile`
4. Return from verification flow – score should reload

### 2.2 Profile Completion item

1. Tap "Update" or "Go" on Profile Completed (when &lt; 100%)
2. **Expected:** Navigate to Biodata Creation (edit mode)
3. Return – score should reload

---

## 3. Parity Check

Compare behavior of:

- **Old:** `TrustScoreScreen` (route `/trust-score-screen`)
- **New:** `TrustScoreScreenRiverpod` (route `/trust-score-screen-riverpod`)

Both should:

- Show same score for the same user
- Show same verification status per item
- Share bottom sheet works identically
- Navigation to verification flows works identically
- Profile Completion navigates to biodata editor

---

## When Migration Is Complete

1. Swap `trustScore` route to `TrustScoreScreenRiverpod`
2. Remove old `TrustScoreScreen`
3. Remove `trustScoreRiverpod` route constant
