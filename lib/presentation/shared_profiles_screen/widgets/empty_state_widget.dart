import 'package:flutter/material.dart';
import 'package:banjarabio/l10n/app_localizations.dart';
import 'package:sizer/sizer.dart';

/// Empty state widget with helpful guidance and call-to-action
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
    final theme = Theme.of(context);

    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 8.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 32.w,
              height: 32.w,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    theme.colorScheme.primary.withValues(alpha: 0.15),
                    theme.colorScheme.primary.withValues(alpha: 0.05),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: theme.colorScheme.primary.withValues(alpha: 0.05),
                    blurRadius: 20,
                    spreadRadius: 5,
                  ),
                ],
              ),
              child: Center(
                child: Icon(
                  isMatched
                      ? Icons.favorite_rounded
                      : isSharedByMe
                      ? Icons.share_rounded
                      : Icons.inbox_rounded,
                  color: isMatched
                      ? const Color(0xFFFF4081)
                      : theme.colorScheme.primary,
                  size: 14.w,
                ),
              ),
            ),
            SizedBox(height: 3.h),
            Text(
              isMatched
                  ? AppLocalizations.of(context)?.noMatchesYet ?? 'No Matches Yet'
                  : isSharedByMe
                  ? AppLocalizations.of(context)?.noProfilesSharedYet ?? 'No Profiles Shared Yet'
                  : AppLocalizations.of(context)?.noProfilesReceived ?? 'No Profiles Received',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 1.h),
            Text(
              isMatched
                  ? AppLocalizations.of(context)?.mutualMatchesDesc ?? 'Mutual matches will appear here when both users share interest in each other'
                  : isSharedByMe
                  ? AppLocalizations.of(context)?.startSharingProfilesDesc ?? 'Start sharing profiles with family and friends to help find the perfect match'
                  : AppLocalizations.of(context)?.profilesSharedWithYouDesc ?? 'Profiles shared with you by family and friends will appear here',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 4.h),
            if (isSharedByMe)
              ElevatedButton.icon(
                onPressed: onStartSharing,
                icon: const Icon(
                  Icons.home_rounded,
                  color: Colors.white,
                  size: 20,
                ),
                label: Text(AppLocalizations.of(context)?.browseProfiles ?? 'Browse Profiles'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: theme.colorScheme.primary,
                  foregroundColor: Colors.white,
                  elevation: 2,
                  padding: EdgeInsets.symmetric(
                    horizontal: 10.w,
                    vertical: 1.8.h,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
