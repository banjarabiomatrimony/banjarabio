import 'package:flutter/material.dart';
import 'package:banjarabio/l10n/app_localizations.dart';
import 'package:intl/intl.dart';
import 'package:sizer/sizer.dart';

import 'package:banjarabio/core/app_export.dart';

/// Individual sharing card widget with swipe actions and selection support
/// Redesigned for a "premium" and "vibrant" look
class SharedProfileCardWidget extends StatelessWidget {
  final Map<String, dynamic> profile;
  final bool isSharedByMe;
  final bool isSelected;
  final bool isSelectionMode;
  final VoidCallback onTap;
  final VoidCallback onLongPress;
  final VoidCallback onReshare;
  final VoidCallback onRemove;

  const SharedProfileCardWidget({
    super.key,
    required this.profile,
    required this.isSharedByMe,
    required this.isSelected,
    required this.isSelectionMode,
    required this.onTap,
    required this.onLongPress,
    required this.onReshare,
    required this.onRemove,
  });

  String _formatTimestamp(BuildContext context, DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);
    final l10n = AppLocalizations.of(context);

    if (difference.inHours < 24) {
      if (difference.inHours == 0) {
        return l10n?.minutesAgo(difference.inMinutes.toString()) ??
            '${difference.inMinutes}m ago';
      }
      return l10n?.hoursAgo(difference.inHours.toString()) ??
          '${difference.inHours}h ago';
    } else if (difference.inDays < 7) {
      return l10n?.daysAgo(difference.inDays.toString()) ??
          '${difference.inDays}d ago';
    } else {
      return DateFormat('dd MMM yyyy').format(timestamp);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final contactName =
        (isSharedByMe ? profile['recipientName'] : profile['senderName'])
            ?.toString() ??
        (l10n?.notAvailable ?? 'N/A');
    final contactRelation =
        (isSharedByMe
                ? profile['recipientRelation']
                : profile['senderRelation'])
            ?.toString() ??
        (l10n?.contactLabel ?? 'Contact');
    final profileName = profile['sharedProfileName']?.toString() ??
        (l10n?.notAvailable ?? 'N/A');
    final profileAge = (profile['sharedProfileAge'] as num?)?.toInt() ?? 0;
    final profileImage = profile['sharedProfileImage']?.toString() ?? '';
    final timestamp = profile['timestamp'] as DateTime? ?? DateTime.now();
    final status = profile['status']?.toString() ?? (l10n?.pending ?? 'Pending');
    final viewCount = (profile['viewCount'] as num?)?.toInt() ?? 0;
    final isMatched = status.toLowerCase() == 'matched';
    final isPremium = profile['isPremium'] as bool? ?? false;

    return GestureDetector(
      onTap: onTap,
      onLongPress: onLongPress,
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: isSelected
                ? theme.colorScheme.primary
                : isMatched
                ? const Color(0xFFFF416C).withValues(alpha: 0.2)
                : theme.colorScheme.outlineVariant.withValues(alpha: 0.3),
            width: isSelected || isMatched ? 1.5 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 15,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header: Share Metadata (To/From/Timestamp)
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.2.h),
                child: Row(
                  children: [
                    if (isSelectionMode)
                      Padding(
                        padding: EdgeInsets.only(right: 3.w),
                        child: Icon(
                          isSelected
                              ? Icons.check_circle
                              : Icons.radio_button_unchecked,
                          color: isSelected
                              ? theme.colorScheme.primary
                              : theme.colorScheme.onSurfaceVariant,
                          size: 20,
                        ),
                      ),
                    CircleAvatar(
                      radius: 12,
                      backgroundColor:
                          (isMatched
                                  ? const Color(0xFFFF416C)
                                  : theme.colorScheme.primary)
                              .withValues(alpha: 0.1),
                      child: Icon(
                        isMatched
                            ? Icons.favorite
                            : (isSharedByMe
                                  ? Icons.arrow_upward
                                  : Icons.arrow_downward),
                        size: 12,
                        color: isMatched
                            ? const Color(0xFFFF416C)
                            : theme.colorScheme.primary,
                      ),
                    ),
                    SizedBox(width: 2.w),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            isMatched
                                ? (l10n?.mutualMatch ?? 'Mutual Match')
                                : (isSharedByMe
                                    ? (l10n?.toContact(contactName) ??
                                        'To: $contactName')
                                    : (l10n?.fromContact(contactName) ??
                                        'From: $contactName')),
                            style: theme.textTheme.labelSmall?.copyWith(
                              fontWeight: FontWeight.w900,
                              color: isMatched
                                  ? const Color(0xFFFF416C)
                                  : theme.colorScheme.onSurface,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            contactRelation,
                            style: theme.textTheme.bodySmall?.copyWith(
                              fontSize: 7.sp,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Text(
                      _formatTimestamp(context, timestamp),
                      style:
                          theme.textTheme.bodySmall?.copyWith(fontSize: 7.sp),
                    ),
                  ],
                ),
              ),

              // Profile Image with Badges
              Stack(
                children: [
                  CustomImageWidget(
                    imageUrl: profileImage,
                    width: double.infinity,
                    height: 25.h,
                    fit: BoxFit.cover,
                  ),
                  // Bottom Gradient
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    height: 8.h,
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.transparent,
                            Colors.black.withValues(alpha: 0.6),
                          ],
                        ),
                      ),
                    ),
                  ),
                  // Matched Badge
                  if (isMatched)
                    Positioned(
                      top: 1.5.h,
                      left: 3.w,
                      child: _buildBadge(
                          l10n?.matchedBadge ?? 'MATCHED',
                          [
                            const Color(0xFFFF4B2B),
                            const Color(0xFFFF416C),
                          ],
                          Icons.favorite),
                    ),
                  // Premium Badge
                  if (isPremium)
                    Positioned(
                      top: 1.5.h,
                      right: 3.w,
                      child: _buildBadge(
                          l10n?.premiumBadge ?? 'PREMIUM',
                          [
                            const Color(0xFFFFD700),
                            const Color(0xFFFFA500),
                          ],
                          Icons.star),
                    ),
                  // Name Overlay
                  Positioned(
                    bottom: 1.h,
                    left: 4.w,
                    child: Text(
                      '$profileName, ${l10n?.yrs(profileAge) ?? "$profileAge Yrs"}',
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w900,
                        shadows: [
                          const Shadow(color: Colors.black45, blurRadius: 4),
                        ],
                      ),
                    ),
                  ),
                ],
              ),

              // Detail Section
              Padding(
                padding: EdgeInsets.all(4.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Wrap(
                      spacing: 3.w,
                      runSpacing: 1.h,
                      children: [
                        _buildTinyTag(
                          context,
                          'school',
                          profile['education']?.toString() ??
                              (l10n?.notAvailable ?? 'N/A'),
                        ),
                        _buildTinyTag(
                          context,
                          'work',
                          profile['job']?.toString() ??
                              (l10n?.notAvailable ?? 'N/A'),
                        ),
                        _buildTinyTag(
                          context,
                          'straighten',
                          profile['height']?.toString() ??
                              (l10n?.notAvailable ?? 'N/A'),
                        ),
                        _buildTinyTag(
                          context,
                          'family_restroom',
                          profile['maritalStatus']?.toString() ??
                              (l10n?.notAvailable ?? 'N/A'),
                        ),
                      ],
                    ),
                    if (viewCount > 0) ...[
                      SizedBox(height: 1.h),
                      Row(
                        children: [
                          Icon(
                            Icons.visibility_outlined,
                            size: 12,
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                          SizedBox(width: 1.w),
                          Text(
                            l10n?.countProfileViews(viewCount) ??
                                '$viewCount profile views',
                            style: theme.textTheme.bodySmall?.copyWith(
                              fontSize: 8.sp,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),

              // Action Bar
              Container(
                height: 6.h,
                decoration: BoxDecoration(
                  border: Border(
                    top: BorderSide(
                      color: isMatched
                          ? const Color(0xFFFF416C).withValues(alpha: 0.2)
                          : theme.colorScheme.outlineVariant.withValues(
                              alpha: 0.3,
                            ),
                    ),
                  ),
                ),
                child: Row(
                  children: [
                    _buildFullWidthAction(
                      label: AppLocalizations.of(context)?.view ?? 'VIEW',
                      icon: Icons.visibility,
                      color: theme.colorScheme.primary,
                      onTap: onTap,
                    ),
                    const VerticalDivider(width: 1, color: Colors.white24),
                    _buildFullWidthAction(
                      label: AppLocalizations.of(context)?.reshare ?? 'RESHARE',
                      icon: Icons.share,
                      color: const Color(0xFF6B48FF),
                      onTap: onReshare,
                    ),
                    const VerticalDivider(width: 1, color: Colors.white24),
                    _buildFullWidthAction(
                      label: AppLocalizations.of(context)?.remove ?? 'REMOVE',
                      icon: Icons.delete_outline,
                      color: theme.colorScheme.error,
                      onTap: onRemove,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFullWidthAction({
    required String label,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        child: Container(
          color: color,
          alignment: Alignment.center,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: Colors.white, size: 16),
              SizedBox(width: 1.5.w),
              Text(
                label,
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w900,
                  fontSize: 8.sp,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBadge(String text, List<Color> colors, IconData icon) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 0.4.h),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: colors),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(color: colors.last.withValues(alpha: 0.3), blurRadius: 4),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.white, size: 10),
          SizedBox(width: 1.w),
          Text(
            text,
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w900,
              fontSize: 6.sp,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTinyTag(BuildContext context, String icon, String text) {
    final theme = Theme.of(context);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        CustomIconWidget(
          iconName: icon,
          color: theme.colorScheme.primary,
          size: 14,
        ),
        SizedBox(width: 1.5.w),
        Text(
          text,
          style: theme.textTheme.bodySmall?.copyWith(
            fontWeight: FontWeight.w600,
            fontSize: 8.sp,
          ),
        ),
      ],
    );
  }
}
