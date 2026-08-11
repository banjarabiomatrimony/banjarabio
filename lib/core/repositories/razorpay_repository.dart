import 'dart:async';
import 'dart:io';

import 'package:flutter/widgets.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:banjarabio/core/models/backend_response.dart';
import 'package:banjarabio/core/models/payment_model.dart';
import 'package:banjarabio/core/models/profile_model.dart';
import 'package:banjarabio/core/models/subscription_model.dart';
import 'package:banjarabio/core/repositories/isolate_first_repository.dart';
import 'package:banjarabio/core/repositories/profile_repository.dart';
import 'package:banjarabio/core/repositories/subscription_repository.dart';
import 'package:banjarabio/shared/billing/razorpay_billing_constants.dart';
import 'package:banjarabio/shared/billing/razorpay_billing_registry.dart';
import 'package:banjarabio/core/services/app_logger.dart';

/// [RazorpayRepository]
///
/// Manages the full lifecycle of a Razorpay payment flow.
///
/// 🏆 10/10 Architecture Highlights:
/// 1. **Future-based API**: Converts Razorpay's event-listener pattern into a clean `await`able Future.
/// 2. **Server-Side Security**: Delegates Order Creation and Verification to Supabase RPCs.
/// 3. **Singleton**: Ensures only one payment flow exists at a time to prevent race conditions.
class RazorpayRepository extends IsolateFirstRepository with WidgetsBindingObserver {
  // ---------------------------------------------------------------------------
  // 1. Singleton & Dependencies
  // ---------------------------------------------------------------------------
  static final RazorpayRepository _instance = RazorpayRepository._();
  factory RazorpayRepository() => _instance;
  RazorpayRepository._();

  /// Fresh Razorpay instance per payment - improves callback delivery on Android
  /// when returning from UPI/external wallet apps (see razorpay_flutter #167).
  Razorpay? _razorpay;

  @visibleForTesting
  SupabaseClient? testClient;
  @visibleForTesting
  SubscriptionRepository? testSubscriptionRepository;
  @visibleForTesting
  ProfileRepository? testProfileRepository;
  @visibleForTesting
  Razorpay? testRazorpay;

  SupabaseClient get _supabase => testClient ?? Supabase.instance.client;
  SubscriptionRepository get _subscriptionRepository =>
      testSubscriptionRepository ?? SubscriptionRepository();
  ProfileRepository get _profileRepository =>
      testProfileRepository ?? ProfileRepository();

  /// Resets the repository state for testing.
  @visibleForTesting
  void reset() {
    testClient = null;
    testSubscriptionRepository = null;
    testProfileRepository = null;
    testRazorpay = null;
    _razorpay = null;
    _paymentCompleter = null;
  }

  // ---------------------------------------------------------------------------
  // 2. State Management (The "Completer" Pattern)
  // ---------------------------------------------------------------------------

  // This Completer turns the Razorpay Event Stream into a single Future result.
  // When a payment starts, we create this. When it finishes, we complete it.
  Completer<BackendResponse<void>>? _paymentCompleter;

  // Pending payment context for verify_payment (amount-only flow)
  int _pendingAmount = 0;
  String _pendingPlanType = '';
  String _pendingAppSlug = 'banjara';
  Map<String, dynamic>? _pendingMetadata;

