import 'package:banjarabio/core/models/backend_response.dart';

/// Abstract repository interface for bookmark operations.
/// This allows for easy testing and swapping implementations.
abstract class BookmarkRepository {
  /// Toggle bookmark status for a profile.
  /// Returns success response if operation completed.
  Future<BackendResponse<void>> toggleBookmark(
    String profileId,
    bool isAdd,
  );

  /// Get list of bookmarked profile IDs for current user.
  Future<BackendResponse<List<String>>> getBookmarkedProfileIds();

  /// Clear all bookmarks for current user.
  Future<BackendResponse<void>> clearAllBookmarks();
}
