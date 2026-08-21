import 'package:banjarabio/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import 'package:banjarabio/core/constants/app_typography.dart';
import 'package:banjarabio/core/models/subscription_config.dart';
import 'package:banjarabio/core/models/subscription_model.dart';
import 'package:banjarabio/core/models/coupon_model.dart';
import 'package:banjarabio/core/repositories/subscription_repository.dart';
import 'package:banjarabio/core/session_manager.dart';
import 'package:banjarabio/presentation/home_screen/widgets/offer_banner_widget.dart';
import 'package:banjarabio/presentation/subscription_screen/widgets/plan_card.dart';
import 'package:banjarabio/presentation/subscription_screen/widgets/feature_comparison_sheet.dart';
import 'package:banjarabio/widgets/tactile/tactile_pressable.dart';

class SelfServiceTabView extends StatelessWidget {
  final SubscriptionModel? currentSubscription;
  final int trustScore;
  final CouponModel? appliedCoupon;
  final bool isProcessingPayment;
  final Animation<double> shimmerAnimation;
  final Function(PlanType) onUpgrade;
  final bool isBvsVerified;

  const SelfServiceTabView({
    super.key,
    required this.currentSubscription,
    required this.trustScore,
    required this.appliedCoupon,
    required this.isProcessingPayment,
    required this.shimmerAnimation,
    required this.onUpgrade,
    this.isBvsVerified = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    // Plans list
    final plans = SubscriptionConfig.getSelfServicePlans();

    // Free trial status
    final profile = SessionManager.instance.currentProfile;
    final isInTrial = profile != null &&
        SubscriptionRepository.isWithinFreeTrial(profile.createdAt);
    final trialDaysLeft = profile != null
        ? SubscriptionRepository.trialDaysRemaining(profile.createdAt)
        : 0;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 4.w),
      child: Column(
        children: [
          // ── Free Trial Banner ──
          if (isInTrial)
            _buildTrialBanner(theme, trialDaysLeft)
          else if (profile != null &&
              !isInTrial &&
              !(currentSubscription?.isPremium ?? false))
            _buildTrialExpiredBanner(theme),

          // Offer Banner
          const OfferBannerWidget(),
          SizedBox(height: 1.5.h),

          // Plans List Title Header
          Align(
            alignment: Alignment.centerLeft,
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 1.w),
              child: Row(
                children: [
                  Container(
                    width: 3.5,
                    height: 15,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          theme.colorScheme.primary,
                          theme.colorScheme.secondary,
                        ],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  SizedBox(width: 2.w),
                  Text(
                    'SELF-SERVICE PLANS',
                    style: TextStyle(
                      fontSize: AppTypography.labelSmall,
                      fontWeight: AppTypography.bold,
                      letterSpacing: 1.2,
                      color: isDark
                          ? Colors.white70
                          : theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    '⚡ Direct Contacts & Messaging',
                    style: TextStyle(
                      fontSize: AppTypography.labelTiny,
                      fontWeight: AppTypography.semiBold,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(height: 1.5.h),

          // Plans List
          ...plans.map((entry) {
            final planType = entry.key;
            final features = entry.value;

            final isCurrentPlan = currentSubscription?.planType == planType;
            final isPlanActive = currentSubscription?.isActive ?? false;
            final isSufficientPlan = isPlanActive &&
                SubscriptionConfig.isPlanBetterOrEqual(
                    currentSubscription?.planType ?? PlanType.free, planType);

            return Padding(
              padding: EdgeInsets.only(bottom: 2.h),
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

          SizedBox(height: 1.h),

          // Compare all features button
          TactilePressable(
            onTap: () => FeatureComparisonSheet.show(context),
            pressedScale: 0.97,
            child: Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.4.h),
              decoration: BoxDecoration(
                color: isDark
                    ? theme.colorScheme.primary.withValues(alpha: 0.1)
                    : theme.colorScheme.primary.withValues(alpha: 0.06),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: theme.colorScheme.primary.withValues(alpha: 0.35),
                  width: 1.2,
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.compare_arrows_rounded,
                      color: theme.colorScheme.primary, size: 18),
                  SizedBox(width: 2.w),
                  Text(
                    AppLocalizations.of(context)?.compareAllPlanFeatures ??
                        'Compare All Plan Features',
                    style: TextStyle(
                      fontSize: AppTypography.bodySmall,
                      fontWeight: AppTypography.bold,
                      color: theme.colorScheme.primary,
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

  Widget _buildTrustBadges(ThemeData theme) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 3.h, horizontal: 2.w),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.lock_outline_rounded,
                  size: 15, color: theme.colorScheme.primary),
              SizedBox(width: 1.5.w),
              Text(
                '100% Secure Checkout via Razorpay',
                style: theme.textTheme.bodySmall?.copyWith(
                  fontWeight: AppTypography.semiBold,
                  fontSize: AppTypography.labelSmall,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
          SizedBox(height: 0.5.h),
          Text(
            'UPI • Google Pay • PhonePe • Cards • Net Banking',
            style: TextStyle(
              fontSize: AppTypography.labelTiny,
              fontWeight: AppTypography.medium,
              color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.6),
            ),
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Trial Banners
  // ─────────────────────────────────────────────────────────────────────────

  Widget _buildTrialBanner(ThemeData theme, int daysLeft) {
    return Container(
      margin: EdgeInsets.only(bottom: 1.8.h),
      padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.2.h),
      decoration: BoxDecoration(
        color: theme.colorScheme.primaryContainer.withValues(alpha: 0.8),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: theme.colorScheme.primary.withValues(alpha: 0.35),
        ),
      ),
      child: Row(
        children: [
          Icon(Icons.hourglass_top_rounded,
              color: theme.colorScheme.primary, size: 20),
          SizedBox(width: 2.5.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Free Trial Active',
                  style: TextStyle(
                    fontWeight: AppTypography.bold,
                    fontSize: AppTypography.bodySmall,
                    color: theme.colorScheme.onPrimaryContainer,
                  ),
                ),
                Text(
                  '$daysLeft days remaining in your free trial',
                  style: TextStyle(
                    color: theme.colorScheme.onPrimaryContainer
                        .withValues(alpha: 0.8),
                    fontSize: AppTypography.labelSmall,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTrialExpiredBanner(ThemeData theme) {
    return Container(
      margin: EdgeInsets.only(bottom: 1.8.h),
      padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.2.h),
      decoration: BoxDecoration(
        color: theme.colorScheme.errorContainer.withValues(alpha: 0.8),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: theme.colorScheme.error.withValues(alpha: 0.35),
        ),
      ),
      child: Row(
        children: [
          Icon(Icons.warning_amber_rounded,
              color: theme.colorScheme.error, size: 20),
          SizedBox(width: 2.5.w),
          Expanded(
            child: Text(
              'Your free trial has ended. Subscribe below to unlock direct contacts and chats.',
              style: TextStyle(
                color: theme.colorScheme.onErrorContainer,
                fontSize: AppTypography.labelSmall,
                fontWeight: AppTypography.medium,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
