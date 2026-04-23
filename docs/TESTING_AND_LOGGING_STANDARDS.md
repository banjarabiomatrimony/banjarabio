# Testing & Manual Verification Standards

This document defines project-wide standards for **unit tests**, **widget tests**, and **debug logs for manual testing**. Apply these when implementing or validating any feature across the app.

**Reference implementation:** Bookmark feature (`lib/features/bookmarks/`, `test/features/bookmarks/`).

**Bookmark bug fixes (Riverpod migration):**
- Merge: never overwrite `false` (user unsaved) with `true` from stale cache/API.
- Filter: exclude profiles where Riverpod says `false` (immediate removal from list).
- Display: SavedProfilesScreen uses `ref.watch(isBookmarkedProvider)` for button color (Saved = green, same as Home & Detail).

---

## 1. Test Structure & Naming

### Directory layout (feature-first, mirrors lib/)

```
test/
  features/
    <feature_name>/
      repository/          # Unit tests for data layer
        <name>_repository_test.dart
      providers/           # Unit tests for Riverpod notifiers/cubits
        <name>_notifier_test.dart
      widgets/             # Widget tests for screens & shared widgets
        <screen_or_widget>_test.dart
```

### Naming

| Type | File name pattern | Group name pattern |
|------|-------------------|--------------------|
| Repository | `{repo}_repository_test.dart` | `{Repo}Impl` or `{Repo}RepositoryImpl` |
| Provider/Notifier | `{name}_notifier_test.dart` | `{NotifierName}` |
| Screen widget | `{screen}_test.dart` or `{screen}_{feature}_test.dart` | `{Screen} {Feature}` |
| Shared widget | `{widget}_test.dart` | `{WidgetName}` |

---

## 2. Unit Test Rules

### 2.1 Repository tests

- **Mock** external dependencies (Supabase, HTTP clients, etc.) via `mocktail`.
- **Assert** correct API/RPC calls (method name, params), success/failure paths, and edge cases.
- **Use fakes** for complex return types (e.g. `PostgrestFilterBuilder`) instead of deep mocks.
- **Cover:**
  - Success paths (add/remove, list, clear)
  - Auth/unauth (e.g. `currentUser == null`)
  - Errors (network, duplicate keys, server errors)
  - RPC params (action, profile_id, user_id)

```dart
// Example structure (from bookmark_repository_test.dart)
test('toggleBookmark calls correct RPC with add action', () async {
  when(() => mockSupabase.rpc('fn_manage_bookmarks', params: any(named: 'params')))
      .thenAnswer((_) => FakeRpcResponse({'status': 'success', 'is_bookmarked': true}));

  final result = await repository.toggleBookmark('profile-1', true);

  expect(result.isSuccess, true);
  verify(() => mockSupabase.rpc('fn_manage_bookmarks', params: any(named: 'params'))).called(1);
});
```

### 2.2 Provider/Notifier tests

- **Override** repository (or data source) provider with mock inside `ProviderContainer`.
- **Test** initial state, state transitions, and rollback on error.
- **Cover:**
  - Initial/empty state
  - Success flows (add, remove, clear)
  - Optimistic updates
  - Rollback when backend fails
  - Family providers if used (e.g. `isBookmarkedProvider('id')`)

```dart
// Example (from bookmark_notifier_test.dart)
test('toggle bookmark rolls back on error', () async {
  when(() => mockRepository.toggleBookmark('profile-1', true))
      .thenAnswer((_) async => BackendResponse.failure('Network error'));

  final notifier = container.read(bookmarkNotifierProvider.notifier);
  try {
    await notifier.toggle('profile-1');
    fail('Should have thrown');
  } catch (e) {
    expect(e, isA<Exception>());
  }
  expect(container.read(isBookmarkedProvider('profile-1')), false);
});
```

### 2.3 General unit test rules

- Use `setUp` / `tearDown` for mocks and `ProviderContainer.dispose()`.
- Prefer `test()` for pure logic; no `pumpWidget` needed.
- Keep tests focused: one logical scenario per `test()`.

---

## 3. Widget Test Rules

### 3.1 Screen-level widget tests

