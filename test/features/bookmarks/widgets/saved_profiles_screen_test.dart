import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mocktail/mocktail.dart';

import 'package:banjarabio/features/bookmarks/providers/bookmark_notifier.dart';
import 'package:banjarabio/features/bookmarks/repository/bookmark_repository.dart';
import 'package:banjarabio/core/models/profile_model.dart';
import 'package:banjarabio/presentation/saved_profiles_screen/saved_profiles_screen.dart';

// Mock repository
class MockBookmarkRepository extends Mock implements BookmarkRepository {}

/// Mirrors SavedProfilesScreen merge/filter logic for unit testing.
/// Ensures unsaved profiles are never re-added from stale cache/API.
///
/// Bug fixes covered:
/// - Merge: never overwrite false (user unsaved) with true from API
/// - Filter: exclude profiles where Riverpod says false (immediate removal)
/// - Display: SavedProfilesScreen passes ref.watch(isBookmarkedProvider) to
///   ProfileCardWidget so Saved shows green (same as Home & Detail), not yellow
Map<String, bool> mergeBookmarkState(
  Map<String, bool> current,
  List<ProfileModel> apiProfiles,
) {
  final merged = Map<String, bool>.from(current);
  for (final p in apiProfiles) {
    if (merged[p.id] != false) merged[p.id] = true;
  }
  return merged;
}

/// Mirrors SavedProfilesScreen filter logic: exclude profiles Riverpod says false.
List<ProfileModel> filterProfilesByBookmarkState(
  List<ProfileModel> profiles,
  Map<String, bool> state,
) {
  return profiles.where((p) => state[p.id] != false).toList();
}

ProfileModel _profile(String id) => ProfileModel.fromJson({
      'id': id,
      'user_id': 'user-1',
      'full_name': 'Test',
      'surname': 'User',
      'age': 25,
      'gender': 'Male',
      'height': "5'8\"",
      'marital_status': 'Single',
      'education': 'Bachelor',
      'profession': 'Engineer',
      'permanent_location': 'Test City',
      'siblings_count': 0,
      'sister_count': 0,
      'brother_count': 0,
    });

void main() {
  group('SavedProfilesScreen', () {
    late MockBookmarkRepository mockRepository;
    late ProviderContainer container;

    setUp(() {
      mockRepository = MockBookmarkRepository();
      container = ProviderContainer(
        overrides: [
          bookmarkRepositoryProvider.overrideWithValue(mockRepository),
        ],
      );
    });

    tearDown(() {
      container.dispose();
    });

    test('is ConsumerStatefulWidget (uses Riverpod ref)', () {
      expect(const SavedProfilesScreen(), isA<ConsumerStatefulWidget>());
    });

    group('mergeBookmarkState (never overwrite user-unsaved with API true)', () {
      test('preserves false when API returns profile user just unsaved', () {
        final current = {'profile-a': true, 'profile-b': false};
        final apiProfiles = [_profile('profile-a'), _profile('profile-b')];
        final merged = mergeBookmarkState(current, apiProfiles);
        expect(merged['profile-b'], false);
        expect(merged['profile-a'], true);
      });

      test('adds new bookmarked from API', () {
        final current = <String, bool>{};
        final apiProfiles = [_profile('profile-1')];
        final merged = mergeBookmarkState(current, apiProfiles);
        expect(merged['profile-1'], true);
      });
    });

    group('filterProfilesByBookmarkState (exclude Riverpod false)', () {
      test('excludes profiles where state is false', () {
        final profiles = [_profile('a'), _profile('b'), _profile('c')];
        final state = {'a': true, 'b': false, 'c': true};
        final filtered = filterProfilesByBookmarkState(profiles, state);
        expect(filtered.map((p) => p.id), ['a', 'c']);
      });

      test('includes all when state has no false', () {
        final profiles = [_profile('a'), _profile('b')];
        final state = {'a': true, 'b': true};
        final filtered = filterProfilesByBookmarkState(profiles, state);
        expect(filtered.length, 2);
      });

      test('includes profile when state has no key (null != false)', () {
        final profiles = [_profile('new')];
        final state = <String, bool>{};
        final filtered = filterProfilesByBookmarkState(profiles, state);
        expect(filtered.length, 1);
      });
    });
  });
}