  DateTime? _pendingStartTime; // Renamed from _paymentStartTime for consistency

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state != AppLifecycleState.resumed) return;
    if (_paymentCompleter == null || _paymentCompleter!.isCompleted) return;
    // User likely returned from UPI/external wallet - refresh subscription
    // in case webhook updated it (future-proofing; helps if callbacks missed)
    final elapsed = _pendingStartTime != null
        ? DateTime.now().difference(_pendingStartTime!)
        : Duration.zero;
    if (elapsed > const Duration(seconds: 10)) {
      AppLogger.debug('RazorpayRepository', '[RAZORPAY] App resumed during payment, refreshing subscription');
      _subscriptionRepository.refreshSubscription();
    }
  }

  /// Initializes a fresh Razorpay instance per payment. Not called at startup.
  void _ensureRazorpayInstance() {
    _razorpay?.clear();
    _razorpay = testRazorpay ?? Razorpay();
    _razorpay!.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    _razorpay!.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
    _razorpay!.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);
    AppLogger.debug('RazorpayRepository', '[RAZORPAY] RazorpayRepository > Fresh instance created, listeners registered');
  }

  /// Disposes listeners to prevent memory leaks.
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _pendingStartTime = null;
    _razorpay?.clear();
    _razorpay = null;
    if (_paymentCompleter != null && !_paymentCompleter!.isCompleted) {
      _paymentCompleter!.complete(
        BackendResponse.failure('Payment cancelled'),
      );
      _paymentCompleter = null;
    }
  }

  // ---------------------------------------------------------------------------
  // 3. Core Payment Flow
  // ---------------------------------------------------------------------------

  /// Starts the Payment Flow.
  ///
  /// Returns a [Future] that completes ONLY when the entire flow is done
  /// (Order Created -> UI Opened -> Payment Done -> Server Verified).
  Future<BackendResponse<void>> startPayment({
    required PlanType planType,
    int? customAmountPaise,
    String entryPoint = 'unknown',
    String? couponCode,
    String? referrerId,
  }) async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) return BackendResponse.failure('User not logged in');

      // 1. Get Amount
      final amountPaise = customAmountPaise ??
          RazorpayBillingRegistry.config.getAmountInPaise(planType.name);

      // Fresh Razorpay instance per payment - improves callback delivery
      // when returning from UPI/external wallet (razorpay_flutter #167)
      _ensureRazorpayInstance();

      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) {
        AppLogger.debug('RazorpayRepository', '[RAZORPAY] startPayment > User not logged in');
        return BackendResponse.failure('User not logged in');
      }

      AppLogger.debug('RazorpayRepository', '[RAZORPAY] startPayment > planType=${planType.name}');

      // 1. Reset State
      if (_paymentCompleter != null && !_paymentCompleter!.isCompleted) {
        return BackendResponse.failure('A payment is already in progress');
      }
      _paymentCompleter = Completer<BackendResponse<void>>();
      _pendingStartTime = DateTime.now();
      WidgetsBinding.instance.addObserver(this);

      // 2. Get Plan Config (from shared billing master via app config)
      final config = RazorpayBillingRegistry.config;
      AppLogger.debug('RazorpayRepository', '[RAZORPAY] startPayment > amount=$amountPaise paise (${amountPaise / 100} INR)');

      // 3. Server: Create Order (or get amount-only flow approval)
      // Backend may return order_id or 'amount_only' when Razorpay creates order on pay.
      final orderRes = await _createOrderRpc(amountPaise, planType.name);

      if (!orderRes.isSuccess) {
        AppLogger.error('RazorpayRepository', '[RAZORPAY] startPayment > createOrder FAILED | ${orderRes.errorMessage}');
        WidgetsBinding.instance.removeObserver(this);
        _pendingStartTime = null;
        _paymentCompleter?.complete(
          BackendResponse.failure(
            'Failed to create order: ${orderRes.errorMessage}',
          ),
        );
        _paymentCompleter = null;
        return BackendResponse.failure(
          'Failed to create order: ${orderRes.errorMessage}',
        );
      }

      final orderData = orderRes.data;
      final orderId = orderData['id']?.toString();
      final useAmountOnly =
          orderId == null || orderId == 'amount_only' || !orderId.startsWith('order_');

      _pendingAmount = amountPaise;
      _pendingPlanType = planType.name;
      _pendingAppSlug = RazorpayBillingRegistry.config.appSlug;

      // 3.5 Prepare Grouped Metadata (User Info + Tech + App)
      try {
        ProfileModel? profile;
        try {
          final profileRes = await _profileRepository.getOwnProfile().timeout(const Duration(seconds: 2));
          profile = profileRes.data;
        } catch (e) {
          AppLogger.error('RazorpayRepository', '[RAZORPAY] startPayment > Profile fetch failed for metadata | $e');
        }
        
        _pendingMetadata = RazorpayBillingConstants.buildGroupedMetadata(
          appSlug: _pendingAppSlug,
          appId: 'BJBIO',
          appName: RazorpayBillingRegistry.config.appName,
          source: 'BanjaraBio_App',
          version: '1.1.3+18',
          platform: Platform.isAndroid ? 'android' : (Platform.isIOS ? 'ios' : 'unknown'),
          device: 'unknown',
          os: Platform.operatingSystemVersion,
          network: 'unknown',
          userId: userId,
          userGender: profile?.gender ?? 'unknown',
          userAge: profile?.age ?? 0,
          userLocation: profile?.state ?? 'unknown',
          plan: planType.name,
          duration: 0,
          coupon: couponCode,
          entry: entryPoint,
          referrer: referrerId,
        );
      } catch (e) {
        AppLogger.error('RazorpayRepository', '[RAZORPAY] startPayment > Metadata collection error (non-fatal) | $e');
      }

      AppLogger.debug('RazorpayRepository', '[RAZORPAY] startPayment > orderId=${orderData['id']} | useAmountOnly=$useAmountOnly');

      // 4. Client: Open Checkout UI (uses shared config for branding/notes)
      _openCheckout(
        amount: amountPaise,
        orderId: useAmountOnly ? null : orderId,
        planName: config.getDisplayName(planType.name),
        userEmail: _supabase.auth.currentUser?.email ?? '',
        userPhone: _supabase.auth.currentUser?.phone ?? '',
        notes: config.buildNotes(userId: userId, planType: planType.name),
      );

      // 5. Wait for Result (Completer) with timeout to prevent indefinite loading
      try {
        final result = await _paymentCompleter!.future.timeout(
          const Duration(minutes: 3),
          onTimeout: () async {
            _razorpay?.clear();
            _razorpay = null;
            WidgetsBinding.instance.removeObserver(this);
            _pendingStartTime = null;
            // Refresh subscription in case webhook updated it (future-proofing)
            try {
              await _subscriptionRepository.refreshSubscription();
            } catch (_) {}
            _paymentCompleter?.complete(
              BackendResponse.failure(
                'Payment timed out. If payment succeeded, please refresh or contact support.',
              ),
            );
            _paymentCompleter = null;
            return BackendResponse.failure(
              'Payment timed out. If payment succeeded, please refresh or contact support.',
            );
          },
        );
        // Auto-cleanup after payment completes
        _paymentCompleter = null;
        return result;
      } catch (e) {
        // Ensure completer is cleaned up on error
        WidgetsBinding.instance.removeObserver(this);
        _pendingStartTime = null;
        _paymentCompleter = null;
        rethrow;
      }
    } catch (e, stack) {
      // Ensure completer is cleaned up on exception
      WidgetsBinding.instance.removeObserver(this);
      _pendingStartTime = null;
      if (_paymentCompleter != null && !_paymentCompleter!.isCompleted) {
        _paymentCompleter!.complete(
          BackendResponse.failure(e.toString(), stackTrace: stack),
        );
        _paymentCompleter = null;
      }
      return BackendResponse.failure(e.toString(), stackTrace: stack);
    }
  }

  // ---------------------------------------------------------------------------
  // 4. Internal Helpers
  // ---------------------------------------------------------------------------

  void _openCheckout({
    required int amount,
    required String? orderId,
    required String planName,
    required String userEmail,
    required String userPhone,
    required Map<String, dynamic> notes,
  }) {
    final config = RazorpayBillingRegistry.config;
    final options = <String, dynamic>{
      'key': config.keyId,
      'amount': amount,
      'name': config.appName,
      'description': planName,
      'prefill': {'contact': userPhone, 'email': userEmail},
      'notes': notes,
      'theme': {'color': config.brandColor},
    };
    if (orderId != null && orderId.isNotEmpty && orderId.startsWith('order_')) {
      options['order_id'] = orderId;
    }

    try {
      AppLogger.debug('RazorpayRepository', '[RAZORPAY] _openCheckout > Opening Razorpay SDK | amount=$amount orderId=$orderId');
      _razorpay!.open(options);
    } catch (e) {
      AppLogger.error('RazorpayRepository', '[RAZORPAY] _openCheckout > FAILED to open | $e');
      _completePaymentWithFailure('Failed to open checkout: $e');
    }
  }

  /// Creates a Razorpay Order - tries Edge Function first, falls back to RPC.
  Future<BackendResponse<Map<String, dynamic>>> _createOrderRpc(
    int amount,
    String planType,
  ) async {
    // 0. Refresh session to avoid "Invalid JWT" (401) when token is expired
    // Edge Functions validate JWT strictly; RPC uses auth.uid() and may succeed with stale token.
    try {
      await _supabase.auth.refreshSession();
      AppLogger.debug('RazorpayRepository', '[RAZORPAY] _createOrderRpc > Session refreshed before Edge Function');
    } catch (e) {
      AppLogger.error('RazorpayRepository', '[RAZORPAY] _createOrderRpc > Session refresh skipped/failed | $e');
      // Continue anyway; Edge Function may still work; RPC fallback will handle failure
    }

    // 1. Try Edge Function (proper server-side order creation)
    try {
      final config = RazorpayBillingRegistry.config;
      debugPrint(
        '[RAZORPAY] _createOrderRpc > Invoking Edge Function ${RazorpayBillingConstants.edgeFunctionCreateOrder}',
      );
      final res = await _supabase.functions.invoke(
        RazorpayBillingConstants.edgeFunctionCreateOrder,
        body: {
          'amount': amount,
          'currency': RazorpayBillingConstants.defaultCurrency,
          'plan_type': planType,
          'app_slug': config.appSlug,
          'app_name': config.appName,
        },
      );
      debugPrint(
        '[RAZORPAY] _createOrderRpc > Edge Function response | status=${res.status} | '
        'data=${res.data != null ? res.data.toString().replaceAll('\n', ' ') : 'null'}',
      );
      if (res.status == 200 && res.data != null) {
        final data = res.data as Map<String, dynamic>;
        if (data['id'] != null && data['id'].toString().startsWith('order_')) {
          AppLogger.debug('RazorpayRepository', '[RAZORPAY] _createOrderRpc > Edge Function SUCCESS | orderId=${data['id']}');
          return BackendResponse.success(data);
        }
        debugPrint(
          '[RAZORPAY] _createOrderRpc > Edge Function 200 but invalid id | id=${data['id']}',
        );
      }
      final err = res.data is Map
          ? (res.data as Map)['error']?.toString() ?? (res.data as Map)['details']?.toString() ?? res.data.toString()
          : res.data?.toString() ?? 'Unknown error';
      debugPrint(
        '[RAZORPAY] _createOrderRpc > Edge Function failed | status=${res.status} | error=$err',
      );
      // On 401 (Invalid JWT): retry once after refresh before falling back to RPC
      if (res.status == 401) {
        AppLogger.warn('RazorpayRepository', '[RAZORPAY] _createOrderRpc > 401 Invalid JWT, retrying after refresh');
        try {
          await _supabase.auth.refreshSession();
          final retryRes = await _supabase.functions.invoke(
            RazorpayBillingConstants.edgeFunctionCreateOrder,
            body: {
              'amount': amount,
              'currency': RazorpayBillingConstants.defaultCurrency,
              'plan_type': planType,
              'app_slug': config.appSlug,
              'app_name': config.appName,
            },
          );
          if (retryRes.status == 200 && retryRes.data != null) {
            final data = retryRes.data as Map<String, dynamic>;
            if (data['id'] != null && data['id'].toString().startsWith('order_')) {
              AppLogger.warn('RazorpayRepository', '[RAZORPAY] _createOrderRpc > Retry SUCCESS | orderId=${data['id']}');
              return BackendResponse.success(data);
            }
          }
        } catch (_) {
          AppLogger.error('RazorpayRepository', '[RAZORPAY] _createOrderRpc > Retry failed, falling through to RPC');
        }
      }
      // Fall through to RPC only for 404 (not deployed), 401 (after retry), or 5xx (server error)
      if (res.status != 404 && res.status != 401 && res.status != 500 && res.status != 502) {
        return BackendResponse.failure('Order creation failed: $err');
      }
    } catch (e, stack) {
      debugPrint(
        '[RAZORPAY] _createOrderRpc > Edge Function exception | $e\n'
        'Stack: ${stack.toString().split('\n').take(3).join('\n')}',
      );
      // Supabase functions.invoke() THROWS on 401 instead of returning response.
      // Retry once after refresh when we get FunctionException with status 401.
      if (e is FunctionException && e.status == 401) {
        AppLogger.warn('RazorpayRepository', '[RAZORPAY] _createOrderRpc > 401 Invalid JWT (thrown), retrying after refresh');
        try {
          await _supabase.auth.refreshSession();
          // Short delay so client picks up new token before next invoke
          await Future<void>.delayed(const Duration(milliseconds: 100));
          final retryConfig = RazorpayBillingRegistry.config;
          final retryRes = await _supabase.functions.invoke(
            RazorpayBillingConstants.edgeFunctionCreateOrder,
            body: {
              'amount': amount,
              'currency': RazorpayBillingConstants.defaultCurrency,
              'plan_type': planType,
              'app_slug': retryConfig.appSlug,
              'app_name': retryConfig.appName,
            },
          );
          if (retryRes.status == 200 && retryRes.data != null) {
            final data = retryRes.data as Map<String, dynamic>;
            if (data['id'] != null && data['id'].toString().startsWith('order_')) {
              AppLogger.warn('RazorpayRepository', '[RAZORPAY] _createOrderRpc > Retry SUCCESS | orderId=${data['id']}');
              return BackendResponse.success(data);
            }
          }
        } catch (_) {
          AppLogger.error('RazorpayRepository', '[RAZORPAY] _createOrderRpc > Retry failed, falling through to RPC');
        }
      }
      // Fall through to RPC on network/parsing errors or other exceptions
    }

      // 2. Fallback: RPC (returns amount_only for checkout without order_id)
      // WARNING: amount_only flow is less reliable; callbacks may not fire on Android.
      // Deploy Edge Function: supabase functions deploy create-razorpay-order
      debugPrint(
        '[RAZORPAY] _createOrderRpc > Using RPC fallback (amount_only). '
        'Deploy Edge Function for reliable order_id.',
      );
      try {
        final config = RazorpayBillingRegistry.config;
        final response = await _supabase.rpc(
          'fn_process_payment',
          params: {
            'action': RazorpayBillingConstants.actionCreateOrder,
            'payload': {
              'amount': amount,
              'currency': RazorpayBillingConstants.defaultCurrency,
              'plan_type': planType,
              'app_slug': config.appSlug,
            },
          },
        );
      AppLogger.warn('RazorpayRepository', '[RAZORPAY] _createOrderRpc > RPC fallback SUCCESS | amount_only');
      return BackendResponse.fromRpc(response);
    } catch (e) {
      AppLogger.error('RazorpayRepository', '[RAZORPAY] _createOrderRpc > RPC fallback FAILED | $e');
      return BackendResponse.failure(e.toString());
    }
  }

  /// Calls Supabase RPC to verify payment signature securely.
  Future<BackendResponse<void>> _verifyPaymentRpc(
    String orderId,
    String paymentId,
    String signature, {
    int? amount,
    String? planType,
    String? appSlug,
  }) async {
    try {
      final config = RazorpayBillingRegistry.config;
      final isTest = config.keyId.startsWith('rzp_test_');

      final response = await _supabase.rpc(
        'fn_process_payment',
        params: {
          'action': RazorpayBillingConstants.actionVerifyPayment,
          'payload': {
            'razorpay_order_id': orderId,
            'razorpay_payment_id': paymentId,
            'razorpay_signature': signature,
            'amount': amount ?? _pendingAmount,
            'plan_type': planType ?? _pendingPlanType,
            'app_slug': appSlug ?? _pendingAppSlug,
            'is_test': isTest,
            'metadata': _pendingMetadata,
          },
        },
      );
      return BackendResponse.fromRpc(response);
    } catch (e) {
      return BackendResponse.failure(e.toString());
    }
  }

  // ---------------------------------------------------------------------------
  // 5. Event Handlers
  // ---------------------------------------------------------------------------

  Future<void> _handlePaymentSuccess(PaymentSuccessResponse response) async {
    AppLogger.debug('RazorpayRepository', '[RAZORPAY] _handlePaymentSuccess > orderId=${response.orderId} paymentId=${response.paymentId}');

    // Null safety: Razorpay SDK can return null in edge cases
    final orderId = response.orderId;
    final paymentId = response.paymentId;
    final signature = response.signature;
    if (orderId == null || orderId.isEmpty ||
        paymentId == null || paymentId.isEmpty ||
        signature == null || signature.isEmpty) {
      AppLogger.warn('RazorpayRepository', '[RAZORPAY] _handlePaymentSuccess > Missing orderId/paymentId/signature');
      _completePaymentWithFailure('Invalid payment response: missing verification data');
      return;
    }

    try {
      // 1. Server-Side Verification
      final verificationRes = await _verifyPaymentRpc(
        orderId,
        paymentId,
        signature,
      );

      if (verificationRes.isSuccess) {
        AppLogger.debug('RazorpayRepository', '[RAZORPAY] _handlePaymentSuccess > verify_payment SUCCESS | refreshing profile & subscription');
        // 2. Brief delay so DB commit/replication is visible before profile fetch (avoids stale read)
        await Future<void>.delayed(const Duration(milliseconds: 500));
        // 3. Refresh profile with retries (webhook/DB may lag; retry until unlocked or max attempts)
        const maxRetries = 4;
        const retryDelayMs = 800;
        var isUnlocked = false;
        for (var attempt = 0; attempt < maxRetries; attempt++) {
          try {
            final profileRes = await _profileRepository.getOwnProfile(forceRefresh: true);
            AppLogger.debug('RazorpayRepository', '[RAZORPAY] _handlePaymentSuccess > profile refreshed (attempt ${attempt + 1}) | isPdfUnlocked=${profileRes.data?.isPdfUnlocked}');
            if (profileRes.data?.isPdfUnlocked == true) {
              isUnlocked = true;
              break;
            }
          } catch (e) {
            AppLogger.error('RazorpayRepository', '[RAZORPAY] _handlePaymentSuccess > profile refresh failed (attempt ${attempt + 1}) | $e');
          }
          if (attempt < maxRetries - 1) {
            await Future<void>.delayed(const Duration(milliseconds: retryDelayMs));
          }
        }
        // 4. Fallback: if still locked, call sync_pdf_unlock and retry (handles replication lag / edge cases)
        if (!isUnlocked) {
          AppLogger.debug('RazorpayRepository', '[RAZORPAY] _handlePaymentSuccess > profile still locked after retries, calling sync_pdf_unlock');
          try {
            final syncRes = await _supabase.rpc(
              'fn_process_payment',
              params: {
                'action': RazorpayBillingConstants.actionSyncPdfUnlock,
                'payload': <String, dynamic>{},
              },
            );
            final status = syncRes is Map ? syncRes['status']?.toString() : null;
            AppLogger.debug('RazorpayRepository', '[RAZORPAY] _handlePaymentSuccess > sync_pdf_unlock | status=$status');
            if (status == 'sync_applied') {
              await Future<void>.delayed(const Duration(milliseconds: 400));
              final profileRes = await _profileRepository.getOwnProfile(forceRefresh: true);
              isUnlocked = profileRes.data?.isPdfUnlocked == true;
              AppLogger.warn('RazorpayRepository', '[RAZORPAY] _handlePaymentSuccess > after sync retry | isPdfUnlocked=$isUnlocked');
            }
          } catch (e) {
            AppLogger.error('RazorpayRepository', '[RAZORPAY] _handlePaymentSuccess > sync_pdf_unlock failed | $e');
          }
        }
        try {
          await _subscriptionRepository.refreshSubscription();
        } catch (e) {
          AppLogger.error('RazorpayRepository', '[RAZORPAY] _handlePaymentSuccess > refreshSubscription failed (non-fatal) | $e');
        }
        // Optimistic unlock for biodata_unlock only (handles replication lag)
        if (_pendingPlanType == 'biodata_unlock') {
          _profileRepository.applyOptimisticPdfUnlock();
        }
        _completePaymentWithSuccess();
      } else {
        AppLogger.error('RazorpayRepository', '[RAZORPAY] _handlePaymentSuccess > verify_payment FAILED | ${verificationRes.errorMessage}');
        _completePaymentWithFailure(
          'Signature Verification Failed: ${verificationRes.errorMessage}',
        );
      }
    } catch (e, stack) {
      AppLogger.error('RazorpayRepository', '[RAZORPAY] _handlePaymentSuccess > Exception | $e');
      _completePaymentWithFailure(
        'Payment verification failed: ${e.toString()}',
        stackTrace: stack,
      );
    }
  }

  void _completePaymentWithSuccess() {
    if (_paymentCompleter != null && !_paymentCompleter!.isCompleted) {
      _razorpay?.clear();
      _razorpay = null;
      WidgetsBinding.instance.removeObserver(this);
      _pendingStartTime = null;
      _paymentCompleter!.complete(BackendResponse.success(null));
      _paymentCompleter = null;
    }
  }

  void _completePaymentWithFailure(String message, {StackTrace? stackTrace}) {
    if (_paymentCompleter != null && !_paymentCompleter!.isCompleted) {
      _razorpay?.clear();
      _razorpay = null;
      WidgetsBinding.instance.removeObserver(this);
      _pendingStartTime = null;
      _paymentCompleter!.complete(
        BackendResponse.failure(message, stackTrace: stackTrace),
      );
      _paymentCompleter = null;
    }
  }

  void _handlePaymentError(PaymentFailureResponse response) {
    AppLogger.error('RazorpayRepository', '[RAZORPAY] _handlePaymentError > code=${response.code} | message=${response.message}');

    // Convert Razorpay error codes to user-friendly messages
    String msg = 'Payment Failed';
    if (response.code == Razorpay.PAYMENT_CANCELLED) {
      msg = 'Payment Cancelled by User';
    } else if (response.code == Razorpay.NETWORK_ERROR) {
      msg = 'Network Error. Please check your connection.';
    }

    _completePaymentWithFailure(msg);
  }

  void _handleExternalWallet(ExternalWalletResponse response) {
    AppLogger.debug('RazorpayRepository', '[RAZORPAY] _handleExternalWallet > wallet=${response.walletName}');
  }

  // ---------------------------------------------------------------------------
  // 6. History
  // ---------------------------------------------------------------------------

  Future<BackendResponse<List<PaymentModel>>> getPaymentHistory() async {
    try {
      final response = await _supabase.rpc(
        'fn_process_payment',
        params: {
          'action': RazorpayBillingConstants.actionGetHistory,
          'payload': {},
        },
      );

      // RPC returns null when no payments (jsonb_agg on empty set), or List of rows
      final rawList = response is List ? response : null;
      if (rawList == null || rawList.isEmpty) {
        return BackendResponse.success(<PaymentModel>[]);
      }

      final list = await mapListInBackground<PaymentModel>(
        rawList,
        PaymentModel.fromJson,
      );
      return BackendResponse.success(list);
    } catch (e) {
      return BackendResponse.failure(e.toString());
    }
  }
}
