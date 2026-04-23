import 'package:flutter/material.dart';
import 'package:banjarabio/l10n/app_localizations.dart';
import 'package:sizer/sizer.dart';

import 'package:banjarabio/core/app_export.dart';

class EmptyStateWidget extends StatelessWidget {
  final VoidCallback? onAdjustFilters;

  const EmptyStateWidget({super.key, this.onAdjustFilters});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(8.w),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Illustration
              Container(
                width: 40.w,
                height: 40.w,
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary.withValues(alpha: 0.05),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Icon(
                    Icons.search_off_rounded,
                    size: 15.w,
                    color: theme.colorScheme.primary.withValues(alpha: 0.5),
                  ),
                ),
              ),

              SizedBox(height: 3.h),

              // Message
              Text(AppLocalizations.of(context)?.noProfilesFound ?? 'No Profiles Found',
                style: theme.textTheme.headlineSmall,
                textAlign: TextAlign.center,
              ),

              SizedBox(height: 1.h),

              Text(AppLocalizations.of(context)?.tryAdjustingYourFiltersToSeeMoreProfiles ?? 'Try adjusting your filters to see more profiles from the Banjara community',
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
                textAlign: TextAlign.center,
              ),

              SizedBox(height: 3.h),

              // Action button
              ElevatedButton.icon(
                onPressed: onAdjustFilters,
                icon: CustomIconWidget(
                  iconName: 'tune',
                  color: theme.colorScheme.onPrimary,
                  size: 20,
                ),
                label: Text(AppLocalizations.of(context)?.adjustFilters ?? 'Adjust Filters'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
