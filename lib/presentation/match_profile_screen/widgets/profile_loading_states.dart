import 'package:flutter/material.dart';

import 'package:banjarabio/l10n/app_localizations.dart';
import 'package:banjarabio/core/app_export.dart';
import 'package:banjarabio/widgets/shimmer_widget.dart';
import 'package:banjarabio/widgets/state_orchestration/bespoke_state_container.dart';
import 'package:banjarabio/widgets/state_orchestration/empty_state_config.dart';

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
        title: Text(AppLocalizations.of(context)?.profile ?? 'Profile Details'),
      ),
      body: BespokeStateContainer(
        isLoading: false,
        isEmpty: true,
        skeleton: const ProfileDetailSkeleton(),
        emptyConfig: EmptyStateConfig(
          icon: Icons.person_off_rounded,
          badgeText: 'PROFILE STATUS',
          accentColor: AppColors.crimsonRose,
          iconGradient: const LinearGradient(
            colors: [AppColors.crimsonRose, AppColors.crimsonMaroon],
          ),
          title: AppLocalizations.of(context)?.profileDataNotFound ?? 'Profile Not Found 👤',
          description: 'This candidate biodata is currently unavailable or has been deactivated by the member.',
          ctaText: AppLocalizations.of(context)?.goBack ?? '✨ Return to Discovery',
          onCtaTap: () => Navigator.of(context).pop(),
        ),
        contentBuilder: (_) => const SizedBox.shrink(),
      ),
    );
  }
}

