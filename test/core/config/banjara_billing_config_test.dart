import 'package:flutter_test/flutter_test.dart';

import 'package:banjarabio/core/config/banjara_billing_config.dart';
import 'package:banjarabio/shared/billing/razorpay_billing_registry.dart';

void main() {
  setUpAll(() {
    // Register config so getAmountInPaise/getDisplayName work
    RazorpayBillingRegistry.register(BanjaraBillingConfig());
  });

  group('BanjaraBillingConfig', () {
    test('appName is BanjaraBio', () {
      final config = BanjaraBillingConfig();
      expect(config.appName, 'BanjaraBio');
    });

    test('appSlug is banjara', () {
      final config = BanjaraBillingConfig();
      expect(config.appSlug, 'banjara');
    });

    test('brandColor is BanjaraBio primary', () {
      final config = BanjaraBillingConfig();
      expect(config.brandColor, '#C94B4B');
    });

    test('getAmountInPaise biodata_unlock returns 19900', () {
      final config = BanjaraBillingConfig();
      expect(config.getAmountInPaise('biodata_unlock'), 19900);
    });

    test('getDisplayName biodata_unlock returns expected string', () {
      final config = BanjaraBillingConfig();
      final name = config.getDisplayName('biodata_unlock');
      expect(name, contains('Biodata'));
    });

    test('buildNotes includes app', () {
      final config = BanjaraBillingConfig();
      final notes = config.buildNotes(userId: 'u1', planType: 'biodata_unlock');
      expect(notes['user_id'], 'u1');
      expect(notes['plan_type'], 'biodata_unlock');
      expect(notes['app'], 'BanjaraBio');
    });
  });
}
