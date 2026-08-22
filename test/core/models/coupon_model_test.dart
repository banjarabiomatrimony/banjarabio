import 'package:flutter_test/flutter_test.dart';
import 'package:banjarabio/core/models/coupon_model.dart';

void main() {
  late DateTime now;
  late DateTime today;
  late Map<String, dynamic> sampleJson;

  setUp(() {
    now = DateTime.now();
    today = DateTime(now.year, now.month, now.day);
    sampleJson = {
      'id': 'c1',
      'code': 'SAVE20',
      'offer_name': '20% Off',
      'description': 'Special discount',
      'valid_until': today.toIso8601String(),
      'discount_percentage': 20,
      'is_active': true,
      'created_at': now.toIso8601String(),
      'updated_at': now.toIso8601String(),
      'banner_url': 'https://example.com/banner.jpg',
      'target_filters': {'gender': 'Male'},
    };
  });

  group('CouponModel - fromJson', () {
    test('fromJson parses all fields', () {
      final model = CouponModel.fromJson(sampleJson);

      expect(model.id, 'c1');
      expect(model.code, 'SAVE20');
      expect(model.offerName, '20% Off');
      expect(model.description, 'Special discount');
      expect(model.discountPercentage, 20);
      expect(model.isActive, true);
      expect(model.bannerUrl, 'https://example.com/banner.jpg');
      expect(model.targetFilters, {'gender': 'Male'});
    });

    test('fromJson handles null optional fields', () {
      final json = {
        'id': 'c2',
        'code': 'FREE10',
        'offer_name': '10% Off',
        'valid_until': today.toIso8601String(),
        'discount_percentage': 10,
        'created_at': now.toIso8601String(),
        'updated_at': now.toIso8601String(),
      };
      final model = CouponModel.fromJson(json);

      expect(model.description, isNull);
      expect(model.bannerUrl, isNull);
      expect(model.targetFilters, isNull);
      expect(model.isActive, true); // default
    });
  });

  group('CouponModel - toJson', () {
    test('toJson produces correct map', () {
      final model = CouponModel.fromJson(sampleJson);
      final json = model.toJson();

      expect(json['id'], 'c1');
      expect(json['code'], 'SAVE20');
      expect(json['offer_name'], '20% Off');
      expect(json['discount_percentage'], 20);
      expect(json['is_active'], true);
      expect(json['target_filters'], {'gender': 'Male'});
    });
  });

  group('CouponModel - isExpired', () {
    test('returns true for past date', () {
      final pastJson = {
        ...sampleJson,
        'valid_until': DateTime(2020).toIso8601String(),
      };
      final model = CouponModel.fromJson(pastJson);

      expect(model.isExpired, true);
    });

    test('returns false for today', () {
      final todayJson = {
        ...sampleJson,
        'valid_until': today.toIso8601String(),
      };
      final model = CouponModel.fromJson(todayJson);

      expect(model.isExpired, false);
    });

    test('returns false for future date', () {
      final futureJson = {
        ...sampleJson,
        'valid_until': DateTime(2099, 12, 31).toIso8601String(),
      };
      final model = CouponModel.fromJson(futureJson);

      expect(model.isExpired, false);
    });
  });

  group('CouponModel - isValidToday', () {
    test('returns true when valid_until is today and coupon is active', () {
      final todayJson = {
        ...sampleJson,
        'valid_until': today.toIso8601String(),
        'is_active': true,
      };
      final model = CouponModel.fromJson(todayJson);

      expect(model.isValidToday, true);
    });

    test('returns false when valid_until is today but coupon is inactive', () {
      final todayInactiveJson = {
        ...sampleJson,
        'valid_until': today.toIso8601String(),
        'is_active': false,
      };
      final model = CouponModel.fromJson(todayInactiveJson);

      expect(model.isValidToday, false);
    });

    test('returns false when valid_until is not today', () {
      final futureJson = {
        ...sampleJson,
        'valid_until': DateTime(2099, 12, 31).toIso8601String(),
        'is_active': true,
      };
      final model = CouponModel.fromJson(futureJson);

      expect(model.isValidToday, false);
    });
  });
}
