import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:banjarabio/core/models/trust_score_config.dart';

void main() {
  group('TrustScoreConfig.calculateScore', () {
    test('returns 0 when nothing verified', () {
      expect(TrustScoreConfig.calculateScore(), 0);
    });

    test('individual flags add correctly', () {
      expect(TrustScoreConfig.calculateScore(hasMobile: true), 10);
      expect(TrustScoreConfig.calculateScore(hasEmail: true), 10);
      expect(TrustScoreConfig.calculateScore(hasPhoto: true), 10);
      expect(TrustScoreConfig.calculateScore(hasCommunityId: true), 15);
      expect(TrustScoreConfig.calculateScore(hasGovtId: true), 15);
      expect(TrustScoreConfig.calculateScore(hasReference: true), 10);
      expect(TrustScoreConfig.calculateScore(hasVideoBio: true), 10);
      expect(TrustScoreConfig.calculateScore(isProfileComplete: true), 20);
    });

    test('all verified = 100', () {
      expect(TrustScoreConfig.calculateScore(
        hasMobile: true, hasEmail: true, hasPhoto: true,
        hasCommunityId: true, hasGovtId: true, hasReference: true,
        hasVideoBio: true, isProfileComplete: true,
      ), 100);
    });

    test('partial combination sums correctly', () {
      expect(TrustScoreConfig.calculateScore(hasMobile: true, hasPhoto: true, hasGovtId: true), 35);
    });
  });

  group('TrustScoreConfig.getDiscountPercentage', () {
    test('all tiers return correct discount', () {
      expect(TrustScoreConfig.getDiscountPercentage(0), 0);
      expect(TrustScoreConfig.getDiscountPercentage(29), 0);
      expect(TrustScoreConfig.getDiscountPercentage(30), 5);
      expect(TrustScoreConfig.getDiscountPercentage(49), 5);
      expect(TrustScoreConfig.getDiscountPercentage(50), 10);
      expect(TrustScoreConfig.getDiscountPercentage(74), 10);
      expect(TrustScoreConfig.getDiscountPercentage(75), 20);
      expect(TrustScoreConfig.getDiscountPercentage(89), 20);
      expect(TrustScoreConfig.getDiscountPercentage(90), 30);
      expect(TrustScoreConfig.getDiscountPercentage(100), 30);
    });
  });

  group('TrustScoreConfig.getDiscountedPrice', () {
    test('applies correct discounts', () {
      expect(TrustScoreConfig.getDiscountedPrice(1000, 0), 1000);
      expect(TrustScoreConfig.getDiscountedPrice(1000, 30), 950);
      expect(TrustScoreConfig.getDiscountedPrice(1000, 50), 900);
      expect(TrustScoreConfig.getDiscountedPrice(1000, 75), 800);
      expect(TrustScoreConfig.getDiscountedPrice(1000, 90), 700);
    });

    test('rounds correctly', () {
      expect(TrustScoreConfig.getDiscountedPrice(999, 30), 949);
    });
  });

  group('TrustScoreConfig.getLevelName', () {
    test('returns correct level names', () {
      expect(TrustScoreConfig.getLevelName(0), isNull);
      expect(TrustScoreConfig.getLevelName(49), isNull);
      expect(TrustScoreConfig.getLevelName(50), 'Standard');
      expect(TrustScoreConfig.getLevelName(75), 'Trusted');
      expect(TrustScoreConfig.getLevelName(90), 'Verified');
    });
  });

  group('TrustScoreConfig.getLevelColor', () {
    test('returns correct colors', () {
      expect(TrustScoreConfig.getLevelColor(0), Colors.grey);
      expect(TrustScoreConfig.getLevelColor(50), Colors.green);
      expect(TrustScoreConfig.getLevelColor(75), Colors.blue);
      expect(TrustScoreConfig.getLevelColor(90), Colors.amber);
    });
  });

  group('TrustScoreConfig constants', () {
    test('all points sum to maxScore', () {
      final total = TrustScoreConfig.pointsMobile + TrustScoreConfig.pointsEmail +
          TrustScoreConfig.pointsPhoto + TrustScoreConfig.pointsCommunityId +
          TrustScoreConfig.pointsGovtId + TrustScoreConfig.pointsReference +
          TrustScoreConfig.pointsVideoBio + TrustScoreConfig.pointsProfileCompletion;
      expect(total, TrustScoreConfig.maxScore);
    });
  });
}
