import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:banjarabio/core/models/backend_response.dart';
import 'package:banjarabio/core/models/daily_reward_model.dart';
import 'package:banjarabio/core/supabase_client.dart' as app_supabase;

class DailyRewardRepository {
  // Singleton
  static final DailyRewardRepository _instance = DailyRewardRepository._();
  factory DailyRewardRepository() => _instance;
  DailyRewardRepository._();

  SupabaseClient? _testClient;
  SupabaseClient get _supabase => _testClient ?? Supabase.instance.client;

  @visibleForTesting
  set testClient(SupabaseClient? client) => _testClient = client;

  Future<BackendResponse<DailyRewardModel>> getRewardStatus() async {
    try {
      final userId = app_supabase.AppSupabaseClient.currentUserId;
      if (userId == null) return BackendResponse.failure('Not authenticated');

      final nowUtc = DateTime.now().toUtc();
      final todayStr = nowUtc.toIso8601String().substring(0, 10);
      final yesterdayStr = nowUtc.subtract(const Duration(days: 1)).toIso8601String().substring(0, 10);

      final response = await _supabase
          .from('daily_rewards')
          .select()
          .eq('user_id', userId)
          .maybeSingle();

      if (response == null) {
        return BackendResponse.success(
          const DailyRewardModel(streakCount: 1, isClaimedToday: false),
        );
      }

      final lastClaimDateStr = response['last_claim_date']?.toString().substring(0, 10);
      final isClaimedToday = lastClaimDateStr == todayStr;
      
      int activeStreak = (response['streak_count'] as num?)?.toInt() ?? 1;

      // Predict the upcoming streak limit visually if not claimed today
      if (!isClaimedToday) {
         if (lastClaimDateStr != yesterdayStr) {
           activeStreak = 1; // Streak was broken
         } else {
           activeStreak += 1;
           if (activeStreak > 7) activeStreak = 1;
         }
      }

      return BackendResponse.success(
        DailyRewardModel(
          streakCount: activeStreak,
          isClaimedToday: isClaimedToday,
        ),
      );
    } catch (e) {
      debugPrint('getRewardStatus error: $e');
      return BackendResponse.failure(e.toString());
    }
  }

  Future<BackendResponse<DailyRewardModel>> claimDailyReward() async {
    try {
      final response = await _supabase.rpc('fn_claim_daily_reward');
      final data = response as Map<String, dynamic>;
      
      if (data['status'] == 'success') {
        return BackendResponse.success(
          DailyRewardModel(
            streakCount: (data['streak_count'] as num).toInt(),
            isClaimedToday: true,
            lastReward: RewardPayload.fromJson(data['reward'] as Map<String, dynamic>),
          ),
        );
      }
      return BackendResponse.failure('Failed to parse claim response');
    } catch (e) {
      debugPrint('claimDailyReward error: $e');
      if (e.toString().contains('ALREADY_CLAIMED_TODAY')) {
        return BackendResponse.failure('You have already claimed your reward today!');
      }
      return BackendResponse.failure(e.toString());
    }
  }
}
