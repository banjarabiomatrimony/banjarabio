import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import 'package:banjarabio/core/constants/app_typography.dart';

class ReferralTierItem {
  final int requiredReferrals;
  final String title;
  final String reward;
  final String emoji;
  final Color color;

  const ReferralTierItem({
    required this.requiredReferrals,
    required this.title,
    required this.reward,
    required this.emoji,
    required this.color,
  });
}

class ReferralTierCard extends StatelessWidget {
  final int currentReferrals;

  static const List<ReferralTierItem> tiers = [
    ReferralTierItem(
      requiredReferrals: 3,
      title: 'Bronze',
      reward: '1 Month Free',
      emoji: '🥉',
      color: Color(0xFFCD7F32),
    ),
    ReferralTierItem(
      requiredReferrals: 5,
      title: 'Silver',
      reward: '2 Months Free',
      emoji: '🥈',
      color: Color(0xFFC0C0C0),
    ),
    ReferralTierItem(
      requiredReferrals: 10,
      title: 'Gold',
      reward: '6 Months Free',
      emoji: '🥇',
      color: Color(0xFFD4AF37),
    ),
    ReferralTierItem(
      requiredReferrals: 25,
      title: 'Diamond',
      reward: '1 Year VIP',
      emoji: '💎',
      color: Color(0xFF00ACC1),
    ),
  ];

  const ReferralTierCard({
    super.key,
    required this.currentReferrals,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // Find next unreached tier
    ReferralTierItem? nextTier;
    for (final t in tiers) {
      if (currentReferrals < t.requiredReferrals) {
        nextTier = t;
        break;
      }
    }

    return Container(
      padding: EdgeInsets.all(16.sp),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16.sp),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Referral Rewards Tiers 👑',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.onSurface,
                ),
              ),
              if (nextTier != null)
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 8.sp, vertical: 4.sp),
                  decoration: BoxDecoration(
                    color: nextTier.color.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${nextTier.requiredReferrals - currentReferrals} more for ${nextTier.title} ${nextTier.emoji}',
                    style: TextStyle(
                      fontSize: AppTypography.labelSmall,
                      fontWeight: FontWeight.bold,
                      color: nextTier.color,
                    ),
                  ),
                ),
            ],
          ),
          SizedBox(height: 16.sp),
          // Tier milestone timeline
          Row(
            children: tiers.map((tier) {
              final isUnlocked = currentReferrals >= tier.requiredReferrals;
              return Expanded(
                child: Column(
                  children: [
                    // Emoji / Icon node
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      width: 32.sp,
                      height: 32.sp,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: isUnlocked
                            ? tier.color.withValues(alpha: 0.15)
                            : theme.colorScheme.surfaceContainerHighest,
                        border: Border.all(
                          color: isUnlocked
                              ? tier.color
                              : Colors.grey.withValues(alpha: 0.3),
                          width: isUnlocked ? 2 : 1,
                        ),
                      ),
                      child: Center(
                        child: Text(
                          tier.emoji,
                          style: TextStyle(
                            fontSize: 16.sp,
                            color: isUnlocked ? null : Colors.grey,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 6.sp),
                    Text(
                      tier.title,
                      style: TextStyle(
                        fontSize: AppTypography.labelSmall,
                        fontWeight:
                            isUnlocked ? FontWeight.bold : FontWeight.normal,
                        color: isUnlocked
                            ? tier.color
                            : theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                    SizedBox(height: 2.sp),
                    Text(
                      tier.reward,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: AppTypography.labelSmall - 2,
                        fontWeight: FontWeight.w600,
                        color: isUnlocked
                            ? theme.colorScheme.primary
                            : Colors.grey,
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}