- **Wrap** with `ProviderScope` or `ProviderContainer` when the screen uses Riverpod.
- **Override** repository/API providers with mocks to avoid real network calls.
- **Verify** that screens are `ConsumerStatefulWidget` or `ConsumerWidget` when they use Riverpod.
- **Test** provider chain: e.g. merge logic, `isBookmarkedProvider` → UI.

```dart
// Example (from home_screen_initial_page_bookmark_test.dart)
test('initializeBookmarks merge preserves existing bookmarks from other screens', () {
  container.read(bookmarkNotifierProvider.notifier).initializeBookmarks({
    'profile-from-saved': true,
  });
  final current = container.read(bookmarkNotifierProvider);
  final merged = Map<String, bool>.from(current);
  merged['profile-from-home'] = false;
  merged['profile-from-home-2'] = true;
  container.read(bookmarkNotifierProvider.notifier).initializeBookmarks(merged);

  expect(container.read(isBookmarkedProvider('profile-from-saved')), true);
  expect(container.read(isBookmarkedProvider('profile-from-home')), false);
  expect(container.read(isBookmarkedProvider('profile-from-home-2')), true);
});
```

### 3.2 Shared widget tests (buttons, cards, etc.)

- **Wrap** with required ancestors (e.g. `MaterialApp`, `Sizer` if using `.h`/`.w`).
- **Test** display states (e.g. SAVE vs SAVED).
- **Test** callbacks: tap → `onBookmark`/`onTap` invoked with expected args.
- **Test** `didUpdateWidget` when parent passes new state (e.g. Riverpod-driven rebuilds).

```dart
// Example (from action_buttons_widget_test.dart)
testWidgets('calls onBookmark when SAVE button tapped', (tester) async {
  Map<String, dynamic>? capturedProfile;
  await tester.pumpWidget(
    wrapWithSizer(MaterialApp(
      home: ActionButtonsWidget(
        profileData: {'id': 'profile-1', 'name': 'Test', 'isBookmarked': false},
        onShare: (_) {},
        onMessage: (_) {},
        onBookmark: (profile) => capturedProfile = profile,
      ),
    )),
  );
  await tester.tap(find.text('SAVE'));
  await tester.pump();
  expect(capturedProfile!['id'], 'profile-1');
});
```

### 3.3 General widget test rules

- Use `testWidgets()` for any test that needs `pumpWidget`.
- Wrap `Sizer`-dependent widgets with `Sizer(builder: (context, orientation, screenType) => child)`.
- Avoid testing implementation details; assert visible text, icons, and callback behavior.

---

## 4. Debug Logs for Manual Testing

### 4.1 Purpose

When implementing a feature, add **feature-tagged debug logs** so manual testers can:

- Trace where each user action originated (which screen, which widget)
- Confirm success/failure of backend sync
- Quickly filter logs by feature name (e.g. `[BOOKMARK]`)

### 4.2 Log format

```
[FEATURE_NAME] Source > User action / System event > Outcome
```

| Part | Example | Purpose |
|------|---------|---------|
| Tag | `[BOOKMARK]` | Filterable; use UPPERCASE feature name |
| Source | `HomeScreenInitialPage`, `ProfileDetailScreen`, `ActionButtonsWidget` | Identifies entry point |
| Action | `User tapped Save on profile abc123` | What the user did |
| Outcome | `Calling Riverpod toggle`, `SUCCESS`, `FAILED \| error` | Result or next step |

### 4.3 Where to add logs

| Location | Log content |
|----------|-------------|
| **Leaf widgets** (buttons, cards) | `[FEATURE] WidgetName > User tapped X on Y (id) > delegating to parent` |
| **Screens** (handlers) | `[FEATURE] ScreenName > User tapped X on profile id > Calling provider/repo` |
| **Screens** (success) | `[FEATURE] ScreenName > toggle(id) > SUCCESS` |
| **Screens** (failure) | `[FEATURE] ScreenName > toggle(id) > FAILED \| error` |
| **Providers/Notifiers** | `[FEATURE] NotifierName > toggle(id) > was: X -> now: Y > Optimistic update` |
| **Providers/Notifiers** | `[FEATURE] NotifierName > toggle(id) > Backend sync SUCCESS` |
| **Providers/Notifiers** | `[FEATURE] NotifierName > toggle(id) > Backend FAILED > Rollback \| error` |
| **Data load** | `[FEATURE] ScreenName > _loadData > Merged/Initialized N items` |

