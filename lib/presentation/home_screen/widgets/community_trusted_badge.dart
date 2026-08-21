import 'package:flutter/material.dart';
import 'package:banjarabio/core/constants/app_typography.dart';
import 'package:banjarabio/theme/app_theme.dart';

class CommunityTrustedBadge extends StatelessWidget {
  final bool isLarge;
  final bool showLabel;

  const CommunityTrustedBadge({
    super.key,
    this.isLarge = false,
    this.showLabel = true,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isLarge ? 12 : 8,
        vertical: isLarge ? 6 : 4,
      ),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            AppTheme.secondaryLight,
            AppTheme.secondaryVariantLight,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppTheme.secondaryLight.withValues(alpha: 0.3),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.verified,
            color: AppTheme.onSecondaryLight,
            size: isLarge ? 18 : 14,
          ),
          if (showLabel) ...[
            const SizedBox(width: 6),
            Text(
              'Community Trusted',
              style: TextStyle(
                color: AppTheme.onSecondaryLight,
                fontSize: isLarge ? AppTypography.bodyMedium : AppTypography.bodySmall,
                fontWeight: AppTypography.bold,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
