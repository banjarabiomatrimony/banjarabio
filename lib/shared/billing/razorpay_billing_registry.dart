import 'package:banjarabio/shared/billing/razorpay_app_billing_config.dart';

/// Global registry for the current app's Razorpay billing config.
///
/// Set once at app startup (main.dart). Shared billing code reads from here.
abstract class RazorpayBillingRegistry {
  RazorpayBillingRegistry._();

  static RazorpayAppBillingConfig? _config;

  /// Register the app's billing config. Call in main.dart before any payment.
  static void register(RazorpayAppBillingConfig config) {
    _config = config;
  }

  /// Current config. Throws if not registered.
  static RazorpayAppBillingConfig get config {
    final c = _config;
    if (c == null) {
      throw StateError(
        'Razorpay billing config not registered. '
        'Call RazorpayBillingRegistry.register() in main.dart',
      );
    }
    return c;
  }

  static bool get isRegistered => _config != null;
}
