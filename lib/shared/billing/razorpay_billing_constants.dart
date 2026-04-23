/// Razorpay billing constants – shared across all apps (1 account, N apps).
///
/// **DO NOT MODIFY** – This is the master template. App-specific values
/// come from [RazorpayAppBillingConfig].
library;

/// RPC action names used by fn_process_payment.
abstract class RazorpayBillingConstants {
  RazorpayBillingConstants._();

  /// Edge Function name for server-side order creation.
  static const String edgeFunctionCreateOrder = 'create-razorpay-order';

  /// RPC actions for fn_process_payment.
  static const String actionCreateOrder = 'create_order';
  static const String actionVerifyPayment = 'verify_payment';
  static const String actionSyncPdfUnlock = 'sync_pdf_unlock';
  static const String actionRecordPayment = 'record_payment';
  static const String actionGetHistory = 'get_history';

  /// Default currency for Razorpay.
  static const String defaultCurrency = 'INR';

  /// Build receipt string for multi-app tracking.
  /// Format: `{appSlug}_{userIdSlice}_{timestamp}`
  static String buildReceipt({
    required String appSlug,
    required String userId,
    required int timestamp,
  }) {
    final slice = userId.length >= 8 ? userId.substring(0, 8) : userId;
    return '${appSlug}_${slice}_$timestamp';
  }

  /// Build notes map for Razorpay (multi-app identification).
  static Map<String, dynamic> buildNotes({
    required String userId,
    required String planType,
    required String appName,
  }) {
    return {
      'user_id': userId,
      'plan_type': planType,
      'app': appName,
    };
  }

  /// Build grouped metadata object for deep tracking.
  static Map<String, dynamic> buildGroupedMetadata({
    required String appSlug,
    required String appId,
    required String appName,
    required String source,
    required String version,
    required String platform,
    required String device,
    required String os,
    required String network,
    required String userId,
    required String userGender,
    required int userAge,
    required String userLocation,
    required String plan,
    required int duration,
    required String? coupon,
    required String entry,
    required String? referrer,
  }) {
    final now = DateTime.now();
    return {
      'app': {
        'slug': appSlug,
        'id': appId,
        'name': appName,
        'source': source,
        'version': version,
      },
      'tech': {
        'platform': platform,
        'device': device,
        'os': os,
        'network': network,
      },
      'user': {
        'id': userId,
        'gender': userGender,
        'age': userAge,
        'location': userLocation,
      },
      'txn': {
        'plan': plan,
        'duration': duration,
        'coupon': coupon,
        'entry': entry,
      },
      'ref': {
        'referrer': referrer,
      },
      'date': {
        'year': now.year,
        'month': now.month,
        'day': now.day,
      },
    };
  }
}
