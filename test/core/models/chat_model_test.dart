import 'package:flutter_test/flutter_test.dart';
import 'package:banjarabio/core/models/chat_model.dart';

void main() {
  group('ConversationModel', () {
    test('fromJson parses all fields correctly', () {
      final json = {
        'id': 'conv1',
        'participant_one_id': 'p1',
        'participant_two_id': 'p2',
        'last_message_text': 'Hello',
        'last_message_at': '2025-01-01T10:00:00Z',
        'unread_count_one': 3,
        'unread_count_two': 0,
        'created_at': '2024-01-01T00:00:00Z',
        'updated_at': '2025-01-01T10:00:00Z',
        'other_participant_name': 'John',
        'other_participant_image_url': 'https://example.com/img.jpg',
      };

      final model = ConversationModel.fromJson(json);

      expect(model.id, 'conv1');
      expect(model.participantOneId, 'p1');
      expect(model.participantTwoId, 'p2');
      expect(model.lastMessageText, 'Hello');
      expect(model.unreadCountOne, 3);
      expect(model.unreadCountTwo, 0);
      expect(model.otherParticipantName, 'John');
      expect(model.otherParticipantImageUrl, 'https://example.com/img.jpg');
    });

    test('fromJson handles null/missing fields gracefully', () {
      final json = <String, dynamic>{};
      final model = ConversationModel.fromJson(json);

      expect(model.id, '');
      expect(model.participantOneId, '');
      expect(model.lastMessageText, isNull);
      expect(model.unreadCountOne, 0);
      expect(model.otherParticipantName, isNull);
    });

    test('equatable compares relevant props', () {
      final a = ConversationModel.fromJson({
        'id': 'c1', 'last_message_at': '2025-01-01T00:00:00Z',
        'unread_count_one': 1, 'unread_count_two': 0,
        'created_at': '2025-01-01T00:00:00Z', 'updated_at': '2025-01-01T00:00:00Z',
      });
      final b = ConversationModel.fromJson({
        'id': 'c1', 'last_message_at': '2025-01-01T00:00:00Z',
        'unread_count_one': 1, 'unread_count_two': 0,
        'created_at': '2025-01-01T00:00:00Z', 'updated_at': '2025-01-01T00:00:00Z',
      });
      expect(a, equals(b));
    });
  });

  group('MessageModel', () {
    test('fromJson parses all fields', () {
      final json = {
        'id': 'msg1',
        'conversation_id': 'conv1',
        'sender_id': 'u1',
        'message_text': 'Hi there',
        'is_read': true,
        'created_at': '2025-01-01T10:00:00Z',
      };

      final model = MessageModel.fromJson(json);

      expect(model.id, 'msg1');
      expect(model.conversationId, 'conv1');
      expect(model.senderId, 'u1');
      expect(model.messageText, 'Hi there');
      expect(model.isRead, true);
    });

    test('fromJson handles null fields', () {
      final model = MessageModel.fromJson({});

      expect(model.id, '');
      expect(model.messageText, '');
      expect(model.isRead, false);
    });
  });

  group('ProfileViewModel', () {
    test('fromJson parses all fields', () {
      final json = {
        'id': 'view1',
        'viewer_id': 'u1',
        'viewed_id': 'u2',
        'view_count': 5,
        'last_viewed_at': '2025-01-01T10:00:00Z',
        'viewer_name': 'Alice',
        'viewer_image_url': 'https://img.url',
      };

      final model = ProfileViewModel.fromJson(json);

      expect(model.id, 'view1');
      expect(model.viewerId, 'u1');
      expect(model.viewedId, 'u2');
      expect(model.viewCount, 5);
      expect(model.viewerName, 'Alice');
    });

    test('fromJson defaults viewCount to 1', () {
      final model = ProfileViewModel.fromJson({});
      expect(model.viewCount, 1);
    });
  });
}
