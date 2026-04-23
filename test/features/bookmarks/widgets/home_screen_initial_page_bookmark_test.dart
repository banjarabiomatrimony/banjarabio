import 'package:flutter_test/flutter_test.dart';

import 'package:banjarabio/features/bookmarks/providers/bookmark_notifier.dart';
import 'package:banjarabio/core/models/backend_response.dart';
import 'package:banjarabio/features/bookmarks/repository/bookmark_repository.dart';
import 'package:banjarabio/presentation/home_screen/home_screen_initial_page.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mocktail/mocktail.dart';

class MockBookmarkRepository extends Mock implements BookmarkRepository {}

/// HomeScreenInitialPage bookmark integration tests.
///
/// Validates that HomeScreenInitialPage uses Riverpod for bookmark state
/// and the provider chain works for merge/display.
void main() {
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

  group('HomeScreenInitialPage Bookmark (Riverpod)', () {
    test('HomeScreenInitialPage is ConsumerStatefulWidget (uses Riverpod ref)',
        () {
      expect(const HomeScreenInitialPage(), isA<ConsumerStatefulWidget>());
    });

    test('initializeBookmarks merge preserves existing bookmarks from other screens',
        () {
      // Simulate SavedProfilesScreen or ProfileDetailScreen having bookmarked profile-A
      container.read(bookmarkNotifierProvider.notifier).initializeBookmarks({
        'profile-from-saved': true,
      });

      // Simulate _loadData merging API response (HomeScreenInitialPage logic)
      final current = container.read(bookmarkNotifierProvider);
      final merged = Map<String, bool>.from(current);
      merged['profile-from-saved'] = true; // Preserve
      merged['profile-from-home'] = false; // From API
      merged['profile-from-home-2'] = true; // From API
      container.read(bookmarkNotifierProvider.notifier).initializeBookmarks(merged);

      expect(container.read(isBookmarkedProvider('profile-from-saved')), true);
      expect(container.read(isBookmarkedProvider('profile-from-home')), false);
      expect(container.read(isBookmarkedProvider('profile-from-home-2')), true);
    });

    test('toggle updates isBookmarkedProvider for HomeScreen card display', () async {
      when(() => mockRepository.toggleBookmark('profile-1', true))
          .thenAnswer((_) async => BackendResponse.success(null));

      container.read(bookmarkNotifierProvider.notifier).initializeBookmarks({
        'profile-1': false,
      });

      await container.read(bookmarkNotifierProvider.notifier).toggle('profile-1');

      expect(container.read(isBookmarkedProvider('profile-1')), true);
    });
  });
}
