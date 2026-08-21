import 'package:banjarabio/core/constants/app_typography.dart';
import 'package:flutter/material.dart';

import 'package:banjarabio/l10n/app_localizations.dart';
import 'package:banjarabio/widgets/custom_icon_widget.dart';
import 'package:banjarabio/theme/app_colors.dart';

/// Disability status toggle widget.
/// Extracted from PersonalDetailsSection._buildDisabilityStatus.
class DisabilityStatusWidget extends StatelessWidget {
  final bool isDisabled;
  final ValueChanged<bool> onChanged;

  const DisabilityStatusWidget({
    super.key,
    required this.isDisabled,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: theme.colorScheme.outline.withValues(alpha: AppColors.opacity15)),
      ),
      child: SwitchListTile(
        secondary: CustomIconWidget(
          iconName: 'accessible',
          color: theme.colorScheme.primary.withValues(alpha: AppColors.opacity70),
        ),
        subtitle: Text(
          AppLocalizations.of(context)?.disabledHint ?? 'Optional field',
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant.withValues(alpha: AppColors.opacity60),
          ),
        ),
        title: Text(
          AppLocalizations.of(context)?.isDisabledPerson ?? 'Physical Status (Disabled)',
          style: theme.textTheme.titleSmall?.copyWith(fontWeight: AppTypography.bold),
        ),
        value: isDisabled,
        onChanged: onChanged,
        activeThumbColor: theme.colorScheme.primary,
      ),
    );
  }
}
