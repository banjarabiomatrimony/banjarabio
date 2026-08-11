import 'package:flutter/material.dart';
import 'package:banjarabio/l10n/app_localizations.dart';
import 'package:fluttertoast/fluttertoast.dart';

import 'package:sizer/sizer.dart';
import 'package:banjarabio/core/constants/app_typography.dart';

import 'package:banjarabio/core/models/subscription_config.dart';
import 'package:banjarabio/core/models/subscription_model.dart';
import 'package:banjarabio/core/repositories/razorpay_repository.dart';
import 'package:banjarabio/core/repositories/subscription_repository.dart';
import 'package:banjarabio/widgets/custom_app_bar.dart';
import 'package:banjarabio/widgets/shimmer_widget.dart';
import 'package:banjarabio/core/models/coupon_model.dart';
import 'package:banjarabio/core/repositories/coupon_repository.dart';
import 'package:banjarabio/widgets/glassmorphism_container.dart';
import 'package:banjarabio/presentation/subscription_screen/widgets/self_service_tab_view.dart';
import 'package:banjarabio/presentation/subscription_screen/widgets/vip_tab_view.dart';
import 'package:banjarabio/core/services/app_logger.dart';

/// Subscription Screen with Tabbed UI:
/// Tab 1: Self-Service Plans (Standard, Silver, Gold, Platinum, Eternal)
/// Tab 2: VIP Matchmaker Plans (Elite, Royal, Eternal Elite)
class SubscriptionScreen extends StatefulWidget {
  const SubscriptionScreen({super.key});

  @override
  State<SubscriptionScreen> createState() => _SubscriptionScreenState();
}

