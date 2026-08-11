import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
        physics: const BouncingScrollPhysics(),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Modern Illustration Ring
              Container(
                width: 38.w,
                height: 38.w,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: [
                      theme.colorScheme.primary.withValues(alpha: 0.12),
                      theme.colorScheme.primary.withValues(alpha: 0.03),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  border: Border.all(
                    color: theme.colorScheme.primary.withValues(alpha: 0.2),
                    width: 1.5,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: theme.colorScheme.primary.withValues(alpha: 0.05),
                      blurRadius: 20,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: Center(
                  child: Container(
                    padding: EdgeInsets.all(4.w),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surface,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.04),
                          blurRadius: 10,
                        ),
                      ],
                    ),
                    child: Icon(
                      Icons.search_off_rounded,
                      size: 14.w,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                ),
              ),

              SizedBox(height: 3.h),

              // Title
              Text(
                AppLocalizations.of(context)?.noProfilesFound ?? 'कोणतेही प्रोफाइल सापडले नाहीत',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w800,
                  color: theme.colorScheme.onSurface,
                  letterSpacing: -0.2,
                ),
                textAlign: TextAlign.center,
              ),

              SizedBox(height: 1.2.h),

              // Description
              Text(
                AppLocalizations.of(context)?.tryAdjustingYourFiltersToSeeMoreProfiles ??
                    'अधिक बंजारा प्रोफाइल पाहण्यासाठी कृपया फिल्टर्स बदला किंवा शोधाची व्याप्ती वाढवा.',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.85),
                  height: 1.4,
                ),
                textAlign: TextAlign.center,
              ),

              SizedBox(height: 3.5.h),

              // Action button
              if (onAdjustFilters != null)
                GestureDetector(
                  onTap: () {
                    HapticFeedback.selectionClick();
                    onAdjustFilters!();
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 1.4.h),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          theme.colorScheme.primary,
                          theme.colorScheme.primary.withValues(alpha: 0.85),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: theme.colorScheme.primary.withValues(alpha: 0.3),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        CustomIconWidget(
                          iconName: 'tune',
                          color: theme.colorScheme.onPrimary,
                          size: 18,
                        ),
                        SizedBox(width: 2.w),
                        Text(
                          AppLocalizations.of(context)?.adjustFilters ?? 'फिल्टर्स बदला',
                          style: theme.textTheme.titleSmall?.copyWith(
                            color: theme.colorScheme.onPrimary,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
