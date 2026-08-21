import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:banjarabio/l10n/app_localizations.dart';
import 'package:sizer/sizer.dart';
import 'package:banjarabio/core/app_export.dart';
import 'package:banjarabio/core/models/chat_model.dart';
import 'package:banjarabio/core/repositories/chat_repository.dart';
import 'package:banjarabio/core/theme/app_gradients.dart';
import 'package:banjarabio/presentation/widgets/rewarded_ad_dialog.dart';
import 'package:banjarabio/core/services/ad_reward_service.dart';
import 'package:banjarabio/core/services/app_logger.dart';
import 'package:banjarabio/core/providers/home_tab_provider.dart';
import 'package:banjarabio/widgets/custom_app_bar.dart';
import 'package:banjarabio/widgets/tactile/tactile_back_button.dart';
import 'package:banjarabio/widgets/tactile/tactile_pressable.dart';
import 'package:banjarabio/widgets/branded_refresh_indicator.dart';
import 'package:banjarabio/widgets/branded_empty_state.dart';
import 'package:banjarabio/widgets/shimmer_widget.dart';

class WhoViewedMeScreen extends ConsumerStatefulWidget {
  const WhoViewedMeScreen({super.key});

  @override
  ConsumerState<WhoViewedMeScreen> createState() => _WhoViewedMeScreenState();
}

class _WhoViewedMeScreenState extends ConsumerState<WhoViewedMeScreen> {
  final ChatRepository _chatRepository = ChatRepository();
  bool _isLoading = true;
  List<ProfileViewModel> _views = [];
  bool _isUnlockedByAd = false;

  @override
  void initState() {
    super.initState();
    _loadViews();
  }

