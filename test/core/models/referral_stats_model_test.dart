import 'package:flutter_test/flutter_test.dart';
import 'package:banjarabio/core/models/referral_stats_model.dart';

void main() {
  final now = DateTime(2025, 3, 20, 14);

  group('ReferralStatsModel', () {
    test('fromJson parses all fields correctly', () {
      final json = {
        'user_id': 'user-abc',
        'referral_count': 5,
        'rewards_earned': 150,
        'last_reward_at': now.toIso8601String(),
        'updated_at': now.toIso8601String(),
      };
      final model = ReferralStatsModel.fromJson(json);
      expect(model.userId, 'user-abc');
      expect(model.referralCount, 5);
      expect(model.rewardsEarned, 150);
      expect(model.lastRewardAt, now);
      expect(model.updatedAt, now);
    });

    test('fromJson handles null/missing fields with defaults', () {
      final json = <String, dynamic>{};
      final model = ReferralStatsModel.fromJson(json);
      expect(model.userId, '');
      expect(model.referralCount, 0);
      expect(model.rewardsEarned, 0);
      expect(model.lastRewardAt, isNull);
      expect(model.updatedAt, isNotNull);
    });

    test('fromJson handles null last_reward_at', () {
      final json = {
        'user_id': 'u1',
        'referral_count': 1,
        'rewards_earned': 10,
        'last_reward_at': null,
        'updated_at': now.toIso8601String(),
      };
      final model = ReferralStatsModel.fromJson(json);
      expect(model.lastRewardAt, isNull);
    });

    test('empty factory creates zero-state model', () {
      final model = ReferralStatsModel.empty('user-xyz');
      expect(model.userId, 'user-xyz');
      expect(model.referralCount, 0);
      expect(model.rewardsEarned, 0);
      expect(model.lastRewardAt, isNull);
      expect(model.updatedAt, isNotNull);
    });

    test('toJson produces correct map', () {
      final model = ReferralStatsModel(
        userId: 'u1',
        referralCount: 3,
        rewardsEarned: 90,
        lastRewardAt: now,
        updatedAt: now,
      );
      final json = model.toJson();
      expect(json['user_id'], 'u1');
      expect(json['referral_count'], 3);
      expect(json['rewards_earned'], 90);
      expect(json['last_reward_at'], now.toIso8601String());
      expect(json['updated_at'], now.toIso8601String());
    });

    test('toJson handles null lastRewardAt', () {
      final model = ReferralStatsModel.empty('u2');
      final json = model.toJson();
      expect(json['last_reward_at'], isNull);
    });

    test('roundtrip fromJson -> toJson preserves data', () {
      final original = ReferralStatsModel(
        userId: 'round',
        referralCount: 7,
        rewardsEarned: 210,
        lastRewardAt: now,
        updatedAt: now,
      );
      final recreated = ReferralStatsModel.fromJson(original.toJson());
      expect(recreated.userId, original.userId);
      expect(recreated.referralCount, original.referralCount);
      expect(recreated.rewardsEarned, original.rewardsEarned);
      expect(recreated.lastRewardAt, original.lastRewardAt);
    });
  });
}
