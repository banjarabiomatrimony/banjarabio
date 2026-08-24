import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:banjarabio/l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:tutorial_coach_mark/tutorial_coach_mark.dart';
import 'package:sizer/sizer.dart';

import 'package:banjarabio/core/app_export.dart';
import 'package:banjarabio/core/models/profile_share_model.dart';
import 'package:banjarabio/core/repositories/share_repository.dart';
import 'package:banjarabio/core/services/guest_guided_tour_service.dart';
import 'package:banjarabio/core/services/local_cache_service.dart';
import 'package:banjarabio/core/utils/tour_keys.dart';
import 'package:banjarabio/widgets/skeleton_loaders.dart';
import 'package:banjarabio/widgets/branded_refresh_indicator.dart';
import 'package:banjarabio/widgets/state_orchestration/bespoke_state_container.dart';
import 'package:banjarabio/widgets/state_orchestration/empty_state_config.dart';
import 'package:banjarabio/presentation/shared_profiles_screen/widgets/shared_profile_card_widget.dart';
import 'package:banjarabio/widgets/app_logo_image.dart';
import 'package:banjarabio/core/services/app_logger.dart';

enum SharedProfileTabFilter { sent, received, matched }

/// Shared Profiles Screen - Tracks biodata sharing history with comprehensive management
/// Accessed via bottom tab navigation (tab bar navigation structure)
class SharedProfilesScreen extends ConsumerStatefulWidget {
  final bool isEmbedded;
  final SharedProfileTabFilter? fixedFilter;
  const SharedProfilesScreen({
    super.key,
    this.isEmbedded = false,
    this.fixedFilter,
  });

  @override
  ConsumerState<SharedProfilesScreen> createState() => _SharedProfilesScreenState();
}

