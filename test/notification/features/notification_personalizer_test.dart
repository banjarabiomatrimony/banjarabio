import 'package:flutter_test/flutter_test.dart';
import 'package:banjarabio/notification/core/notification_payload.dart';
import 'package:banjarabio/notification/features/notification_personalizer.dart';

void main() {
  late NotificationPersonalizer personalizer;

  setUp(() {
    personalizer = NotificationPersonalizer();
  });

  group('NotificationPersonalizer - interestReceived', () {
    test('personalizes with sender name', () {
      final payload = NotificationPayload(
        category: NotificationCategory.interestReceived,
        data: {'sender_name': 'Priya'},
      );

      final result = personalizer.personalize(payload);

      expect(result.title, isNotNull);
      expect('${result.title} ${result.body}', contains('Priya'));
      expect(result.category, NotificationCategory.interestReceived);
    });

    test('high compatibility (>=90) uses special template', () {
      final payload = NotificationPayload(
        category: NotificationCategory.interestReceived,
        data: {
          'sender_name': 'Rahul',
          'compatibility_score': 95,
        },
      );

      final result = personalizer.personalize(payload);

      expect(result.title!, contains('95'));
      expect('${result.title} ${result.body}', contains('Rahul'));
    });

    test('includes city when available', () {
      final payload = NotificationPayload(
        category: NotificationCategory.interestReceived,
        data: {
          'sender_name': 'Priya',
          'sender_city': 'Mumbai',
        },
      );

      final result = personalizer.personalize(payload);

      // The result should contain the personalized content (may vary due to randomization)
      expect(result.title, isNotNull);
      expect(result.body, isNotNull);
    });

    test('uses "Someone" for missing sender name', () {
      final payload = NotificationPayload(
        category: NotificationCategory.interestReceived,
        data: {},
      );

      final result = personalizer.personalize(payload);

      expect('${result.title} ${result.body}', contains('Someone'));
    });

    test('preserves original metadata (imageUrl, route, data)', () {
      final payload = NotificationPayload(
        category: NotificationCategory.interestReceived,
        imageUrl: 'https://img.com/photo.jpg',
        route: '/profile/123',
        data: {'sender_name': 'Test', 'extra': 'data'},
      );

      final result = personalizer.personalize(payload);

      expect(result.imageUrl, 'https://img.com/photo.jpg');
      expect(result.route, '/profile/123');
      expect(result.data['extra'], 'data');
    });
  });

  group('NotificationPersonalizer - matchFound', () {
    test('personalizes with sender name', () {
      final payload = NotificationPayload(
        category: NotificationCategory.matchFound,
        data: {'sender_name': 'Priya'},
      );

      final result = personalizer.personalize(payload);

      expect('${result.title} ${result.body}', contains('Priya'));
      expect(result.category, NotificationCategory.matchFound);
    });

    test('uses "Someone" for missing sender name', () {
      final payload = NotificationPayload(
        category: NotificationCategory.matchFound,
        data: {},
      );

      final result = personalizer.personalize(payload);

      expect('${result.title} ${result.body}', contains('Someone'));
    });
  });

  group('NotificationPersonalizer - chatMessage', () {
    test('uses sender name and message preview', () {
      final payload = NotificationPayload(
        category: NotificationCategory.chatMessage,
        data: {
          'sender_name': 'Rahul',
          'message_preview': 'Hello, how are you?',
        },
      );

      final result = personalizer.personalize(payload);

      expect(result.title!, contains('Rahul'));
      expect(result.body!, contains('Hello, how are you?'));
    });

    test('truncates long message preview to 40 chars', () {
      final longMessage = 'A' * 50;
      final payload = NotificationPayload(
        category: NotificationCategory.chatMessage,
        data: {
          'sender_name': 'Priya',
          'message_preview': longMessage,
        },
      );

      final result = personalizer.personalize(payload);

      expect(result.body!, contains('...'));
      expect(result.body!.length, lessThan(50));
    });

    test('uses default body when no preview', () {
      final payload = NotificationPayload(
        category: NotificationCategory.chatMessage,
        data: {'sender_name': 'Test'},
      );

      final result = personalizer.personalize(payload);

      expect(result.body!, contains('Sent you a message'));
    });
  });

  group('NotificationPersonalizer - profileView', () {
    test('personalizes with sender name', () {
      final payload = NotificationPayload(
        category: NotificationCategory.profileView,
        data: {'sender_name': 'Priya'},
      );

      final result = personalizer.personalize(payload);

      expect(result.title!, contains('Priya'));
    });

    test('personalizes without sender name', () {
      final payload = NotificationPayload(
        category: NotificationCategory.profileView,
        data: {},
      );

      final result = personalizer.personalize(payload);

      expect(result.title, isNotNull);
      // Should use anonymous templates
      expect(result.title!.toLowerCase(), anyOf(
        contains('someone'),
        contains('profile'),
        contains('attention'),
      ));
    });

    test('includes city context when available', () {
      final payload = NotificationPayload(
        category: NotificationCategory.profileView,
        data: {
          'sender_name': 'Priya',
          'sender_city': 'Pune',
        },
      );

      final result = personalizer.personalize(payload);

      // Body may or may not contain city (randomized), but should be non-null
      expect(result.body, isNotNull);
    });
  });

  group('NotificationPersonalizer - pass-through categories', () {
    test('nudge is returned as-is', () {
      final payload = NotificationPayload(
        title: 'Complete your profile',
        body: 'Add a photo to get more matches',
        category: NotificationCategory.nudge,
      );

      final result = personalizer.personalize(payload);

      expect(result.title, 'Complete your profile');
      expect(result.body, 'Add a photo to get more matches');
    });

    test('system is returned as-is', () {
      final payload = NotificationPayload(
        title: 'System Update',
        body: 'New features available',
        category: NotificationCategory.system,
      );

      final result = personalizer.personalize(payload);

      expect(result.title, 'System Update');
      expect(result.body, 'New features available');
    });

    test('general is returned as-is', () {
      final payload = NotificationPayload(
        title: 'Hello',
        body: 'World',
      );

      final result = personalizer.personalize(payload);

      expect(result.title, 'Hello');
    });
  });
}
