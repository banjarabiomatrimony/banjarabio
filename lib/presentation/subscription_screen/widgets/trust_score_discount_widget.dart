import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import 'package:banjarabio/core/constants/app_typography.dart';
import 'package:banjarabio/core/models/trust_score_config.dart';
import 'package:banjarabio/routes/app_routes.dart';
import 'package:banjarabio/widgets/glassmorphism_container.dart';
import 'package:banjarabio/widgets/tactile/tactile_pressable.dart';

class TrustScoreDiscountWidget extends StatelessWidget {
  final int trustScore;

  const TrustScoreDiscountWidget({
    super.key,
    required this.trustScore,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final discount = TrustScoreConfig.getDiscountPercentage(trustScore);
    final levelName = TrustScoreConfig.getLevelName(trustScore) ?? 'Basic';
    final levelColor = TrustScoreConfig.getLevelColor(trustScore);

    // Calculate next tier threshold
    int nextThreshold = 100;
    int nextDiscount = 30;
    if (trustScore < 30) {
      nextThreshold = 30;
      nextDiscount = 5;
    } else if (trustScore < 50) {
      nextThreshold = 50;
      nextDiscount = 10;
    } else if (trustScore < 75) {
      nextThreshold = 75;
      nextDiscount = 20;
    } else if (trustScore < 90) {
      nextThreshold = 90;
      nextDiscount = 30;
    } else {
      nextThreshold = 100;
      nextDiscount = 30;
    }
    final pointsNeeded = nextThreshold - trustScore;

    return TactilePressable(
      onTap: () => Navigator.pushNamed(context, AppRoutes.trustScore),
      pressedScale: 0.98,
      child: GlassmorphismContainer(
        padding: EdgeInsets.symmetric(horizontal: 3.5.w, vertical: 1.2.h),
        borderRadius: BorderRadius.circular(16),
        color: theme.colorScheme.surface,
        opacity: 0.85,
        blur: 16,
        border: Border.all(
          color: levelColor.withValues(alpha: 0.35),
          width: 1.2,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Row 1: Icon + Level + Score + Discount Badge
            Row(
              children: [
                Icon(
                  Icons.verified_user_rounded,
                  color: levelColor,
                  size: 18,
                ),
                SizedBox(width: 1.8.w),
                Expanded(
                  child: Text(
                    'Trust Level: $levelName ($trustScore/100)',
                    style: TextStyle(
                      fontWeight: AppTypography.bold,
                      fontSize: AppTypography.bodySmall,
                      color: theme.colorScheme.onSurface,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                if (discount > 0) ...[
                  Container(
                    padding: EdgeInsets.symmetric(
                        horizontal: 2.2.w, vertical: 0.3.h),
                    decoration: BoxDecoration(
                      color:
                          Colors.green.withValues(alpha: isDark ? 0.2 : 0.12),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(
                        color: Colors.green.withValues(alpha: 0.4),
                      ),
                    ),
                    child: Text(
                      '🔥 $discount% OFF Applied',
                      style: TextStyle(
                        color:
                            isDark ? Colors.greenAccent : Colors.green.shade800,
                        fontWeight: AppTypography.bold,
                        fontSize: AppTypography.labelSmall,
                      ),
                    ),
                  ),
                ] else ...[
                  Container(
                    padding: EdgeInsets.symmetric(
                        horizontal: 2.2.w, vertical: 0.3.h),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      'Verify & Save',
                      style: TextStyle(
                        color: theme.colorScheme.primary,
                        fontWeight: AppTypography.bold,
                        fontSize: AppTypography.labelSmall,
                      ),
                    ),
                  ),
                ],
              ],
            ),
            SizedBox(height: 0.8.h),

            // Row 2: Progress Gauge Bar + Incentive/Action text
            Row(
              children: [
                Expanded(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: (trustScore / 100.0).clamp(0.05, 1.0),
                      backgroundColor: theme.colorScheme.outlineVariant
                          .withValues(alpha: 0.25),
                      valueColor: AlwaysStoppedAnimation<Color>(levelColor),
                      minHeight: 5,
                    ),
                  ),
                ),
                SizedBox(width: 3.w),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      trustScore < 90
                          ? '+$pointsNeeded pts for $nextDiscount% OFF'
                          : 'Max Discount Active',
                      style: TextStyle(
                        fontSize: AppTypography.labelTiny,
                        color: isDark
                            ? Colors.white70
                            : theme.colorScheme.onSurfaceVariant,
                        fontWeight: AppTypography.medium,
                      ),
                    ),
                    SizedBox(width: 1.w),
                    Icon(
                      Icons.arrow_forward_ios_rounded,
                      size: 10,
                      color: theme.colorScheme.primary,
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