class _SubscriptionScreenState extends State<SubscriptionScreen>
    with TickerProviderStateMixin {
  final SubscriptionRepository _subscriptionRepository =
      SubscriptionRepository();
  final RazorpayRepository _razorpayRepository = RazorpayRepository();

  late AnimationController _shimmerController;
  late TabController _tabController;

  SubscriptionModel? _currentSubscription;
  int _trustScore = 0;
  bool _isLoading = true;
  bool _isProcessingPayment = false;

  final TextEditingController _couponController = TextEditingController();
  CouponModel? _appliedCoupon;
  bool _isValidatingCoupon = false;
  final CouponRepository _couponRepository = CouponRepository();

  @override
  void initState() {
    super.initState();
    _shimmerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2500),
    )..repeat();
    // Only show tabs if VIP plans are enabled
    final tabCount = SubscriptionConfig.hasEnabledVipPlans ? 2 : 1;
    _tabController = TabController(length: tabCount, vsync: this);
    _loadCurrentSubscription();
  }

  @override
  void dispose() {
    _shimmerController.dispose();
    _tabController.dispose();
    _couponController.dispose();
    super.dispose();
  }

  Future<void> _loadCurrentSubscription({bool forceRefresh = false}) async {
    setState(() => _isLoading = true);
    try {
      final subRes = await _subscriptionRepository.getCurrentSubscription(
        forceRefresh: forceRefresh,
      );
      final scoreRes = await _subscriptionRepository.getTrustScore();

      if (mounted) {
        if (subRes.isSuccess && scoreRes.isSuccess) {
          setState(() {
            _currentSubscription = subRes.data;
            _trustScore = scoreRes.data;
            _isLoading = false;
          });
        } else {
          AppLogger.error('SubscriptionScreen', 'Subscription load error: ${subRes.errorMessage}');
          AppLogger.error('SubscriptionScreen', 'Score load error: ${scoreRes.errorMessage}');
          setState(() => _isLoading = false);
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        Fluttertoast.showToast(
          msg: AppLocalizations.of(context)
                  ?.failedToLoadSubscription(e.toString()) ??
              'Failed to load subscription: $e',
          backgroundColor: Theme.of(context).colorScheme.error,
          textColor: Colors.white,
        );
      }
    }
  }

  Future<void> _handleUpgrade(PlanType planType) async {
    if (_isProcessingPayment) return;

    debugPrint(
        '[RAZORPAY] SubscriptionScreen > User tapped upgrade | planType=${planType.name}');
    setState(() => _isProcessingPayment = true);

    try {
      int? customAmountPaise;
      if (_appliedCoupon != null) {
        final originalPrice = SubscriptionConfig.getFeatures(planType)
            .getDiscountedPrice(_trustScore);
        final discount =
            originalPrice * (_appliedCoupon!.discountPercentage / 100);
        customAmountPaise = ((originalPrice - discount) * 100).toInt();
      }

      final response = await _razorpayRepository.startPayment(
        planType: planType,
        customAmountPaise: customAmountPaise,
      );

      if (!mounted) return;

      if (response.isSuccess) {
        debugPrint(
            '[RAZORPAY] SubscriptionScreen > Payment SUCCESS | ${planType.displayName}');
        Fluttertoast.showToast(
          msg: AppLocalizations.of(context)?.paymentSuccessfulWelcome(
                  SubscriptionConfig.getDisplayName(
                      planType, AppLocalizations.of(context))) ??
              'Payment successful! Welcome',
          backgroundColor: Colors.green,
          textColor: Colors.white,
        );

        await _loadCurrentSubscription(forceRefresh: true);

        if (mounted) {
          Navigator.pop(context);
        }
      } else {
        debugPrint(
            '[RAZORPAY] SubscriptionScreen > Payment FAILED | ${response.errorMessage}');
        Fluttertoast.showToast(
          msg: AppLocalizations.of(context)
                  ?.paymentFailedError(response.errorMessage) ??
              'Payment failed: ${response.errorMessage}',
          backgroundColor: Theme.of(context).colorScheme.error,
          textColor: Colors.white,
        );
      }
    } catch (e) {
      if (mounted) {
        Fluttertoast.showToast(
          msg: AppLocalizations.of(context)
                  ?.unexpectedErrorOccurred(e.toString()) ??
              'An unexpected error occurred: $e',
          backgroundColor: Theme.of(context).colorScheme.error,
          textColor: Colors.white,
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isProcessingPayment = false);
      }
    }
  }

  Future<void> _applyCoupon() async {
    final code = _couponController.text.trim();
    if (code.isEmpty) return;

    setState(() => _isValidatingCoupon = true);
    final response = await _couponRepository.validateCoupon(code);

    if (mounted) {
      setState(() => _isValidatingCoupon = false);
      response.fold(
        onSuccess: (coupon) {
          setState(() => _appliedCoupon = coupon);
          Fluttertoast.showToast(
            msg: 'Coupon applied: ${coupon?.discountPercentage}% off!',
            backgroundColor: Colors.green,
            textColor: Colors.white,
          );
        },
        onFailure: (error) {
          setState(() => _appliedCoupon = null);
          Fluttertoast.showToast(
            msg: error,
            backgroundColor: Theme.of(context).colorScheme.error,
            textColor: Colors.white,
          );
        },
      );
    }
  }

  Color _getCurrentPlanTextColor(PlanType planType, ThemeData theme) {
    if (planType == PlanType.gold) {
      return const Color(0xFF422100); // deep warm bronze
    }
    if (planType == PlanType.silver && theme.brightness == Brightness.light) {
      return const Color(0xFF263238); // slate/dark blue grey
    }
    return Colors.white;
  }

  Decoration _getCurrentPlanDecoration(PlanType planType, ThemeData theme) {
    final isDark = theme.brightness == Brightness.dark;
    
    switch (planType) {
      case PlanType.silver:
        return BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: LinearGradient(
            colors: isDark
                ? [const Color(0xFF616161), const Color(0xFF9E9E9E), const Color(0xFFE0E0E0)]
                : [const Color(0xFFCFD8DC), const Color(0xFFECEFF1), const Color(0xFFB0BEC5)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withValues(alpha: 0.25),
              blurRadius: 15,
              offset: const Offset(0, 5),
            ),
          ],
        );
      case PlanType.gold:
        return BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: const LinearGradient(
            colors: [Color(0xFFD4AF37), Color(0xFFFFDF00), Color(0xFFAA7C11)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFFD4AF37).withValues(alpha: 0.35),
              blurRadius: 20,
              offset: const Offset(0, 6),
            ),
          ],
        );
      case PlanType.platinum:
        return BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: LinearGradient(
            colors: isDark
                ? [const Color(0xFF1F1C2C), const Color(0xFF928DAB)]
                : [const Color(0xFFE2E2E2), const Color(0xFFC9D6FF)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF928DAB).withValues(alpha: 0.3),
              blurRadius: 20,
              offset: const Offset(0, 6),
            ),
          ],
        );
      case PlanType.eternal:
        return BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: const LinearGradient(
            colors: [Color(0xFF0F2027), Color(0xFF203A43), Color(0xFF2C5364)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          border: Border.all(
            color: const Color(0xFFFFD700).withValues(alpha: 0.5),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF2C5364).withValues(alpha: 0.4),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        );
      case PlanType.elite:
      case PlanType.royal:
      case PlanType.eternal_elite:
        return BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: const LinearGradient(
            colors: [Color(0xFF8E2DE2), Color(0xFF4A00E0)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          border: Border.all(
            color: const Color(0xFFFFD700).withValues(alpha: 0.4),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF4A00E0).withValues(alpha: 0.4),
              blurRadius: 22,
              offset: const Offset(0, 8),
            ),
          ],
        );
      default:
        return BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: LinearGradient(
            colors: [
              theme.colorScheme.primary,
              theme.colorScheme.primary.withValues(alpha: 0.8),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          boxShadow: [
            BoxShadow(
              color: theme.colorScheme.primary.withValues(alpha: 0.25),
              blurRadius: 15,
              offset: const Offset(0, 5),
            ),
          ],
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);

    final bool showVipTab = SubscriptionConfig.hasEnabledVipPlans;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: CustomAppBar(
          title: l10n?.premiumMembership ?? 'Premium Membership'),
      body: _isLoading
          ? _buildShimmer(theme)
          : Column(
              children: [
                // ─── Current Plan Status ───
                if (_currentSubscription != null)
                  Padding(
                    padding: EdgeInsets.fromLTRB(4.w, 2.h, 4.w, 0),
                    child: _buildCurrentSubscriptionCard(theme),
                  ),

                // ─── Coupon Field ───
                Padding(
                  padding: EdgeInsets.fromLTRB(4.w, 2.h, 4.w, 2.h),
                  child: _buildCouponField(theme),
                ),

                // ─── Tab Bar (only when VIP plans are enabled) ───
                if (showVipTab)
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 4.w),
                    child: GlassmorphismContainer(
                      borderRadius: BorderRadius.circular(16),
                      color: theme.colorScheme.surface,
                      opacity: 0.85,
                      blur: 20,
                      border: Border.all(
                        color: theme.colorScheme.outlineVariant.withValues(alpha: 0.3),
                      ),
                      padding: const EdgeInsets.all(4),
                      child: TabBar(
                        controller: _tabController,
                        indicator: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              theme.colorScheme.primary,
                              theme.colorScheme.primary.withValues(alpha: 0.8),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: theme.colorScheme.primary.withValues(alpha: 0.35),
                              blurRadius: 10,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        indicatorSize: TabBarIndicatorSize.tab,
                        dividerColor: Colors.transparent,
                        labelColor: Colors.white,
                        unselectedLabelColor: theme.colorScheme.onSurfaceVariant,
                        labelStyle: TextStyle(
                          fontSize: AppTypography.bodySmall,
                          fontWeight: FontWeight.bold,
                        ),
                        unselectedLabelStyle: TextStyle(
                          fontSize: AppTypography.bodySmall,
                          fontWeight: FontWeight.normal,
                        ),
                        tabs: [
                          Tab(
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(Icons.person, size: 18),
                                SizedBox(width: 1.5.w),
                                Flexible(
                                  child: Text(
                                    l10n?.selfServicePlans ?? 'Self-Service',
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Tab(
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(Icons.diamond_outlined, size: 18),
                                SizedBox(width: 1.5.w),
                                Flexible(
                                  child: Text(
                                    l10n?.vipMatchmaker ?? 'VIP Matchmaker',
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                if (showVipTab) SizedBox(height: 1.h),

                // ─── Content ───
                Expanded(
                  child: showVipTab
                      ? TabBarView(
                          controller: _tabController,
                          children: [
                            SelfServiceTabView(
                              currentSubscription: _currentSubscription,
                              trustScore: _trustScore,
                              appliedCoupon: _appliedCoupon,
                              isProcessingPayment: _isProcessingPayment,
                              shimmerAnimation: _shimmerController,
                              onUpgrade: _handleUpgrade,
                            ),
                            VipTabView(
                              currentSubscription: _currentSubscription,
                              trustScore: _trustScore,
                              appliedCoupon: _appliedCoupon,
                              isProcessingPayment: _isProcessingPayment,
                              shimmerAnimation: _shimmerController,
                              onUpgrade: _handleUpgrade,
                            ),
                          ],
                        )
                      : SelfServiceTabView(
                          currentSubscription: _currentSubscription,
                          trustScore: _trustScore,
                          appliedCoupon: _appliedCoupon,
                          isProcessingPayment: _isProcessingPayment,
                          shimmerAnimation: _shimmerController,
                          onUpgrade: _handleUpgrade,
                        ),
                ),
              ],
            ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // LOCAL HELPERS
  // ═══════════════════════════════════════════════════════════════════════════

  Widget _buildShimmer(ThemeData theme) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(4.w),
      child: Column(
        children: [
          ShimmerWidget.rectangular(
            height: 20.h,
            shapeBorder: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
          ),
          SizedBox(height: 3.h),
          ...List.generate(
            2,
            (index) => Padding(
              padding: EdgeInsets.only(bottom: 2.h),
              child: ShimmerWidget.rectangular(
                height: 40.h,
                shapeBorder: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCurrentSubscriptionCard(ThemeData theme) {
    final planType = _currentSubscription!.planType;
    final daysRemaining = _currentSubscription!.daysRemaining;
    final textColor = _getCurrentPlanTextColor(planType, theme);

    return Container(
      padding: EdgeInsets.all(4.w),
      decoration: _getCurrentPlanDecoration(planType, theme),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.workspace_premium, color: textColor, size: 32),
              SizedBox(width: 2.w),
              Text(
                AppLocalizations.of(context)?.currentPlan ?? 'Current Plan',
                style: theme.textTheme.titleMedium?.copyWith(
                  color: textColor.withValues(alpha: 0.8),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          SizedBox(height: 2.h),
          Text(
            SubscriptionConfig.getDisplayName(
                planType, AppLocalizations.of(context)),
            style: theme.textTheme.headlineMedium?.copyWith(
              color: textColor,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 1.h),
          if (daysRemaining != null)
            Text(
              AppLocalizations.of(context)
                      ?.daysRemaining(daysRemaining) ??
                  '$daysRemaining days remaining',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: textColor.withValues(alpha: 0.75),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildCouponField(ThemeData theme) {
    final hasCoupon = _appliedCoupon != null;
    return GlassmorphismContainer(
      padding: EdgeInsets.all(4.w),
      borderRadius: BorderRadius.circular(20),
      color: theme.colorScheme.surface,
      opacity: 0.85,
      blur: 20,
      border: Border.all(
        color: hasCoupon
            ? Colors.green.withValues(alpha: 0.4)
            : theme.colorScheme.outlineVariant.withValues(alpha: 0.25),
        width: 1.5,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.local_offer,
                size: 20,
                color: hasCoupon ? Colors.green : theme.colorScheme.primary,
              ),
              SizedBox(width: 2.w),
              Text(
                'Promo Code & Coupons',
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.2,
                ),
              ),
            ],
          ),
          SizedBox(height: 1.5.h),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _couponController,
                  decoration: InputDecoration(
                    hintText: 'Enter code (e.g. GUDI50)',
                    hintStyle: TextStyle(fontSize: AppTypography.bodySmall, color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.6)),
                    filled: true,
                    fillColor: theme.cardColor.withValues(alpha: 0.5),
                    prefixIcon: Icon(
                      Icons.discount_outlined,
                      size: 18,
                      color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.7),
                    ),
                    suffixIcon: hasCoupon
                        ? const Icon(Icons.check_circle, color: Colors.green, size: 20)
                        : null,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: theme.colorScheme.outlineVariant.withValues(alpha: 0.5),
                      ),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: theme.colorScheme.outlineVariant.withValues(alpha: 0.3),
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: theme.colorScheme.primary,
                        width: 1.5,
                      ),
                    ),
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 4.w,
                      vertical: 1.2.h,
                    ),
                  ),
                  textCapitalization: TextCapitalization.characters,
                  style: TextStyle(
                    fontSize: AppTypography.bodySmall,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.0,
                  ),
                  onChanged: (v) {
                    if (_appliedCoupon != null) {
                      setState(() => _appliedCoupon = null);
                    }
                  },
                ),
              ),
              SizedBox(width: 3.w),
              SizedBox(
                height: 5.2.h,
                child: ElevatedButton(
                  onPressed: _isValidatingCoupon ? null : _applyCoupon,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: hasCoupon ? Colors.green : theme.colorScheme.primary,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: EdgeInsets.symmetric(horizontal: 5.w),
                  ),
                  child: _isValidatingCoupon
                      ? const SizedBox(
                          height: 18,
                          width: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : Text(
                          hasCoupon ? 'Applied' : 'Apply',
                          style: TextStyle(
                            fontSize: AppTypography.bodySmall,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ),
            ],
          ),
          if (hasCoupon) ...[
            SizedBox(height: 1.5.h),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.h),
              decoration: BoxDecoration(
                color: Colors.green.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: Colors.green.withValues(alpha: 0.15),
                ),
              ),
              child: Row(
                children: [
                  const Icon(Icons.celebration, color: Colors.green, size: 20),
                  SizedBox(width: 2.w),
                  Expanded(
                    child: Text(
                      'Yay! "${_appliedCoupon!.code}" applied. You save extra ${_appliedCoupon!.discountPercentage}% on checkout!',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: Colors.green.shade800,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}
