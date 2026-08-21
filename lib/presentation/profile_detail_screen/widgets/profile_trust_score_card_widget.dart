import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import 'package:banjarabio/core/app_export.dart';
import 'package:banjarabio/widgets/tactile/tactile_pressable.dart';

/// 🛡️ World-Class Luxury Dynamic Trust Score Card
/// Redesigned with tier milestone progress tracking, glowing emblems,
/// dynamic credibility insights, and tactile micro-animations.
class ProfileTrustScoreCardWidget extends StatefulWidget {
  final Map<String, dynamic> profileData;
  final EdgeInsets? margin;
  final VoidCallback? onTap;

  const ProfileTrustScoreCardWidget({
    super.key,
    required this.profileData,
    this.margin,
    this.onTap,
  });

  @override
  State<ProfileTrustScoreCardWidget> createState() =>
      _ProfileTrustScoreCardWidgetState();
}

class _ProfileTrustScoreCardWidgetState
    extends State<ProfileTrustScoreCardWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  late Animation<double> _progressAnim;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    _progressAnim = CurvedAnimation(
      parent: _animController,
      curve: Curves.easeOutCubic,
    );
    _animController.forward();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    // Resolve live trust score
    final rawScore = widget.profileData['trustScore'];
    final isVerified = widget.profileData['isVerified'] == true ||
        widget.profileData['verificationStatus']?.toString().toLowerCase() ==
            'verified';
    final int liveTrustScore = rawScore != null
        ? (int.tryParse(rawScore.toString()) ?? (isVerified ? 75 : 65))
        : (isVerified ? 75 : 65);

    // Dynamic Tier Matrix & Next Milestone Details
    final _TrustTierSpec tierSpec;
    if (liveTrustScore >= 90) {
      tierSpec = _TrustTierSpec(
        tierName: 'PLATINUM VERIFIED',
        tierHindi: 'प्लैटिनम प्रोफाइल',
        icon: Icons.verified_user_rounded,
        primaryColor: AppColors.materialPurple, // Royal Amethyst
        accentColor: AppColors.purple300,
        darkTextColor:
            isDark ? AppColors.purple50 : AppColors.materialPurpleDark,
        subtitleColor:
            isDark ? AppColors.lavender : AppColors.materialPurpleDark,
        gradientColors: isDark
            ? const [AppColors.canvasRichDark, AppColors.canvasMidnight, AppColors.surfaceDarkBluePurple]
            : const [AppColors.violetBgSoft, AppColors.purple50, AppColors.purple50],
        borderColor: AppColors.purple300.withValues(alpha: AppColors.opacity50),
        glowColor: AppColors.materialPurple.withValues(alpha: AppColors.opacity15),
        nextMilestoneText: '🌟 Highest Trust Tier Reached • Maximum Match Views',
        ctaText: 'VIEW BADGE',
        targetScore: 100,
        progressFraction: (liveTrustScore / 100).clamp(0.0, 1.0),
      );
    } else if (liveTrustScore >= 70) {
      final pointsNeeded = 90 - liveTrustScore;
      tierSpec = _TrustTierSpec(
        tierName: 'GOLD TRUSTED',
        tierHindi: 'गोल्ड प्रोफाइल',
        icon: Icons.verified_user_rounded,
        primaryColor: AppColors.success, // Emerald Green
        accentColor: AppColors.successDark,
        darkTextColor:
            isDark ? AppColors.greenLightBg : AppColors.success,
        subtitleColor:
            isDark ? AppColors.green200 : AppColors.success,
        gradientColors: isDark
            ? const [AppColors.darkForest1, AppColors.darkForest2, AppColors.greenDeepForest]
            : const [AppColors.mintGreenBg, AppColors.greenLightBg, AppColors.sageGreenBorder],
        borderColor: AppColors.successDark.withValues(alpha: AppColors.opacity50),
        glowColor: AppColors.success.withValues(alpha: AppColors.opacity15),
        nextMilestoneText:
            '🏆 Add Community Vouch ($pointsNeeded% more) to reach Platinum',
        ctaText: 'REACH PLATINUM',
        targetScore: 90,
        progressFraction: (liveTrustScore / 100).clamp(0.0, 1.0),
      );
    } else if (liveTrustScore >= 40) {
      final pointsNeeded = 70 - liveTrustScore;
      tierSpec = _TrustTierSpec(
        tierName: 'SILVER PROFILE',
        tierHindi: 'सिल्वर प्रोफाइल',
        icon: Icons.shield_rounded,
        primaryColor: AppColors.categoryAstroDark, // Warm Amber Gold
        accentColor: AppColors.categoryAstro,
        darkTextColor:
            isDark ? AppColors.goldTint100 : AppColors.amberDeepText,
        subtitleColor:
            isDark ? AppColors.goldTint200 : AppColors.amberDarkestText,
        gradientColors: isDark
            ? const [AppColors.bloodRedBg, AppColors.amberBgDark, AppColors.amberBrownBg]
            : const [AppColors.goldLight, AppColors.warningLight, AppColors.orangePeachBg],
        borderColor: AppColors.categoryAstro.withValues(alpha: 0.55),
        glowColor: AppColors.categoryAstroDark.withValues(alpha: 0.18),
        nextMilestoneText:
            '🚀 Add Government ID ($pointsNeeded% more) to reach Gold 🥇',
        ctaText: 'REACH GOLD ➔',
        targetScore: 70,
        progressFraction: (liveTrustScore / 100).clamp(0.0, 1.0),
      );
    } else {
      final pointsNeeded = 40 - liveTrustScore;
      tierSpec = _TrustTierSpec(
        tierName: isVerified ? 'BASIC VERIFIED' : 'VERIFICATION PENDING',
        tierHindi: isVerified ? 'सत्यापित' : 'सत्यापन बाकी है',
        icon: isVerified
            ? Icons.verified_user_rounded
            : Icons.gpp_maybe_rounded,
        primaryColor:
            isVerified ? AppColors.success : AppColors.deepOrange,
        accentColor:
            isVerified ? AppColors.successDark : AppColors.deepOrange400,
        darkTextColor: isDark
            ? (isVerified
                ? AppColors.greenLightBg
                : AppColors.warningLight)
            : (isVerified
                ? AppColors.success
                : AppColors.amberDark),
        subtitleColor: isDark
            ? (isVerified
                ? AppColors.green200
                : AppColors.warningDark)
            : (isVerified
                ? AppColors.success
                : AppColors.deepOrange),
        gradientColors: isDark
            ? (isVerified
                ? const [AppColors.darkForest1, AppColors.darkForest2, AppColors.greenDeepForest]
                : const [AppColors.bloodRedBg, AppColors.amberBgDark, AppColors.bloodRedBg])
            : (isVerified
                ? const [AppColors.mintGreenBg, AppColors.greenLightBg, AppColors.sageGreenBorder]
                : const [AppColors.roseBlush, AppColors.warningLight, AppColors.warningLight]),
        borderColor: isVerified
            ? AppColors.successDark.withValues(alpha: AppColors.opacity50)
            : AppColors.deepOrange400.withValues(alpha: AppColors.opacity50),
        glowColor: (isVerified
                ? AppColors.success
                : AppColors.deepOrange)
            .withValues(alpha: AppColors.opacity15),
        nextMilestoneText: isVerified
            ? '⚡ Add community details ($pointsNeeded% more) to reach Silver'
            : '⚠️ Upload ID to boost trust and attract 3x more interest',
        ctaText: 'VERIFY NOW ➔',
        targetScore: 40,
        progressFraction: (liveTrustScore / 100).clamp(0.0, 1.0),
      );
    }

    return TactilePressable(
      onTap: widget.onTap ??
          () {
            Navigator.pushNamed(context, AppRoutes.trustScore);
          },
      pressedScale: 0.965,
      child: Container(
        width: double.infinity,
        margin: widget.margin ??
            EdgeInsets.symmetric(horizontal: 4.w, vertical: 0.9.h),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: tierSpec.gradientColors,
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: tierSpec.borderColor,
            width: 1.2,
          ),
          boxShadow: [
            BoxShadow(
              color: tierSpec.glowColor,
              blurRadius: 16,
              offset: const Offset(0, 5),
            ),
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 4,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // 🌟 1. Top Section: Glowing Emblem, Tier Title, and Hero Percentage Capsule
            Padding(
              padding: EdgeInsets.only(
                  left: 3.8.w, right: 3.8.w, top: 1.6.h, bottom: 1.2.h),
              child: Row(
                children: [
                  // Glowing Circular Shield Icon with Ambient Ring
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: tierSpec.primaryColor
                          .withValues(alpha: isDark ? 0.25 : 0.14),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: tierSpec.accentColor.withValues(alpha: AppColors.opacity50),
                        width: 1.2,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: tierSpec.primaryColor
                              .withValues(alpha: isDark ? 0.35 : 0.2),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Center(
                      child: Icon(
                        tierSpec.icon,
                        color: tierSpec.primaryColor,
                        size: 22,
                      ),
                    ),
                  ),
                  SizedBox(width: 3.2.w),

                  // Tier Title & Eyebrow Badge
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          padding: EdgeInsets.symmetric(
                              horizontal: 2.w, vertical: 0.25.h),
                          decoration: BoxDecoration(
                            color: tierSpec.primaryColor
                                .withValues(alpha: isDark ? 0.28 : 0.15),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            'TRUST LEVEL',
                            style: TextStyle(
                               fontFamily: AppTypography.bodyFontFamily,
                               color: tierSpec.darkTextColor,
                               fontWeight: AppTypography.black,
                               fontSize: AppTypography.labelTiny,
                               letterSpacing: 0.5,
                             ),
                          ),
                        ),
                        Wrap(
                          crossAxisAlignment: WrapCrossAlignment.center,
                          spacing: 1.2.w,
                          children: [
                            Text(
                              tierSpec.tierName,
                              style: TextStyle(
                                 fontFamily: AppTypography.bodyFontFamily,
                                 color: tierSpec.darkTextColor,
                                 fontWeight: AppTypography.black,
                                 height: 1.15,
                                 letterSpacing: -0.2,
                               ),
                            ),
                            Text(
                              '(${tierSpec.tierHindi})',
                              style: TextStyle(
                                 fontFamily: AppTypography.bodyFontFamily,
                                 fontWeight: AppTypography.bold,
                                 color: tierSpec.subtitleColor,
                                 fontSize: AppTypography.labelSmall,
                               ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  // 💎 Hero Percentage Capsule Badge
                  Container(
                    padding: EdgeInsets.symmetric(
                        horizontal: 3.2.w, vertical: 0.7.h),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          tierSpec.primaryColor,
                          tierSpec.accentColor,
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(22),
                      boxShadow: [
                        BoxShadow(
                          color: tierSpec.primaryColor
                              .withValues(alpha: isDark ? 0.45 : 0.3),
                          blurRadius: 10,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          '$liveTrustScore%',
                          style: const TextStyle(
                             fontFamily: AppTypography.bodyFontFamily,
                             color: Colors.white,
                             fontWeight: AppTypography.black,
                             letterSpacing: -0.3,
                           ),
                        ),
                        const Icon(
                          Icons.arrow_forward_ios_rounded,
                          size: 10,
                          color: Colors.white,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // 📊 2. Milestone Progress Bar with Animated Track
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 3.8.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AnimatedBuilder(
                    animation: _progressAnim,
                    builder: (context, child) {
                      final currentProgress =
                          tierSpec.progressFraction * _progressAnim.value;
                      return Stack(
                        children: [
                          // Background Track
                          Container(
                            height: 7,
                            width: double.infinity,
                            decoration: BoxDecoration(
                              color: tierSpec.primaryColor
                                  .withValues(alpha: isDark ? 0.2 : 0.12),
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          // Filled Animated Gradient Progress
                          FractionallySizedBox(
                            widthFactor: currentProgress,
                            child: Container(
                              height: 7,
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    tierSpec.accentColor,
                                    tierSpec.primaryColor,
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(8),
                                boxShadow: [
                                  BoxShadow(
                                    color: tierSpec.primaryColor
                                        .withValues(alpha: 0.45),
                                    blurRadius: 6,
                                    offset: const Offset(0, 1),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                  SizedBox(height: 0.6.h),

                  // Tier Range Legend Marks (Bronze -> Silver -> Gold -> Platinum)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildTierStepLabel('Bronze 0%', 0 <= liveTrustScore,
                          tierSpec.subtitleColor),
                      _buildTierStepLabel('Silver 40%', 40 <= liveTrustScore,
                          tierSpec.subtitleColor),
                      _buildTierStepLabel('Gold 70%', 70 <= liveTrustScore,
                          tierSpec.subtitleColor),
                      _buildTierStepLabel('Platinum 90%+',
                          90 <= liveTrustScore, tierSpec.subtitleColor),
                    ],
                  ),
                ],
              ),
            ),
            SizedBox(height: 1.2.h),

            // 💡 3. Bottom Translucent Insight & Action Strip
            Container(
              width: double.infinity,
              padding:
                  EdgeInsets.symmetric(horizontal: 3.8.w, vertical: 1.1.h),
              decoration: BoxDecoration(
                color: tierSpec.primaryColor
                    .withValues(alpha: isDark ? 0.16 : 0.08),
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(19),
                  bottomRight: Radius.circular(19),
                ),
                border: Border(
                  top: BorderSide(
                    color: tierSpec.borderColor.withValues(alpha: AppColors.opacity35),
                    width: 0.8,
                  ),
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      tierSpec.nextMilestoneText,
                      style: TextStyle(
                         fontFamily: AppTypography.bodyFontFamily,
                         fontWeight: AppTypography.bold,
                         color: tierSpec.darkTextColor,
                         fontSize: AppTypography.labelSmall,
                         height: 1.2,
                       ),
                      softWrap: true,
                    ),
                  ),

                  // Action Button Pill
                  Container(
                    padding: EdgeInsets.symmetric(
                        horizontal: 2.5.w, vertical: 0.4.h),
                    decoration: BoxDecoration(
                      color: tierSpec.primaryColor,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      tierSpec.ctaText,
                      style: TextStyle(
                         fontFamily: AppTypography.bodyFontFamily,
                         color: Colors.white,
                         fontWeight: AppTypography.black,
                         fontSize: AppTypography.labelTiny,
                         letterSpacing: 0.2,
                       ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTierStepLabel(String label, bool isReached, Color color) {
    return Text(
      label,
      style: TextStyle(
        fontFamily: AppTypography.bodyFontFamily,
        color: isReached ? color : color.withValues(alpha: 0.45),
        fontWeight: isReached ? AppTypography.black : AppTypography.medium,
        fontSize: AppTypography.labelTiny,
        letterSpacing: 0.1,
      ),
    );
  }
}

/// 📐 Complete Visual Specification for Dynamic Trust Tiers
class _TrustTierSpec {
  final String tierName;
  final String tierHindi;
  final IconData icon;
  final Color primaryColor;
  final Color accentColor;
  final Color darkTextColor;
  final Color subtitleColor;
  final List<Color> gradientColors;
  final Color borderColor;
  final Color glowColor;
  final String nextMilestoneText;
  final String ctaText;
  final int targetScore;
  final double progressFraction;

  const _TrustTierSpec({
    required this.tierName,
    required this.tierHindi,
    required this.icon,
    required this.primaryColor,
    required this.accentColor,
    required this.darkTextColor,
    required this.subtitleColor,
    required this.gradientColors,
    required this.borderColor,
    required this.glowColor,
    required this.nextMilestoneText,
    required this.ctaText,
    required this.targetScore,
    required this.progressFraction,
  });
}
