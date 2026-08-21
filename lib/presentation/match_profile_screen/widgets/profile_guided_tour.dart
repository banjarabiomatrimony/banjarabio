import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tutorial_coach_mark/tutorial_coach_mark.dart';

import 'package:banjarabio/l10n/app_localizations.dart';
import 'package:banjarabio/core/constants/app_typography.dart';
import 'package:banjarabio/core/services/local_cache_service.dart';
import 'package:banjarabio/core/services/guest_guided_tour_service.dart';
import 'package:banjarabio/core/utils/tour_keys.dart';

/// Profile detail guided tour extracted from ProfileDetailScreen.
/// Handles _checkAndStartProfileTour and _startProfileTour.
class ProfileGuidedTour {
  ProfileGuidedTour._();

  /// Check if tour should start and trigger it.
  static void checkAndStart(BuildContext context, WidgetRef ref) {
    final cache = LocalCacheService();
    if (cache.isGuestMode() &&
        !cache.isTourStageCompleted(TourStage.profileDetail.name)) {
      _start(context, ref);
    }
  }

  static void _start(BuildContext context, WidgetRef ref) {
    final tourService = ref.read(guestTourProvider);
    tourService.startTour(
      context,
      stage: TourStage.profileDetail,
      targets: [
        TargetFocus(
          identify: 'bookmark',
          keyTarget: TourKeys.bookmarkButtonKey,
          contents: [
            TargetContent(
              align: ContentAlign.top,
              builder: (context, controller) => Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    AppLocalizations.of(context)?.tourBookmarkTitle ??
                        'Save for later',
                    style:                     AppTypography.titleStyle(
                      color: Colors.white,
                      fontSize: AppTypography.headingLarge,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    AppLocalizations.of(context)?.tourBookmarkDesc ??
                        'Bookmark this profile to view later.',
                    style: const TextStyle(color: Colors.white),
                  ),
                ],
              ),
            ),
          ],
        ),
        TargetFocus(
          identify: 'interest',
          keyTarget: TourKeys.interestButtonKey,
          contents: [
            TargetContent(
              align: ContentAlign.top,
              builder: (context, controller) => Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    AppLocalizations.of(context)?.tourInterestTitle ??
                        'Express Interest',
                    style:                     AppTypography.titleStyle(
                      color: Colors.white,
                      fontSize: AppTypography.headingLarge,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    AppLocalizations.of(context)?.tourInterestDesc ??
                        AppLocalizations.of(context)?.sendHeartInterested ?? "Send a heart to show you're interested.",
                    style: const TextStyle(color: Colors.white),
                  ),
                ],
              ),
            ),
          ],
        ),
        TargetFocus(
          identify: 'share',
          keyTarget: TourKeys.shareButtonKey,
          contents: [
            TargetContent(
              align: ContentAlign.top,
              builder: (context, controller) => Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    AppLocalizations.of(context)?.tourShareTitle ??
                        'Share with family',
                    style:                     AppTypography.titleStyle(
                      color: Colors.white,
                      fontSize: AppTypography.headingLarge,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    AppLocalizations.of(context)?.tourShareDesc ??
                        'Share profiles via WhatsApp.',
                    style: const TextStyle(color: Colors.white),
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
      onFinish: () {
        LocalCacheService()
            .setTourStageCompleted(TourStage.profileDetail.name, true);
      },
      onSkip: () {
        LocalCacheService()
            .setTourStageCompleted(TourStage.profileDetail.name, true);
      },
    );
  }
}
