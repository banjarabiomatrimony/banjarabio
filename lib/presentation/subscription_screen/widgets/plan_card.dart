import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import 'package:banjarabio/core/constants/app_typography.dart';
import 'package:banjarabio/core/models/subscription_config.dart';
import 'package:banjarabio/core/models/subscription_model.dart';
import 'package:banjarabio/core/models/coupon_model.dart';
import 'package:banjarabio/l10n/app_localizations.dart';
import 'package:banjarabio/presentation/subscription_screen/widgets/feature_comparison_sheet.dart';
import 'package:banjarabio/widgets/tactile/tactile_pressable.dart';
import 'package:banjarabio/theme/app_colors.dart';

/// Highly attractive, easy-to-understand, state-of-the-art PlanCard.
/// Features distinct jewel gradients, clear pricing scannability,
/// highlighted superpower chips, and rotating sweep animations.
class PlanCard extends StatelessWidget {
  final PlanType planType;
  final PlanFeatures features;
  final bool isCurrentPlan;
  final bool isSufficientPlan;
  final bool isProcessingPayment;
  final int trustScore;
  final CouponModel? appliedCoupon;
  final VoidCallback onUpgrade;
  final Animation<double> shimmerAnimation;

  const PlanCard({
    super.key,
    required this.planType,
    required this.features,
    required this.isCurrentPlan,
    required this.isSufficientPlan,
    required this.isProcessingPayment,
    required this.trustScore,
    required this.appliedCoupon,
    required this.onUpgrade,
    required this.shimmerAnimation,
  });

