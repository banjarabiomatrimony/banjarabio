import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:banjarabio/notification/features/smart_delivery_gate.dart';
import 'package:banjarabio/notification/core/notification_payload.dart';

void main() {
  late SmartDeliveryGate gate;

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    gate = SmartDeliveryGate();
    gate.reset();
  });

  NotificationPayload make({
    NotificationCategory cat = NotificationCategory.general,
    String id = 'n1',
  }) {
    return NotificationPayload(
      id: id,
      title: 'Test',
      body: 'Test body',
      category: cat,
    );
  }

  group('SmartDeliveryGate.shouldDeliver', () {
    test('allows first notification by default', () async {
      expect(await gate.shouldDeliver(make()), true);
    });

    test('rate-limits general category (10 min)', () async {
      expect(await gate.shouldDeliver(make()), true);
      // Second one immediately should be rate limited
      expect(await gate.shouldDeliver(make(id: 'n2')), false);
    });

    test('rate-limits profileView category (5 min)', () async {
      expect(await gate.shouldDeliver(make(cat: NotificationCategory.profileView)), true);
      expect(await gate.shouldDeliver(make(cat: NotificationCategory.profileView, id: 'n2')), false);
    });

    test('rate-limits nudge category (4 hours)', () async {
      expect(await gate.shouldDeliver(make(cat: NotificationCategory.nudge)), true);
      expect(await gate.shouldDeliver(make(cat: NotificationCategory.nudge, id: 'n2')), false);
    });

    test('does NOT rate-limit chatMessage', () async {
      expect(await gate.shouldDeliver(make(cat: NotificationCategory.chatMessage)), true);
      expect(await gate.shouldDeliver(make(cat: NotificationCategory.chatMessage, id: 'n2')), true);
    });

    test('does NOT rate-limit matchFound', () async {
      expect(await gate.shouldDeliver(make(cat: NotificationCategory.matchFound)), true);
      expect(await gate.shouldDeliver(make(cat: NotificationCategory.matchFound, id: 'n2')), true);
    });

    test('does NOT rate-limit interestReceived', () async {
      expect(await gate.shouldDeliver(make(cat: NotificationCategory.interestReceived)), true);
      expect(await gate.shouldDeliver(make(cat: NotificationCategory.interestReceived, id: 'n2')), true);
    });

    test('blocks when category is disabled', () async {
      SharedPreferences.setMockInitialValues({
        'notif_category_general': false,
      });
      expect(await gate.shouldDeliver(make()), false);
    });

    test('allows chatMessage even during quiet hours', () async {
      SharedPreferences.setMockInitialValues({
        'quiet_hours_start': 0,
        'quiet_hours_end': 23,
      });
      // Chat should always go through
      expect(await gate.shouldDeliver(make(cat: NotificationCategory.chatMessage)), true);
    });

    test('different categories have independent rate limits', () async {
      expect(await gate.shouldDeliver(make()), true);
      // Different category should still be allowed
      expect(await gate.shouldDeliver(make(cat: NotificationCategory.profileView)), true);
    });
  });

  group('SmartDeliveryGate.reset', () {
    test('clears rate limit history', () async {
      await gate.shouldDeliver(make());
      // Should be rate limited
      expect(await gate.shouldDeliver(make(id: 'n2')), false);
      // After reset
      gate.reset();
      expect(await gate.shouldDeliver(make(id: 'n3')), true);
    });
  });
}
