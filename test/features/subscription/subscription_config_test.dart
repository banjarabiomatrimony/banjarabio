import 'package:flutter_test/flutter_test.dart';
import 'package:banjarabio/core/models/subscription_config.dart';
import 'package:banjarabio/core/models/subscription_model.dart';

void main() {
  group('SubscriptionConfig Tests', () {
    test('getFeatures should return correct limits for Free plan', () {
      final features = SubscriptionConfig.getFeatures(PlanType.free);
      expect(features.price, 0);
      expect(features.profileViewsPerDay, 5);
      expect(features.messaging, false);
      expect(features.advancedFilters, false);
    });

    test('getFeatures should return correct limits for Gold plan', () {
      final features = SubscriptionConfig.getFeatures(PlanType.gold);
      expect(features.price, 6300);
      expect(features.messaging, true);
      expect(features.profileViewsPerDay, 999); // Unlimited signal
      expect(features.adFree, true);
    });

    test('hasUnlimitedFeature should correctly identify unlimited flags', () {
      expect(SubscriptionConfig.hasUnlimitedFeature(PlanType.free, 'profileViews'), false);
      expect(SubscriptionConfig.hasUnlimitedFeature(PlanType.gold, 'profileViews'), true);
      expect(SubscriptionConfig.hasUnlimitedFeature(PlanType.silver, 'shares'), true);
    });

    test('calculateSavings should return positive values for paid plans', () {
      // Silver MRP is 4500, price is 3600. Savings = 900
      final savings = SubscriptionConfig.calculateSavings(PlanType.silver);
      expect(savings, 900);
    });

    test('getDiscountedPrice should integrate with Trust Score', () {
      // Silver price 3600. Trust Score 95 -> 30% discount.
      // 3600 * 0.7 = 2520
      final silverFeatures = SubscriptionConfig.getFeatures(PlanType.silver);
      final discounted = silverFeatures.getDiscountedPrice(95); // level 4
      expect(discounted, 2520);
    });
    
    test('getDisplayName should provide human readable labels', () {
      expect(SubscriptionConfig.getDisplayName(PlanType.platinum), 'Platinum - 1 Year');
      expect(SubscriptionConfig.getDisplayName(PlanType.free), 'Free');
    });
  });
}
