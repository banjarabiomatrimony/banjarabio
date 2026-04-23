import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import 'package:banjarabio/core/models/subscription_config.dart';
import 'package:banjarabio/core/models/subscription_model.dart';
import 'package:banjarabio/core/models/coupon_model.dart';
import 'package:banjarabio/l10n/app_localizations.dart';
import 'package:banjarabio/widgets/glassmorphism_container.dart';
import 'package:banjarabio/presentation/subscription_screen/widgets/plan_card.dart';

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
          // VIP Header
          GlassmorphismContainer(
            padding: EdgeInsets.all(4.w),
            borderRadius: BorderRadius.circular(16),
            child: Column(
              children: [
                Container(
                  width: 16.w,
                  height: 16.w,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF6A11CB), Color(0xFF2575FC)],
                    ),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF6A11CB).withValues(alpha: 0.4),
                        blurRadius: 16,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: const Center(
                    child: Icon(Icons.diamond, color: Colors.white, size: 32),
                  ),
                ),
                SizedBox(height: 2.h),
                Text(
                  l10n?.personalConcierge ?? 'Personal Concierge',
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 1.h),
                Text(
                  l10n?.focusOnCareer ??
                      'Focus on your career, while we find your life partner',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 2.h),
                // VIP feature pillars
                _buildVipFeaturePillar(
                    theme, Icons.people_alt, l10n?.dedicatedManager ?? 'Dedicated Relationship Manager'),
                _buildVipFeaturePillar(
                    theme, Icons.contact_phone, l10n?.directContactAccess ?? 'Direct Contact Access'),
                _buildVipFeaturePillar(
                    theme, Icons.auto_awesome, l10n?.profileMakeover ?? 'Professional Profile Makeover'),
                _buildVipFeaturePillar(
                    theme, Icons.visibility_off, l10n?.incognitoMode ?? 'Private Profile Browsing'),
              ],
            ),
          ),

          SizedBox(height: 3.h),

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
          SizedBox(height: 2.h),
        ],
      ),
    );
  }

  Widget _buildVipFeaturePillar(
      ThemeData theme, IconData icon, String text) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 0.6.h),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: const Color(0xFF6A11CB).withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: const Color(0xFF6A11CB), size: 18),
          ),
          SizedBox(width: 3.w),
          Expanded(
            child: Text(text,
                style: theme.textTheme.bodyMedium
                    ?.copyWith(fontWeight: FontWeight.w500)),
          ),
        ],
      ),
    );
  }
}