class _SharedProfilesScreenState extends ConsumerState<SharedProfilesScreen>
    with TickerProviderStateMixin {
  bool get _isMatchesTourActive {
    final cache = LocalCacheService();
    return cache.isGuestMode() && !cache.isTourStageCompleted(TourStage.matchesScreen.name);
  }

  TabController? _tabController;
  VoidCallback? _tabListener;
  final ShareRepository _shareRepository = ShareRepository();
  bool _isLoading = true;
  String? _errorMessage;
  final Set<String> _selectedItems = {};
  bool _isSelectionMode = false;
  String? _myProfileId;

  // Real data from backend
  List<ProfileShare> _sharedByMe = [];
  List<ProfileShare> _sharedWithMe = [];
  List<ProfileShare> _matchedProfiles = [];

  @override
  void initState() {
    super.initState();
    if (widget.fixedFilter == null) {
      _tabController = TabController(length: 3, vsync: this);
      _tabListener = () {
        if (_tabController?.indexIsChanging ?? false) {
          setState(() {
            _selectedItems.clear();
            _isSelectionMode = false;
          });
        }
      };
      _tabController!.addListener(_tabListener!);
    }
    _loadShares();
    // Start tour after UI settles
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkAndStartTour();
    });
  }

  @override
  void dispose() {
    if (_tabListener != null && _tabController != null) {
      _tabController!.removeListener(_tabListener!);
      _tabController!.dispose();
    }
    super.dispose();
  }

  void _checkAndStartTour() {
    final cache = LocalCacheService();
    if (cache.isTourStageCompleted(TourStage.matchesScreen.name)) return;

    Future.delayed(const Duration(milliseconds: 800), () {
      if (!mounted) return;
      final tourService = ref.read(guestTourProvider);
      tourService.startTour(
        context,
        stage: TourStage.matchesScreen,
        targets: [
          TargetFocus(
            identify: 'matches_sent_tab',
            keyTarget: TourKeys.matchesSentTabKey,
            contents: [
              TargetContent(
                builder: (context, controller) => Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      AppLocalizations.of(context)?.tourMatchesSentTitle ?? 'Sent Profiles',
                      style: TextStyle(fontWeight: AppTypography.bold, color: Colors.white, fontSize: AppTypography.headingLarge),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      AppLocalizations.of(context)?.tourMatchesSentDesc ?? 'Profiles you have shared with others.',
                      style: const TextStyle(color: Colors.white),
                    ),
                  ],
                ),
              ),
            ],
          ),
          TargetFocus(
            identify: 'matches_received_tab',
            keyTarget: TourKeys.matchesReceivedTabKey,
            contents: [
              TargetContent(
                builder: (context, controller) => Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      AppLocalizations.of(context)?.tourMatchesReceivedTitle ?? 'Received Profiles',
                      style: TextStyle(fontWeight: AppTypography.bold, color: Colors.white, fontSize: AppTypography.headingLarge),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      AppLocalizations.of(context)?.tourMatchesReceivedDesc ?? 'Profiles others have shared with you.',
                      style: const TextStyle(color: Colors.white),
                    ),
                  ],
                ),
              ),
            ],
          ),
          TargetFocus(
            identify: 'matches_matched_tab',
            keyTarget: TourKeys.matchesMatchedTabKey,
            contents: [
              TargetContent(
                builder: (context, controller) => Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      AppLocalizations.of(context)?.tourMatchesMatchedTitle ?? 'Matched Profiles',
                      style: TextStyle(fontWeight: AppTypography.bold, color: Colors.white, fontSize: AppTypography.headingLarge),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      AppLocalizations.of(context)?.tourMatchesMatchedDesc ?? 'Mutual matches where both parties showed interest!',
                      style: const TextStyle(color: Colors.white),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
        onFinish: () {
          LocalCacheService().setTourStageCompleted(TourStage.matchesScreen.name, true);
        },
        onSkip: () {
          LocalCacheService().setTourStageCompleted(TourStage.matchesScreen.name, true);
        },
      );
    });
  }

  Future<void> _loadShares() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      _myProfileId = await _shareRepository.getMyProfileId();

      final results = await Future.wait([
        _shareRepository.getSharesByMe(),
        _shareRepository.getSharesWithMe(),
        _shareRepository.getMatchedProfiles(),
      ]);

      if (mounted) {
        final byMeRes = results[0];
        final withMeRes = results[1];
        final matchedRes = results[2];

        byMeRes.fold(
          onSuccess: (data) => _sharedByMe = data,
          onFailure: (err) => _errorMessage = err,
        );

        withMeRes.fold(
          onSuccess: (data) => _sharedWithMe = data,
          onFailure: (err) => _errorMessage ??= err,
        );

        matchedRes.fold(
          onSuccess: (data) => _matchedProfiles = data,
          onFailure: (err) => _errorMessage ??= err,
        );

        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      AppLogger.error('SharedProfilesScreen', 'SharedProfilesScreen: Error loading shares: $e');
      if (mounted) {
        setState(() {
          _errorMessage = 'Failed to load shares';
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _handleRefresh() async {
    await _loadShares();
  }

  void _toggleSelection(String id) {
    setState(() {
      _selectedItems.contains(id)
          ? _selectedItems.remove(id)
          : _selectedItems.add(id);
      _isSelectionMode = _selectedItems.isNotEmpty;
    });
  }

  Future<void> _handleBulkDelete() async {
    if (_selectedItems.isEmpty) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(AppLocalizations.of(context)?.deleteShares ?? 'Delete Shares'),
        content: Text(
          AppLocalizations.of(context)?.deleteSelectedSharesQuery(
                _selectedItems.length,
              ) ??
              'Delete ${_selectedItems.length} selected share(s)?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(AppLocalizations.of(context)?.cancel ?? 'Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
            child: Text(AppLocalizations.of(context)?.delete ?? 'Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        final deleteRes = await _shareRepository.deleteShares(
          _selectedItems.toList(),
        );

        await deleteRes.fold(
          onSuccess: (_) async {
            if (mounted) {
              Fluttertoast.showToast(
                msg: 'Deleted ${_selectedItems.length} share(s)',
                backgroundColor: Colors.green,
                textColor: Colors.white,
              );
              setState(() {
                _selectedItems.clear();
                _isSelectionMode = false;
              });
              await _loadShares();
            }
          },
          onFailure: (error) async {
            if (mounted) {
              Fluttertoast.showToast(
                msg: 'Failed to delete: $error',
                backgroundColor: Theme.of(context).colorScheme.error,
                textColor: Colors.white,
              );
            }
          },
        );
      } catch (e) {
        if (mounted) {
          Fluttertoast.showToast(
            msg: 'Error: $e',
            backgroundColor: Theme.of(context).colorScheme.error,
            textColor: Colors.white,
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // Direct single-tab rendering when embedded in InboxScreen 4-tab bar
    if (widget.fixedFilter != null) {
      if (_isLoading) {
        final skeletonType = widget.fixedFilter == SharedProfileTabFilter.sent
            ? SharedProfileSkeletonType.sent
            : (widget.fixedFilter == SharedProfileTabFilter.matched
                ? SharedProfileSkeletonType.matched
                : SharedProfileSkeletonType.received);
        return SharedProfilesScreenSkeleton(type: skeletonType);
      }
      if (_errorMessage != null) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, color: theme.colorScheme.error, size: 48),
              SizedBox(height: 2.h),
              Text(_errorMessage!),
              SizedBox(height: 2.h),
              ElevatedButton(
                onPressed: _loadShares,
                child: Text(AppLocalizations.of(context)?.retry ?? 'Retry'),
              ),
            ],
          ),
        );
      }
      final bool? isSharedByMe = widget.fixedFilter == SharedProfileTabFilter.sent
          ? true
          : (widget.fixedFilter == SharedProfileTabFilter.received ? false : null);
      return _buildProfileList(isSharedByMe);
    }

    return Column(
      children: [
        if (!widget.isEmbedded)
          // Custom Header with Gradient (Premium, Glassmorphic & Compact)
          Container(
            padding: EdgeInsets.fromLTRB(4.w, 0, 4.w, 0.4.h),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  theme.colorScheme.primary,
                  theme.colorScheme.primary.withValues(alpha: AppColors.opacity80),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: const BorderRadius.vertical(bottom: Radius.circular(32)),
              boxShadow: [
                BoxShadow(
                  color: theme.colorScheme.primary.withValues(alpha: AppColors.opacity20),
                  blurRadius: 15,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: SafeArea(
              bottom: false,
              child: SingleChildScrollView(
                physics: const NeverScrollableScrollPhysics(),
                child: Column(
                  children: [
                     SizedBox(
                      height: 4.h,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          Align(
                            alignment: Alignment.centerLeft,
                            child: Padding(
                              padding: EdgeInsets.symmetric(vertical: 0.5.h, horizontal: 1.w),
                              child: AppLogoImage(
                                height: 3.0.h,
                              ),
                            ),
                          ),
                          Text(
                            AppLocalizations.of(context)?.shareHub ?? 'Share Hub',
                            style: theme.appBarTheme.titleTextStyle?.copyWith(
                              color: Colors.white,
                              fontSize: AppTypography.headingMedium,
                              fontWeight: AppTypography.bold,
                            ),
                          ),
                          if (_isSelectionMode)
                            Align(
                              alignment: Alignment.centerRight,
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    icon: const Icon(
                                      Icons.delete_outline,
                                      color: Colors.white,
                                      size: 26,
                                    ),
                                    onPressed: _handleBulkDelete,
                                  ),
                                  IconButton(
                                    icon: const Icon(
                                      Icons.close,
                                      color: Colors.white,
                                      size: 26,
                                    ),
                                    onPressed: () {
                                      setState(() {
                                        _selectedItems.clear();
                                        _isSelectionMode = false;
                                      });
                                    },
                                  ),
                                ],
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
        SizedBox(height: 1.h),
        // Tab bar
        Container(
          margin: EdgeInsets.symmetric(horizontal: 3.w, vertical: 0.5.h),
          decoration: BoxDecoration(
            color: theme.brightness == Brightness.dark
                ? AppColors.canvasNearBlack
                : theme.colorScheme.surfaceContainerHighest.withValues(alpha: AppColors.opacity50),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: theme.brightness == Brightness.dark
                  ? Colors.white.withValues(alpha: AppColors.opacity8)
                  : theme.colorScheme.outlineVariant.withValues(alpha: AppColors.opacity30),
            ),
          ),
          child: TabBar(
            controller: _tabController,
            labelColor: Colors.white,
            unselectedLabelColor: theme.brightness == Brightness.dark
                ? Colors.white60
                : AppColors.slate600,
            labelStyle: TextStyle(
              fontSize: AppTypography.labelMedium,
              fontWeight: AppTypography.black,
              letterSpacing: 0.2,
            ),
            unselectedLabelStyle: TextStyle(
              fontSize: AppTypography.labelMedium,
              fontWeight: AppTypography.semiBold,
            ),
            indicator: BoxDecoration(
              gradient: const LinearGradient(
                colors: [AppColors.crimsonRose, AppColors.wineRed],
              ),
              borderRadius: BorderRadius.circular(13),
              boxShadow: [
                BoxShadow(
                  color: AppColors.crimsonRose.withValues(alpha: AppColors.opacity35),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            indicatorSize: TabBarIndicatorSize.tab,
            padding: const EdgeInsets.all(3),
            dividerColor: Colors.transparent,
            tabs: [
              Tab(
                key: _isMatchesTourActive ? TourKeys.matchesSentTabKey : null,
                height: 34,
                text: '${AppLocalizations.of(context)?.sent ?? 'Sent'} (${_sharedByMe.length})',
              ),
              Tab(
                key: _isMatchesTourActive ? TourKeys.matchesReceivedTabKey : null,
                height: 34,
                text: '${AppLocalizations.of(context)?.received ?? 'Received'} (${_sharedWithMe.length})',
              ),
              Tab(
                key: _isMatchesTourActive ? TourKeys.matchesMatchedTabKey : null,
                height: 34,
                text: '${AppLocalizations.of(context)?.matched ?? 'Matched'} (${_matchedProfiles.length})',
              ),
            ],
          ),
        ),
        // Tab content
        Expanded(
          child: _isLoading
              ? SharedProfilesScreenSkeleton(
                  type: (_tabController?.index ?? 0) == 0
                      ? SharedProfileSkeletonType.sent
                      : ((_tabController?.index ?? 0) == 1
                          ? SharedProfileSkeletonType.received
                          : SharedProfileSkeletonType.matched),
                )
              : _errorMessage != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.error_outline,
                        color: theme.colorScheme.error,
                        size: 48,
                      ),
                      SizedBox(height: 2.h),
                      Text(_errorMessage!),
                      SizedBox(height: 2.h),
                      ElevatedButton(
                        onPressed: _loadShares,
                        child: Text(AppLocalizations.of(context)?.retry ?? 'Retry'),
                      ),
                    ],
                  ),
                )
              : TabBarView(
                  controller: _tabController,
                  children: [
                    _buildProfileList(true), // Sent
                    _buildProfileList(false), // Received
                    _buildProfileList(null), // Matched
                  ],
                ),
        ),
      ],
    );
  }

  Widget _buildProfileList(bool? isSharedByMe) {
    final theme = Theme.of(context);

    // Re-filter for current tab
    late List<ProfileShare> shares;
    if (isSharedByMe == null) {
      shares = _matchedProfiles;
    } else {
      shares = isSharedByMe ? _sharedByMe : _sharedWithMe;
    }

    // Group shares by profile ID to avoid duplicates (Not needed for matched, but safe)
    final Map<String, List<ProfileShare>> groupedShares = {};
    for (var share in shares) {
      groupedShares.putIfAbsent(share.sharedProfileId, () => []).add(share);
    }

    final List<Map<String, dynamic>> displayProfiles = [];
    groupedShares.forEach((profileId, profileShares) {
      // Use the latest share for the base info
      profileShares.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      final latestShare = profileShares.first;

      final displayMap = latestShare.toDisplayMap(
        isSharedByMe: isSharedByMe ?? true,
      );

      // Special handling for matched tab UI
      if (isSharedByMe == null) {
        displayMap['senderName'] =
            latestShare.otherPersonName(_myProfileId) ?? 'Matched User';
        displayMap['status'] = 'Matched';
      }

      // Add all sharing methods and IDs in this group
      displayMap['sharingMethods'] = profileShares
          .map((s) => s.sharingMethod)
          .toSet()
          .toList();
      displayMap['allShareIds'] = profileShares.map((s) => s.id).toList();
      displayMap['sharedProfileId'] = latestShare
          .sharedProfileId; // Ensure we have the profile ID for navigation

      displayProfiles.add(displayMap);
    });

    final skeletonType = isSharedByMe == true
        ? SharedProfileSkeletonType.sent
        : (isSharedByMe == false
            ? SharedProfileSkeletonType.received
            : SharedProfileSkeletonType.matched);

    return BespokeStateContainer(
      isLoading: _isLoading,
      isEmpty: displayProfiles.isEmpty,
      errorMessage: _errorMessage,
      onRetry: _loadShares,
      skeleton: SharedProfilesScreenSkeleton(
        type: skeletonType,
        physics: const NeverScrollableScrollPhysics(),
      ),
      emptyConfig: _getEmptyConfig(context, isSharedByMe),
      contentBuilder: (context) {
        return BrandedRefreshIndicator(
          onRefresh: _handleRefresh,
          child: ListView.builder(
            physics: const BouncingScrollPhysics(),
            padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 1.h),
            itemCount: displayProfiles.length + 1,
            itemBuilder: (context, index) {
              // Top 0: Hero Highlights Banner
              if (index == 0) {
                return _buildHeroHighlightsBanner(context, isSharedByMe, displayProfiles.length);
              }

              final profile = displayProfiles[index - 1];
              final shareId = profile['id']?.toString() ?? '';
              final allShareIds =
                  (profile['allShareIds'] as List<dynamic>?)
                      ?.map((e) => e.toString())
                      .toList() ??
                  [shareId];
              final isSelected = allShareIds.any(
                (id) => _selectedItems.contains(id),
              );

              return TweenAnimationBuilder<double>(
                tween: Tween(begin: 0.0, end: 1.0),
                duration: Duration(milliseconds: 200 + ((index - 1).clamp(0, 8) * 50)),
                curve: Curves.easeOutCubic,
                builder: (context, val, child) {
                  return Transform.translate(
                    offset: Offset(0, 16 * (1 - val)),
                    child: Opacity(
                      opacity: val.clamp(0.0, 1.0),
                      child: child,
                    ),
                  );
                },
                child: RepaintBoundary(
                  child: SharedProfileCardWidget(
                    profile: profile,
                    isSharedByMe: isSharedByMe ?? true,
                    isSelected: isSelected,
                    isSelectionMode: _isSelectionMode,
                    onTap: () async {
                      if (_isSelectionMode) {
                        for (var id in allShareIds) {
                          _toggleSelection(id);
                        }
                      } else {
                        // Mark all as viewed if it's a share with me
                        if (isSharedByMe == false) {
                          for (var id in allShareIds) {
                            final markRes = await _shareRepository.markAsViewed(id);
                            await markRes.fold(
                              onSuccess: (_) async {
                                AppLogger.debug('SharedProfilesScreen', 'Marked share $id as viewed');
                              },
                              onFailure: (err) async {
                                AppLogger.error('SharedProfilesScreen', 'Failed to mark share $id: $err');
                              },
                            );
                          }
                        }
                        // Navigate to profile detail using ID for full data loading
                        if (context.mounted) {
                          Navigator.of(context, rootNavigator: true).pushNamed(
                            AppRoutes.profileDetail,
                            arguments: profile['sharedProfileId'] ?? profile['id'],
                          );
                        }
                      }
                    },
                    onLongPress: () {
                      for (var id in allShareIds) {
                        _toggleSelection(id);
                      }
                    },
                    onReshare: () async {
                      try {
                        // Get original method (unformatted)
                        final sharesList = isSharedByMe == null
                            ? _matchedProfiles
                            : isSharedByMe
                            ? _sharedByMe
                            : _sharedWithMe;
                        final originalShare = sharesList.firstWhere(
                          (s) => s.id == shareId,
                          orElse: () => sharesList.firstWhere(
                            (s) => s.sharedProfileId == profile['sharedProfileId'],
                          ),
                        );

                        final shareRes = await _shareRepository.shareProfile(
                          sharedProfileId: profile['sharedProfileId'] ?? '',
                          sharingMethod: originalShare.sharingMethod,
                          recipientId: originalShare.recipientId,
                          recipientName: originalShare.recipientName,
                          recipientRelation: originalShare.recipientRelation,
                          profileName: profile['sharedProfileName'],
                        );

                        await shareRes.fold(
                          onSuccess: (_) async {
                            if (mounted) {
                              Fluttertoast.showToast(
                                msg: 'Reshared successfully',
                                backgroundColor: Colors.green,
                                textColor: Colors.white,
                              );
                              await _loadShares();
                            }
                          },
                          onFailure: (error) async {
                            if (mounted) {
                              Fluttertoast.showToast(
                                msg: 'Failed to reshare: $error',
                                backgroundColor: Theme.of(context).colorScheme.error,
                                textColor: Colors.white,
                              );
                            }
                          },
                        );
                      } catch (e) {
                        if (mounted) {
                          Fluttertoast.showToast(
                            msg: 'Error: $e',
                            backgroundColor: theme.colorScheme.error,
                            textColor: Colors.white,
                          );
                        }
                      }
                    },
                    onRemove: () async {
                      try {
                        for (var id in allShareIds) {
                          final delRes = await _shareRepository.deleteShare(id);
                          await delRes.fold(
                            onSuccess: (_) async {},
                            onFailure: (err) async {
                              AppLogger.error('SharedProfilesScreen', 'Failed to delete share $id: $err');
                            },
                          );
                        }
                        if (mounted) {
                          Fluttertoast.showToast(
                            msg: 'Removed from history',
                            backgroundColor: Colors.green,
                            textColor: Colors.white,
                          );
                          await _loadShares();
                        }
                      } catch (e) {
                        if (mounted) {
                          Fluttertoast.showToast(
                            msg: 'Error: $e',
                            backgroundColor: theme.colorScheme.error,
                            textColor: Colors.white,
                          );
                        }
                      }
                    },
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildHeroHighlightsBanner(BuildContext context, bool? isSharedByMe, int count) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final Color primaryColor;
    final List<Color> gradientColors;
    final IconData iconData;
    final String title;
    final String subtitle;

    if (isSharedByMe == null) {
      primaryColor = AppColors.categoryAstro;
      gradientColors = isDark
          ? const [AppColors.amberBgDark, AppColors.amberBrownBg]
          : const [AppColors.warningLight, AppColors.goldTint100];
      iconData = Icons.favorite_rounded;
      title = '$count Mutual Matches 💍';
      subtitle = 'Both families showed mutual interest! Ready to start chatting.';
    } else if (isSharedByMe == false) {
      primaryColor = AppColors.categoryCareerDark;
      gradientColors = isDark
          ? const [AppColors.blue900, AppColors.slate900]
          : const [AppColors.infoLight, AppColors.blue100];
      iconData = Icons.inbox_rounded;
      title = '$count Connection Requests 📥';
      subtitle = 'Profiles shared with you. Review biodatas and respond.';
    } else {
      primaryColor = AppColors.categoryFamilyDark;
      gradientColors = isDark
          ? const [AppColors.deepIndigo, AppColors.canvasMidnight]
          : const [AppColors.violetBgSoft, AppColors.violetBg];
      iconData = Icons.send_rounded;
      title = '$count Shared Profiles 📤';
      subtitle = "Track profiles you've shared with family and friends.";
    }

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 0.8.h),
      padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.2.h),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: gradientColors,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: primaryColor.withValues(alpha: isDark ? 0.35 : 0.2),
        ),
        boxShadow: [
          BoxShadow(
            color: primaryColor.withValues(alpha: isDark ? 0.15 : 0.04),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: primaryColor.withValues(alpha: isDark ? 0.25 : 0.12),
            ),
            child: Icon(
              iconData,
              color: primaryColor,
              size: 18,
            ),
          ),
          SizedBox(width: 3.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: AppTypography.bodySmall,
                    fontWeight: AppTypography.black,
                    color: isDark ? Colors.white : AppColors.slate900,
                    letterSpacing: 0.2,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: AppTypography.labelSmall,
                    fontWeight: AppTypography.medium,
                    color: isDark ? Colors.white60 : AppColors.slate600,
                    height: 1.2,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  EmptyStateConfig _getEmptyConfig(BuildContext context, bool? isSharedByMe) {
    if (isSharedByMe == false) {
      // 📥 Received
      return EmptyStateConfig(
        icon: Icons.move_to_inbox_rounded,
        badgeText: 'RECEIVED REQUESTS',
        accentColor: AppColors.categoryCareerDark,
        iconGradient: const LinearGradient(
          colors: [AppColors.categoryCareer, AppColors.categoryCareerDark],
        ),
        title: 'No Received Requests Yet 📥',
        description:
            'When other Banjara community members or families send you connection requests, they will appear here for you to accept or review.',
        ctaText: '✨ Explore Matches on Home',
        onCtaTap: () {
          HapticFeedback.selectionClick();
          Navigator.pushNamedAndRemoveUntil(context, AppRoutes.home, (route) => false);
        },
      );
    } else if (isSharedByMe == null) {
      // 💍 Matched
      return EmptyStateConfig(
        icon: Icons.favorite_rounded,
        badgeText: 'MUTUAL MATCHES',
        accentColor: AppColors.categoryAstro,
        iconGradient: const LinearGradient(
          colors: [AppColors.categoryAstro, AppColors.categoryAstroDark],
        ),
        title: 'No Mutual Matches Yet 💍',
        description:
            'When both families accept connection requests, mutual matches unlock here for direct chatting and family discussions.',
        ctaText: '✨ Discover Matches',
        onCtaTap: () {
          HapticFeedback.selectionClick();
          Navigator.pushNamedAndRemoveUntil(context, AppRoutes.home, (route) => false);
        },
      );
    } else {
      // 📤 Sent
      return EmptyStateConfig(
        icon: Icons.outbox_rounded,
        badgeText: 'SENT PROFILES',
        accentColor: AppColors.categoryFamily,
        iconGradient: const LinearGradient(
          colors: [AppColors.categoryFamily, AppColors.categoryFamilyDark],
        ),
        title: 'No Sent Requests Yet 📤',
        description:
            'Profiles you express interest in or share with family members will be neatly tracked here.',
        ctaText: '✨ Browse Community Profiles',
        onCtaTap: () {
          HapticFeedback.selectionClick();
          Navigator.pushNamedAndRemoveUntil(context, AppRoutes.home, (route) => false);
        },
      );
    }
  }
}

