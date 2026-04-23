import 'package:flutter_test/flutter_test.dart';
import 'package:banjarabio/core/models/coupon_model.dart';
import '../helpers/test_data_factory.dart';

void main() {
  group('CouponModel.fromJson', () {
    test('parses all fields from JSON', () {
      final json = {
        'id': 'c-001',
        'code': 'SAVE20',
        'offer_name': 'Festival Offer',
        'description': 'Get 20% off',
        'valid_until': '2025-12-31',
        'discount_percentage': 20,
        'is_active': true,
        'created_at': '2025-01-01T00:00:00.000Z',
        'updated_at': '2025-01-01T00:00:00.000Z',
        'banner_url': 'https://example.com/banner.png',
      };

      final coupon = CouponModel.fromJson(json);
      expect(coupon.id, 'c-001');
      expect(coupon.code, 'SAVE20');
      expect(coupon.offerName, 'Festival Offer');
      expect(coupon.discountPercentage, 20);
      expect(coupon.isActive, true);
      expect(coupon.bannerUrl, 'https://example.com/banner.png');
    });
  });

  group('CouponModel.toJson', () {
    test('round-trip preserves data', () {
      final coupon = TestData.coupon(code: 'TEST10', discountPercentage: 10);
      final json = coupon.toJson();

      expect(json['code'], 'TEST10');
      expect(json['discount_percentage'], 10);
      expect(json['is_active'], true);
    });
  });

  group('CouponModel.isExpired', () {
    test('past date is expired', () {
      final coupon = TestData.coupon(
        validUntil: DateTime.now().subtract(const Duration(days: 5)),
      );
      expect(coupon.isExpired, true);
    });

    test('future date is not expired', () {
      final coupon = TestData.coupon(
        validUntil: DateTime.now().add(const Duration(days: 30)),
      );
      expect(coupon.isExpired, false);
    });
  });

  group('CouponModel.isValidToday', () {
    test('valid today when exact date + active', () {
      final now = DateTime.now();
      final todayCoupon = TestData.coupon(
        validUntil: DateTime(now.year, now.month, now.day),
      );
      expect(todayCoupon.isValidToday, true);
    });

    test('not valid today when inactive', () {
      final now = DateTime.now();
      final inactiveCoupon = TestData.coupon(
        validUntil: DateTime(now.year, now.month, now.day),
        isActive: false,
      );
      expect(inactiveCoupon.isValidToday, false);
    });

    test('not valid today when date is tomorrow', () {
      final tomorrow = DateTime.now().add(const Duration(days: 1));
      final coupon = TestData.coupon(validUntil: tomorrow);
      expect(coupon.isValidToday, false);
    });
  });
}
