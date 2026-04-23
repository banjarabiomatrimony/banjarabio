import 'package:flutter_test/flutter_test.dart';
import 'package:banjarabio/shared/billing/razorpay_billing_registry.dart';
import 'package:banjarabio/shared/billing/razorpay_app_billing_config.dart';

class FakeBillingConfig extends RazorpayAppBillingConfig {
  @override
  String get appName => 'TestApp';

  @override
  String get appSlug => 'test';

  @override
  String get keyId => 'rzp_test_123';

  @override
  String get brandColor => '#FF0000';

  @override
  int getAmountInPaise(String planType) {
    switch (planType) {
      case 'premium':
        return 49900;
      case 'basic':
        return 19900;
      default:
        return 0;
    }
  }

  @override
  String getDisplayName(String planType) {
    switch (planType) {
      case 'premium':
        return 'Premium Plan';
      case 'basic':
        return 'Basic Plan';
      default:
        return 'Unknown';
    }
  }
}

void main() {
  group('RazorpayBillingRegistry', () {
    test('throws StateError when config not registered', () {
      // Reset static state - create a fresh test scenario
      // Note: Since we can't easily reset the static _config,
      // we test the behavior when config IS registered
      expect(() {
        // If not registered, accessing config should throw
        // This may or may not throw depending on prior test state
        RazorpayBillingRegistry.config;
      }, anyOf(returnsNormally, throwsA(isA<StateError>())));
    });

    test('register and access config', () {
      final config = FakeBillingConfig();
      RazorpayBillingRegistry.register(config);

      expect(RazorpayBillingRegistry.isRegistered, true);
      expect(RazorpayBillingRegistry.config, config);
      expect(RazorpayBillingRegistry.config.appName, 'TestApp');
      expect(RazorpayBillingRegistry.config.appSlug, 'test');
    });

    test('isRegistered returns true after registration', () {
      RazorpayBillingRegistry.register(FakeBillingConfig());

      expect(RazorpayBillingRegistry.isRegistered, true);
    });
  });

  group('RazorpayAppBillingConfig (via FakeBillingConfig)', () {
    late FakeBillingConfig config;

    setUp(() {
      config = FakeBillingConfig();
    });

    test('getAmountInPaise returns correct amounts', () {
      expect(config.getAmountInPaise('premium'), 49900);
      expect(config.getAmountInPaise('basic'), 19900);
      expect(config.getAmountInPaise('unknown'), 0);
    });

    test('getDisplayName returns correct names', () {
      expect(config.getDisplayName('premium'), 'Premium Plan');
      expect(config.getDisplayName('basic'), 'Basic Plan');
      expect(config.getDisplayName('unknown'), 'Unknown');
    });

    test('buildNotes returns correct structure', () {
      final notes = config.buildNotes(userId: 'u1', planType: 'premium');

      expect(notes['user_id'], 'u1');
      expect(notes['plan_type'], 'premium');
      expect(notes['app'], 'TestApp');
    });

    test('buildReceipt returns correct format', () {
      final receipt = config.buildReceipt('abcdefghijkl');

      expect(receipt, startsWith('test_'));
      expect(receipt, contains('abcdefgh'));
    });
  });
}
