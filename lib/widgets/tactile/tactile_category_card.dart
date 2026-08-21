import 'package:banjarabio/core/constants/app_typography.dart';
import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import 'package:banjarabio/theme/app_category_theme.dart';
import 'package:banjarabio/widgets/tactile/tactile_pressable.dart';
import 'package:banjarabio/theme/app_colors.dart';

/// 🏛️ Universal Luxury Tactile Category Card
/// Used for grouping profile, service, event, and setting sections with dynamic
/// theme tokens, glowing category circular emblems, standard sleek proportions,
/// and direct edit actions.
class TactileCategoryCard extends StatelessWidget {
  final CategoryType categoryType;
  final String title;
  final IconData icon;
  final Widget child;
  final VoidCallback? onEdit;
  final String? editLabel;
  final EdgeInsets? margin;
  final EdgeInsets? padding;

  const TactileCategoryCard({
    super.key,
    required this.categoryType,
    required this.title,
    required this.icon,
    required this.child,
    this.onEdit,
    this.editLabel,
    this.margin,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final token = AppCategoryTheme.of(context).forType(categoryType);

    return Container(
      margin: margin ?? EdgeInsets.symmetric(horizontal: 4.w, vertical: 0.8.h),
      padding: padding ?? EdgeInsets.symmetric(horizontal: 3.8.w, vertical: 1.4.h),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark28 : theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: token.border,
          width: 1.1,
        ),
        boxShadow: [
          BoxShadow(
            color: token.glowShadow,
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 3,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section Header with Glowing Category Emblem & Direct Edit Action
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 34,
                      height: 34,
                      decoration: BoxDecoration(
                        color: token.iconBg,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: token.border,
                        ),
                      ),
                      child: Center(
                        child: Icon(
                          icon,
                          color: token.primary,
                          size: 18,
                        ),
                      ),
                    ),
                    SizedBox(width: 2.8.w),
                    Flexible(
                      child: Text(
                        title,
                        style: theme.textTheme.titleMedium?.copyWith(
                          color: theme.colorScheme.onSurface,
                          fontWeight: AppTypography.black,
                          letterSpacing: -0.2,
                          fontSize: AppTypography.headingSmall,
                        ),
                        softWrap: true,
                      ),
                    ),
                  ],
                ),
              ),
              if (onEdit != null) ...[
                SizedBox(width: 2.w),
                TactilePressable(
                  onTap: onEdit,
                  pressedScale: 0.92,
                  child: Container(
                    padding:
                        EdgeInsets.symmetric(horizontal: 2.8.w, vertical: 0.5.h),
                    decoration: BoxDecoration(
                      color: token.iconBg,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: token.border,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.edit_rounded, size: 12, color: token.primary),
                        SizedBox(width: 1.w),
                        Text(
                          editLabel ?? 'Edit',
                          style:                           AppTypography.buttonStyle(
                            color: token.primary,
                            fontSize: AppTypography.labelSmall,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ],
          ),
          SizedBox(height: 1.4.h),

          // Card Body
          child,
        ],
      ),
    );
  }
}
