import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import 'package:banjarabio/l10n/app_localizations.dart';
import 'package:banjarabio/core/app_export.dart';
import 'package:banjarabio/widgets/shimmer_widget.dart';

/// Loading and error scaffolds for ProfileDetailScreen.
/// Extracted from the build method's early-return branches.

class ProfileLoadingScaffold extends StatelessWidget {
  const ProfileLoadingScaffold({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        leading: IconButton(
          icon: CustomIconWidget(
            iconName: 'arrow_back',
            color: theme.colorScheme.onSurface,
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: const ProfileDetailSkeleton(),
    );
  }
}

class ProfileErrorScaffold extends StatelessWidget {
  const ProfileErrorScaffold({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: CustomIconWidget(
            iconName: 'arrow_back',
            color: theme.colorScheme.onSurface,
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(AppLocalizations.of(context)?.profile ?? 'Profile'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CustomIconWidget(
              iconName: 'error_outline',
              color: theme.colorScheme.error,
              size: 48,
            ),
            SizedBox(height: 2.h),
            Text(
              AppLocalizations.of(context)?.profileDataNotFound ?? 'Profile data not found',
              style: theme.textTheme.titleMedium,
            ),
            SizedBox(height: 2.h),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(AppLocalizations.of(context)?.goBack ?? 'Go Back'),
            ),
          ],
        ),
      ),
    );
  }
}
