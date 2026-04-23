import 'package:flutter_test/flutter_test.dart';
import 'package:banjarabio/shared/billing/razorpay_billing_constants.dart';

void main() {
  group('RazorpayBillingConstants - constants', () {
    test('edgeFunctionCreateOrder is correct', () {
      expect(RazorpayBillingConstants.edgeFunctionCreateOrder, 'create-razorpay-order');
    });

    test('action constants are correct', () {
      expect(RazorpayBillingConstants.actionCreateOrder, 'create_order');
      expect(RazorpayBillingConstants.actionVerifyPayment, 'verify_payment');
      expect(RazorpayBillingConstants.actionSyncPdfUnlock, 'sync_pdf_unlock');
      expect(RazorpayBillingConstants.actionRecordPayment, 'record_payment');
      expect(RazorpayBillingConstants.actionGetHistory, 'get_history');
    });

    test('defaultCurrency is INR', () {
      expect(RazorpayBillingConstants.defaultCurrency, 'INR');
    });
  });

  group('RazorpayBillingConstants - buildReceipt', () {
    test('builds receipt with correct format', () {
      final receipt = RazorpayBillingConstants.buildReceipt(
        appSlug: 'banjara',
        userId: 'abcdefghijkl',
        timestamp: 1234567890,
      );

      expect(receipt, 'banjara_abcdefgh_1234567890');
    });

    test('handles short user ID (less than 8 chars)', () {
      final receipt = RazorpayBillingConstants.buildReceipt(
        appSlug: 'banjara',
        userId: 'abc',
        timestamp: 999,
      );

      expect(receipt, 'banjara_abc_999');
    });

    test('truncates userId to first 8 characters', () {
      final receipt = RazorpayBillingConstants.buildReceipt(
        appSlug: 'app',
        userId: '12345678extra',
        timestamp: 0,
      );

      expect(receipt, 'app_12345678_0');
    });
  });

  group('RazorpayBillingConstants - buildNotes', () {
    test('builds correct notes map', () {
      final notes = RazorpayBillingConstants.buildNotes(
        userId: 'u1',
        planType: 'premium',
        appName: 'BanjaraBio',
      );

      expect(notes['user_id'], 'u1');
      expect(notes['plan_type'], 'premium');
      expect(notes['app'], 'BanjaraBio');
    });
  });

  group('RazorpayBillingConstants - buildGroupedMetadata', () {
    test('builds correct grouped metadata', () {
      final meta = RazorpayBillingConstants.buildGroupedMetadata(
        appSlug: 'banjara',
        appId: 'com.avishio.banjarabio',
        appName: 'BanjaraBio',
        source: 'organic',
        version: '1.0.0',
        platform: 'android',
        device: 'Pixel 7',
        os: 'Android 14',
        network: 'wifi',
        userId: 'u1',
        userGender: 'Male',
        userAge: 28,
        userLocation: 'Pune',
        plan: 'premium',
        duration: 3,
        coupon: 'SAVE20',
        entry: 'paywall',
        referrer: 'ref123',
      );

      expect(meta['app']['slug'], 'banjara');
      expect(meta['app']['name'], 'BanjaraBio');
      expect(meta['tech']['platform'], 'android');
      expect(meta['tech']['device'], 'Pixel 7');
      expect(meta['user']['id'], 'u1');
      expect(meta['user']['gender'], 'Male');
      expect(meta['user']['age'], 28);
      expect(meta['txn']['plan'], 'premium');
      expect(meta['txn']['duration'], 3);
      expect(meta['txn']['coupon'], 'SAVE20');
      expect(meta['ref']['referrer'], 'ref123');
      expect(meta['date']['year'], isA<int>());
      expect(meta['date']['month'], isA<int>());
      expect(meta['date']['day'], isA<int>());
    });

    test('handles null coupon and referrer', () {
      final meta = RazorpayBillingConstants.buildGroupedMetadata(
        appSlug: 'banjara',
        appId: 'id',
        appName: 'App',
        source: 'organic',
        version: '1.0',
        platform: 'ios',
        device: 'iPhone',
        os: 'iOS 18',
        network: 'mobile',
        userId: 'u2',
        userGender: 'Female',
        userAge: 25,
        userLocation: 'Mumbai',
        plan: 'basic',
        duration: 1,
        coupon: null,
        entry: 'profile',
        referrer: null,
      );

      expect(meta['txn']['coupon'], isNull);
      expect(meta['ref']['referrer'], isNull);
    });
  });
}
