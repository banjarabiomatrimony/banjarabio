import 'package:flutter_test/flutter_test.dart';
import 'package:banjarabio/core/models/trust_score_config.dart';

void main() {
  group('TrustScoreConfig.calculateScore', () {
    test('all false flags = 0', () {
      expect(TrustScoreConfig.calculateScore(), 0);
    });

    test('individual flag contributions', () {
      expect(TrustScoreConfig.calculateScore(hasMobile: true), 10);
      expect(TrustScoreConfig.calculateScore(hasEmail: true), 10);
      expect(TrustScoreConfig.calculateScore(hasPhoto: true), 10);
      expect(TrustScoreConfig.calculateScore(hasCommunityId: true), 15);
      expect(TrustScoreConfig.calculateScore(hasGovtId: true), 15);
      expect(TrustScoreConfig.calculateScore(hasReference: true), 10);
      expect(TrustScoreConfig.calculateScore(hasVideoBio: true), 10);
      expect(TrustScoreConfig.calculateScore(isProfileComplete: true), 20);
    });

    test('all true flags = 100 (max score)', () {
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

    test('clamped at 100 even if somehow exceeds', () {
      // With all true it is exactly 100 (10+10+10+15+15+10+10+20)
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
      expect(score, lessThanOrEqualTo(100));
    });
  });

  group('TrustScoreConfig.getDiscountPercentage', () {
    test('below level1 (30) = 0%', () {
      expect(TrustScoreConfig.getDiscountPercentage(0), 0);
      expect(TrustScoreConfig.getDiscountPercentage(29), 0);
    });

    test('level1 boundary (30) = 5%', () {
      expect(TrustScoreConfig.getDiscountPercentage(30), 5);
    });

    test('level2 boundary (50) = 10%', () {
      expect(TrustScoreConfig.getDiscountPercentage(50), 10);
      expect(TrustScoreConfig.getDiscountPercentage(49), 5);
    });

    test('level3 boundary (75) = 20%', () {
      expect(TrustScoreConfig.getDiscountPercentage(75), 20);
      expect(TrustScoreConfig.getDiscountPercentage(74), 10);
    });

    test('level4 boundary (90) = 30%', () {
      expect(TrustScoreConfig.getDiscountPercentage(90), 30);
      expect(TrustScoreConfig.getDiscountPercentage(100), 30);
    });
  });

  group('TrustScoreConfig.getDiscountedPrice', () {
    test('0 score = full price', () {
      expect(TrustScoreConfig.getDiscountedPrice(1000, 0), 1000);
    });

    test('75 score = 20% off', () {
      expect(TrustScoreConfig.getDiscountedPrice(1000, 75), 800);
    });

    test('90 score = 30% off', () {
      expect(TrustScoreConfig.getDiscountedPrice(1000, 90), 700);
    });

    test('handles odd amounts with rounding', () {
      // 5% off 999 = 999 - 49.95 ≈ 949
      expect(TrustScoreConfig.getDiscountedPrice(999, 30), 949);
    });
  });

  group('TrustScoreConfig.getLevelName', () {
    test('below 50 = null (no badge)', () {
      expect(TrustScoreConfig.getLevelName(0), isNull);
      expect(TrustScoreConfig.getLevelName(29), isNull);
      expect(TrustScoreConfig.getLevelName(49), isNull);
    });

    test('50-74 = Standard', () {
      expect(TrustScoreConfig.getLevelName(50), 'Standard');
      expect(TrustScoreConfig.getLevelName(74), 'Standard');
    });

    test('75-89 = Trusted', () {
      expect(TrustScoreConfig.getLevelName(75), 'Trusted');
      expect(TrustScoreConfig.getLevelName(89), 'Trusted');
    });

    test('90+ = Verified', () {
      expect(TrustScoreConfig.getLevelName(90), 'Verified');
      expect(TrustScoreConfig.getLevelName(100), 'Verified');
    });
  });
}
