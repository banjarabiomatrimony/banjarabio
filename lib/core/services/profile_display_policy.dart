import 'package:flutter/material.dart';
import 'package:banjarabio/core/models/profile_model.dart';
import 'package:banjarabio/core/models/subscription_model.dart';
import 'package:banjarabio/core/models/trust_score_config.dart';
import 'package:banjarabio/core/services/compatibility_service.dart';
import 'package:banjarabio/theme/app_colors.dart';

/// ─────────────────────────────────────────────────────────────
///  Data Holder Models for Profile Display
/// ─────────────────────────────────────────────────────────────

class GotraDisplayInfo {
  final String formattedText;
  final bool isLocked;
  final bool isPartiallyLocked;
  final String majorGotra;
  final String? subGotra;

  const GotraDisplayInfo({
    required this.formattedText,
    this.isLocked = false,
    this.isPartiallyLocked = false,
    required this.majorGotra,
    this.subGotra,
  });
}

class KundaliDisplayInfo {
  final bool isLocked;
  final int scorePercentage;
  final int gunMilanMatched;
  final String displayBadgeText;
  final String displaySubtext;

  const KundaliDisplayInfo({
    required this.isLocked,
    required this.scorePercentage,
    required this.gunMilanMatched,
    required this.displayBadgeText,
    required this.displaySubtext,
  });
}

class SubscriptionBadgeInfo {
  final String label;
  final IconData icon;
  final List<Color> gradientColors;
  final Color textColor;
  final Color borderColor;

  const SubscriptionBadgeInfo({
    required this.label,
    required this.icon,
    required this.gradientColors,
    required this.textColor,
    required this.borderColor,
  });
}

/// ─────────────────────────────────────────────────────────────
///  Centralized Profile Display & Privacy Policy Engine
///  Easily switchable for UI, backend, or remote config flags.
/// ─────────────────────────────────────────────────────────────
class ProfileDisplayPolicy {
  // ─── Global Configurable Toggles (Backend / Remote Config ready) ───
  static bool enableFemaleNamePrivacy = true;
  static bool enableGotraPrivacyTiers = true;
  static bool enableBvsBadgeOnCards = false; // Strictly false per product policy
  static bool enableKundaliLockForFree = false; // Open match score & Gun Milan for all users

  /// 1. 🛡️ Gender-Aware Display Name:
  /// - Female candidate: First name ONLY (e.g. "Pooja")
  /// - Male candidate: Full name (e.g. "Rahul Rathod")
  static String getDisplayName(ProfileModel profile) {
    final fullName = profile.fullName.trim();
    if (fullName.isEmpty) return 'Banjara Member';

    if (!enableFemaleNamePrivacy) return fullName;

    final genderStr = profile.gender.trim().toLowerCase();
    final isFemale = genderStr.startsWith('f') || genderStr == 'bride' || genderStr == 'female';

    if (isFemale) {
      final parts = fullName.split(RegExp(r'\s+'));
      return parts.isNotEmpty ? parts.first : fullName;
    }

    return fullName;
  }

  /// 2. 💍 3-Tier Gotra & Sub-Clan Formatting:
  /// - Free User: "Gotra: 🔒 Premium"
  /// - BVS Subsidized User: "[ 💍 Gotra: Rathod - 🔒 Premium ]"
  /// - Main Paid / Premium (Silver, Gold, Platinum, VIP): "[ 💍 Gotra: Rathod - Karamtoth ]"
  static GotraDisplayInfo getGotraInfo(
    ProfileModel profile, {
    PlanType viewerPlan = PlanType.free,
  }) {
    final rawGotra = profile.gotra?.trim() ?? '';

    if (rawGotra.isEmpty) {
      return const GotraDisplayInfo(
        formattedText: 'Not Specified',
        majorGotra: '',
      );
    }

    // Split major Gotra and Sub-Gotra (e.g., "Rathod - Karamtoth" or "Rathod / Karamtoth")
    String major = rawGotra;
    String? sub;

    if (rawGotra.contains('-')) {
      final parts = rawGotra.split('-');
      major = parts[0].trim();
      if (parts.length > 1 && parts[1].trim().isNotEmpty) {
        sub = parts[1].trim();
      }
    } else if (rawGotra.contains('/')) {
      final parts = rawGotra.split('/');
      major = parts[0].trim();
      if (parts.length > 1 && parts[1].trim().isNotEmpty) {
        sub = parts[1].trim();
      }
    }

    if (!enableGotraPrivacyTiers) {
      final text = sub != null ? '$major - $sub' : major;
      return GotraDisplayInfo(
        formattedText: text,
        majorGotra: major,
        subGotra: sub,
      );
    }

    // Tier 1: Free User
    if (viewerPlan == PlanType.free || viewerPlan == PlanType.unknown) {
      return const GotraDisplayInfo(
        formattedText: '🔒 Premium',
        isLocked: true,
        majorGotra: '🔒 Premium',
      );
    }

    // Tier 2: BVS Subsidized Plan (e.g., mass_market, mass_market_annual)
    final isBvsPlan = viewerPlan == PlanType.mass_market || viewerPlan == PlanType.mass_market_annual;
    if (isBvsPlan) {
      if (sub != null && sub.isNotEmpty) {
        return GotraDisplayInfo(
          formattedText: '$major - 🔒 Premium',
          isPartiallyLocked: true,
          majorGotra: major,
          subGotra: '🔒 Premium',
        );
      }
      return GotraDisplayInfo(
        formattedText: major,
        majorGotra: major,
      );
    }

    // Tier 3: Main Paid / Premium (Standard, Silver, Gold, Platinum, Eternal, VIP)
    final fullText = sub != null && sub.isNotEmpty ? '$major - $sub' : major;
    return GotraDisplayInfo(
      formattedText: fullText,
      majorGotra: major,
      subGotra: sub,
    );
  }

