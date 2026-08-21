import 'package:banjarabio/core/constants/app_typography.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';
import 'package:banjarabio/l10n/app_localizations.dart';
import 'package:banjarabio/widgets/tactile/tactile_pressable.dart';
import 'package:banjarabio/theme/app_colors.dart';

/// 💎 Ultra-Luxury Animated Services Tab Switcher (Self-Service ⚡ vs VIP Matchmaker 💎)
/// Features a fluid sliding physical pill with spring physics, glowing drop shadows,
/// dynamic tier gradients, pulsating micro-badges, and tactile haptics.
class ServicesTabSwitcherWidget extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onTabChanged;
  final Animation<double>? shimmerAnimation;

  const ServicesTabSwitcherWidget({
    super.key,
    required this.selectedIndex,
    required this.onTabChanged,
    this.shimmerAnimation,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final l10n = AppLocalizations.of(context);

    final isSelfService = selectedIndex == 0;
    final isVip = selectedIndex == 1;

    return Container(
      height: 7.2.h,
      decoration: BoxDecoration(
        color: isDark
            ? AppColors.canvasCharcoal
            : AppColors.neutral200,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark
              ? Colors.white.withValues(alpha: AppColors.opacity8)
              : Colors.black.withValues(alpha: 0.07),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.25 : 0.05),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Stack(
        children: [
          // ── 1. Animated Sliding Glass Pill (Spring Physics) ──
          AnimatedAlign(
            duration: const Duration(milliseconds: 320),
            curve: Curves.easeOutBack,
            alignment: isSelfService
                ? Alignment.centerLeft
                : Alignment.centerRight,
            child: FractionallySizedBox(
              widthFactor: 0.5,
              heightFactor: 1.0,
              child: Container(
                margin: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  gradient: isSelfService
                      ? LinearGradient(
                          colors: [
                            theme.colorScheme.primary,
                            Color.lerp(theme.colorScheme.primary, Colors.black, 0.2) ??
                                AppColors.crimsonMaroon,
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        )
                      : const LinearGradient(
                          colors: [
                            AppColors.electricPurple, // Royal Violet
                            AppColors.materialPurpleDark, // Deep Amethyst
                            AppColors.deepIndigo, // Imperial Purple
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: isSelfService
                          ? theme.colorScheme.primary.withValues(alpha: 0.42)
                          : AppColors.electricPurple.withValues(alpha: 0.45),
                      blurRadius: 12,
                      spreadRadius: 1,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // ── 2. Interactive Tab Buttons ──
          Row(
            children: [
              // ⚡ Self-Service Tab
              Expanded(
                child: TactilePressable(
                  onTap: () {
                    if (selectedIndex != 0) {
                      HapticFeedback.selectionClick();
                      onTabChanged(0);
                    }
                  },
                  pressedScale: 0.97,
                  child: Container(
                    color: Colors.transparent,
                    child: Center(
                      child: _buildTabContent(
                        context: context,
                        isSelected: isSelfService,
                        icon: Icons.bolt_rounded,
                        activeIconColor: AppColors.categoryVip,
                        title: l10n?.selfServicePlans ?? 'Self-Service',
                        badgeText: '⚡ Instant • 5 Plans',
                        badgeColor: isSelfService
                            ? Colors.white.withValues(alpha: AppColors.opacity20)
                            : (isDark ? Colors.white.withValues(alpha: AppColors.opacity8) : Colors.black.withValues(alpha: 0.06)),
                        badgeTextColor: isSelfService
                            ? Colors.white
                            : (isDark ? Colors.white70 : theme.colorScheme.onSurfaceVariant),
                        isDark: isDark,
                      ),
                    ),
                  ),
                ),
              ),

              // 💎 VIP Matchmaker Tab
              Expanded(
                child: TactilePressable(
                  onTap: () {
                    if (selectedIndex != 1) {
                      HapticFeedback.selectionClick();
                      onTabChanged(1);
                    }
                  },
                  pressedScale: 0.97,
                  child: Container(
                    color: Colors.transparent,
                    child: Center(
                      child: _buildTabContent(
                        context: context,
                        isSelected: isVip,
                        icon: Icons.diamond_rounded,
                        activeIconColor: AppColors.categoryVip,
                        title: l10n?.vipMatchmaker ?? 'VIP Matchmaker',
                        badgeText: '👑 1-on-1 Concierge',
                        badgeColor: isVip
                            ? AppColors.categoryVip.withValues(alpha: AppColors.opacity25)
                            : (isDark ? AppColors.categoryVip.withValues(alpha: AppColors.opacity10) : AppColors.goldLight),
                        badgeTextColor: isVip
                            ? AppColors.goldGlow
                            : (isDark ? AppColors.categoryVip : AppColors.amberDark),
                        isDark: isDark,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTabContent({
    required BuildContext context,
    required bool isSelected,
    required IconData icon,
    required Color activeIconColor,
    required String title,
    required String badgeText,
    required Color badgeColor,
    required Color badgeTextColor,
    required bool isDark,
  }) {
    final theme = Theme.of(context);

    return AnimatedDefaultTextStyle(
      duration: const Duration(milliseconds: 220),
      curve: Curves.easeOut,
      style: AppTypography.bodyStyle(
        color: isSelected
            ? Colors.white
            : (isDark ? Colors.white60 : theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.75)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Top Row: Animated Icon + Title
          Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              AnimatedScale(
                scale: isSelected ? 1.15 : 0.95,
                duration: const Duration(milliseconds: 260),
                curve: Curves.easeOutBack,
                child: Icon(
                  icon,
                  size: 16,
                  color: isSelected
                      ? activeIconColor
                      : (isDark ? Colors.white54 : theme.colorScheme.onSurfaceVariant.withValues(alpha: AppColors.opacity60)),
                ),
              ),
              SizedBox(width: 1.5.w),
              Flexible(
                child: Text(
                  title,
                  style:                   AppTypography.bodyStyle(
                    fontWeight: isSelected ? AppTypography.extraBold : AppTypography.semiBold,
                    fontSize: AppTypography.bodySmall,
                    letterSpacing: 0.2,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),

          SizedBox(height: 0.3.h),

          // Bottom Row: Animated Micro-Badge
          AnimatedContainer(
            duration: const Duration(milliseconds: 220),
            padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 0.2.h),
            decoration: BoxDecoration(
              color: badgeColor,
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              badgeText,
              style:               AppTypography.bodyStyle(
                color: badgeTextColor,
                fontWeight: isSelected ? AppTypography.bold : AppTypography.semiBold,
                fontSize: AppTypography.labelTiny,
                letterSpacing: 0.1,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
