import 'package:flutter/foundation.dart';
import 'package:banjarabio/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:sizer/sizer.dart';
import 'dart:async';
import 'dart:math' as math;

import 'package:banjarabio/core/app_export.dart';
import 'package:banjarabio/core/data/location_data.dart';
import 'package:banjarabio/core/utils/tour_keys.dart';
import 'package:banjarabio/core/models/filter_criteria.dart';
import 'package:banjarabio/core/models/profile_model.dart';
import 'package:banjarabio/core/repositories/profile_repository.dart';
import 'package:banjarabio/core/repositories/photo_repository.dart';

import 'package:banjarabio/core/repositories/share_repository.dart';
import 'package:banjarabio/core/repositories/usage_repository.dart';
import 'package:banjarabio/core/services/scroll_velocity_service.dart';
import 'package:banjarabio/core/services/local_cache_service.dart';
import 'package:banjarabio/core/services/startup_orchestrator.dart';
import 'package:banjarabio/core/services/share_service.dart';
import 'package:banjarabio/core/services/deep_link_service.dart';
import 'package:banjarabio/features/bookmarks/providers/bookmark_notifier.dart';
import 'package:banjarabio/widgets/upgrade_dialog.dart';
import 'package:banjarabio/widgets/shimmer_widget.dart';
import 'package:banjarabio/presentation/home_screen/widgets/empty_state_widget.dart';
import 'package:banjarabio/presentation/home_screen/widgets/profile_card_widget.dart';
import 'package:banjarabio/presentation/home_screen/widgets/swipeable_card_deck.dart';
import 'package:banjarabio/presentation/home_screen/widgets/daily_match_widget.dart';
import 'package:banjarabio/presentation/home_screen/widgets/instagram_follow_interstitial.dart';
import 'package:banjarabio/presentation/home_screen/widgets/guest_restricted_dialog.dart';
import 'package:banjarabio/presentation/home_screen/widgets/offer_banner_widget.dart';
import 'package:banjarabio/widgets/ads/banner_ad_widget.dart';
import 'package:banjarabio/presentation/filter_screen/filter_screen.dart';
import 'package:banjarabio/presentation/home_screen/location_selection_screen.dart';
import 'package:banjarabio/widgets/branded_refresh_indicator.dart';
import 'package:banjarabio/notification/features/notification_bridge.dart';
import 'package:banjarabio/core/models/daily_reward_model.dart';
import 'package:banjarabio/core/repositories/daily_reward_repository.dart';
import 'package:banjarabio/widgets/daily_reward_dialog.dart';


class HomeScreenInitialPage extends ConsumerStatefulWidget {
  final ProfileRepository? profileRepository;
  final ShareRepository? shareRepository;
  final UsageRepository? usageRepository;
  final PhotoRepository? photoRepository;

  const HomeScreenInitialPage({
    super.key,
    this.profileRepository,
    this.shareRepository,
    this.usageRepository,
    this.photoRepository,
  });

  @override
  ConsumerState<HomeScreenInitialPage> createState() =>
      _HomeScreenInitialPageState();
}

