/// Shared Razorpay billing – master template for 1 account, N apps.
///
/// Usage:
/// 1. Implement [RazorpayAppBillingConfig] for your app.
/// 2. Call [RazorpayBillingRegistry.register] in main.dart.
/// 3. [RazorpayRepository] uses the shared config automatically.
library;

export 'billing/razorpay_app_billing_config.dart';
export 'billing/razorpay_billing_constants.dart';
export 'billing/razorpay_billing_registry.dart';
