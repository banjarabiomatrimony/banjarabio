import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import 'package:banjarabio/l10n/app_localizations.dart';

import 'package:banjarabio/core/constants/app_typography.dart';
import 'package:banjarabio/theme/app_category_theme.dart';
import 'package:banjarabio/widgets/tactile/tactile_category_card.dart';
import 'package:banjarabio/theme/app_colors.dart';

class ReferralTierItem {
  final int requiredReferrals;
  final String key;
  final String title;
  final String reward;
  final String emoji;
  final Color color;

  const ReferralTierItem({
    required this.requiredReferrals,
    required this.key,
    required this.title,
    required this.reward,
    required this.emoji,
    required this.color,
  });
}

/// 👑 Referral Tier Milestone Card with glowing progress and VIP badges
class ReferralTierCard extends StatelessWidget {
  final int currentReferrals;

  static const List<ReferralTierItem> tiers = [
    ReferralTierItem(
      requiredReferrals: 3,
      key: 'bronze',
      title: 'Bronze',
      reward: '1 Month Free',
      emoji: '🥉',
      color: AppColors.bronze,
    ),
    ReferralTierItem(
      requiredReferrals: 5,
      key: 'silver',
      title: 'Silver',
      reward: '2 Months Free',
      emoji: '🥈',
      color: AppColors.blueGray500,
    ),
    ReferralTierItem(
      requiredReferrals: 10,
      key: 'gold',
      title: 'Gold',
      reward: '6 Months Free',
      emoji: '🥇',
      color: AppColors.gold,
    ),
    ReferralTierItem(
      requiredReferrals: 25,
      key: 'diamond',
      title: 'Diamond',
      reward: '1 Year VIP',
      emoji: '💎',
      color: AppColors.categoryVerification,
    ),
  ];

  const ReferralTierCard({
    super.key,
    required this.currentReferrals,
  });

  String _getTierTitle(String key, BuildContext context) {
    final l10n = AppLocalizations.of(context);
    switch (key) {
      case 'bronze':
        return l10n?.bronze ?? 'Bronze';
      case 'silver':
        return l10n?.silver ?? 'Silver';
      case 'gold':
        return l10n?.gold ?? 'Gold';
      case 'diamond':
        return l10n?.diamond ?? 'Diamond';
      default:
        return key;
    }
  }

  String _getTierReward(String key, BuildContext context) {
    final l10n = AppLocalizations.of(context);
    switch (key) {
      case 'bronze':
        return l10n?.oneMonthFree ?? '1 Month Free';
      case 'silver':
        return l10n?.twoMonthsFree ?? '2 Months Free';
      case 'gold':
        return l10n?.sixMonthsFree ?? '6 Months Free';
      case 'diamond':
        return l10n?.oneYearVip ?? '1 Year VIP';
      default:
        return key;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final l10n = AppLocalizations.of(context);

    // Find next unreached tier
    ReferralTierItem? nextTier;
    for (final t in tiers) {
      if (currentReferrals < t.requiredReferrals) {
        nextTier = t;
        break;
      }
    }

    return TactileCategoryCard(
      categoryType: CategoryType.vip,
      title: l10n?.referralRewardsTiers ?? 'Referral Rewards Tiers 👑',
      icon: Icons.military_tech_rounded,
      margin: EdgeInsets.zero,
      padding: EdgeInsets.all(3.8.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (nextTier != null)
            Container(
              margin: const EdgeInsets.only(bottom: 14),
              padding: EdgeInsets.symmetric(horizontal: 3.5.w, vertical: 0.8.h),
              decoration: BoxDecoration(
                color: nextTier.color.withValues(alpha: isDark ? 0.18 : 0.12),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: nextTier.color.withValues(alpha: AppColors.opacity40),
                ),
              ),
              child: Row(
                children: [
                  Text(
                    nextTier.emoji,
                    style: TextStyle(fontSize: AppTypography.headingSmall),
                  ),
                  SizedBox(width: 2.w),
                  Expanded(
                    child: Text(
                      l10n?.moreInvitesToUnlockTier(
                            nextTier.requiredReferrals - currentReferrals,
                            _getTierTitle(nextTier.key, context),
                            _getTierReward(nextTier.key, context),
                          ) ??
                          '${nextTier.requiredReferrals - currentReferrals} more invites to unlock ${_getTierTitle(nextTier.key, context)} tier (${_getTierReward(nextTier.key, context)})',
                      style: TextStyle(
                        fontSize: AppTypography.labelSmall,
                        fontWeight: AppTypography.bold,
                        color: isDark ? Colors.white : nextTier.color,
                      ),
                    ),
                  ),
                ],
              ),
            ),

          // ── Tier Milestone Timeline ──
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: tiers.map((tier) {
              final isUnlocked = currentReferrals >= tier.requiredReferrals;
              return Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 2),
                  child: Column(
                    children: [
                      // Emoji / Icon node
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: isUnlocked
                              ? tier.color.withValues(alpha: AppColors.opacity20)
                              : (isDark
                                  ? Colors.white.withValues(alpha: AppColors.opacity5)
                                  : theme.colorScheme.surfaceContainerHighest.withValues(alpha: AppColors.opacity50)),
                          border: Border.all(
                            color: isUnlocked
                                ? tier.color
                                : theme.colorScheme.outlineVariant.withValues(alpha: AppColors.opacity30),
                            width: isUnlocked ? 2.2 : 1,
                          ),
                          boxShadow: isUnlocked
                              ? [
                                  BoxShadow(
                                    color: tier.color.withValues(alpha: AppColors.opacity30),
                                    blurRadius: 8,
                                    offset: const Offset(0, 2),
                                  ),
                                ]
                              : null,
                        ),
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            Text(
                              tier.emoji,
                              style: TextStyle(
                                fontSize: AppTypography.titleLarge,
                                color: isUnlocked ? null : Colors.grey,
                              ),
                            ),
                            if (isUnlocked)
                              Positioned(
                                right: 0,
                                bottom: 0,
                                child: Container(
                                  padding: const EdgeInsets.all(2),
                                  decoration: const BoxDecoration(
                                    color: AppColors.categoryLocation,
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    Icons.check,
                                    size: 10,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                      SizedBox(height: 0.8.h),
                      Text(
                        _getTierTitle(tier.key, context),
                        style: TextStyle(
                          fontSize: AppTypography.labelSmall,
                          fontWeight:
                              isUnlocked ? AppTypography.extraBold : AppTypography.semiBold,
                          color: isUnlocked
                              ? (isDark ? Colors.white : tier.color)
                              : theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        _getTierReward(tier.key, context),
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: AppTypography.labelTiny,
                          fontWeight: AppTypography.bold,
                          color: isUnlocked
                              ? AppColors.categoryLocationDark
                              : theme.colorScheme.onSurfaceVariant.withValues(alpha: AppColors.opacity70),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}
