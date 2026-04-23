import 'package:banjarabio/core/models/profile_model.dart';
import 'package:banjarabio/core/models/subscription_config.dart';
import 'package:banjarabio/core/models/subscription_model.dart';
import 'package:banjarabio/shared/billing/razorpay_app_billing_config.dart';
import 'package:banjarabio/shared/billing/razorpay_billing_registry.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Minimal locked profile for payment widget tests (isPdfUnlocked: false).
ProfileModel createLockedTestProfile() {
  final now = DateTime.now();
  return ProfileModel(
    id: 'test-profile-id',
    userId: 'test-user-id',
    fullName: 'Test',
    surname: 'User',
    age: 25,
    gender: 'Female',
    height: "5'5\"",
    education: 'Graduate',
    profession: 'Engineer',
    createdAt: now,
    updatedAt: now,
  );
}

/// Test-only Razorpay billing config – no env.json or AppSupabaseClient required.
class TestBillingConfig extends RazorpayAppBillingConfig {
  TestBillingConfig._();
  static final TestBillingConfig _instance = TestBillingConfig._();
  factory TestBillingConfig() => _instance;

  @override
  String get appName => 'BanjaraBio';

  @override
  String get appSlug => 'banjara';

  @override
  String get keyId => 'rzp_test_fake';

  @override
  String get brandColor => '#C94B4B';

  @override
  int getAmountInPaise(String planType) {
    final type = PlanType.fromString(planType);
    return SubscriptionConfig.getFeatures(type).priceInPaise;
  }

  @override
  String getDisplayName(String planType) {
    final type = PlanType.fromString(planType);
    return SubscriptionConfig.getDisplayName(type);
  }
}

bool _supabaseTestSetupDone = false;

/// Ensures Supabase and Razorpay billing are initialized for widget/unit tests
/// that use [RazorpayRepository] or any code touching Supabase.instance.
///
/// Call once in [setUpAll] for test files that need it.
Future<void> ensureSupabaseTestSetup() async {
  if (_supabaseTestSetupDone) return;

  // Required for Supabase auth persistence in tests (avoids MissingPluginException)
  SharedPreferences.setMockInitialValues(<String, Object>{});

  await Supabase.initialize(
    url: 'https://test.supabase.co',
    anonKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZS1kZW1vIiwicm9sZSI6ImFub24iLCJleHAiOjE5ODM4MTI5OTZ9.CRXP1A7WOeoJeXxjNni43kdQwgnWNReilDMblYTn_I0',
  );
  RazorpayBillingRegistry.register(TestBillingConfig());
  _supabaseTestSetupDone = true;
}
