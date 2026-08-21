import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import 'package:banjarabio/core/constants/app_typography.dart';
import 'package:banjarabio/theme/app_colors.dart';

/// Badge tier definitions for profile completion gamification.
enum CompletionTier {
  starter(0, 24, 'Starter', '🌱', AppColors.neutral500),
  bronze(25, 49, 'Bronze', '🥉', AppColors.bronze),
  silver(50, 74, 'Silver', '🥈', AppColors.neutral400),
  gold(75, 99, 'Gold', '🥇', AppColors.gold),
  champion(100, 100, 'Champion', '🏆', AppColors.materialPurpleDark);

  final int minPct;
  final int maxPct;
  final String label;
  final String emoji;
  final Color color;

  const CompletionTier(this.minPct, this.maxPct, this.label, this.emoji, this.color);

  static CompletionTier fromPercentage(int pct) {
    if (pct >= 100) return champion;
    if (pct >= 75) return gold;
    if (pct >= 50) return silver;
    if (pct >= 25) return bronze;
    return starter;
  }

  /// Returns the next tier, or null if already at max.
  CompletionTier? get nextTier {
    switch (this) {
      case starter: return bronze;
      case bronze: return silver;
      case silver: return gold;
      case gold: return champion;
      case champion: return null;
    }
  }
}

/// Displays completion badges with animated progress toward next tier.
class CompletionBadgeWidget extends StatelessWidget {
  final int completionPercentage;
  final VoidCallback? onEditTap;

  const CompletionBadgeWidget({
    super.key,
    required this.completionPercentage,
    this.onEditTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final currentTier = CompletionTier.fromPercentage(completionPercentage);
    final nextTier = currentTier.nextTier;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Badge row — all tiers
        Padding(
          padding: EdgeInsets.symmetric(vertical: 0.5.h),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: CompletionTier.values.map((tier) {
              final isAchieved = completionPercentage >= tier.minPct;
              final isCurrent = tier == currentTier;
              return _BadgeIcon(
                tier: tier,
                isAchieved: isAchieved,
                isCurrent: isCurrent,
              );
            }).toList(),
          ),
        ),

        // Next tier prompt
        if (nextTier != null) ...[
          SizedBox(height: 1.h),
          InkWell(
            onTap: onEditTap,
            borderRadius: BorderRadius.circular(8),
            child: Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 0.8.h),
              decoration: BoxDecoration(
                color: nextTier.color.withValues(alpha: AppColors.opacity8),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: nextTier.color.withValues(alpha: AppColors.opacity20),
                ),
              ),
              child: Row(
                children: [
                  Text(nextTier.emoji, style: TextStyle(fontSize: AppTypography.bodyLarge)),
                  SizedBox(width: 2.w),
                  Expanded(
                    child: Text(
                      '${nextTier.minPct - completionPercentage}% more to unlock ${nextTier.label}!',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: nextTier.color,
                        fontWeight: AppTypography.bold,
                        fontSize: AppTypography.labelMedium,
                      ),
                    ),
                  ),
                  Icon(
                    Icons.arrow_forward_ios,
                    size: 12,
                    color: nextTier.color.withValues(alpha: AppColors.opacity60),
                  ),
                ],
              ),
            ),
          ),
        ] else ...[
          SizedBox(height: 1.h),
          Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 0.8.h),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [AppColors.goldLight, AppColors.purple50],
              ),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Text('🏆', style: TextStyle(fontSize: AppTypography.headingSmall)),
                SizedBox(width: 2.w),
                Expanded(
                  child: Text(
                    'Profile 100% Complete — Champion Badge Unlocked!',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: AppColors.materialPurpleDark,
                      fontWeight: AppTypography.extraBold,
                      fontSize: AppTypography.labelMedium,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }
}

class _BadgeIcon extends StatelessWidget {
  final CompletionTier tier;
  final bool isAchieved;
  final bool isCurrent;

  const _BadgeIcon({
    required this.tier,
    required this.isAchieved,
    required this.isCurrent,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeOutBack,
      padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 0.4.h),
      decoration: BoxDecoration(
        color: isCurrent
            ? tier.color.withValues(alpha: AppColors.opacity12)
            : Colors.transparent,
        borderRadius: BorderRadius.circular(10),
        border: isCurrent
            ? Border.all(color: tier.color.withValues(alpha: AppColors.opacity30), width: 1.5)
            : null,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          AnimatedOpacity(
            duration: const Duration(milliseconds: 300),
            opacity: isAchieved ? 1.0 : 0.3,
            child: Text(
              tier.emoji,
              style: TextStyle(fontSize: isCurrent ? 18 : 14),
            ),
          ),
          SizedBox(height: 0.2.h),
          Text(
            tier.label,
            style: TextStyle(
              fontFamily: AppTypography.bodyFontFamily,
              color: Colors.grey.withValues(alpha: AppColors.opacity50),
              fontWeight: isCurrent ? AppTypography.extraBold : AppTypography.medium,
              fontSize: AppTypography.labelSmall,
            ),
          ),
        ],
      ),
    );
  }
}