class _HomeScreenInitialPageState extends ConsumerState<HomeScreenInitialPage>
    with WidgetsBindingObserver {
  @visibleForTesting
  Future<void> loadData() => _loadData();

  @visibleForTesting
  set profiles(List<ProfileModel> value) {
    setState(() {
      _profiles = value;
      _isLoading = false;
    });
  }

  @visibleForTesting
  bool get isLoading => _isLoading;
  @visibleForTesting
  int get profilesLength => _profiles.length;

  late final ScrollController _scrollController = ScrollController();
  late final ProfileRepository _profileRepository;
  late final ShareRepository _shareRepository;
  late final UsageRepository _usageRepository;


  bool _isLoading = true;
  bool _isFetchingMore = false;
  bool _hasMore = true;
  static const int _pageSize = 20;
  static const int _initialPageSize = 8; // 🚨 SIGNAL 3 FIX: Fewer cards on first paint
  String? _lastCreatedAt;
  bool _hasLoaded = false;

  bool _isLocationOverridden = true;
  bool _isSwipeMode = false; // Default to Grid mode (user request)
  int _selectedTab = 0; // 0 = Recommended, 1 = Daily
  String? _errorMessage;
  List<ProfileModel> _profiles = [];
  ProfileModel? _ownProfile;
  DailyRewardModel? _dailyRewardStatus;

  final Set<String> _enrichingIds = {};
  Timer? _batchTimer;
  final List<ProfileModel> _batchEnrichedProfiles = [];
  Timer? _shimmerFallback;

  // Search and Location state
  final TextEditingController _searchController = TextEditingController();
  Timer? _debounce;

  // Filter state
  FilterCriteria _currentFilters = const FilterCriteria();

  // Filter options

  @override
  void initState() {
    super.initState();
    _profileRepository = widget.profileRepository ?? ProfileRepository();
    _shareRepository = widget.shareRepository ?? ShareRepository();
    _usageRepository = widget.usageRepository ?? UsageRepository();

    _scrollController.addListener(_onScroll);
    WidgetsBinding.instance.addObserver(this);

    DeepLinkService().onRewardsTriggered = () {
      if (mounted) _handleRewardsDeepLink();
    };

    // 🚀 Register Data Load with Orchestrator — FIRE AND FORGET
    // Do NOT await _loadData(). Awaiting kept the orchestrator blocked for
    // 1.7+ seconds, contributing to cumulative main-thread time that triggers
    // Signal 3 on OEM Android skins. Data loads asynchronously and calls
    // setState() when ready — the shimmer placeholder handles the UX.
    StartupOrchestrator().registerTask(StartupPhase.interactive, () async {
      if (!mounted || _hasLoaded) return;
      _hasLoaded = true;
      // Fire and forget — don't await
      Future.wait([
        _loadData(),
        _loadDailyRewardStatus(),
      ]).then((_) {
        if (mounted) {
          _checkInstagramPrompt();
          _checkPostStartupRewards();
        }
      });
    });

    DeepLinkService().onRewardsTriggered = () {
      if (mounted) _handleRewardsDeepLink();
    };

    // 🧬 SAFETY FALLBACK (10M DAU): Prevent infinite shimmer if orchestrator tasks hang
    _shimmerFallback = Timer(const Duration(seconds: 10), () {
      if (mounted && _isLoading && _profiles.isEmpty) {
        debugPrint('⚠️ HomeScreen: Shimmer safety fallback triggered');
        setState(() => _isLoading = false);
      }
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _checkPostStartupRewards();
    }
  }

  void _checkPostStartupRewards() {
    if (LocalCacheService().getPendingRewardsFlag()) {
      _handleRewardsDeepLink();
    }
  }

  void _handleRewardsDeepLink() {
    LocalCacheService().clearPendingRewardsFlag();
    if (_dailyRewardStatus != null && !_dailyRewardStatus!.isClaimedToday) {
      DailyRewardDialog.show(context, _dailyRewardStatus!).then((updatedStatus) {
        if (updatedStatus != null && mounted) {
          setState(() => _dailyRewardStatus = updatedStatus);
        }
      });
    }
  }

  Future<void> _loadDailyRewardStatus() async {
    if (LocalCacheService().isGuestMode()) return;
    final res = await DailyRewardRepository().getRewardStatus();
    if (mounted && res.isSuccess) {
      setState(() {
        _dailyRewardStatus = res.data;
      });
      // Optionally auto-show if not claimed today and it's their first session
      if (_dailyRewardStatus != null && !_dailyRewardStatus!.isClaimedToday) {
         // Could show dialog automatically, but we'll let them click the icon for now.
      }
    }
  }

  Future<void> _checkInstagramPrompt() async {
    // Small delay to ensure UI is ready and data might be loaded
    await Future.delayed(const Duration(seconds: 4));
    if (!mounted) return;

    final ownProfile = _ownProfile;
    if (ownProfile == null || ownProfile.hasFollowedInstagram) return;

    final lastPrompt = LocalCacheService().getLastInstagramPromptDate();
    final now = DateTime.now();

    if (lastPrompt == null || now.difference(lastPrompt).inDays >= 7) {
      if (mounted) {
        await Navigator.push(
          context,
          PageRouteBuilder(
            opaque: false,
            pageBuilder: (context, animation, secondaryAnimation) => const InstagramFollowInterstitial(),
            transitionsBuilder: (context, animation, _, child) {
              return FadeTransition(opacity: animation, child: child);
            },
          ),
        );
        await LocalCacheService().saveLastInstagramPromptDate(now);
      }
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    _debounce?.cancel();
    _batchTimer?.cancel();
    _shimmerFallback?.cancel();
    WidgetsBinding.instance.removeObserver(this);
    // 🧬 PERFORMANCE: Removed aggressive image cache clearing during dispose.
    // Clearing the entire cache synchronously can block the main thread 
    // and trigger ANRs during UI transitions. We rely on the 500-item 
    // memory guardrail in _loadData for gradual pruning.
    super.dispose();
  }

  void _onScroll() {
    if (_isSwipeMode || _selectedTab != 0) return;
    
    // 🚨 SIGNAL 3 FIX: Prevent automatic precaching during layout attachment.
    // Flutter triggers _onScroll automatically when the SliverGrid mounts and establishes its size.
    // We strictly require that the user has actually moved the viewport before we
    // unleash intense concurrent photo precaching tasks onto the isolate pool.
    if (_scrollController.position.pixels <= 0) return;
    
    // 🧬 PERFORMANCE: Pre-fetch next page when 70% through
    final triggerThreshold = _scrollController.position.maxScrollExtent * 0.7;
    
    if (_scrollController.position.pixels >= triggerThreshold &&
        !_isFetchingMore &&
        _hasMore &&
        !_isLoading) {
      _loadMoreProfiles();
    }

    // 🧬 EXTREME PERFORMANCE: Trigger Predictive Enrichment
    // If user is within 10 cards of un-enriched content, trigger batch enrichment
    _triggerPredictiveEnrichment();

    // 🧬 EXTREME SCALE: Predictive Photo Pre-fetching
    // When user hits 70% of current scroll extent, precache next page images
    _triggerPredictivePhotoPrecache();
  }

  bool _isPredictivePrecaching = false;
  void _triggerPredictivePhotoPrecache() {
    // 🚨 MOTOROLA/ANDROID 15 FIX: Skip background precaching.
    if (WidgetsBinding.instance.lifecycleState != AppLifecycleState.resumed) {
      return;
    }
    if (_isPredictivePrecaching || _profiles.length < 5) return;
    
    // Find next block of 10-20 profiles that might need precaching
    final itemHeight = 450.0;
    final currentIndex = (_scrollController.offset / itemHeight).floor();
    final lookAheadStart = currentIndex + 5; // Start precaching 5 items ahead of current view
    final lookAheadEnd = math.min(lookAheadStart + 15, _profiles.length);

    if (lookAheadStart >= _profiles.length) return;

    final upcoming = _profiles.sublist(lookAheadStart, lookAheadEnd);
    final urlsToPrecache = upcoming
        .where((p) => p.photos.isNotEmpty)
        .map((p) => p.photos.first.publicUrl)
        .where((url) => url.isNotEmpty)
        .toList();

    if (urlsToPrecache.isNotEmpty) {
      _isPredictivePrecaching = true;
      CustomImageWidget.precachePhotos(context, urlsToPrecache).then((_) {
        // 🧬 PERFORMANCE: Added 2-second cooldown to prevent flood of 
        // precache requests during high-velocity scrolling.
        Future.delayed(const Duration(seconds: 2), () {
          if (mounted) _isPredictivePrecaching = false;
        });
      }).catchError((_) {
        if (mounted) _isPredictivePrecaching = false;
      });
    }
  }

  bool _isPredictiveEnriching = false;
  void _triggerPredictiveEnrichment() {
    // 🚨 MOTOROLA/ANDROID 15 FIX: Skip background enrichment.
    if (WidgetsBinding.instance.lifecycleState != AppLifecycleState.resumed) {
      return;
    }
    if (_isPredictiveEnriching || _profiles.length < 5) return;

    // Find first 5 un-enriched profiles in the visible vicinity + buffer
    // We look at the current scroll position to guess the visible range
    final itemHeight = 450.0; // Rough estimate of ProfileCardWidget height
    final currentIndex = (_scrollController.offset / itemHeight).floor();
    final lookAheadStart = currentIndex + 3;
    final lookAheadEnd = math.min(lookAheadStart + 10, _profiles.length);

    if (lookAheadStart >= _profiles.length) return;

    final upcoming = _profiles.sublist(lookAheadStart, lookAheadEnd);
    final needsEnrichment = upcoming.where((p) => !p.isEnriched && !_enrichingIds.contains(p.id)).toList();

    if (needsEnrichment.length >= 3) {
      _isPredictiveEnriching = true;
      _profileRepository.predictiveEnrichment(needsEnrichment).then((_) {
        if (mounted) {
          setState(() {
            _isPredictiveEnriching = false;
            // The repository updated its internal _cachedFeed, but we need to update our local _profiles
            // Note: In a real app, you might use a Provider for the feed which would auto-notify.
            // Here we just sync the items that were enriched.
            for (final p in needsEnrichment) {
              final idx = _profiles.indexWhere((orig) => orig.id == p.id);
              if (idx != -1) {
                // Fetch the now-enriched profile from memory cache
                // This is a bit indirect, but safe.
              }
            }
            // Force a rebuild to pick up the cache changes (ProfileCardWidget calls getProfileMetadata)
            _profiles = List.from(_profiles);
          });
        }
      }).catchError((_) {
        _isPredictiveEnriching = false;
      });
    }
  }

  Future<void> _loadData({bool clearCache = false, bool isLoadMore = false}) async {
    if (clearCache) {
      // 🧬 PERFORMANCE: Removed global imageCache.clear() for pull-to-refresh.
      // Flutter's ImageProvider will handle re-fetching if the key changes.
    }

    if (isLoadMore) {
      if (_isFetchingMore || !_hasMore) return;
      setState(() {
        _isFetchingMore = true;
      });
    } else {
      setState(() {
        // 🧬 PRO SCALE: Stale-While-Revalidate (SWR) logic
        // If we already have profiles (from disk cache), DON'T show full-screen spinner.
        // This makes the transition feel instant.
        if (_profiles.isEmpty) {
          _isLoading = true;
        }
        _errorMessage = null;
        _lastCreatedAt = null;
        _hasMore = true;
      });
    }

    try {
      final bool isGuest = LocalCacheService().isGuestMode();

      // 🧬 PERFORMANCE: redundant _ownProfile fetch removed.
      // ProfileRepository.getProfiles now fetches it in parallel internally.

      // Get profiles with location fallback to user's own details if none selected AND not overridden
      // 🚀 GUEST FIX: Skip location fallback for guests (they have no profile)
      FilterCriteria applyFilters = _currentFilters;
      if (!isGuest &&
          !_isLocationOverridden &&
          _currentFilters.state == null &&
          _currentFilters.district == null &&
          _currentFilters.taluka == null &&
          _ownProfile != null) {
        applyFilters = _currentFilters.copyWith(
          state: _ownProfile!.state,
          district: _ownProfile!.district,
          taluka: _ownProfile!.taluka,
        );
      }

      // 🚀 GUEST FIX: Wrap in tight timeout to prevent 235s hang for guest users
      final result = await _profileRepository.getProfiles(
        // 🚨 SIGNAL 3 FIX: Use smaller page for initial load to reduce concurrent image decodes
        limit: isLoadMore ? _pageSize : _initialPageSize,
        lastCreatedAt: isLoadMore ? _lastCreatedAt : null,
        filters: applyFilters,
        searchQuery: _searchController.text,
      ).timeout(
        Duration(seconds: isGuest ? 10 : 30),
        onTimeout: () {
          debugPrint('⚠️ _loadData: Timed out${isGuest ? " (guest mode)" : ""}');
          return BackendResponse.success(<ProfileModel>[]);
        },
      );

      if (mounted) {
        result.fold(
          onSuccess: (allProfiles) {
            final profiles =
                allProfiles.where((p) => p.id != _ownProfile?.id).toList();
            
            // 💉 PERFORMANCE: Defer bookmark state merging to avoid event loop starvation
            // during critical UI build of 20 profile cards.
            Future.delayed(const Duration(seconds: 1), () {
              if (!mounted) return;
              try {
                final current = ref.read(bookmarkNotifierProvider);
                final merged = Map<String, bool>.from(current);
                bool changed = false;
                for (final p in profiles) {
                  if (merged[p.id] != p.isBookmarked) {
                    merged[p.id] = p.isBookmarked;
                    changed = true;
                  }
                }
                if (changed) {
                  ref.read(bookmarkNotifierProvider.notifier).initializeBookmarks(merged);
                }
              } catch (_) {}
            });

            setState(() {
              if (isLoadMore) {
                _profiles.addAll(profiles);
                _isFetchingMore = false;
                
                // 🧬 EXTREME SCALE: Memory Safety Guardrail
                if (_profiles.length > 500) {
                  _profiles = _profiles.sublist(_profiles.length - 200);
                  // 🧬 PERFORMANCE: Removed redundant imageCache.clear() here.
                  // GlobalWatchdog handles emergency pruning if the UI actually stutters.
                  // Manual clearing during setState causes a massive re-decode spike.
                }
              } else {
                _profiles = profiles;
              }
              // 🧬 FIX: Always clear isLoading if we have data to display
              _isLoading = false;
              _hasMore = allProfiles.length >= (isLoadMore ? _pageSize : _initialPageSize);
              if (allProfiles.isNotEmpty) {
                _lastCreatedAt = allProfiles.last.createdAt.toIso8601String();
              }
            });

            // 🚨 ANR / SIGNAL 3 FIX: Removed _precacheInitialImages and _enrichProfileLazy from
            // a 3-second delayed timer. Firing parallel isolate loads for 5 massive JPEGs
            // exactly at runtime T+3s completely starves the CPU cores, triggering an immediate
            // ANR Kill from the Android OS. We now rely strictly on viewport lazy-loading
            // via CachedNetworkImage inside ProfileCardWidget to deserialize images one by one.
          },
          onFailure: (error) {
            setState(() {
              if (isLoadMore) {
                _isFetchingMore = false;
              } else {
                _errorMessage = 'Failed to load profiles';
                _isLoading = false;
              }
            });
          },
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          if (isLoadMore) {
            _isFetchingMore = false;
          } else {
            _errorMessage = AppLocalizations.of(context)?.failedToLoadProfiles ?? 'Failed to load profiles';
            _isLoading = false;
          }
        });
      }
    }
  }

  Future<void> _loadMoreProfiles() async {
    await _loadData(isLoadMore: true);
  }

  void _clearFilters() {
    setState(() {
      _currentFilters = const FilterCriteria();
      _searchController.clear();
    });
    _loadData(clearCache: true);
  }

  int get _activeFilterCount {
    if (_currentFilters.isEmpty) return 0;
    int count = 0;
    if (_currentFilters.minAge != null || _currentFilters.maxAge != null) {
      count++;
    }
    if (_currentFilters.education?.isNotEmpty ?? false) count++;
    if (_currentFilters.profession?.isNotEmpty ?? false) count++;
    if (_currentFilters.state != null) count++;
    if (_currentFilters.maritalStatus != null) count++;
    return count;
  }

  Map<String, String> get _activeFiltersMap {
    final filters = <String, String>{};
    if (_currentFilters.minAge != null || _currentFilters.maxAge != null) {
      filters['Age'] =
          '${_currentFilters.minAge ?? 18}-${_currentFilters.maxAge ?? '+'}';
    }
    if (_currentFilters.education?.isNotEmpty ?? false) {
      filters['Education'] = _currentFilters.education!.first;
    }
    if (_currentFilters.profession?.isNotEmpty ?? false) {
      filters['Profession'] = _currentFilters.profession!.first;
    }
    if (_currentFilters.maritalStatus != null) {
      filters['Marital'] = _currentFilters.maritalStatus!;
    }
    return filters;
  }

  Future<void> _toggleBookmark(
    String profileId,
    bool isCurrentlyBookmarked,
  ) async {
    if (LocalCacheService().isGuestMode()) {
      GuestRestrictedDialog.show(context);
      return;
    }
    
    HapticFeedback.lightImpact();
    // 🧬 PERFORMANCE: Use microtask to ensure haptic/UI feedback is prioritized
    // before the heavy Riverpod/Supabase operation starts.
    Future.microtask(() async {
      try {
        await ref.read(bookmarkNotifierProvider.notifier).toggle(profileId);
      } catch (e) {
        if (kDebugMode) {
          debugPrint('[BOOKMARK] HomeScreenInitialPage > toggle($profileId) > FAILED | $e');
        }
        if (mounted) {
          Fluttertoast.showToast(
            msg: AppLocalizations.of(context)?.failedToUpdateBookmark(e.toString()) ?? 'Failed to update bookmark: $e',
            backgroundColor: Theme.of(context).colorScheme.error,
            textColor: Colors.white,
          );
        }
      }
    });
  }

  void _enrichProfileLazy(ProfileModel profile) async {
    if (profile.isEnriched || _enrichingIds.contains(profile.id)) return;
    _enrichingIds.add(profile.id);
    
    final enriched = await _profileRepository.getProfileMetadata(profile);
    
    if (mounted) {
      _batchEnrichedProfiles.add(enriched);
      
      // 🚨 Aggressive Batching: 500ms buffer to prevent "rebuild storm"
      _batchTimer?.cancel();
      _batchTimer = Timer(const Duration(milliseconds: 500), () {
        if (!mounted) return;
        
        setState(() {
          for (final p in _batchEnrichedProfiles) {
            final idx = _profiles.indexWhere((orig) => orig.id == p.id);
            if (idx != -1) {
              _profiles[idx] = p;
            }
            _enrichingIds.remove(p.id);
          }
          _batchEnrichedProfiles.clear();
          _profiles = List.from(_profiles);
        });
      });
    }
  }





  Future<void> _handleRefresh() async {
    await _loadData();
  }

  void _onSearchChanged(String query) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      _loadData();
    });
  }

  String _getUserLocationLabel() {
    // 1. Check if we have an active filter override (from Location Selection Screen)
    if (_isLocationOverridden) {
      if (_currentFilters.taluka != null && _currentFilters.district != null) {
        return LocationData.getLocalizedFullLocation(
          '${_currentFilters.taluka}, ${_currentFilters.district}',
          context,
        );
      }
      if (_currentFilters.taluka != null) return LocationData.getLocalizedName(_currentFilters.taluka!, context);
      if (_currentFilters.district != null) return LocationData.getLocalizedName(_currentFilters.district!, context);
      if (_currentFilters.state != null) return LocationData.getLocalizedName(_currentFilters.state!, context);
      return AppLocalizations.of(context)?.allIndia ?? 'All India';
    }

    // 2. Fallback to User's Own Location (Formatted without village)
    if (_ownProfile != null) {
      if (_ownProfile!.taluka != null && _ownProfile!.district != null) {
        return LocationData.getLocalizedFullLocation(
          '${_ownProfile!.taluka}, ${_ownProfile!.district}',
          context,
        );
      }
      return LocationData.getLocalizedName(_ownProfile!.taluka, context).isNotEmpty 
          ? LocationData.getLocalizedName(_ownProfile!.taluka, context)
          : LocationData.getLocalizedName(_ownProfile!.district, context).isNotEmpty
              ? LocationData.getLocalizedName(_ownProfile!.district, context)
              : LocationData.getLocalizedName(_ownProfile!.state, context).isNotEmpty
                  ? LocationData.getLocalizedName(_ownProfile!.state, context)
                  : (AppLocalizations.of(context)?.allIndia ?? 'All India');
    }

    return AppLocalizations.of(context)?.allIndia ?? 'All India';
  }

  void _openLocationSelection() async {
    final Map<String, String?>? result =
        await Navigator.push<Map<String, String?>>(
          context,
          MaterialPageRoute(
            builder: (context) => const LocationSelectionScreen(),
          ),
        );

    if (result != null) {
      setState(() {
        _isLocationOverridden = true;
        // Use direct constructor to allow nulls from result to override/clear old values
        // copyWith would preserve old values if result has nulls
        _currentFilters = FilterCriteria(
          minAge: _currentFilters.minAge,
          maxAge: _currentFilters.maxAge,
          gender: _currentFilters.gender,
          education: _currentFilters.education,
          profession: _currentFilters.profession,
          hasPhoto: _currentFilters.hasPhoto,
          maritalStatus: _currentFilters.maritalStatus,
          state: result['state'],
          district: result['district'],
          taluka: result['taluka'],
        );
      });

    // 🧬 EXTREME SCALE: Monitor Scroll Velocity
    ScrollVelocityService.instance.attach(_scrollController);

    // Initial load
    _loadData();
    }
  }

  void _openFilterSheet() async {
    final result = await Navigator.push<FilterCriteria>(
      context,
      MaterialPageRoute(
        builder: (context) => FilterScreen(initialFilters: _currentFilters),
      ),
    );

    if (result != null) {
      setState(() {
        _currentFilters = result;
        if (result.searchQuery != null) {
          _searchController.text = result.searchQuery!;
        }
      });
      _loadData();
    }
  }

  void _openProfileDetail(ProfileModel profile) async {
    if (LocalCacheService().isGuestMode()) {
      GuestRestrictedDialog.show(context);
      return;
    }

    // Check view limits
    final usageRepo = _usageRepository;
    final canViewRes = await usageRepo.canViewProfile();

    canViewRes.fold(
      onSuccess: (canView) async {
        if (!canView && mounted) {
          final remainingRes = await usageRepo.getRemainingProfileViews();
          remainingRes.fold(
            onSuccess: (remaining) {
              if (mounted) {
                UpgradeDialog.showProfileViewLimit(context, remaining);
              }
            },
            onFailure: (error) =>
                debugPrint('Error fetching remaining views: $error'),
          );
          return;
        }

        // Increment view count (Fire and forget, don't await)
        if (mounted) {
          usageRepo.incrementProfileView().then((result) {
            if (!result.isSuccess) {
              debugPrint(
                'Background increment view failed: ${result.errorMessage}',
              );
            }
          });
        }

        if (mounted) {
          Navigator.of(
            context,
            rootNavigator: true,
          ).pushNamed(AppRoutes.profileDetail, arguments: profile.toDisplayMap()).then((_) {
            // Refresh to update bookmark status if changed
            _loadData(); // Reload allows seeing latest bookmark status
          });
        }
      },
      onFailure: (error) {
        if (mounted) {
          Fluttertoast.showToast(
            msg: AppLocalizations.of(context)?.errorCheckingViewLimits(error.toString()) ?? 'Error checking view limits: $error',
            backgroundColor: Theme.of(context).colorScheme.error,
            textColor: Colors.white,
          );
        }
      },
    );
  }

  void _showSharingOptions(ProfileModel profile) {
    if (LocalCacheService().isGuestMode()) {
      GuestRestrictedDialog.show(context);
      return;
    }

    HapticFeedback.selectionClick();
    // 🧬 PERFORMANCE: Use microtask to show sheet after haptic feedback haptic
    Future.microtask(() {
      if (!mounted) return;
      final theme = Theme.of(context);

      showModalBottomSheet(
        context: context,
        useRootNavigator: true,
        backgroundColor: Colors.transparent,
        builder: (ctx) => Container(
        padding: EdgeInsets.all(4.w),
        decoration: BoxDecoration(
          color: theme.bottomSheetTheme.backgroundColor ?? theme.cardColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              margin: EdgeInsets.only(bottom: 2.h),
              decoration: BoxDecoration(
                color: theme.dividerColor,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Text(AppLocalizations.of(context)?.shareProfile ?? 'Share Profile',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 2.h),
            _buildShareOption(
              ctx,
              'WhatsApp Status Card (Premium)',
              'share',
              profile,
              'whatsapp_status_card',
            ),
            _buildShareOption(
              ctx,
              AppLocalizations.of(context)?.whatsApp ?? 'WhatsApp',
              'share',
              profile,
              'whatsapp',
            ),
            _buildShareOption(
              ctx,
              AppLocalizations.of(context)?.copyLink ?? 'Copy Link',
              'link',
              profile,
              'link',
            ),
            SizedBox(height: 2.h),
          ],
        ),
      ),
      );
    });
  }
  Widget _buildShareOption(
    BuildContext ctx,
    String title,
    String icon,
    ProfileModel profile,
    String method,
  ) {
    final profileId = profile.id;
    final profileName = profile.fullName;
    final theme = Theme.of(ctx);
    return ListTile(
      leading: Container(
        padding: EdgeInsets.all(1.2.h),
        decoration: BoxDecoration(
          color: theme.colorScheme.primary.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: CustomIconWidget(
          iconName: icon,
          color: theme.colorScheme.primary,
        ),
      ),
      title: Text(title, style: theme.textTheme.bodyLarge),
      trailing: CustomIconWidget(
        iconName: 'chevron_right',
        color: theme.colorScheme.onSurfaceVariant,
        size: 20,
      ),
      onTap: () async {
        Navigator.pop(ctx);
        try {
          // Check share limits first
          final usageRepo = _usageRepository;
          final canShareRes = await usageRepo.canShareProfile();

          canShareRes.fold(
            onSuccess: (canShare) async {
              if (!canShare) {
                final remainingRes = await usageRepo.getRemainingShares();
                remainingRes.fold(
                  onSuccess: (remaining) {
                    if (mounted) {
                      UpgradeDialog.showShareLimit(context, remaining);
                    }
                  },
                  onFailure: (error) =>
                      debugPrint('Error fetching remaining shares: $error'),
                );
                return;
              }

              if (method == 'whatsapp_status_card') {
                if (mounted) {
                  await ShareService().shareProfileStatus(context, profile);
                }
                return;
              }

              final shareResponse = await _shareRepository.shareProfile(
                sharedProfileId: profileId,
                sharingMethod: method,
                recipientName: '$title Contact',
                recipientRelation: 'Contact',
                profileName: profileName,
              );

              shareResponse.fold(
                onSuccess: (_) {
                  if (mounted) {
                    final l10n = AppLocalizations.of(context);
                    String successMsg = l10n?.profileSharedVia(profileName, title) ?? 'Shared $profileName via $title';
                    if (method == 'link') {
                      successMsg = l10n?.profileLinkCopied ?? 'Profile link copied to clipboard!';
                    }
                    if (method == 'in_app') {
                      successMsg = l10n?.profileSharedWith(profileName) ?? 'Profile shared with $profileName';
                    }

                    Fluttertoast.showToast(
                      msg: successMsg,
                      backgroundColor: Colors.green,
                      textColor: Colors.white,
                    );
                  }
                },
                onFailure: (error) {
                  if (mounted) {
                    Fluttertoast.showToast(
                      msg: AppLocalizations.of(context)?.shareFailed(error.toString()) ?? 'Share failed: $error',
                      backgroundColor: Theme.of(context).colorScheme.error,
                      textColor: Colors.white,
                    );
                  }
                },
              );
            },
            onFailure: (error) {
              if (mounted) {
                Fluttertoast.showToast(
                  msg: AppLocalizations.of(context)?.errorCheckingShareLimits(error.toString()) ?? 'Error checking share limits: $error',
                  backgroundColor: Theme.of(context).colorScheme.error,
                  textColor: Colors.white,
                );
              }
            },
          );
        } catch (e) {
          debugPrint('Share error: $e');
          if (mounted) {
            Fluttertoast.showToast(
              msg: e.toString().replaceAll('Exception: ', ''),
              backgroundColor: Theme.of(context).colorScheme.error,
              textColor: Colors.white,
            );
          }
        }
      },
    );
  }

  void _handleInterest(ProfileModel profile) {
    if (LocalCacheService().isGuestMode()) {
      GuestRestrictedDialog.show(context);
      return;
    }

    HapticFeedback.mediumImpact();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(AppLocalizations.of(context)?.interestConfirmationTitle ?? 'Express Interest?'),
        content: Text(AppLocalizations.of(context)?.interestConfirmationMessage(profile.fullName) ?? 'This will share your profile with ${profile.fullName} and allow them to connect with you. Are you sure?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(AppLocalizations.of(context)?.cancel ?? 'Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              _executeInterest(profile);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.primary,
              foregroundColor: Theme.of(context).colorScheme.onPrimary,
            ),
            child: Text(AppLocalizations.of(context)?.confirm ?? 'Confirm'),
          ),
        ],
      ),
    );
  }

  Future<void> _executeInterest(ProfileModel profile) async {
    try {
      final usageRepo = _usageRepository;
      final canShareRes = await usageRepo.canShareProfile();

      await canShareRes.fold(
        onSuccess: (canShare) async {
          if (!canShare) {
            final remainingRes = await usageRepo.getRemainingShares();
            remainingRes.fold(
              onSuccess: (remaining) {
                if (mounted) {
                  UpgradeDialog.showShareLimit(context, remaining);
                }
              },
              onFailure: (error) => debugPrint('Error fetching remaining shares: $error'),
            );
            return;
          }

          final shareResponse = await _shareRepository.shareProfile(
            sharedProfileId: profile.id,
            sharingMethod: 'in_app',
            recipientName: profile.fullName,
            recipientRelation: 'Interest',
            profileName: profile.fullName,
          );

          shareResponse.fold(
            onSuccess: (_) {
              if (mounted) {
                Fluttertoast.showToast(
                  msg: AppLocalizations.of(context)?.interestShared(profile.fullName) ?? 'Interest shared with ${profile.fullName}!',
                  backgroundColor: Colors.green,
                  textColor: Colors.white,
                );
              }
            },
            onFailure: (error) {
              if (mounted) {
                Fluttertoast.showToast(
                  msg: AppLocalizations.of(context)?.shareFailed(error.toString()) ?? 'Share failed: $error',
                  backgroundColor: Theme.of(context).colorScheme.error,
                  textColor: Colors.white,
                );
              }
            },
          );
        },
        onFailure: (error) {
          if (mounted) {
            Fluttertoast.showToast(
              msg: AppLocalizations.of(context)?.errorCheckingShareLimits(error.toString()) ?? 'Error checking share limits: $error',
              backgroundColor: Theme.of(context).colorScheme.error,
              textColor: Colors.white,
            );
          }
        },
      );
    } catch (e) {
      if (mounted) {
        Fluttertoast.showToast(msg: 'Error: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    // Bookmark UI updates via ref.watch(isBookmarkedProvider) per card - no ref.listen needed
    return BrandedRefreshIndicator(
      onRefresh: _handleRefresh,
      child: CustomScrollView(
        controller: _scrollController,
        physics: const AlwaysScrollableScrollPhysics(),
        slivers: [
          // Header with Search, Location and Filter - Hides on scroll
          SliverAppBar(
            floating: true,
            snap: true,
            automaticallyImplyLeading: false,
            backgroundColor: theme.appBarTheme.backgroundColor,
            expandedHeight:
                15.h, // Dynamic: 15% of screen height for adaptive layout
            elevation: 0,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      theme.colorScheme.primary,
                      theme.colorScheme.primary.withValues(alpha: 0.8),
                    ],
                  ),
                  borderRadius: const BorderRadius.vertical(bottom: Radius.circular(32)),
                  boxShadow: [
                    BoxShadow(
                      color: theme.colorScheme.primary.withValues(alpha: 0.2),
                      blurRadius: 15,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                padding: EdgeInsets.fromLTRB(4.w, 0, 4.w, 2.h),
                child: SafeArea(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Location Selector Row with Branding
                      Padding(
                        padding: EdgeInsets.symmetric(vertical: 0.1.h),
                        child: Row(
                          children: [
                            // Location Clickable Area
                            Expanded(
                              child: InkWell(
                                key: TourKeys.locationKey,
                                onTap: _openLocationSelection,
                                borderRadius: BorderRadius.circular(12),
                                child: Row(
                                  children: [
                                    Container(
                                      padding: EdgeInsets.all(1.h),
                                      decoration: BoxDecoration(
                                        color: Colors.white.withValues(
                                          alpha: 0.15,
                                        ),
                                        shape: BoxShape.circle,
                                      ),
                                      child: const Icon(
                                        Icons.location_on_rounded,
                                        color: Colors.white,
                                        size: 20,
                                      ),
                                    ),
                                    SizedBox(width: 3.w),
                                    Expanded(
                                      child: Row(
                                        children: [
                                          Flexible(
                                            child: Text(
                                              _getUserLocationLabel(),
                                              style: theme
                                                  .textTheme
                                                  .titleMedium
                                                  ?.copyWith(
                                                    color: Colors.white,
                                                    fontWeight:
                                                        FontWeight.w700,
                                                    fontSize: 13.sp,
                                                  ),
                                              maxLines: 1,
                                              overflow:
                                                  TextOverflow.ellipsis,
                                            ),
                                          ),
                                          SizedBox(width: 1.w),
                                          const Icon(
                                            Icons
                                                .keyboard_arrow_down_rounded,
                                            color: Colors.white70,
                                            size: 18,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            // Brand & Support Icons - Remove Flexible to prevent competing for space with Location text
                            // Changed to MainAxisSize.min to take only necessary space
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                // Category 1: Brand & Support Icons
                                  Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      // Daily Rewards
                                      if (_dailyRewardStatus != null)
                                        InkWell(
                                          onTap: () async {
                                            final updatedStatus = await DailyRewardDialog.show(context, _dailyRewardStatus!);
                                            if (updatedStatus != null && mounted) {
                                              setState(() {
                                                _dailyRewardStatus = updatedStatus;
                                              });
                                            }
                                          },
                                          borderRadius: BorderRadius.circular(50),
                                          child: Container(
                                            margin: EdgeInsets.only(right: 2.w),
                                            padding: EdgeInsets.all(0.8.h),
                                            child: Stack(
                                              clipBehavior: Clip.none,
                                              children: [
                                                Icon(
                                                  Icons.redeem_rounded,
                                                  color: _dailyRewardStatus!.isClaimedToday ? Colors.white70 : Colors.amber,
                                                  size: 26,
                                                ),
                                                if (!_dailyRewardStatus!.isClaimedToday)
                                                  Positioned(
                                                    right: -2,
                                                    top: -2,
                                                    child: Container(
                                                      width: 10,
                                                      height: 10,
                                                      decoration: const BoxDecoration(
                                                        color: Colors.red,
                                                        shape: BoxShape.circle,
                                                      ),
                                                    ),
                                                  ),
                                              ],
                                            ),
                                          ),
                                        ),
                                        
                                      // Notification Bell
                                      ListenableBuilder(
                                        listenable: NotificationBridge().historyStore,
                                        builder: (context, _) {
                                          final unreadCount = NotificationBridge().historyStore.unreadCount;
                                          return InkWell(
                                            onTap: () => Navigator.pushNamed(context, AppRoutes.activityHub),
                                            borderRadius: BorderRadius.circular(50),
                                            child: Container(
                                              padding: EdgeInsets.all(0.8.h),
                                              child: Stack(
                                                clipBehavior: Clip.none,
                                                children: [
                                                  const Icon(
                                                    Icons.notifications_none_rounded,
                                                    color: Colors.white,
                                                    size: 24,
                                                  ),
                                                  if (unreadCount > 0)
                                                    Positioned(
                                                      right: -2,
                                                      top: -2,
                                                      child: Container(
                                                        padding: const EdgeInsets.all(4),
                                                        decoration: const BoxDecoration(
                                                          color: Colors.white,
                                                          shape: BoxShape.circle,
                                                        ),
                                                        constraints: const BoxConstraints(
                                                          minWidth: 16,
                                                          minHeight: 16,
                                                        ),
                                                        child: Text(
                                                          unreadCount > 9 ? '9+' : unreadCount.toString(),
                                                          style: TextStyle(
                                                            color: theme.colorScheme.primary,
                                                            fontSize: 8,
                                                            fontWeight: FontWeight.bold,
                                                          ),
                                                          textAlign: TextAlign.center,
                                                        ),
                                                      ),
                                                    ),
                                                ],
                                              ),
                                            ),
                                          );
                                        },
                                      ),
                                      SizedBox(width: 2.w),
                                      // WhatsApp
                                      InkWell(
                                        key: TourKeys.whatsappKey,
                                        onTap: () async {
                                          final Uri url = Uri.parse('https://wa.me/8186050406');
                                          if (await canLaunchUrl(url)) {
                                            await launchUrl(url, mode: LaunchMode.externalApplication);
                                          }
                                        },
                                        borderRadius: BorderRadius.circular(50),
                                        child: Container(
                                          padding: EdgeInsets.all(0.8.h),
                                          decoration: BoxDecoration(
                                            color: Colors.white,
                                            shape: BoxShape.circle,
                                            boxShadow: [
                                              BoxShadow(
                                                color: Colors.black.withValues(alpha: 0.1),
                                                blurRadius: 4,
                                                offset: const Offset(0, 2),
                                              ),
                                            ],
                                          ),
                                          child: Image.asset(
                                            'assets/icons/whatsapp_icon.png',
                                            width: 20,
                                            height: 20,
                                          ),
                                        ),
                                      ),
                                      SizedBox(width: 1.5.w),
                                      // Instagram
                                      InkWell(
                                        key: TourKeys.instagramKey,
                                        onTap: () async {
                                          final Uri url = Uri.parse('https://www.instagram.com/banjarabio.matrimony/');
                                          if (await canLaunchUrl(url)) {
                                            await launchUrl(url, mode: LaunchMode.externalApplication);
                                          }
                                        },
                                        borderRadius: BorderRadius.circular(50),
                                        child: Container(
                                          padding: EdgeInsets.all(0.8.h),
                                          decoration: BoxDecoration(
                                            color: Colors.white,
                                            shape: BoxShape.circle,
                                            boxShadow: [
                                              BoxShadow(
                                                color: Colors.black.withValues(alpha: 0.1),
                                                blurRadius: 4,
                                                offset: const Offset(0, 2),
                                              ),
                                            ],
                                          ),
                                          child: Image.asset(
                                            'assets/icons/instagram_icon.png',
                                            width: 20,
                                            height: 20,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  
                                  // Subtle Visual Divider
                                  Container(
                                    height: 22,
                                    width: 1.5,
                                    margin: EdgeInsets.symmetric(horizontal: 2.w),
                                    decoration: BoxDecoration(
                                      color: Colors.white.withValues(alpha: 0.3),
                                      borderRadius: BorderRadius.circular(1),
                                    ),
                                  ),

                                  // Category 2: Personal Interaction (Chat)
                                  InkWell(
                                    key: TourKeys.chatKey,
                                    onTap: () {
                                      Navigator.of(
                                        context,
                                        rootNavigator: true,
                                      ).pushNamed(AppRoutes.conversationList);
                                    },
                                    borderRadius: BorderRadius.circular(50),
                                    child: Container(
                                      padding: EdgeInsets.all(0.8.h),
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        shape: BoxShape.circle,
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.black.withValues(alpha: 0.1),
                                            blurRadius: 4,
                                            offset: const Offset(0, 2),
                                          ),
                                        ],
                                      ),
                                      child: Image.asset(
                                        'assets/icons/chatting_icon.png',
                                        width: 22,
                                        height: 22,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      SizedBox(height: 0.5.h),
                      // Search Bar & Filter Row
                      Row(
                        children: [
                          Expanded(
                            child: Container(
                              key: TourKeys.searchKey,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(30),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.1),
                                    blurRadius: 10,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: TextField(
                                controller: _searchController,
                                onChanged: _onSearchChanged,
                                style: theme.textTheme.bodyLarge?.copyWith(
                                  fontWeight: FontWeight.w500,
                                ),
                                decoration: InputDecoration(
                                  hintText: AppLocalizations.of(context)?.searchProfiles ?? 'Search profiles...',
                                  hintStyle: theme
                                      .inputDecorationTheme
                                      .hintStyle
                                      ?.copyWith(fontSize: 11.sp),
                                  prefixIcon: Padding(
                                    padding: const EdgeInsets.only(
                                      left: 12,
                                      right: 8,
                                    ),
                                    child: Icon(
                                      Icons.search_rounded,
                                      color: theme
                                          .colorScheme
                                          .primary, // Brand color icon
                                      size: 24,
                                    ),
                                  ),
                                  border: InputBorder.none,
                                  enabledBorder: InputBorder.none,
                                  focusedBorder: InputBorder.none,
                                  errorBorder: InputBorder.none,
                                  filled: false, // Container handles fill
                                  isDense: true,
                                  contentPadding: EdgeInsets.symmetric(
                                    vertical: 1.5.h,
                                  ),
                                  suffixIcon: _searchController.text.isNotEmpty
                                      ? IconButton(
                                          icon: const Icon(
                                            Icons.close_rounded,
                                            size: 20,
                                          ),
                                          onPressed: () {
                                            _searchController.clear();
                                            _loadData();
                                          },
                                        )
                                      : null,
                                ),
                              ),
                            ),
                          ),
                          SizedBox(width: 3.w),
                          // Filter Button
                          InkWell(
                            key: TourKeys.filterKey,
                            onTap: _openFilterSheet,
                            borderRadius: BorderRadius.circular(12),
                            child: Container(
                              height: 6.h,
                              width: 6.h,
                              decoration: BoxDecoration(
                                color: _activeFilterCount > 0
                                    ? theme.colorScheme.secondary
                                    : theme.colorScheme.surface,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Center(
                                child: CustomIconWidget(
                                  iconName: 'tune',
                                  color: _activeFilterCount > 0
                                      ? theme.colorScheme.onSecondary
                                      : theme.colorScheme.primary,
                                  size: 20,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // Applied filters chips (as a separate sliver to stay visible or hide with bar)
          if (_activeFiltersMap.isNotEmpty)
            SliverToBoxAdapter(
              child: Container(
                padding: EdgeInsets.fromLTRB(4.w, 1.h, 4.w, 0.5.h),
                height: 6.h,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: [
                    // Adjust Filters button
                    GestureDetector(
                      onTap: _openFilterSheet,
                      child: Container(
                        margin: EdgeInsets.only(right: 2.w),
                        padding: EdgeInsets.symmetric(horizontal: 3.w),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.primary,
                          borderRadius: BorderRadius.circular(18),
                        ),
                        child: Row(
                          children: [
                            CustomIconWidget(
                              iconName: 'edit',
                              color: theme.colorScheme.onPrimary,
                              size: 16,
                            ),
                            SizedBox(width: 1.w),
                            Text(AppLocalizations.of(context)?.adjust ?? 'Adjust',
                              style: theme.textTheme.labelMedium?.copyWith(
                                color: theme.colorScheme.onPrimary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    // Filter chips
                    ..._activeFiltersMap.entries.map((entry) {
                      return Container(
                        margin: EdgeInsets.only(right: 2.w),
                        child: Chip(
                          label: Text(
                            '${entry.key}: ${entry.value}',
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: theme.colorScheme.onSecondaryContainer,
                            ),
                          ),
                          backgroundColor: theme.colorScheme.secondaryContainer,
                          deleteIcon: CustomIconWidget(
                            iconName: 'close',
                            size: 16,
                            color: theme.colorScheme.onSecondaryContainer,
                          ),
                          onDeleted: () {
                            setState(() {
                              if (entry.key == 'Age') {
                                _currentFilters = _currentFilters.copyWith(
                                  
                                );
                              }
                              if (entry.key == 'Education') {
                                _currentFilters = _currentFilters.copyWith(
                                  education: [],
                                );
                              }
                              if (entry.key == 'Profession') {
                                _currentFilters = _currentFilters.copyWith(
                                  profession: [],
                                );
                              }
                              if (entry.key == 'Marital') {
                                _currentFilters = _currentFilters.copyWith(
                                  
                                );
                              }
                            });
                            _loadData();
                          },
                          visualDensity: VisualDensity.compact,
                          padding: EdgeInsets.zero,
                          materialTapTargetSize:
                              MaterialTapTargetSize.shrinkWrap,
                        ),
                      );
                    }),
                    // Clear all button
                    GestureDetector(
                      onTap: _clearFilters,
                      child: Container(
                        padding: EdgeInsets.symmetric(horizontal: 3.w),
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: theme.colorScheme.error.withValues(
                              alpha: 0.5,
                            ),
                          ),
                          borderRadius: BorderRadius.circular(18),
                        ),
                        child: Row(
                          children: [
                            CustomIconWidget(
                              iconName: 'clear_all',
                              color: theme.colorScheme.error,
                              size: 16,
                            ),
                            SizedBox(width: 1.w),
                            Text(AppLocalizations.of(context)?.clear ?? 'Clear',
                              style: theme.textTheme.labelMedium?.copyWith(
                                color: theme.colorScheme.error,
                                fontWeight: FontWeight.w600,
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

          // Tab selector + View toggle
          if (!_isLoading && _errorMessage == null)
            SliverToBoxAdapter(
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 8.0, vertical: 1.h),
                child: IntrinsicHeight(
                  child: Row(
                    children: [
                      // -- Group 1: Recommended / Daily --
                      Expanded(
                        child: Container(
                          decoration: BoxDecoration(
                            color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
                            borderRadius: BorderRadius.circular(24),
                            border: Border.all(
                              color: theme.colorScheme.primary.withValues(alpha: 0.5),
                              width: 1.5,
                            ),
                          ),
                          padding: EdgeInsets.zero,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              Expanded(
                                child: _buildTabPill(
                                  label: AppLocalizations.of(context)?.recommended ?? 'Rec',
                                  isActive: _selectedTab == 0,
                                  onTap: () {
                                    if (_selectedTab == 0) return;
                                    HapticFeedback.selectionClick();
                                    Future.microtask(() => setState(() => _selectedTab = 0));
                                  },
                                  theme: theme,
                                ),
                              ),
                              Expanded(
                                child: _buildTabPill(
                                  label: AppLocalizations.of(context)?.daily ?? 'Daily',
                                  isActive: _selectedTab == 1,
                                  onTap: () {
                                    if (_selectedTab == 1) return;
                                    HapticFeedback.selectionClick();
                                    Future.microtask(() => setState(() => _selectedTab = 1));
                                  },
                                  theme: theme,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      
                      // Dark Bold Vertical Divider
                      Container(
                        width: 2.5,
                        height: 28,
                        margin: EdgeInsets.symmetric(horizontal: 1.5.w), // Slightly reduced margin
                        decoration: BoxDecoration(
                          color: Colors.black, 
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),

                      // -- Group 2: Grid / Swipe --
                      Expanded(
                        child: Container(
                          decoration: BoxDecoration(
                            color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
                            borderRadius: BorderRadius.circular(24),
                            border: Border.all(
                              color: theme.colorScheme.primary.withValues(alpha: 0.5),
                              width: 1.5,
                            ),
                          ),
                          padding: EdgeInsets.zero,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              Expanded(
                                child: _buildTabPill(
                                  label: AppLocalizations.of(context)?.grid ?? 'Grid',
                                  isActive: !_isSwipeMode,
                                  onTap: () {
                                    if (!_isSwipeMode) return;
                                    HapticFeedback.selectionClick();
                                    setState(() => _isSwipeMode = false);
                                  },
                                  theme: theme,
                                ),
                              ),
                              Expanded(
                                child: _buildTabPill(
                                  label: AppLocalizations.of(context)?.swipe ?? 'Swipe',
                                  isActive: _isSwipeMode,
                                  onTap: () {
                                    if (_isSwipeMode) return;
                                    HapticFeedback.selectionClick();
                                    setState(() => _isSwipeMode = true);
                                  },
                                  theme: theme,
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
            ),

          // 🎁 Dynamic Offer Banners
          if (!_isLoading && _errorMessage == null && _selectedTab == 0)
            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.only(top: 1.h, bottom: 2.h),
                child: OfferBannerWidget(
                  gender: _ownProfile?.gender,
                  currentPlan: _ownProfile?.planType.name,
                ),
              ),
            ),
            
           // 📢 Interleaved Banner Ad (Hidden for Premium users inside the widget)
           if (!_isLoading && _errorMessage == null && _selectedTab == 0)
              const SliverToBoxAdapter(
                child: BannerAdWidget(),
              ),

          // ══════════════════════════════════════════════════════
          // RECOMMENDED TAB content
          // ══════════════════════════════════════════════════════
          if (_selectedTab == 0) ...[
            // Main Content (Skeletons, Error, Empty, or Grid)
            if (_isLoading)
              SliverPadding(
                padding: const EdgeInsets.all(8.0),
                sliver: SliverGrid(
                  gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
                    maxCrossAxisExtent: 500,
                    mainAxisSpacing: 8,
                    crossAxisSpacing: 8,
                    mainAxisExtent: 64.h,
                  ),
                  delegate: SliverChildBuilderDelegate(
                    (context, index) => const ProfileCardSkeleton(),
                    childCount: 4,
                  ),
                ),
              )
            else if (_errorMessage != null)
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
                      Text(_errorMessage!, textAlign: TextAlign.center),
                      SizedBox(height: 2.h),
                      ElevatedButton.icon(
                        onPressed: _loadData,
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
            else if (_profiles.isEmpty)
              SliverFillRemaining(
                hasScrollBody: false,
                child: _activeFilterCount > 0
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
                            Text(AppLocalizations.of(context)?.noProfilesMatchYourFilters ?? 'No profiles match your filters',
                              style: theme.textTheme.titleMedium,
                            ),
                            SizedBox(height: 1.h),
                            Text(AppLocalizations.of(context)?.tryAdjustingYourFilterCriteria ?? 'Try adjusting your filter criteria',
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                            ),
                            SizedBox(height: 3.h),
                            OutlinedButton.icon(
                              onPressed: _clearFilters,
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
                        onAdjustFilters: () {
                          _openFilterSheet();
                        },
                      ),
              )
            else if (_isSwipeMode)
              // ── Swipe Mode ──
              SliverFillRemaining(
                hasScrollBody: false,
                child: ConstrainedBox(
                  constraints: BoxConstraints(maxHeight: 80.h),
                  child: SwipeableCardDeck(
                    profiles: _profiles, // Pass raw models
                    onTap: _openProfileDetail,
                    onInterest: (profile) {
                      _showSharingOptions(profile);
                    },
                    onSkip: (profile) {
                      // Trigger enrichment for the next card (3 ahead)
                      final nextIdx = _profiles.indexWhere((p) => p.id == profile.id) + 3;
                      if (nextIdx < _profiles.length) {
                        _enrichProfileLazy(_profiles[nextIdx]);
                      }
                    },
                    onSuperLike: (profile) {
                      _showSharingOptions(profile);
                    },
                    onShare: (profile) => _showSharingOptions(profile),
                    onBookmark: (profile) {
                      _toggleBookmark(profile.id, profile.isBookmarked);
                    },
                    onLoadMore: _loadMoreProfiles,
                  ),
                ),
              )
            else
              // ── Grid Mode ──
              SliverPadding(
                padding: const EdgeInsets.all(8.0),
                sliver: SliverGrid(
                  gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
                    maxCrossAxisExtent: 600,
                    mainAxisSpacing: 8,
                    crossAxisSpacing: 8,
                    mainAxisExtent: 68.h,
                  ),
                  delegate: SliverChildBuilderDelegate((context, index) {
                    // Logic to inject ads every 6 profiles
                    final isPremium = SessionManager.instance.isPremium;
                    final adInterval = 6;
                    
                    if (!isPremium && index != 0 && index % adInterval == 0) {
                      return BannerAdWidget(key: ValueKey('ad_widget_$index'));
                    }

                    // Adjust index for profiles list because of injected ads
                    final profileIndex = isPremium ? index : index - (index ~/ adInterval);
                    if (profileIndex >= _profiles.length) return null;

                    final profile = _profiles[profileIndex];

                    // Trigger enrichment if visible and not enriched
                    if (!profile.isEnriched) {
                      _enrichProfileLazy(profile);
                    }

                    return RepaintBoundary(
                      key: ValueKey('profile_${profile.id}'),
                      child: ProfileCardWidget(
                        profile: profile,
                        onTap: () => _openProfileDetail(profile),
                        onBookmark: () => _toggleBookmark(profile.id, profile.isBookmarked),
                        onShare: (profile) => _showSharingOptions(profile),
                        onInterest: (profile) => _handleInterest(profile),
                      ),
                    );
                  }, childCount: SessionManager.instance.isPremium 
                      ? _profiles.length 
                      : _profiles.length + (_profiles.length ~/ 5)), // Approximate count with ads
                ),
              ),
            if (_isFetchingMore)
              SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 2.h),
                  child: Center(
                    child: Text(
                      '. . .',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.5),
                      ),
                    ),
                  ),
                ),
              ),
          ],

          // ══════════════════════════════════════════════════════
          // DAILY TAB content
          // ══════════════════════════════════════════════════════
          if (_selectedTab == 1) ...[
            if (_isLoading)
              SliverFillRemaining(
                hasScrollBody: false,
                child: Center(
                  child: Text(
                    '. . .',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.5),
                    ),
                  ),
                ),
              )
            else if (_errorMessage != null)
              SliverFillRemaining(
                hasScrollBody: false,
                child: Center(child: Text(_errorMessage!)),
              )
            else
              SliverFillRemaining(
                hasScrollBody: false,
                child: Center(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(maxHeight: 85.h),
                    child: DailyMatchWidget(
                      dailyProfiles: pickDailyMatches(_profiles),
                      onTap: _openProfileDetail,
                      onInterest: _handleInterest,
                      onBookmark: (profile) {
                        _toggleBookmark(profile.id, profile.isBookmarked);
                      },
                      onShare: (profile) => _showSharingOptions(profile),
                    ),
                  ),
                ),
              ),
          ],
        ],
      ),
    );
  }

  Widget _buildTabPill({
    required String label,
    required bool isActive,
    required VoidCallback onTap,
    required ThemeData theme,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOut,
        padding: EdgeInsets.symmetric(vertical: 1.h), // Consistent vertical padding
        decoration: BoxDecoration(
          color: isActive ? theme.colorScheme.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(24),
        ),
        child: Center(
          child: Text(
            label,
            style: theme.textTheme.labelLarge?.copyWith(
              color: isActive
                  ? theme.colorScheme.onPrimary
                  : theme.colorScheme.onSurfaceVariant,
              fontWeight: isActive ? FontWeight.w800 : FontWeight.w600,
              fontSize: 12.sp,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
}
