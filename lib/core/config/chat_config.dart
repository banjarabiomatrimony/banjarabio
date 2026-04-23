/// Chat/notification configuration – single source of truth.
///
/// Must match SQL: 15_chat_and_notifications.sql.
/// Conversations are created by fn_create_chat_on_match trigger when profile_shares status = 'matched'.
abstract class ChatConfig {
  ChatConfig._();

  /// fn_manage_chat RPC actions.
  static const String actionGetOrCreateConversation = 'get_or_create_conversation';
  static const String actionSendMessage = 'send_message';
  static const String actionMarkAsRead = 'mark_as_read';
  static const String actionTrackView = 'track_view';

  /// Payload keys for fn_manage_chat.
  static const String payloadConversationId = 'conversation_id';
  static const String payloadOtherUserId = 'other_user_id';
  static const String payloadMessageText = 'message_text';
  static const String payloadViewedId = 'viewed_id';
}
