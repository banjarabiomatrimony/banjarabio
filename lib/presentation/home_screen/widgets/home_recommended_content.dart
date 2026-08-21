import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import 'package:banjarabio/l10n/app_localizations.dart';
import 'package:banjarabio/core/app_export.dart';
import 'package:banjarabio/core/models/profile_model.dart';
import 'package:banjarabio/presentation/home_screen/widgets/empty_state_widget.dart';
import 'package:banjarabio/presentation/home_screen/widgets/profile_card_widget.dart';
// import 'package:banjarabio/presentation/home_screen/widgets/swipeable_card_deck.dart';
import 'package:banjarabio/widgets/shimmer_widget.dart';
import 'package:banjarabio/widgets/ads/banner_ad_widget.dart';

/// Recommended tab content slivers extracted from HomeScreenInitialPage.build().
/// Renders one of: skeleton grid, error state, empty/filtered state,
/// swipe deck, or masonry grid — depending on loading/data state.
class HomeRecommendedContent {
  HomeRecommendedContent._();

  /// Returns a list of slivers for the Recommended tab.
  static List<Widget> buildSlivers({
    required BuildContext context,
    required bool isLoading,
    required String? errorMessage,
    required List<ProfileModel> profiles,
    required bool isSwipeMode,
    required int activeFilterCount,
    required bool isFetchingMore,
    bool isDistrictFallback = false,
    String? requestedDistrict,
    String? selectedState,
    required VoidCallback onLoadData,
    required VoidCallback onClearFilters,
    required VoidCallback onOpenFilterSheet,
    required void Function(ProfileModel) onOpenProfileDetail,
    required void Function(ProfileModel) onShowSharingOptions,
    required void Function(ProfileModel) onHandleInterest,
    void Function(ProfileModel)? onMessage,
    required void Function(String, bool) onToggleBookmark,
    required void Function(ProfileModel) onEnrichProfileLazy,
    required VoidCallback onLoadMoreProfiles,
  }) {
    final theme = Theme.of(context);

    return [
      if (!isLoading && errorMessage == null && isDistrictFallback && requestedDistrict != null && requestedDistrict.isNotEmpty)
        SliverToBoxAdapter(
          child: Padding(
            padding: EdgeInsets.fromLTRB(3.w, 1.h, 3.w, 0.5.h),
            child: Container(
              padding: EdgeInsets.all(3.5.w),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    theme.colorScheme.primaryContainer.withValues(alpha: 0.8),
                    theme.colorScheme.surface,
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: theme.colorScheme.primary.withValues(alpha: 0.35),
                  width: 1.2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.04),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: EdgeInsets.all(2.5.w),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primary.withValues(alpha: 0.12),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.access_time_filled_rounded,
                      color: theme.colorScheme.primary,
                      size: 22,
                    ),
                  ),
                  SizedBox(width: 3.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '$requestedDistrict जिल्ह्यातील प्रोफाइल लवकरच उपलब्ध होतील! ⏳',
                          style: theme.textTheme.titleSmall?.copyWith(
                            fontWeight: AppTypography.extraBold,
                            fontSize: AppTypography.bodySmall,
                            color: theme.colorScheme.onSurface,
                          ),
                        ),
                        SizedBox(height: 0.5.h),
                        Text(
                          '${(selectedState != null && selectedState.isNotEmpty) ? selectedState : "महाराष्ट्र"} राज्यातील इतर सर्व प्रोफाइल आपोआप दाखवले जात आहेत. नवीन प्रोफाईलसाठी कृपया दररोज तपासत राहा.',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                            fontSize: AppTypography.labelMedium,
                            height: 1.3,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      if (isLoading)
        SliverPadding(
          padding: const EdgeInsets.all(8.0),
          sliver: SliverGrid(
            gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
              maxCrossAxisExtent: 500,
              mainAxisSpacing: 8,
              crossAxisSpacing: 8,
              mainAxisExtent: 60.h,
            ),
            delegate: SliverChildBuilderDelegate(
              (context, index) => const ProfileCardSkeleton(),
              childCount: 4,
            ),
          ),
        )
      else if (errorMessage != null)
        SliverFillRemaining(
          hasScrollBody: false,
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CustomIconWidget(
                  iconName: 'error_outline',
                  color: theme.colorScheme.error,
                  size: 48,
                ),
                SizedBox(height: 2.h),
                Text(errorMessage, textAlign: TextAlign.center),
                SizedBox(height: 2.h),
                ElevatedButton.icon(
                  onPressed: onLoadData,
                  icon: const CustomIconWidget(
                    iconName: 'refresh',
                    size: 18,
                    color: Colors.white,
                  ),
                  label: Text(AppLocalizations.of(context)?.retry ?? 'Retry'),
                ),
              ],
            ),
          ),
        )
      else if (profiles.isEmpty)
        SliverFillRemaining(
          hasScrollBody: false,
          child: activeFilterCount > 0
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CustomIconWidget(
                        iconName: 'filter_list_off',
                        color: theme.colorScheme.onSurfaceVariant,
                        size: 64,
                      ),
                      SizedBox(height: 2.h),
                      Text(
                        AppLocalizations.of(context)?.noProfilesMatchYourFilters ?? 'No profiles match your filters',
                        style: theme.textTheme.titleMedium,
                      ),
                      SizedBox(height: 1.h),
                      Text(
                        AppLocalizations.of(context)?.tryAdjustingYourFilterCriteria ?? 'Try adjusting your filter criteria',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                      SizedBox(height: 3.h),
                      OutlinedButton.icon(
                        onPressed: onClearFilters,
                        icon: const CustomIconWidget(
                          iconName: 'clear_all',
                          size: 18,
                          color: Colors.red,
                        ),
                        label: Text(AppLocalizations.of(context)?.clearAllFilters ?? 'Clear All Filters'),
                      ),
                    ],
                  ),
                )
              : EmptyStateWidget(
                  onAdjustFilters: onOpenFilterSheet,
                ),
        )
      // ── COMMENTED OUT: Swipe Mode ──
      // else if (isSwipeMode)
      //   SliverFillRemaining(
      //     hasScrollBody: false,
      //     child: Padding(
      //       padding: EdgeInsets.only(bottom: 1.0.h),
      //       child: SwipeableCardDeck(
      //         profiles: profiles,
      //         onTap: onOpenProfileDetail,
      //         onInterest: (profile) => onShowSharingOptions(profile),
      //         onSkip: (profile) {
      //           final nextIdx = profiles.indexWhere((p) => p.id == profile.id) + 3;
      //           if (nextIdx < profiles.length) {
      //             onEnrichProfileLazy(profiles[nextIdx]);
      //           }
      //         },
      //         onSuperLike: (profile) => onShowSharingOptions(profile),
      //         onShare: (profile) => onShowSharingOptions(profile),
      //         onBookmark: (profile) => onToggleBookmark(profile.id, profile.isBookmarked),
      //         onLoadMore: onLoadMoreProfiles,
      //       ),
      //     ),
      //   )
      else
        // ── Grid Mode (Standard Feed) ──
        SliverPadding(
          padding: const EdgeInsets.all(8.0),
          sliver: SliverGrid(
            gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
              maxCrossAxisExtent: 600,
              mainAxisSpacing: 8,
              crossAxisSpacing: 8,
              mainAxisExtent: 60.h,
            ),
            delegate: SliverChildBuilderDelegate((context, index) {
              final isPremium = SessionManager.instance.isPremium;
              const adInterval = 6;

              if (!isPremium && index != 0 && index % adInterval == 0) {
                return BannerAdWidget(key: ValueKey('ad_widget_$index'));
              }

              final profileIndex = isPremium ? index : index - (index ~/ adInterval);
              if (profileIndex >= profiles.length) return null;

              final profile = profiles[profileIndex];

              if (!profile.isEnriched) {
                onEnrichProfileLazy(profile);
              }

              return RepaintBoundary(
                key: ValueKey('profile_${profile.id}'),
                child: ProfileCardWidget(
                  profile: profile,
                  onTap: () => onOpenProfileDetail(profile),
                  onBookmark: () => onToggleBookmark(profile.id, profile.isBookmarked),
                  onShare: (profile) => onShowSharingOptions(profile),
                  onInterest: (profile) => onHandleInterest(profile),
                  onMessage: onMessage != null ? (profile) => onMessage(profile) : null,
                ),
              );
            },
            childCount: SessionManager.instance.isPremium
                ? profiles.length
                : profiles.length + (profiles.length ~/ 5)),
          ),
        ),
      if (isFetchingMore)
        SliverToBoxAdapter(
          child: Padding(
            padding: EdgeInsets.symmetric(vertical: 2.h),
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
          ),
        ),
    ];
  }
}
