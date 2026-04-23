import 'package:flutter_test/flutter_test.dart';
import 'package:banjarabio/core/models/chat_model.dart';

void main() {
  group('ConversationModel', () {
    test('fromJson parses all fields', () {
      final c = ConversationModel.fromJson({
        'id': 'c1',
        'participant_one_id': 'u1',
        'participant_two_id': 'u2',
        'last_message_text': 'Hello',
        'last_message_at': '2025-06-01T10:00:00Z',
        'unread_count_one': 3,
        'unread_count_two': 0,
        'created_at': '2025-01-01T00:00:00Z',
        'updated_at': '2025-06-01T10:00:00Z',
        'other_participant_name': 'Priya',
        'other_participant_image_url': 'https://cdn/img.jpg',
      });
      expect(c.id, 'c1');
      expect(c.participantOneId, 'u1');
      expect(c.participantTwoId, 'u2');
      expect(c.lastMessageText, 'Hello');
      expect(c.unreadCountOne, 3);
      expect(c.unreadCountTwo, 0);
      expect(c.otherParticipantName, 'Priya');
    });

    test('defaults for missing fields', () {
      final c = ConversationModel.fromJson({});
      expect(c.id, '');
      expect(c.unreadCountOne, 0);
      expect(c.lastMessageText, isNull);
    });

    test('handles invalid dates', () {
      final c = ConversationModel.fromJson({'last_message_at': 'invalid'});
      expect(c.lastMessageAt.year, DateTime.now().year);
    });
  });

  group('MessageModel', () {
    test('fromJson parses all fields', () {
      final m = MessageModel.fromJson({
        'id': 'm1',
        'conversation_id': 'c1',
        'sender_id': 'u1',
        'message_text': 'Hello there',
        'is_read': true,
        'created_at': '2025-06-01T10:00:00Z',
      });
      expect(m.id, 'm1');
      expect(m.messageText, 'Hello there');
      expect(m.isRead, true);
    });

    test('defaults for missing fields', () {
      final m = MessageModel.fromJson({});
      expect(m.messageText, '');
      expect(m.isRead, false);
    });
  });

  group('ProfileViewModel', () {
    test('fromJson parses all fields', () {
      final v = ProfileViewModel.fromJson({
        'id': 'v1', 'viewer_id': 'u1', 'viewed_id': 'u2',
        'view_count': 5, 'last_viewed_at': '2025-06-01T10:00:00Z',
        'viewer_name': 'Rahul',
      });
      expect(v.viewCount, 5);
      expect(v.viewerName, 'Rahul');
    });

    test('defaults for missing fields', () {
      final v = ProfileViewModel.fromJson({});
      expect(v.viewCount, 1);
      expect(v.viewerName, isNull);
    });
  });
}
