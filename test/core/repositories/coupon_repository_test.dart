import 'package:flutter_test/flutter_test.dart';
import 'package:banjarabio/core/repositories/coupon_repository.dart';
import 'package:banjarabio/core/models/coupon_model.dart';
import '../../helpers/supabase_fakes.dart';

void main() {
  late FakeSupabaseClient fakeSupabase;
  late CouponRepository couponRepository;

  setUp(() {
    fakeSupabase = FakeSupabaseClient();
    couponRepository = CouponRepository();
    couponRepository.testClient = fakeSupabase;
  });

  group('CouponRepository Tests', () {
    test('validateCoupon returns success for valid code', () async {
      final now = DateTime.now();
      final couponData = {
        'id': 'coupon-123',
        'code': 'SAVE50',
        'offer_name': 'Half Off',
        'discount_percentage': 50,
        'valid_until': now.toIso8601String(),
        'is_active': true,
        'created_at': now.toIso8601String(),
        'updated_at': now.toIso8601String(),
      };
      
      fakeSupabase.rpcResponse = {'is_valid': true, 'message': 'Success'};
      fakeSupabase.setTableData('coupons', [couponData]);
      
      final result = await couponRepository.validateCoupon('SAVE50');
      
      expect(result.isSuccess, true);
      expect(result.data?.code, 'SAVE50');
      expect(result.data?.discountPercentage, 50);
      expect(fakeSupabase.rpcFunction, 'fn_validate_coupon');
    });

    test('validateCoupon handles invalid code', () async {
      fakeSupabase.rpcResponse = {'is_valid': false, 'message': 'Invalid coupon'};
      
      final result = await couponRepository.validateCoupon('INVALID');
      
      expect(result.isSuccess, false);
      expect(result.errorMessage, 'Invalid coupon');
    });

    test('validateCoupon handles server error', () async {
      fakeSupabase.rpcError = 'Server error';
      
      final result = await couponRepository.validateCoupon('ERROR');
      
      expect(result.isSuccess, false);
      expect(result.errorMessage, contains('Server error'));
    });
  });

  group('CouponModel Tests', () {
    test('isValidToday should return true for today', () {
      final now = DateTime.now();
      final coupon = CouponModel(
        id: '1',
        code: 'TEST',
        offerName: 'Test',
        validUntil: now,
        discountPercentage: 10,
        createdAt: now,
        updatedAt: now,
      );
      expect(coupon.isValidToday, true);
    });

    test('isExpired should return true for past dates', () {
      final yesterday = DateTime.now().subtract(const Duration(days: 1));
      final coupon = CouponModel(
        id: '1',
        code: 'TEST',
        offerName: 'Test',
        validUntil: yesterday,
        discountPercentage: 10,
        createdAt: yesterday,
        updatedAt: yesterday,
      );
      expect(coupon.isExpired, true);
    });
  });
}