### 4.4 Guard with kDebugMode

```dart
if (kDebugMode) {
  debugPrint('[BOOKMARK] ProfileDetailScreen > User tapped SAVE on profile $profileId > Calling Riverpod toggle');
}
```

- Ensures logs only appear in **debug builds**.
- Import: `import 'package:flutter/foundation.dart';`

### 4.5 Example flow (full trace)

```
[BOOKMARK] ProfileCardWidget > User tapped Save on card (profile abc123) > delegating to parent
[BOOKMARK] HomeScreenInitialPage > User tapped Save on profile abc123 > Calling Riverpod toggle
[BOOKMARK] BookmarkNotifier > toggle(abc123) > was: false -> now: true > Optimistic update
[BOOKMARK] BookmarkNotifier > toggle(abc123) > Backend sync SUCCESS
[BOOKMARK] HomeScreenInitialPage > toggle(abc123) > SUCCESS
```

---

## 5. Manual Testing Guide Template

For each feature, create a guide under `docs/`:

**Filename:** `docs/{FEATURE}_MANUAL_TESTING_GUIDE.md`

**Structure:**

1. **Prerequisites** – Login, network, device
2. **`[FEATURE]` Debug Logs** – Table of log prefixes and meanings; example flow
3. **Entry points** – List of screens/widgets where the feature is used
4. **Step-by-step scenarios** – Numbered steps with expected results
5. **Error & offline** – Optional: network off, rapid taps
6. **Edge cases** – Empty list, many items, etc.
7. **Test Summary Checklist** – Table with Pass/Fail columns

**Reference:** `docs/BOOKMARK_MANUAL_TESTING_GUIDE.md`

---

## 6. Feature Rollout Checklist

When adding tests and manual verification for a **new feature**:

| # | Task | Done |
|---|------|------|
| 1 | Create `test/features/<feature>/repository/` and add repository unit tests | ☐ |
| 2 | Create `test/features/<feature>/providers/` and add notifier/provider unit tests | ☐ |
| 3 | Create `test/features/<feature>/widgets/` and add screen/widget tests | ☐ |
| 4 | Add `[FEATURE]` logs to all entry points (widgets, screens, notifier) | ☐ |
| 5 | Guard logs with `kDebugMode` | ☐ |
| 6 | Create `docs/{FEATURE}_MANUAL_TESTING_GUIDE.md` | ☐ |
| 7 | Document log prefixes table and example flow in the guide | ☐ |
| 8 | Run `flutter test test/features/<feature>/` – all pass | ☐ |
| 9 | Run manual tests using the guide and verify logs | ☐ |

---

## 7. Quick Reference – Feature Tag Naming

| Feature | Tag | Example log |
|---------|-----|-------------|
| Bookmark | `[BOOKMARK]` | `[BOOKMARK] ProfileDetailScreen > User tapped SAVE > ...` |
| Share | `[SHARE]` | `[SHARE] ProfileDetailScreen > User tapped Share > ...` |
| Message | `[MESSAGE]` | `[MESSAGE] ProfileDetailScreen > User sent message > ...` |
| Match | `[MATCH]` | `[MATCH] HomeScreen > User tapped Like > ...` |
| Search | `[SEARCH]` | `[SEARCH] SearchScreen > User searched "..." > ...` |

Use a short, uppercase, memorable tag for each feature.

---

## 8. Summary

- **Unit tests:** Repository (API/RPC), Provider (state, rollback). Mock deps; assert behavior.
- **Widget tests:** Screens (provider chain), shared widgets (display, callbacks, didUpdateWidget).
- **Manual logs:** `[FEATURE]` tag, source, action, outcome. `kDebugMode` only.
- **Guide:** `docs/{FEATURE}_MANUAL_TESTING_GUIDE.md` with log table, steps, and checklist.

Follow the **Bookmark** implementation as the canonical example for all features.
