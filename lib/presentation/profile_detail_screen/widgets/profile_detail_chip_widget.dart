import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import 'package:banjarabio/widgets/custom_icon_widget.dart';
import 'package:banjarabio/core/constants/app_typography.dart';

/// A highly visual, icon-driven mini-card for displaying profile details.
/// Designed for extreme accessibility, prioritizing the value and an intuitive icon.
class ProfileDetailChipWidget extends StatelessWidget {
  final String iconName;
  final String label;
  final String value;
  final Color tintColor;
  final bool fullWidth;

  const ProfileDetailChipWidget({
    super.key,
    required this.iconName,
    required this.label,
    required this.value,
    required this.tintColor,
    this.fullWidth = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Container(
      width: fullWidth ? double.infinity : 40.w, // Stable 2-column width (80.w + 3.w spacing = 83.w < 84.w available space)
      padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 1.h),
      decoration: BoxDecoration(
        color: tintColor.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: tintColor.withValues(alpha: 0.35),
          width: 0.8,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(2.w),
            decoration: BoxDecoration(
              color: tintColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: CustomIconWidget(
              iconName: iconName,
              color: tintColor,
              size: 20,
            ),
          ),
          SizedBox(width: 3.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  value,
                  style: theme.textTheme.titleSmall?.copyWith(
                    color: theme.colorScheme.onSurface,
                    fontWeight: FontWeight.bold,
                    fontSize: AppTypography.bodyLarge,
                    height: 1.1,
                  ),
                  maxLines: fullWidth ? 5 : 1,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: 0.2.h),
                Text(
                  label.toUpperCase(),
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.8),
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.2,
                    fontSize: AppTypography.bodySmall,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
