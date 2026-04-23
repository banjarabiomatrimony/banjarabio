import 'package:flutter_test/flutter_test.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:banjarabio/core/repositories/daily_reward_repository.dart';
import 'package:banjarabio/core/supabase_client.dart';
import '../../helpers/supabase_fakes.dart';

void main() {
  late FakeSupabaseClient fakeSupabase;
  late DailyRewardRepository repository;

  setUp(() {
    fakeSupabase = FakeSupabaseClient();
    repository = DailyRewardRepository();
    repository.testClient = fakeSupabase;
    
    // Mock AppSupabaseClient for currentUserId
    AppSupabaseClient.testAuth = fakeSupabase.auth;
    AppSupabaseClient.testClient = fakeSupabase;

    // Default mock user
    fakeSupabase.mockUser = const User(
      id: 'test-user',
      appMetadata: {},
      userMetadata: {},
      aud: '',
      createdAt: '',
    );
  });

  group('DailyRewardRepository Tests', () {
    test('getRewardStatus returns streak 1 when no history exists', () async {
      final rewardsTable = fakeSupabase.from('daily_rewards') as dynamic;
      rewardsTable.builder.responseData = null; // No existing row

      final result = await repository.getRewardStatus();

      expect(result.isSuccess, true);
      expect(result.data.streakCount, 1);
      expect(result.data.isClaimedToday, false);
    });

    test('getRewardStatus handles streak logic when claimed today', () async {
      final nowUtc = DateTime.now().toUtc();
      final todayStr = nowUtc.toIso8601String().substring(0, 10);
      
      final rewardsTable = fakeSupabase.from('daily_rewards') as dynamic;
      rewardsTable.builder.responseData = {
        'last_claim_date': todayStr,
        'streak_count': 3,
      };

      final result = await repository.getRewardStatus();

      expect(result.isSuccess, true);
      expect(result.data.streakCount, 3);
      expect(result.data.isClaimedToday, true);
    });

    test('getRewardStatus predicts next streak when streak is unbroken', () async {
      final yesterdayUtc = DateTime.now().toUtc().subtract(const Duration(days: 1));
      final yesterdayStr = yesterdayUtc.toIso8601String().substring(0, 10);
      
      final rewardsTable = fakeSupabase.from('daily_rewards') as dynamic;
      rewardsTable.builder.responseData = {
        'last_claim_date': yesterdayStr,
        'streak_count': 3,
      };

      final result = await repository.getRewardStatus();

      expect(result.isSuccess, true);
      expect(result.data.streakCount, 4); // Predicts 4
      expect(result.data.isClaimedToday, false);
    });

    test('getRewardStatus resets streak when streak is broken', () async {
      final twoDaysAgoUtc = DateTime.now().toUtc().subtract(const Duration(days: 2));
      final brokenDateStr = twoDaysAgoUtc.toIso8601String().substring(0, 10);
      
      final rewardsTable = fakeSupabase.from('daily_rewards') as dynamic;
      rewardsTable.builder.responseData = {
        'last_claim_date': brokenDateStr,
        'streak_count': 3,
      };

      final result = await repository.getRewardStatus();

      expect(result.isSuccess, true);
      // Streak broken, next should be 1
      expect(result.data.streakCount, 1);
      expect(result.data.isClaimedToday, false);
    });

    test('getRewardStatus loops back to 1 after day 7', () async {
      final yesterdayUtc = DateTime.now().toUtc().subtract(const Duration(days: 1));
      final yesterdayStr = yesterdayUtc.toIso8601String().substring(0, 10);
      
      final rewardsTable = fakeSupabase.from('daily_rewards') as dynamic;
      rewardsTable.builder.responseData = {
        'last_claim_date': yesterdayStr,
        'streak_count': 7,
      };

      final result = await repository.getRewardStatus();

      expect(result.isSuccess, true);
      // Next day after 7 is 1
      expect(result.data.streakCount, 1);
      expect(result.data.isClaimedToday, false);
    });

    test('claimReward loops through successfully', () async {
       fakeSupabase.rpcResponse = {
         'status': 'success',
         'streak_count': 3,
         'reward': {
           'type': 'profile_views',
           'amount': 2,
         }
       };

       final result = await repository.claimDailyReward();

       expect(result.isSuccess, true);
       expect(result.data.streakCount, 3);
       expect(result.data.isClaimedToday, true);
       expect(result.data.lastReward?.type, 'profile_views');
       expect(result.data.lastReward?.amount, 2);
    });
  });
}
