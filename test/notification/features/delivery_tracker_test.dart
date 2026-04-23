import 'package:flutter_test/flutter_test.dart';
import 'package:fake_async/fake_async.dart';
import 'package:banjarabio/notification/features/delivery_tracker.dart';
import 'package:banjarabio/notification/core/notification_payload.dart';

void main() {
  late DeliveryTracker tracker;

  setUp(() {
    tracker = DeliveryTracker();
    tracker.dispose(); // Clear any leftover state from singleton
  });

  tearDown(() {
    tracker.dispose();
  });

  NotificationPayload makePayload({
    String? id,
    NotificationCategory category = NotificationCategory.general,
  }) {
    return NotificationPayload(
      id: id ?? 'test-notif',
      title: 'Test',
      body: 'Test body',
      category: category,
    );
  }

  group('DeliveryTracker.trackDelivery', () {
    test('increments pendingCount', () {
      tracker.trackDelivery(makePayload(id: 'n1'));
      expect(tracker.pendingCount, 1);

      tracker.trackDelivery(makePayload(id: 'n2'));
      expect(tracker.pendingCount, 2);
    });
  });

  group('DeliveryTracker.markAsSeen', () {
    test('removes notification from tracking', () {
      tracker.trackDelivery(makePayload(id: 'n1'));
      tracker.markAsSeen('n1');
      expect(tracker.pendingCount, 0);
    });

    test('does nothing for unknown notification', () {
      tracker.markAsSeen('nonexistent');
      expect(tracker.pendingCount, 0);
    });
  });

  group('DeliveryTracker.markAllAsSeen', () {
    test('clears all tracked notifications', () {
      tracker.trackDelivery(makePayload(id: 'n1'));
      tracker.trackDelivery(makePayload(id: 'n2'));
      tracker.markAllAsSeen();
      expect(tracker.pendingCount, 0);
    });
  });

  group('DeliveryTracker.dispose', () {
    test('cancels all timers and clears records', () {
      tracker.trackDelivery(makePayload(id: 'n1'));
      tracker.dispose();
      expect(tracker.pendingCount, 0);
    });
  });

  group('DeliveryTracker escalation', () {
    test('fires onEscalationNeeded after window expires', () {
      fakeAsync((async) {
        NotificationPayload? escalated;
        tracker.onEscalationNeeded = (p) => escalated = p;

        tracker.trackDelivery(makePayload(
          id: 'n1',
        ));

        // Advance past the 15-minute default escalation window
        async.elapse(const Duration(minutes: 16));

        expect(escalated, isNotNull);
        expect(escalated!.id, 'n1');
        expect(tracker.pendingCount, 0);
      });
    });

    test('uses 5-minute window for high-priority categories', () {
      fakeAsync((async) {
        NotificationPayload? escalated;
        tracker.onEscalationNeeded = (p) => escalated = p;

        tracker.trackDelivery(makePayload(
          id: 'match1',
          category: NotificationCategory.matchFound,
        ));

        async.elapse(const Duration(minutes: 3));
        expect(escalated, isNull); // Not yet

        async.elapse(const Duration(minutes: 3));
        expect(escalated, isNotNull); // After 6 min > 5 min
      });
    });

    test('markAsSeen cancels escalation', () {
      fakeAsync((async) {
        NotificationPayload? escalated;
        tracker.onEscalationNeeded = (p) => escalated = p;

        tracker.trackDelivery(makePayload(id: 'n1'));
        tracker.markAsSeen('n1');

        async.elapse(const Duration(minutes: 20));
        expect(escalated, isNull); // Timer was cancelled
      });
    });
  });
}
