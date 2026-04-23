import 'package:flutter/material.dart';

/// Trust Score Configuration
@immutable
class TrustScoreConfig {
  // Max Score
  static const int maxScore = 100;

  // Points for each verification step
  static const int pointsMobile = 10;
  static const int pointsEmail = 10;
  static const int pointsPhoto = 10; // Adjusted for balance
  static const int pointsCommunityId = 15;
  static const int pointsGovtId = 15; // Adjusted for balance
  static const int pointsReference = 10;
  static const int pointsVideoBio = 10;
  static const int pointsProfileCompletion = 20; // Increased to 20

  // Discount Tiers
  static const int level1Threshold = 30; // Basic
  static const int level2Threshold = 50; // Standard
  static const int level3Threshold = 75; // Trusted
  static const int level4Threshold = 90; // Verified

  static const int discountLevel0 = 0;
  static const int discountLevel1 = 5;
  static const int discountLevel2 = 10;
  static const int discountLevel3 = 20;
  static const int discountLevel4 = 30;

  /// Calculate Trust Score based on user data
  /// [hasMobile]: Mobile number verified
  /// [hasEmail]: Email verified
  /// [hasPhoto]: Profile photo verified (face scan)
  /// [hasCommunityId]: Community ID provided/verified
  /// [hasGovtId]: Govt ID (Aadhaar/PAN) verified
  /// [hasReference]: Two references added
  /// [hasVideoBio]: Video bio uploaded
  static int calculateScore({
    bool hasMobile = false,
    bool hasEmail = false,
    bool hasPhoto = false,
    bool hasCommunityId = false,
    bool hasGovtId = false,
    bool hasReference = false,
    bool hasVideoBio = false,
    bool isProfileComplete = false,
  }) {
    int score = 0;
    if (hasMobile) score += pointsMobile;
    if (hasEmail) score += pointsEmail;
    if (hasPhoto) score += pointsPhoto;
    if (hasCommunityId) score += pointsCommunityId;
    if (hasGovtId) score += pointsGovtId;
    if (hasReference) score += pointsReference;
    if (hasVideoBio) score += pointsVideoBio;
    if (isProfileComplete) score += pointsProfileCompletion;
    return score.clamp(0, maxScore);
  }

  /// Get Discount Percentage based on score
  static int getDiscountPercentage(int score) {
    if (score >= level4Threshold) return discountLevel4;
    if (score >= level3Threshold) return discountLevel3;
    if (score >= level2Threshold) return discountLevel2;
    if (score >= level1Threshold) return discountLevel1;
    return discountLevel0;
  }

  /// Get Final Price after discount
  static int getDiscountedPrice(int originalPrice, int score) {
    final discountPercent = getDiscountPercentage(score);
    final discountAmount = (originalPrice * discountPercent) / 100;
    return (originalPrice - discountAmount).round();
  }

  /// Get Trust Level Name (Standard, Trusted, Verified)
  /// Returns null if score is below Standard level
  static String? getLevelName(int score) {
    if (score >= level4Threshold) return 'Verified';
    if (score >= level3Threshold) return 'Trusted';
    if (score >= level2Threshold) return 'Standard';
    return null; // No badge for Basic or Ghost
  }

  /// Get Trust Level Color
  static Color getLevelColor(int score) {
    if (score >= level4Threshold) return Colors.amber; // Gold
    if (score >= level3Threshold) return Colors.blue;
    if (score >= level2Threshold) return Colors.green;
    return Colors.grey; // Default color
  }
}
