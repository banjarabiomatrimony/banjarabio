import 'package:flutter_test/flutter_test.dart';
import 'package:banjarabio/core/models/payment_model.dart';

void main() {
  group('PaymentStatus', () {
    test('fromString parses all known values', () {
      expect(PaymentStatus.fromString('authorized'), PaymentStatus.authorized);
      expect(PaymentStatus.fromString('captured'), PaymentStatus.captured);
      expect(PaymentStatus.fromString('failed'), PaymentStatus.failed);
      expect(PaymentStatus.fromString('refunded'), PaymentStatus.refunded);
    });

    test('fromString defaults to created for unknown values', () {
      expect(PaymentStatus.fromString('unknown'), PaymentStatus.created);
      expect(PaymentStatus.fromString(''), PaymentStatus.created);
    });
  });

  group('PaymentModel', () {
    final now = DateTime.now();
    final sampleJson = {
      'id': 'pay1',
      'user_id': 'u1',
      'subscription_id': 'sub1',
      'amount': 249900,
      'currency': 'INR',
      'status': 'captured',
      'razorpay_order_id': 'order_123',
      'razorpay_payment_id': 'pay_123',
      'razorpay_signature': 'sig_123',
      'plan_type': 'platinum',
      'plan_duration': 12,
      'app_slug': 'banjara',
      'metadata': {'key': 'value'},
      'notes': 'Test payment',
      'created_at': now.toIso8601String(),
      'updated_at': now.toIso8601String(),
    };

    test('fromJson parses all fields', () {
      final model = PaymentModel.fromJson(sampleJson);

      expect(model.id, 'pay1');
      expect(model.userId, 'u1');
      expect(model.subscriptionId, 'sub1');
      expect(model.amount, 249900);
      expect(model.currency, 'INR');
      expect(model.status, PaymentStatus.captured);
      expect(model.razorpayOrderId, 'order_123');
      expect(model.planType, 'platinum');
      expect(model.planDuration, 12);
      expect(model.appSlug, 'banjara');
      expect(model.metadata?['key'], 'value');
      expect(model.notes, 'Test payment');
    });

    test('amountInRupees converts correctly', () {
      final model = PaymentModel.fromJson(sampleJson);
      expect(model.amountInRupees, 2499.0);
    });

    test('isSuccessful returns true for captured and authorized', () {
      final captured = PaymentModel.fromJson({...sampleJson, 'status': 'captured'});
      final authorized = PaymentModel.fromJson({...sampleJson, 'status': 'authorized'});
      final failed = PaymentModel.fromJson({...sampleJson, 'status': 'failed'});

      expect(captured.isSuccessful, true);
      expect(authorized.isSuccessful, true);
      expect(failed.isSuccessful, false);
    });

    test('toJson round-trips correctly', () {
      final model = PaymentModel.fromJson(sampleJson);
      final json = model.toJson();

      expect(json['id'], 'pay1');
      expect(json['amount'], 249900);
      expect(json['status'], 'captured');
      expect(json['plan_type'], 'platinum');
    });

    test('copyWith creates modified copy', () {
      final model = PaymentModel.fromJson(sampleJson);
      final modified = model.copyWith(amount: 99900, status: PaymentStatus.refunded);

      expect(modified.amount, 99900);
      expect(modified.status, PaymentStatus.refunded);
      expect(modified.id, model.id); // unchanged
    });

    test('fromJson handles null/missing fields', () {
      final model = PaymentModel.fromJson({});

      expect(model.id, '');
      expect(model.amount, 0);
      expect(model.currency, 'INR');
      expect(model.status, PaymentStatus.created);
      expect(model.planType, 'free');
    });

    test('toString includes relevant info', () {
      final model = PaymentModel.fromJson(sampleJson);
      expect(model.toString(), contains('₹2499'));
      expect(model.toString(), contains('captured'));
    });
  });
}
