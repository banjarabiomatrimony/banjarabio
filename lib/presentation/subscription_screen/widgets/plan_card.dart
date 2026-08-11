import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import 'package:banjarabio/core/constants/app_typography.dart';
import 'package:banjarabio/core/models/subscription_config.dart';
import 'package:banjarabio/core/models/subscription_model.dart';
import 'package:banjarabio/core/models/coupon_model.dart';
import 'package:banjarabio/l10n/app_localizations.dart';
import 'package:banjarabio/presentation/subscription_screen/widgets/feature_comparison_sheet.dart';

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
          // Header rendering with pricing
          _buildHeader(context, theme, isRecommended, isBestValue, discountedPrice, finalPrice, totalSavings),
          // Features
          _buildFeatures(context, theme),
          // CTA
          _buildCTA(context, theme, isRecommended, isBestValue),
        ],
      ),
    );

    if (isRecommended || isBestValue) {
      card = _buildAnimatedBorder(theme, card, isRecommended);
    }

    return card;
  }

  Widget _buildHeader(
    BuildContext context,
    ThemeData theme,
    bool isRecommended,
    bool isBestValue,
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

    return Container(
      padding: EdgeInsets.fromLTRB(4.w, 4.w, 4.w, 3.w),
      decoration: BoxDecoration(
        gradient: isRecommended
            ? LinearGradient(
                colors: [
                  theme.colorScheme.primary.withValues(alpha: 0.12),
                  theme.colorScheme.primary.withValues(alpha: 0.02),
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              )
            : isBestValue
                ? LinearGradient(
                    colors: [
                      Colors.amber.withValues(alpha: 0.12),
                      Colors.amber.withValues(alpha: 0.02),
                    ],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  )
                : null,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
      ),
      child: Column(
        children: [
          if (isRecommended || isBestValue) ...[
            _buildAnimatedBadge(
              theme,
              isRecommended
                  ? AppLocalizations.of(context)!.mostPopular.toUpperCase()
                  : AppLocalizations.of(context)!.bestValue.toUpperCase(),
              isRecommended ? theme.colorScheme.primary : Colors.amber.shade700,
            ),
            SizedBox(height: 1.5.h),
          ],
          Text(
            SubscriptionConfig.getDisplayName(planType, AppLocalizations.of(context)),
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
              letterSpacing: 0.1,
            ),
          ),
          SizedBox(height: 0.5.h),
          Text(
            SubscriptionConfig.getDescription(planType, AppLocalizations.of(context)),
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.8),
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 2.h),

          // ── Pricing Section ──
          if (planType == PlanType.free) ...[
            Text(
              'Free',
              style: theme.textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.primary,
              ),
            ),
            SizedBox(height: 0.5.h),
            Text(
              'Basic standard access',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.7),
              ),
            ),
          ] else ...[
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                if (!isLifetime && durationMonths > 1 && mrpPerMonth > finalPricePerMonth) ...[
                  Text(
                    '₹$mrpPerMonth',
                    style: TextStyle(
                      fontSize: AppTypography.bodyMedium + 1,
                      color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
                      decoration: TextDecoration.lineThrough,
                    ),
                  ),
                  SizedBox(width: 2.w),
                ],
                Text(
                  '₹${!isLifetime ? finalPricePerMonth : finalPrice}',
                  style: TextStyle(
                    fontSize: AppTypography.headingMedium + 4,
                    fontWeight: FontWeight.bold,
                    color: isRecommended
                        ? theme.colorScheme.primary
                        : isBestValue
                            ? Colors.amber.shade800
                            : theme.colorScheme.onSurface,
                  ),
                ),
                Text(
                  !isLifetime ? ' / month' : ' one-time',
                  style: TextStyle(
                    fontSize: AppTypography.bodySmall,
                    color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.7),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            SizedBox(height: 0.5.h),
            if (!isLifetime && durationMonths > 1) ...[
              Text(
                'Billed as ₹$finalPrice for $durationMonths months',
                style: TextStyle(
                  fontSize: AppTypography.labelMedium,
                  color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.7),
                  fontWeight: FontWeight.w500,
                ),
              ),
              SizedBox(height: 1.h),
            ],
            if (hasSavings) ...[
              Container(
                padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 0.6.h),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: isRecommended
                        ? [theme.colorScheme.primary, theme.colorScheme.primary.withValues(alpha: 0.8)]
                        : isBestValue
                            ? [Colors.amber.shade700, Colors.amber.shade900]
                            : [Colors.green.shade600, Colors.green.shade800],
                  ),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: (isRecommended
                              ? theme.colorScheme.primary
                              : isBestValue
                                  ? Colors.amber
                                  : Colors.green)
                          .withValues(alpha: 0.25),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Text(
                  'Save ₹$totalSavings ($discountPercent% OFF)',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: AppTypography.bodySmall,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.2,
                  ),
                ),
              ),
            ],
          ],
        ],
      ),
    );
  }

  Widget _buildFeatures(BuildContext context, ThemeData theme) {
    final featuresList = _getPlanFeaturesList(context);
    final displayedFeatures = featuresList.take(4).toList();
    final remainingCount = featuresList.length - displayedFeatures.length;
    
    return Padding(
      padding: EdgeInsets.all(4.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.star_border, color: theme.colorScheme.primary, size: 18),
              SizedBox(width: 1.5.w),
              Text(
                AppLocalizations.of(context)!.featuresIncluded.toUpperCase(),
                style: theme.textTheme.labelMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.5,
                  color: theme.colorScheme.primary,
                ),
              ),
            ],
          ),
          SizedBox(height: 1.5.h),
          ...displayedFeatures.map((item) => _buildFeatureItem(theme, item.icon, item.text)),
          if (remainingCount > 0) ...[
            SizedBox(height: 1.h),
            InkWell(
              onTap: () => FeatureComparisonSheet.show(context),
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 0.5.h),
                child: Row(
                  children: [
                    Icon(Icons.add_circle_outline, color: theme.colorScheme.primary, size: 16),
                    SizedBox(width: 2.w),
                    Text(
                      'plus $remainingCount more benefits (Tap to Compare)',
                      style: TextStyle(
                        fontSize: AppTypography.labelMedium,
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildFeatureItem(ThemeData theme, IconData icon, String text) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 0.6.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: theme.colorScheme.primary, size: 18),
          SizedBox(width: 2.5.w),
          Expanded(
            child: Text(
              text,
              style: theme.textTheme.bodyMedium?.copyWith(
                height: 1.25,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
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
          backgroundColor: isRecommended
              ? theme.colorScheme.primary
              : isBestValue
                  ? Colors.amber.shade700
                  : theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.1),
          foregroundColor: isRecommended || isBestValue ? Colors.white : theme.colorScheme.onSurface,
          padding: EdgeInsets.symmetric(vertical: 1.8.h),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        ),
        child: isProcessingPayment
            ? const CircularProgressIndicator(color: Colors.white)
            : Text(
                isCurrentPlan
                    ? AppLocalizations.of(context)!.currentPlan
                    : AppLocalizations.of(context)!.upgradeNow,
                style: TextStyle(fontSize: AppTypography.bodyMedium, fontWeight: FontWeight.bold),
              ),
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
      child: Text(
        label,
        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: AppTypography.bodySmall),
      ),
    );
  }

  Widget _buildAnimatedBorder(ThemeData theme, Widget child, bool isPrimary) {
    return AnimatedBuilder(
      animation: shimmerAnimation,
      builder: (context, _) {
        final value = shimmerAnimation.value;
        return Container(
          padding: const EdgeInsets.all(2.0),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            gradient: SweepGradient(
              colors: isPrimary
                  ? [
                      theme.colorScheme.primary,
                      theme.colorScheme.primary.withValues(alpha: 0.3),
                      theme.colorScheme.secondary,
                      theme.colorScheme.primary,
                    ]
                  : [
                      Colors.amber.shade700,
                      Colors.amber.shade200,
                      Colors.orange.shade600,
                      Colors.amber.shade700,
                    ],
              stops: const [0.0, 0.25, 0.75, 1.0],
              transform: GradientRotation(value * 2 * 3.14159),
            ),
            boxShadow: [
              BoxShadow(
                color: (isPrimary ? theme.colorScheme.primary : Colors.amber).withValues(alpha: 0.25),
                blurRadius: 15,
                spreadRadius: 1,
                offset: const Offset(0, 4),
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

    if (features.profileViewsPerDay >= 999) {
      list.add(const _FeatureItem(Icons.visibility, 'Unlimited Profile Views'));
    } else if (features.profileViewsPerDay > 0) {
      list.add(_FeatureItem(Icons.visibility, '${features.profileViewsPerDay} Profile Views per day'));
    }

    if (features.photosLimit > 0) {
      list.add(_FeatureItem(Icons.photo_library, 'Upload up to ${features.photosLimit} Photos'));
    }

    if (features.sharesPerMonth >= 999) {
      list.add(const _FeatureItem(Icons.share, 'Unlimited Biodata Shares'));
    } else if (features.sharesPerMonth > 0) {
      list.add(_FeatureItem(Icons.share, '${features.sharesPerMonth} Biodata Shares / month'));
    }

    if (features.messaging) {
      if (features.newChatsPerWeek >= 999) {
        list.add(const _FeatureItem(Icons.chat_bubble, 'Unlimited Direct Messaging'));
      } else if (features.newChatsPerWeek > 0) {
        list.add(_FeatureItem(Icons.chat_bubble, '${features.newChatsPerWeek} New Chats / week + Unlimited Replies'));
      } else {
        list.add(const _FeatureItem(Icons.chat_bubble, 'Direct Chat & Messaging'));
      }
    }

    if (features.advancedFilters) {
      list.add(const _FeatureItem(Icons.filter_list, 'Advanced Partner Filters'));
    }

    if (features.profileBoostPerMonth >= 999) {
      list.add(const _FeatureItem(Icons.bolt, 'Unlimited Monthly Profile Boosts'));
    } else if (features.profileBoostPerMonth > 0) {
      list.add(_FeatureItem(Icons.bolt, '${features.profileBoostPerMonth} Profile Boosts / month'));
    }

    if (features.verificationBadge) {
      list.add(const _FeatureItem(Icons.verified, 'Verified Profile Badge'));
    }

    if (features.adFree) {
      list.add(const _FeatureItem(Icons.block, 'Ad-Free Premium Experience'));
    }

    if (features.prioritySupport) {
      list.add(const _FeatureItem(Icons.support_agent, 'Priority 24/7 Support'));
    }

    if (features.hasPersonalManager) {
      list.add(const _FeatureItem(Icons.contact_phone_sharp, 'Dedicated Relationship Manager'));
    }

    if (features.handpickedMatchesPerWeek > 0) {
      list.add(_FeatureItem(Icons.auto_awesome, '${features.handpickedMatchesPerWeek} Curated Match Recommendations / week'));
    }

    if (features.contactUnlocksPerMonth >= 999) {
      list.add(const _FeatureItem(Icons.phone_iphone, 'Unlimited Direct Contact Unlocks'));
    } else if (features.contactUnlocksPerMonth > 0) {
      list.add(_FeatureItem(Icons.phone_iphone, 'Unlock ${features.contactUnlocksPerMonth} Contacts / month'));
    }

    if (features.hasProfileMakeover) {
      list.add(const _FeatureItem(Icons.brush, 'Professional Profile Makeover'));
    }

    if (features.hasFeaturedBadge) {
      list.add(const _FeatureItem(Icons.stars, 'Elite Featured Spotlight Badge'));
    }

    if (features.hasIncognitoMode) {
      list.add(const _FeatureItem(Icons.visibility_off, 'Browse Profiles Incognito'));
    }

    if (features.hasBiodataPremium) {
      list.add(const _FeatureItem(Icons.description, 'Premium PDF Biodata Templates (Free)'));
    }

    return list;
  }
}

class _FeatureItem {
  final IconData icon;
  final String text;
  const _FeatureItem(this.icon, this.text);
}
