import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import 'package:banjarabio/core/constants/app_typography.dart';
import 'package:banjarabio/core/models/subscription_config.dart';
import 'package:banjarabio/core/models/subscription_model.dart';
import 'package:banjarabio/core/models/coupon_model.dart';
import 'package:banjarabio/l10n/app_localizations.dart';
import 'package:banjarabio/presentation/subscription_screen/widgets/plan_card.dart';
import 'package:banjarabio/presentation/subscription_screen/widgets/trust_score_discount_widget.dart';
import 'package:banjarabio/presentation/subscription_screen/widgets/feature_comparison_sheet.dart';

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
    final l10n = AppLocalizations.of(context);
    
    // Get defined VIP plans from config
    final plans = SubscriptionConfig.getVipPlans();

    return SingleChildScrollView(
      padding: EdgeInsets.all(4.w),
      child: Column(
        children: [
          // ── Majestic VIP Concierge Header ──
          Container(
            padding: EdgeInsets.all(5.w),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF1F1235), Color(0xFF2C1654), Color(0xFF150A26)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: const Color(0xFFFFD700).withValues(alpha: 0.35),
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF2C1654).withValues(alpha: 0.4),
                  blurRadius: 20,
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
                      colors: [Color(0xFFFFD700), Color(0xFFFFA500)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFFFFD700).withValues(alpha: 0.4),
                        blurRadius: 16,
                        spreadRadius: 2,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: const Center(
                    child: Icon(Icons.diamond, color: Color(0xFF3A0070), size: 32),
                  ),
                ),
                SizedBox(height: 2.5.h),
                
                // VIP Title
                Text(
                  l10n?.personalConcierge ?? 'Personal Concierge',
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFFFFD700),
                    letterSpacing: 0.5,
                  ),
                ),
                SizedBox(height: 1.h),
                
                // VIP Description
                Text(
                  l10n?.focusOnCareer ??
                      'Focus on your career, while we find your life partner',
                  style: TextStyle(
                    color: const Color(0xFFE2D6FF),
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

          SizedBox(height: 3.h),

          // Trust Score Discount Gauge
          TrustScoreDiscountWidget(trustScore: trustScore),
          SizedBox(height: 4.h),

          // VIP Plans List Title
          Align(
            alignment: Alignment.centerLeft,
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 1.w),
              child: Text(
                'VIP EXCLUSIVE PLANS',
                style: theme.textTheme.labelLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                  color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.8),
                ),
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

  Widget _buildVipFeaturePillar(
      ThemeData theme, IconData icon, String text) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 0.8.h),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(7),
            decoration: BoxDecoration(
              color: const Color(0xFFFFD700).withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: const Color(0xFFFFD700).withValues(alpha: 0.25),
              ),
            ),
            child: Icon(icon, color: const Color(0xFFFFD700), size: 18),
          ),
          SizedBox(width: 4.w),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                color: const Color(0xFFF0E6FF),
                fontWeight: FontWeight.w600,
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
}
