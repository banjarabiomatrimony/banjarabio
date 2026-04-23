import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:banjarabio/core/models/backend_response.dart';
import 'package:banjarabio/core/models/payment_model.dart';
import 'package:banjarabio/shared/billing/razorpay_billing_constants.dart';
import 'package:banjarabio/shared/billing/razorpay_billing_registry.dart';
import 'package:banjarabio/notification/features/admin_notification_service.dart';
import 'package:banjarabio/core/repositories/profile_repository.dart';

/// Repository for payment-related operations and persistence.
///
/// Canonical flow: [RazorpayRepository.startPayment] → verify_payment RPC.
/// This repository provides lower-level alternatives for status updates.
class PaymentRepository {
  static SupabaseClient? testClient;
  SupabaseClient get _supabase => testClient ?? Supabase.instance.client;
  final ProfileRepository _profileRepository = ProfileRepository();

  /// Creates a payment record via record_payment RPC.
  ///
  /// **Deprecated**: Payment records are created by verify_payment when the user
  /// completes Razorpay checkout. Use [RazorpayRepository.startPayment] instead.
  @Deprecated('Payment records are created by verify_payment. Use RazorpayRepository.startPayment.')
  Future<BackendResponse<PaymentModel>> createPaymentRecord({
    required int amount,
    required String currency,
    required String razorpayOrderId,
    required String planType,
    required int planDuration,
    String? status = 'created',
    Map<String, dynamic>? metadata,
    String? notes,
  }) async {
    try {
      final response = await _supabase.rpc(
        'fn_process_payment',
        params: {
          'action': RazorpayBillingConstants.actionRecordPayment,
          'payload': {
            'amount': amount,
            'status': status ?? 'created',
            'order_id': razorpayOrderId,
            'plan': planType,
            'duration': planDuration,
          },
        },
      );
      return BackendResponse.fromRpc(
        response,
        mapper: (data) => PaymentModel.fromJson(data as Map<String, dynamic>),
      );
    } catch (e, stack) {
      debugPrint('PaymentRepository.createPaymentRecord via RPC error: $e');
      return BackendResponse.failure(
        e.toString(),
        stackTrace: stack,
        onRetry: () => createPaymentRecord(
          amount: amount,
          currency: currency,
          razorpayOrderId: razorpayOrderId,
          planType: planType,
          planDuration: planDuration,
          status: status,
          metadata: metadata,
          notes: notes,
        ),
      );
    }
  }

  /// Updates payment status via fn_process_payment update_status.
  Future<BackendResponse<void>> updatePaymentStatus({
    required String razorpayOrderId,
    required String status,
    String? razorpayPaymentId,
    String? razorpaySignature,
    String? failureReason,
  }) async {
    try {
      final response = await _supabase.rpc(
        'fn_process_payment',
        params: {
          'action': 'update_status',
          'payload': {
            'order_id': razorpayOrderId,
            'status': status,
            'payment_id': razorpayPaymentId,
          },
        },
      );
      return BackendResponse.fromRpc(response);
    } catch (e, stack) {
      debugPrint('PaymentRepository.updatePaymentStatus via RPC error: $e');
      return BackendResponse.failure(
        e.toString(),
        stackTrace: stack,
        onRetry: () => updatePaymentStatus(
          razorpayOrderId: razorpayOrderId,
          status: status,
          razorpayPaymentId: razorpayPaymentId,
          razorpaySignature: razorpaySignature,
          failureReason: failureReason,
        ),
      );
    }
  }

  /// Verifies Razorpay payment and applies unlock/subscription via fn_process_payment verify_payment.
  Future<BackendResponse<void>> recordPaymentSuccess({
    required String orderId,
    required String paymentId,
    required String signature,
    required int amount, // in paise
    required String planType, // e.g., 'biodata_unlock', 'silver', 'gold', 'platinum'
  }) async {
    try {
      final appSlug = RazorpayBillingRegistry.isRegistered
          ? RazorpayBillingRegistry.config.appSlug
          : 'banjara';

      final response = await _supabase.rpc(
        'fn_process_payment',
        params: {
          'action': RazorpayBillingConstants.actionVerifyPayment,
          'payload': {
            'razorpay_order_id': orderId,
            'razorpay_payment_id': paymentId,
            'razorpay_signature': signature,
            'amount': amount,
            'plan_type': planType,
            'app_slug': appSlug,
          },
        },
      );

      if (response == null) {
        return BackendResponse.failure('Verify payment returned null');
      }

      _profileRepository.clearCache();

      // 🔔 Admin Alert: Payment received
      AdminNotificationService().notifyPaymentReceived(
        userId: _supabase.auth.currentUser?.id ?? '',
        amountPaise: amount,
        planType: planType,
      );

      debugPrint(
        'PaymentRepository: Successfully verified payment via RPC. DB handled unlock/subscription.',
      );
      return BackendResponse.success(null);
    } catch (e, stack) {
      debugPrint('PaymentRepository: Error recording payment: $e');
      return BackendResponse.failure(e.toString(), stackTrace: stack);
    }
  }

  /// Check if PDF is currently unlocked for the user
  Future<BackendResponse<bool>> isPdfUnlocked() async {
    try {
      final profileRes = await _profileRepository.getOwnProfile();
      return profileRes.fold(
        onSuccess: (profile) =>
            BackendResponse.success(profile?.isPdfUnlocked ?? false),
        onFailure: (error) => BackendResponse.failure(error),
      );
    } catch (e) {
      debugPrint('PaymentRepository: Error checking unlock status: $e');
      return BackendResponse.failure(e.toString());
    }
  }
}
