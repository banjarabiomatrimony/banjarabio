import 'package:flutter_test/flutter_test.dart';

import 'package:banjarabio/features/bookmarks/providers/bookmark_notifier.dart';
import 'package:banjarabio/core/models/backend_response.dart';
import 'package:banjarabio/features/bookmarks/repository/bookmark_repository.dart';
import 'package:banjarabio/presentation/profile_detail_screen/profile_detail_screen.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mocktail/mocktail.dart';

class MockBookmarkRepository extends Mock implements BookmarkRepository {}

/// ProfileDetailScreen bookmark integration tests.
///
/// Full widget tests require mocking ProfileRepository, ShareRepository,
/// ChatRepository, CustomIconWidget assets, and app theme. The bookmark
/// integration is validated by:
/// 1. ActionButtonsWidget tests (didUpdateWidget sync, display state)
/// 2. BookmarkNotifier unit tests (toggle, optimistic update, rollback)
/// 3. Manual testing on device
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

  group('ProfileDetailScreen Bookmark (Riverpod)', () {
    test('ProfileDetailScreen is ConsumerStatefulWidget (uses Riverpod ref)',
        () {
      expect(const ProfileDetailScreen(), isA<ConsumerStatefulWidget>());
    });

    test('bookmark state flows from isBookmarkedProvider to displayProfileData',
        () {
      // Verify the provider chain works (unit-level)
      container.read(bookmarkNotifierProvider.notifier).initializeBookmarks({
        'profile-1': true,
        'profile-2': false,
      });

      expect(container.read(isBookmarkedProvider('profile-1')), true);
      expect(container.read(isBookmarkedProvider('profile-2')), false);
    });

    test('toggle updates isBookmarkedProvider for ProfileDetailScreen consumption',
        () async {
      when(() => mockRepository.toggleBookmark('profile-1', true))
          .thenAnswer((_) async => BackendResponse.success(null));

      final notifier = container.read(bookmarkNotifierProvider.notifier);
      await notifier.toggle('profile-1');

      expect(container.read(isBookmarkedProvider('profile-1')), true);
      verify(() => mockRepository.toggleBookmark('profile-1', true)).called(1);
    });
  });
}
