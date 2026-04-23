# Referral Feature – Manual Testing Guide

This guide covers manual testing for the Referral Invite screen (Riverpod migration in progress).

---

## Prerequisites

- **Logged-in user** with a profile
- **Network connection** (to load stats and code)
- **Device or emulator** running a **debug build**

---

## [REFERRAL] Debug Logs (Debug Build Only)

When running a **debug build**, all referral actions emit `[REFERRAL]` logs. Use these to trace where each action originated.

| Log prefix | Meaning |
|------------|---------|
| `ReferralInviteScreenRiverpod` | User tapped Copy link, Share Link, Retry, or pulled to refresh |
| `ReferralInviteNotifier` | Data load complete, refresh invalidated |

**Example flow** when opening the Referral Invite screen:

```
[REFERRAL] ReferralInviteNotifier > build > Loaded stats: true, code: BANJARA-7X29
```

**Example flow** when copying the link:

```
[REFERRAL] ReferralInviteScreenRiverpod > User tapped Copy link > Clipboard set
```

**Example flow** when sharing:

```
[REFERRAL] ReferralInviteScreenRiverpod > User tapped Share Link > Opening share sheet
```

**Example flow** when pulling to refresh:

```
[REFERRAL] ReferralInviteScreenRiverpod > User pulled to refresh > Calling refresh
[REFERRAL] ReferralInviteNotifier > refresh > Invalidating
[REFERRAL] ReferralInviteNotifier > build > Loaded stats: true, code: BANJARA-7X29
```

**Example flow** when tapping Retry (after error):

```
[REFERRAL] ReferralInviteScreenRiverpod > User tapped Retry (error state) > Calling refresh
[REFERRAL] ReferralInviteNotifier > refresh > Invalidating
[REFERRAL] ReferralInviteNotifier > build > Loaded stats: true, code: BANJARA-7X29
```

**Where to see logs:** Run `flutter run` and watch the terminal, or use Android Studio / VS Code Debug Console. Filter by `[REFERRAL]` for quick scanning.

---

## 1. View Referral Invite Screen

### 1.1 Navigate and load

1. Open the app and log in
2. Go to **Settings**
3. Tap **Invite a Relative** (or use `/referral-invite-riverpod` if testing new screen)
4. **Expected:** Loading spinner, then stats and invite link appear
5. **Expected:** Log: `[REFERRAL] ReferralInviteNotifier > build > Loaded stats: true, code: ...`

### 1.2 Copy link

1. On Referral Invite screen, tap the **Copy** icon
2. **Expected:** Snackbar: "Referral link copied to clipboard!"
3. **Expected:** Log: `[REFERRAL] ReferralInviteScreenRiverpod > User tapped Copy link > Clipboard set`

### 1.3 Share link

1. Tap **Share Link on WhatsApp**
2. **Expected:** Share sheet opens
3. **Expected:** Log: `[REFERRAL] ReferralInviteScreenRiverpod > User tapped Share Link > Opening share sheet`

### 1.4 Pull to refresh

1. Pull down on the content
2. **Expected:** Spinner, then data reloads
3. **Expected:** Logs for refresh and build

---

## 2. Error Scenarios

### 2.1 Load failure + Retry

1. **Turn off network** and open Referral Invite
2. **Expected:** Error state with "Failed to load referral data"
3. **Turn on network**
4. Tap **Retry**
5. **Expected:** Data loads successfully
6. **Expected:** Log: `[REFERRAL] ReferralInviteScreenRiverpod > User tapped Retry (error state) > Calling refresh`

---

## Test Summary Checklist

| # | Scenario              | Pass / Fail |
|---|-----------------------|------------|
| 1 | Load stats and code   | ☐          |
| 2 | Copy link             | ☐          |
| 3 | Share link            | ☐          |
| 4 | Pull to refresh       | ☐          |
| 5 | Error + Retry         | ☐          |

---

## Screens Using Riverpod Referral

- **ReferralInviteScreenRiverpod** – stats, code, copy, share, refresh

All use `referralInviteProvider` for state.
