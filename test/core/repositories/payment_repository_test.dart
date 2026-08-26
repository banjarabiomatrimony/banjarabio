import 'package:flutter_test/flutter_test.dart';
import 'package:banjarabio/core/repositories/payment_repository.dart';
import 'package:banjarabio/shared/billing/razorpay_billing_constants.dart';
import '../../helpers/supabase_fakes.dart';

void main() {
  late FakeSupabaseClient fakeSupabase;
  late PaymentRepository paymentRepository;

  setUp(() {
    fakeSupabase = FakeSupabaseClient();
    PaymentRepository.testClient = fakeSupabase;
    paymentRepository = PaymentRepository();
  });

  tearDown(() {
    PaymentRepository.testClient = null;
  });

  group('PaymentRepository Tests', () {
    test('createPaymentRecord calls RPC fn_process_payment with record_payment action', () async {
      fakeSupabase.rpcResponse = {
        'id': 'pay_123',
        'user_id': 'user_1',
        'amount': 49900,
        'status': 'created',
        'razorpay_order_id': 'order_123',
        'plan_type': 'silver',
        'created_at': DateTime.now().toIso8601String(),
      };

      // ignore: deprecated_member_use_from_same_package
      final result = await paymentRepository.createPaymentRecord(
        amount: 49900,
        currency: 'INR',
        razorpayOrderId: 'order_123',
        planType: 'silver',
        planDuration: 30,
      );

      expect(result.isSuccess, isTrue);
      expect(fakeSupabase.rpcFunction, equals('fn_process_payment'));
      expect(fakeSupabase.rpcParams?['action'], equals(RazorpayBillingConstants.actionRecordPayment));
    });

    test('updatePaymentStatus calls RPC fn_process_payment with update_status action', () async {
      fakeSupabase.rpcResponse = {'status': 'success'};

      final result = await paymentRepository.updatePaymentStatus(
        razorpayOrderId: 'order_123',
        status: 'captured',
        razorpayPaymentId: 'pay_xyz',
      );

      expect(result.isSuccess, isTrue);
      expect(fakeSupabase.rpcFunction, equals('fn_process_payment'));
      expect(fakeSupabase.rpcParams?['action'], equals('update_status'));
    });

    test('recordPaymentSuccess calls verify_payment RPC action', () async {
      fakeSupabase.rpcResponse = {'success': true};

      final result = await paymentRepository.recordPaymentSuccess(
        orderId: 'order_123',
        paymentId: 'pay_123',
        signature: 'sig_123',
        amount: 49900,
        planType: 'gold',
      );

      expect(result.isSuccess, isTrue);
      expect(fakeSupabase.rpcFunction, equals('fn_process_payment'));
      expect(fakeSupabase.rpcParams?['action'], equals(RazorpayBillingConstants.actionVerifyPayment));
    });

    test('recordPaymentSuccess handles null RPC response gracefully', () async {
      fakeSupabase.rpcResponse = null;

      final result = await paymentRepository.recordPaymentSuccess(
        orderId: 'order_123',
        paymentId: 'pay_123',
        signature: 'sig_123',
        amount: 49900,
        planType: 'gold',
      );

      expect(result.isSuccess, isFalse);
      expect(result.errorMessage, contains('Verify payment returned null'));
    });
  });
}
