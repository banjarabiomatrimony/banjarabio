import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';

import 'package:banjarabio/l10n/app_localizations.dart';
import 'package:banjarabio/core/app_export.dart';
import 'package:banjarabio/core/models/profile_model.dart';
import 'package:banjarabio/presentation/home_screen/widgets/profile_card_widget.dart';
// import 'package:banjarabio/presentation/home_screen/widgets/swipeable_card_deck.dart';
import 'package:banjarabio/widgets/shimmer_widget.dart';
import 'package:banjarabio/widgets/state_orchestration/bespoke_state_container.dart';
import 'package:banjarabio/widgets/state_orchestration/empty_state_config.dart';
import 'package:banjarabio/widgets/ads/banner_ad_widget.dart';

/// Recommended tab content slivers extracted from HomeScreen.build().
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
                    theme.colorScheme.primaryContainer.withValues(alpha: AppColors.opacity80),
                    theme.colorScheme.surface,
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: theme.colorScheme.primary.withValues(alpha: AppColors.opacity35),
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
                      color: theme.colorScheme.primary.withValues(alpha: AppColors.opacity12),
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
      SliverBespokeStateContainer(
        isLoading: isLoading,
        isEmpty: profiles.isEmpty,
        skeleton: CustomScrollView(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          slivers: [
            SliverPadding(
              padding: const EdgeInsets.all(8.0),
              sliver: SliverGrid(
                gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
                  maxCrossAxisExtent: 500,
                  mainAxisSpacing: 8,
                  crossAxisSpacing: 8,
                  mainAxisExtent: 50.h,
                ),
                delegate: SliverChildBuilderDelegate(
                  (context, index) => const ProfileCardSkeleton(),
                  childCount: 16,
                ),
              ),
            ),
          ],
        ),
        emptyConfig: activeFilterCount > 0
            ? EmptyStateConfig(
                icon: Icons.filter_list_off_rounded,
                badgeText: 'FILTERED RESULTS',
                accentColor: AppColors.crimsonRose,
                iconGradient: const LinearGradient(
                  colors: [AppColors.crimsonRose, AppColors.crimsonBlush],
                ),
                title: AppLocalizations.of(context)?.noProfilesMatchYourFilters ?? 'No Matches in Current Filters 🔍',
                description: AppLocalizations.of(context)?.tryAdjustingYourFilterCriteria ??
                    'Try adjusting or clearing your age, education, or location filters to view more profiles.',
                ctaText: AppLocalizations.of(context)?.clearAllFilters ?? '✨ Clear All Filters',
                onCtaTap: () {
                  HapticFeedback.selectionClick();
                  onClearFilters();
                },
              )
            : EmptyStateConfig(
                icon: Icons.favorite_border_rounded,
                badgeText: 'COMMUNITY FEED',
                accentColor: AppColors.crimsonRose,
                iconGradient: const LinearGradient(
                  colors: [AppColors.crimsonRose, AppColors.crimsonBlush],
                ),
                title: 'No New Profiles Found ✨',
                description: 'New community matrimonial profiles are added regularly. Adjust search preferences or refresh.',
                ctaText: '✨ Adjust Search Filters',
                onCtaTap: () {
                  HapticFeedback.selectionClick();
                  onOpenFilterSheet();
                },
              ),
        content: SliverPadding(
          padding: const EdgeInsets.fromLTRB(8.0, 0.0, 8.0, 8.0),
          sliver: SliverGrid(
            gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
              maxCrossAxisExtent: 600,
              mainAxisSpacing: 8,
              crossAxisSpacing: 8,
              mainAxisExtent: 50.h,
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
                  color: Theme.of(context).colorScheme.primary.withValues(alpha: AppColors.opacity50),
                ),
              ),
            ),
          ),
        ),
    ];
  }
}
