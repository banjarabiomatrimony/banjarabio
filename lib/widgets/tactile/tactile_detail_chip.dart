import 'package:banjarabio/core/constants/app_typography.dart';
import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import 'package:banjarabio/theme/app_category_theme.dart';
import 'package:banjarabio/widgets/custom_icon_widget.dart';
import 'package:banjarabio/widgets/tactile/tactile_pressable.dart';
import 'package:banjarabio/theme/app_colors.dart';

/// 💎 Universal Sleek Tactile Detail Chip
/// Displays profile, setting, or service key-value attributes with full text
/// visibility (never clipped), spring scale physics, and dynamic category tints.
class TactileDetailChip extends StatelessWidget {
  final String? iconName;
  final IconData? iconData;
  final String label;
  final String value;
  final Color? tintColor;
  final bool fullWidth;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final String? subtitle;
  final Widget? trailingBadge;

  const TactileDetailChip({
    super.key,
    this.iconName,
    this.iconData,
    required this.label,
    required this.value,
    this.tintColor,
    this.fullWidth = false,
    this.onTap,
    this.onLongPress,
    this.subtitle,
    this.trailingBadge,
  }) : assert(iconName != null || iconData != null,
            'Must provide either iconName or iconData');

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    // Resolve color dynamically if not explicitly provided
    final resolvedColor = tintColor ??
        FieldColorResolver.resolveFieldToken(context, label).primary;

    return TactilePressable(
      onTap: onTap,
      onLongPress: onLongPress,
      pressedScale: 0.96,
      child: Container(
        width: fullWidth ? double.infinity : null,
        padding: EdgeInsets.symmetric(horizontal: 2.8.w, vertical: 0.85.h),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              resolvedColor.withValues(alpha: isDark ? 0.12 : 0.07),
              resolvedColor.withValues(alpha: isDark ? 0.04 : 0.02),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: resolvedColor.withValues(alpha: isDark ? 0.35 : 0.22),
          ),
          boxShadow: [
            BoxShadow(
              color: resolvedColor.withValues(alpha: isDark ? 0.10 : 0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.02),
              blurRadius: 3,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        child: Row(
          children: [
            // 🌟 Sleek Circular Icon Emblem
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: resolvedColor.withValues(alpha: isDark ? 0.22 : 0.12),
                shape: BoxShape.circle,
                border: Border.all(
                  color: resolvedColor.withValues(alpha: AppColors.opacity30),
                  width: 0.8,
                ),
              ),
              child: Center(
                child: iconData != null
                    ? Icon(
                        iconData,
                        color: resolvedColor,
                        size: 16,
                      )
                    : (iconName != null && iconName!.isNotEmpty
                        ? CustomIconWidget(
                            iconName: iconName!,
                            color: resolvedColor,
                            size: 16,
                          )
                        : Icon(
                            Icons.info_outline_rounded,
                            color: resolvedColor,
                            size: 16,
                          )),
              ),
            ),
            SizedBox(width: 2.5.w),

            // Text Content (Label + Main Value + Subtitle) - Full Visibility
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          label.toUpperCase(),
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant
                                .withValues(alpha: AppColors.opacity85),
                            fontWeight: AppTypography.extraBold,
                            letterSpacing: 0.3,
                            fontSize: AppTypography.labelSmall,
                          ),
                          softWrap: true,
                        ),
                      ),
                      if (trailingBadge != null) trailingBadge!,
                    ],
                  ),
                  SizedBox(height: 0.2.h),
                  Text(
                    value,
                    style: theme.textTheme.titleSmall?.copyWith(
                      color: theme.colorScheme.onSurface,
                      fontWeight: AppTypography.extraBold,
                      fontSize: AppTypography.bodyMedium,
                      height: 1.2,
                      letterSpacing: -0.2,
                    ),
                    softWrap: true,
                  ),
                  if (subtitle != null && subtitle!.isNotEmpty) ...[
                    SizedBox(height: 0.1.h),
                    Text(
                      subtitle!,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant
                            .withValues(alpha: 0.75),
                        fontSize: AppTypography.labelTiny,
                        fontWeight: AppTypography.semiBold,
                      ),
                      softWrap: true,
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
