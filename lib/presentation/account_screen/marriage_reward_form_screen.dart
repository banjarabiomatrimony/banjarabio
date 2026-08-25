import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';

import 'package:banjarabio/l10n/app_localizations.dart';
import 'package:banjarabio/core/app_export.dart';
import 'package:banjarabio/core/models/success_story_model.dart';
import 'package:banjarabio/core/repositories/success_story_repository.dart';
import 'package:banjarabio/core/repositories/subscription_repository.dart';
import 'package:banjarabio/widgets/custom_app_bar.dart';
import 'package:banjarabio/widgets/app_logo_image.dart';
import 'package:banjarabio/widgets/tactile/tactile_pressable.dart';
import 'package:banjarabio/widgets/tactile/tactile_category_card.dart';
import 'package:banjarabio/theme/app_category_theme.dart';
import 'package:banjarabio/core/utils/app_feedback_service.dart';

/// 💍 Claim Marriage Gift / Success Story Screen - Ultra-Premium Tactile Edition
/// Features:
/// ✨ Celebration Hero Banner with Pulsating Rings & Gold Sparkles
/// 💎 Interactive Tactile Tier Selectors with Spring Physics & Benefit List
/// 📈 Animated Counting Currency Counter (Live Smooth Calculation)
/// 🏛️ Structured TactileCategoryCards with Dynamic Theming
/// 🔒 100% Trust & Verification Guarantee Banner
/// ❓ Expandable Instant FAQ Accordion
/// 🔘 Tactile Submit Action Button with Loading State & Haptics
class MarriageRewardFormScreen extends StatefulWidget {
  const MarriageRewardFormScreen({super.key});

  @override
  State<MarriageRewardFormScreen> createState() => _MarriageRewardFormScreenState();
}

