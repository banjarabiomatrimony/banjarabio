import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:banjarabio/core/models/backend_response.dart';
import 'package:banjarabio/features/bookmarks/repository/bookmark_repository.dart';

/// Supabase implementation of BookmarkRepository.
/// Uses fn_manage_bookmarks RPC function.
class BookmarkRepositoryImpl implements BookmarkRepository {
  final SupabaseClient _supabase;

  BookmarkRepositoryImpl({SupabaseClient? supabase})
      : _supabase = supabase ?? Supabase.instance.client;

  @override
  Future<BackendResponse<void>> toggleBookmark(
    String profileId,
    bool isAdd,
  ) async {
    final action = isAdd ? 'add' : 'remove';
    try {
      final response = await _supabase.rpc(
        'fn_manage_bookmarks',
        params: {
          'action': action,
          'payload': {'profile_id': profileId},
        },
      );
      return BackendResponse.fromRpc(response);
    } catch (e) {
      // Handle race condition where user double taps
      if (e.toString().contains('duplicate')) {
        return BackendResponse.success(null);
      }
      return BackendResponse.failure(e.toString());
    }
  }

  @override
  Future<BackendResponse<List<String>>> getBookmarkedProfileIds() async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) {
        return BackendResponse.failure('Not authenticated');
      }

      final response = await _supabase
          .from('bookmarks')
          .select('profile_id')
          .eq('user_id', userId);

      final profileIds = (response as List)
          .map((item) => item['profile_id'] as String)
          .toList();

      return BackendResponse.success(profileIds);
    } catch (e) {
      return BackendResponse.failure(e.toString());
    }
  }

  @override
  Future<BackendResponse<void>> clearAllBookmarks() async {
    try {
      final response = await _supabase.rpc(
        'fn_manage_bookmarks',
        params: {
          'action': 'clear_all',
          'payload': <String, dynamic>{},
        },
      );
      return BackendResponse.fromRpc(response);
    } catch (e) {
      return BackendResponse.failure(e.toString());
    }
  }
}
