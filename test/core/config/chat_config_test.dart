import 'package:flutter_test/flutter_test.dart';
import 'package:banjarabio/core/config/chat_config.dart';

void main() {
  group('ChatConfig - constants', () {
    test('actionGetOrCreateConversation is correct', () {
      expect(ChatConfig.actionGetOrCreateConversation, 'get_or_create_conversation');
    });

    test('actionSendMessage is correct', () {
      expect(ChatConfig.actionSendMessage, 'send_message');
    });

    test('actionMarkAsRead is correct', () {
      expect(ChatConfig.actionMarkAsRead, 'mark_as_read');
    });

    test('actionTrackView is correct', () {
      expect(ChatConfig.actionTrackView, 'track_view');
    });

    test('payloadConversationId is correct', () {
      expect(ChatConfig.payloadConversationId, 'conversation_id');
    });

    test('payloadOtherUserId is correct', () {
      expect(ChatConfig.payloadOtherUserId, 'other_user_id');
    });

    test('payloadMessageText is correct', () {
      expect(ChatConfig.payloadMessageText, 'message_text');
    });

    test('payloadViewedId is correct', () {
      expect(ChatConfig.payloadViewedId, 'viewed_id');
    });
  });
}
