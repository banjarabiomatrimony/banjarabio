import 'package:flutter_test/flutter_test.dart';
import 'package:banjarabio/core/models/payment_model.dart';

void main() {
  group('PaymentStatus', () {
    test('fromString parses all valid statuses', () {
      expect(PaymentStatus.fromString('authorized'), PaymentStatus.authorized);
      expect(PaymentStatus.fromString('captured'), PaymentStatus.captured);
      expect(PaymentStatus.fromString('failed'), PaymentStatus.failed);
      expect(PaymentStatus.fromString('refunded'), PaymentStatus.refunded);
    });

    test('fromString defaults to created for unknown input', () {
      expect(PaymentStatus.fromString('unknown'), PaymentStatus.created);
    });

    test('fromString is case-insensitive', () {
      expect(PaymentStatus.fromString('CAPTURED'), PaymentStatus.captured);
    });
  });

  group('PaymentModel', () {
    test('fromJson parses all fields', () {
      final p = PaymentModel.fromJson({
        'id': 'pay1', 'user_id': 'u1', 'subscription_id': 'sub1',
        'amount': 49900, 'currency': 'INR', 'status': 'captured',
        'razorpay_order_id': 'order_123', 'plan_type': 'gold', 'plan_duration': 3,
        'metadata': {'coupon': 'FIRST50'}, 'notes': 'Test',
        'created_at': '2025-01-01T00:00:00Z', 'updated_at': '2025-06-01T00:00:00Z',
      });
      expect(p.id, 'pay1');
      expect(p.amount, 49900);
      expect(p.status, PaymentStatus.captured);
      expect(p.planDuration, 3);
      expect(p.metadata, {'coupon': 'FIRST50'});
    });

    test('defaults for missing fields', () {
      final p = PaymentModel.fromJson({});
      expect(p.amount, 0);
      expect(p.currency, 'INR');
      expect(p.status, PaymentStatus.created);
    });

    test('amountInRupees converts paise to rupees', () {
      expect(PaymentModel.fromJson({'amount': 49900}).amountInRupees, 499.0);
    });

    test('isSuccessful for captured/authorized', () {
      expect(PaymentModel.fromJson({'status': 'captured'}).isSuccessful, true);
      expect(PaymentModel.fromJson({'status': 'authorized'}).isSuccessful, true);
      expect(PaymentModel.fromJson({'status': 'failed'}).isSuccessful, false);
    });

    test('toJson round-trips', () {
      final json = PaymentModel.fromJson({'id': 'p1', 'amount': 100, 'status': 'captured', 'plan_type': 'gold', 'created_at': '2025-01-01T00:00:00Z', 'updated_at': '2025-01-01T00:00:00Z'}).toJson();
      expect(json['status'], 'captured');
    });

    test('copyWith changes fields', () {
      final copy = PaymentModel.fromJson({'id': 'p1', 'amount': 100}).copyWith(amount: 200);
      expect(copy.amount, 200);
      expect(copy.id, 'p1');
    });

    test('toString includes readable info', () {
      expect(PaymentModel.fromJson({'amount': 49900, 'status': 'captured', 'plan_type': 'gold'}).toString(), contains('499.0'));
    });
  });
}
