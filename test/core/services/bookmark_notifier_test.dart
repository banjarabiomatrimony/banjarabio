import 'package:flutter_test/flutter_test.dart';
import 'package:banjarabio/core/services/bookmark_notifier.dart';

void main() {
  // Note: BookmarkNotifier is a singleton. We test it but ensure state is clean.
  late BookmarkNotifier notifier;

  setUp(() {
    notifier = BookmarkNotifier();
    notifier.clear(); // Clean state before each test
  });

  tearDown(() {
    notifier.clear();
  });

  group('BookmarkNotifier - isBookmarked', () {
    test('returns false for unknown profile', () {
      expect(notifier.isBookmarked('unknown_id'), false);
    });

    test('returns true after bookmark is added', () {
      notifier.updateBookmark('p1', true);

      expect(notifier.isBookmarked('p1'), true);
    });

    test('returns false after bookmark is removed', () {
      notifier.updateBookmark('p1', true);
      notifier.updateBookmark('p1', false);

      expect(notifier.isBookmarked('p1'), false);
    });
  });

  group('BookmarkNotifier - updateBookmark', () {
    test('notifies listeners when bookmark status changes', () {
      int notifyCount = 0;
      notifier.addListener(() => notifyCount++);

      notifier.updateBookmark('p1', true);

      expect(notifyCount, 1);
    });

    test('does not notify if bookmark status is unchanged', () {
      notifier.updateBookmark('p1', true);

      int notifyCount = 0;
      notifier.addListener(() => notifyCount++);

      notifier.updateBookmark('p1', true); // Same value

      expect(notifyCount, 0);
    });
  });

  group('BookmarkNotifier - removeBookmark', () {
    test('removes a tracked bookmark and notifies', () {
      notifier.updateBookmark('p1', true);
      int notifyCount = 0;
      notifier.addListener(() => notifyCount++);

      notifier.removeBookmark('p1');

      expect(notifier.isBookmarked('p1'), false);
      expect(notifyCount, 1);
    });

    test('does not notify when removing non-existent bookmark', () {
      int notifyCount = 0;
      notifier.addListener(() => notifyCount++);

      notifier.removeBookmark('non_existent');

      expect(notifyCount, 0);
    });
  });

  group('BookmarkNotifier - initializeBookmarks', () {
    test('initializes with provided map and notifies', () {
      int notifyCount = 0;
      notifier.addListener(() => notifyCount++);

      notifier.initializeBookmarks({'p1': true, 'p2': false, 'p3': true});

      expect(notifier.isBookmarked('p1'), true);
      expect(notifier.isBookmarked('p2'), false);
      expect(notifier.isBookmarked('p3'), true);
      expect(notifyCount, 1);
    });

    test('clears previous bookmarks on re-initialization', () {
      notifier.updateBookmark('old', true);
      notifier.initializeBookmarks({'new': true});

      expect(notifier.isBookmarked('old'), false);
      expect(notifier.isBookmarked('new'), true);
    });
  });

  group('BookmarkNotifier - clear', () {
    test('clears all bookmarks and notifies', () {
      notifier.updateBookmark('p1', true);
      notifier.updateBookmark('p2', true);

      int notifyCount = 0;
      notifier.addListener(() => notifyCount++);

      notifier.clear();

      expect(notifier.isBookmarked('p1'), false);
      expect(notifier.isBookmarked('p2'), false);
      expect(notifyCount, 1);
    });
  });
}
