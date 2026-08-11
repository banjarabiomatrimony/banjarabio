import 'package:flutter_test/flutter_test.dart';
import 'package:banjarabio/core/models/subscription_config.dart';
import 'package:banjarabio/core/models/subscription_model.dart';

void main() {
  // ─── PlanFeatures pricing ──────────────────────────────────────────────

  group('PlanFeatures.priceInPaise', () {
    test('converts rupees to paise', () {
      expect(SubscriptionConfig.gold.priceInPaise, 630000);
      expect(SubscriptionConfig.free.priceInPaise, 0);
      expect(SubscriptionConfig.standard.priceInPaise, 150000);
    });
  });

  group('PlanFeatures.bulkSavings', () {
    test('calculates MRP - offer price', () {
      expect(SubscriptionConfig.gold.bulkSavings, 2700); // 9000 - 6300
      expect(SubscriptionConfig.silver.bulkSavings, 900); // 4500 - 3600
      expect(SubscriptionConfig.free.bulkSavings, 0);
      expect(SubscriptionConfig.standard.bulkSavings, 0); // no discount
    });
  });

  group('PlanFeatures.pricePerMonth', () {
    test('calculates per-month cost for standard plans', () {
      expect(SubscriptionConfig.gold.pricePerMonth, 1050.0); // 6300/6
      expect(SubscriptionConfig.platinum.pricePerMonth, 900.0); // 10800/12
    });

    test('returns 0 for lifetime plans', () {
      expect(SubscriptionConfig.eternal.pricePerMonth, 0.0);
    });

    test('returns 0 for free plan', () {
      expect(SubscriptionConfig.free.pricePerMonth, 0.0);
    });
  });

  group('PlanFeatures.isLifetime', () {
    test('eternal plans are lifetime', () {
      expect(SubscriptionConfig.eternal.isLifetime, true);
      expect(SubscriptionConfig.eternalElite.isLifetime, true);
    });

    test('regular plans are not lifetime', () {
      expect(SubscriptionConfig.gold.isLifetime, false);
      expect(SubscriptionConfig.standard.isLifetime, false);
    });
  });

  // ─── 3-Layer Pricing ──────────────────────────────────────────────────

  group('PlanFeatures.getDiscountedPrice (trust score)', () {
    test('0 trust score = no discount', () {
      final price = SubscriptionConfig.gold.getDiscountedPrice(0);
      expect(price, 6300); // 0% discount
    });

    test('75 trust score = 20% discount', () {
      final price = SubscriptionConfig.gold.getDiscountedPrice(75);
      expect(price, 5040); // 6300 * 0.8
    });

    test('90+ trust score = 30% discount', () {
      final price = SubscriptionConfig.gold.getDiscountedPrice(95);
      expect(price, 4410); // 6300 * 0.7
    });
  });

  group('PlanFeatures.getFinalPrice (trust + coupon)', () {
    test('trust discount only', () {
      final price = SubscriptionConfig.gold.getFinalPrice(75);
      expect(price, 5040);
    });

    test('trust + coupon discount stacks', () {
      final price = SubscriptionConfig.gold.getFinalPrice(75, couponPercent: 10);
      // After trust: 5040, coupon 10% off: 5040 - 504 = 4536
      expect(price, 4536);
    });

    test('zero coupon is no-op', () {
      final withCoupon = SubscriptionConfig.gold.getFinalPrice(75);
      final without = SubscriptionConfig.gold.getFinalPrice(75);
      expect(withCoupon, without);
    });

    test('free plan stays 0 regardless of discounts', () {
      expect(SubscriptionConfig.free.getFinalPrice(100, couponPercent: 50), 0);
    });
  });

  group('PlanFeatures.getTotalSavings', () {
    test('calculates total MRP-to-final savings', () {
      final savings = SubscriptionConfig.gold.getTotalSavings(75, couponPercent: 10);
      // MRP 9000 - final 4536 = 4464
      expect(savings, 4464);
    });
  });

  // ─── Config Lookups ───────────────────────────────────────────────────

  group('SubscriptionConfig.getFeatures', () {
    test('returns correct config for each PlanType', () {
      expect(SubscriptionConfig.getFeatures(PlanType.gold), SubscriptionConfig.gold);
      expect(SubscriptionConfig.getFeatures(PlanType.elite), SubscriptionConfig.elite);
      expect(SubscriptionConfig.getFeatures(PlanType.free), SubscriptionConfig.free);
      expect(SubscriptionConfig.getFeatures(PlanType.unknown), SubscriptionConfig.free);
    });
  });

  group('SubscriptionConfig.getDisplayName', () {
    test('returns human-readable names', () {
      expect(SubscriptionConfig.getDisplayName(PlanType.gold), contains('Gold'));
      expect(SubscriptionConfig.getDisplayName(PlanType.eternal), contains('Eternal'));
      expect(SubscriptionConfig.getDisplayName(PlanType.elite), contains('Elite'));
    });

    test('free plan returns Free', () {
      expect(SubscriptionConfig.getDisplayName(PlanType.free), 'Free');
    });
  });

  group('SubscriptionConfig.isPlanBetterOrEqual', () {
    test('same plan is equal', () {
      expect(SubscriptionConfig.isPlanBetterOrEqual(PlanType.gold, PlanType.gold), true);
    });

    test('higher tier >= lower tier', () {
      expect(SubscriptionConfig.isPlanBetterOrEqual(PlanType.platinum, PlanType.gold), true);
      expect(SubscriptionConfig.isPlanBetterOrEqual(PlanType.eternal_elite, PlanType.standard), true);
    });

    test('lower tier < higher tier', () {
      expect(SubscriptionConfig.isPlanBetterOrEqual(PlanType.standard, PlanType.gold), false);
      expect(SubscriptionConfig.isPlanBetterOrEqual(PlanType.silver, PlanType.platinum), false);
    });

    test('any plan >= free', () {
      expect(SubscriptionConfig.isPlanBetterOrEqual(PlanType.standard, PlanType.free), true);
      expect(SubscriptionConfig.isPlanBetterOrEqual(PlanType.free, PlanType.free), true);
    });
  });

  group('SubscriptionConfig.hasUnlimitedFeature', () {
    test('gold has unlimited profile views', () {
      expect(SubscriptionConfig.hasUnlimitedFeature(PlanType.gold, 'profileViews'), true);
    });

    test('free does not have unlimited shares', () {
      expect(SubscriptionConfig.hasUnlimitedFeature(PlanType.free, 'shares'), false);
    });

    test('eternal elite has unlimited contact unlocks', () {
      expect(SubscriptionConfig.hasUnlimitedFeature(PlanType.eternal_elite, 'contactUnlocks'), true);
    });
  });

  group('SubscriptionConfig plan lists', () {
    test('getSelfServicePlans returns active plans', () {
      expect(SubscriptionConfig.getSelfServicePlans(), hasLength(2));
    });

    test('getVipPlans returns active VIP plans', () {
      expect(SubscriptionConfig.getVipPlans(), hasLength(0));
    });
  });
}
