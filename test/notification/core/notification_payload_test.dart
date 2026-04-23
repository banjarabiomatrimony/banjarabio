import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:banjarabio/notification/core/notification_payload.dart';

void main() {
  group('NotificationCategory', () {
    test('has 7 values', () {
      expect(NotificationCategory.values.length, 7);
    });

    test('contains all expected categories', () {
      final names = NotificationCategory.values.map((e) => e.name).toSet();
      expect(names, containsAll([
        'interestReceived', 'matchFound', 'chatMessage',
        'profileView', 'nudge', 'system', 'general',
      ]));
    });
  });

  group('NotificationAction', () {
    test('fromJson parses all fields', () {
      final action = NotificationAction.fromJson({
        'id': 'view',
        'label': 'View Profile',
        'route': '/profile/123',
      });

      expect(action.id, 'view');
      expect(action.label, 'View Profile');
      expect(action.route, '/profile/123');
    });

    test('fromJson handles missing fields', () {
      final action = NotificationAction.fromJson({});

      expect(action.id, '');
      expect(action.label, '');
      expect(action.route, isNull);
    });

    test('toJson produces correct map', () {
      const action = NotificationAction(
        id: 'reply',
        label: 'Reply',
        route: '/chat/456',
      );
      final json = action.toJson();

      expect(json['id'], 'reply');
      expect(json['label'], 'Reply');
      expect(json['route'], '/chat/456');
    });
  });

  group('NotificationPayload - constructor', () {
    test('creates with defaults', () {
      final payload = NotificationPayload();

      expect(payload.id, isNull);
      expect(payload.title, isNull);
      expect(payload.body, isNull);
      expect(payload.imageUrl, isNull);
      expect(payload.route, isNull);
      expect(payload.category, NotificationCategory.general);
      expect(payload.actions, isEmpty);
      expect(payload.data, isEmpty);
    });

    test('creates with all fields', () {
      final payload = NotificationPayload(
        id: 'n1',
        title: 'Test',
        body: 'Body text',
        imageUrl: 'https://img.com/photo.jpg',
        route: '/profile/123',
        category: NotificationCategory.matchFound,
        actions: const [NotificationAction(id: 'a1', label: 'View')],
        data: {'key': 'value'},
      );

      expect(payload.id, 'n1');
      expect(payload.title, 'Test');
      expect(payload.category, NotificationCategory.matchFound);
      expect(payload.actions.length, 1);
    });
  });

  group('NotificationPayload - fromFcm', () {
    test('parses FCM data with all fields', () {
      final payload = NotificationPayload.fromFcm(
        {
          'id': 'fcm1',
          'category': 'matchFound',
          'image': 'https://img.com/photo.jpg',
          'route': '/match/123',
          'sender_profile_id': 'p123',
        },
        title: 'Match Found!',
        body: 'You have a new match',
      );

      expect(payload.id, 'fcm1');
      expect(payload.title, 'Match Found!');
      expect(payload.body, 'You have a new match');
      expect(payload.imageUrl, 'https://img.com/photo.jpg');
      expect(payload.route, '/match/123');
      expect(payload.category, NotificationCategory.matchFound);
      expect(payload.senderProfileId, 'p123');
    });

    test('defaults to general category for unknown category', () {
      final payload = NotificationPayload.fromFcm(
        {'category': 'unknown_category'},
      );

      expect(payload.category, NotificationCategory.general);
    });

    test('uses fallback keys (message_id, image_url, click_action)', () {
      final payload = NotificationPayload.fromFcm({
        'message_id': 'msg1',
        'image_url': 'https://img.com/alt.jpg',
        'click_action': '/fallback',
      });

      expect(payload.id, 'msg1');
      expect(payload.imageUrl, 'https://img.com/alt.jpg');
      expect(payload.route, '/fallback');
    });

    test('parses actions from JSON string', () {
      final actionsJson = json.encode([
        {'id': 'view', 'label': 'View', 'route': '/profile'},
        {'id': 'dismiss', 'label': 'Dismiss'},
      ]);

      final payload = NotificationPayload.fromFcm({
        'actions': actionsJson,
      });

      expect(payload.actions.length, 2);
      expect(payload.actions[0].id, 'view');
      expect(payload.actions[1].id, 'dismiss');
    });

    test('parses actions from List directly', () {
      final payload = NotificationPayload.fromFcm({
        'actions': [
          {'id': 'a1', 'label': 'Action 1'},
        ],
      });

      expect(payload.actions.length, 1);
    });

    test('handles malformed actions gracefully', () {
      final payload = NotificationPayload.fromFcm({
        'actions': 'not_valid_json{{{',
      });

      expect(payload.actions, isEmpty);
    });

    test('uses title/body from fcmData when named params are null', () {
      final payload = NotificationPayload.fromFcm({
        'title': 'FCM Title',
        'body': 'FCM Body',
      });

      expect(payload.title, 'FCM Title');
      expect(payload.body, 'FCM Body');
    });
  });

  group('NotificationPayload - fromJsonString', () {
    test('parses valid JSON string', () {
      final jsonStr = json.encode({
        'id': 'local1',
        'title': 'Local Title',
        'body': 'Local Body',
        'imageUrl': 'https://img.com/photo.jpg',
        'route': '/home',
        'category': 'chatMessage',
        'actions': [
          {'id': 'reply', 'label': 'Reply'},
        ],
        'data': {'key': 'value'},
      });

      final payload = NotificationPayload.fromJsonString(jsonStr);

      expect(payload.id, 'local1');
      expect(payload.title, 'Local Title');
      expect(payload.category, NotificationCategory.chatMessage);
      expect(payload.actions.length, 1);
      expect(payload.data['key'], 'value');
    });

    test('returns empty payload for invalid JSON', () {
      final payload = NotificationPayload.fromJsonString('not{valid}json');

      expect(payload.id, isNull);
      expect(payload.title, isNull);
      expect(payload.category, NotificationCategory.general);
    });

    test('handles unknown category in JSON', () {
      final jsonStr = json.encode({
        'category': 'nonexistent',
      });

      final payload = NotificationPayload.fromJsonString(jsonStr);
      expect(payload.category, NotificationCategory.general);
    });
  });

  group('NotificationPayload - toJsonString', () {
    test('round-trips correctly', () {
      final original = NotificationPayload(
        id: 'rt1',
        title: 'Round Trip',
        body: 'Testing serialization',
        imageUrl: 'https://img.com/photo.jpg',
        route: '/test',
        category: NotificationCategory.interestReceived,
        actions: const [NotificationAction(id: 'a1', label: 'Act')],
        data: {'sender_name': 'Priya'},
      );

      final jsonStr = original.toJsonString();
      final restored = NotificationPayload.fromJsonString(jsonStr);

      expect(restored.id, 'rt1');
      expect(restored.title, 'Round Trip');
      expect(restored.body, 'Testing serialization');
      expect(restored.category, NotificationCategory.interestReceived);
      expect(restored.actions.length, 1);
    });
  });

  group('NotificationPayload - convenience getters', () {
    test('hasImage returns true when imageUrl is set', () {
      final payload = NotificationPayload(imageUrl: 'https://img.com/a.jpg');
      expect(payload.hasImage, true);
    });

    test('hasImage returns false for null or empty', () {
      expect(NotificationPayload().hasImage, false);
      expect(NotificationPayload(imageUrl: '').hasImage, false);
    });

    test('hasActions returns true when actions are non-empty', () {
      final payload = NotificationPayload(
        actions: const [NotificationAction(id: 'a', label: 'A')],
      );
      expect(payload.hasActions, true);
    });

    test('hasActions returns false for empty actions', () {
      expect(NotificationPayload().hasActions, false);
    });

    test('senderProfileId returns correct value', () {
      final payload = NotificationPayload(data: {'sender_profile_id': 'p1'});
      expect(payload.senderProfileId, 'p1');
    });

    test('senderProfileId returns null when not present', () {
      expect(NotificationPayload().senderProfileId, isNull);
    });

    test('toString contains key info', () {
      final payload = NotificationPayload(
        id: 'n1',
        title: 'Test',
        category: NotificationCategory.matchFound,
        route: '/match',
      );
      final str = payload.toString();
      expect(str, contains('n1'));
      expect(str, contains('Test'));
      expect(str, contains('matchFound'));
    });
  });
}
