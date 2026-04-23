# Bookmark Feature – Manual Testing Guide

This guide covers end-to-end manual testing for the bookmark feature across all relevant screens (Riverpod migration complete).

---

## Prerequisites

- **Logged-in user** with at least one profile available in the home feed
- **Network connection** (backend sync)
- **Device or emulator** running the app

---

## [BOOKMARK] Debug Logs (Debug Build Only)

When running a **debug build**, all bookmark actions emit `[BOOKMARK]` logs. Use these to trace where each action originated and whether it succeeded.

| Log prefix | Meaning |
|------------|---------|
| `ProfileCardWidget` | User tapped Save/Saved on a profile card (Home or Saved Profiles list) |
| `ActionButtonsWidget (ProfileDetail)` | User tapped Save/SAVED on the profile detail bottom bar |
| `HomeScreenInitialPage` | Home screen handled the toggle (merged API state → Riverpod) |
| `ProfileDetailScreen` | Profile detail handled the toggle |
| `SavedProfilesScreen` | Saved Profiles list: toggle (ref.listen removes unsaved immediately), _loadBookmarks merge, display uses ref.watch for correct Saved color |
| `BookmarkNotifier` | Riverpod notifier: optimistic update, backend sync, rollback on error |

**Example flow** when tapping Save on a home feed card:

```
[BOOKMARK] ProfileCardWidget > User tapped Save on card (profile abc123) > delegating to parent
[BOOKMARK] HomeScreenInitialPage > User tapped Save on profile abc123 > Calling Riverpod toggle
[BOOKMARK] BookmarkNotifier > toggle(abc123) > was: false -> now: true > Optimistic update
[BOOKMARK] BookmarkNotifier > toggle(abc123) > Backend sync SUCCESS
[BOOKMARK] HomeScreenInitialPage > toggle(abc123) > SUCCESS
```

**Example flow** when unsaving from Saved Profiles list:

```
[BOOKMARK] ProfileCardWidget > User tapped Saved on card (profile abc123) > delegating to parent
[BOOKMARK] SavedProfilesScreen > User tapped Saved on profile abc123 > Calling Riverpod toggle (ref.listen will immediately remove if unsaving)
[BOOKMARK] BookmarkNotifier > toggle(abc123) > was: true -> now: false > Optimistic update
[BOOKMARK] BookmarkNotifier > toggle(abc123) > Backend sync SUCCESS
[BOOKMARK] SavedProfilesScreen > toggle(abc123) > SUCCESS
```

→ Profile is **immediately removed** from the list (ref.listen + _syncBookmarkState). No _loadBookmarks call (would overwrite with stale cache).

**Where to see logs:** Run `flutter run` and watch the terminal, or use Android Studio / VS Code Debug Console. Filter by `[BOOKMARK]` for quick scanning.

---

## 1. Home Screen – Profile Card Bookmark

### 1.1 Bookmark (Save) from home feed

1. Open the app and log in if needed
2. Go to **Home** tab (first tab in bottom nav)
3. Wait for the profile list to load
4. Find a profile card showing **Save** (not bookmarked)
5. **Tap the Save button** (or swipe left and tap Save)
6. **Expected:** Icon changes to bookmark (filled) immediately (optimistic update)
7. **Expected:** Toast: "Saved for consultation" or "Profile saved!"
8. **Expected:** Button label changes to **Saved**

### 1.2 Unbookmark from home feed

1. Find a profile card that shows **Saved** (bookmarked)
2. **Tap the Saved button**
3. **Expected:** Icon changes to bookmark outline immediately
4. **Expected:** Toast: "Removed from saved"
5. **Expected:** Button label changes to **Save**

### 1.3 Pull-to-refresh and bookmark state

1. Bookmark 1–2 profiles
2. **Pull down** to refresh the home feed
3. **Expected:** Bookmarked profiles still show **Saved**
4. **Expected:** No flicker or loss of bookmark state

---

## 2. Profile Detail Screen – Action bar bookmark

### 2.1 Bookmark from profile detail

1. From Home, **tap a profile card** to open Profile Detail
2. Scroll to bottom action bar (Save / Message / Share)
3. If profile shows **SAVE**, tap it
4. **Expected:** Button changes to **SAVED** immediately
5. **Expected:** Green background, filled bookmark icon
6. **Expected:** Toast: "Profile saved!"

