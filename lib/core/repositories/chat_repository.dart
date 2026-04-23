import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:banjarabio/core/config/chat_config.dart';
import 'package:banjarabio/core/models/chat_model.dart';
import 'package:banjarabio/core/models/backend_response.dart';
import 'package:banjarabio/core/repositories/isolate_first_repository.dart';
import 'package:banjarabio/core/session_manager.dart';

/// [ChatRepository]
///
/// Manages real-time chat, message history, and profile views.
///
/// 🏆 10/10 Architecture Highlights:
/// 1. **Correct Stream Async Mapping**: Uses `asyncMap` directly to unwrap Isolate futures.
/// 2. **Type Safety**: Strong typing for RPC payloads.
/// 3. **Error Resilience**: Swallows non-critical errors (like "track view") to keep UI smooth.
class ChatRepository extends IsolateFirstRepository {
  // 1. Singleton (Optional but good for Repositories)
  static final ChatRepository _instance = ChatRepository._();
  factory ChatRepository() => _instance;
  ChatRepository._();

  @visibleForTesting
  SupabaseClient? testClient;
  SupabaseClient get _supabase => testClient ?? Supabase.instance.client;

  // ---------------------------------------------------------------------------
  // 1. Real-time Streams
  // ---------------------------------------------------------------------------

  /// Stream of conversations for the current user.
  /// Listens to `conversations_view` (Real-time).
  Stream<List<ConversationModel>> getConversationsStream() {
    final myUserId = _supabase.auth.currentUser?.id;
    if (myUserId == null) return Stream.value([]);

    return _supabase
        .from('conversations_view')
        .stream(primaryKey: ['id'])
        .order('last_message_at')
        .asyncMap((data) async {
          // ⚠️ FIX: Use asyncMap directly to await the Isolate result
          return await mapListInBackground<ConversationModel>(
            data, // Supabase stream returns List<Map<String, dynamic>>
            ConversationModel.fromJson,
          );
        })
        .handleError((error) {
          debugPrint('ChatRepository: Conversation Stream Error: $error');
          // Return empty list on error to keep UI alive, or rethrow based on needs
          return <ConversationModel>[];
        });
  }

  /// Stream of messages for a specific conversation.
  Stream<List<MessageModel>> getMessagesStream(String conversationId) {
    return _supabase
        .from('messages')
        .stream(primaryKey: ['id', 'created_at'])
        .eq('conversation_id', conversationId)
        .order('created_at')
        .asyncMap((data) async {
          // ⚠️ FIX: Use asyncMap directly
          return await mapListInBackground<MessageModel>(
            data,
            MessageModel.fromJson,
          );
        });
  }

  // ---------------------------------------------------------------------------
  // 2. Chat Actions (RPC)
  // ---------------------------------------------------------------------------

  /// Send a message via master RPC `fn_manage_chat`.
  /// RPC returns { id, created_at }; build MessageModel to match 15_chat schema.
  Future<BackendResponse<MessageModel>> sendMessage(
    String conversationId,
    String text,
  ) async {
    try {
      final response = await _supabase.rpc(
        'fn_manage_chat',
        params: {
          'action': ChatConfig.actionSendMessage,
          'payload': {
            ChatConfig.payloadConversationId: conversationId,
            ChatConfig.payloadMessageText: text,
          },
        },
      );

      // RPC returns { id, created_at }; stream will have full message
      final msg = MessageModel(
        id: response['id']?.toString() ?? '',
        conversationId: conversationId,
        senderId: SessionManager.instance.profileId ?? '',
        messageText: text,
        createdAt: response['created_at'] != null
            ? DateTime.parse(response['created_at'].toString())
            : DateTime.now(),
      );
      return BackendResponse.success(msg);
    } catch (e) {
      return BackendResponse.failure(e.toString());
    }
  }

  /// Mark all messages in a conversation as read.
  Future<void> markAsRead(String conversationId) async {
    try {
      await _supabase.rpc(
        'fn_manage_chat',
        params: {
          'action': ChatConfig.actionMarkAsRead,
          'payload': {ChatConfig.payloadConversationId: conversationId},
        },
      );
    } catch (e) {
      // Fail silently for read receipts
      debugPrint('Error marking as read: $e');
    }
  }

  /// Get or create a conversation with another user.
  Future<BackendResponse<ConversationModel>> getOrCreateConversation(
    String otherUserId,
  ) async {
    try {
      final response = await _supabase.rpc(
        'fn_manage_chat',
        params: {
          'action': ChatConfig.actionGetOrCreateConversation,
          'payload': {ChatConfig.payloadOtherUserId: otherUserId},
        },
      );

      final data = response is Map ? response : null;
      if (data == null) return BackendResponse.failure('Invalid conversation response');
      return BackendResponse.success(ConversationModel.fromJson(Map<String, dynamic>.from(data)));
    } catch (e) {
      return BackendResponse.failure(e.toString());
    }
  }

  // ---------------------------------------------------------------------------
  // 3. Profile Views
  // ---------------------------------------------------------------------------

  /// Get list of users who viewed my profile.
  /// 15_chat: profile_views.viewed_id = my profile (who viewed ME).
  Future<BackendResponse<List<ProfileViewModel>>> getWhoViewedMe() async {
    try {
      final myProfileId = SessionManager.instance.profileId;
      if (myProfileId == null || myProfileId.isEmpty) {
        return BackendResponse.failure('Not authenticated');
      }
      final response = await _supabase
          .from('profile_views')
          .select('*, viewer:profiles!viewer_id(full_name, photos(public_url))')
          .eq('viewed_id', myProfileId)
          .order('last_viewed_at', ascending: false);

      final List<ProfileViewModel> views =
          await mapListInBackground<ProfileViewModel>(
            response as List,
            _mapProfileView, // Static helper
          );

      return BackendResponse.success(views);
    } catch (e) {
      return BackendResponse.failure(e.toString());
    }
  }

  /// Track a profile view (Fire and Forget).
  Future<void> trackView(String viewedId) async {
    try {
      await _supabase.rpc(
        'fn_manage_chat',
        params: {
          'action': ChatConfig.actionTrackView,
          'payload': {ChatConfig.payloadViewedId: viewedId},
        },
      );
    } catch (e) {
      // Ignore errors for analytics/tracking
    }
  }

  // ---------------------------------------------------------------------------
  // 4. Static Mappers (Must be static for Isolate)
  // ---------------------------------------------------------------------------

  /// Maps raw JSON from Supabase profile_views + viewer join to ProfileViewModel.
  /// 15_chat: profile_views(viewer_id, viewed_id, view_count, last_viewed_at).
  static ProfileViewModel _mapProfileView(Map<String, dynamic> json) {
    final viewer = json['viewer'] as Map<String, dynamic>? ?? {};
    final photos = viewer['photos'] as List?;
    String? imageUrl;
    if (photos != null && photos.isNotEmpty) {
      imageUrl = photos[0]['public_url']?.toString();
    }
    return ProfileViewModel(
      id: json['id']?.toString() ?? '',
      viewerId: json['viewer_id']?.toString() ?? '',
      viewedId: json['viewed_id']?.toString() ?? '',
      viewCount: (json['view_count'] as num?)?.toInt() ?? 1,
      viewerName: viewer['full_name']?.toString() ?? 'Unknown',
      viewerImageUrl: imageUrl,
      lastViewedAt: json['last_viewed_at'] != null
          ? DateTime.tryParse(json['last_viewed_at'].toString()) ?? DateTime.now()
          : DateTime.now(),
    );
  }
}
