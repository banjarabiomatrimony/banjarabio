import 'package:flutter_test/flutter_test.dart';
import 'package:banjarabio/core/models/referral_model.dart';
import 'package:banjarabio/core/models/referral_stats_model.dart';
import 'package:banjarabio/core/models/sibling_model.dart';
import 'package:banjarabio/core/models/creator_model.dart';

void main() {
  group('ReferralModel', () {
    test('fromJson parses all fields', () {
      final json = {
        'id': 'ref1', 'referrer_id': 'u1', 'referred_user_id': 'u2',
        'status': 'completed', 'created_at': '2025-01-01T00:00:00Z',
      };
      final model = ReferralModel.fromJson(json);
      expect(model.id, 'ref1');
      expect(model.referrerId, 'u1');
      expect(model.referredUserId, 'u2');
      expect(model.status, ReferralStatus.completed);
    });

    test('fromJson defaults to pending for unknown status', () {
      final model = ReferralModel.fromJson({'status': 'unknown'});
      expect(model.status, ReferralStatus.pending);
    });

    test('toJson round-trips correctly', () {
      final model = ReferralModel.fromJson({
        'id': 'ref1', 'referrer_id': 'u1', 'status': 'completed',
        'created_at': '2025-01-01T00:00:00Z',
      });
      final json = model.toJson();
      expect(json['id'], 'ref1');
      expect(json['status'], 'completed');
    });
  });

  group('ReferralStatsModel', () {
    test('fromJson parses all fields', () {
      final json = {
        'user_id': 'u1', 'referral_count': 10, 'rewards_earned': 500,
        'last_reward_at': '2025-01-01T00:00:00Z', 'updated_at': '2025-01-15T00:00:00Z',
      };
      final model = ReferralStatsModel.fromJson(json);
      expect(model.userId, 'u1');
      expect(model.referralCount, 10);
      expect(model.rewardsEarned, 500);
      expect(model.lastRewardAt, isNotNull);
    });

    test('fromJson handles null fields', () {
      final model = ReferralStatsModel.fromJson({});
      expect(model.userId, '');
      expect(model.referralCount, 0);
      expect(model.rewardsEarned, 0);
      expect(model.lastRewardAt, isNull);
    });

    test('empty factory creates zeroed model', () {
      final model = ReferralStatsModel.empty('u1');
      expect(model.userId, 'u1');
      expect(model.referralCount, 0);
      expect(model.rewardsEarned, 0);
    });

    test('toJson round-trips correctly', () {
      final model = ReferralStatsModel.fromJson({
        'user_id': 'u1', 'referral_count': 5, 'rewards_earned': 200,
        'updated_at': '2025-01-01T00:00:00Z',
      });
      final json = model.toJson();
      expect(json['user_id'], 'u1');
      expect(json['referral_count'], 5);
    });
  });

  group('SiblingModel', () {
    test('fromJson parses all fields', () {
      final model = SiblingModel.fromJson({'position': 2, 'relation': 'Brother', 'is_married': true});
      expect(model.position, 2);
      expect(model.relation, 'Brother');
      expect(model.isMarried, true);
    });

    test('fromJson handles defaults', () {
      final model = SiblingModel.fromJson({});
      expect(model.position, 1);
      expect(model.relation, 'Self');
      expect(model.isMarried, false);
    });

    test('toJson round-trips', () {
      final model = SiblingModel.fromJson({'position': 3, 'relation': 'Sister', 'is_married': false});
      final json = model.toJson();
      expect(json['position'], 3);
      expect(json['relation'], 'Sister');
    });
  });

  group('Creator', () {
    final now = DateTime.now();
    final sampleJson = {
      'id': 'c1', 'name': 'Creator1', 'promo_code': 'CODE123',
      'commission_pct': 10.5, 'instagram_handle': '@creator1',
      'total_referrals': 50, 'total_conversions': 20, 'total_commission_earned': 5000.0,
      'is_active': true, 'created_at': now.toIso8601String(), 'updated_at': now.toIso8601String(),
    };

    test('fromJson parses all fields', () {
      final model = Creator.fromJson(sampleJson);
      expect(model.id, 'c1');
      expect(model.name, 'Creator1');
      expect(model.promoCode, 'CODE123');
      expect(model.commissionPct, 10.5);
      expect(model.instagramHandle, '@creator1');
      expect(model.totalReferrals, 50);
      expect(model.totalConversions, 20);
      expect(model.totalCommissionEarned, 5000.0);
      expect(model.isActive, true);
    });

    test('fromJson handles defaults', () {
      final json = {
        'id': 'c2', 'name': 'C2', 'promo_code': 'P2', 'commission_pct': 5,
        'created_at': now.toIso8601String(), 'updated_at': now.toIso8601String(),
      };
      final model = Creator.fromJson(json);
      expect(model.totalReferrals, 0);
      expect(model.totalConversions, 0);
      expect(model.totalCommissionEarned, 0);
      expect(model.isActive, true);
    });

    test('toJson round-trips', () {
      final model = Creator.fromJson(sampleJson);
      final json = model.toJson();
      expect(json['id'], 'c1');
      expect(json['promo_code'], 'CODE123');
      expect(json['commission_pct'], 10.5);
    });
  });
}
