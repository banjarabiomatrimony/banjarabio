import 'package:flutter/material.dart';
import 'package:banjarabio/l10n/app_localizations.dart';
import 'package:sizer/sizer.dart';

import 'package:banjarabio/core/app_export.dart';
import 'package:banjarabio/core/constants/app_typography.dart';

/// Upgrade dialog to show when free users hit feature limits
class UpgradeDialog extends StatelessWidget {
  final String title;
  final String message;
  final String featureName;
  final int? currentUsage;
  final int? limit;

  const UpgradeDialog({
    super.key,
    required this.title,
    required this.message,
    required this.featureName,
    this.currentUsage,
    this.limit,
  });

  /// Show profile view limit dialog
  static Future<void> showProfileViewLimit(
    BuildContext context,
    int remaining,
  ) {
    return showDialog(
      context: context,
      builder: (ctx) => UpgradeDialog(
        title: AppLocalizations.of(context)?.profileViewLimitReached ?? 'Profile View Limit Reached',
        message:
            'You have used your daily limit of profile views. Upgrade to premium for unlimited browsing!',
        featureName: 'profile views',
        currentUsage: 10 - remaining,
        limit: 10,
      ),
    );
  }

  /// Show share limit dialog
  static Future<void> showShareLimit(BuildContext context, int remaining) {
    return showDialog(
      context: context,
      builder: (ctx) => UpgradeDialog(
        title: AppLocalizations.of(context)?.shareLimitReached ?? 'Share Limit Reached',
        message:
            'You have used your monthly share limit. Upgrade to premium for unlimited profile sharing!',
        featureName: 'shares this month',
        currentUsage: 3 - remaining,
        limit: 3,
      ),
    );
  }

  /// Show bookmark limit dialog
  static Future<void> showBookmarkLimit(BuildContext context, int remaining) {
    return showDialog(
      context: context,
      builder: (ctx) => UpgradeDialog(
        title: AppLocalizations.of(context)?.bookmarkLimitReached ?? 'Bookmark Limit Reached',
        message:
            'You have reached your bookmark limit. Upgrade to premium for unlimited saved profiles!',
        featureName: 'bookmarks',
        currentUsage: 5 - remaining,
        limit: 5,
      ),
    );
  }

  /// Show photo upload limit dialog
  static Future<void> showPhotoLimit(
    BuildContext context,
    int remaining,
    int limit,
  ) {
    return showDialog(
      context: context,
      builder: (ctx) => UpgradeDialog(
        title: AppLocalizations.of(context)?.photoLimitReached ?? 'Photo Limit Reached',
        message:
            'You have reached your photo limit. Upgrade to premium for more photo uploads!',
        featureName: 'photos',
        currentUsage: limit - remaining,
        limit: limit,
      ),
    );
  }

  /// Show messaging limit dialog
  static Future<void> showMessagingLimit(BuildContext context) {
    return showDialog(
      context: context,
      builder: (ctx) => UpgradeDialog(
        title: AppLocalizations.of(context)?.messagingLimitReached ?? 'Messaging Limit Reached',
        message:
            'You can only send 1 message on the free plan. Upgrade to premium for unlimited chatting!',
        featureName: 'messages',
        currentUsage: 1,
        limit: 1,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: EdgeInsets.all(5.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Premium icon
            Container(
              width: 20.w,
              height: 20.w,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    theme.colorScheme.primary,
                    theme.colorScheme.primary.withValues(alpha: 0.7),
                  ],
                ),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: CustomIconWidget(
                  iconName: 'workspace_premium',
                  color: Colors.white,
                  size: 10.w,
                ),
              ),
            ),

            SizedBox(height: 3.h),

            // Title
            Text(
              title,
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),

            SizedBox(height: 2.h),

            // Usage indicator
            if (currentUsage != null && limit != null) ...[
              Container(
                padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.5.h),
                decoration: BoxDecoration(
                  color: theme.colorScheme.error.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CustomIconWidget(
                      iconName: 'error_outline',
                      color: theme.colorScheme.error,
                      size: 20,
                    ),
                    SizedBox(width: 2.w),
                    Text(
                      '$currentUsage / $limit $featureName used',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.error,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 2.h),
            ],

            // Message
            Text(
              message,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),

            SizedBox(height: 3.h),

            // Premium benefits
            _buildBenefitItem(theme, 'Unlimited profile views'),
            _buildBenefitItem(theme, 'Unlimited sharing'),
            _buildBenefitItem(theme, 'More photos'),
            _buildBenefitItem(theme, 'Direct messaging'),

            SizedBox(height: 3.h),

            // Upgrade button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.pushNamed(context, AppRoutes.subscription);
                },
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: 2.h),
                ),
                child: Text(AppLocalizations.of(context)?.upgradeToPremium ?? 'Upgrade to Premium',
                  style: TextStyle(fontSize: AppTypography.bodyMedium, fontWeight: FontWeight.bold),
                ),
              ),
            ),

            SizedBox(height: 1.5.h),

            // Close button
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(AppLocalizations.of(context)?.maybeLater ?? 'Maybe Later',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBenefitItem(ThemeData theme, String text) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 0.5.h),
      child: Row(
        children: [
          CustomIconWidget(
            iconName: 'check_circle',
            color: theme.colorScheme.primary,
            size: 20,
          ),
          SizedBox(width: 2.w),
          Text(text, style: theme.textTheme.bodyMedium),
        ],
      ),
    );
  }
}

