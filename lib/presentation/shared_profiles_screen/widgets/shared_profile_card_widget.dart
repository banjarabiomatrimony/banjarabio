import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:banjarabio/l10n/app_localizations.dart';
import 'package:intl/intl.dart';
import 'package:sizer/sizer.dart';

import 'package:banjarabio/core/app_export.dart';
import 'package:banjarabio/widgets/tactile/tactile_pressable.dart';

/// Individual sharing card widget with modern floating actions and selection support
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
        return l10n?.minutesAgo(difference.inMinutes) ??
            '${difference.inMinutes}m ago';
      }
      return l10n?.hoursAgo(difference.inHours) ??
          '${difference.inHours}h ago';
    } else if (difference.inDays < 7) {
      return l10n?.daysAgo(difference.inDays) ??
          '${difference.inDays}d ago';
    } else {
      return DateFormat('dd MMM yyyy').format(timestamp);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

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

    // Dynamic Tab-Matching Border & Glow Colors
    final Color cardBorderColor;
    final Color cardShadowColor;
    if (isSelected) {
      cardBorderColor = AppColors.crimsonRose;
      cardShadowColor = AppColors.crimsonRose.withValues(alpha: isDark ? 0.35 : 0.2);
    } else if (isMatched) {
      // 💍 Matched Tab: Sacred 24K Gold
      cardBorderColor = AppColors.categoryAstro.withValues(alpha: isDark ? 0.55 : 0.45);
      cardShadowColor = AppColors.categoryAstro.withValues(alpha: isDark ? 0.22 : 0.09);
    } else if (isSharedByMe) {
      // 📤 Sent Tab: Royal Amethyst Purple
      cardBorderColor = AppColors.categoryFamilyDark.withValues(alpha: isDark ? 0.45 : 0.35);
      cardShadowColor = AppColors.categoryFamilyDark.withValues(alpha: isDark ? 0.18 : 0.07);
    } else {
      // 📥 Received Tab: Trust Sapphire Blue
      cardBorderColor = AppColors.categoryCareerDark.withValues(alpha: isDark ? 0.45 : 0.35);
      cardShadowColor = AppColors.categoryCareerDark.withValues(alpha: isDark ? 0.18 : 0.07);
    }

    return Semantics(
      label: "Shared profile card of $profileName, age $profileAge. ${isSharedByMe ? 'Shared to' : 'Shared from'} $contactName.",
      hint: 'Double tap to view details.',
      child: TactilePressable(
        onTap: isSelectionMode ? onTap : onTap,
        onLongPress: onLongPress,
        pressedScale: 0.98,
        child: Container(
            margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
            decoration: BoxDecoration(
              color: isDark ? AppColors.canvasNearBlack : Colors.white,
              borderRadius: BorderRadius.circular(22),
              border: Border.all(
                color: cardBorderColor,
                width: (isSelected || isMatched) ? 1.5 : 1.3,
              ),
              boxShadow: [
                BoxShadow(
                  color: cardShadowColor,
                  blurRadius: 16,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: ClipRRect(
            borderRadius: BorderRadius.circular(22),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                // Header: Share Metadata (To/From/Timestamp)
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
                  child: Row(
                    children: [
                      if (isSelectionMode)
                        Padding(
                          padding: EdgeInsets.only(right: 2.5.w),
                          child: Icon(
                            isSelected
                                ? Icons.check_circle_rounded
                                : Icons.radio_button_unchecked_rounded,
                            color: isSelected
                                ? AppColors.crimsonRose
                                : (isDark ? Colors.white38 : Colors.black38),
                            size: 20,
                          ),
                        ),
                      Container(
                        padding: const EdgeInsets.all(5.5),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: isMatched
                              ? AppColors.crimsonRose.withValues(alpha: AppColors.opacity15)
                              : (isDark ? Colors.white10 : AppColors.infoLight),
                        ),
                        child: Icon(
                          isMatched
                              ? Icons.favorite_rounded
                              : (isSharedByMe
                                  ? Icons.arrow_outward_rounded
                                  : Icons.call_received_rounded),
                          size: 13,
                          color: isMatched
                              ? AppColors.crimsonRose
                              : (isDark ? AppColors.blue400 : AppColors.categoryCareerDark),
                        ),
                      ),
                      SizedBox(width: 2.5.w),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              isMatched
                                  ? (l10n?.mutualMatch ?? 'Mutual Match 💍')
                                  : (isSharedByMe
                                      ? (l10n?.toContact(contactName) ?? 'To: $contactName')
                                      : (l10n?.fromContact(contactName) ?? 'From: $contactName')),
                              style: TextStyle(
                                fontWeight: AppTypography.extraBold,
                                fontSize: AppTypography.labelSmall,
                                color: isMatched
                                    ? AppColors.crimsonRose
                                    : (isDark ? Colors.white : AppColors.slate900),
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            Text(
                              contactRelation,
                              style: TextStyle(
                                fontSize: AppTypography.labelTiny,
                                fontWeight: AppTypography.medium,
                                color: isDark ? Colors.white54 : AppColors.slate500,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                        decoration: BoxDecoration(
                          color: isDark ? Colors.white.withValues(alpha: 0.06) : AppColors.slate100,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          _formatTimestamp(context, timestamp),
                          style: TextStyle(
                            fontSize: AppTypography.labelTiny,
                            fontWeight: AppTypography.bold,
                            color: isDark ? Colors.white54 : AppColors.slate500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // Profile Image with Badges & Gradient Overlay
                Stack(
                  children: [
                    CustomImageWidget(
                      imageUrl: profileImage,
                      width: double.infinity,
                      height: 24.h,
                      fit: BoxFit.cover,
                    ),
                    // High-contrast Bottom Gradient
                    Positioned(
                      bottom: 0,
                      left: 0,
                      right: 0,
                      height: 10.h,
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.transparent,
                              Colors.black.withValues(alpha: 0.75),
                            ],
                          ),
                        ),
                      ),
                    ),
                    // Verified Badge (Top Left)
                    Positioned(
                      top: 1.2.h,
                      left: 3.w,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3.5),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.55),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: Colors.white.withValues(alpha: AppColors.opacity25),
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.verified_rounded, color: AppColors.categoryCareer, size: 12),
                            const SizedBox(width: 3.5),
                            Text(
                              'Verified',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: AppTypography.labelTiny,
                                fontWeight: AppTypography.extraBold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    // Matched Badge (Top Right)
                    if (isMatched)
                      Positioned(
                        top: 1.2.h,
                        right: 3.w,
                        child: _buildBadge(
                          l10n?.matchedBadge ?? 'MATCHED',
                          [
                            AppColors.crimsonRose,
                            AppColors.crimsonBlush,
                          ],
                          Icons.favorite_rounded,
                        ),
                      ),
                    // Premium Crown Badge
                    if (isPremium && !isMatched)
                      Positioned(
                        top: 1.2.h,
                        right: 3.w,
                        child: _buildBadge(
                          l10n?.premiumBadge ?? 'PREMIUM',
                          [
                            AppColors.categoryAstro,
                            AppColors.categoryAstroDark,
                          ],
                          Icons.star_rounded,
                        ),
                      ),
                    // Name & Age Overlay
                    Positioned(
                      bottom: 1.2.h,
                      left: 4.w,
                      right: 4.w,
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              '$profileName, ${l10n?.yrs(profileAge) ?? "$profileAge Yrs"}',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: AppTypography.black,
                                fontSize: AppTypography.headingSmall,
                                shadows: [
                                  const Shadow(color: Colors.black54, blurRadius: 6),
                                ],
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                // Detail Section: Micro-tag Pills
                Padding(
                  padding: EdgeInsets.fromLTRB(4.w, 1.2.h, 4.w, 1.h),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Wrap(
                        spacing: 2.w,
                        runSpacing: 0.8.h,
                        children: [
                          _buildModernTag(
                            context,
                            isDark,
                            Icons.school_rounded,
                            profile['education']?.toString() ?? (l10n?.notAvailable ?? 'N/A'),
                          ),
                          _buildModernTag(
                            context,
                            isDark,
                            Icons.work_outline_rounded,
                            profile['job']?.toString() ?? (l10n?.notAvailable ?? 'N/A'),
                          ),
                          _buildModernTag(
                            context,
                            isDark,
                            Icons.straighten_rounded,
                            profile['height']?.toString() ?? (l10n?.notAvailable ?? 'N/A'),
                          ),
                          _buildModernTag(
                            context,
                            isDark,
                            Icons.favorite_outline_rounded,
                            profile['maritalStatus']?.toString() ?? (l10n?.notAvailable ?? 'N/A'),
                          ),
                        ],
                      ),
                      if (viewCount > 0) ...[
                        SizedBox(height: 0.8.h),
                        Row(
                          children: [
                            Icon(
                              Icons.visibility_outlined,
                              size: 13,
                              color: isDark ? Colors.white38 : AppColors.slate500,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              l10n?.countProfileViews(viewCount) ?? '$viewCount profile views',
                              style: TextStyle(
                                fontSize: AppTypography.labelTiny,
                                fontWeight: AppTypography.semiBold,
                                color: isDark ? Colors.white54 : AppColors.slate500,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),

                // Modern Floating Action Bar
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 3.5.w, vertical: 1.h),
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.canvasDeepDark : AppColors.slate50,
                    border: Border(
                      top: BorderSide(
                        color: isDark ? Colors.white.withValues(alpha: 0.06) : AppColors.slate100,
                      ),
                    ),
                  ),
                  child: Row(
                    children: [
                      // View Biodata Primary Button
                      Expanded(
                        child: TactilePressable(
                          onTap: () {
                            HapticFeedback.lightImpact();
                            onTap();
                          },
                          pressedScale: 0.96,
                          child: Container(
                            height: 38,
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [
                                  AppColors.crimsonRose,
                                  AppColors.wineRed,
                                ],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.crimsonRose.withValues(alpha: AppColors.opacity35),
                                  blurRadius: 6,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            alignment: Alignment.center,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(Icons.visibility_rounded, color: Colors.white, size: 15),
                                const SizedBox(width: 5),
                                Text(
                                  AppLocalizations.of(context)?.view ?? 'View Details',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: AppTypography.extraBold,
                                    fontSize: AppTypography.labelSmall,
                                    letterSpacing: 0.3,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),

                      // Reshare Action Button
                      TactilePressable(
                        onTap: () {
                          HapticFeedback.lightImpact();
                          onReshare();
                        },
                        pressedScale: 0.9,
                        child: Container(
                          width: 38,
                          height: 38,
                          decoration: BoxDecoration(
                            color: isDark ? AppColors.surfaceDark30 : Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: isDark ? Colors.white10 : AppColors.slate200,
                            ),
                          ),
                          child: Icon(
                            Icons.share_rounded,
                            color: isDark ? AppColors.blue300 : AppColors.categoryCareerDark,
                            size: 16,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),

                      // Remove Action Button
                      TactilePressable(
                        onTap: () {
                          HapticFeedback.lightImpact();
                          onRemove();
                        },
                        pressedScale: 0.9,
                        child: Container(
                          width: 38,
                          height: 38,
                          decoration: BoxDecoration(
                            color: isDark ? AppColors.surfaceDark : AppColors.primaryLight,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: AppColors.crimsonRose.withValues(alpha: AppColors.opacity20),
                            ),
                          ),
                          child: const Icon(
                            Icons.delete_outline_rounded,
                            color: AppColors.crimsonRose,
                            size: 17,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBadge(String text, List<Color> colors, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: colors),
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: colors.first.withValues(alpha: AppColors.opacity40),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.white, size: 11),
          const SizedBox(width: 4),
          Text(
            text,
            style: TextStyle(
              color: Colors.white,
              fontWeight: AppTypography.black,
              fontSize: AppTypography.labelTiny,
              letterSpacing: 0.3,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildModernTag(BuildContext context, bool isDark, IconData icon, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark30 : AppColors.slate100,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isDark ? Colors.white.withValues(alpha: AppColors.opacity5) : AppColors.slate200,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 12,
            color: isDark ? AppColors.coralRed : AppColors.crimsonRose,
          ),
          const SizedBox(width: 4),
          Text(
            text,
            style: TextStyle(
              fontWeight: AppTypography.bold,
              fontSize: AppTypography.labelTiny,
              color: isDark ? Colors.white70 : AppColors.slate700,
            ),
          ),
        ],
      ),
    );
  }
}

