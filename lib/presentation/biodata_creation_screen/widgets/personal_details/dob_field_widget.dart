import 'package:banjarabio/core/constants/app_typography.dart';
import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import 'package:banjarabio/l10n/app_localizations.dart';
import 'package:banjarabio/theme/app_colors.dart';

/// Date of Birth field with calendar picker trigger.
/// Extracted from PersonalDetailsSection._buildDOBField.
class DobFieldWidget extends StatelessWidget {
  final DateTime? selectedDOB;
  final VoidCallback onTap;

  const DobFieldWidget({
    super.key,
    required this.selectedDOB,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppLocalizations.of(context)?.dateOfBirth ?? 'Date of Birth',
          style: theme.textTheme.titleSmall?.copyWith(fontWeight: AppTypography.bold),
        ),
        SizedBox(height: 1.h),
        InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: EdgeInsets.symmetric(
              horizontal: 4.w,
              vertical: 2.1.h,
            ),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: theme.colorScheme.outline.withValues(alpha: AppColors.opacity30)),
            ),
            child: Row(
              children: [
                Icon(Icons.calendar_month_outlined, color: theme.colorScheme.onSurfaceVariant, size: 20),
                SizedBox(width: 3.w),
                Expanded(
                  child: Text(
                    selectedDOB == null
                        ? AppLocalizations.of(context)?.selectDate ?? 'Select Date'
                        : "${selectedDOB!.day.toString().padLeft(2, '0')}/${selectedDOB!.month.toString().padLeft(2, '0')}/${selectedDOB!.year}",
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: selectedDOB == null ? theme.colorScheme.onSurfaceVariant.withValues(alpha: AppColors.opacity50) : theme.colorScheme.onSurface,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
