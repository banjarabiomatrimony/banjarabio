import 'package:flutter_test/flutter_test.dart';
import 'package:banjarabio/core/models/referral_model.dart';
import 'package:banjarabio/core/models/referral_stats_model.dart';

void main() {
  group('ReferralStatus', () {
    test('fromString parses completed', () {
      expect(ReferralStatus.fromString('completed'), ReferralStatus.completed);
    });

    test('fromString defaults to pending', () {
      expect(ReferralStatus.fromString('unknown'), ReferralStatus.pending);
      expect(ReferralStatus.fromString(''), ReferralStatus.pending);
    });
  });

  group('ReferralModel', () {
    test('fromJson parses all fields', () {
      final r = ReferralModel.fromJson({
        'id': 'r1',
        'referrer_id': 'u1',
        'referred_user_id': 'u2',
        'status': 'completed',
        'created_at': '2025-06-01T00:00:00Z',
      });
      expect(r.id, 'r1');
      expect(r.referrerId, 'u1');
      expect(r.referredUserId, 'u2');
      expect(r.status, ReferralStatus.completed);
    });

    test('defaults for missing fields', () {
      final r = ReferralModel.fromJson({});
      expect(r.id, '');
      expect(r.referredUserId, isNull);
      expect(r.status, ReferralStatus.pending);
    });

    test('toJson round-trips', () {
      final json = ReferralModel.fromJson({
        'id': 'r1', 'referrer_id': 'u1', 'status': 'completed',
        'created_at': '2025-06-01T00:00:00Z',
      }).toJson();
      expect(json['id'], 'r1');
      expect(json['status'], 'completed');
    });
  });

  group('ReferralStatsModel', () {
    test('fromJson parses all fields', () {
      final s = ReferralStatsModel.fromJson({
        'user_id': 'u1',
        'referral_count': 5,
        'rewards_earned': 250,
        'last_reward_at': '2025-06-01T00:00:00Z',
        'updated_at': '2025-06-01T00:00:00Z',
      });
      expect(s.userId, 'u1');
      expect(s.referralCount, 5);
      expect(s.rewardsEarned, 250);
      expect(s.lastRewardAt, isNotNull);
    });

    test('defaults for missing fields', () {
      final s = ReferralStatsModel.fromJson({});
      expect(s.referralCount, 0);
      expect(s.rewardsEarned, 0);
      expect(s.lastRewardAt, isNull);
    });

    test('empty factory creates default stats', () {
      final s = ReferralStatsModel.empty('u1');
      expect(s.userId, 'u1');
      expect(s.referralCount, 0);
      expect(s.rewardsEarned, 0);
    });

    test('toJson round-trips', () {
      final json = ReferralStatsModel.fromJson({
        'user_id': 'u1', 'referral_count': 3, 'rewards_earned': 100,
        'updated_at': '2025-06-01T00:00:00Z',
      }).toJson();
      expect(json['referral_count'], 3);
      expect(json['rewards_earned'], 100);
    });
  });
}
