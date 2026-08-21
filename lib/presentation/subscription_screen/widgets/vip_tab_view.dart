import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import 'package:banjarabio/core/constants/app_typography.dart';
import 'package:banjarabio/core/models/subscription_config.dart';
import 'package:banjarabio/core/models/subscription_model.dart';
import 'package:banjarabio/core/models/coupon_model.dart';
import 'package:banjarabio/l10n/app_localizations.dart';
import 'package:banjarabio/presentation/subscription_screen/widgets/plan_card.dart';
import 'package:banjarabio/presentation/subscription_screen/widgets/feature_comparison_sheet.dart';
import 'package:banjarabio/widgets/tactile/tactile_pressable.dart';
import 'package:banjarabio/theme/app_colors.dart';

class VipTabView extends StatelessWidget {
  final SubscriptionModel? currentSubscription;
  final int trustScore;
  final CouponModel? appliedCoupon;
  final bool isProcessingPayment;
  final Animation<double> shimmerAnimation;
  final Function(PlanType) onUpgrade;

  const VipTabView({
    super.key,
    required this.currentSubscription,
    required this.trustScore,
    required this.appliedCoupon,
    required this.isProcessingPayment,
    required this.shimmerAnimation,
    required this.onUpgrade,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final l10n = AppLocalizations.of(context);
    
    // Get defined VIP plans from config
    final plans = SubscriptionConfig.getVipPlans();

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 4.w),
      child: Column(
        children: [
          // ── Majestic VIP Concierge Header ──
          Container(
            padding: EdgeInsets.all(5.w),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [AppColors.canvasRichDark, AppColors.canvasMidnight, AppColors.canvasDeepDark],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: AppColors.categoryVip.withValues(alpha: AppColors.opacity40),
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: AppColors.canvasMidnight.withValues(alpha: 0.45),
                  blurRadius: 22,
                  spreadRadius: 1,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Column(
              children: [
                // Glowing circular diamond badge
                Container(
                  width: 16.w,
                  height: 16.w,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [AppColors.categoryVip, AppColors.categoryVipDark],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.categoryVip.withValues(alpha: 0.45),
                        blurRadius: 18,
                        spreadRadius: 2,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: const Center(
                    child: Icon(Icons.diamond, color: AppColors.deepIndigo, size: 32),
                  ),
                ),
                SizedBox(height: 2.5.h),
                
                // VIP Title
                Text(
                  l10n?.personalConcierge ?? 'Personal Concierge',
                  style: TextStyle(
                    fontSize: AppTypography.headingMedium,
                    fontWeight: AppTypography.bold,
                    color: AppColors.categoryVip,
                    letterSpacing: 0.5,
                  ),
                ),
                SizedBox(height: 1.h),
                
                // VIP Description
                Text(
                  l10n?.focusOnCareer ??
                      'Focus on your career, while we find your life partner',
                  style: TextStyle(
                    color: AppColors.blue100,
                    fontSize: AppTypography.bodyMedium,
                    height: 1.3,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 3.h),
                
                // VIP Feature Pillars
                _buildVipFeaturePillar(
                  theme,
                  Icons.people_alt,
                  l10n?.dedicatedManager ?? 'Dedicated Relationship Manager',
                ),
                _buildVipFeaturePillar(
                  theme,
                  Icons.contact_phone,
                  l10n?.directContactAccess ?? 'Direct Contact Access',
                ),
                _buildVipFeaturePillar(
                  theme,
                  Icons.auto_awesome,
                  l10n?.profileMakeover ?? 'Professional Profile Makeover',
                ),
                _buildVipFeaturePillar(
                  theme,
                  Icons.visibility_off,
                  l10n?.incognitoMode ?? 'Private Profile Browsing',
                ),
              ],
            ),
          ),

          SizedBox(height: 2.h),

          // VIP Plans List Title
          Align(
            alignment: Alignment.centerLeft,
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 1.w),
              child: Row(
                children: [
                  Container(
                    width: 4,
                    height: 16,
                    decoration: BoxDecoration(
                      color: AppColors.purpleElectric,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  SizedBox(width: 2.w),
                  Text(
                    'VIP EXCLUSIVE PLANS',
                    style: TextStyle(
                      fontSize: AppTypography.labelMedium,
                      fontWeight: AppTypography.bold,
                      letterSpacing: 1.2,
                      color: isDark ? Colors.white70 : theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(height: 2.h),

          // VIP Plans
          ...plans.map((entry) {
            final planType = entry.key;
            final features = entry.value;

            final isCurrentPlan = currentSubscription?.planType == planType;
            final isPlanActive = currentSubscription?.isActive ?? false;
            final isSufficientPlan = isPlanActive &&
                SubscriptionConfig.isPlanBetterOrEqual(
                    currentSubscription?.planType ?? PlanType.free, planType);

            return Padding(
              padding: EdgeInsets.only(bottom: 2.5.h),
              child: PlanCard(
                planType: planType,
                features: features,
                isCurrentPlan: isCurrentPlan,
                isSufficientPlan: isSufficientPlan,
                isProcessingPayment: isProcessingPayment,
                trustScore: trustScore,
                appliedCoupon: appliedCoupon,
                shimmerAnimation: shimmerAnimation,
                onUpgrade: () => onUpgrade(planType),
              ),
            );
          }),

          SizedBox(height: 1.5.h),

          // Compare all features button
          TactilePressable(
            onTap: () => FeatureComparisonSheet.show(context),
            pressedScale: 0.97,
            child: Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(horizontal: 5.w, vertical: 1.6.h),
              decoration: BoxDecoration(
                color: isDark
                    ? AppColors.purpleElectric.withValues(alpha: AppColors.opacity12)
                    : AppColors.purpleElectric.withValues(alpha: AppColors.opacity8),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: AppColors.purpleElectric.withValues(alpha: AppColors.opacity40),
                  width: 1.2,
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.compare_arrows_rounded, color: AppColors.purpleElectric, size: 20),
                  SizedBox(width: 2.5.w),
                  Text(
                    AppLocalizations.of(context)?.compareAllPlanFeatures ?? 'Compare All Plan Features',
                    style: TextStyle(
                      fontSize: AppTypography.bodySmall,
                      fontWeight: AppTypography.bold,
                      color: isDark ? AppColors.lavender : AppColors.materialPurpleDark,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Secure trust badges
          _buildTrustBadges(theme),
        ],
      ),
    );
  }

  Widget _buildVipFeaturePillar(
      ThemeData theme, IconData icon, String text) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 0.8.h),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(7),
            decoration: BoxDecoration(
              color: AppColors.categoryVip.withValues(alpha: AppColors.opacity12),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: AppColors.categoryVip.withValues(alpha: AppColors.opacity25),
              ),
            ),
            child: Icon(icon, color: AppColors.categoryVip, size: 18),
          ),
          SizedBox(width: 4.w),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                color: AppColors.violetBg,
                fontWeight: AppTypography.semiBold,
                fontSize: AppTypography.bodyLarge,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTrustBadges(ThemeData theme) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4.h, horizontal: 2.w),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.lock_outline, size: 14, color: theme.colorScheme.onSurfaceVariant.withValues(alpha: AppColors.opacity60)),
              SizedBox(width: 1.5.w),
              Text(
                'Secure 256-bit SSL Encrypted Payment',
                style: TextStyle(
                  fontSize: AppTypography.labelSmall,
                  fontWeight: AppTypography.semiBold,
                  color: theme.colorScheme.onSurfaceVariant.withValues(alpha: AppColors.opacity70),
                ),
              ),
            ],
          ),
          SizedBox(height: 2.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildBadgeItem(theme, Icons.security, 'Verified Profile'),
              _buildBadgeItem(theme, Icons.verified_user, 'Safe Checkout'),
              _buildBadgeItem(theme, Icons.star, 'Top Matchmaking'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBadgeItem(ThemeData theme, IconData icon, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 15, color: theme.colorScheme.primary.withValues(alpha: AppColors.opacity80)),
        SizedBox(width: 1.w),
        Text(
          label,
          style: TextStyle(
            fontSize: AppTypography.labelMedium,
            fontWeight: AppTypography.bold,
            color: theme.colorScheme.onSurfaceVariant.withValues(alpha: AppColors.opacity80),
          ),
        ),
      ],
    );
  }
}
