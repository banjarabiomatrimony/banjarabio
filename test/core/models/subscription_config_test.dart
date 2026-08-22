import 'package:flutter_test/flutter_test.dart';
import 'package:banjarabio/core/models/subscription_config.dart';
import 'package:banjarabio/core/models/subscription_model.dart';

void main() {
  group('PlanFeatures', () {
    test('priceInPaise converts correctly', () {
      expect(SubscriptionConfig.silver.priceInPaise, 360000);
      expect(SubscriptionConfig.gold.priceInPaise, 630000);
      expect(SubscriptionConfig.platinum.priceInPaise, 1080000);
      expect(SubscriptionConfig.free.priceInPaise, 0);
    });

    test('displayPrice formats correctly', () {
      expect(SubscriptionConfig.silver.displayPrice(), '₹3600');
      expect(SubscriptionConfig.free.displayPrice(), 'Free');
    });

    test('pricePerMonth calculates correctly', () {
      expect(SubscriptionConfig.silver.pricePerMonth, 3600 / 3);
      expect(SubscriptionConfig.gold.pricePerMonth, 6300 / 6);
      expect(SubscriptionConfig.platinum.pricePerMonth, 10800 / 12);
      expect(SubscriptionConfig.free.pricePerMonth, 0);
    });

    test('getDiscountedPrice returns discounted value', () {
      final price = SubscriptionConfig.platinum.getDiscountedPrice(100);
      expect(price, lessThanOrEqualTo(10800));
    });

    test('getDiscountedPrice returns 0 for free plan', () {
      expect(SubscriptionConfig.free.getDiscountedPrice(100), 0);
    });
  });

  group('SubscriptionConfig', () {
    test('getFeatures returns correct features for each plan', () {
      expect(SubscriptionConfig.getFeatures(PlanType.free), SubscriptionConfig.free);
      expect(SubscriptionConfig.getFeatures(PlanType.silver), SubscriptionConfig.silver);
      expect(SubscriptionConfig.getFeatures(PlanType.gold), SubscriptionConfig.gold);
      expect(SubscriptionConfig.getFeatures(PlanType.platinum), SubscriptionConfig.platinum);
      expect(SubscriptionConfig.getFeatures(PlanType.biodata_unlock), SubscriptionConfig.biodataUnlock);
    });

    test('getAllPaidPlans returns self-service paid plans', () {
      final plans = SubscriptionConfig.getAllPaidPlans();
      expect(plans.isNotEmpty, true);
      expect(plans.map((p) => p.key), containsAll([PlanType.standard, PlanType.silver, PlanType.gold, PlanType.platinum]));
    });

    test('getBvsSubsidizedPlans returns 2 subsidized plans', () {
      final plans = SubscriptionConfig.getBvsSubsidizedPlans();
      expect(plans.length, 2);
      expect(plans.map((p) => p.key), containsAll([PlanType.mass_market, PlanType.mass_market_annual]));
    });

    test('calculateSavings returns positive value for paid plans', () {
      expect(SubscriptionConfig.calculateSavings(PlanType.silver), greaterThan(0));
      expect(SubscriptionConfig.calculateSavings(PlanType.gold), greaterThan(0));
      expect(SubscriptionConfig.calculateSavings(PlanType.platinum), greaterThan(0));
      expect(SubscriptionConfig.calculateSavings(PlanType.free), 0);
    });

    test('getDisplayName returns formatted names', () {
      expect(SubscriptionConfig.getDisplayName(PlanType.silver), contains('Silver'));
      expect(SubscriptionConfig.getDisplayName(PlanType.gold), contains('Gold'));
      expect(SubscriptionConfig.getDisplayName(PlanType.platinum), contains('Platinum'));
      expect(SubscriptionConfig.getDisplayName(PlanType.biodata_unlock), contains('Biodata'));
      expect(SubscriptionConfig.getDisplayName(PlanType.free), 'Free');
    });

    test('getDescription returns descriptions', () {
      expect(SubscriptionConfig.getDescription(PlanType.silver).isNotEmpty, true);
      expect(SubscriptionConfig.getDescription(PlanType.gold).isNotEmpty, true);
      expect(SubscriptionConfig.getDescription(PlanType.platinum).isNotEmpty, true);
      expect(SubscriptionConfig.getDescription(PlanType.free).isNotEmpty, true);
    });

    test('hasUnlimitedFeature checks correctly', () {
      expect(SubscriptionConfig.hasUnlimitedFeature(PlanType.platinum, 'profileViews'), true);
      expect(SubscriptionConfig.hasUnlimitedFeature(PlanType.free, 'profileViews'), false);
      expect(SubscriptionConfig.hasUnlimitedFeature(PlanType.gold, 'shares'), true);
      expect(SubscriptionConfig.hasUnlimitedFeature(PlanType.free, 'shares'), false);
    });

    test('isPlanBetterOrEqual compares tiers correctly', () {
      expect(SubscriptionConfig.isPlanBetterOrEqual(PlanType.platinum, PlanType.gold), true);
      expect(SubscriptionConfig.isPlanBetterOrEqual(PlanType.gold, PlanType.silver), true);
      expect(SubscriptionConfig.isPlanBetterOrEqual(PlanType.silver, PlanType.free), true);
      expect(SubscriptionConfig.isPlanBetterOrEqual(PlanType.free, PlanType.gold), false);
      expect(SubscriptionConfig.isPlanBetterOrEqual(PlanType.gold, PlanType.gold), true);
    });

    test('plan features have correct limits', () {
      expect(SubscriptionConfig.free.profileViewsPerDay, 5);
      expect(SubscriptionConfig.free.photosLimit, 1);
      expect(SubscriptionConfig.free.messaging, false);

      expect(SubscriptionConfig.silver.messaging, true);
      expect(SubscriptionConfig.silver.advancedFilters, true);
      expect(SubscriptionConfig.silver.photosLimit, 7);

      expect(SubscriptionConfig.gold.verificationBadge, true);
      expect(SubscriptionConfig.gold.adFree, true);
      expect(SubscriptionConfig.gold.prioritySupport, true);

      expect(SubscriptionConfig.platinum.matchmakerSupport, true);
      expect(SubscriptionConfig.platinum.photosLimit, 15);
    });
  });
}
