import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mocktail/mocktail.dart';

import 'package:banjarabio/features/bookmarks/providers/bookmark_notifier.dart';
import 'package:banjarabio/features/bookmarks/repository/bookmark_repository.dart';
import 'package:banjarabio/core/models/backend_response.dart';

// Mock repository
class MockBookmarkRepository extends Mock implements BookmarkRepository {}

void main() {
  group('BookmarkNotifier', () {
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

    test('initial state is empty map', () {
      final state = container.read(bookmarkNotifierProvider);
      expect(state, isEmpty);
    });

    test('isBookmarked returns false for non-existent profile', () {
      final isBookmarked = container.read(isBookmarkedProvider('profile-1'));
      expect(isBookmarked, false);
    });

    test('toggle bookmark adds bookmark optimistically', () async {
      when(() => mockRepository.toggleBookmark('profile-1', true))
          .thenAnswer((_) async => BackendResponse.success(null));

      final notifier = container.read(bookmarkNotifierProvider.notifier);
      await notifier.toggle('profile-1');

      expect(container.read(isBookmarkedProvider('profile-1')), true);
      verify(() => mockRepository.toggleBookmark('profile-1', true)).called(1);
    });

    test('toggle bookmark removes bookmark optimistically', () async {
      // First add
      when(() => mockRepository.toggleBookmark('profile-1', true))
          .thenAnswer((_) async => BackendResponse.success(null));
      final notifier = container.read(bookmarkNotifierProvider.notifier);
      await notifier.toggle('profile-1');

      // Then remove
      when(() => mockRepository.toggleBookmark('profile-1', false))
          .thenAnswer((_) async => BackendResponse.success(null));
      await notifier.toggle('profile-1');

      expect(container.read(isBookmarkedProvider('profile-1')), false);
    });

    test('toggle bookmark rolls back on error', () async {
      when(() => mockRepository.toggleBookmark('profile-1', true))
          .thenAnswer((_) async => BackendResponse.failure('Network error'));

      final notifier = container.read(bookmarkNotifierProvider.notifier);

      // Attempt toggle and catch exception
      try {
        await notifier.toggle('profile-1');
        fail('Should have thrown an exception');
      } catch (e) {
        expect(e, isA<Exception>());
      }

      // State should be rolled back to original (false)
      expect(container.read(isBookmarkedProvider('profile-1')), false);
    });

    test('initializeBookmarks sets state correctly', () {
      final notifier = container.read(bookmarkNotifierProvider.notifier);
      notifier.initializeBookmarks({
        'profile-1': true,
        'profile-2': true,
        'profile-3': false,
      });

      expect(container.read(isBookmarkedProvider('profile-1')), true);
      expect(container.read(isBookmarkedProvider('profile-2')), true);
      expect(container.read(isBookmarkedProvider('profile-3')), false);
    });

    test('removeBookmark removes from state', () {
      final notifier = container.read(bookmarkNotifierProvider.notifier);
      notifier.initializeBookmarks({'profile-1': true});
      expect(container.read(isBookmarkedProvider('profile-1')), true);

      notifier.removeBookmark('profile-1');
      expect(container.read(isBookmarkedProvider('profile-1')), false);
    });

    test('clearAll clears all bookmarks', () async {
      when(() => mockRepository.clearAllBookmarks())
          .thenAnswer((_) async => BackendResponse.success(null));

      final notifier = container.read(bookmarkNotifierProvider.notifier);
      notifier.initializeBookmarks({
        'profile-1': true,
        'profile-2': true,
      });

      await notifier.clearAll();

      expect(container.read(bookmarkNotifierProvider), isEmpty);
      verify(() => mockRepository.clearAllBookmarks()).called(1);
    });

    test('clearAll rolls back on error', () async {
      when(() => mockRepository.clearAllBookmarks())
          .thenAnswer((_) async => BackendResponse.failure('Error'));

      final notifier = container.read(bookmarkNotifierProvider.notifier);
      notifier.initializeBookmarks({
        'profile-1': true,
        'profile-2': true,
      });

      // Attempt clearAll and catch exception
      try {
        await notifier.clearAll();
        fail('Should have thrown an exception');
      } catch (e) {
        expect(e, isA<Exception>());
      }

      // State should be rolled back to original (2 bookmarks)
      expect(container.read(bookmarkNotifierProvider).length, 2);
    });
  });
}
