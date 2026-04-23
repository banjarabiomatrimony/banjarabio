import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:banjarabio/features/bookmarks/repository/bookmark_repository.dart';
import 'package:banjarabio/features/bookmarks/repository/bookmark_repository_impl.dart';

/// Riverpod Notifier for managing bookmark state.
/// Maintains a Map of String to bool where key is profileId and value is isBookmarked.
class BookmarkNotifier extends Notifier<Map<String, bool>> {
  BookmarkRepository? _repository;

  @override
  Map<String, bool> build() {
    // Initialize repository (can be overridden in tests)
    _repository = ref.read(bookmarkRepositoryProvider);
    return {};
  }

  /// Get bookmark repository instance.
  BookmarkRepository get repository {
    return _repository ?? BookmarkRepositoryImpl();
  }

  /// Check if a profile is bookmarked.
  bool isBookmarked(String profileId) {
    return state[profileId] ?? false;
  }

  /// Toggle bookmark status for a profile.
  /// Performs optimistic update, then syncs with backend.
  Future<void> toggle(String profileId) async {
    final currentStatus = isBookmarked(profileId);
    final newStatus = !currentStatus;
    if (kDebugMode) {
      debugPrint('[BOOKMARK] BookmarkNotifier > toggle($profileId) > was: $currentStatus -> now: $newStatus > Optimistic update');
    }

    // Optimistic update
    state = {...state, profileId: newStatus};

    try {
      // Sync with backend
      final result = await repository.toggleBookmark(profileId, newStatus);

      await result.fold(
        onSuccess: (_) {
          if (kDebugMode) {
            debugPrint('[BOOKMARK] BookmarkNotifier > toggle($profileId) > Backend sync SUCCESS');
          }
        },
        onFailure: (error) {
          // Rollback on error
          state = {...state, profileId: currentStatus};
          if (kDebugMode) {
            debugPrint('[BOOKMARK] BookmarkNotifier > toggle($profileId) > Backend FAILED > Rollback to $currentStatus | error: $error');
          }
          throw Exception(error);
        },
      );
    } catch (e) {
      // Rollback on exception
      state = {...state, profileId: currentStatus};
      if (kDebugMode) {
        debugPrint('[BOOKMARK] BookmarkNotifier > toggle($profileId) > Exception > Rollback to $currentStatus | $e');
      }
      rethrow;
    }
  }

  /// Initialize bookmarks from a map of profile IDs.
  void initializeBookmarks(Map<String, bool> bookmarks) {
    state = Map<String, bool>.from(bookmarks);
    if (kDebugMode) {
      final count = bookmarks.values.where((v) => v).length;
      debugPrint(
        '[BOOKMARK] BookmarkNotifier > initializeBookmarks > ${bookmarks.length} profiles, $count bookmarked',
      );
    }
  }

  /// Remove a bookmark from state (local only).
  /// Use toggle() for backend sync.
  void removeBookmark(String profileId) {
    if (state.containsKey(profileId)) {
      final newState = Map<String, bool>.from(state);
      newState.remove(profileId);
      state = newState;
    }
  }

  /// Clear all bookmarks.
  Future<void> clearAll() async {
    final previousState = Map<String, bool>.from(state);

    // Optimistic update
    state = {};

    try {
      final result = await repository.clearAllBookmarks();

      await result.fold(
        onSuccess: (_) {
          // Success - state already cleared
        },
        onFailure: (error) {
          // Rollback on error
          state = previousState;
          throw Exception(error);
        },
      );
    } catch (e) {
      // Rollback on exception
      state = previousState;
      rethrow;
    }
  }
}

/// Provider for BookmarkRepository.
/// Can be overridden in tests with mock implementation.
final bookmarkRepositoryProvider = Provider<BookmarkRepository>((ref) {
  return BookmarkRepositoryImpl();
});

/// Provider for BookmarkNotifier.
/// This is the main provider that screens should use.
final bookmarkNotifierProvider =
    NotifierProvider<BookmarkNotifier, Map<String, bool>>(
  BookmarkNotifier.new,
);

/// Convenience provider to check if a specific profile is bookmarked.
/// Usage: ref.watch(isBookmarkedProvider('profile-id'))
final isBookmarkedProvider = Provider.family<bool, String>((ref, profileId) {
  return ref.watch(bookmarkNotifierProvider)[profileId] ?? false;
});
