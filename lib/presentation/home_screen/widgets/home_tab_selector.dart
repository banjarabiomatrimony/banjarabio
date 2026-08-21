import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';

import 'package:banjarabio/l10n/app_localizations.dart';
import 'package:banjarabio/core/constants/app_typography.dart';
import 'package:banjarabio/theme/app_colors.dart';

/// Dual tab-group selector: Recommended/Daily + Grid/Swipe with visual labels and icons.
class HomeTabSelector extends StatelessWidget {
  final int selectedTab;
  final bool isSwipeMode;
  final ValueChanged<int> onTabChanged;
  final ValueChanged<bool> onViewModeChanged;

  const HomeTabSelector({
    super.key,
    required this.selectedTab,
    required this.isSwipeMode,
    required this.onTabChanged,
    required this.onViewModeChanged,
  });

  String _getMatchesFilterLabel(BuildContext context) {
    return AppLocalizations.of(context)?.matchesCategoryLabel ?? 'Matches Category';
  }

  String _getDisplayLayoutLabel(BuildContext context) {
    return AppLocalizations.of(context)?.displayLayoutLabel ?? 'Display Layout';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SliverToBoxAdapter(
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.0.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Category Headers
            Row(
              children: [
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(left: 6, bottom: 6),
                    child: Row(
                      children: [
                        Icon(
                          Icons.tune_rounded,
                          size: 11.sp,
                          color: theme.colorScheme.primary,
                        ),
                        const SizedBox(width: 5),
                        Expanded(
                          child: Text(
                            _getMatchesFilterLabel(context),
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant.withValues(alpha: AppColors.opacity80),
                              fontWeight: AppTypography.bold,
                              fontSize: AppTypography.labelMedium,
                              letterSpacing: 0.3,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(width: 4.w),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(left: 6, bottom: 6),
                    child: Row(
                      children: [
                        Icon(
                          Icons.dashboard_customize_rounded,
                          size: 11.sp,
                          color: theme.colorScheme.primary,
                        ),
                        const SizedBox(width: 5),
                        Expanded(
                          child: Text(
                            _getDisplayLayoutLabel(context),
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant.withValues(alpha: AppColors.opacity80),
                              fontWeight: AppTypography.bold,
                              fontSize: AppTypography.labelMedium,
                              letterSpacing: 0.3,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            IntrinsicHeight(
              child: Row(
                children: [
                  // Group 1: Recommended / Daily
                  Expanded(
                    child: _buildPillGroup(
                      theme: theme,
                      children: [
                        Expanded(
                          child: _buildTabPill(
                            icon: Icons.thumb_up_alt_rounded,
                            label: AppLocalizations.of(context)?.recommended ?? 'Rec',
                            isActive: selectedTab == 0,
                            onTap: () {
                              if (selectedTab == 0) return;
                              HapticFeedback.selectionClick();
                              onTabChanged(0);
                            },
                            theme: theme,
                          ),
                        ),
                        Expanded(
                          child: _buildTabPill(
                            icon: Icons.today_rounded,
                            label: AppLocalizations.of(context)?.daily ?? 'Daily',
                            isActive: selectedTab == 1,
                            onTap: () {
                              if (selectedTab == 1) return;
                              HapticFeedback.selectionClick();
                              onTabChanged(1);
                            },
                            theme: theme,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Soft Vertical Divider
                  Container(
                    width: 1.5,
                    height: 26,
                    margin: EdgeInsets.symmetric(horizontal: 2.w),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.outlineVariant.withValues(alpha: AppColors.opacity40),
                      borderRadius: BorderRadius.circular(1),
                    ),
                  ),
                  // Group 2: Grid / Swipe
                  Expanded(
                    child: _buildPillGroup(
                      theme: theme,
                      children: [
                        Expanded(
                          child: _buildTabPill(
                            icon: Icons.grid_view_rounded,
                            label: AppLocalizations.of(context)?.grid ?? 'Grid',
                            isActive: !isSwipeMode,
                            onTap: () {
                              if (!isSwipeMode) return;
                              HapticFeedback.selectionClick();
                              onViewModeChanged(false);
                            },
                            theme: theme,
                          ),
                        ),
                        Expanded(
                          child: _buildTabPill(
                            icon: Icons.swipe_rounded,
                            label: AppLocalizations.of(context)?.swipe ?? 'Swipe',
                            isActive: isSwipeMode,
                            onTap: () {
                              if (isSwipeMode) return;
                              HapticFeedback.selectionClick();
                              onViewModeChanged(true);
                            },
                            theme: theme,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPillGroup({required ThemeData theme, required List<Widget> children}) {
    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: AppColors.opacity35),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: theme.colorScheme.outlineVariant.withValues(alpha: 0.45),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.all(3),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: children,
      ),
    );
  }

  Widget _buildTabPill({
    required IconData icon,
    required String label,
    required bool isActive,
    required VoidCallback onTap,
    required ThemeData theme,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOutCubic,
        padding: EdgeInsets.symmetric(vertical: 0.9.h, horizontal: 1.w),
        decoration: BoxDecoration(
          gradient: isActive
              ? LinearGradient(
                  colors: [
                    theme.colorScheme.primary,
                    theme.colorScheme.primary.withValues(alpha: AppColors.opacity85),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                )
              : null,
          borderRadius: BorderRadius.circular(20),
          boxShadow: isActive
              ? [
                  BoxShadow(
                    color: theme.colorScheme.primary.withValues(alpha: AppColors.opacity30),
                    blurRadius: 10,
                    offset: const Offset(0, 3),
                  ),
                ]
              : null,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 13.sp,
              color: isActive ? theme.colorScheme.onPrimary : theme.colorScheme.onSurfaceVariant,
            ),
            SizedBox(width: 1.5.w),
            Flexible(
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.labelLarge?.copyWith(
                  color: isActive ? theme.colorScheme.onPrimary : theme.colorScheme.onSurfaceVariant,
                  fontWeight: isActive ? AppTypography.extraBold : AppTypography.semiBold,
                  fontSize: AppTypography.bodySmall,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
