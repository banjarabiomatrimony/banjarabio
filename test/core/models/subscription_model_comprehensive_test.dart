import 'package:flutter_test/flutter_test.dart';
import 'package:banjarabio/core/models/subscription_model.dart';

void main() {
  group('PlanType', () {
    test('displayName returns correct names', () {
      expect(PlanType.free.displayName, 'Free');
      expect(PlanType.gold.displayName, 'Gold');
      expect(PlanType.platinum.displayName, 'Platinum');
      expect(PlanType.eternal.displayName, 'Eternal');
      expect(PlanType.elite.displayName, 'Elite');
      expect(PlanType.royal.displayName, 'Royal');
      expect(PlanType.eternal_elite.displayName, 'Eternal Elite');
      expect(PlanType.biodata_unlock.displayName, 'Biodata Premium');
      expect(PlanType.unknown.displayName, 'Free');
      expect(PlanType.standard.displayName, 'Standard');
      expect(PlanType.silver.displayName, 'Silver');
      expect(PlanType.basic.displayName, 'Basic');
      expect(PlanType.premium.displayName, 'Premium');
      expect(PlanType.vip.displayName, 'VIP');
    });

    test('isVipPlan for VIP plans only', () {
      expect(PlanType.elite.isVipPlan, true);
      expect(PlanType.royal.isVipPlan, true);
      expect(PlanType.eternal_elite.isVipPlan, true);
      expect(PlanType.gold.isVipPlan, false);
    });

    test('isSelfServicePlan for self-service plans', () {
      expect(PlanType.standard.isSelfServicePlan, true);
      expect(PlanType.silver.isSelfServicePlan, true);
      expect(PlanType.gold.isSelfServicePlan, true);
      expect(PlanType.platinum.isSelfServicePlan, true);
      expect(PlanType.eternal.isSelfServicePlan, true);
      expect(PlanType.elite.isSelfServicePlan, false);
    });

    test('isPaidPlan includes both types', () {
      expect(PlanType.gold.isPaidPlan, true);
      expect(PlanType.elite.isPaidPlan, true);
      expect(PlanType.free.isPaidPlan, false);
    });

    test('fromString parses all plan types', () {
      expect(PlanType.fromString('gold'), PlanType.gold);
      expect(PlanType.fromString('elite'), PlanType.elite);
      expect(PlanType.fromString('eternal_elite'), PlanType.eternal_elite);
      expect(PlanType.fromString('biodata_unlock'), PlanType.biodata_unlock);
      expect(PlanType.fromString('unknown_value'), PlanType.free);
    });
  });

  group('SubscriptionStatus', () {
    test('fromString parses all statuses', () {
      expect(SubscriptionStatus.fromString('active'), SubscriptionStatus.active);
      expect(SubscriptionStatus.fromString('expired'), SubscriptionStatus.expired);
      expect(SubscriptionStatus.fromString('cancelled'), SubscriptionStatus.cancelled);
      expect(SubscriptionStatus.fromString('xyz'), SubscriptionStatus.pending);
    });
  });

  group('SubscriptionModel', () {
    Map<String, dynamic> base({Map<String, dynamic>? o}) => {
      'id': 's1', 'user_id': 'u1', 'plan_type': 'gold', 'status': 'active',
      'started_at': '2025-01-01T00:00:00Z', 'created_at': '2025-01-01T00:00:00Z', 'updated_at': '2025-01-01T00:00:00Z', ...?o,
    };

    test('fromJson parses', () {
      final s = SubscriptionModel.fromJson(base(o: {'auto_renew': true, 'razorpay_subscription_id': 'sub_123', 'expires_at': '2099-01-01T00:00:00Z'}));
      expect(s.planType, PlanType.gold);
      expect(s.autoRenew, true);
      expect(s.razorpaySubscriptionId, 'sub_123');
    });

    test('isActive for active non-expired', () {
      expect(SubscriptionModel.fromJson(base(o: {'expires_at': '2099-01-01T00:00:00Z'})).isActive, true);
    });

    test('isActive false for expired', () {
      expect(SubscriptionModel.fromJson(base(o: {'expires_at': '2020-01-01T00:00:00Z'})).isActive, false);
    });

    test('isActive true for eternal (null expiry)', () {
      final s = SubscriptionModel.fromJson(base(o: {'plan_type': 'eternal'}));
      expect(s.isActive, true);
      expect(s.daysRemaining, isNull);
    });

    test('isActive false for cancelled', () {
      expect(SubscriptionModel.fromJson(base(o: {'status': 'cancelled', 'expires_at': '2099-01-01T00:00:00Z'})).isActive, false);
    });

    test('isPremium for active paid plan', () {
      expect(SubscriptionModel.fromJson(base(o: {'expires_at': '2099-01-01T00:00:00Z'})).isPremium, true);
    });

    test('isPremium false for free plan', () {
      expect(SubscriptionModel.fromJson(base(o: {'plan_type': 'free'})).isPremium, false);
    });

    test('isVip for active VIP plan', () {
      expect(SubscriptionModel.fromJson(base(o: {'plan_type': 'elite', 'expires_at': '2099-01-01T00:00:00Z'})).isVip, true);
    });

    test('daysRemaining calculates', () {
      final future = DateTime.now().add(const Duration(days: 30));
      expect(SubscriptionModel.fromJson(base(o: {'expires_at': future.toIso8601String()})).daysRemaining, closeTo(30, 1));
    });

    test('toJson round-trips', () {
      expect(SubscriptionModel.fromJson(base()).toJson()['plan_type'], 'gold');
    });

    test('copyWith changes fields', () {
      final copy = SubscriptionModel.fromJson(base()).copyWith(planType: PlanType.platinum);
      expect(copy.planType, PlanType.platinum);
      expect(copy.id, 's1');
    });
  });
}
