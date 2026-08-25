import 'package:flutter/material.dart';
import 'package:banjarabio/l10n/app_localizations.dart';
import 'package:banjarabio/core/utils/app_feedback_service.dart';

import 'package:sizer/sizer.dart';
import 'package:banjarabio/core/constants/app_typography.dart';

import 'package:banjarabio/core/models/subscription_config.dart';
import 'package:banjarabio/core/models/subscription_model.dart';
import 'package:banjarabio/core/models/trust_score_config.dart';
import 'package:banjarabio/core/repositories/razorpay_repository.dart';
import 'package:banjarabio/core/repositories/subscription_repository.dart';
import 'package:banjarabio/widgets/branded_refresh_indicator.dart';
import 'package:banjarabio/widgets/custom_app_bar.dart';
import 'package:banjarabio/widgets/skeleton_loaders.dart';
import 'package:banjarabio/widgets/tactile/tactile_back_button.dart';
import 'package:banjarabio/widgets/tactile/tactile_pressable.dart';
import 'package:banjarabio/core/models/coupon_model.dart';
import 'package:banjarabio/core/repositories/coupon_repository.dart';
import 'package:banjarabio/core/repositories/trust_score_repository.dart';
import 'package:banjarabio/widgets/glassmorphism_container.dart';
import 'package:intl/intl.dart';
import 'package:banjarabio/presentation/subscription_screen/widgets/self_service_tab_view.dart';
import 'package:banjarabio/presentation/subscription_screen/widgets/vip_tab_view.dart';
import 'package:banjarabio/presentation/subscription_screen/widgets/trust_score_discount_widget.dart';
import 'package:banjarabio/presentation/subscription_screen/widgets/services_tab_switcher_widget.dart';
import 'package:banjarabio/routes/app_routes.dart';
import 'package:banjarabio/core/session_manager.dart';
import 'package:banjarabio/core/services/app_logger.dart';
import 'package:banjarabio/theme/app_colors.dart';

