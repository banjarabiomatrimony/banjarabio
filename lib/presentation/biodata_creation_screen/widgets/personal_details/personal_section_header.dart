import 'package:banjarabio/core/constants/app_typography.dart';
import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import 'package:banjarabio/l10n/app_localizations.dart';

/// Header widget for the Personal Details section.
/// Extracted from PersonalDetailsSection._buildHeader.
class PersonalSectionHeader extends StatelessWidget {
  const PersonalSectionHeader({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppLocalizations.of(context)?.personalDetails ?? 'Personal Details',
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: AppTypography.extraBold,
            letterSpacing: -0.5,
            color: theme.colorScheme.primary,
          ),
        ),
        SizedBox(height: 0.8.h),
        Text(
          AppLocalizations.of(context)?.enterYourBasicInformationAsItAppearsInOf ?? 'Enter your basic information faithfully',
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.7),
            letterSpacing: 0.2,
          ),
        ),
      ],
    );
  }
}
