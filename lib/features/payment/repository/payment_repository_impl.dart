import 'package:banjarabio/core/models/backend_response.dart';
import 'package:banjarabio/core/models/payment_model.dart';
import 'package:banjarabio/core/repositories/payment_repository.dart' as core;

import 'package:banjarabio/features/payment/repository/payment_repository.dart';

/// Delegates to core PaymentRepository. Avoids code duplication during migration.
class PaymentRepositoryImpl implements PaymentRepository {
  final core.PaymentRepository _delegate = core.PaymentRepository();

  @override
  @Deprecated('Use RazorpayRepository.startPayment. Records created by verify_payment.')
  Future<BackendResponse<PaymentModel>> createPaymentRecord({
    required int amount,
    required String currency,
    required String razorpayOrderId,
    required String planType,
    required int planDuration,
    String? status = 'created',
    Map<String, dynamic>? metadata,
    String? notes,
  }) =>
      // ignore: deprecated_member_use_from_same_package
      _delegate.createPaymentRecord(
        amount: amount,
        currency: currency,
        razorpayOrderId: razorpayOrderId,
        planType: planType,
        planDuration: planDuration,
        status: status,
        metadata: metadata,
        notes: notes,
      );

  @override
  Future<BackendResponse<void>> updatePaymentStatus({
    required String razorpayOrderId,
    required String status,
    String? razorpayPaymentId,
    String? razorpaySignature,
    String? failureReason,
  }) =>
      _delegate.updatePaymentStatus(
        razorpayOrderId: razorpayOrderId,
        status: status,
        razorpayPaymentId: razorpayPaymentId,
        razorpaySignature: razorpaySignature,
        failureReason: failureReason,
      );

  @override
  Future<BackendResponse<void>> recordPaymentSuccess({
    required String orderId,
    required String paymentId,
    required String signature,
    required int amount,
    required String planType,
  }) =>
      _delegate.recordPaymentSuccess(
        orderId: orderId,
        paymentId: paymentId,
        signature: signature,
        amount: amount,
        planType: planType,
      );

  @override
  Future<BackendResponse<bool>> isPdfUnlocked() => _delegate.isPdfUnlocked();
}
