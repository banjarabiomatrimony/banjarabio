import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import 'package:banjarabio/core/models/subscription_config.dart';
import 'package:banjarabio/core/models/coupon_model.dart';
import 'package:banjarabio/core/models/subscription_model.dart';
import 'package:banjarabio/l10n/app_localizations.dart';

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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isRecommended = planType == PlanType.gold;
    final isBestValue = planType == PlanType.eternal;

    final discountedPrice = features.getDiscountedPrice(trustScore);
    final couponPercent = appliedCoupon?.discountPercentage ?? 0;
    final finalPrice = features.getFinalPrice(trustScore, couponPercent: couponPercent);
    final totalSavings = features.getTotalSavings(trustScore, couponPercent: couponPercent);

    Widget card = Container(
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isRecommended || isBestValue ? Colors.transparent : theme.dividerColor,
          width: isRecommended || isBestValue ? 0 : 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header rendering...
          _buildHeader(context, theme, isRecommended, isBestValue, discountedPrice, finalPrice, totalSavings),
          // Features...
          _buildFeatures(context, theme),
          // CTA...
          _buildCTA(context, theme, isRecommended, isBestValue),
        ],
      ),
    );

    if (isRecommended || isBestValue) {
      card = _buildAnimatedBorder(theme, card, isRecommended);
    }

    return card;
  }

  Widget _buildHeader(BuildContext context, ThemeData theme, bool isRecommended, bool isBestValue, int discountedPrice, int finalPrice, int totalSavings) {
     return Container(
            padding: EdgeInsets.all(4.w),
            decoration: BoxDecoration(
              gradient: isRecommended
                  ? LinearGradient(
                      colors: [theme.colorScheme.primary.withValues(alpha: 0.12), theme.colorScheme.primary.withValues(alpha: 0.04)],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    )
                  : isBestValue
                      ? LinearGradient(
                          colors: [Colors.amber.withValues(alpha: 0.12), Colors.amber.withValues(alpha: 0.04)],
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                        )
                      : null,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
            ),
            child: Column(
              children: [
                if (isRecommended || isBestValue) ...[
                  _buildAnimatedBadge(theme, isRecommended ? AppLocalizations.of(context)!.mostPopular.toUpperCase() : AppLocalizations.of(context)!.bestValue.toUpperCase(), isRecommended ? theme.colorScheme.primary : Colors.amber.shade700),
                  SizedBox(height: 1.5.h),
                ],
                Text(SubscriptionConfig.getDisplayName(planType, AppLocalizations.of(context)),
                    style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
                SizedBox(height: 0.5.h),
                Text(SubscriptionConfig.getDescription(planType, AppLocalizations.of(context)),
                    style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
                SizedBox(height: 2.h),
                // Pricing display logic goes here (can call shared widget later)
              ],
            ),
     );
  }

  Widget _buildFeatures(BuildContext context, ThemeData theme) {
     return Padding(
        padding: EdgeInsets.all(4.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Simplified feature list for extraction example
            Text(AppLocalizations.of(context)!.featuresIncluded, style: theme.textTheme.labelMedium),
            SizedBox(height: 1.h),
            _buildFeatureItem(theme, '${features.profileViewsPerDay} profile views/day'),
            _buildFeatureItem(theme, '${features.photosLimit} photos'),
          ],
        ),
      );
  }
  
  Widget _buildFeatureItem(ThemeData theme, String text) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 0.8.h),
      child: Row(
        children: [
          Icon(Icons.check_circle, color: theme.colorScheme.primary, size: 20),
          SizedBox(width: 2.w),
          Expanded(child: Text(text, style: theme.textTheme.bodyMedium)),
        ],
      ),
    );
  }

  Widget _buildCTA(BuildContext context, ThemeData theme, bool isRecommended, bool isBestValue) {
    return Padding(
            padding: EdgeInsets.all(4.w),
            child: ElevatedButton(
              onPressed: isSufficientPlan || isProcessingPayment ? null : onUpgrade,
              style: ElevatedButton.styleFrom(
                backgroundColor: isRecommended ? theme.colorScheme.primary : isBestValue ? Colors.amber.shade700 : theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.1),
                foregroundColor: isRecommended || isBestValue ? Colors.white : theme.colorScheme.onSurface,
                padding: EdgeInsets.symmetric(vertical: 1.8.h),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
              child: isProcessingPayment
                  ? const CircularProgressIndicator(color: Colors.white)
                  : Text(isCurrentPlan ? AppLocalizations.of(context)!.currentPlan : AppLocalizations.of(context)!.upgradeNow, style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.bold)),
            ),
    );
  }

  Widget _buildAnimatedBadge(ThemeData theme, String label, Color baseColor) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 0.6.h),
      decoration: BoxDecoration(
        color: baseColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(label, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
    );
  }

  Widget _buildAnimatedBorder(ThemeData theme, Widget child, bool isPrimary) {
     return Container(
       padding: const EdgeInsets.all(2.5),
       decoration: BoxDecoration(
         borderRadius: BorderRadius.circular(18),
         color: isPrimary ? theme.colorScheme.primary : Colors.amber,
       ),
       child: child,
     );
  }
}