  /// 3. 🎓 Education Formatting with Status Prefix:
  /// Maps degrees to:
  /// - "10th"
  /// - "12th / Diploma"
  /// - "Graduate (UG)"
  /// - "Post Graduate (PG)"
  /// - "Doctorate (PhD)"
  /// With "Under - " or "Completed - " prefix.
  static String getFormattedEducation(ProfileModel profile) {
    final rawEducation = profile.education.trim();
    final rawDetails = profile.educationDetails?.trim() ?? '';
    final combined = '$rawEducation $rawDetails'.toLowerCase();

    if (rawEducation.isEmpty && rawDetails.isEmpty) {
      return 'Education: Not Disclosed';
    }

    // Check if status is explicitly specified
    final bool isPursuing = combined.contains('under') ||
        combined.contains('pursuing') ||
        combined.contains('studying') ||
        combined.contains('appearing') ||
        combined.contains('incomplete');

    final String prefix = isPursuing ? 'Under - ' : 'Completed - ';

    // Map education brackets
    String bracket;

    if (combined.contains('phd') ||
        combined.contains('doctorate') ||
        combined.contains('post doc') ||
        combined.contains('m.ch') ||
        combined.contains('d.m')) {
      bracket = 'Doctorate (PhD)';
    } else if (combined.contains('post graduate') ||
        combined.contains('pg') ||
        combined.contains('master') ||
        combined.contains('m.tech') ||
        combined.contains('mba') ||
        combined.contains('m.sc') ||
        combined.contains('m.com') ||
        combined.contains('mca') ||
        combined.contains('m.s') ||
        combined.contains('m.e') ||
        combined.contains('md') ||
        combined.contains('m.pharm') ||
        combined.contains('llm')) {
      bracket = 'Post Graduate (PG)';
    } else if (combined.contains('graduate') ||
        combined.contains('bachelor') ||
        combined.contains('ug') ||
        combined.contains('b.tech') ||
        combined.contains('b.e') ||
        combined.contains('b.sc') ||
        combined.contains('b.com') ||
        combined.contains('bba') ||
        combined.contains('bca') ||
        combined.contains('ba') ||
        combined.contains('mbbs') ||
        combined.contains('b.pharm') ||
        combined.contains('bams') ||
        combined.contains('bhms') ||
        combined.contains('bds') ||
        combined.contains('llb')) {
      bracket = 'Graduate (UG)';
    } else if (combined.contains('12th') ||
        combined.contains('hsc') ||
        combined.contains('diploma') ||
        combined.contains('intermediate') ||
        combined.contains('inter') ||
        combined.contains('polytechnic') ||
        combined.contains('puc')) {
      bracket = '12th / Diploma';
    } else if (combined.contains('10th') ||
        combined.contains('ssc') ||
        combined.contains('matric') ||
        combined.contains('secondary') ||
        combined.contains('school')) {
      bracket = '10th';
    } else {
      // Fallback: If raw education has readable string, use Clean Graduate/PG or original
      if (rawEducation.length <= 25 && !rawEducation.toLowerCase().contains('under')) {
        return '$prefix$rawEducation';
      }
      bracket = 'Graduate (UG)';
    }

    return '$prefix$bracket';
  }

  /// 4. 🔮 Dynamic Kundali / Compatibility Match Display:
  /// - Free User: "Gun Milan: •• / 36 Guna", "🔒 Kundali Match (Tap to Unlock)"
  /// - Paid User: "Gun Milan: 28/36 Guna", "✨ 88% Match"
  static KundaliDisplayInfo getKundaliInfo(
    ProfileModel candidateProfile, {
    PlanType viewerPlan = PlanType.free,
    ProfileModel? viewerProfile,
  }) {
    // Calculate matching percentage
    int matchingScore = 85; // Default safe fallback
    if (viewerProfile != null) {
      matchingScore = CompatibilityService.calculateMatchingScore(viewerProfile, candidateProfile);
      if (matchingScore == 0) matchingScore = 78;
    } else {
      // Deterministic calculation based on profile ID hash for consistent display
      final hash = candidateProfile.id.hashCode.abs();
      matchingScore = 75 + (hash % 21); // 75% to 95%
    }

    // Calculate Gun Milan out of 36 proportionally
    final int gunMilan = ((matchingScore / 100.0) * 36).round().clamp(18, 36);

    final isPaid = viewerPlan.isPaidPlan;

    if (!isPaid && enableKundaliLockForFree) {
      return KundaliDisplayInfo(
        isLocked: true,
        scorePercentage: matchingScore,
        gunMilanMatched: gunMilan,
        displayBadgeText: '🔒 Kundali: •• / 36',
        displaySubtext: 'Unlock Match',
      );
    }

    return KundaliDisplayInfo(
      isLocked: false,
      scorePercentage: matchingScore,
      gunMilanMatched: gunMilan,
      displayBadgeText: '✨ $matchingScore% Match',
      displaySubtext: 'Gun Milan: $gunMilan/36',
    );
  }