  _TierTheme _getTierTheme(ThemeData theme, bool isDark) {
    switch (planType) {
      case PlanType.gold:
        return const _TierTheme(
          title: 'Gold Membership',
          iconEmoji: '🥇',
          iconData: Icons.workspace_premium_rounded,
          tagline: 'Most chosen by verified matches',
          durationLabel: '6 Months',
          ribbonLabel: '🔥 MOST POPULAR',
          primaryColor: AppColors.categoryAstroDark,
          secondaryColor: AppColors.amberDark,
          accentColor: AppColors.categoryAstro,
          lightBgGradient: [AppColors.warningLight, AppColors.goldTint100],
          darkBgGradient: [AppColors.amberBrownBg, AppColors.amberBrownBg],
          borderColors: [
            AppColors.categoryVip,
            AppColors.categoryVipDark,
            AppColors.categoryVip,
          ],
        );

      case PlanType.platinum:
        return const _TierTheme(
          title: 'Platinum Membership',
          iconEmoji: '💎',
          iconData: Icons.diamond_rounded,
          tagline: 'Best long-term value for serious seekers',
          durationLabel: '1 Year',
          ribbonLabel: '✨ BEST VALUE • 1 YEAR',
          primaryColor: AppColors.categoryFamilyDark,
          secondaryColor: AppColors.materialPurpleDark,
          accentColor: AppColors.categoryFamily,
          lightBgGradient: [AppColors.violetBgSoft, AppColors.violetBg],
          darkBgGradient: [AppColors.canvasRichDark, AppColors.canvasDeepDark],
          borderColors: [
            AppColors.materialPurple700,
            AppColors.categoryFamily,
            AppColors.materialPurple700,
          ],
        );

      case PlanType.eternal:
        return const _TierTheme(
          title: 'Eternal Lifetime',
          iconEmoji: '👑',
          iconData: Icons.all_inclusive_rounded,
          tagline: 'Pay once, enjoy till you find your match',
          durationLabel: 'Lifetime',
          ribbonLabel: '👑 TILL U MARRY • BEST VALUE',
          primaryColor: AppColors.sunsetOrange,
          secondaryColor: AppColors.deepOrange,
          accentColor: AppColors.warning,
          lightBgGradient: [AppColors.goldLight, AppColors.orangePeachBg],
          darkBgGradient: [AppColors.amberBgDark, AppColors.amberBrownBg],
          borderColors: [
            AppColors.amber600,
            AppColors.orangeDark900,
            AppColors.amber600,
          ],
        );

      case PlanType.silver:
        return const _TierTheme(
          title: 'Silver Membership',
          iconEmoji: '🥈',
          iconData: Icons.shield_outlined,
          tagline: 'Fast-track search with direct contacts',
          durationLabel: '3 Months',
          ribbonLabel: '⚡ STARTER PACK',
          primaryColor: AppColors.slate600,
          secondaryColor: AppColors.slate700,
          accentColor: AppColors.slate500,
          lightBgGradient: [AppColors.slate50, AppColors.slate100],
          darkBgGradient: [AppColors.slate800, AppColors.slate900],
          borderColors: [
            AppColors.slate400,
            AppColors.slate500,
            AppColors.slate400,
          ],
        );

      case PlanType.elite:
      case PlanType.royal:
      case PlanType.eternal_elite:
        return _TierTheme(
          title: 'VIP Concierge',
          iconEmoji: '💎',
          iconData: Icons.stars_rounded,
          tagline: 'Dedicated Matchmaker & Relationship Manager',
          durationLabel: features.isLifetime ? 'Lifetime' : '${features.duration} Mo',
          ribbonLabel: '💎 VIP CONCIERGE',
          primaryColor: AppColors.purpleElectric,
          secondaryColor: AppColors.violetDeep,
          accentColor: AppColors.purple400,
          lightBgGradient: const [AppColors.categoryFamilyBg, AppColors.violetBg],
          darkBgGradient: const [AppColors.canvasMidnight, AppColors.canvasCharcoal],
          borderColors: const [
            AppColors.purpleElectric,
            AppColors.categoryVip,
            AppColors.purpleElectric,
          ],
        );

      case PlanType.free:
      default:
        return _TierTheme(
          title: 'Starter Free Plan',
          iconEmoji: '🌱',
          iconData: Icons.eco_outlined,
          tagline: 'Standard browsing & profile creation',
          durationLabel: 'Forever',
          ribbonLabel: null,
          primaryColor: theme.colorScheme.primary,
          secondaryColor: theme.colorScheme.primary,
          accentColor: theme.colorScheme.primary,
          lightBgGradient: [theme.cardColor, theme.cardColor],
          darkBgGradient: [theme.cardColor, theme.cardColor],
          borderColors: const [],
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final tier = _getTierTheme(theme, isDark);

    final isRecommended = planType == PlanType.gold;
    final isBestValue = planType == PlanType.eternal;
    final isPlatinum = planType == PlanType.platinum;
    final isVip = tier.ribbonLabel?.contains('VIP') ?? false;
    final hasAnimatedBorder = isRecommended || isBestValue || isPlatinum || isVip;

    final discountedPrice = features.getDiscountedPrice(trustScore);
    final couponPercent = appliedCoupon?.discountPercentage ?? 0;
    final finalPrice = features.getFinalPrice(trustScore, couponPercent: couponPercent);
    final totalSavings = features.getTotalSavings(trustScore, couponPercent: couponPercent);

    Widget cardContent = Container(
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: hasAnimatedBorder
              ? Colors.transparent
              : isDark
                  ? Colors.white.withValues(alpha: AppColors.opacity8)
                  : Colors.black.withValues(alpha: 0.07),
        ),
        boxShadow: [
          BoxShadow(
            color: tier.primaryColor.withValues(alpha: isDark ? 0.2 : 0.06),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // ── 1. Top Ribbon & Header ──
          _buildHeader(context, theme, tier, isDark),

          // ── 2. Pricing & Savings Display Card ──
          _buildPricingSection(context, theme, tier, isDark, discountedPrice, finalPrice, totalSavings),

          // ── 3. Superpower Features Highlights ──
          _buildFeaturePillars(context, theme, tier, isDark),

          // ── 4. CTA Button ──
          _buildCTAButton(context, theme, tier, isDark),
        ],
      ),
    );

    if (hasAnimatedBorder) {
      cardContent = _buildAnimatedSweepBorder(tier, cardContent);
    }

    return cardContent;
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // 1. HEADER SECTION
  // ═══════════════════════════════════════════════════════════════════════════

  Widget _buildHeader(BuildContext context, ThemeData theme, _TierTheme tier, bool isDark) {
    return Container(
      padding: EdgeInsets.fromLTRB(4.w, 3.5.w, 4.w, 2.5.w),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isDark ? tier.darkBgGradient : tier.lightBgGradient,
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Ribbon Banner if available
          if (tier.ribbonLabel != null) ...[
            Row(
              children: [
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 2.8.w, vertical: 0.4.h),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [tier.primaryColor, tier.secondaryColor],
                    ),
                    borderRadius: BorderRadius.circular(8),
                    boxShadow: [
                      BoxShadow(
                        color: tier.primaryColor.withValues(alpha: AppColors.opacity35),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Text(
                    tier.ribbonLabel!,
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: AppTypography.bold,
                      fontSize: AppTypography.labelTiny,
                      letterSpacing: 0.4,
                    ),
                  ),
                ),
                const Spacer(),
                // Validity Pill
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 2.5.w, vertical: 0.35.h),
                  decoration: BoxDecoration(
                    color: tier.primaryColor.withValues(alpha: isDark ? 0.25 : 0.12),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: tier.primaryColor.withValues(alpha: AppColors.opacity35),
                    ),
                  ),
                  child: Text(
                    tier.durationLabel,
                    style: TextStyle(
                      color: isDark ? Colors.white : tier.primaryColor,
                      fontWeight: AppTypography.bold,
                      fontSize: AppTypography.labelSmall,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 1.2.h),
          ],

          // Title Row with Icon Emblem
          Row(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: tier.primaryColor.withValues(alpha: isDark ? 0.25 : 0.12),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: tier.primaryColor.withValues(alpha: AppColors.opacity40),
                    width: 1.2,
                  ),
                ),
                child: Center(
                  child: Text(
                    tier.iconEmoji,
                    style: TextStyle(fontSize: AppTypography.titleLarge),
                  ),
                ),
              ),
              SizedBox(width: 3.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      SubscriptionConfig.getDisplayName(planType, AppLocalizations.of(context)),
                      style: TextStyle(
                        fontSize: AppTypography.headingSmall,
                        fontWeight: AppTypography.bold,
                        letterSpacing: 0.1,
                        color: isDark ? Colors.white : theme.colorScheme.onSurface,
                      ),
                    ),
                    SizedBox(height: 0.2.h),
                    Text(
                      tier.tagline,
                      style: TextStyle(
                        fontSize: AppTypography.labelSmall,
                        color: theme.colorScheme.onSurfaceVariant.withValues(alpha: AppColors.opacity85),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              if (tier.ribbonLabel == null)
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 2.5.w, vertical: 0.35.h),
                  decoration: BoxDecoration(
                    color: tier.primaryColor.withValues(alpha: isDark ? 0.2 : 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    tier.durationLabel,
                    style: TextStyle(
                      color: tier.primaryColor,
                      fontWeight: AppTypography.bold,
                      fontSize: AppTypography.labelSmall,
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // 2. PRICING & SAVINGS SECTION
  // ═══════════════════════════════════════════════════════════════════════════

  Widget _buildPricingSection(
    BuildContext context,
    ThemeData theme,
    _TierTheme tier,
    bool isDark,
    int discountedPrice,
    int finalPrice,
    int totalSavings,
  ) {
    final durationMonths = features.duration;
    final isLifetime = features.isLifetime;
    final finalPricePerMonth = isLifetime ? 0 : (finalPrice / durationMonths).round();
    final mrpPerMonth = isLifetime ? 0 : (features.mrp / durationMonths).round();
    final hasSavings = totalSavings > 0;
    final discountPercent = hasSavings ? (totalSavings / features.mrp * 100).round() : 0;

    if (planType == PlanType.free) {
      return Padding(
        padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.5.h),
        child: Container(
          padding: EdgeInsets.all(3.w),
          decoration: BoxDecoration(
            color: isDark ? Colors.white.withValues(alpha: 0.04) : Colors.black.withValues(alpha: 0.02),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: isDark ? Colors.white12 : Colors.black12,
            ),
          ),
          child: Row(
            children: [
              Text(
                '₹0',
                style: TextStyle(
                  fontSize: AppTypography.headingLarge,
                  fontWeight: AppTypography.bold,
                  color: theme.colorScheme.primary,
                ),
              ),
              SizedBox(width: 2.w),
              Text(
                'Free standard access forever',
                style: TextStyle(
                  fontSize: AppTypography.bodySmall,
                  color: theme.colorScheme.onSurfaceVariant,
                  fontWeight: AppTypography.medium,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Padding(
      padding: EdgeInsets.fromLTRB(4.w, 1.2.h, 4.w, 0),
      child: Container(
        padding: EdgeInsets.all(3.5.w),
        decoration: BoxDecoration(
          color: isDark
              ? Colors.white.withValues(alpha: 0.04)
              : tier.primaryColor.withValues(alpha: 0.03),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: tier.primaryColor.withValues(alpha: isDark ? 0.25 : 0.15),
          ),
        ),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Flexible(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Rupee symbol and price
                      Text(
                        '₹',
                        style: TextStyle(
                          fontSize: AppTypography.headingMedium,
                          fontWeight: AppTypography.bold,
                          color: isDark ? Colors.white : tier.primaryColor,
                        ),
                      ),
                      Text(
                        '${!isLifetime ? finalPricePerMonth : finalPrice}',
                        style: TextStyle(
                          fontSize: AppTypography.headingLarge,
                          fontWeight: AppTypography.black,
                          color: isDark ? Colors.white : tier.primaryColor,
                          letterSpacing: -0.5,
                        ),
                      ),
                      Flexible(
                        child: Text(
                          !isLifetime ? ' / mo' : ' one-time',
                          style: TextStyle(
                            fontSize: AppTypography.bodySmall,
                            color: theme.colorScheme.onSurfaceVariant,
                            fontWeight: AppTypography.semiBold,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),

                // Savings Pill
                if (hasSavings)
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 2.5.w, vertical: 0.4.h),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [tier.primaryColor, tier.secondaryColor],
                      ),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: tier.primaryColor.withValues(alpha: AppColors.opacity30),
                          blurRadius: 6,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Text(
                      '🔥 $discountPercent% OFF',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: AppTypography.bold,
                        fontSize: AppTypography.labelSmall,
                        letterSpacing: 0.3,
                      ),
                    ),
                  ),
              ],
            ),

            SizedBox(height: 0.8.h),

            // Billing breakdown & MRP Comparison
            Row(
              children: [
                Expanded(
                  child: Wrap(
                    crossAxisAlignment: WrapCrossAlignment.center,
                    spacing: 1.5.w,
                    runSpacing: 2,
                    children: [
                      if (!isLifetime &&
                          durationMonths > 1 &&
                          mrpPerMonth > finalPricePerMonth)
                        Text(
                          'MRP ₹${features.mrp}',
                          style: TextStyle(
                            fontSize: AppTypography.labelSmall,
                            color: theme.colorScheme.onSurfaceVariant
                                .withValues(alpha: 0.55),
                            decoration: TextDecoration.lineThrough,
                          ),
                        ),
                      Text(
                        !isLifetime
                            ? 'Billed: ₹$finalPrice ($durationMonths mo)'
                            : 'Lifetime Access (Never expires)',
                        style: TextStyle(
                          fontSize: AppTypography.labelSmall,
                          fontWeight: AppTypography.semiBold,
                          color: theme.colorScheme.onSurfaceVariant
                              .withValues(alpha: AppColors.opacity90),
                        ),
                      ),
                    ],
                  ),
                ),
                if (hasSavings) ...[
                  SizedBox(width: 1.5.w),
                  Text(
                    'Save ₹$totalSavings',
                    style: TextStyle(
                      fontSize: AppTypography.labelSmall,
                      fontWeight: AppTypography.bold,
                      color:
                          isDark ? Colors.greenAccent : Colors.green.shade700,
                    ),
                  ),
                ],
              ],
            ),

            // Applied Trust / Coupon perks banner
            if (trustScore > 0 || appliedCoupon != null) ...[
              SizedBox(height: 0.8.h),
              Container(
                width: double.infinity,
                padding: EdgeInsets.symmetric(horizontal: 2.5.w, vertical: 0.4.h),
                decoration: BoxDecoration(
                  color: Colors.green.withValues(alpha: isDark ? 0.15 : 0.08),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(
                    color: Colors.green.withValues(alpha: AppColors.opacity30),
                  ),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.check_circle_outline_rounded, color: Colors.green, size: 13),
                    SizedBox(width: 1.5.w),
                    Expanded(
                      child: Text(
                        appliedCoupon != null
                            ? 'Special ${appliedCoupon!.code} + Trust Discount applied!'
                            : 'Trust Score Verified Discount applied!',
                        style: TextStyle(
                          fontSize: AppTypography.labelTiny,
                          fontWeight: AppTypography.semiBold,
                          color: isDark ? Colors.greenAccent : Colors.green.shade800,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // 3. FEATURES HIGHLIGHT PILLARS
  // ═══════════════════════════════════════════════════════════════════════════

  Widget _buildFeaturePillars(BuildContext context, ThemeData theme, _TierTheme tier, bool isDark) {
    final featuresList = _getPlanFeaturesList(context);
    final displayedFeatures = featuresList.take(4).toList();
    final remainingCount = featuresList.length - displayedFeatures.length;

    return Padding(
      padding: EdgeInsets.fromLTRB(4.w, 1.4.h, 4.w, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Superpower perks list
          ...displayedFeatures.map((item) => Padding(
                padding: EdgeInsets.symmetric(vertical: 0.35.h),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(3.5),
                      decoration: BoxDecoration(
                        color: tier.primaryColor.withValues(alpha: isDark ? 0.2 : 0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        item.icon,
                        color: tier.primaryColor,
                        size: 13,
                      ),
                    ),
                    SizedBox(width: 2.5.w),
                    Expanded(
                      child: Text(
                        item.text,
                        style: TextStyle(
                          fontSize: AppTypography.bodySmall,
                          fontWeight: AppTypography.medium,
                          color: theme.colorScheme.onSurface,
                        ),
                      ),
                    ),
                  ],
                ),
              )),

          // View full comparison trigger
          if (remainingCount > 0) ...[
            SizedBox(height: 0.6.h),
            TactilePressable(
              onTap: () => FeatureComparisonSheet.show(context),
              pressedScale: 0.97,
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 0.4.h),
                child: Row(
                  children: [
                    Icon(Icons.add_circle_outline_rounded,
                        color: tier.primaryColor, size: 14),
                    SizedBox(width: 1.5.w),
                    Expanded(
                      child: Text(
                        'plus $remainingCount more benefits (Tap to Compare)',
                        style: TextStyle(
                          fontSize: AppTypography.labelSmall,
                          fontWeight: AppTypography.bold,
                          color: tier.primaryColor,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    SizedBox(width: 1.w),
                    Icon(Icons.arrow_forward_ios_rounded,
                        color: tier.primaryColor, size: 11),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // 4. CTA UPGRADE BUTTON
  // ═══════════════════════════════════════════════════════════════════════════

  Widget _buildCTAButton(BuildContext context, ThemeData theme, _TierTheme tier, bool isDark) {
    if (isSufficientPlan) {
      return Padding(
        padding: EdgeInsets.all(3.5.w),
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 1.2.h),
          decoration: BoxDecoration(
            color: isDark ? Colors.white.withValues(alpha: AppColors.opacity5) : Colors.black.withValues(alpha: 0.03),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: isDark ? Colors.white12 : Colors.black12,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.check_circle_rounded, color: Colors.green, size: 16),
              SizedBox(width: 2.w),
              Text(
                isCurrentPlan ? '✓ Current Active Plan' : '✓ Included in Current Plan',
                style: TextStyle(
                  fontSize: AppTypography.bodySmall,
                  fontWeight: AppTypography.bold,
                  color: isCurrentPlan ? Colors.green : theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Padding(
      padding: EdgeInsets.all(3.5.w),
      child: TactilePressable(
        onTap: isProcessingPayment ? null : onUpgrade,
        pressedScale: 0.96,
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 1.4.h),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [tier.primaryColor, tier.secondaryColor],
            ),
            borderRadius: BorderRadius.circular(14),
            boxShadow: [
              BoxShadow(
                color: tier.primaryColor.withValues(alpha: AppColors.opacity35),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Center(
            child: isProcessingPayment
                ? const SizedBox(
                    height: 18,
                    width: 18,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2,
                    ),
                  )
                : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        isCurrentPlan
                            ? AppLocalizations.of(context)!.currentPlan
                            : planType == PlanType.free
                                ? 'Continue with Free'
                                : 'UPGRADE TO ${SubscriptionConfig.getDisplayName(planType, AppLocalizations.of(context)).toUpperCase()}',
                        style: TextStyle(
                          fontSize: AppTypography.bodySmall,
                          fontWeight: AppTypography.bold,
                          letterSpacing: 0.4,
                          color: Colors.white,
                        ),
                      ),
                      SizedBox(width: 1.5.w),
                      const Icon(Icons.arrow_forward_rounded, color: Colors.white, size: 15),
                    ],
                  ),
          ),
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // 5. ANIMATED SWEEP ROTATING BORDER
  // ═══════════════════════════════════════════════════════════════════════════

  Widget _buildAnimatedSweepBorder(_TierTheme tier, Widget child) {
    return AnimatedBuilder(
      animation: shimmerAnimation,
      builder: (context, _) {
        final value = shimmerAnimation.value;
        return Container(
          padding: const EdgeInsets.all(1.5),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(21),
            gradient: SweepGradient(
              colors: [
                tier.borderColors[0],
                tier.borderColors[1],
                tier.borderColors[0].withValues(alpha: AppColors.opacity25),
                tier.borderColors[0],
              ],
              stops: const [0.0, 0.3, 0.7, 1.0],
              transform: GradientRotation(value * 2 * 3.14159),
            ),
            boxShadow: [
              BoxShadow(
                color: tier.primaryColor.withValues(alpha: 0.22),
                blurRadius: 14,
                spreadRadius: 0.5,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: child,
        );
      },
    );
  }

  List<_FeatureItem> _getPlanFeaturesList(BuildContext context) {
    final list = <_FeatureItem>[];

    if (features.contactUnlocksPerMonth >= 999) {
      list.add(const _FeatureItem(Icons.phone_iphone_rounded, 'Unlimited Direct Contacts'));
    } else if (features.contactUnlocksPerMonth > 0) {
      list.add(_FeatureItem(Icons.phone_iphone_rounded, '${features.contactUnlocksPerMonth} Verified Contacts / month'));
    }

    if (features.messaging) {
      if (features.newChatsPerWeek >= 999) {
        list.add(const _FeatureItem(Icons.chat_bubble_rounded, 'Unlimited Direct Chats & Replies'));
      } else if (features.newChatsPerWeek > 0) {
        list.add(_FeatureItem(Icons.chat_bubble_rounded, '${features.newChatsPerWeek} New Chats / week + Unlimited Replies'));
      } else {
        list.add(const _FeatureItem(Icons.chat_bubble_rounded, 'Direct Chat & Messaging'));
      }
    }

    if (features.profileViewsPerDay >= 999) {
      list.add(const _FeatureItem(Icons.visibility_rounded, 'Unlimited Daily Profile Views'));
    } else if (features.profileViewsPerDay > 0) {
      list.add(_FeatureItem(Icons.visibility_rounded, '${features.profileViewsPerDay} Profile Views per day'));
    }

    if (features.verificationBadge) {
      list.add(const _FeatureItem(Icons.verified_rounded, 'Official Verified Profile Badge'));
    }

    if (features.profileBoostPerMonth >= 999) {
      list.add(const _FeatureItem(Icons.bolt_rounded, 'Unlimited Monthly Profile Boosts'));
    } else if (features.profileBoostPerMonth > 0) {
      list.add(_FeatureItem(Icons.bolt_rounded, '${features.profileBoostPerMonth} Profile Boosts / month (3x Views)'));
    }

    if (features.photosLimit > 0) {
      list.add(_FeatureItem(Icons.photo_library_rounded, 'Upload up to ${features.photosLimit} Photos'));
    }

    if (features.hasBiodataPremium) {
      list.add(const _FeatureItem(Icons.description_rounded, 'Premium PDF Biodata Templates (Free)'));
    }

    if (features.matchmakerSupport) {
      list.add(const _FeatureItem(Icons.support_agent_rounded, 'Matchmaker Assisted Guidance'));
    }

    if (features.adFree) {
      list.add(const _FeatureItem(Icons.block_rounded, '100% Ad-Free Premium Experience'));
    }

    if (features.prioritySupport) {
      list.add(const _FeatureItem(Icons.verified_user_rounded, '24/7 Priority Support'));
    }

    return list;
  }
}

class _TierTheme {
  final String title;
  final String iconEmoji;
  final IconData iconData;
  final String tagline;
  final String durationLabel;
  final String? ribbonLabel;
  final Color primaryColor;
  final Color secondaryColor;
  final Color accentColor;
  final List<Color> lightBgGradient;
  final List<Color> darkBgGradient;
  final List<Color> borderColors;

  const _TierTheme({
    required this.title,
    required this.iconEmoji,
    required this.iconData,
    required this.tagline,
    required this.durationLabel,
    required this.ribbonLabel,
    required this.primaryColor,
    required this.secondaryColor,
    required this.accentColor,
    required this.lightBgGradient,
    required this.darkBgGradient,
    required this.borderColors,
  });
}

class _FeatureItem {
  final IconData icon;
  final String text;
  const _FeatureItem(this.icon, this.text);
}
