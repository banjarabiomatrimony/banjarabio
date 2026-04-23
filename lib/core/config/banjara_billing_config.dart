import 'package:banjarabio/core/models/subscription_config.dart';
import 'package:banjarabio/core/models/subscription_model.dart';
import 'package:banjarabio/core/supabase_client.dart';
import 'package:banjarabio/shared/billing/razorpay_app_billing_config.dart';

/// BanjaraBio implementation of [RazorpayAppBillingConfig].
///
/// Uses shared billing master. Values come from [SubscriptionConfig]
/// and [AppSupabaseClient].
class BanjaraBillingConfig extends RazorpayAppBillingConfig {
  BanjaraBillingConfig._();
  static final BanjaraBillingConfig _instance = BanjaraBillingConfig._();
  factory BanjaraBillingConfig() => _instance;

  @override
  String get appName => 'BanjaraBio';

  @override
  String get appSlug => 'banjara';

  @override
  String get keyId => AppSupabaseClient.razorpayKeyId;

  @override
  String get brandColor => '#C94B4B';

  @override
  int getAmountInPaise(String planType) {
    final type = PlanType.fromString(planType);
    // Uses offer price (after bulk discount), not MRP
    return SubscriptionConfig.getFeatures(type).priceInPaise;
  }

  @override
  String getDisplayName(String planType) {
    final type = PlanType.fromString(planType);
    return SubscriptionConfig.getDisplayName(type);
  }
}
