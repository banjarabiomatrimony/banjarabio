import 'package:fake_async/fake_async.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:banjarabio/notification/core/notification_payload.dart';
import 'package:banjarabio/notification/features/notification_batcher.dart';

void main() {
  late NotificationBatcher batcher;
  late List<NotificationPayload> deliveredBatches;

  setUp(() {
    batcher = NotificationBatcher();
    batcher.dispose(); // Clear any previous state
    deliveredBatches = [];
    batcher.onBatchReady = (payload) => deliveredBatches.add(payload);
  });

  tearDown(() {
    batcher.dispose();
  });

  NotificationPayload makePayload({
    NotificationCategory category = NotificationCategory.profileView,
    String? id,
    String? senderName,
  }) {
    return NotificationPayload(
      id: id ?? 'n_${DateTime.now().microsecondsSinceEpoch}',
      title: 'Test',
      body: 'Body',
      category: category,
      data: senderName != null ? {'sender_name': senderName} : {},
    );
  }

  group('NotificationBatcher - batching decision', () {
    test('returns false (do not batch) for high-priority categories', () {
      // interestReceived, matchFound, chatMessage should NOT be batched
      expect(
        batcher.add(makePayload(category: NotificationCategory.interestReceived)),
        false,
      );
      expect(
        batcher.add(makePayload(category: NotificationCategory.matchFound)),
        false,
      );
      expect(
        batcher.add(makePayload(category: NotificationCategory.chatMessage)),
        false,
      );
    });

    test('returns true (batched) for batchable categories', () {
      expect(
        batcher.add(makePayload()),
        true,
      );
      expect(
        batcher.add(makePayload(category: NotificationCategory.nudge)),
        true,
      );
      expect(
        batcher.add(makePayload(category: NotificationCategory.general)),
        true,
      );
    });
  });

  group('NotificationBatcher - batch flushing', () {
    test('flushes single item as-is after batch window', () {
      fakeAsync((async) {
        batcher.add(makePayload(
          id: 'single',
          senderName: 'Priya',
        ));

        // Fast-forward past batch window (30 seconds)
        async.elapse(const Duration(seconds: 31));

        expect(deliveredBatches.length, 1);
        expect(deliveredBatches.first.id, 'single');
      });
    });

    test('flushes multiple items as summary after batch window', () {
      fakeAsync((async) {
        batcher.add(makePayload(
          id: 'v1',
          senderName: 'Priya',
        ));
        batcher.add(makePayload(
          id: 'v2',
          senderName: 'Rahul',
        ));
        batcher.add(makePayload(
          id: 'v3',
          senderName: 'Sneha',
        ));

        async.elapse(const Duration(seconds: 31));

        expect(deliveredBatches.length, 1);
        final summary = deliveredBatches.first;
        expect(summary.title!, contains('3'));
        expect(summary.title!, contains('viewed'));
        expect(summary.data['batch_count'], 3);
      });
    });

    test('nudge batch creates tip-style summary', () {
      fakeAsync((async) {
        batcher.add(makePayload(id: 'n1', category: NotificationCategory.nudge));
        batcher.add(makePayload(id: 'n2', category: NotificationCategory.nudge));

        async.elapse(const Duration(seconds: 31));

        expect(deliveredBatches.length, 1);
        expect(deliveredBatches.first.title!, contains('tips'));
      });
    });

    test('general batch creates generic summary', () {
      fakeAsync((async) {
        batcher.add(makePayload(id: 'g1', category: NotificationCategory.general));
        batcher.add(makePayload(id: 'g2', category: NotificationCategory.general));

        async.elapse(const Duration(seconds: 31));

        expect(deliveredBatches.length, 1);
        expect(deliveredBatches.first.title!, contains('notifications'));
      });
    });
  });

  group('NotificationBatcher - flushAll', () {
    test('flushAll delivers all pending batches immediately', () {
      batcher.add(makePayload(id: 'v1'));
      batcher.add(makePayload(id: 'n1', category: NotificationCategory.nudge));

      batcher.flushAll();

      expect(deliveredBatches.length, 2);
    });

    test('flushAll does nothing when empty', () {
      batcher.flushAll();

      expect(deliveredBatches, isEmpty);
    });
  });

  group('NotificationBatcher - _summarizeNames', () {
    test('summary with multiple names formats correctly', () {
      fakeAsync((async) {
        batcher.add(makePayload(
          id: 'v1',
          senderName: 'Priya',
        ));
        batcher.add(makePayload(
          id: 'v2',
          senderName: 'Rahul',
        ));

        async.elapse(const Duration(seconds: 31));

        final body = deliveredBatches.first.body!;
        expect(body, contains('Priya'));
        expect(body, contains('Rahul'));
      });
    });

    test('summary with 3+ names uses "and N others"', () {
      fakeAsync((async) {
        batcher.add(makePayload(id: 'v1', senderName: 'A'));
        batcher.add(makePayload(id: 'v2', senderName: 'B'));
        batcher.add(makePayload(id: 'v3', senderName: 'C'));
        batcher.add(makePayload(id: 'v4', senderName: 'D'));

        async.elapse(const Duration(seconds: 31));

        final body = deliveredBatches.first.body!;
        expect(body, contains('others'));
      });
    });
  });

  group('NotificationBatcher - dispose', () {
    test('dispose clears all state', () {
      batcher.add(makePayload());

      batcher.dispose();

      // After dispose, flushing should produce nothing
      batcher.flushAll();
      expect(deliveredBatches, isEmpty);
    });
  });
}
