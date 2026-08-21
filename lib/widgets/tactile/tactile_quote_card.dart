import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import 'package:banjarabio/core/constants/app_typography.dart';
import 'package:banjarabio/theme/app_colors.dart';

/// 💬 Tactile Quote Container for Bios, Expectations, and Partner Preferences
/// Styled with prominent readable typography, glowing accents, and clear contrast.
class TactileQuoteCard extends StatelessWidget {
  final String title;
  final String content;
  final Color color;
  final IconData icon;

  const TactileQuoteCard({
    super.key,
    required this.title,
    required this.content,
    required this.color,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.4.h),
      decoration: BoxDecoration(
        color: color.withValues(alpha: isDark ? 0.12 : 0.06),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: color.withValues(alpha: isDark ? 0.38 : 0.24),
          width: 1.1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(5),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: AppColors.opacity15),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, size: 14, color: color),
              ),
              SizedBox(width: 2.2.w),
              Expanded(
                child: Text(
                  title.toUpperCase(),
                  style:                   AppTypography.bodyStyle(
                    color: color,
                    fontWeight: AppTypography.black,
                    fontSize: AppTypography.labelMedium,
                    letterSpacing: 0.4,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 0.9.h),
          Text(
            content,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.95),
              height: 1.5,
              fontWeight: AppTypography.semiBold,
              fontSize: AppTypography.bodyMedium,
            ),
            softWrap: true,
          ),
        ],
      ),
    );
  }
}
