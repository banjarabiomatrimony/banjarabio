import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:banjarabio/l10n/app_localizations.dart';
import 'package:sizer/sizer.dart';
import 'package:banjarabio/core/app_export.dart';
import 'package:banjarabio/core/models/chat_model.dart';
import 'package:banjarabio/core/repositories/chat_repository.dart';
import 'package:banjarabio/core/theme/app_gradients.dart';
import 'package:banjarabio/presentation/widgets/rewarded_ad_dialog.dart';
import 'package:banjarabio/core/services/ad_reward_service.dart';
import 'package:banjarabio/core/services/app_logger.dart';
import 'package:banjarabio/core/constants/app_typography.dart';

class WhoViewedMeScreen extends StatefulWidget {
  const WhoViewedMeScreen({super.key});

  @override
  State<WhoViewedMeScreen> createState() => _WhoViewedMeScreenState();
}

class _WhoViewedMeScreenState extends State<WhoViewedMeScreen> {
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

    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)?.whoViewedMe ?? '',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            letterSpacing: 1.2,
            fontSize: AppTypography.bodyLarge,
          ),
        ),
        centerTitle: true,
      ),
      body: _isLoading
          ? _buildLoadingState(theme)
          : _views.isEmpty
              ? _buildEmptyState(theme)
              : _buildTimelineList(theme),
      bottomNavigationBar: (!SessionManager.instance.isPremium && !_isUnlockedByAd && _views.length > 3)
          ? _buildUnlockBanner(theme)
          : null,
    );
  }

  Widget _buildLoadingState(ThemeData theme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: 40,
            height: 40,
            child: CircularProgressIndicator(
              strokeWidth: 3,
              color: theme.colorScheme.primary,
            ),
          ),
          SizedBox(height: 2.h),
          Text(AppLocalizations.of(context)?.loadingViews ?? '',
            style: TextStyle(
              color: theme.colorScheme.onSurfaceVariant,
              fontSize: AppTypography.bodySmall,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimelineList(ThemeData theme) {
    final bool isPremium = SessionManager.instance.isPremium;
    final bool isFullyUnlocked = isPremium || _isUnlockedByAd;
    // Show first 3 items clearly, then blurred tease cards
    final int clearCount = _views.length > 3 ? 3 : _views.length;
    final int blurredCount = isFullyUnlocked ? 0 : (_views.length - clearCount).clamp(0, 4);
    final int totalItems = isFullyUnlocked 
        ? _views.length 
        : clearCount + (blurredCount > 0 ? blurredCount + 1 : 0); // +1 for CTA card

    return ListView.builder(
      padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
      itemCount: totalItems,
      itemBuilder: (context, index) {
        // Clear items
        if (index < clearCount || isFullyUnlocked) {
          final viewIndex = index;
          if (viewIndex >= _views.length) return const SizedBox.shrink();
          final view = _views[viewIndex];
          return _AnimatedTimelineEntry(
            index: index,
            isLast: index == totalItems - 1,
            child: _buildViewCard(theme, view),
          );
        }

        // CTA card inserted after blurred items
        if (index == clearCount + blurredCount) {
          return _buildPremiumTeaseCard(theme);
        }

        // Blurred tease cards
        final blurIndex = clearCount + (index - clearCount);
        if (blurIndex < _views.length) {
          final view = _views[blurIndex];
          return _AnimatedTimelineEntry(
            index: index,
            isLast: false,
            child: _buildBlurredViewCard(theme, view),
          );
        }
        return const SizedBox.shrink();
      },
    );
  }

  /// 🔒 Blurred tease card — shows profile with blur overlay + lock icon
  Widget _buildBlurredViewCard(ThemeData theme, ProfileViewModel view) {
    // Mask the name: show first 2 chars + asterisks
    final maskedName = (view.viewerName ?? 'Someone');
    final displayName = maskedName.length > 2
        ? '${maskedName.substring(0, 2)}${'•' * (maskedName.length - 2)}'
        : maskedName;

    return GestureDetector(
      onTap: () => _showUpgradePrompt(theme),
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
                    color: theme.colorScheme.surface,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: theme.colorScheme.outlineVariant.withValues(alpha: 0.2),
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
                                fontWeight: FontWeight.bold,
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
                    color: theme.colorScheme.surface.withValues(alpha: 0.3),
                  ),
                  child: Center(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primary.withValues(alpha: 0.9),
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
                              fontWeight: FontWeight.w700,
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
  Widget _buildPremiumTeaseCard(ThemeData theme) {
    final hiddenCount = _views.length - 3;
    final l10n = AppLocalizations.of(context);

    return Container(
      margin: EdgeInsets.symmetric(vertical: 2.h),
      padding: EdgeInsets.all(5.w),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            theme.colorScheme.primary.withValues(alpha: 0.12),
            theme.colorScheme.primary.withValues(alpha: 0.04),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: theme.colorScheme.primary.withValues(alpha: 0.3),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.primary.withValues(alpha: 0.1),
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
                  theme.colorScheme.primary.withValues(alpha: 0.7),
                ],
              ),
              boxShadow: [
                BoxShadow(
                  color: theme.colorScheme.primary.withValues(alpha: 0.3),
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
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
          ),
          SizedBox(height: 1.5.h),
          Text(
            '$hiddenCount more people viewed your profile',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontWeight: FontWeight.w700,
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
                child: OutlinedButton.icon(
                  onPressed: () {
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
                  icon: const Icon(Icons.play_circle_fill_rounded, size: 18),
                  label: Text(
                    l10n?.watchAdToUnlockAll ?? 'Watch Ad',
                    style: TextStyle(
                      fontSize: AppTypography.bodySmall,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: theme.colorScheme.primary,
                    side: BorderSide(color: theme.colorScheme.primary),
                    padding: EdgeInsets.symmetric(vertical: 1.2.h),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
              SizedBox(width: 3.w),
              // Go Pro button
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () =>
                      Navigator.pushNamed(context, AppRoutes.subscription),
                  icon: const Icon(Icons.star_rounded, size: 18),
                  label: Text(
                    'Go Pro',
                    style: TextStyle(
                      fontSize: AppTypography.bodySmall,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: theme.colorScheme.primary,
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(vertical: 1.2.h),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 4,
                    shadowColor: theme.colorScheme.primary.withValues(alpha: 0.3),
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
          color: theme.colorScheme.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.2),
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
                fontWeight: FontWeight.w800,
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
              child: ElevatedButton.icon(
                onPressed: () {
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
                icon: const Icon(Icons.play_circle_fill_rounded),
                label: Text(l10n?.watchAdToUnlockAll ?? 'Watch Ad to Unlock'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: theme.colorScheme.primary,
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(vertical: 1.5.h),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
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
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            SizedBox(height: 2.h),
          ],
        ),
      ),
    );
  }

  Widget _buildUnlockBanner(ThemeData theme) {
    final l10n = AppLocalizations.of(context);
    return Container(
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: theme.colorScheme.primaryContainer,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            l10n?.unlockMoreVisitors(_views.length - 3) ?? '',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: AppTypography.bodyMedium,
              color: theme.colorScheme.onPrimaryContainer,
            ),
          ),
          SizedBox(height: 1.h),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () {
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
              icon: const Icon(Icons.play_circle_fill),
              label: Text(l10n?.watchAdToUnlockAll ?? ''),
              style: ElevatedButton.styleFrom(
                backgroundColor: theme.colorScheme.primary,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(vertical: 1.5.h),
              ),
            ),
          ),
          TextButton(
            onPressed: () =>
                Navigator.pushNamed(context, AppRoutes.subscription),
            child: Text(l10n?.goProAdFree ?? ''),
          ),
        ],
      ),
    );
  }

  Widget _buildViewCard(ThemeData theme, ProfileViewModel view) {
    final relativeTime = _relativeTime(view.lastViewedAt);

    return GestureDetector(
      onTap: () {
        Navigator.pushNamed(
          context,
          AppRoutes.profileDetail,
          arguments: view.viewerId,
        );
      },
      child: Container(
        margin: EdgeInsets.only(bottom: 1.5.h),
        padding: EdgeInsets.all(3.w),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: theme.colorScheme.outlineVariant.withValues(alpha: 0.2),
          ),
          boxShadow: [
            BoxShadow(
              color: theme.colorScheme.shadow.withValues(alpha: 0.05),
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
                      fontWeight: FontWeight.bold,
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
                    fontWeight: FontWeight.w500,
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
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 25.w,
            height: 25.w,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: theme.colorScheme.primary.withValues(alpha: 0.08),
            ),
            child: Icon(
              Icons.visibility_off_outlined,
              size: 40.sp,
              color: theme.colorScheme.primary.withValues(alpha: 0.4),
            ),
          ),
          SizedBox(height: 3.h),
          Text(AppLocalizations.of(context)?.noViewsYet ?? '',
            style: TextStyle(
              fontSize: AppTypography.bodyLarge,
              color: theme.colorScheme.onSurface,
              fontWeight: FontWeight.w700,
            ),
          ),
          SizedBox(height: 1.h),
          Text(AppLocalizations.of(context)?.completeYourProfileToGetNoticed ?? '',
            style: TextStyle(
              fontSize: AppTypography.bodySmall,
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
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
                                  .withValues(alpha: 0.3),
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
                                    .withValues(alpha: 0.1),
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
