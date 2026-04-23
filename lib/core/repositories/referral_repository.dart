import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:banjarabio/core/models/backend_response.dart';
import 'package:banjarabio/core/models/referral_model.dart';
import 'package:banjarabio/core/models/referral_stats_model.dart';
import 'package:banjarabio/core/repositories/isolate_first_repository.dart';

/// [ReferralRepository]
///
/// Manages the Referral System: Generating codes, tracking invites, and rewarding users.
///
/// 🏆 10/10 Architecture Highlights:
/// 1. **Secure Redemption**: Uses `fn_process_referral` RPC to validate codes server-side.
///    This prevents users from referring themselves or spamming fake referrals.
/// 2. **Hybrid Tracking**: Supports both Deep Link IDs and Manual Code entry.
/// 3. **Background Parsing**: Parses large referral history lists on a background thread.
class ReferralRepository extends IsolateFirstRepository {
  // ---------------------------------------------------------------------------
  // 1. Singleton & Dependencies
  // ---------------------------------------------------------------------------
  static final ReferralRepository _instance = ReferralRepository._();
  factory ReferralRepository() => _instance;
  ReferralRepository._();

  @visibleForTesting
  SupabaseClient? testClient;
  SupabaseClient get _supabase => testClient ?? Supabase.instance.client;

  // ---------------------------------------------------------------------------
  // 2. Core Actions (RPC)
  // ---------------------------------------------------------------------------

  /// Fetches (or generates) the unique referral code for the current user.
  /// Example: "BANJARA-7X29"
  Future<BackendResponse<String>> getMyReferralCode() async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) {
        return BackendResponse.failure('User not authenticated');
      }

      // 1. Check if code already exists in profile
      final response = await _supabase
          .from('profiles')
          .select('referral_code')
          .eq('user_id', userId)
          .single();

      if (response['referral_code'] != null) {
        return BackendResponse.success(response['referral_code']);
      }

      // 2. If not, generate via fn_process_referral RPC (returns { ok: true, code })
      final newCodeRes = await _callReferralRpc('generate_code', {});

      return newCodeRes.fold(
        onSuccess: (data) {
          if (data is Map && data.containsKey('code')) {
            return BackendResponse.success(data['code'] as String);
          }
          // Fallback if structure is different
          return BackendResponse.failure('Invalid code format from server');
        },
        onFailure: (err) => BackendResponse.failure(err),
      );
    } catch (e) {
      return BackendResponse.failure(e.toString());
    }
  }

  /// Redeems a referral code (Manual Entry or Deep Link).
  ///
  /// This function:
  /// 1. Validates the code exists.
  /// 2. Checks if the user is new (hasn't been referred yet).
  /// 3. Prevents self-referral.
  /// 4. Awards rewards to both parties.
  Future<BackendResponse<void>> redeemReferralCode(String code) async {
    return _callReferralRpc('redeem_code', {'code': code.toUpperCase()});
  }

  /// [Deep Link Handler]
  /// Marks a pending referral as completed when a user signs up.
  /// This is used when we tracked the install via a deep link ID (not a visible code).
  Future<BackendResponse<void>> completeReferral(
    String referralId,
    String referredUserId,
  ) async {
    return _callReferralRpc('complete_referral', {
      'referral_id': referralId,
      'referred_user_id': referredUserId,
    });
  }

  // ---------------------------------------------------------------------------
  // 3. Data Fetching
  // ---------------------------------------------------------------------------

  /// Get summary stats: Total Invites, Pending, Earned Rewards.
  Future<BackendResponse<ReferralStatsModel>> getReferralStats() async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) {
        return BackendResponse.failure('User not authenticated');
      }

      final response = await _supabase
          .from('referral_stats')
          .select()
          .eq('user_id', userId)
          .maybeSingle();

      if (response == null) {
        // Return empty stats for new users
        return BackendResponse.success(ReferralStatsModel.empty(userId));
      }

      return BackendResponse.success(ReferralStatsModel.fromJson(response));
    } catch (e) {
      return BackendResponse.failure(e.toString());
    }
  }

  /// Get the full history of who I referred.
  Future<BackendResponse<List<ReferralModel>>> getMyReferrals() async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) {
        return BackendResponse.failure('User not authenticated');
      }

      // referrals.referred_user_id -> auth.users; no direct FK to profiles.
      // Select referral columns only; matches 13_referrals_and_rewards schema.
      final response = await _supabase
          .from('referrals')
          .select('id, referrer_id, referred_user_id, status, created_at')
          .eq('referrer_id', userId)
          .order('created_at', ascending: false);

      // Parse on background thread to prevent UI jank
      // Note: 'referred_user' join needs to be handled by ReferralModel.fromJson or flattened
      final referrals = await mapListInBackground<ReferralModel>(
        response as List,
        ReferralModel.fromJson,
      );

      return BackendResponse.success(referrals);
    } catch (e) {
      return BackendResponse.failure(e.toString());
    }
  }

  // ---------------------------------------------------------------------------
  // 4. Private Helpers
  // ---------------------------------------------------------------------------

  /// Centralized handler for Referral RPC calls.
  /// RPC returns { ok: true, code?: ... } or { ok: false, error: ... }.
  Future<BackendResponse<dynamic>> _callReferralRpc(
    String action,
    Map<String, dynamic> payload,
  ) async {
    try {
      debugPrint('Referral RPC: fn_process_referral -> $action');
      final response = await _supabase.rpc(
        'fn_process_referral',
        params: {'action': action, 'payload': payload},
      );

      if (response is Map && response['ok'] == false) {
        return BackendResponse.failure(
          response['error']?.toString() ?? 'Unknown error',
        );
      }
      return BackendResponse.fromRpc(response);
    } catch (e) {
      debugPrint('Referral Action Failed [$action]: $e');
      return BackendResponse.failure(e.toString());
    }
  }
}
