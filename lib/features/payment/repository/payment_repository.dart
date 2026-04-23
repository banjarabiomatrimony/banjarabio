import 'package:banjarabio/core/models/backend_response.dart';
import 'package:banjarabio/core/models/payment_model.dart';

/// Abstract interface for payment operations.
/// Allows for mocking in tests and swapping implementations.
///
/// Canonical flow: [RazorpayRepository.startPayment] → verify_payment.
abstract class PaymentRepository {
  /// Create a new payment record.
  ///
  /// **Deprecated**: Use RazorpayRepository.startPayment; records are created by verify_payment.
  @Deprecated('Use RazorpayRepository.startPayment. Records created by verify_payment.')
  Future<BackendResponse<PaymentModel>> createPaymentRecord({
    required int amount,
    required String currency,
    required String razorpayOrderId,
    required String planType,
    required int planDuration,
    String? status,
    Map<String, dynamic>? metadata,
    String? notes,
  });

  /// Update payment status (e.g. captured/failed).
  Future<BackendResponse<void>> updatePaymentStatus({
    required String razorpayOrderId,
    required String status,
    String? razorpayPaymentId,
    String? razorpaySignature,
    String? failureReason,
  });

  /// Record a successful Razorpay payment and unlock PDF.
  Future<BackendResponse<void>> recordPaymentSuccess({
    required String orderId,
    required String paymentId,
    required String signature,
    required int amount,
    required String planType,
  });

  /// Check if PDF is currently unlocked for the user.
  Future<BackendResponse<bool>> isPdfUnlocked();
}