/// Subscription badge widget to display in profile
class SubscriptionBadge extends StatelessWidget {
  final String planType;
  final bool isSmall;

  const SubscriptionBadge({
    super.key,
    required this.planType,
    this.isSmall = false,
  });

  @override
  Widget build(BuildContext context) {
    if (planType.toLowerCase() == 'free') {
      return const SizedBox.shrink();
    }

    Color badgeColor;
    String displayText;

    switch (planType.toLowerCase()) {
      case 'silver':
      case 'standard':
        badgeColor = Colors.grey.shade400;
        displayText = planType.toUpperCase();
        break;
      case 'gold':
        badgeColor = Colors.amber;
        displayText = 'GOLD';
        break;
      case 'platinum':
      case 'eternal':
        badgeColor = Colors.blue.shade300;
        displayText = planType.toUpperCase();
        break;
      case 'elite':
      case 'royal':
      case 'eternal_elite':
        badgeColor = Colors.deepPurple;
        displayText = planType.replaceAll('_', ' ').toUpperCase();
        break;
      default:
        return const SizedBox.shrink();
    }

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isSmall ? 2.w : 3.w,
        vertical: isSmall ? 0.3.h : 0.5.h,
      ),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [badgeColor, badgeColor.withValues(alpha: 0.7)],
        ),
        borderRadius: BorderRadius.circular(isSmall ? 4 : 8),
        boxShadow: [
          BoxShadow(
            color: badgeColor.withValues(alpha: 0.3),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          CustomIconWidget(
            iconName: 'workspace_premium',
            color: Colors.white,
            size: isSmall ? 12 : 16,
          ),
          SizedBox(width: isSmall ? 1.w : 1.5.w),
          Text(
            displayText,
            style: TextStyle(
              color: Colors.white,
              fontSize: isSmall ? 10 : 12,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }
}

/// Remaining limits indicator widget
class RemainingLimitsWidget extends StatelessWidget {
  final int profileViews;
  final int shares;
  final int bookmarks;
  final bool isCompact;

  const RemainingLimitsWidget({
    super.key,
    required this.profileViews,
    required this.shares,
    required this.bookmarks,
    this.isCompact = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (isCompact) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildCompactItem(theme, 'views_left', profileViews),
          SizedBox(width: 3.w),
          _buildCompactItem(theme, 'share', shares),
          SizedBox(width: 3.w),
          _buildCompactItem(theme, 'bookmark', bookmarks),
        ],
      );
    }

    return Container(
      padding: EdgeInsets.all(3.w),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: theme.dividerColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(AppLocalizations.of(context)?.remainingToday ?? 'Remaining Today',
            style: theme.textTheme.labelMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          SizedBox(height: 1.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildLimitItem(
                theme,
                'Views',
                profileViews,
                10,
                Icons.visibility,
              ),
              _buildLimitItem(theme, 'Shares', shares, 3, Icons.share),
              _buildLimitItem(theme, 'Saved', bookmarks, 5, Icons.bookmark),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCompactItem(ThemeData theme, String icon, int remaining) {
    final isLow = remaining <= 2;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        CustomIconWidget(
          iconName: icon == 'views_left' ? 'visibility' : icon,
          color: isLow
              ? theme.colorScheme.error
              : theme.colorScheme.onSurfaceVariant,
          size: 14,
        ),
        SizedBox(width: 1.w),
        Text(
          remaining >= 999 ? '∞' : '$remaining',
          style: TextStyle(
            fontSize: AppTypography.bodySmall,
            fontWeight: FontWeight.w600,
            color: isLow
                ? theme.colorScheme.error
                : theme.colorScheme.onSurface,
          ),
        ),
      ],
    );
  }

  Widget _buildLimitItem(
    ThemeData theme,
    String label,
    int remaining,
    int max,
    IconData icon,
  ) {
    final isLow = remaining <= 2;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          icon,
          color: isLow ? theme.colorScheme.error : theme.colorScheme.primary,
          size: 24,
        ),
        SizedBox(height: 0.5.h),
        Text(
          remaining >= 999 ? '∞' : '$remaining',
          style: TextStyle(
            fontSize: AppTypography.bodyMedium,
            fontWeight: FontWeight.bold,
            color: isLow
                ? theme.colorScheme.error
                : theme.colorScheme.onSurface,
          ),
        ),
        Text(
          label,
          style: theme.textTheme.labelSmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}
