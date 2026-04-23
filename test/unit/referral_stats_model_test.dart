import 'package:flutter_test/flutter_test.dart';
import 'package:banjarabio/core/models/referral_stats_model.dart';
import '../helpers/test_data_factory.dart';

void main() {
  group('ReferralStatsModel.fromJson', () {
    test('parses all fields', () {
      final json = {
        'user_id': 'user-001',
        'referral_count': 10,
        'rewards_earned': 5,
        'last_reward_at': '2025-06-15T12:00:00.000Z',
        'updated_at': '2025-06-15T12:00:00.000Z',
      };

      final model = ReferralStatsModel.fromJson(json);
      expect(model.userId, 'user-001');
      expect(model.referralCount, 10);
      expect(model.rewardsEarned, 5);
      expect(model.lastRewardAt, isNotNull);
    });

    test('handles null/missing fields with defaults', () {
      final model = ReferralStatsModel.fromJson({});
      expect(model.userId, '');
      expect(model.referralCount, 0);
      expect(model.rewardsEarned, 0);
      expect(model.lastRewardAt, isNull);
    });
  });

  group('ReferralStatsModel.empty', () {
    test('creates empty stats for a user', () {
      final model = ReferralStatsModel.empty('user-001');
      expect(model.userId, 'user-001');
      expect(model.referralCount, 0);
      expect(model.rewardsEarned, 0);
      expect(model.lastRewardAt, isNull);
    });
  });

  group('ReferralStatsModel.toJson', () {
    test('round-trip preserves data', () {
      final original = TestData.referralStats(
        referralCount: 10,
        rewardsEarned: 5,
      );
      final json = original.toJson();

      expect(json['user_id'], 'user-uuid-001');
      expect(json['referral_count'], 10);
      expect(json['rewards_earned'], 5);
    });
  });
}