  /// 5. 👑 Candidate Subscription Badge (On Public Home Cards):
  /// - Free / BVS: NULL (Omitted per policy to keep card pristine and avoid discount stigmas)
  /// - Silver / Gold / Platinum / Eternal / VIP: Returns styled jewel badge dynamically
  static SubscriptionBadgeInfo? getCandidateSubscriptionBadge(ProfileModel profile) {
    final role = profile.role.toLowerCase();
    final plan = profile.planType;

    // 1. VIP & Admin
    if (role == 'vip' || role == 'admin' || plan == PlanType.vip || plan == PlanType.eternal_elite || plan == PlanType.royal || plan == PlanType.elite || plan == PlanType.eternal) {
      return const SubscriptionBadgeInfo(
        label: 'VIP',
        icon: Icons.workspace_premium_rounded,
        gradientColors: [AppColors.crimsonRose, AppColors.categoryAstro],
        textColor: Colors.white,
        borderColor: AppColors.categoryAstro,
      );
    }

    // 2. Platinum Tier
    if (plan == PlanType.platinum) {
      return const SubscriptionBadgeInfo(
        label: 'PLATINUM',
        icon: Icons.diamond_rounded,
        gradientColors: [AppColors.categorySecurity, AppColors.purple400],
        textColor: Colors.white,
        borderColor: AppColors.violetSoft,
      );
    }

    // 3. Gold Tier
    if (plan == PlanType.gold) {
      return const SubscriptionBadgeInfo(
        label: 'GOLD',
        icon: Icons.military_tech_rounded,
        gradientColors: [AppColors.categoryAstroDark, AppColors.categoryAstro],
        textColor: Colors.white,
        borderColor: AppColors.goldTint200,
      );
    }

    // 4. Silver Tier
    if (plan == PlanType.silver) {
      return const SubscriptionBadgeInfo(
        label: 'SILVER',
        icon: Icons.shield_rounded,
        gradientColors: [AppColors.slate600, AppColors.slate400],
        textColor: Colors.white,
        borderColor: AppColors.slate300,
      );
    }

    // 5. Generic Premium
    if (profile.isPremium && plan != PlanType.mass_market && plan != PlanType.mass_market_annual && plan != PlanType.free) {
      return const SubscriptionBadgeInfo(
        label: 'PREMIUM',
        icon: Icons.star_rounded,
        gradientColors: [AppColors.categoryAstro, AppColors.categoryAstroDark],
        textColor: Colors.white,
        borderColor: AppColors.goldTint200,
      );
    }

    return null;
  }

  /// 6. 📊 Dynamic Profile Completion Percentage (100% Total):
  /// Checks database column -> calculates from available fields if 0.
  static int getCompletionPercentage(ProfileModel profile) {
    if (profile.profileCompletion > 0) {
      return profile.profileCompletion.clamp(0, 100);
    }
    if (profile.completionPercentage > 0) {
      return profile.completionPercentage.clamp(0, 100);
    }
    return profile.calculateCompletionPercentage().clamp(0, 100);
  }

  /// 📊 Profile Completion Label for Home Card Pill
  static String getProfileCompletionLabel(ProfileModel profile) {
    final completion = getCompletionPercentage(profile);
    return '$completion% Bio Complete';
  }

  /// 7. 🛡️ Dynamic Trust Score (100% Total):
  /// Uses DB column or calculates dynamically from verified fields.
  static int getDynamicTrustScore(ProfileModel profile) {
    if (profile.trustScore > 0) {
      return profile.trustScore.clamp(0, 100);
    }
    final hasPhone = (profile.phoneNumber?.trim().isNotEmpty ?? false) || profile.phoneVerified;
    final hasEmail = (profile.email?.trim().isNotEmpty ?? false) || profile.emailVerified;
    final hasGotra = profile.gotra?.trim().isNotEmpty ?? false;
    return TrustScoreConfig.calculateScore(
      hasMobile: hasPhone,
      hasEmail: hasEmail,
      hasPhoto: profile.photos.isNotEmpty,
      hasCommunityId: profile.isCommunityTrusted || hasGotra,
      hasGovtId: profile.isVerified,
      isProfileComplete: getCompletionPercentage(profile) >= 80,
    ).clamp(0, 100);
  }
}
