import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:banjarabio/core/models/trust_score_config.dart';

void main() {
  group('TrustScoreConfig - calculateScore', () {
    test('returns 0 when all flags are false', () {
      expect(TrustScoreConfig.calculateScore(), 0);
    });

    test('returns maxScore (100) when all flags are true', () {
      final score = TrustScoreConfig.calculateScore(
        hasMobile: true,
        hasEmail: true,
        hasPhoto: true,
        hasCommunityId: true,
        hasGovtId: true,
        hasReference: true,
        hasVideoBio: true,
        isProfileComplete: true,
      );

      expect(score, 100);
    });

    test('adds correct points for individual flags', () {
      expect(TrustScoreConfig.calculateScore(hasMobile: true), 10);
      expect(TrustScoreConfig.calculateScore(hasEmail: true), 10);
      expect(TrustScoreConfig.calculateScore(hasPhoto: true), 10);
      expect(TrustScoreConfig.calculateScore(hasCommunityId: true), 15);
      expect(TrustScoreConfig.calculateScore(hasGovtId: true), 15);
      expect(TrustScoreConfig.calculateScore(hasReference: true), 10);
      expect(TrustScoreConfig.calculateScore(hasVideoBio: true), 10);
      expect(TrustScoreConfig.calculateScore(isProfileComplete: true), 20);
    });

    test('combines multiple flags correctly', () {
      final score = TrustScoreConfig.calculateScore(
        hasMobile: true,
        hasEmail: true,
        hasPhoto: true,
      );

      expect(score, 30); // 10 + 10 + 10
    });

    test('score is clamped to maxScore', () {
      // Even if somehow all flags exceed 100, it should clamp
      final score = TrustScoreConfig.calculateScore(
        hasMobile: true,
        hasEmail: true,
        hasPhoto: true,
        hasCommunityId: true,
        hasGovtId: true,
        hasReference: true,
        hasVideoBio: true,
        isProfileComplete: true,
      );

      expect(score, lessThanOrEqualTo(TrustScoreConfig.maxScore));
    });
  });

  group('TrustScoreConfig - getDiscountPercentage', () {
    test('returns 0 for score below level1', () {
      expect(TrustScoreConfig.getDiscountPercentage(0), 0);
      expect(TrustScoreConfig.getDiscountPercentage(29), 0);
    });

    test('returns 5 for level1 threshold (30-49)', () {
      expect(TrustScoreConfig.getDiscountPercentage(30), 5);
      expect(TrustScoreConfig.getDiscountPercentage(49), 5);
    });

    test('returns 10 for level2 threshold (50-74)', () {
      expect(TrustScoreConfig.getDiscountPercentage(50), 10);
      expect(TrustScoreConfig.getDiscountPercentage(74), 10);
    });

    test('returns 20 for level3 threshold (75-89)', () {
      expect(TrustScoreConfig.getDiscountPercentage(75), 20);
      expect(TrustScoreConfig.getDiscountPercentage(89), 20);
    });

    test('returns 30 for level4 threshold (90+)', () {
      expect(TrustScoreConfig.getDiscountPercentage(90), 30);
      expect(TrustScoreConfig.getDiscountPercentage(100), 30);
    });
  });

  group('TrustScoreConfig - getDiscountedPrice', () {
    test('returns original price when score is 0', () {
      expect(TrustScoreConfig.getDiscountedPrice(1000, 0), 1000);
    });

    test('applies 5% discount for level1', () {
      // 1000 * 5% = 50 discount → 950
      expect(TrustScoreConfig.getDiscountedPrice(1000, 30), 950);
    });

    test('applies 30% discount for level4', () {
      // 1000 * 30% = 300 discount → 700
      expect(TrustScoreConfig.getDiscountedPrice(1000, 95), 700);
    });

    test('handles odd amounts correctly (rounds)', () {
      // 999 * 10% = 99.9 discount → 999 - 99.9 = 899.1 → 899
      expect(TrustScoreConfig.getDiscountedPrice(999, 50), 899);
    });
  });

  group('TrustScoreConfig - getLevelName', () {
    test('returns null for score below 50', () {
      expect(TrustScoreConfig.getLevelName(0), isNull);
      expect(TrustScoreConfig.getLevelName(49), isNull);
    });

    test('returns Standard for score 50-74', () {
      expect(TrustScoreConfig.getLevelName(50), 'Standard');
      expect(TrustScoreConfig.getLevelName(74), 'Standard');
    });

    test('returns Trusted for score 75-89', () {
      expect(TrustScoreConfig.getLevelName(75), 'Trusted');
      expect(TrustScoreConfig.getLevelName(89), 'Trusted');
    });

    test('returns Verified for score 90+', () {
      expect(TrustScoreConfig.getLevelName(90), 'Verified');
      expect(TrustScoreConfig.getLevelName(100), 'Verified');
    });
  });

  group('TrustScoreConfig - getLevelColor', () {
    test('returns grey for low scores', () {
      expect(TrustScoreConfig.getLevelColor(0), Colors.grey);
      expect(TrustScoreConfig.getLevelColor(49), Colors.grey);
    });

    test('returns green for Standard level', () {
      expect(TrustScoreConfig.getLevelColor(50), Colors.green);
    });

    test('returns blue for Trusted level', () {
      expect(TrustScoreConfig.getLevelColor(75), Colors.blue);
    });

    test('returns amber (gold) for Verified level', () {
      expect(TrustScoreConfig.getLevelColor(90), Colors.amber);
    });
  });

  group('TrustScoreConfig - constants', () {
    test('maxScore is 100', () {
      expect(TrustScoreConfig.maxScore, 100);
    });

    test('threshold constants are in ascending order', () {
      expect(TrustScoreConfig.level1Threshold, lessThan(TrustScoreConfig.level2Threshold));
      expect(TrustScoreConfig.level2Threshold, lessThan(TrustScoreConfig.level3Threshold));
      expect(TrustScoreConfig.level3Threshold, lessThan(TrustScoreConfig.level4Threshold));
    });

    test('discount constants are in ascending order', () {
      expect(TrustScoreConfig.discountLevel0, lessThan(TrustScoreConfig.discountLevel1));
      expect(TrustScoreConfig.discountLevel1, lessThan(TrustScoreConfig.discountLevel2));
      expect(TrustScoreConfig.discountLevel2, lessThan(TrustScoreConfig.discountLevel3));
      expect(TrustScoreConfig.discountLevel3, lessThan(TrustScoreConfig.discountLevel4));
    });
  });
}