  Future<void> _loadViews() async {
    final response = await _chatRepository.getWhoViewedMe();
    if (mounted) {
      Future.microtask(() {
        if (!mounted) return;
        if (response.isSuccess) {
          setState(() {
            _views = response.data;
            _isLoading = false;
          });
        } else {
          AppLogger.error('WhoViewedMeScreen', 'Error loading views: ${response.errorMessage}');
          setState(() {
            _isLoading = false;
          });
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: CustomAppBar(
        leading: const TactileBackButton(),
        title: AppLocalizations.of(context)?.whoViewedMe ?? 'Who Viewed Me',
        actions: [
          if (_views.isNotEmpty)
            Container(
              margin: EdgeInsets.only(right: 3.w),
              padding: EdgeInsets.symmetric(horizontal: 2.8.w, vertical: 0.5.h),
              decoration: BoxDecoration(
                color: theme.colorScheme.primary.withValues(alpha: AppColors.opacity10),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: theme.colorScheme.primary.withValues(alpha: AppColors.opacity25),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.visibility_rounded,
                    size: 14,
                    color: theme.colorScheme.primary,
                  ),
                  SizedBox(width: 1.2.w),
                  Text(
                    '${_views.length}',
                    style: TextStyle(
                      color: theme.colorScheme.primary,
                      fontWeight: AppTypography.extraBold,
                      fontSize: AppTypography.labelMedium,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
      body: _isLoading
          ? _buildLoadingSkeleton(theme)
          : _views.isEmpty
              ? _buildEmptyState(theme)
              : BrandedRefreshIndicator(
                  onRefresh: _loadViews,
                  child: _buildTimelineList(theme, isDark),
                ),
      bottomNavigationBar: (!SessionManager.instance.isPremium && !_isUnlockedByAd && _views.length > 3)
          ? _buildUnlockBanner(theme, isDark)
          : null,
    );
  }

  Widget _buildLoadingSkeleton(ThemeData theme) {
    return SingleChildScrollView(
      physics: const NeverScrollableScrollPhysics(),
      padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.5.h),
      child: Column(
        children: [
          ShimmerWidget.rectangular(
            height: 8.h,
            shapeBorder: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
          ),
          SizedBox(height: 2.h),
          ...List.generate(
            6,
            (index) => Padding(
              padding: EdgeInsets.only(bottom: 1.5.h),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    width: 6.w,
                    child: Column(
                      children: [
                        const ShimmerWidget.circular(width: 10, height: 10),
                        SizedBox(height: 0.8.h),
                        const ShimmerWidget.rectangular(height: 60, width: 2),
                      ],
                    ),
                  ),
                  SizedBox(width: 2.w),
                  Expanded(
                    child: ShimmerWidget.rectangular(
                      height: 9.h,
                      shapeBorder: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimelineList(ThemeData theme, bool isDark) {
    final bool isPremium = SessionManager.instance.isPremium;
    final bool isFullyUnlocked = isPremium || _isUnlockedByAd;
    // Show first 3 items clearly, then blurred tease cards
    final int clearCount = _views.length > 3 ? 3 : _views.length;
    final int blurredCount = isFullyUnlocked ? 0 : (_views.length - clearCount).clamp(0, 4);
    final int totalItems = isFullyUnlocked 
        ? _views.length 
        : clearCount + (blurredCount > 0 ? blurredCount + 1 : 0); // +1 for CTA card

    return ListView.builder(
      physics: const AlwaysScrollableScrollPhysics(
        parent: BouncingScrollPhysics(),
      ),
      padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.5.h),
      itemCount: totalItems + 1, // +1 for header info banner
      itemBuilder: (context, index) {
        if (index == 0) {
          return _buildHeaderInfoBanner(theme, isDark);
        }

        final itemIndex = index - 1;

        // Clear items
        if (itemIndex < clearCount || isFullyUnlocked) {
          if (itemIndex >= _views.length) return const SizedBox.shrink();
          final view = _views[itemIndex];
          return _AnimatedTimelineEntry(
            index: itemIndex,
            isLast: itemIndex == totalItems - 1,
            child: _buildViewCard(theme, view, isDark),
          );
        }

        // CTA card inserted after blurred items
        if (itemIndex == clearCount + blurredCount) {
          return _buildPremiumTeaseCard(theme, isDark);
        }

        // Blurred tease cards
        final blurIndex = clearCount + (itemIndex - clearCount);
        if (blurIndex < _views.length) {
          final view = _views[blurIndex];
          return _AnimatedTimelineEntry(
            index: itemIndex,
            isLast: false,
            child: _buildBlurredViewCard(theme, view, isDark),
          );
        }
        return const SizedBox.shrink();
      },
    );
  }

  Widget _buildHeaderInfoBanner(ThemeData theme, bool isDark) {
    return Container(
      margin: EdgeInsets.only(bottom: 2.h),
      padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.4.h),
      decoration: BoxDecoration(
        color: isDark ? theme.cardColor : theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: theme.colorScheme.primary.withValues(alpha: AppColors.opacity15),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(9),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  theme.colorScheme.primary,
                  theme.colorScheme.primary.withValues(alpha: AppColors.opacity80),
                ],
              ),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.remove_red_eye_rounded,
              color: Colors.white,
              size: 20,
            ),
          ),
          SizedBox(width: 3.5.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${_views.length} Profile ${_views.length == 1 ? "Visitor" : "Visitors"}',
                  style: TextStyle(
                    fontWeight: AppTypography.extraBold,
                    fontSize: AppTypography.bodyMedium,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
                SizedBox(height: 0.2.h),
                Text(
                  'Members who recently viewed your biodata & details',
                  style: TextStyle(
                    fontSize: AppTypography.bodySmall,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// 🔒 Blurred tease card — shows profile with blur overlay + lock icon
  Widget _buildBlurredViewCard(ThemeData theme, ProfileViewModel view, bool isDark) {
    // Mask the name: show first 2 chars + asterisks
    final maskedName = (view.viewerName ?? 'Someone');
    final displayName = maskedName.length > 2
        ? '${maskedName.substring(0, 2)}${'•' * (maskedName.length - 2)}'
        : maskedName;

    return TactilePressable(
      onTap: () => _showUpgradePrompt(theme),
      pressedScale: 0.97,
      child: Container(
        margin: EdgeInsets.only(bottom: 1.5.h),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Stack(
            children: [
              // Blurred content layer
              ImageFiltered(
                imageFilter: ImageFilter.blur(sigmaX: 6, sigmaY: 6),
                child: Container(
                  padding: EdgeInsets.all(3.w),
                  decoration: BoxDecoration(
                    color: theme.cardColor,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: isDark
                          ? Colors.white.withValues(alpha: AppColors.opacity8)
                          : theme.colorScheme.outlineVariant.withValues(alpha: AppColors.opacity20),
                    ),
                  ),
                  child: Row(
                    children: [
                      // Blurred avatar
                      Container(
                        width: 14.w,
                        height: 14.w,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: AppGradients.romance,
                        ),
                        padding: const EdgeInsets.all(2),
                        child: ClipOval(
                          child: CustomImageWidget(
                            imageUrl: view.viewerImageUrl ?? '',
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      SizedBox(width: 3.w),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              displayName,
                              style: TextStyle(
                                fontWeight: AppTypography.bold,
                                fontSize: AppTypography.bodyMedium,
                                color: theme.colorScheme.onSurface,
                              ),
                            ),
                            SizedBox(height: 0.3.h),
                            Row(
                              children: [
                                Icon(
                                  Icons.visibility,
                                  size: 12,
                                  color: theme.colorScheme.primary,
                                ),
                                SizedBox(width: 1.w),
                                Text(
                                  '${view.viewCount} ${view.viewCount == 1 ? (AppLocalizations.of(context)?.viewLabel ?? "") : (AppLocalizations.of(context)?.viewsLabel ?? "")}',
                                  style: TextStyle(
                                    fontSize: AppTypography.labelMedium,
                                    color: theme.colorScheme.onSurfaceVariant,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              // Lock overlay
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    color: theme.cardColor.withValues(alpha: AppColors.opacity30),
                  ),
                  child: Center(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primary.withValues(alpha: AppColors.opacity90),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.lock_rounded, color: Colors.white, size: 14),
                          const SizedBox(width: 4),
                          Text(
                            AppLocalizations.of(context)?.premium ?? 'Premium',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: AppTypography.labelMedium,
                              fontWeight: AppTypography.bold,
                              letterSpacing: 0.5,
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
        ),
      ),
    );
  }

  /// 💎 Premium tease CTA card — compelling upgrade prompt between blurred items
  Widget _buildPremiumTeaseCard(ThemeData theme, bool isDark) {
    final hiddenCount = _views.length - 3;
    final l10n = AppLocalizations.of(context);

    return Container(
      margin: EdgeInsets.symmetric(vertical: 2.h),
      padding: EdgeInsets.all(5.w),
      decoration: BoxDecoration(
        color: isDark ? theme.cardColor : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: theme.colorScheme.primary.withValues(alpha: AppColors.opacity30),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.primary.withValues(alpha: AppColors.opacity10),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // Emoji + count header
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [
                  theme.colorScheme.primary,
                  theme.colorScheme.primary.withValues(alpha: AppColors.opacity70),
                ],
              ),
              boxShadow: [
                BoxShadow(
                  color: theme.colorScheme.primary.withValues(alpha: AppColors.opacity30),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Center(
              child: Text(
                '+$hiddenCount',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: AppTypography.headingSmall,
                  fontWeight: AppTypography.black,
                ),
              ),
            ),
          ),
          SizedBox(height: 1.5.h),
          Text(
            '$hiddenCount more people viewed your profile',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontWeight: AppTypography.bold,
              fontSize: AppTypography.bodyLarge,
              color: theme.colorScheme.onSurface,
            ),
          ),
          SizedBox(height: 0.5.h),
          Text(
            'Upgrade to see who is interested in you',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: AppTypography.bodySmall,
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          SizedBox(height: 2.h),
          // Two-button layout: Watch Ad | Go Pro
          Row(
            children: [
              // Watch Ad button
              Expanded(
                child: TactilePressable(
                  onTap: () {
                    showDialog(
                      context: context,
                      builder: (context) => RewardedAdDialog(
                        rewardType: AdRewardType.whoViewedMe,
                        onRewardGranted: () {
                          setState(() {
                            _isUnlockedByAd = true;
                          });
                        },
                      ),
                    );
                  },
                  pressedScale: 0.96,
                  child: Container(
                    padding: EdgeInsets.symmetric(vertical: 1.3.h),
                    decoration: BoxDecoration(
                      border: Border.all(color: theme.colorScheme.primary),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.play_circle_fill_rounded, size: 18, color: theme.colorScheme.primary),
                        SizedBox(width: 1.5.w),
                        Text(
                          l10n?.watchAdToUnlockAll ?? 'Watch Ad',
                          style: TextStyle(
                            fontSize: AppTypography.bodySmall,
                            fontWeight: AppTypography.bold,
                            color: theme.colorScheme.primary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              SizedBox(width: 3.w),
              // Go Pro button
              Expanded(
                child: TactilePressable(
                  onTap: () => Navigator.pushNamed(context, AppRoutes.subscription),
                  pressedScale: 0.96,
                  child: Container(
                    padding: EdgeInsets.symmetric(vertical: 1.3.h),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          theme.colorScheme.primary,
                          theme.colorScheme.primary.withValues(alpha: AppColors.opacity85),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: theme.colorScheme.primary.withValues(alpha: AppColors.opacity30),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.star_rounded, size: 18, color: Colors.white),
                        SizedBox(width: 1.5.w),
                        Text(
                          'Go Pro',
                          style: TextStyle(
                            fontSize: AppTypography.bodySmall,
                            fontWeight: AppTypography.extraBold,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Show upgrade prompt when user taps a blurred card
  void _showUpgradePrompt(ThemeData theme) {
    final l10n = AppLocalizations.of(context);
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: EdgeInsets.all(6.w),
        decoration: BoxDecoration(
          color: theme.cardColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: theme.colorScheme.onSurface.withValues(alpha: AppColors.opacity20),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            SizedBox(height: 3.h),
            Icon(
              Icons.visibility_rounded,
              size: 48,
              color: theme.colorScheme.primary,
            ),
            SizedBox(height: 2.h),
            Text(
              'Someone viewed your profile!',
              style: TextStyle(
                fontSize: AppTypography.headingSmall,
                fontWeight: AppTypography.extraBold,
                color: theme.colorScheme.onSurface,
              ),
            ),
            SizedBox(height: 1.h),
            Text(
              'Unlock to see who is interested in your profile. Watch a quick ad or upgrade to Pro.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: AppTypography.bodySmall,
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            SizedBox(height: 3.h),
            SizedBox(
              width: double.infinity,
              child: TactilePressable(
                onTap: () {
                  Navigator.pop(context);
                  showDialog(
                    context: context,
                    builder: (ctx) => RewardedAdDialog(
                      rewardType: AdRewardType.whoViewedMe,
                      onRewardGranted: () {
                        setState(() => _isUnlockedByAd = true);
                      },
                    ),
                  );
                },
                pressedScale: 0.96,
                child: Container(
                  padding: EdgeInsets.symmetric(vertical: 1.5.h),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary,
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: [
                      BoxShadow(
                        color: theme.colorScheme.primary.withValues(alpha: AppColors.opacity30),
                        blurRadius: 8,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.play_circle_fill_rounded, color: Colors.white, size: 20),
                      SizedBox(width: 2.w),
                      Text(
                        l10n?.watchAdToUnlockAll ?? 'Watch Ad to Unlock',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: AppTypography.bold,
                          fontSize: AppTypography.bodyMedium,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            SizedBox(height: 1.h),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, AppRoutes.subscription);
              },
              child: Text(
                l10n?.goProAdFree ?? 'Go Pro — Ad Free',
                style: TextStyle(
                  color: theme.colorScheme.primary,
                  fontWeight: AppTypography.bold,
                  fontSize: AppTypography.bodyMedium,
                ),
              ),
            ),
            SizedBox(height: 2.h),
          ],
        ),
      ),
    );
  }

  Widget _buildUnlockBanner(ThemeData theme, bool isDark) {
    final l10n = AppLocalizations.of(context);
    return Container(
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: isDark ? theme.cardColor : theme.colorScheme.primaryContainer,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.08),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            l10n?.unlockMoreVisitors(_views.length - 3) ?? 'Unlock more visitors',
            style: TextStyle(
              fontWeight: AppTypography.bold,
              fontSize: AppTypography.bodyMedium,
              color: isDark ? theme.colorScheme.onSurface : theme.colorScheme.onPrimaryContainer,
            ),
          ),
          SizedBox(height: 1.2.h),
          SizedBox(
            width: double.infinity,
            child: TactilePressable(
              onTap: () {
                showDialog(
                  context: context,
                  builder: (context) => RewardedAdDialog(
                    rewardType: AdRewardType.whoViewedMe,
                    onRewardGranted: () {
                      setState(() {
                        _isUnlockedByAd = true;
                      });
                    },
                  ),
                );
              },
              pressedScale: 0.96,
              child: Container(
                padding: EdgeInsets.symmetric(vertical: 1.4.h),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: theme.colorScheme.primary.withValues(alpha: AppColors.opacity30),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.play_circle_fill, color: Colors.white, size: 20),
                    SizedBox(width: 2.w),
                    Text(
                      l10n?.watchAdToUnlockAll ?? 'Watch Ad to Unlock All',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: AppTypography.bold,
                        fontSize: AppTypography.bodyMedium,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          SizedBox(height: 0.5.h),
          TextButton(
            onPressed: () => Navigator.pushNamed(context, AppRoutes.subscription),
            child: Text(
              l10n?.goProAdFree ?? 'Go Pro — Ad Free',
              style: TextStyle(
                color: theme.colorScheme.primary,
                fontWeight: AppTypography.bold,
                fontSize: AppTypography.bodySmall,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildViewCard(ThemeData theme, ProfileViewModel view, bool isDark) {
    final relativeTime = _relativeTime(view.lastViewedAt);

    return TactilePressable(
      onTap: () {
        Navigator.pushNamed(
          context,
          AppRoutes.profileDetail,
          arguments: view.viewerId,
        );
      },
      pressedScale: 0.97,
      child: Container(
        margin: EdgeInsets.only(bottom: 1.5.h),
        padding: EdgeInsets.all(3.w),
        decoration: BoxDecoration(
          color: theme.cardColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isDark
                ? Colors.white.withValues(alpha: AppColors.opacity8)
                : theme.colorScheme.outlineVariant.withValues(alpha: AppColors.opacity20),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: isDark ? 0.15 : 0.03),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            // Avatar with gradient border
            Container(
              width: 14.w,
              height: 14.w,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                gradient: AppGradients.romance,
              ),
              padding: const EdgeInsets.all(2),
              child: ClipOval(
                child: CustomImageWidget(
                  imageUrl: view.viewerImageUrl ?? '',
                  fit: BoxFit.cover,
                ),
              ),
            ),

            SizedBox(width: 3.w),

            // Name and details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    view.viewerName ?? AppLocalizations.of(context)?.someone ?? '',
                    style: TextStyle(
                      fontWeight: AppTypography.bold,
                      fontSize: AppTypography.bodyMedium,
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                  SizedBox(height: 0.3.h),
                  Row(
                    children: [
                      Icon(
                        Icons.visibility,
                        size: 12,
                        color: theme.colorScheme.primary,
                      ),
                      SizedBox(width: 1.w),
                      Text(
                        '${view.viewCount} ${view.viewCount == 1 ? (AppLocalizations.of(context)?.viewLabel ?? "") : (AppLocalizations.of(context)?.viewsLabel ?? "")}',
                        style: TextStyle(
                          fontSize: AppTypography.labelMedium,
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Relative time + arrow
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  relativeTime,
                  style: TextStyle(
                    fontSize: AppTypography.labelSmall,
                    color: theme.colorScheme.onSurfaceVariant,
                    fontWeight: AppTypography.medium,
                  ),
                ),
                SizedBox(height: 0.5.h),
                Icon(
                  Icons.chevron_right,
                  color: theme.colorScheme.primary,
                  size: 20,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(ThemeData theme) {
    final l10n = AppLocalizations.of(context);
    return BrandedEmptyState(
      icon: Icons.visibility_off_rounded,
      title: l10n?.noViewsYet ?? 'No Profile Views Yet',
      description: l10n?.completeYourProfileToGetNoticed ??
          'Complete your biodata, add a verified photo, and boost your trust score to get noticed by potential matches!',
      ctaText: 'Explore Matches',
      onCtaPressed: () {
        ref.read(homeTabProvider.notifier).state = 0;
        Navigator.popUntil(context, (route) => route.isFirst);
      },
    );
  }

  String _relativeTime(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);

    if (diff.inMinutes < 1) return AppLocalizations.of(context)?.justNow ?? '';
    if (diff.inMinutes < 60) return AppLocalizations.of(context)?.minutesAgo(diff.inMinutes) ?? '';
    if (diff.inHours < 24) return AppLocalizations.of(context)?.hoursAgo(diff.inHours) ?? '';
    if (diff.inDays == 1) return AppLocalizations.of(context)?.yesterday ?? '';
    if (diff.inDays < 7) return AppLocalizations.of(context)?.daysAgo(diff.inDays) ?? '';
    return '${date.day}/${date.month}/${date.year}';
  }
}

/// Animates each timeline entry: slide-in from left + fade + timeline connector.
class _AnimatedTimelineEntry extends StatefulWidget {
  final int index;
  final bool isLast;
  final Widget child;

  const _AnimatedTimelineEntry({
    required this.index,
    required this.isLast,
    required this.child,
  });

  @override
  State<_AnimatedTimelineEntry> createState() => _AnimatedTimelineEntryState();
}

class _AnimatedTimelineEntryState extends State<_AnimatedTimelineEntry>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _slideAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );

    _slideAnimation = Tween<double>(begin: -30, end: 0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic),
    );

    _fadeAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );

    // Stagger animation by index
    Future.delayed(Duration(milliseconds: widget.index * 80), () {
      if (mounted) _controller.forward();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(_slideAnimation.value, 0),
          child: Opacity(
            opacity: _fadeAnimation.value,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Timeline connector
                SizedBox(
                  width: 6.w,
                  child: Column(
                    children: [
                      // Dot
                      Container(
                        width: 10,
                        height: 10,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: AppGradients.primary,
                          boxShadow: [
                            BoxShadow(
                              color: theme.colorScheme.primary
                                  .withValues(alpha: AppColors.opacity30),
                              blurRadius: 4,
                            ),
                          ],
                        ),
                      ),
                      // Line
                      if (!widget.isLast)
                        Container(
                          width: 2,
                          height: 10.h,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                theme.colorScheme.primary,
                                theme.colorScheme.primary
                                    .withValues(alpha: AppColors.opacity10),
                              ],
                            ),
                          ),
                        ),
                    ],
                  ),
                ),

                // Card
                Expanded(child: widget.child),
              ],
            ),
          ),
        );
      },
    );
  }
}
