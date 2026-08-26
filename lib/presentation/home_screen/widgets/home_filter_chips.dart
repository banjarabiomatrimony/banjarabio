import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';

import 'package:banjarabio/l10n/app_localizations.dart';
import 'package:banjarabio/core/app_export.dart';

/// Horizontal scrollable list of active filter chips with
/// "Adjust" and "Clear All" actions.
class HomeFilterChips extends StatelessWidget {
  final Map<String, String> activeFiltersMap;
  final VoidCallback onAdjustFilters;
  final VoidCallback onClearFilters;
  final ValueChanged<String> onRemoveFilter;

  const HomeFilterChips({
    super.key,
    required this.activeFiltersMap,
    required this.onAdjustFilters,
    required this.onClearFilters,
    required this.onRemoveFilter,
  });

  @override
  Widget build(BuildContext context) {
    if (activeFiltersMap.isEmpty) return const SliverToBoxAdapter(child: SizedBox.shrink());

    final theme = Theme.of(context);

    return SliverToBoxAdapter(
      child: Container(
        padding: EdgeInsets.fromLTRB(3.5.w, 0.2.h, 3.5.w, 0.2.h),
        height: 4.8.h,
        child: ListView(
          scrollDirection: Axis.horizontal,
          physics: const BouncingScrollPhysics(),
          children: [
            // Adjust button
            GestureDetector(
              onTap: () {
                HapticFeedback.selectionClick();
                onAdjustFilters();
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                margin: EdgeInsets.only(right: 2.w),
                padding: EdgeInsets.symmetric(horizontal: 3.5.w, vertical: 0.6.h),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      theme.colorScheme.primary,
                      theme.colorScheme.primary.withValues(alpha: AppColors.opacity85),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: theme.colorScheme.primary.withValues(alpha: AppColors.opacity25),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CustomIconWidget(iconName: 'edit', color: theme.colorScheme.onPrimary, size: 14),
                    SizedBox(width: 1.5.w),
                    Text(
                      AppLocalizations.of(context)?.adjust ?? 'Adjust',
                      style: theme.textTheme.labelMedium?.copyWith(
                        color: theme.colorScheme.onPrimary,
                        fontWeight: AppTypography.bold,
                        fontSize: AppTypography.labelMedium,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // Filter chips
            ...activeFiltersMap.entries.map((entry) {
              return Container(
                margin: EdgeInsets.only(right: 2.w),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.45),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: theme.colorScheme.outlineVariant.withValues(alpha: AppColors.opacity50),
                    width: 1.1,
                  ),
                ),
                padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 0.4.h),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '${entry.key}: ',
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant.withValues(alpha: AppColors.opacity70),
                        fontWeight: AppTypography.semiBold,
                        fontSize: AppTypography.labelSmall,
                      ),
                    ),
                    Text(
                      entry.value,
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: theme.colorScheme.onSurface,
                        fontWeight: AppTypography.bold,
                        fontSize: AppTypography.labelSmall,
                      ),
                    ),
                    SizedBox(width: 1.5.w),
                    GestureDetector(
                      onTap: () {
                        HapticFeedback.lightImpact();
                        onRemoveFilter(entry.key);
                      },
                      child: Container(
                        padding: const EdgeInsets.all(2),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.surfaceContainerHighest,
                          shape: BoxShape.circle,
                        ),
                        child: CustomIconWidget(
                          iconName: 'close',
                          size: 13,
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }),
            // Clear all
            GestureDetector(
              onTap: () {
                HapticFeedback.selectionClick();
                onClearFilters();
              },
              child: Container(
                margin: EdgeInsets.only(right: 2.w),
                padding: EdgeInsets.symmetric(horizontal: 3.5.w, vertical: 0.6.h),
                decoration: BoxDecoration(
                  color: theme.colorScheme.errorContainer.withValues(alpha: AppColors.opacity20),
                  border: Border.all(color: theme.colorScheme.error.withValues(alpha: AppColors.opacity40), width: 1.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CustomIconWidget(iconName: 'clear_all', color: theme.colorScheme.error, size: 14),
                    SizedBox(width: 1.5.w),
                    Text(
                      AppLocalizations.of(context)?.clear ?? 'Clear',
                      style: theme.textTheme.labelMedium?.copyWith(
                        color: theme.colorScheme.error,
                        fontWeight: AppTypography.bold,
                        fontSize: AppTypography.labelMedium,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