class _MarriageRewardFormScreenState extends State<MarriageRewardFormScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _storyController = TextEditingController();
  final _partnerNameController = TextEditingController();
  final _instagramLinkController = TextEditingController();

  MarriageRewardType _rewardType = MarriageRewardType.digital25;
  DateTime _weddingDate = DateTime.now().add(const Duration(days: 30));
  double _subscriptionAmount = 0.0;
  bool _isLoading = true;
  bool _isSubmitting = false;

  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.06).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _loadSubscriptionDetails();
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _storyController.dispose();
    _partnerNameController.dispose();
    _instagramLinkController.dispose();
    super.dispose();
  }

  Future<void> _loadSubscriptionDetails() async {
    final subRes = await SubscriptionRepository().getCurrentSubscription();
    subRes.fold(
      onSuccess: (sub) {
        if (mounted) {
          setState(() {
            _subscriptionAmount = sub?.amountPaid?.toDouble() ?? 0.0;
            _isLoading = false;
          });
        }
      },
      onFailure: (_) => setState(() => _isLoading = false),
    );
  }

  void _handleSubmit() async {
    if (!_formKey.currentState!.validate()) {
      HapticFeedback.vibrate();
      return;
    }

    HapticFeedback.mediumImpact();
    setState(() => _isSubmitting = true);

    final story = SuccessStoryModel(
      id: '',
      userId: SessionManager.instance.profileId ?? '',
      partnerName: _partnerNameController.text.trim(),
      storyText: _storyController.text.trim(),
      instagramLink: _instagramLinkController.text.trim(),
      weddingDate: _weddingDate,
      subscriptionAmount: _subscriptionAmount,
      type: _rewardType,
      createdAt: DateTime.now(),
    );

    final res = await SuccessStoryRepository().submitSuccessStory(story);

    if (mounted) {
      res.fold(
        onSuccess: (_) {
          AppFeedback.showSuccess(
            context,
            AppLocalizations.of(context)?.successSubmission ??
                '🎉 Success! Your reward claim has been submitted for review.',
          );
          Navigator.pop(context);
        },
        onFailure: (error) {
          AppFeedback.showError(
            context,
            error,
            contextTag: 'reward',
            fallbackMessage: AppLocalizations.of(context)?.failedWithError(''),
          );
        },
      );
      setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final l10n = AppLocalizations.of(context);

    PreferredSizeWidget buildHeaderAppBar() {
      return CustomAppBar(
        automaticallyImplyLeading: false,
        leadingWidth: 175,
        leading: Padding(
          padding: const EdgeInsets.only(left: 10),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              // ⬅️ Tactile Back Button
              TactilePressable(
                onTap: () {
                  HapticFeedback.lightImpact();
                  Navigator.maybePop(context);
                },
                child: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: (theme.appBarTheme.foregroundColor ?? Colors.white)
                        .withValues(alpha: isDark ? AppColors.opacity12 : AppColors.opacity15),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.arrow_back_ios_new_rounded,
                    color: theme.appBarTheme.foregroundColor ?? Colors.white,
                    size: 15,
                  ),
                ),
              ),
              const SizedBox(width: 8),

              // 👑 App Logo
              ClipOval(
                child: Container(
                  width: 24,
                  height: 24,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                  ),
                  child: const AppLogoImage(
                    width: 24,
                    height: 24,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              const SizedBox(width: 5),

              // 🏷️ Wordmark
              Image.asset(
                'assets/logo/brand_kit/wordmark.png',
                height: 20,
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) =>
                    const SizedBox.shrink(),
              ),
            ],
          ),
        ),
        titleWidget: FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            l10n?.claimMarriageGift ?? 'Found Partner',
            maxLines: 1,
            style: (theme.appBarTheme.titleTextStyle ?? theme.textTheme.titleMedium)?.copyWith(
              fontSize: AppTypography.headingSmall,
              fontWeight: AppTypography.bold,
              color: theme.appBarTheme.foregroundColor ?? Colors.white,
              letterSpacing: 0.1,
            ),
          ),
        ),
      );
    }

    if (_isLoading) {
      return Scaffold(
        backgroundColor: theme.scaffoldBackgroundColor,
        appBar: buildHeaderAppBar(),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    final refundPercentage = _rewardType == MarriageRewardType.digital25 ? 0.25 : 0.35;
    final refundAmount = _subscriptionAmount * refundPercentage;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: buildHeaderAppBar(),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.2.h),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 🎊 1. Royal Celebration Hero Banner
              _buildCelebrationHeroBanner(theme),
              SizedBox(height: 2.h),

              // 👑 2. Reward Tier Selection with Benefits
              _buildRewardTierSelector(theme, l10n),
              SizedBox(height: 2.h),

              // 💍 3. Match & Love Story Details
              TactileCategoryCard(
                categoryType: CategoryType.personal,
                title: l10n?.tellUsYourStory ?? 'Match & Couple Details',
                icon: Icons.favorite_rounded,
                margin: EdgeInsets.zero,
                padding: EdgeInsets.all(3.5.w),
                child: Column(
                  children: [
                    _buildTextInput(
                      controller: _partnerNameController,
                      label: l10n?.partnerName ?? "Partner's Full Name",
                      hint: 'Enter your spouse / partner name',
                      icon: Icons.person_outline_rounded,
                      validator: (v) =>
                          v!.trim().isEmpty ? (l10n?.thisFieldIsRequired ?? 'Required') : null,
                    ),
                    SizedBox(height: 1.5.h),
                    _buildTextInput(
                      controller: _storyController,
                      label: l10n?.yourSuccessStory ?? 'Your Success Story',
                      hint: l10n?.howDidYouMeet ?? 'How did you meet? Share your joy...',
                      icon: Icons.auto_stories_outlined,
                      maxLines: 4,
                    ),
                  ],
                ),
              ),
              SizedBox(height: 2.h),

              // 📸 4. Wedding Date & Proof Link
              TactileCategoryCard(
                categoryType: CategoryType.verification,
                title: l10n?.proofOfMarriage ?? 'Wedding Proof & Date',
                icon: Icons.verified_rounded,
                margin: EdgeInsets.zero,
                padding: EdgeInsets.all(3.5.w),
                child: Column(
                  children: [
                    _buildTextInput(
                      controller: _instagramLinkController,
                      label: l10n?.instagramLink ?? 'Instagram Reel / Post / Proof Link',
                      hint: l10n?.pasteUrlHere ?? 'Paste the URL here',
                      icon: Icons.link_rounded,
                      validator: (v) =>
                          v!.trim().isEmpty ? (l10n?.linkRequiredForRefund ?? 'Link required for refund') : null,
                    ),
                    SizedBox(height: 1.8.h),
                    _buildWeddingDatePickerTile(theme, l10n, isDark),
                  ],
                ),
              ),
              SizedBox(height: 2.h),

              // 💰 5. Live Estimated Refund Preview Card (Animated Counter)
              _buildEstimatedRefundCard(theme, l10n, refundAmount, refundPercentage, isDark),
              SizedBox(height: 2.h),

              // 🔒 6. 100% Trust & Verification Guarantee
              _buildTrustGuaranteeBanner(theme, isDark),
              SizedBox(height: 2.h),

              // ❓ 7. Quick FAQ Accordion
              _buildFaqAccordion(theme, isDark),
              SizedBox(height: 3.h),

              // 🚀 8. Tactile Submit Action Button
              _buildSubmitButton(theme, l10n),
              SizedBox(height: 4.h),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCelebrationHeroBanner(ThemeData theme) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(4.5.w),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        gradient: const LinearGradient(
          colors: [
            AppColors.primaryDark,
            AppColors.primary,
            AppColors.deepOrange,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: AppColors.opacity35),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          AnimatedBuilder(
            animation: _pulseAnimation,
            builder: (context, child) {
              return Transform.scale(
                scale: _pulseAnimation.value,
                child: Container(
                  padding: EdgeInsets.all(3.w),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: AppColors.opacity20),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Colors.white.withValues(alpha: AppColors.opacity40),
                      width: 1.2,
                    ),
                  ),
                  child: const Icon(
                    Icons.card_giftcard_rounded,
                    color: AppColors.categoryVip,
                    size: 32,
                  ),
                ),
              );
            },
          ),
          SizedBox(width: 3.5.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Found Your Life Partner? 🎉💍',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: AppTypography.headingSmall,
                    fontWeight: AppTypography.black,
                    letterSpacing: 0.3,
                  ),
                ),
                SizedBox(height: 0.4.h),
                Text(
                  'Share your story & proof to claim up to 35% cashback on your matrimony subscription!',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: AppColors.opacity90),
                    fontSize: AppTypography.bodySmall,
                    height: 1.35,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRewardTierSelector(ThemeData theme, AppLocalizations? l10n) {
    return TactileCategoryCard(
      categoryType: CategoryType.vip,
      title: l10n?.selectRewardType ?? 'Select Reward Tier',
      icon: Icons.workspace_premium_rounded,
      margin: EdgeInsets.zero,
      padding: EdgeInsets.all(3.5.w),
      child: Column(
        children: [
          Row(
            children: [
              // Tier 1: Digital 25%
              Expanded(
                child: _buildTierOptionCard(
                  title: l10n?.digital ?? 'Digital Proof',
                  percentage: '25% Refund',
                  description: 'Share Reel or Post',
                  type: MarriageRewardType.digital25,
                  icon: Icons.video_library_rounded,
                  theme: theme,
                ),
              ),
              SizedBox(width: 3.w),

              // Tier 2: Team Visit / Invitation 35%
              Expanded(
                child: _buildTierOptionCard(
                  title: l10n?.teamVisit ?? 'Wedding Invite',
                  percentage: '35% Refund',
                  description: 'Invite BanjaraBio Team',
                  type: MarriageRewardType.fullInvitation35,
                  icon: Icons.mark_email_read_rounded,
                  isVipBadge: true,
                  theme: theme,
                ),
              ),
            ],
          ),
          SizedBox(height: 1.5.h),

          // Benefits bullet list for active tier
          Container(
            padding: EdgeInsets.all(3.w),
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: AppColors.opacity35),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: theme.colorScheme.outlineVariant.withValues(alpha: AppColors.opacity25),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.stars_rounded, color: AppColors.categoryAstroDark, size: 16),
                    SizedBox(width: 2.w),
                    Text(
                      _rewardType == MarriageRewardType.digital25
                          ? '25% Tier Benefits Included:'
                          : '35% VIP Max Tier Benefits Included:',
                      style: TextStyle(
                        fontSize: AppTypography.labelSmall,
                        fontWeight: AppTypography.bold,
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 0.8.h),
                _buildBenefitRow(
                  _rewardType == MarriageRewardType.digital25
                      ? 'Share wedding reel / story tag on Instagram'
                      : 'Invite BanjaraBio team to felicitate couple at wedding',
                  theme,
                ),
                _buildBenefitRow('Direct UPI / Bank transfer within 5-7 working days', theme),
                _buildBenefitRow('Featured spotlight in community success stories', theme),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBenefitRow(String text, ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.only(top: 2),
            child: Icon(Icons.check_circle_rounded, color: AppColors.categoryLocation, size: 14),
          ),
          SizedBox(width: 2.w),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: AppTypography.labelSmall,
                color: theme.colorScheme.onSurfaceVariant,
                height: 1.3,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTierOptionCard({
    required String title,
    required String percentage,
    required String description,
    required MarriageRewardType type,
    required IconData icon,
    required ThemeData theme,
    bool isVipBadge = false,
  }) {
    final isSelected = _rewardType == type;
    final isDark = theme.brightness == Brightness.dark;

    return TactilePressable(
      onTap: () {
        HapticFeedback.selectionClick();
        setState(() => _rewardType = type);
      },
      pressedScale: 0.95,
      child: Container(
        padding: EdgeInsets.all(3.w),
        decoration: BoxDecoration(
          color: isSelected
              ? (isDark ? AppColors.warmDarkText : AppColors.rose100)
              : (isDark ? AppColors.surfaceDark28 : theme.colorScheme.surface),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected
                ? AppColors.primary
                : theme.colorScheme.outlineVariant.withValues(alpha: AppColors.opacity40),
            width: isSelected ? 2.0 : 1.0,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: AppColors.opacity25),
                    blurRadius: 10,
                    offset: const Offset(0, 3),
                  ),
                ]
              : null,
        ),
        child: Column(
          children: [
            if (isVipBadge)
              Container(
                margin: const EdgeInsets.only(bottom: 6),
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.categoryVip.withValues(alpha: AppColors.opacity20),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.categoryVip, width: 0.8),
                ),
                child: Text(
                  '🌟 VIP MAX',
                  style: TextStyle(
                    fontSize: AppTypography.labelTiny,
                    fontWeight: AppTypography.black,
                    color: AppColors.amberDark,
                  ),
                ),
              ),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isSelected
                    ? AppColors.primary
                    : theme.colorScheme.surfaceContainerHighest.withValues(alpha: AppColors.opacity50),
              ),
              child: Icon(
                icon,
                color: isSelected ? Colors.white : theme.colorScheme.primary,
                size: 22,
              ),
            ),
            SizedBox(height: 1.h),
            Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontWeight: AppTypography.extraBold,
                fontSize: AppTypography.bodyMedium,
                color: isSelected ? AppColors.primary : theme.colorScheme.onSurface,
              ),
            ),
            SizedBox(height: 0.2.h),
            Text(
              percentage,
              style: TextStyle(
                fontWeight: AppTypography.black,
                fontSize: AppTypography.labelMedium,
                color: isSelected ? AppColors.categoryLocationDark : theme.colorScheme.onSurfaceVariant,
              ),
            ),
            SizedBox(height: 0.3.h),
            Text(
              description,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: AppTypography.labelTiny,
                color: theme.colorScheme.onSurfaceVariant.withValues(alpha: AppColors.opacity80),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextInput({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    int maxLines = 1,
    String? Function(String?)? validator,
  }) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      validator: validator,
      style: TextStyle(
        fontSize: AppTypography.bodyMedium,
        color: theme.colorScheme.onSurface,
        fontWeight: AppTypography.medium,
      ),
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: Icon(icon, color: theme.colorScheme.primary, size: 20),
        filled: true,
        fillColor: isDark
            ? Colors.white.withValues(alpha: 0.04)
            : theme.colorScheme.surfaceContainerHighest.withValues(alpha: AppColors.opacity30),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(
            color: theme.colorScheme.outlineVariant.withValues(alpha: AppColors.opacity40),
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(
            color: theme.colorScheme.outlineVariant.withValues(alpha: AppColors.opacity30),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(
            color: theme.colorScheme.primary,
            width: 1.6,
          ),
        ),
        contentPadding: EdgeInsets.symmetric(horizontal: 3.5.w, vertical: 1.4.h),
      ),
    );
  }

  Widget _buildWeddingDatePickerTile(ThemeData theme, AppLocalizations? l10n, bool isDark) {
    return TactilePressable(
      onTap: () async {
        HapticFeedback.lightImpact();
        final date = await showDatePicker(
          context: context,
          initialDate: _weddingDate,
          firstDate: DateTime(2020),
          lastDate: DateTime(2030),
        );
        if (date != null) setState(() => _weddingDate = date);
      },
      pressedScale: 0.98,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 3.5.w, vertical: 1.4.h),
        decoration: BoxDecoration(
          color: isDark
              ? Colors.white.withValues(alpha: 0.04)
              : theme.colorScheme.surfaceContainerHighest.withValues(alpha: AppColors.opacity30),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: theme.colorScheme.outlineVariant.withValues(alpha: AppColors.opacity30),
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: theme.colorScheme.primary.withValues(alpha: AppColors.opacity12),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.calendar_month_rounded, color: theme.colorScheme.primary, size: 20),
            ),
            SizedBox(width: 3.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n?.weddingDate ?? 'Wedding Date',
                    style: TextStyle(
                      fontSize: AppTypography.labelSmall,
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  SizedBox(height: 0.2.h),
                  Text(
                    '${_weddingDate.day.toString().padLeft(2, '0')}/${_weddingDate.month.toString().padLeft(2, '0')}/${_weddingDate.year}',
                    style: TextStyle(
                      fontSize: AppTypography.bodyMedium,
                      fontWeight: AppTypography.bold,
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.edit_calendar_rounded, size: 20, color: AppColors.primary),
          ],
        ),
      ),
    );
  }

  Widget _buildEstimatedRefundCard(
    ThemeData theme,
    AppLocalizations? l10n,
    double refundAmount,
    double refundPercentage,
    bool isDark,
  ) {
    return Container(
      padding: EdgeInsets.all(4.5.w),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isDark
              ? [AppColors.greenDeepForest, AppColors.darkForest2]
              : [AppColors.successLight, AppColors.green100alt],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppColors.categoryLocation.withValues(alpha: AppColors.opacity40),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.categoryLocation.withValues(alpha: isDark ? 0.2 : 0.12),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.categoryLocation.withValues(alpha: AppColors.opacity20),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.savings_rounded,
              color: AppColors.categoryLocationDark,
              size: 28,
            ),
          ),
          SizedBox(width: 3.5.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n?.estimatedRefund ?? 'Estimated Refund Amount',
                  style: TextStyle(
                    fontSize: AppTypography.bodySmall,
                    fontWeight: AppTypography.semiBold,
                    color: isDark ? Colors.white70 : AppColors.greenDeepForest,
                  ),
                ),
                SizedBox(height: 0.2.h),

                // 📈 Smooth Animated Currency Counter
                TweenAnimationBuilder<double>(
                  tween: Tween<double>(begin: 0.0, end: refundAmount),
                  duration: const Duration(milliseconds: 650),
                  curve: Curves.easeOutCubic,
                  builder: (context, value, child) {
                    return Text(
                      '₹${value.toStringAsFixed(0)}',
                      style: TextStyle(
                        fontSize: AppTypography.headingLarge,
                        fontWeight: AppTypography.black,
                        color: isDark ? AppColors.green400 : AppColors.emerald,
                        letterSpacing: 0.5,
                      ),
                    );
                  },
                ),
                SizedBox(height: 0.2.h),
                Text(
                  '${(refundPercentage * 100).toInt()}% cashback on ₹${_subscriptionAmount.toStringAsFixed(0)} plan',
                  style: TextStyle(
                    fontSize: AppTypography.labelSmall,
                    color: isDark ? Colors.white60 : AppColors.emerald.withValues(alpha: AppColors.opacity80),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTrustGuaranteeBanner(ThemeData theme, bool isDark) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.2.h),
      decoration: BoxDecoration(
        color: isDark
            ? Colors.white.withValues(alpha: 0.04)
            : AppColors.warningLight,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: AppColors.categoryAstroDark.withValues(alpha: AppColors.opacity30),
        ),
      ),
      child: Row(
        children: [
          const Icon(Icons.verified_user_rounded, color: AppColors.categoryAstroDark, size: 22),
          SizedBox(width: 3.w),
          Expanded(
            child: Text(
              '🔒 100% Guaranteed Refund: Direct bank transfer within 7 working days once verification is approved.',
              style: TextStyle(
                fontSize: AppTypography.labelSmall,
                fontWeight: AppTypography.semiBold,
                color: isDark ? Colors.white70 : AppColors.amberDarkestText,
                height: 1.35,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFaqAccordion(ThemeData theme, bool isDark) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark28 : theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: theme.colorScheme.outlineVariant.withValues(alpha: AppColors.opacity30),
        ),
      ),
      child: Theme(
        data: theme.copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          tilePadding: EdgeInsets.symmetric(horizontal: 3.5.w, vertical: 0.2.h),
          leading: Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: theme.colorScheme.primary.withValues(alpha: AppColors.opacity10),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.help_outline_rounded, color: theme.colorScheme.primary, size: 18),
          ),
          title: Text(
            'Frequently Asked Questions (FAQ)',
            style: TextStyle(
              fontSize: AppTypography.bodyMedium,
              fontWeight: AppTypography.bold,
              color: theme.colorScheme.onSurface,
            ),
          ),
          children: [
            Padding(
              padding: EdgeInsets.fromLTRB(4.w, 0, 4.w, 1.5.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildFaqItem(
                    'Q: When do I receive the refund?',
                    'A: Once submitted, our team reviews the proof in 24-48 hours. After verification, funds are credited directly to your UPI ID or Bank account.',
                    theme,
                  ),
                  SizedBox(height: 1.h),
                  _buildFaqItem(
                    'Q: Can I claim if my wedding is in the future?',
                    'A: Yes! You can submit your wedding card/date in advance to book the team visit or digital cashback.',
                    theme,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFaqItem(String q, String a, ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          q,
          style: TextStyle(
            fontSize: AppTypography.labelMedium,
            fontWeight: AppTypography.bold,
            color: theme.colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          a,
          style: TextStyle(
            fontSize: AppTypography.labelSmall,
            color: theme.colorScheme.onSurfaceVariant,
            height: 1.35,
          ),
        ),
      ],
    );
  }

  Widget _buildSubmitButton(ThemeData theme, AppLocalizations? l10n) {
    return TactilePressable(
      onTap: _isSubmitting ? () {} : _handleSubmit,
      pressedScale: 0.96,
      child: Container(
        width: double.infinity,
        height: 52,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [AppColors.primaryDark, AppColors.primary, AppColors.materialPink700],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withValues(alpha: AppColors.opacity40),
              blurRadius: 14,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Center(
          child: _isSubmitting
              ? const SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5),
                )
              : Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.celebration_rounded, color: Colors.white, size: 20),
                    SizedBox(width: 2.w),
                    Text(
                      l10n?.submitForReview ?? 'SUBMIT FOR REVIEW',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: AppTypography.black,
                        fontSize: AppTypography.headingSmall,
                        letterSpacing: 0.6,
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}
