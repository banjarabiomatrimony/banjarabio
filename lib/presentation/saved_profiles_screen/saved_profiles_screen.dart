import 'package:flutter/foundation.dart';
import 'package:banjarabio/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sizer/sizer.dart';
import 'package:banjarabio/core/app_export.dart';
import 'package:banjarabio/core/models/profile_model.dart';
import 'package:banjarabio/core/providers/home_tab_provider.dart';
import 'package:banjarabio/core/repositories/profile_repository.dart';
import 'package:banjarabio/features/bookmarks/providers/bookmark_notifier.dart';
import 'package:banjarabio/widgets/custom_app_bar.dart';
import 'package:banjarabio/widgets/app_logo_image.dart';
import 'package:banjarabio/widgets/tactile/tactile_pressable.dart';
import 'package:banjarabio/widgets/shimmer_widget.dart';
import 'package:banjarabio/widgets/branded_refresh_indicator.dart';
import 'package:banjarabio/presentation/home_screen/widgets/profile_card_widget.dart';
import 'package:banjarabio/presentation/match_profile_screen/widgets/direct_note_bottom_sheet.dart';
import 'package:banjarabio/widgets/state_orchestration/bespoke_state_container.dart';
import 'package:banjarabio/widgets/state_orchestration/empty_state_config.dart';
import 'package:banjarabio/core/services/app_logger.dart';

class SavedProfilesScreen extends ConsumerStatefulWidget {
  const SavedProfilesScreen({super.key});

  @override
  ConsumerState<SavedProfilesScreen> createState() =>
      _SavedProfilesScreenState();
}

