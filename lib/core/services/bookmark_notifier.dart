import 'package:flutter/foundation.dart';

/// Global notifier for bookmark state changes
/// Broadcasts bookmark updates across all screens for real-time synchronization
class BookmarkNotifier extends ChangeNotifier {
  static final BookmarkNotifier _instance = BookmarkNotifier._internal();
  factory BookmarkNotifier() => _instance;
  BookmarkNotifier._internal();

  // Map of profileId -> isBookmarked
  final Map<String, bool> _bookmarks = {};

  /// Get bookmark status for a profile
  bool isBookmarked(String profileId) {
    return _bookmarks[profileId] ?? false;
  }

  /// Update bookmark status and notify listeners
  void updateBookmark(String profileId, bool isBookmarked) {
    if (_bookmarks[profileId] != isBookmarked) {
      _bookmarks[profileId] = isBookmarked;
      notifyListeners();
      debugPrint('📌 [BookmarkNotifier] Updated: $profileId -> $isBookmarked');
    }
  }

  /// Remove bookmark from tracking
  void removeBookmark(String profileId) {
    if (_bookmarks.containsKey(profileId)) {
      _bookmarks.remove(profileId);
      notifyListeners();
      debugPrint('📌 [BookmarkNotifier] Removed: $profileId');
    }
  }

  /// Initialize bookmarks from a list of profile IDs
  void initializeBookmarks(Map<String, bool> bookmarks) {
    _bookmarks.clear();
    _bookmarks.addAll(bookmarks);
    notifyListeners();
    debugPrint(
      '📌 [BookmarkNotifier] Initialized ${bookmarks.length} bookmarks',
    );
  }

  /// Clear all bookmarks
  void clear() {
    _bookmarks.clear();
    notifyListeners();
    debugPrint('📌 [BookmarkNotifier] Cleared all bookmarks');
  }
}
