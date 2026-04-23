import 'package:flutter/material.dart';
import 'package:banjarabio/routes/app_routes.dart';
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
import 'package:banjarabio/widgets/shimmer_widget.dart';
import 'package:banjarabio/widgets/branded_refresh_indicator.dart';
import 'package:banjarabio/presentation/shared_profiles_screen/widgets/empty_state_widget.dart';
import 'package:banjarabio/presentation/shared_profiles_screen/widgets/shared_profile_card_widget.dart';
import 'package:banjarabio/widgets/app_logo_image.dart';

/// Shared Profiles Screen - Tracks biodata sharing history with comprehensive management
/// Accessed via bottom tab navigation (tab bar navigation structure)
class SharedProfilesScreen extends ConsumerStatefulWidget {
  const SharedProfilesScreen({super.key});

  @override
  ConsumerState<SharedProfilesScreen> createState() => _SharedProfilesScreenState();
}

class _SharedProfilesScreenState extends ConsumerState<SharedProfilesScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late VoidCallback _tabListener;
  final TextEditingController _searchController = TextEditingController();
  final ShareRepository _shareRepository = ShareRepository();

  String _searchQuery = '';
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
    _tabController = TabController(length: 3, vsync: this);
    _tabListener = () {
      if (_tabController.indexIsChanging) {
        setState(() {
          _selectedItems.clear();
          _isSelectionMode = false;
        });
      }
    };
    _tabController.addListener(_tabListener);
    _loadShares();
    // Start tour after UI settles
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkAndStartTour();
    });
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
            identify: 'matches_search',
            keyTarget: TourKeys.matchesSearchKey,
            contents: [
              TargetContent(
                builder: (context, controller) => Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      AppLocalizations.of(context)?.tourMatchesSearchTitle ?? 'Search Shared Profiles',
                      style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 20),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      AppLocalizations.of(context)?.tourMatchesSearchDesc ?? 'Quickly find profiles shared with you or by you.',
                      style: const TextStyle(color: Colors.white),
                    ),
                  ],
                ),
              ),
            ],
          ),
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
                      style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 20),
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
                      style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 20),
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
                      style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 20),
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

  @override
  void dispose() {
    _tabController.removeListener(_tabListener);
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
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
      debugPrint('SharedProfilesScreen: Error loading shares: $e');
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
    return Column(
      children: [
        // Custom Header with Gradient
        Container(
          padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                theme.colorScheme.primary,
                theme.colorScheme.primary.withValues(alpha: 0.8),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: const BorderRadius.only(
              bottomLeft: Radius.circular(24),
              bottomRight: Radius.circular(24),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.2),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: SafeArea(
            bottom: false,
            child: Column(
              children: [
                Row(
                  children: [
                    Padding(
                      padding: EdgeInsets.all(1.h),
                      child: AppLogoImage(
                        height: 3.5.h,
                      ),
                    ),
                    Text(AppLocalizations.of(context)?.shareHub ?? 'Share Hub',
                      style: theme.textTheme.headlineMedium?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const Spacer(),
                    if (_isSelectionMode) ...[
                      IconButton(
                        icon: const Icon(
                          Icons.delete_outline,
                          color: Colors.white,
                          size: 28,
                        ),
                        onPressed: _handleBulkDelete,
                      ),
                      IconButton(
                        icon: const Icon(
                          Icons.close,
                          color: Colors.white,
                          size: 28,
                        ),
                        onPressed: () {
                          setState(() {
                            _selectedItems.clear();
                            _isSelectionMode = false;
                          });
                        },
                      ),
                    ] else ...[
                      const SizedBox.shrink(),
                    ],
                  ],
                ),
                SizedBox(height: 2.h),
                // Search bar (Swiggy-inspired Solid White Pill - Streamlined)
                TextField(
                  key: TourKeys.matchesSearchKey,
                  controller: _searchController,
                  onChanged: (value) {
                    setState(() => _searchQuery = value);
                  },
                  style: TextStyle(
                    color: theme.colorScheme.onSurface,
                    fontWeight: FontWeight.w500,
                  ),
                  decoration: InputDecoration(
                    hintText: AppLocalizations.of(context)?.searchSharedProfiles ?? 'Search shared profiles...',
                    hintStyle: TextStyle(
                      color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.6),
                    ),
                    prefixIcon: Icon(
                      Icons.search_rounded,
                      color: theme.colorScheme.primary,
                      size: 22,
                    ),
                    suffixIcon: _searchQuery.isNotEmpty
                        ? IconButton(
                            icon: Icon(
                              Icons.cancel_rounded,
                              color: theme.colorScheme.onSurfaceVariant,
                              size: 20,
                            ),
                            onPressed: () {
                              _searchController.clear();
                              setState(() => _searchQuery = '');
                            },
                          )
                        : null,
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(50),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 4.w,
                      vertical: 1.5.h,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        SizedBox(height: 1.h),
        // Tab bar
        Container(
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(color: theme.dividerColor),
            ),
          ),
          child: TabBar(
            controller: _tabController,
            labelColor: theme.colorScheme.primary,
            unselectedLabelColor: theme.colorScheme.onSurface.withValues(alpha: 0.6),
            labelStyle: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
            unselectedLabelStyle: theme.textTheme.titleSmall,
            indicatorColor: theme.colorScheme.primary,
            indicatorWeight: 3,
            indicatorSize: TabBarIndicatorSize.label,
            padding: EdgeInsets.zero,
            labelPadding: EdgeInsets.symmetric(vertical: 0.5.h),
            tabs: [
              Tab(key: TourKeys.matchesSentTabKey, text: '${AppLocalizations.of(context)?.sent ?? 'Sent'} (${_sharedByMe.length})'),
              Tab(key: TourKeys.matchesReceivedTabKey, text: '${AppLocalizations.of(context)?.received ?? 'Received'} (${_sharedWithMe.length})'),
              Tab(key: TourKeys.matchesMatchedTabKey, text: '${AppLocalizations.of(context)?.matched ?? 'Matched'} (${_matchedProfiles.length})'),
            ],
          ),
        ),
        // Tab content
        Expanded(
          child: _isLoading
              ? ListView.separated(
                  padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
                  itemCount: 5,
                  separatorBuilder: (context, index) => SizedBox(height: 2.h),
                  itemBuilder: (context, index) => ShimmerWidget.rectangular(
                    height: 12.h,
                    shapeBorder: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
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

    // Apply search filter
    final filteredList = _searchQuery.isEmpty
        ? displayProfiles
        : displayProfiles.where((profile) {
            final name = (isSharedByMe ?? true)
                ? (profile['recipientName'] as String? ?? '').toLowerCase()
                : (profile['senderName'] as String? ?? '').toLowerCase();
            final profileName = (profile['sharedProfileName'] as String? ?? '')
                .toLowerCase();
            final query = _searchQuery.toLowerCase();
            return name.contains(query) || profileName.contains(query);
          }).toList();

    if (filteredList.isEmpty) {
      return EmptyStateWidget(
        isSharedByMe: isSharedByMe ?? true,
        isMatched: isSharedByMe == null,
        onStartSharing: () {
          Navigator.of(context, rootNavigator: true).pushNamed(AppRoutes.home);
        },
      );
    }

    return BrandedRefreshIndicator(
      onRefresh: _handleRefresh,
      child: ListView.separated(
        padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
        itemCount: filteredList.length,
        separatorBuilder: (context, index) => SizedBox(height: 2.h),
        itemBuilder: (context, index) {
          final profile = filteredList[index];
          final shareId = profile['id']?.toString() ?? '';
          final allShareIds =
              (profile['allShareIds'] as List<dynamic>?)
                  ?.map((e) => e.toString())
                  .toList() ??
              [shareId];
          final isSelected = allShareIds.any(
            (id) => _selectedItems.contains(id),
          );

          return RepaintBoundary(
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
                          debugPrint('Marked share $id as viewed');
                        },
                        onFailure: (err) async {
                          debugPrint('Failed to mark share $id: $err');
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
                        debugPrint('Failed to delete share $id: $err');
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
          );
        },
      ),
    );
  }
}