class _SavedProfilesScreenState extends ConsumerState<SavedProfilesScreen> {
  final ProfileRepository _profileRepository = ProfileRepository();
  bool _isLoading = true;
  String? _errorMessage;
  List<ProfileModel> _bookmarkedProfiles = [];
  bool _loadScheduled = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || _loadScheduled) return;
      _loadScheduled = true;
      _loadBookmarks();
    });
  }

  void _syncBookmarkState(Map<String, bool>? bookmarkState) {
    if (!mounted || bookmarkState == null) return;

    setState(() {
      // Update bookmark status for all profiles
      for (int i = 0; i < _bookmarkedProfiles.length; i++) {
        final profileId = _bookmarkedProfiles[i].id;
        final isBookmarked = bookmarkState[profileId] ?? false;
        if (_bookmarkedProfiles[i].isBookmarked != isBookmarked) {
          _bookmarkedProfiles[i] = _bookmarkedProfiles[i].copyWith(
            isBookmarked: isBookmarked,
          );
        }
      }

      // Remove profiles that are no longer bookmarked
      _bookmarkedProfiles.removeWhere(
        (profile) => !(bookmarkState[profile.id] ?? false),
      );
    });
  }

  Future<void> _loadBookmarks() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final response = await _profileRepository.getBookmarkedProfiles();

      await response.fold(
        onSuccess: (profiles) {
          if (mounted) {
            // Merge with existing Riverpod state: never overwrite false (user unsaved)
            // with true from stale cache/API. (Delayed for performance)
            Future.delayed(const Duration(milliseconds: 500), () {
              if (!mounted) return;
              try {
                final current = ref.read(bookmarkNotifierProvider);
                final merged = Map<String, bool>.from(current);
                bool changed = false;
                for (final profile in profiles) {
                  if (merged[profile.id] != true && merged[profile.id] != false) {
                    merged[profile.id] = true;
                    changed = true;
                  }
                }
                if (changed && mounted) {
                  ref.read(bookmarkNotifierProvider.notifier).initializeBookmarks(merged);
                }
              } catch (_) {}
            });

            // Filter by Riverpod state: exclude profiles user unsaved (Riverpod says false).
            final riverpodState = ref.read(bookmarkNotifierProvider);
            final filtered =
                profiles.where((p) => riverpodState[p.id] != false).toList();

            setState(() {
              _bookmarkedProfiles = filtered;
              _isLoading = false;
            });
          }
        },
        onFailure: (error) {
          if (mounted) {
            setState(() {
              _errorMessage = AppLocalizations.of(context)?.failedToLoadBookmarks(error.toString()) ?? 'Failed to load bookmarks: $error';
              _isLoading = false;
            });
          }
        },
      );
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = AppLocalizations.of(context)?.anErrorOccurred(e.toString()) ?? 'An error occurred: $e';
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _handleRefresh() async {
    await _loadBookmarks();
  }

  Future<void> _toggleBookmark(
    String profileId,
    bool isCurrentlyBookmarked,
  ) async {
    if (kDebugMode) {
      AppLogger.debug('SavedProfilesScreen', '[BOOKMARK] SavedProfilesScreen > User tapped ${isCurrentlyBookmarked ? "Saved" : "Save"} on profile $profileId > Calling Riverpod toggle (ref.listen will immediately remove if unsaving)');
    }
    try {
      // Riverpod notifier: optimistic update + backend sync.
      // ref.listen + _syncBookmarkState will immediately remove the profile from
      // the list when unsaved—do NOT call _loadBookmarks() here as it overwrites
      // with stale cache/API data and re-adds the unsaved profile.
      await ref.read(bookmarkNotifierProvider.notifier).toggle(profileId);
      if (kDebugMode) {
        AppLogger.debug('SavedProfilesScreen', '[BOOKMARK] SavedProfilesScreen > toggle($profileId) > SUCCESS');
      }
    } catch (e) {
      if (kDebugMode) {
        AppLogger.error('SavedProfilesScreen', '[BOOKMARK] SavedProfilesScreen > toggle($profileId) > FAILED | $e');
      }
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context)?.failedToUpdateBookmark(e.toString()) ?? 'Failed to update bookmark: ${e.toString()}'),
          ),
        );
      }
    }
  }

  void _openProfileDetail(ProfileModel profile) async {
    // Navigate to detail
    if (mounted) {
      await Navigator.of(
        context,
        rootNavigator: true,
      ).pushNamed(AppRoutes.profileDetail, arguments: profile.toDisplayMap());
      _loadBookmarks(); // Refresh upon return
    }
  }

  void _handleShare(ProfileModel profile) {
    _showSharingOptions(profile);
  }

  void _showSharingOptions(ProfileModel profile) {
    // Re-use the sharing sheet from HomeScreen but local to this screen
    // For simplicity, we'll just open detail for now as it has sharing,
    // but better would be to show the same sheet as HomeScreen.
    _openProfileDetail(profile);
  }

  void _handleInterest(ProfileModel profile) {
    if (kDebugMode) {
      AppLogger.debug('SavedProfilesScreen', '[INTEREST] SavedProfilesScreen > Expressing interest for ${profile.id}');
    }
    // For SavedProfilesScreen, we redirect to Detail where the primary Interest button/logic lives
    _openProfileDetail(profile);
  }

  void _handleMessage(ProfileModel profile) {
    if (profile.isMatched) {
      _openProfileDetail(profile);
    } else {
      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (ctx) => DirectNoteBottomSheet(
          profile: profile.toDisplayMap(),
          onSuccess: () => _openProfileDetail(profile),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final l10n = AppLocalizations.of(context);
    final count = _bookmarkedProfiles.length;

    ref.listen<Map<String, bool>>(
      bookmarkNotifierProvider,
      (previous, next) {
        if (!mounted) return;
        _syncBookmarkState(next);
      },
    );

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: CustomAppBar(
        automaticallyImplyLeading: false,
        leadingWidth: 175,
        leading: Padding(
          padding: const EdgeInsets.only(left: 10),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              // ⬅️ Tactile Back Button
              TactilePressable(
                onTap: () {
                  HapticFeedback.lightImpact();
                  Navigator.maybePop(context);
                },
                child: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: (theme.appBarTheme.foregroundColor ?? Colors.white)
                        .withValues(alpha: isDark ? AppColors.opacity12 : AppColors.opacity15),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.arrow_back_ios_new_rounded,
                    color: theme.appBarTheme.foregroundColor ?? Colors.white,
                    size: 15,
                  ),
                ),
              ),
              const SizedBox(width: 8),

              // 👑 App Logo
              ClipOval(
                child: Container(
                  width: 24,
                  height: 24,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                  ),
                  child: const AppLogoImage(
                    width: 24,
                    height: 24,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              const SizedBox(width: 5),

              // 🏷️ Wordmark
              Image.asset(
                'assets/logo/brand_kit/wordmark.png',
                height: 20,
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) =>
                    const SizedBox.shrink(),
              ),
            ],
          ),
        ),
        titleWidget: FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            l10n?.savedProfiles ?? 'Saved Profiles',
            maxLines: 1,
            style: (theme.appBarTheme.titleTextStyle ?? theme.textTheme.titleMedium)?.copyWith(
              fontSize: AppTypography.headingSmall,
              fontWeight: AppTypography.bold,
              color: theme.appBarTheme.foregroundColor ?? Colors.white,
              letterSpacing: 0.1,
            ),
          ),
        ),
        actions: [
          if (!_isLoading && _errorMessage == null && count > 0)
            Container(
              margin: EdgeInsets.only(right: 3.w),
              padding: EdgeInsets.symmetric(horizontal: 2.8.w, vertical: 0.5.h),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppColors.materialRed600, AppColors.error],
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.materialRed600.withValues(alpha: AppColors.opacity30),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.bookmark_rounded, size: 14, color: Colors.white),
                  SizedBox(width: 1.w),
                  Text(
                    '$count',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: AppTypography.bold,
                      fontSize: AppTypography.bodySmall,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
      body: BespokeStateContainer(
        isLoading: _isLoading,
        isEmpty: _bookmarkedProfiles.isEmpty,
        errorMessage: _errorMessage,
        onRetry: _loadBookmarks,
        skeleton: ListView.separated(
          padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
          physics: const NeverScrollableScrollPhysics(),
          itemCount: 8,
          separatorBuilder: (context, index) => SizedBox(height: 2.h),
          itemBuilder: (context, index) => const ProfileCardSkeleton(),
        ),
        emptyConfig: EmptyStateConfig(
          icon: Icons.bookmark_rounded,
          badgeText: 'SHORTLISTED PROFILES',
          accentColor: AppColors.categoryAstro,
          iconGradient: const LinearGradient(
            colors: [AppColors.categoryAstro, AppColors.categoryAstroDark],
          ),
          title: l10n?.noBookmarkedProfilesYet ?? 'No Shortlisted Profiles Yet ⭐',
          description: l10n?.profilesYouSaveWillAppearHere ??
              'Profiles you bookmark or shortlist will appear here for easy family access and discussions.',
          ctaText: l10n?.browseProfiles ?? '✨ Discover Matches on Home',
          onCtaTap: () {
            HapticFeedback.selectionClick();
            if (Navigator.canPop(context)) {
              Navigator.pop(context);
            } else {
              ref.read(homeTabProvider.notifier).state = 0;
            }
          },
        ),
        contentBuilder: (context) {
          return BrandedRefreshIndicator(
            onRefresh: _handleRefresh,
            child: ListView.separated(
              physics: const AlwaysScrollableScrollPhysics(
                parent: BouncingScrollPhysics(),
              ),
              padding: EdgeInsets.fromLTRB(4.w, 1.5.h, 4.w, 4.h),
              itemCount: _bookmarkedProfiles.length + 1,
              separatorBuilder: (context, index) => SizedBox(height: 2.h),
              itemBuilder: (context, index) {
                if (index == 0) {
                  return _buildHeaderInfoBanner(theme, isDark, count);
                }
                final profile = _bookmarkedProfiles[index - 1];
                final profileId = profile.id;

                return RepaintBoundary(
                  child: ProfileCardWidget(
                    profile: profile,
                    onTap: () => _openProfileDetail(profile),
                    onBookmark: () => _toggleBookmark(profileId, true),
                    onInterest: (profile) => _handleInterest(profile),
                    onMessage: (profile) => _handleMessage(profile),
                    onShare: (profile) => _handleShare(profile),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }

  Widget _buildHeaderInfoBanner(ThemeData theme, bool isDark, int count) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.4.h),
      decoration: BoxDecoration(
        color: isDark
            ? theme.colorScheme.surfaceContainerHigh
            : theme.colorScheme.primaryContainer.withValues(alpha: AppColors.opacity40),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark
              ? theme.colorScheme.outlineVariant.withValues(alpha: AppColors.opacity30)
              : theme.colorScheme.primary.withValues(alpha: AppColors.opacity15),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.materialRed600.withValues(alpha: isDark ? 0.2 : 0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.bookmark_added_rounded,
              size: 18,
              color: AppColors.materialRed600,
            ),
          ),
          SizedBox(width: 3.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '$count ${count == 1 ? "Saved Profile" : "Saved Profiles"}',
                  style: TextStyle(
                    fontWeight: AppTypography.bold,
                    fontSize: AppTypography.bodyMedium,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Shortlisted for quick review and direct connection',
                  style: TextStyle(
                    fontSize: AppTypography.labelSmall,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}