/// Subscription Screen with Tabbed UI:
/// Tab 1: Self-Service Plans (Standard, Silver, Gold, Platinum, Eternal / BVS Subsidized Plans)
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
  final TrustScoreRepository _trustScoreRepository = TrustScoreRepository();

  AnimationController? _shimmerController;
  AnimationController? _entranceController;
  AnimationController? _pulseController;

  late Animation<double> _fadeAnimation;
  late Animation<Offset> _headerSlide;
  late Animation<Offset> _couponSlide;
  late Animation<Offset> _tabSlide;
  late Animation<Offset> _contentSlide;
  late Animation<double> _pulseAnimation;

  SubscriptionModel? _currentSubscription;
  int _trustScore = 0;
  bool _isLoading = true;
  bool _isProcessingPayment = false;
  bool _isBvsVerified = false;

  int _selectedTabIndex = 0;
  final TextEditingController _couponController = TextEditingController();
  CouponModel? _appliedCoupon;
  bool _isValidatingCoupon = false;
  List<CouponModel> _availableCoupons = [];
  bool _isCouponsDropdownOpen = false;
  final CouponRepository _couponRepository = CouponRepository();

  void _initControllers() {
    _shimmerController ??= AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2500),
    )..repeat();

    _entranceController ??= AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 850),
    );

    _pulseController ??= AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat(reverse: true);

    _fadeAnimation = CurvedAnimation(
      parent: _entranceController!,
      curve: Curves.easeOut,
    );

    _headerSlide = Tween<Offset>(
      begin: const Offset(0, 0.15),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _entranceController!,
      curve: const Interval(0.0, 0.35, curve: Curves.easeOutCubic),
    ));

    _couponSlide = Tween<Offset>(
      begin: const Offset(0, 0.15),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _entranceController!,
      curve: const Interval(0.2, 0.55, curve: Curves.easeOutCubic),
    ));

    _tabSlide = Tween<Offset>(
      begin: const Offset(0, 0.15),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _entranceController!,
      curve: const Interval(0.35, 0.75, curve: Curves.easeOutCubic),
    ));

    _contentSlide = Tween<Offset>(
      begin: const Offset(0, 0.12),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _entranceController!,
      curve: const Interval(0.5, 1.0, curve: Curves.easeOutCubic),
    ));

    _pulseAnimation = Tween<double>(begin: 0.96, end: 1.04).animate(
      CurvedAnimation(parent: _pulseController!, curve: Curves.easeInOut),
    );
  }

  @override
  void initState() {
    super.initState();
    _initControllers();
    _loadCurrentSubscription();
  }

  @override
  void dispose() {
    _shimmerController?.dispose();
    _entranceController?.dispose();
    _pulseController?.dispose();
    _couponController.dispose();
    super.dispose();
  }

  Future<void> _loadCurrentSubscription({bool forceRefresh = false}) async {
    if (!forceRefresh) {
      setState(() => _isLoading = true);
    }
    try {
      final subRes = await _subscriptionRepository.getCurrentSubscription(
        forceRefresh: forceRefresh,
      );
      final scoreRes = await _subscriptionRepository.getTrustScore();
      final statusRes = await _trustScoreRepository.getVerificationStatus();

      // Fetch dynamic active coupons from backend
      final profileId = SessionManager.instance.profileId;
      final couponsRes =
          await _couponRepository.getActiveCoupons(userId: profileId);
      List<CouponModel> activeCoupons = [];
      if (couponsRes.isSuccess && couponsRes.data.isNotEmpty) {
        activeCoupons = couponsRes.data;
      }

      if (mounted) {
        if (subRes.isSuccess && scoreRes.isSuccess) {
          bool isBvsVerified = false;
          if (statusRes.isSuccess) {
            isBvsVerified = statusRes.data['communityId'] ==
                TrustScoreRepository.statusVerified;
          }

          setState(() {
            _currentSubscription = subRes.data;
            _trustScore = scoreRes.data;
            _isBvsVerified = isBvsVerified;
            _availableCoupons = activeCoupons;
            _isLoading = false;
          });
          _entranceController?.forward(from: 0.0);
        } else {
          AppLogger.error('SubscriptionScreen', 'Subscription load error: ${subRes.errorMessage}');
          AppLogger.error('SubscriptionScreen', 'Score load error: ${scoreRes.errorMessage}');
          setState(() {
            _availableCoupons = activeCoupons;
            _isLoading = false;
          });
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        AppFeedback.showError(
          context,
          e,
          contextTag: 'subscription',
          fallbackMessage: AppLocalizations.of(context)?.failedToLoadSubscription(''),
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
        couponCode: _appliedCoupon?.code,
        entryPoint: 'subscription_screen',
      );

      if (mounted) {
        if (response.isSuccess) {
          AppFeedback.showSuccess(
            context,
            AppLocalizations.of(context)?.paymentSuccessfulWelcome(
                    SubscriptionConfig.getDisplayName(
                        planType, AppLocalizations.of(context))) ??
                'Payment successful! Welcome',
          );
          _loadCurrentSubscription(forceRefresh: true);
        } else {
          AppFeedback.showError(
            context,
            response.errorMessage,
            contextTag: 'subscription',
            fallbackMessage: AppLocalizations.of(context)?.paymentFailedError(''),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        AppFeedback.showError(
          context,
          e,
          contextTag: 'subscription',
          fallbackMessage: AppLocalizations.of(context)?.unexpectedErrorOccurred(''),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isProcessingPayment = false);
      }
    }
  }

  Future<void> _applyCoupon() async {
    final code = _couponController.text.trim().toUpperCase();
    if (code.isEmpty) return;

    setState(() => _isValidatingCoupon = true);
    final response = await _couponRepository.validateCoupon(code);

    if (mounted) {
      setState(() => _isValidatingCoupon = false);
      response.fold(
        onSuccess: (coupon) {
          setState(() => _appliedCoupon = coupon);
          AppFeedback.showSuccess(
            context,
            'Coupon applied: ${coupon?.discountPercentage}% off!',
          );
        },
        onFailure: (error) {
          setState(() => _appliedCoupon = null);
          AppFeedback.showError(
            context,
            error,
            contextTag: 'coupon',
          );
        },
      );
    }
  }

  Color _getCurrentPlanTextColor(PlanType planType, ThemeData theme) {
    if (planType == PlanType.gold) {
      return AppColors.amberBgDark; // deep warm bronze
    }
    if (planType == PlanType.silver && theme.brightness == Brightness.light) {
      return AppColors.slate800; // slate/dark blue grey
    }
    return Colors.white;
  }

  Decoration _getCurrentPlanDecoration(PlanType planType, ThemeData theme) {
    final isDark = theme.brightness == Brightness.dark;
    
    switch (planType) {
      case PlanType.silver:
        return BoxDecoration(
          borderRadius: BorderRadius.circular(22),
          gradient: LinearGradient(
            colors: isDark
                ? [AppColors.slate800, AppColors.slate700, AppColors.slate900]
                : [AppColors.slate600, AppColors.slate500, AppColors.slate700],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          border: Border.all(
            color: AppColors.slate300.withValues(alpha: AppColors.opacity40),
            width: 1.3,
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.slate700.withValues(alpha: AppColors.opacity35),
              blurRadius: 18,
              offset: const Offset(0, 6),
            ),
          ],
        );
      case PlanType.gold:
        return BoxDecoration(
          borderRadius: BorderRadius.circular(22),
          gradient: LinearGradient(
            colors: isDark
                ? [AppColors.amberBrownBg, AppColors.amberBgDark, AppColors.amberBrownBg]
                : [AppColors.amberDeepText, AppColors.amberDark, AppColors.amberBgDark],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          border: Border.all(
            color: AppColors.categoryVip.withValues(alpha: 0.55),
            width: 1.4,
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.gold.withValues(alpha: AppColors.opacity35),
              blurRadius: 20,
              offset: const Offset(0, 6),
            ),
          ],
        );
      case PlanType.platinum:
        return BoxDecoration(
          borderRadius: BorderRadius.circular(22),
          gradient: LinearGradient(
            colors: isDark
                ? [AppColors.surfaceDarkNavy, AppColors.blue900, AppColors.slate900]
                : [AppColors.slate800, AppColors.categoryCareer, AppColors.slate900],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          border: Border.all(
            color: AppColors.blue300.withValues(alpha: 0.45),
            width: 1.3,
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.categoryCareer.withValues(alpha: AppColors.opacity30),
              blurRadius: 18,
              offset: const Offset(0, 6),
            ),
          ],
        );
      case PlanType.eternal:
        return BoxDecoration(
          borderRadius: BorderRadius.circular(22),
          gradient: LinearGradient(
            colors: isDark
                ? [AppColors.slate900, AppColors.slate800, AppColors.slate900]
                : [AppColors.slate900, AppColors.slate800, AppColors.slate900],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          border: Border.all(
            color: AppColors.categoryVip.withValues(alpha: AppColors.opacity60),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.categoryVip.withValues(alpha: AppColors.opacity25),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        );
      case PlanType.elite:
      case PlanType.royal:
      case PlanType.eternal_elite:
        return BoxDecoration(
          borderRadius: BorderRadius.circular(22),
          gradient: LinearGradient(
            colors: isDark
                ? [AppColors.canvasRichDark, AppColors.deepIndigo, AppColors.canvasDeepDark]
                : [AppColors.deepIndigo, AppColors.violetDeep, AppColors.deepIndigo],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          border: Border.all(
            color: AppColors.categoryVip.withValues(alpha: AppColors.opacity50),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.violetDeep.withValues(alpha: AppColors.opacity40),
              blurRadius: 20,
              offset: const Offset(0, 6),
            ),
          ],
        );
      default:
        return BoxDecoration(
          borderRadius: BorderRadius.circular(22),
          gradient: LinearGradient(
            colors: isDark
                ? [AppColors.bloodRedBg, AppColors.crimsonDarkBg, AppColors.crimsonBlack]
                : [AppColors.crimsonMaroon, AppColors.crimsonRose, AppColors.crimsonDarkBg],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          border: Border.all(
            color: AppColors.categoryVip.withValues(alpha: AppColors.opacity40),
            width: 1.3,
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.crimsonRose.withValues(alpha: AppColors.opacity30),
              blurRadius: 18,
              offset: const Offset(0, 6),
            ),
          ],
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    _initControllers();
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final bool showVipTab = SubscriptionConfig.hasEnabledVipPlans;
    final trustDiscount = TrustScoreConfig.getDiscountPercentage(_trustScore);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: CustomAppBar(
        leading: const TactileBackButton(),
        centerTitle: false,
        backgroundColor: isDark ? AppColors.canvasCharcoal : theme.scaffoldBackgroundColor,
        elevation: 0,
        titleWidget: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Membership Plans',
                  style: TextStyle(
                    fontSize: AppTypography.headingSmall,
                    fontWeight: AppTypography.bold,
                    color: isDark ? Colors.white : theme.colorScheme.onSurface,
                    letterSpacing: 0.1,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(width: 1.5.w),
                Icon(
                  Icons.verified_rounded,
                  color: isDark ? AppColors.categoryVip : AppColors.categoryAstroDark,
                  size: 16,
                ),
              ],
            ),
            Text(
              'Unlock Matches & Direct Contacts',
              style: TextStyle(
                fontSize: AppTypography.labelSmall,
                fontWeight: AppTypography.medium,
                color: isDark
                    ? Colors.white60
                    : theme.colorScheme.onSurfaceVariant.withValues(alpha: AppColors.opacity85),
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
        actions: [
          Padding(
            padding: EdgeInsets.only(right: 3.5.w),
            child: TactilePressable(
              onTap: () {
                Navigator.pushNamed(context, AppRoutes.trustScore);
              },
              child: ScaleTransition(
                scale: _pulseAnimation,
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 2.8.w, vertical: 0.5.h),
                  decoration: BoxDecoration(
                    color: isDark
                        ? (trustDiscount > 0
                            ? Colors.green.withValues(alpha: 0.18)
                            : Colors.amber.withValues(alpha: 0.18))
                        : (trustDiscount > 0
                            ? AppColors.greenLightBg
                            : AppColors.goldLight),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isDark
                          ? (trustDiscount > 0
                              ? Colors.green.withValues(alpha: 0.45)
                              : Colors.amber.withValues(alpha: 0.45))
                          : (trustDiscount > 0
                              ? AppColors.green200
                              : AppColors.categoryVip),
                      width: 1.2,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: (trustDiscount > 0
                                ? (isDark ? Colors.green : AppColors.successDark)
                                : (isDark ? Colors.amber : AppColors.categoryVip))
                            .withValues(alpha: isDark ? 0.25 : 0.18),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        trustDiscount > 0
                            ? Icons.discount_rounded
                            : Icons.workspace_premium_rounded,
                        color: isDark
                            ? (trustDiscount > 0 ? Colors.greenAccent : Colors.amber)
                            : (trustDiscount > 0 ? AppColors.success : AppColors.amberDark),
                        size: 15,
                      ),
                      SizedBox(width: 1.2.w),
                      Text(
                        trustDiscount > 0 ? '$trustDiscount% OFF' : 'VIP TIER',
                        style: TextStyle(
                          fontSize: AppTypography.labelSmall,
                          fontWeight: AppTypography.bold,
                          color: isDark
                              ? (trustDiscount > 0 ? Colors.greenAccent : Colors.amber.shade200)
                              : (trustDiscount > 0 ? AppColors.success : AppColors.crimson700),
                          letterSpacing: 0.4,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      body: _isLoading
          ? const SubscriptionSkeleton()
          : BrandedRefreshIndicator(
              onRefresh: () => _loadCurrentSubscription(forceRefresh: true),
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(
                  parent: AlwaysScrollableScrollPhysics(),
                ),
                child: FadeTransition(
                  opacity: _fadeAnimation,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // ─── 1. Hero Showcase / Current Plan Status ───
                      SlideTransition(
                        position: _headerSlide,
                        child: Padding(
                          padding: EdgeInsets.fromLTRB(4.w, 1.5.h, 4.w, 0),
                          child: _buildCurrentSubscriptionCard(theme),
                        ),
                      ),

                      // ─── 2. Coupon Field ───
                      SlideTransition(
                        position: _couponSlide,
                        child: Padding(
                          padding: EdgeInsets.fromLTRB(4.w, 1.5.h, 4.w, 0),
                          child: _buildCouponField(theme),
                        ),
                      ),

                      // ─── 3. BVS Subsidized Plans Shortcut Banner (Above Tabs) ───
                      SlideTransition(
                        position: _tabSlide,
                        child: Padding(
                          padding: EdgeInsets.fromLTRB(4.w, 1.2.h, 4.w, 0),
                          child: _buildBvsDiscountCallout(context, theme),
                        ),
                      ),

                      // ─── 4. User Trust Score Discount Card (Above Tabs) ───
                      SlideTransition(
                        position: _tabSlide,
                        child: Padding(
                          padding: EdgeInsets.fromLTRB(4.w, 1.2.h, 4.w, 0),
                          child: TrustScoreDiscountWidget(trustScore: _trustScore),
                        ),
                      ),

                      SizedBox(height: 1.5.h),

                      // ─── 5. Animated Category Switcher (Self-Service vs VIP) ───
                      if (showVipTab)
                        SlideTransition(
                          position: _tabSlide,
                          child: Padding(
                            padding: EdgeInsets.symmetric(horizontal: 4.w),
                            child: ServicesTabSwitcherWidget(
                              selectedIndex: _selectedTabIndex,
                              onTabChanged: (index) {
                                setState(() => _selectedTabIndex = index);
                              },
                              shimmerAnimation: _shimmerController,
                            ),
                          ),
                        ),

                      if (showVipTab) SizedBox(height: 1.5.h),

                      // ─── 6. Selected Tab Plans Content ───
                      SlideTransition(
                        position: _contentSlide,
                        child: AnimatedSwitcher(
                          duration: const Duration(milliseconds: 300),
                          switchInCurve: Curves.easeOutCubic,
                          switchOutCurve: Curves.easeInCubic,
                          transitionBuilder: (child, animation) {
                            return FadeTransition(
                              opacity: animation,
                              child: SlideTransition(
                                position: Tween<Offset>(
                                  begin: const Offset(0.03, 0),
                                  end: Offset.zero,
                                ).animate(animation),
                                child: child,
                              ),
                            );
                          },
                          child: _selectedTabIndex == 0
                              ? KeyedSubtree(
                                  key: const ValueKey('self_service_tab'),
                                  child: SelfServiceTabView(
                                    currentSubscription: _currentSubscription,
                                    trustScore: _trustScore,
                                    appliedCoupon: _appliedCoupon,
                                    isProcessingPayment: _isProcessingPayment,
                                    shimmerAnimation: _shimmerController!,
                                    onUpgrade: _handleUpgrade,
                                    isBvsVerified: _isBvsVerified,
                                  ),
                                )
                              : KeyedSubtree(
                                  key: const ValueKey('vip_tab'),
                                  child: VipTabView(
                                    currentSubscription: _currentSubscription,
                                    trustScore: _trustScore,
                                    appliedCoupon: _appliedCoupon,
                                    isProcessingPayment: _isProcessingPayment,
                                    shimmerAnimation: _shimmerController!,
                                    onUpgrade: _handleUpgrade,
                                  ),
                                ),
                        ),
                      ),

                      SizedBox(height: 4.h),
                    ],
                  ),
                ),
              ),
            ),
    );
  }



  // ═══════════════════════════════════════════════════════════════════════════
  // LOCAL HELPERS
  // ═══════════════════════════════════════════════════════════════════════════

  Widget _buildBvsDiscountCallout(BuildContext context, ThemeData theme) {
    final l10n = AppLocalizations.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return TactilePressable(
      onTap: () => Navigator.pushNamed(context, AppRoutes.bvsGateway),
      pressedScale: 0.98,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 3.5.w, vertical: 1.1.h),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            colors: isDark
                ? [
                    AppColors.wineDark,
                    AppColors.bloodRedBg,
                  ]
                : [
                    AppColors.crimsonDeep, // BVS Crimson
                    AppColors.wineDark,
                  ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.crimsonDeep
                  .withValues(alpha: isDark ? 0.35 : 0.22),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
          border: Border.all(
            color: AppColors.categoryVip.withValues(alpha: 0.55),
            width: 1.2,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(2.5),
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                border: Border.all(
                  color: AppColors.categoryVip,
                  width: 1.2,
                ),
              ),
              child: ClipOval(
                child: Image.asset(
                  'assets/images/bvs_logo_gold.png',
                  width: 24,
                  height: 24,
                  fit: BoxFit.cover,
                ),
              ),
            ),
            SizedBox(width: 2.5.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      Text(
                        l10n?.bvsTitle ?? 'बणजारा विरासत संघ',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: AppTypography.bodySmall,
                          fontWeight: AppTypography.bold,
                        ),
                      ),
                      SizedBox(width: 1.5.w),
                      ScaleTransition(
                        scale: _pulseAnimation,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 5, vertical: 1),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [AppColors.categoryVip, AppColors.categoryVipDark],
                            ),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            'VIP ₹200',
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: AppTypography.labelTiny,
                              fontWeight: AppTypography.bold,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 0.2.h),
                  Text(
                    l10n?.bvsSubsidyCardSubtitle ??
                        'BVS सदस्यांसाठी विशेष सवलत प्लॅन पहा →',
                    style: TextStyle(
                      color: Colors.amber.shade200,
                      fontSize: AppTypography.labelSmall,
                      fontWeight: AppTypography.medium,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios_rounded,
              color: Colors.amber.shade200,
              size: 13,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCurrentSubscriptionCard(ThemeData theme) {
    final isDark = theme.brightness == Brightness.dark;
    final isSubActive =
        _currentSubscription != null && _currentSubscription!.isActive;

    if (!isSubActive) {
      // ─── Compact Hero Value Showcase (Free / Inactive) ───
      return TactilePressable(
        pressedScale: 0.98,
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 3.5.w, vertical: 1.2.h),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: LinearGradient(
              colors: isDark
                  ? [
                      AppColors.bloodRedBg,
                      AppColors.surfaceDarkBluePurple,
                      AppColors.canvasCharcoal,
                    ]
                  : [
                      AppColors.crimson700,
                      AppColors.crimsonDarkBg,
                      AppColors.bloodRedBg,
                    ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            border: Border.all(
              color: AppColors.categoryVip.withValues(alpha: 0.45),
              width: 1.2,
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.crimson700
                    .withValues(alpha: isDark ? 0.35 : 0.2),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(7),
                decoration: BoxDecoration(
                  color: AppColors.categoryVip.withValues(alpha: AppColors.opacity15),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.workspace_premium_rounded,
                  color: AppColors.categoryVip,
                  size: 22,
                ),
              ),
              SizedBox(width: 2.5.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Upgrade to Premium',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: AppTypography.bodyMedium,
                        fontWeight: AppTypography.bold,
                      ),
                    ),
                    Text(
                      'Unlock 10x matches, direct contacts & chat',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: AppTypography.labelSmall,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              SizedBox(width: 2.w),
              ScaleTransition(
                scale: _pulseAnimation,
                child: Container(
                  padding: EdgeInsets.symmetric(
                      horizontal: 2.5.w, vertical: 0.45.h),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [AppColors.categoryVip, AppColors.categoryVipDark],
                    ),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    'PLANS ↓',
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: AppTypography.labelSmall,
                      fontWeight: AppTypography.bold,
                      letterSpacing: 0.4,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    final planType = _currentSubscription!.planType;
    final daysRemaining = _currentSubscription!.daysRemaining;
    final textColor = _getCurrentPlanTextColor(planType, theme);
    final isVip = _currentSubscription!.isVip;

    // ─── Compact Streamlined Active Subscription Card ───
    return TactilePressable(
      pressedScale: 0.98,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.4.h),
        decoration: _getCurrentPlanDecoration(planType, theme),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Row 1: Header Badge + Live Pulse Status
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(
                      isVip
                          ? Icons.diamond_rounded
                          : Icons.workspace_premium_rounded,
                      color: AppColors.categoryVip,
                      size: 18,
                    ),
                    SizedBox(width: 1.5.w),
                    Text(
                      isVip ? 'VIP CONCIERGE MEMBER' : 'PREMIUM ACTIVE MEMBER',
                      style: TextStyle(
                        color: AppColors.categoryVip,
                        fontWeight: AppTypography.bold,
                        fontSize: AppTypography.labelSmall,
                        letterSpacing: 0.8,
                      ),
                    ),
                  ],
                ),
                ScaleTransition(
                  scale: _pulseAnimation,
                  child: Container(
                    padding: EdgeInsets.symmetric(
                        horizontal: 2.2.w, vertical: 0.3.h),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: AppColors.opacity35),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: Colors.greenAccent.withValues(alpha: AppColors.opacity60),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 6,
                          height: 6,
                          decoration: const BoxDecoration(
                            color: Colors.greenAccent,
                            shape: BoxShape.circle,
                          ),
                        ),
                        SizedBox(width: 1.2.w),
                        Text(
                          'LIVE ACTIVE',
                          style: TextStyle(
                            color: Colors.greenAccent,
                            fontSize: AppTypography.labelTiny,
                            fontWeight: AppTypography.bold,
                            letterSpacing: 0.6,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 0.8.h),

            // Row 2: Plan Name + Validity Pill
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    SubscriptionConfig.getDisplayName(
                        planType, AppLocalizations.of(context)),
                    style: TextStyle(
                      color: textColor,
                      fontSize: AppTypography.headingSmall,
                      fontWeight: AppTypography.bold,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                if (daysRemaining != null) ...[
                  Container(
                    padding: EdgeInsets.symmetric(
                        horizontal: 2.2.w, vertical: 0.35.h),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.16),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: AppColors.opacity20),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.schedule_rounded,
                            size: 12, color: textColor),
                        SizedBox(width: 1.w),
                        Text(
                          '$daysRemaining days left',
                          style: TextStyle(
                            color: textColor,
                            fontSize: AppTypography.labelSmall,
                            fontWeight: AppTypography.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ] else ...[
                  Container(
                    padding: EdgeInsets.symmetric(
                        horizontal: 2.2.w, vertical: 0.35.h),
                    decoration: BoxDecoration(
                      color: AppColors.categoryVip.withValues(alpha: AppColors.opacity20),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: AppColors.categoryVip.withValues(alpha: AppColors.opacity40),
                      ),
                    ),
                    child: Text(
                      '👑 Lifetime',
                      style: TextStyle(
                        color: AppColors.categoryVip,
                        fontSize: AppTypography.labelSmall,
                        fontWeight: AppTypography.bold,
                      ),
                    ),
                  ),
                ],
              ],
            ),
            SizedBox(height: 0.8.h),

            // Row 3: Compact Inline Perks Badges
            Wrap(
              spacing: 1.5.w,
              runSpacing: 0.5.h,
              children: [
                _buildActivePerkPill('⚡ Direct Contacts'),
                _buildActivePerkPill('💬 Chat Unlocked'),
                _buildActivePerkPill('🌟 3x Views'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActivePerkPill(String text) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 2.2.w, vertical: 0.3.h),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: AppColors.opacity12),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.18),
        ),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: Colors.white,
          fontSize: AppTypography.labelSmall,
          fontWeight: AppTypography.semiBold,
        ),
      ),
    );
  }

  Widget _buildCouponField(ThemeData theme) {
    final hasCoupon = _appliedCoupon != null;
    final isDark = theme.brightness == Brightness.dark;
    final hasAvailableCoupons = _availableCoupons.isNotEmpty;

    return GlassmorphismContainer(
      padding: EdgeInsets.symmetric(horizontal: 3.5.w, vertical: 1.4.h),
      borderRadius: BorderRadius.circular(18),
      color: theme.colorScheme.surface,
      opacity: 0.85,
      blur: 20,
      border: Border.all(
        color: hasCoupon
            ? Colors.green.withValues(alpha: AppColors.opacity50)
            : theme.colorScheme.outlineVariant.withValues(alpha: AppColors.opacity25),
        width: 1.2,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.local_offer_rounded,
                    size: 18,
                    color: hasCoupon
                        ? (isDark ? Colors.greenAccent : AppColors.success)
                        : (isDark
                            ? AppColors.categoryVip
                            : theme.colorScheme.primary),
                  ),
                  SizedBox(width: 1.8.w),
                  Text(
                    'Promo Code & Coupons',
                    style: TextStyle(
                      fontSize: AppTypography.bodySmall,
                      fontWeight: AppTypography.bold,
                      letterSpacing: 0.2,
                    ),
                  ),
                ],
              ),
              if (hasCoupon)
                TactilePressable(
                  onTap: () {
                    setState(() {
                      _appliedCoupon = null;
                      _couponController.clear();
                    });
                  },
                  child: Container(
                    padding: EdgeInsets.symmetric(
                        horizontal: 2.2.w, vertical: 0.3.h),
                    decoration: BoxDecoration(
                      color: Colors.red.withValues(alpha: AppColors.opacity12),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(
                        color: Colors.red.withValues(alpha: AppColors.opacity25),
                      ),
                    ),
                    child: Text(
                      '✕ Remove',
                      style: TextStyle(
                        color: Colors.red.shade700,
                        fontSize: AppTypography.labelTiny,
                        fontWeight: AppTypography.bold,
                      ),
                    ),
                  ),
                ),
            ],
          ),
          SizedBox(height: 1.h),

          // Compact Promo Input & Apply Button
          Row(
            children: [
              Expanded(
                child: SizedBox(
                  height: 4.6.h,
                  child: TextField(
                    controller: _couponController,
                    decoration: InputDecoration(
                      hintText: 'Enter promo code',
                      hintStyle: TextStyle(
                        fontSize: AppTypography.labelSmall,
                        color: theme.colorScheme.onSurfaceVariant
                            .withValues(alpha: AppColors.opacity60),
                      ),
                      filled: true,
                      fillColor: theme.cardColor.withValues(alpha: AppColors.opacity50),
                      prefixIcon: Icon(
                        Icons.discount_outlined,
                        size: 16,
                        color: theme.colorScheme.onSurfaceVariant
                            .withValues(alpha: AppColors.opacity70),
                      ),
                      suffixIcon: hasCoupon
                          ? const Icon(Icons.check_circle_rounded,
                              color: Colors.green, size: 18)
                          : null,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide(
                          color: theme.colorScheme.outlineVariant
                              .withValues(alpha: AppColors.opacity40),
                        ),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide(
                          color: theme.colorScheme.outlineVariant
                              .withValues(alpha: AppColors.opacity25),
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide(
                          color: theme.colorScheme.primary,
                          width: 1.3,
                        ),
                      ),
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 3.w,
                        vertical: 0.8.h,
                      ),
                    ),
                    textCapitalization: TextCapitalization.characters,
                    style: TextStyle(
                      fontSize: AppTypography.bodySmall,
                      fontWeight: AppTypography.bold,
                      letterSpacing: 0.8,
                    ),
                    onChanged: (v) {
                      if (_appliedCoupon != null) {
                        setState(() => _appliedCoupon = null);
                      }
                    },
                  ),
                ),
              ),
              SizedBox(width: 2.5.w),
              TactilePressable(
                onTap: _isValidatingCoupon ? null : _applyCoupon,
                child: Container(
                  height: 4.6.h,
                  padding: EdgeInsets.symmetric(horizontal: 4.w),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: hasCoupon
                          ? [Colors.green.shade600, Colors.green.shade800]
                          : [
                              theme.colorScheme.primary,
                              theme.colorScheme.primary.withValues(alpha: AppColors.opacity85),
                            ],
                    ),
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: [
                      BoxShadow(
                        color: (hasCoupon
                                ? Colors.green
                                : theme.colorScheme.primary)
                            .withValues(alpha: AppColors.opacity25),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Center(
                    child: _isValidatingCoupon
                        ? const SizedBox(
                            height: 16,
                            width: 16,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor:
                                  AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                        : Text(
                            hasCoupon ? 'Applied ✓' : 'Apply',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: AppTypography.labelSmall,
                              fontWeight: AppTypography.bold,
                            ),
                          ),
                  ),
                ),
              ),
            ],
          ),

          // ── Dynamic Coupons Dropdown Accordion (Admin / Founder Created Only) ──
          if (hasAvailableCoupons) ...[
            SizedBox(height: 1.h),
            TactilePressable(
              onTap: () {
                setState(() {
                  _isCouponsDropdownOpen = !_isCouponsDropdownOpen;
                });
              },
              child: Container(
                padding:
                    EdgeInsets.symmetric(horizontal: 3.w, vertical: 0.8.h),
                decoration: BoxDecoration(
                  color: isDark
                      ? AppColors.canvasNearBlack.withValues(alpha: AppColors.opacity60)
                      : AppColors.slate100,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: isDark
                        ? AppColors.categoryVip.withValues(alpha: AppColors.opacity30)
                        : AppColors.categoryAstroDark.withValues(alpha: AppColors.opacity25),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.auto_awesome,
                      size: 14,
                      color: isDark
                          ? AppColors.categoryVip
                          : AppColors.categoryAstroDark,
                    ),
                    SizedBox(width: 1.8.w),
                    Expanded(
                      child: Text(
                        'Available Offers & Coupons (${_availableCoupons.length})',
                        style: TextStyle(
                          fontSize: AppTypography.labelSmall,
                          fontWeight: AppTypography.bold,
                          color: isDark
                              ? AppColors.categoryVip
                              : AppColors.amberDarkestText,
                        ),
                      ),
                    ),
                    Icon(
                      _isCouponsDropdownOpen
                          ? Icons.keyboard_arrow_up_rounded
                          : Icons.keyboard_arrow_down_rounded,
                      size: 18,
                      color: isDark
                          ? AppColors.categoryVip
                          : AppColors.amberDarkestText,
                    ),
                  ],
                ),
              ),
            ),
            if (_isCouponsDropdownOpen) ...[
              SizedBox(height: 0.8.h),
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _availableCoupons.length,
                separatorBuilder: (context, index) => SizedBox(height: 0.8.h),
                itemBuilder: (context, index) {
                  final coupon = _availableCoupons[index];
                  final isSelected = _appliedCoupon?.code == coupon.code;

                  return TactilePressable(
                    onTap: () {
                      _couponController.text = coupon.code;
                      _applyCoupon();
                      setState(() => _isCouponsDropdownOpen = false);
                    },
                    child: Container(
                      padding: EdgeInsets.all(2.5.w),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? Colors.green
                                .withValues(alpha: isDark ? 0.18 : 0.08)
                            : isDark
                                ? Colors.white.withValues(alpha: 0.04)
                                : Colors.white,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: isSelected
                              ? Colors.green.withValues(alpha: AppColors.opacity60)
                              : theme.colorScheme.outlineVariant
                                  .withValues(alpha: AppColors.opacity25),
                          width: isSelected ? 1.3 : 1.0,
                        ),
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: EdgeInsets.symmetric(
                                horizontal: 2.w, vertical: 0.3.h),
                            decoration: BoxDecoration(
                              color: isDark
                                  ? AppColors.categoryVip
                                  : AppColors.goldTint100,
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(
                                color: isDark
                                    ? AppColors.categoryVip
                                    : AppColors.categoryAstro,
                              ),
                            ),
                            child: Text(
                              coupon.code,
                              style: TextStyle(
                                fontSize: AppTypography.labelSmall,
                                fontWeight: AppTypography.bold,
                                color: isDark
                                    ? Colors.black
                                    : AppColors.amberDark,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ),
                          SizedBox(width: 2.5.w),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '${coupon.discountPercentage}% OFF • ${coupon.offerName}',
                                  style: TextStyle(
                                    fontSize: AppTypography.labelSmall,
                                    fontWeight: AppTypography.bold,
                                    color: theme.colorScheme.onSurface,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                if (coupon.description != null &&
                                    coupon.description!.isNotEmpty) ...[
                                  Text(
                                    coupon.description!,
                                    style: TextStyle(
                                      fontSize: AppTypography.labelTiny,
                                      color: theme.colorScheme.onSurfaceVariant
                                          .withValues(alpha: AppColors.opacity80),
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                                Text(
                                  'Valid till ${DateFormat('dd MMM yyyy').format(coupon.validUntil)}',
                                  style: TextStyle(
                                    fontSize: AppTypography.labelTiny,
                                    color: theme.colorScheme.onSurfaceVariant
                                        .withValues(alpha: AppColors.opacity60),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(width: 1.5.w),
                          Container(
                            padding: EdgeInsets.symmetric(
                                horizontal: 2.2.w, vertical: 0.35.h),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? Colors.green
                                  : theme.colorScheme.primary
                                      .withValues(alpha: AppColors.opacity12),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              isSelected ? 'Applied' : 'Apply',
                              style: TextStyle(
                                fontSize: AppTypography.labelTiny,
                                fontWeight: AppTypography.bold,
                                color: isSelected
                                    ? Colors.white
                                    : theme.colorScheme.primary,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ],
          ],

          if (hasCoupon) ...[
            SizedBox(height: 1.h),
            Container(
              padding:
                  EdgeInsets.symmetric(horizontal: 2.5.w, vertical: 0.8.h),
              decoration: BoxDecoration(
                color: Colors.green.withValues(alpha: isDark ? 0.15 : 0.08),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: Colors.green.withValues(alpha: AppColors.opacity30),
                ),
              ),
              child: Row(
                children: [
                  const Icon(Icons.celebration,
                      color: Colors.green, size: 16),
                  SizedBox(width: 1.5.w),
                  Expanded(
                    child: Text(
                      'Yay! "${_appliedCoupon!.code}" applied: You save extra ${_appliedCoupon!.discountPercentage}% on checkout!',
                      style: TextStyle(
                        color: isDark
                            ? Colors.greenAccent
                            : Colors.green.shade800,
                        fontWeight: AppTypography.semiBold,
                        fontSize: AppTypography.labelSmall,
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

