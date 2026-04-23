import 'package:banjarabio/shared/billing/razorpay_billing_constants.dart';

/// App-specific Razorpay billing configuration – implements this per app.
///
/// Each app provides its own config (app name, slug, plans, amounts).
/// The shared billing flow uses this config and never hardcodes app details.
abstract class RazorpayAppBillingConfig {
  /// Display name for Razorpay checkout and support.
  String get appName;

  /// Short slug for receipt prefix (e.g. `banjara`, `app2`).
  String get appSlug;

  /// Razorpay Key ID (from env – same across apps using 1 account).
  String get keyId;

  /// Brand color hex for Razorpay checkout theme.
  String get brandColor;

  /// Amount in paise for the given plan type.
  int getAmountInPaise(String planType);

  /// Display name for the plan in checkout.
  String getDisplayName(String planType);

  /// Build notes for Razorpay (uses shared format).
  Map<String, dynamic> buildNotes({
    required String userId,
    required String planType,
  }) =>
      RazorpayBillingConstants.buildNotes(
        userId: userId,
        planType: planType,
        appName: appName,
      );

  /// Build receipt string (uses shared format).
  String buildReceipt(String userId) =>
      RazorpayBillingConstants.buildReceipt(
        appSlug: appSlug,
        userId: userId,
        timestamp: DateTime.now().millisecondsSinceEpoch,
      );
}
