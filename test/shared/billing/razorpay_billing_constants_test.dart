import 'package:flutter_test/flutter_test.dart';

import 'package:banjarabio/shared/billing/razorpay_billing_constants.dart';

void main() {
  group('RazorpayBillingConstants', () {
    test('edgeFunctionCreateOrder is create-razorpay-order', () {
      expect(
        RazorpayBillingConstants.edgeFunctionCreateOrder,
        'create-razorpay-order',
      );
    });

    test('defaultCurrency is INR', () {
      expect(RazorpayBillingConstants.defaultCurrency, 'INR');
    });

    test('buildReceipt formats correctly', () {
      final receipt = RazorpayBillingConstants.buildReceipt(
        appSlug: 'banjara',
        userId: 'a1b2c3d4-e5f6-7890-abcd-ef1234567890',
        timestamp: 1739123456,
      );
      expect(receipt, 'banjara_a1b2c3d4_1739123456');
    });

    test('buildReceipt short userId uses full id', () {
      final receipt = RazorpayBillingConstants.buildReceipt(
        appSlug: 'app2',
        userId: 'short',
        timestamp: 1,
      );
      expect(receipt, 'app2_short_1');
    });

    test('buildNotes includes user_id plan_type app', () {
      final notes = RazorpayBillingConstants.buildNotes(
        userId: 'user-123',
        planType: 'biodata_unlock',
        appName: 'BanjaraBio',
      );
      expect(notes['user_id'], 'user-123');
      expect(notes['plan_type'], 'biodata_unlock');
      expect(notes['app'], 'BanjaraBio');
    });

    test('buildGroupedMetadata creates correct nested structure', () {
      final metadata = RazorpayBillingConstants.buildGroupedMetadata(
        appSlug: 'banjara',
        appId: 'BJBIO',
        appName: 'BanjaraBio',
        source: 'app',
        version: '1.1.0',
        platform: 'android',
        device: 'Pixel 6',
        os: 'Android 13',
        network: 'wifi',
        userId: 'u1',
        userGender: 'Male',
        userAge: 30,
        userLocation: 'Maharashtra',
        plan: 'silver',
        duration: 1,
        coupon: 'SAVE50',
        entry: 'profile',
        referrer: 'ref1',
      );

      expect(metadata['app']['slug'], 'banjara');
      expect(metadata['tech']['platform'], 'android');
      expect(metadata['user']['gender'], 'Male');
      expect(metadata['txn']['plan'], 'silver');
      expect(metadata['txn']['coupon'], 'SAVE50');
      expect(metadata['ref']['referrer'], 'ref1');
      expect(metadata['date']['year'], isA<int>());
    });
  });
}
