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
import 'package:banjarabio/presentation/subscription_screen/widgets/trust_score_discount_widget.dart';
import 'package:banjarabio/presentation/subscription_screen/widgets/feature_comparison_sheet.dart';

class SelfServiceTabView extends StatelessWidget {
  final SubscriptionModel? currentSubscription;
  final int trustScore;
  final CouponModel? appliedCoupon;
  final bool isProcessingPayment;
  final Animation<double> shimmerAnimation;
  final Function(PlanType) onUpgrade;

  const SelfServiceTabView({
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
    
    // Get defined self-service plans from config
    final plans = SubscriptionConfig.getSelfServicePlans();

    // Trial status
    final profile = SessionManager.instance.currentProfile;
    final isInTrial = profile != null &&
        SubscriptionRepository.isWithinFreeTrial(profile.createdAt);
    final trialDaysLeft = profile != null
        ? SubscriptionRepository.trialDaysRemaining(profile.createdAt)
        : 0;

    return SingleChildScrollView(
      padding: EdgeInsets.all(4.w),
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
          SizedBox(height: 2.h),

          // Trust Score Discount Gauge
          TrustScoreDiscountWidget(trustScore: trustScore),
          SizedBox(height: 3.h),

          // Plans List Title
          Align(
            alignment: Alignment.centerLeft,
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 1.w),
              child: Text(
                'CHOOSE A PLAN',
                style: theme.textTheme.labelLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                  color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.8),
                ),
              ),
            ),
          ),
          SizedBox(height: 2.h),

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

          SizedBox(height: 2.h),

          // Compare all features button
          OutlinedButton.icon(
            onPressed: () => FeatureComparisonSheet.show(context),
            icon: const Icon(Icons.compare_arrows),
            label: const Text('Compare All Plan Features'),
            style: OutlinedButton.styleFrom(
              padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 1.5.h),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
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
      padding: EdgeInsets.symmetric(vertical: 4.h, horizontal: 2.w),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.lock_outline, size: 14, color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.6)),
              SizedBox(width: 1.5.w),
              Text(
                'Secure 256-bit SSL Encrypted Payment',
                style: TextStyle(
                  fontSize: AppTypography.labelSmall,
                  fontWeight: FontWeight.w600,
                  color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.7),
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
        Icon(icon, size: 15, color: theme.colorScheme.primary.withValues(alpha: 0.8)),
        SizedBox(width: 1.w),
        Text(
          label,
          style: TextStyle(
            fontSize: AppTypography.labelMedium,
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.8),
          ),
        ),
      ],
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Trial Banners
  // ─────────────────────────────────────────────────────────────────────────

  Widget _buildTrialBanner(ThemeData theme, int daysLeft) {
    return Container(
      margin: EdgeInsets.only(bottom: 2.h),
      padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: LinearGradient(
          colors: [
            Colors.green.shade600,
            Colors.teal.shade700,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.green.withValues(alpha: 0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.auto_awesome, color: Colors.white, size: 24),
          ),
          SizedBox(width: 3.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '🎉 Free Trial Active',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: AppTypography.bodyMedium + 1,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 0.3.h),
                Text(
                  '$daysLeft day${daysLeft == 1 ? '' : 's'} remaining — enjoy all premium features!',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.9),
                    fontSize: AppTypography.bodySmall,
                    fontWeight: FontWeight.w500,
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
      margin: EdgeInsets.only(bottom: 2.h),
      padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.5.h),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: theme.colorScheme.errorContainer.withValues(alpha: 0.3),
        border: Border.all(
          color: theme.colorScheme.error.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        children: [
          Icon(Icons.timer_off_outlined,
              color: theme.colorScheme.error, size: 20),
          SizedBox(width: 2.w),
          Expanded(
            child: Text(
              'Your free trial has ended. Subscribe to continue enjoying premium features.',
              style: TextStyle(
                color: theme.colorScheme.onErrorContainer,
                fontSize: AppTypography.bodySmall,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
