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
import 'package:banjarabio/widgets/tactile/tactile_back_button.dart';
import 'package:banjarabio/widgets/tactile/tactile_pressable.dart';
import 'package:banjarabio/widgets/shimmer_widget.dart';
import 'package:banjarabio/widgets/branded_refresh_indicator.dart';
import 'package:banjarabio/presentation/home_screen/widgets/profile_card_widget.dart';
import 'package:banjarabio/presentation/match_profile_screen/widgets/direct_note_bottom_sheet.dart';
import 'package:banjarabio/widgets/branded_empty_state.dart';
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
                if (changed) {
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
        leading: const TactileBackButton(),
        title: l10n?.savedProfiles ?? 'Saved Profiles',
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
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        child: _isLoading
            ? ListView.separated(
                key: const ValueKey('loading'),
                padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
                itemCount: 3,
                separatorBuilder: (context, index) => SizedBox(height: 2.h),
                itemBuilder: (context, index) => const ProfileCardSkeleton(),
              )
            : _errorMessage != null
                ? _buildErrorState(theme, isDark, l10n)
                : _bookmarkedProfiles.isEmpty
                    ? BrandedEmptyState(
                        key: const ValueKey('empty'),
                        icon: Icons.bookmark_border_rounded,
                        title: l10n?.noBookmarkedProfilesYet ?? 'No bookmarked profiles yet',
                        description: l10n?.profilesYouSaveWillAppearHere ??
                            'Profiles you save will appear here for easy access.',
                        ctaText: l10n?.browseProfiles ?? 'Browse Profiles',
                        onCtaPressed: () {
                          HapticFeedback.lightImpact();
                          if (Navigator.canPop(context)) {
                            Navigator.pop(context);
                          } else {
                            ref.read(homeTabProvider.notifier).state = 0;
                          }
                        },
                      )
                    : BrandedRefreshIndicator(
                        key: const ValueKey('list'),
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
                      ),
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

  Widget _buildErrorState(ThemeData theme, bool isDark, AppLocalizations? l10n) {
    return Center(
      key: const ValueKey('error'),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 6.w),
        child: Container(
          padding: EdgeInsets.all(6.w),
          decoration: BoxDecoration(
            color: theme.cardColor,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: Colors.red.withValues(alpha: AppColors.opacity20),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.04),
                blurRadius: 16,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.red.withValues(alpha: AppColors.opacity10),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.error_outline_rounded, size: 40, color: Colors.red),
              ),
              SizedBox(height: 2.h),
              Text(
                _errorMessage ?? 'An error occurred',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: AppTypography.bodyMedium,
                  color: theme.colorScheme.onSurface,
                ),
              ),
              SizedBox(height: 2.5.h),
              TactilePressable(
                onTap: () {
                  HapticFeedback.lightImpact();
                  _loadBookmarks();
                },
                pressedScale: 0.95,
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 1.2.h),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary,
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: [
                      BoxShadow(
                        color: theme.colorScheme.primary.withValues(alpha: AppColors.opacity30),
                        blurRadius: 8,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.refresh_rounded, size: 18, color: Colors.white),
                      SizedBox(width: 2.w),
                      Text(
                        l10n?.retry ?? 'Retry',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: AppTypography.bold,
                          fontSize: AppTypography.bodyMedium,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}