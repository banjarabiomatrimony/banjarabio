import 'package:flutter/material.dart';
import 'package:banjarabio/l10n/app_localizations.dart';
import 'package:fluttertoast/fluttertoast.dart';

import 'package:sizer/sizer.dart';

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
    _tabController = TabController(length: 2, vsync: this);
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
          debugPrint('Subscription load error: ${subRes.errorMessage}');
          debugPrint('Score load error: ${scoreRes.errorMessage}');
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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);

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

                // ─── Tab Bar ───
                Container(
                  margin: EdgeInsets.symmetric(horizontal: 4.w),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surfaceContainerHighest
                        .withValues(alpha: 0.5),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: TabBar(
                    controller: _tabController,
                    indicator: BoxDecoration(
                      color: theme.colorScheme.primary,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: theme.colorScheme.primary
                              .withValues(alpha: 0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    indicatorSize: TabBarIndicatorSize.tab,
                    dividerColor: Colors.transparent,
                    labelColor: Colors.white,
                    unselectedLabelColor: theme.colorScheme.onSurfaceVariant,
                    labelStyle: TextStyle(
                      fontSize: 10.sp,
                      fontWeight: FontWeight.bold,
                    ),
                    tabs: [
                      Tab(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.person, size: 18),
                            SizedBox(width: 1.w),
                            Text(l10n?.selfServicePlans ?? 'Self-Service'),
                          ],
                        ),
                      ),
                      Tab(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.diamond_outlined, size: 18),
                            SizedBox(width: 1.w),
                            Text(l10n?.vipMatchmaker ?? 'VIP Matchmaker'),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                SizedBox(height: 1.h),

                // ─── Tab Views ───
                Expanded(
                  child: TabBarView(
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

    return Container(
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            theme.colorScheme.primary,
            theme.colorScheme.primary.withValues(alpha: 0.7),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.workspace_premium, color: Colors.white, size: 32),
              SizedBox(width: 2.w),
              Text(
                AppLocalizations.of(context)?.currentPlan ?? 'Current Plan',
                style: theme.textTheme.titleMedium?.copyWith(
                  color: Colors.white,
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
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 1.h),
          if (daysRemaining != null)
            Text(
              AppLocalizations.of(context)
                      ?.daysRemaining(daysRemaining.toString()) ??
                  '$daysRemaining days remaining',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: Colors.white70,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildCouponField(ThemeData theme) {
    return GlassmorphismContainer(
      padding: EdgeInsets.all(4.w),
      borderRadius: BorderRadius.circular(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Have a Coupon Code?',
            style: theme.textTheme.titleSmall
                ?.copyWith(fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 1.h),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _couponController,
                  decoration: InputDecoration(
                    hintText: 'Enter code (e.g. GUDI50)',
                    filled: true,
                    fillColor: theme.cardColor.withValues(alpha: 0.5),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: EdgeInsets.symmetric(
                        horizontal: 4.w, vertical: 1.5.h),
                  ),
                  textCapitalization: TextCapitalization.characters,
                  onChanged: (v) {
                    if (_appliedCoupon != null) {
                      setState(() => _appliedCoupon = null);
                    }
                  },
                ),
              ),
              SizedBox(width: 2.w),
              SizedBox(
                height: 5.5.h,
                child: ElevatedButton(
                  onPressed: _isValidatingCoupon ? null : _applyCoupon,
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                  child: _isValidatingCoupon
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child:
                              CircularProgressIndicator(strokeWidth: 2))
                      : const Text('Apply'),
                ),
              ),
            ],
          ),
          if (_appliedCoupon != null)
            Padding(
              padding: EdgeInsets.only(top: 1.h),
              child: Row(
                children: [
                  const Icon(Icons.check_circle,
                      color: Colors.green, size: 16),
                  SizedBox(width: 1.w),
                  Text(
                    'Coupon "${_appliedCoupon!.code}" applied!',
                    style: const TextStyle(
                        color: Colors.green,
                        fontWeight: FontWeight.bold,
                        fontSize: 12),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
