import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:banjarabio/core/models/backend_response.dart';
import 'package:banjarabio/core/models/creator_model.dart';
import 'package:banjarabio/core/repositories/isolate_first_repository.dart';
import 'package:banjarabio/core/services/app_logger.dart';

/// [InfluencerRepository]
///
/// Manages Influencer Marketing: Tracking creator referrals and admin-side creator management.
class InfluencerRepository extends IsolateFirstRepository {
  static final InfluencerRepository _instance = InfluencerRepository._();
  factory InfluencerRepository() => _instance;
  InfluencerRepository._();

  SupabaseClient get _supabase => testClient ?? Supabase.instance.client;

  /// 🧪 TEST-ONLY: Inject a mock client.
  @visibleForTesting
  SupabaseClient? testClient;

  // ---------------------------------------------------------------------------
  // 1. User-Facing Actions
  // ---------------------------------------------------------------------------

  /// Registers a user under a creator using their promo code.
  Future<BackendResponse<void>> registerCreatorReferral(String promoCode) async {
    try {
      final response = await _supabase.rpc(
        'fn_register_creator_referral',
        params: {'p_promo_code': promoCode},
      );

      if (response is Map && response['ok'] == false) {
        return BackendResponse.failure(
          response['error']?.toString() ?? 'Invalid promo code',
        );
      }
      return BackendResponse.success(null);
    } catch (e) {
      AppLogger.error('InfluencerRepository', 'Register Creator Referral Failed: $e');
      return BackendResponse.failure(e.toString());
    }
  }

  // ---------------------------------------------------------------------------
  // 2. Admin Actions (Centralized via fn_admin_actions)
  // ---------------------------------------------------------------------------

  /// Fetches all creators for the admin dashboard.
  Future<BackendResponse<List<Creator>>> getAllCreators() async {
    try {
      final response = await _supabase.rpc(
        'fn_admin_actions',
        params: {'action': 'get_creators', 'p_payload': {}},
      );

      return BackendResponse.fromRpc<List<Creator>>(
        response,
        mapper: (json) {
          final List<dynamic> data = json as List<dynamic>;
          return data
              .map((e) => Creator.fromJson(Map<String, dynamic>.from(e as Map)))
              .toList();
        },
      );
    } catch (e) {
      AppLogger.error('InfluencerRepository', 'Get All Creators Failed: $e');
      return BackendResponse.failure(e.toString());
    }
  }

  /// Adds a new creator.
  Future<BackendResponse<void>> addCreator({
    required String name,
    required String promoCode,
    double commissionPct = 0.10,
    String? instagramHandle,
    String? phoneNumber,
  }) async {
    try {
      final response = await _supabase.rpc(
        'fn_admin_actions',
        params: {
          'action': 'add_creator',
          'p_payload': {
            'name': name,
            'promo_code': promoCode,
            'commission_pct': commissionPct,
            'instagram_handle': instagramHandle,
            'phone_number': phoneNumber,
          },
        },
      );
      return BackendResponse.fromRpc(response);
    } catch (e) {
      AppLogger.error('InfluencerRepository', 'Add Creator Failed: $e');
      return BackendResponse.failure(e.toString());
    }
  }

  /// Updates an existing creator.
  Future<BackendResponse<void>> updateCreator({
    required String id,
    String? name,
    double? commissionPct,
    String? instagramHandle,
    String? phoneNumber,
    bool? isActive,
  }) async {
    try {
      final response = await _supabase.rpc(
        'fn_admin_actions',
        params: {
          'action': 'update_creator',
          'p_payload': {
            'id': id,
            if (name != null) 'name': name,
            if (commissionPct != null) 'commission_pct': commissionPct,
            if (instagramHandle != null) 'instagram_handle': instagramHandle,
            if (phoneNumber != null) 'phone_number': phoneNumber,
            if (isActive != null) 'is_active': isActive,
          },
        },
      );
      return BackendResponse.fromRpc(response);
    } catch (e) {
      AppLogger.error('InfluencerRepository', 'Update Creator Failed: $e');
      return BackendResponse.failure(e.toString());
    }
  }
}
