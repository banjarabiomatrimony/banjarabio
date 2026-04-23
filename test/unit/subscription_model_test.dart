import 'package:flutter_test/flutter_test.dart';
import 'package:banjarabio/core/models/subscription_model.dart';
import '../helpers/test_data_factory.dart';

void main() {
  // ─── PlanType enum ──────────────────────────────────────────────────────

  group('PlanType.fromString', () {
    test('maps all known plan strings', () {
      expect(PlanType.fromString('standard'), PlanType.standard);
      expect(PlanType.fromString('silver'), PlanType.silver);
      expect(PlanType.fromString('gold'), PlanType.gold);
      expect(PlanType.fromString('platinum'), PlanType.platinum);
      expect(PlanType.fromString('eternal'), PlanType.eternal);
      expect(PlanType.fromString('elite'), PlanType.elite);
      expect(PlanType.fromString('royal'), PlanType.royal);
      expect(PlanType.fromString('eternal_elite'), PlanType.eternal_elite);
      expect(PlanType.fromString('biodata_unlock'), PlanType.biodata_unlock);
      expect(PlanType.fromString('basic'), PlanType.basic);
      expect(PlanType.fromString('premium'), PlanType.premium);
      expect(PlanType.fromString('vip'), PlanType.vip);
    });

    test('unknown string defaults to free', () {
      expect(PlanType.fromString('garbage'), PlanType.free);
      expect(PlanType.fromString(''), PlanType.free);
    });

    test('is case insensitive', () {
      expect(PlanType.fromString('GOLD'), PlanType.gold);
      expect(PlanType.fromString('Platinum'), PlanType.platinum);
    });
  });

  group('PlanType classification', () {
    test('VIP plans', () {
      expect(PlanType.elite.isVipPlan, true);
      expect(PlanType.royal.isVipPlan, true);
      expect(PlanType.eternal_elite.isVipPlan, true);
      expect(PlanType.gold.isVipPlan, false);
      expect(PlanType.free.isVipPlan, false);
    });

    test('Self-service plans', () {
      expect(PlanType.standard.isSelfServicePlan, true);
      expect(PlanType.silver.isSelfServicePlan, true);
      expect(PlanType.gold.isSelfServicePlan, true);
      expect(PlanType.platinum.isSelfServicePlan, true);
      expect(PlanType.eternal.isSelfServicePlan, true);
      expect(PlanType.elite.isSelfServicePlan, false);
    });

    test('isPaidPlan = selfService or VIP', () {
      expect(PlanType.gold.isPaidPlan, true);
      expect(PlanType.royal.isPaidPlan, true);
      expect(PlanType.free.isPaidPlan, false);
      expect(PlanType.unknown.isPaidPlan, false);
    });

    test('displayName returns human-readable string', () {
      expect(PlanType.gold.displayName, 'Gold');
      expect(PlanType.eternal_elite.displayName, 'Eternal Elite');
      expect(PlanType.biodata_unlock.displayName, 'Biodata Premium');
      expect(PlanType.unknown.displayName, 'Free');
    });
  });

  // ─── SubscriptionStatus ─────────────────────────────────────────────────

  group('SubscriptionStatus.fromString', () {
    test('maps known statuses', () {
      expect(SubscriptionStatus.fromString('active'), SubscriptionStatus.active);
      expect(SubscriptionStatus.fromString('expired'), SubscriptionStatus.expired);
      expect(SubscriptionStatus.fromString('cancelled'), SubscriptionStatus.cancelled);
    });

    test('unknown defaults to pending', () {
      expect(SubscriptionStatus.fromString('garbage'), SubscriptionStatus.pending);
    });
  });

  // ─── SubscriptionModel ──────────────────────────────────────────────────

  group('SubscriptionModel.isActive', () {
    test('active + not expired = true', () {
      final sub = TestData.subscription(
        expiresAt: DateTime.now().add(const Duration(days: 30)),
      );
      expect(sub.isActive, true);
    });

    test('active + expired = false', () {
      final sub = TestData.subscription(
        expiresAt: DateTime.now().subtract(const Duration(days: 1)),
      );
      expect(sub.isActive, false);
    });

    test('cancelled = false regardless of expiry', () {
      final sub = TestData.subscription(
        status: SubscriptionStatus.cancelled,
        expiresAt: DateTime.now().add(const Duration(days: 30)),
      );
      expect(sub.isActive, false);
    });

    test('eternal plan (null expiry) + active = true', () {
      final sub = SubscriptionModel(
        id: 'sub',
        userId: 'user',
        planType: PlanType.eternal,
        status: SubscriptionStatus.active,
        startedAt: DateTime.now(),
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      expect(sub.isActive, true);
    });
  });

  group('SubscriptionModel.isPremium', () {
    test('active paid plan = true', () {
      final sub = TestData.subscription(
        expiresAt: DateTime.now().add(const Duration(days: 30)),
      );
      expect(sub.isPremium, true);
    });

    test('active free plan = false', () {
      final sub = TestData.subscription(
        planType: PlanType.free,
        expiresAt: DateTime.now().add(const Duration(days: 30)),
      );
      expect(sub.isPremium, false);
    });
  });

  group('SubscriptionModel.isVip', () {
    test('active VIP plan = true', () {
      final sub = TestData.subscription(
        planType: PlanType.elite,
        expiresAt: DateTime.now().add(const Duration(days: 30)),
      );
      expect(sub.isVip, true);
    });

    test('active non-VIP paid plan = false', () {
      final sub = TestData.subscription(
        expiresAt: DateTime.now().add(const Duration(days: 30)),
      );
      expect(sub.isVip, false);
    });
  });

  group('SubscriptionModel.daysRemaining', () {
    test('returns positive days for future expiry', () {
      final sub = TestData.subscription(
        expiresAt: DateTime.now().add(const Duration(days: 45)),
      );
      expect(sub.daysRemaining, greaterThanOrEqualTo(44));
    });

    test('returns negative for past expiry', () {
      final sub = TestData.subscription(
        expiresAt: DateTime.now().subtract(const Duration(days: 5)),
      );
      expect(sub.daysRemaining, lessThan(0));
    });

    test('returns null for eternal (null expiry)', () {
      final sub = SubscriptionModel(
        id: 'sub',
        userId: 'user',
        planType: PlanType.eternal,
        status: SubscriptionStatus.active,
        startedAt: DateTime.now(),
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      expect(sub.daysRemaining, isNull);
    });
  });

  group('SubscriptionModel.fromJson / toJson', () {
    test('round-trip preserves fields', () {
      final original = TestData.subscription();
      final json = original.toJson();
      final restored = SubscriptionModel.fromJson(json);

      expect(restored.id, original.id);
      expect(restored.userId, original.userId);
      expect(restored.planType, original.planType);
      expect(restored.status, original.status);
      expect(restored.autoRenew, original.autoRenew);
    });
  });
}
