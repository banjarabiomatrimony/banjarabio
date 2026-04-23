import 'package:flutter_test/flutter_test.dart';
import 'package:banjarabio/core/models/trust_score_config.dart';

void main() {
  group('TrustScoreConfig Tests', () {
    test('calculateScore should return total points for all verified items', () {
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
      
      // 10 + 10 + 10 + 15 + 15 + 10 + 10 + 20 = 100
      expect(score, 100);
    });

    test('calculateScore should clamp to 100', () {
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

    test('calculateScore should handle partially verified profile', () {
      final score = TrustScoreConfig.calculateScore(
        hasMobile: true,
        hasEmail: true,
        isProfileComplete: true,
      );
      // 10 + 10 + 20 = 40
      expect(score, 40);
    });

    test('getDiscountPercentage should return correct tiers', () {
      expect(TrustScoreConfig.getDiscountPercentage(0), 0);
      expect(TrustScoreConfig.getDiscountPercentage(35), 5);  // Level 1: >= 30
      expect(TrustScoreConfig.getDiscountPercentage(55), 10); // Level 2: >= 50
      expect(TrustScoreConfig.getDiscountPercentage(80), 20); // Level 3: >= 75
      expect(TrustScoreConfig.getDiscountPercentage(95), 30); // Level 4: >= 90
    });

    test('getLevelName should return correct badge labels', () {
      expect(TrustScoreConfig.getLevelName(20), null);
      expect(TrustScoreConfig.getLevelName(55), 'Standard');
      expect(TrustScoreConfig.getLevelName(80), 'Trusted');
      expect(TrustScoreConfig.getLevelName(95), 'Verified');
    });

    test('getDiscountedPrice should calculate math correctly', () {
      // 1000 INR, 90 score -> 30% discount -> 700 INR
      final price = TrustScoreConfig.getDiscountedPrice(1000, 95);
      expect(price, 700);
    });
  });
}
