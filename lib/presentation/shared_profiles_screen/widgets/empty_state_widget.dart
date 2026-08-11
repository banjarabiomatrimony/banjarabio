import 'package:flutter/material.dart';
import 'package:banjarabio/l10n/app_localizations.dart';
import 'package:banjarabio/widgets/branded_empty_state.dart';

/// Reusable Empty state widget built on top of BrandedEmptyState to ensure design consistency.
class EmptyStateWidget extends StatelessWidget {
  final bool isSharedByMe;
  final bool isMatched;
  final VoidCallback onStartSharing;

  const EmptyStateWidget({
    super.key,
    required this.isSharedByMe,
    required this.onStartSharing,
    this.isMatched = false,
  });

  @override
  Widget build(BuildContext context) {
    IconData icon;
    String title;
    String description;
    String ctaText;

    if (isMatched) {
      icon = Icons.favorite_rounded;
      title = AppLocalizations.of(context)?.noMatchesYet ?? 'No Matches Yet';
      description = AppLocalizations.of(context)?.mutualMatchesDesc ?? 'Mutual matches will appear here when both users share interest in each other. Explore profiles to start matching!';
      ctaText = AppLocalizations.of(context)?.browseProfiles ?? 'Browse Profiles';
    } else if (isSharedByMe) {
      icon = Icons.share_rounded;
      title = AppLocalizations.of(context)?.noProfilesSharedYet ?? 'No Profiles Shared Yet';
      description = AppLocalizations.of(context)?.startSharingProfilesDesc ?? 'Start sharing profiles with family and friends to help find the perfect match.';
      ctaText = AppLocalizations.of(context)?.browseProfiles ?? 'Browse Profiles';
    } else {
      icon = Icons.inbox_rounded;
      title = AppLocalizations.of(context)?.noProfilesReceived ?? 'No Profiles Received';
      description = AppLocalizations.of(context)?.profilesSharedWithYouDesc ?? 'Profiles shared with you by family and friends will appear here. Get started by exploring recommendations!';
      ctaText = AppLocalizations.of(context)?.browseProfiles ?? 'Browse Profiles';
    }

    return BrandedEmptyState(
      icon: icon,
      title: title,
      description: description,
      ctaText: ctaText,
      onCtaPressed: onStartSharing,
    );
  }
}
