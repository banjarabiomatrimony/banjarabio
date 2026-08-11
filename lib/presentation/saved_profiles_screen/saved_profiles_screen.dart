import 'package:flutter/foundation.dart';
import 'package:banjarabio/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sizer/sizer.dart';
import 'package:banjarabio/core/app_export.dart';
import 'package:banjarabio/core/models/profile_model.dart';
import 'package:banjarabio/core/repositories/profile_repository.dart';
import 'package:banjarabio/features/bookmarks/providers/bookmark_notifier.dart';
import 'package:banjarabio/widgets/shimmer_widget.dart';
import 'package:banjarabio/widgets/branded_refresh_indicator.dart';
import 'package:banjarabio/presentation/home_screen/widgets/profile_card_widget.dart';
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

  @override
  Widget build(BuildContext context) {
    ref.listen<Map<String, bool>>(
      bookmarkNotifierProvider,
      (previous, next) {
        if (!mounted) return;
        _syncBookmarkState(next);
      },
    );
    return Scaffold(
      appBar: AppBar(title: Text(AppLocalizations.of(context)?.savedProfiles ?? 'Saved Profiles'), centerTitle: true),
      body: _isLoading
          ? ListView.separated(
              padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
              itemCount: 3,
              separatorBuilder: (context, index) => SizedBox(height: 2.h),
              itemBuilder: (context, index) => const ProfileCardSkeleton(),
            )
          : _errorMessage != null
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 48, color: Colors.red),
                  SizedBox(height: 2.h),
                  Text(_errorMessage!),
                  SizedBox(height: 2.h),
                  ElevatedButton(
                    onPressed: _loadBookmarks,
                    child: Text(AppLocalizations.of(context)?.retry ?? 'Retry'),
                  ),
                ],
              ),
            )
          : _bookmarkedProfiles.isEmpty
          ? BrandedEmptyState(
              icon: Icons.bookmark_border_rounded,
              title: AppLocalizations.of(context)?.noBookmarkedProfilesYet ?? 'No bookmarked profiles yet',
              description: AppLocalizations.of(context)?.profilesYouSaveWillAppearHere ?? 'Profiles you save will appear here',
              ctaText: AppLocalizations.of(context)?.browseProfiles ?? 'Browse Profiles',
            )
          : BrandedRefreshIndicator(
              onRefresh: _handleRefresh,
              child: ListView.separated(
                padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
                itemCount: _bookmarkedProfiles.length,
                separatorBuilder: (context, index) => SizedBox(height: 2.h),
                itemBuilder: (context, index) {
                  final profile = _bookmarkedProfiles[index];
                  final profileId = profile.id;
                  // The ProfileModel already contains the isBookmarked status,
                  // which is kept in sync by _syncBookmarkState and Riverpod.
                  // No need to override it here.

                  return RepaintBoundary(
                    child: ProfileCardWidget(
                      profile: profile,
                      onTap: () => _openProfileDetail(profile),
                      onBookmark: () => _toggleBookmark(profileId, true),
                      onInterest: (profile) => _handleInterest(profile),
                      onShare: (profile) => _handleShare(profile),
                    ),
                  );
                },
              ),
            ),
    );
  }
}