### 2.2 Unbookmark from profile detail

1. Open a profile that shows **SAVED**
2. **Tap SAVED**
3. **Expected:** Button changes to **SAVE** immediately
4. **Expected:** Toast: "Profile removed from saved"

### 2.3 Cross-screen consistency – Home → Detail → back

1. From Home, **bookmark a profile** (tap Save)
2. **Tap the same profile** to open Detail
3. **Expected:** Action bar shows **SAVED**
4. **Tap back** to return to Home
5. **Expected:** Same profile still shows **Saved** on the card

### 2.4 Cross-screen consistency – Detail → Home

1. Open a profile from Home (not bookmarked)
2. **Bookmark** from Profile Detail (tap SAVE)
3. **Tap back** to Home
4. **Expected:** That profile now shows **Saved** on the card

---

## 3. Saved Profiles Screen

### 3.1 View saved profiles

1. Go to **Profile** tab (or My Profile)
2. Tap **Saved Profiles** (or similar entry)
3. **Expected:** List of bookmarked profiles
4. **Expected:** Profiles bookmarked from Home or Detail appear here
5. **Expected:** Each saved profile shows **Saved** (green/blue) button—**same color as Home and Profile Detail** (no yellow)

### 3.2 Unbookmark from saved list

1. Open Saved Profiles
2. Find a profile and **tap Saved** (or swipe left and tap Save to unbookmark)
3. **Expected:** Profile is **immediately removed** from the list (ref.listen + _syncBookmarkState)
4. **Expected:** No reload from cache—unsaved profile stays removed

### 3.3 Navigate to profile detail from saved list

1. In Saved Profiles, **tap a profile**
2. **Expected:** Profile Detail opens
3. **Expected:** Action bar shows **SAVED**
4. **Unbookmark** from Detail (tap SAVED)
5. **Tap back** to Saved Profiles
6. **Expected:** That profile is **immediately removed** from Saved Profiles list (merge/filter prevents stale cache from re-adding it)

---

## 4. Error & Offline Scenarios

### 4.1 Offline toggle (optional)

1. **Turn off Wi‑Fi and mobile data**
2. Try to bookmark a profile
3. **Expected:** Optimistic update (icon changes)
4. **Expected:** Error toast on backend failure, state rolls back
5. **Turn network back on**
6. **Expected:** Subsequent bookmark/unbookmark works

### 4.2 Rapid toggling (double-tap)

1. Quickly **tap Save** twice
2. **Expected:** No crash
3. **Expected:** Final state matches last tap (or backend resolves conflicts)

---

## 5. Edge Cases

### 5.1 Empty saved list

1. Ensure no profiles are bookmarked
2. Open Saved Profiles
3. **Expected:** Empty state message
4. **Expected:** No crash or blank screen

### 5.2 Many bookmarks

1. Bookmark 10+ profiles
2. Open Saved Profiles
3. **Expected:** List scrolls smoothly
4. **Expected:** All bookmarked profiles appear
5. Return to Home and refresh
6. **Expected:** All still show **Saved**

---

## Test Summary Checklist

| # | Scenario                      | Pass / Fail |
|---|-------------------------------|------------|
| 1 | Home – Save profile           | ☐          |
| 2 | Home – Unsave profile         | ☐          |
| 3 | Home – Refresh keeps state    | ☐          |
| 4 | Detail – Save profile        | ☐          |
| 5 | Detail – Unsave profile      | ☐          |
| 6 | Home → Detail → Back sync    | ☐          |
| 7 | Detail → Home sync           | ☐          |
| 8 | Saved – View list (correct Saved color) | ☐          |
| 9 | Saved – Unbookmark            | ☐          |
|10 | Saved → Detail → Unbookmark  | ☐          |
|11 | Offline rollback (optional)  | ☐          |
|12 | Empty saved list             | ☐          |

---

## Screens Using Riverpod Bookmark

- **HomeScreenInitialPage** – Home feed cards
- **ProfileDetailScreen** – Action bar (Save/SAVED)
- **SavedProfilesScreen** – Saved list

All use `bookmarkNotifierProvider` and `isBookmarkedProvider` for state.
