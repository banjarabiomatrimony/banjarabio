import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import 'package:banjarabio/core/constants/app_typography.dart';
import 'package:banjarabio/core/models/profile_model.dart';
import 'package:banjarabio/presentation/home_screen/widgets/daily_match_widget.dart';

/// Daily tab content slivers extracted from HomeScreenInitialPage.build().
class HomeDailyContent {
  HomeDailyContent._();

  /// Returns slivers for the Daily tab.
  static List<Widget> buildSlivers({
    required BuildContext context,
    required bool isLoading,
    required String? errorMessage,
    required List<ProfileModel> profiles,
    required void Function(ProfileModel) onTap,
    required void Function(ProfileModel) onInterest,
    required void Function(String, bool) onToggleBookmark,
    required void Function(ProfileModel) onShare,
  }) {
    return [
      if (isLoading)
        SliverFillRemaining(
          hasScrollBody: false,
          child: Center(
            child: Text(
              '. . .',
              style: TextStyle(
                fontSize: AppTypography.headingLarge,
                fontWeight: AppTypography.bold,
                color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.5),
              ),
            ),
          ),
        )
      else if (errorMessage != null)
        SliverFillRemaining(
          hasScrollBody: false,
          child: Center(child: Text(errorMessage)),
        )
      else
        SliverFillRemaining(
          hasScrollBody: false,
          child: Center(
            child: ConstrainedBox(
              constraints: BoxConstraints(maxHeight: 85.h),
              child: DailyMatchWidget(
                dailyProfiles: pickDailyMatches(profiles),
                onTap: onTap,
                onInterest: onInterest,
                onBookmark: (profile) => onToggleBookmark(profile.id, profile.isBookmarked),
                onShare: (profile) => onShare(profile),
              ),
            ),
          ),
        ),
    ];
  }
}
