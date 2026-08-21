import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:banjarabio/core/models/backend_response.dart';
import 'package:banjarabio/core/models/coupon_model.dart';
import 'package:banjarabio/core/services/app_logger.dart';

class CouponRepository {
  static final CouponRepository _instance = CouponRepository._internal();
  factory CouponRepository() => _instance;
  CouponRepository._internal();

  SupabaseClient? testClient;

  SupabaseClient get _client => testClient ?? Supabase.instance.client;

  /// Validates a coupon code on the server for the current date.
  Future<BackendResponse<CouponModel?>> validateCoupon(String code) async {
    try {
      final response = await _client.rpc(
        'fn_validate_coupon',
        params: {'p_code': code},
      );

      if (response == null) {
        return BackendResponse.failure('Server returned no response');
      }

      final data = Map<String, dynamic>.from(response as Map);
      if (data['is_valid'] == true) {
        // Since fn_validate_coupon doesn't return full coupon object in my migration,
        // let's fetch it manually or update the RPC to return it.
        // For now, I'll fetch it by code since we know it's valid.
        final couponRes = await _client
            .from('coupons')
            .select()
            .eq('code', code.toUpperCase().trim())
            .eq('is_active', true)
            .single();
        
        return BackendResponse.success(CouponModel.fromJson(couponRes));
      } else {
        return BackendResponse.failure(data['message'] ?? 'Invalid coupon');
      }
    } catch (e) {
      AppLogger.error('CouponRepository', 'Error validating coupon: $e');
      return BackendResponse.failure(e.toString());
    }
  }

  /// Fetches coupons targeted for the specified user.
  Future<BackendResponse<List<CouponModel>>> getTargetedCoupons(String userId) async {
    try {
      final response = await _client.rpc(
        'fn_get_targeted_coupons',
        params: {'p_user_id': userId},
      );

      final rawList = response is List ? response : [];
      final coupons = rawList
          .map((e) => CouponModel.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList();

      return BackendResponse.success(coupons);
    } catch (e) {
      AppLogger.error('CouponRepository', 'Error fetching targeted coupons: $e');
      return BackendResponse.failure(e.toString());
    }
  }

  /// Fetches all active, non-expired dynamic coupons from Supabase (created by Admin/Founder).
  Future<BackendResponse<List<CouponModel>>> getActiveCoupons({String? userId}) async {
    try {
      if (userId != null && userId.isNotEmpty) {
        final targetedRes = await getTargetedCoupons(userId);
        if (targetedRes.isSuccess && targetedRes.data.isNotEmpty) {
          return targetedRes;
        }
      }

      final nowStr = DateFormat('yyyy-MM-dd').format(DateTime.now());
      final res = await _client
          .from('coupons')
          .select()
          .eq('is_active', true)
          .gte('valid_until', nowStr)
          .order('discount_percentage', ascending: false);

      final list = (res as List)
          .map((e) => CouponModel.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList();

      return BackendResponse.success(list);
    } catch (e) {
      AppLogger.error('CouponRepository', 'Error fetching active coupons: $e');
      return BackendResponse.failure(e.toString());
    }
  }
}
