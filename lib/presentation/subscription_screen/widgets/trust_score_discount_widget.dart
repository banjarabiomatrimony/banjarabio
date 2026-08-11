import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import 'package:banjarabio/core/constants/app_typography.dart';
import 'package:banjarabio/core/models/trust_score_config.dart';
import 'package:banjarabio/routes/app_routes.dart';
import 'package:banjarabio/widgets/glassmorphism_container.dart';

class TrustScoreDiscountWidget extends StatelessWidget {
  final int trustScore;

  const TrustScoreDiscountWidget({
    super.key,
    required this.trustScore,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
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

    return GlassmorphismContainer(
      padding: EdgeInsets.all(4.w),
      borderRadius: BorderRadius.circular(20),
      color: theme.colorScheme.surface,
      opacity: 0.85,
      blur: 20,
      border: Border.all(
        color: levelColor.withValues(alpha: 0.35),
        width: 1.5,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.verified_user_rounded,
                    color: levelColor,
                    size: 22,
                  ),
                  SizedBox(width: 2.w),
                  Text(
                    'Profile Trust Level: $levelName',
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.1,
                    ),
                  ),
                ],
              ),
              if (discount > 0)
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 2.5.w, vertical: 0.4.h),
                  decoration: BoxDecoration(
                    color: Colors.green.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: Colors.green.withValues(alpha: 0.35),
                    ),
                  ),
                  child: Text(
                    '$discount% OFF Applied',
                    style: TextStyle(
                      color: Colors.green,
                      fontWeight: FontWeight.bold,
                      fontSize: AppTypography.bodySmall,
                    ),
                  ),
                ),
            ],
          ),
          SizedBox(height: 2.h),
          Row(
            children: [
              // Radial Gauge
              SizedBox(
                width: 14.w,
                height: 14.w,
                child: Stack(
                  children: [
                    Center(
                      child: SizedBox(
                        width: 13.w,
                        height: 13.w,
                        child: CircularProgressIndicator(
                          value: trustScore / 100.0,
                          backgroundColor: theme.colorScheme.outlineVariant.withValues(alpha: 0.25),
                          valueColor: AlwaysStoppedAnimation<Color>(levelColor),
                          strokeWidth: 4,
                        ),
                      ),
                    ),
                    Center(
                      child: Text(
                        '$trustScore',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: levelColor,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(width: 4.w),
              // Message & CTA
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (trustScore < 90) ...[
                      Text(
                        'Unlock higher discounts by verifying your profile details.',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                          height: 1.25,
                        ),
                      ),
                      SizedBox(height: 0.5.h),
                      Text(
                        'Verify more steps (need $pointsNeeded points) to unlock $nextDiscount% OFF!',
                        style: TextStyle(
                          fontSize: AppTypography.labelMedium,
                          fontWeight: FontWeight.bold,
                          color: theme.colorScheme.primary,
                        ),
                      ),
                    ] else ...[
                      Text(
                        'Congratulations! You have unlocked the highest trust verification discount level.',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                          height: 1.25,
                        ),
                      ),
                      SizedBox(height: 0.5.h),
                      Text(
                        'Premium Verified Member Discount is Active!',
                        style: TextStyle(
                          fontSize: AppTypography.labelMedium,
                          fontWeight: FontWeight.bold,
                          color: Colors.green,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 1.8.h),
          SizedBox(
            width: double.infinity,
            height: 4.5.h,
            child: OutlinedButton(
              onPressed: () {
                Navigator.pushNamed(context, AppRoutes.trustScore);
              },
              style: OutlinedButton.styleFrom(
                side: BorderSide(color: theme.colorScheme.primary.withValues(alpha: 0.5)),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.shield_outlined, size: 16, color: theme.colorScheme.primary),
                  SizedBox(width: 1.5.w),
                  Text(
                    'Boost Trust Score & Save More',
                    style: TextStyle(
                      fontSize: AppTypography.bodySmall,
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
