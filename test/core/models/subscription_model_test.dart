import 'package:flutter_test/flutter_test.dart';
import 'package:banjarabio/core/models/subscription_model.dart';

void main() {
  group('PlanType', () {
    test('displayName returns correct name', () {
      expect(PlanType.free.displayName, 'Free');
      expect(PlanType.silver.displayName, 'Silver');
      expect(PlanType.gold.displayName, 'Gold');
      expect(PlanType.platinum.displayName, 'Platinum');
      expect(PlanType.biodata_unlock.displayName, 'Biodata Premium');
    });

    test('fromString parses all known values', () {
      expect(PlanType.fromString('silver'), PlanType.silver);
      expect(PlanType.fromString('gold'), PlanType.gold);
      expect(PlanType.fromString('platinum'), PlanType.platinum);
      expect(PlanType.fromString('biodata_unlock'), PlanType.biodata_unlock);
    });

    test('fromString defaults to free for unknown', () {
      expect(PlanType.fromString('unknown'), PlanType.free);
      expect(PlanType.fromString(''), PlanType.free);
    });
  });

  group('SubscriptionStatus', () {
    test('fromString parses all known values', () {
      expect(SubscriptionStatus.fromString('active'), SubscriptionStatus.active);
      expect(SubscriptionStatus.fromString('expired'), SubscriptionStatus.expired);
      expect(SubscriptionStatus.fromString('cancelled'), SubscriptionStatus.cancelled);
    });

    test('fromString defaults to pending for unknown', () {
      expect(SubscriptionStatus.fromString('unknown'), SubscriptionStatus.pending);
    });
  });

  group('SubscriptionModel', () {
    final futureDate = DateTime.now().add(const Duration(days: 30));
    final pastDate = DateTime.now().subtract(const Duration(days: 5));
    final now = DateTime.now();

    test('fromJson parses all fields', () {
      final json = {
        'id': 'sub1', 'user_id': 'u1', 'plan_type': 'gold', 'status': 'active',
        'started_at': now.toIso8601String(), 'expires_at': futureDate.toIso8601String(),
        'razorpay_subscription_id': 'rzp_sub_1', 'auto_renew': true,
        'created_at': now.toIso8601String(), 'updated_at': now.toIso8601String(),
      };
      final model = SubscriptionModel.fromJson(json);

      expect(model.id, 'sub1');
      expect(model.userId, 'u1');
      expect(model.planType, PlanType.gold);
      expect(model.status, SubscriptionStatus.active);
      expect(model.razorpaySubscriptionId, 'rzp_sub_1');
      expect(model.autoRenew, true);
    });

    test('isActive returns true for active with future expiry', () {
      final model = SubscriptionModel(
        id: 's', userId: 'u', planType: PlanType.gold, status: SubscriptionStatus.active,
        startedAt: now, expiresAt: futureDate, createdAt: now, updatedAt: now,
      );
      expect(model.isActive, true);
    });

    test('isActive returns false for active with past expiry', () {
      final model = SubscriptionModel(
        id: 's', userId: 'u', planType: PlanType.gold, status: SubscriptionStatus.active,
        startedAt: now, expiresAt: pastDate, createdAt: now, updatedAt: now,
      );
      expect(model.isActive, false);
    });

    test('isActive returns true when expiresAt is null', () {
      final model = SubscriptionModel(
        id: 's', userId: 'u', planType: PlanType.gold, status: SubscriptionStatus.active,
        startedAt: now, createdAt: now, updatedAt: now,
      );
      expect(model.isActive, true);
    });

    test('isActive returns false for expired status', () {
      final model = SubscriptionModel(
        id: 's', userId: 'u', planType: PlanType.gold, status: SubscriptionStatus.expired,
        startedAt: now, expiresAt: futureDate, createdAt: now, updatedAt: now,
      );
      expect(model.isActive, false);
    });

    test('isPremium returns true for active silver/gold/platinum', () {
      for (final plan in [PlanType.silver, PlanType.gold, PlanType.platinum]) {
        final model = SubscriptionModel(
          id: 's', userId: 'u', planType: plan, status: SubscriptionStatus.active,
          startedAt: now, expiresAt: futureDate, createdAt: now, updatedAt: now,
        );
        expect(model.isPremium, true, reason: '${plan.name} should be premium');
      }
    });

    test('isPremium returns false for free plan', () {
      final model = SubscriptionModel(
        id: 's', userId: 'u', planType: PlanType.free, status: SubscriptionStatus.active,
        startedAt: now, expiresAt: futureDate, createdAt: now, updatedAt: now,
      );
      expect(model.isPremium, false);
    });

    test('daysRemaining returns correct days', () {
      final model = SubscriptionModel(
        id: 's', userId: 'u', planType: PlanType.gold, status: SubscriptionStatus.active,
        startedAt: now, expiresAt: now.add(const Duration(days: 15)), createdAt: now, updatedAt: now,
      );
      expect(model.daysRemaining, greaterThanOrEqualTo(14));
      expect(model.daysRemaining, lessThanOrEqualTo(16));
    });

    test('daysRemaining returns null when no expiry', () {
      final model = SubscriptionModel(
        id: 's', userId: 'u', planType: PlanType.gold, status: SubscriptionStatus.active,
        startedAt: now, createdAt: now, updatedAt: now,
      );
      expect(model.daysRemaining, isNull);
    });

    test('toJson round-trips correctly', () {
      final model = SubscriptionModel(
        id: 's1', userId: 'u1', planType: PlanType.platinum, status: SubscriptionStatus.active,
        startedAt: now, expiresAt: futureDate, autoRenew: true, createdAt: now, updatedAt: now,
      );
      final json = model.toJson();
      expect(json['plan_type'], 'platinum');
      expect(json['status'], 'active');
      expect(json['auto_renew'], true);
    });

    test('copyWith creates modified copy', () {
      final model = SubscriptionModel(
        id: 's', userId: 'u', planType: PlanType.gold, status: SubscriptionStatus.active,
        startedAt: now, expiresAt: futureDate, createdAt: now, updatedAt: now,
      );
      final modified = model.copyWith(planType: PlanType.platinum, status: SubscriptionStatus.expired);
      expect(modified.planType, PlanType.platinum);
      expect(modified.status, SubscriptionStatus.expired);
      expect(modified.id, 's');
    });
  });
}
