import 'package:banjarabio/l10n/app_localizations.dart';
import 'package:banjarabio/routes/app_routes.dart';
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
    
    // Get defined self-service plans from config based on BVS verification
    final plans = SubscriptionConfig.getSelfServicePlans(isBvsVerified: isBvsVerified);

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

          // ── BVS Verification Callout / Badge ──
          if (isBvsVerified)
            _buildBvsVerifiedBadge(context, theme)
          else
            _buildBvsDiscountCallout(context, theme),

          SizedBox(height: 2.h),

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

  // ─────────────────────────────────────────────────────────────────────────
  // BVS Banners
  // ─────────────────────────────────────────────────────────────────────────

  Widget _buildBvsDiscountCallout(BuildContext context, ThemeData theme) {
    final l10n = AppLocalizations.of(context);
    return Container(
      margin: EdgeInsets.only(bottom: 2.h),
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: const LinearGradient(
          colors: [
            Color(0xFF8B1A2E), // BVS Crimson
            Color(0xFFB71C1C),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF8B1A2E).withValues(alpha: 0.35),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(
          color: const Color(0xFFFFD700).withValues(alpha: 0.6),
          width: 1.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(3),
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Colors.amberAccent,
                    width: 1.5,
                  ),
                ),
                child: ClipOval(
                  child: Image.asset(
                    'assets/images/bvs_logo_gold.png',
                    width: 28,
                    height: 28,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              SizedBox(width: 3.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          l10n?.bvsTitle ?? 'बणजारा विरासत संघ',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(width: 2.w),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.amber,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: const Text(
                            'VIP',
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      l10n?.bvsSubsidyCardSubtitle ?? 'विशेष सवलत: वार्षिक प्लॅन फक्त ₹२०० मध्ये!',
                      style: TextStyle(
                        color: Colors.amber.shade200,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 1.5.h),
          Text(
            l10n?.bvsSpecialDiscountBanner ??
                'बणजारा विरासत संघ सदस्य आहात का? BVS कार्ड पडताळणी करा आणि मिळवा वार्षिक प्लॅन फक्त ₹२०० मध्ये!',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12.5,
              height: 1.35,
            ),
          ),
          SizedBox(height: 1.5.h),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () {
                Navigator.pushNamed(context, AppRoutes.communityIdVerification);
              },
              icon: const Icon(Icons.badge_outlined, size: 18),
              label: Text(
                l10n?.bvsUploadCardButton ?? '🪪 BVS कार्ड अपलोड करा (Upload BVS Card)',
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12.5),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFFD700),
                foregroundColor: const Color(0xFF5A000F),
                elevation: 2,
                padding: const EdgeInsets.symmetric(vertical: 10),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBvsVerifiedBadge(BuildContext context, ThemeData theme) {
    final l10n = AppLocalizations.of(context);
    return Container(
      margin: EdgeInsets.only(bottom: 2.h),
      padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.5.h),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        gradient: LinearGradient(
          colors: [
            const Color(0xFF1B5E20),
            Colors.green.shade700,
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.green.withValues(alpha: 0.3),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          const Icon(Icons.verified_user_rounded, color: Colors.amberAccent, size: 28),
          SizedBox(width: 3.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n?.bvsVerifiedActiveBadge ?? '👑 BVS प्रमाणित सदस्य सवलत सक्रिय!',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 13.5,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  l10n?.bvsVerifiedActiveDesc ??
                      'आपल्यासाठी मासिक प्लॅन ₹२० आणि वार्षिक सबस्क्रिप्शन फक्त ₹२०० मध्ये उपलब्ध आहे.',
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 11.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
