import 'package:flutter/foundation.dart';
import 'package:banjarabio/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fluttertoast/fluttertoast.dart';

import 'package:sizer/sizer.dart';
import 'dart:async';
import 'dart:math' as math;
import 'dart:ui';

import 'package:banjarabio/core/app_export.dart';
import 'package:banjarabio/core/data/location_data.dart';
import 'package:banjarabio/core/models/filter_criteria.dart';
import 'package:banjarabio/core/models/profile_model.dart';
import 'package:banjarabio/core/repositories/profile_repository.dart';
import 'package:banjarabio/core/repositories/photo_repository.dart';

import 'package:banjarabio/core/repositories/share_repository.dart';
import 'package:banjarabio/core/repositories/usage_repository.dart';
import 'package:banjarabio/core/services/scroll_velocity_service.dart';
import 'package:banjarabio/core/services/local_cache_service.dart';

import 'package:banjarabio/core/services/deep_link_service.dart';
import 'package:banjarabio/features/bookmarks/providers/bookmark_notifier.dart';
import 'package:banjarabio/widgets/upgrade_dialog.dart';
import 'package:banjarabio/presentation/home_screen/widgets/instagram_follow_interstitial.dart';
import 'package:banjarabio/presentation/home_screen/widgets/guest_restricted_dialog.dart';
import 'package:banjarabio/presentation/home_screen/widgets/offer_banner_widget.dart';
import 'package:banjarabio/presentation/home_screen/widgets/relative_browse_hero_card.dart';
import 'package:banjarabio/presentation/home_screen/widgets/home_feed_header.dart';
import 'package:banjarabio/presentation/home_screen/widgets/home_filter_chips.dart';
import 'package:banjarabio/presentation/home_screen/widgets/home_sharing_sheet.dart';
import 'package:banjarabio/presentation/home_screen/widgets/home_recommended_content.dart';
import 'package:banjarabio/presentation/home_screen/widgets/home_daily_content.dart';
import 'package:banjarabio/presentation/home_screen/widgets/home_interest_handler.dart';
import 'package:banjarabio/widgets/ads/banner_ad_widget.dart';
import 'package:banjarabio/presentation/filter_screen/filter_screen.dart';
import 'package:banjarabio/presentation/home_screen/location_selection_screen.dart';
import 'package:banjarabio/widgets/branded_refresh_indicator.dart';
import 'package:banjarabio/widgets/tactile/tactile_pressable.dart';
import 'package:banjarabio/core/models/daily_reward_model.dart';
import 'package:banjarabio/core/repositories/daily_reward_repository.dart';
import 'package:banjarabio/widgets/daily_reward_dialog.dart';
import 'package:banjarabio/core/repositories/chat_repository.dart';
import 'package:banjarabio/presentation/match_profile_screen/widgets/direct_note_bottom_sheet.dart';
import 'package:banjarabio/core/services/app_logger.dart';


class HomeScreen extends ConsumerStatefulWidget {
  final ProfileRepository? profileRepository;
  final ShareRepository? shareRepository;
  final UsageRepository? usageRepository;
  final PhotoRepository? photoRepository;

  const HomeScreen({
    super.key,
    this.profileRepository,
    this.shareRepository,
    this.usageRepository,
    this.photoRepository,
  });

  @override
  ConsumerState<HomeScreen> createState() =>
      _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen>
    with WidgetsBindingObserver, TickerProviderStateMixin {
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
  AnimationController? _bounceController;
  Animation<double>? _bounceAnimation;
  Animation<double>? _pulseAnimation;
  Animation<double>? _glowAnimation;

  void _initAnimations() {
    if (_bounceController == null) {
      _bounceController = AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 1100),
      )..repeat(reverse: true);

      _bounceAnimation = Tween<double>(begin: -1.0, end: 3.5).animate(
        CurvedAnimation(parent: _bounceController!, curve: Curves.easeInOut),
      );
      _pulseAnimation = Tween<double>(begin: 0.98, end: 1.025).animate(
        CurvedAnimation(parent: _bounceController!, curve: Curves.easeInOut),
      );
      _glowAnimation = Tween<double>(begin: 0.25, end: 0.85).animate(
        CurvedAnimation(parent: _bounceController!, curve: Curves.easeInOut),
      );
    }
  }


  bool _isLoading = true;
  bool _isFetchingMore = false;
  bool _hasMore = true;
  static const int _pageSize = 20;
  static const int _initialPageSize = 8; // 🚨 SIGNAL 3 FIX: Fewer cards on first paint
  String? _lastCreatedAt;

  bool _isLocationOverridden = true;
  // bool _isSwipeMode = false; // Commented out swipe mode
  int _selectedTab = 0; // 0 = Recommended, 1 = Daily
  String? _errorMessage;
  List<ProfileModel> _profiles = [];
  ProfileModel? _ownProfile;
  DailyRewardModel? _dailyRewardStatus;

  // District Fallback tracking
  bool _isDistrictFallback = false;
  String? _fallbackDistrict;
  String? _fallbackState;

  final Set<String> _enrichingIds = {};
  Timer? _batchTimer;
  final List<ProfileModel> _batchEnrichedProfiles = [];
  Timer? _shimmerFallback;
  Timer? _instagramTimer;
  StreamSubscription<List<ProfileModel>>? _feedSubscription;
  DateTime? _lastResumeLoadTime; // Throttle for app-resume feed reload

  // Search and Location state
  final TextEditingController _searchController = TextEditingController();
  Timer? _debounce;

  // Filter state
  FilterCriteria _currentFilters = const FilterCriteria();

  // Relative browse intent (applied once from route arguments)
  bool _hasAppliedRelativeFilters = false;

  // Filter options

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Apply relative browse filters from route arguments (Pathway A).
    // This runs when HomeScreen is pushed with arguments from StartupWorkflow.
    if (!_hasAppliedRelativeFilters) {
      final args = ModalRoute.of(context)?.settings.arguments;
      if (args is Map) {
        final map = Map<String, dynamic>.from(args);
        final gender = map['target_gender']?.toString() ?? map['targetGender']?.toString();
        final state = map['state']?.toString();
        final district = map['district']?.toString();
        if (gender != null || state != null || district != null) {
          _hasAppliedRelativeFilters = true;
          final newFilters = FilterCriteria(
            gender: gender,
            state: state,
            district: district,
          );
          if (_currentFilters != newFilters) {
            _currentFilters = newFilters;
            _isLocationOverridden = true;
            _loadData(clearCache: true);
          }
        }
      }
    }
  }

  @override
  void initState() {
    super.initState();
    _profileRepository = widget.profileRepository ?? ProfileRepository();
    _shareRepository = widget.shareRepository ?? ShareRepository();
    _usageRepository = widget.usageRepository ?? UsageRepository();

    // 🎯 CRITICAL FIX: Synchronously initialize filters for Relative Browse Mode only if no own profile
    final cachedOwnProfile = LocalCacheService().getOwnProfile();
    final bool hasOwnProfile = cachedOwnProfile != null;

    if (hasOwnProfile) {
      LocalCacheService().clearRelativeBrowseSession();
    } else if (LocalCacheService().isRelativeBrowseMode()) {
      final intent = LocalCacheService().getRelativeIntent();
      if (intent != null) {
        final gender = intent['target_gender'] ?? intent['targetGender'];
        final state = intent['state'];
        final district = intent['district'];
        if (gender != null || state != null || district != null) {
          _currentFilters = FilterCriteria(
            gender: gender,
            state: state,
            district: district,
          );
          _isLocationOverridden = true;
          _hasAppliedRelativeFilters = true;
          AppLogger.debug('HomeScreen', '🎯 Relative Browse Filters pre-loaded in initState: $_currentFilters');
        }
      }
    }

    _scrollController.addListener(_onScroll);
    WidgetsBinding.instance.addObserver(this);

    _initAnimations();

    // 📡 Stream listener: Live update feed whenever background API fetch arrives
    _feedSubscription = _profileRepository.onFeedUpdated.listen((freshProfiles) {
      if (mounted) {
        final profiles =
            freshProfiles.where((p) => p.id != _ownProfile?.id).toList();
        setState(() {
          _profiles = profiles;
          _isLoading = false;
        });
      }
    });

    DeepLinkService().onRewardsTriggered = () {
      if (mounted) _handleRewardsDeepLink();
    };

    // 🚀 ALWAYS DIRECTLY LOAD PROFILES ON SCREEN INITIALIZATION
    _loadData();
    _loadDailyRewardStatus().then((_) {
      if (mounted) {
        _checkInstagramPrompt();
        _checkPostStartupRewards();
      }
    });

    // 🧬 SAFETY FALLBACK (10M DAU): Prevent infinite shimmer if network is stalled
    _shimmerFallback = Timer(const Duration(seconds: 10), () {
      if (mounted && _isLoading && _profiles.isEmpty) {
        AppLogger.warn('HomeScreen', '⚠️ HomeScreen: Shimmer safety fallback triggered');
        setState(() => _isLoading = false);
      }
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _checkPostStartupRewards();

      // 🛡️ Throttle: Skip reload if last resume was < 30 seconds ago.
      // Prevents rapid app-switches (notification tray, etc.) from hammering the RPC.
      final now = DateTime.now();
      if (_lastResumeLoadTime != null &&
          now.difference(_lastResumeLoadTime!).inSeconds < 30) {
        AppLogger.debug('HomeScreen', '📱 App resumed: Skipped reload (throttled, last was ${now.difference(_lastResumeLoadTime!).inSeconds}s ago)');
        return;
      }
      _lastResumeLoadTime = now;

      AppLogger.debug('HomeScreen', '📱 App resumed: Triggering fresh API call for profiles');
      _loadData(clearCache: true);
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

  void _checkInstagramPrompt() {
    _instagramTimer?.cancel();
    // Small delay to ensure UI is ready and data might be loaded
    _instagramTimer = Timer(const Duration(seconds: 4), () async {
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
    });
  }

  @override
  void dispose() {
    _bounceController?.dispose();
    _feedSubscription?.cancel();
    _scrollController.dispose();
    _searchController.dispose();
    _debounce?.cancel();
    _batchTimer?.cancel();
    _shimmerFallback?.cancel();
    _instagramTimer?.cancel();
    WidgetsBinding.instance.removeObserver(this);
    // 🧬 PERFORMANCE: Removed aggressive image cache clearing during dispose.
    // Clearing the entire cache synchronously can block the main thread 
    // and trigger ANRs during UI transitions. We rely on the 500-item 
    // memory guardrail in _loadData for gradual pruning.
    super.dispose();
  }

  double get _currentScrollOffset {
    if (!_scrollController.hasClients || _scrollController.positions.isEmpty) {
      return 0.0;
    }
    return _scrollController.positions.first.pixels;
  }

  void _onScroll() {
    if (_selectedTab == 1) return;
    if (!_scrollController.hasClients || _scrollController.positions.isEmpty) return;
    
    final pos = _scrollController.positions.first;
    if (pos.pixels <= 0) return;
    
    // 🧬 PERFORMANCE: Pre-fetch next page when 70% through
    final triggerThreshold = pos.maxScrollExtent * 0.7;
    
    if (pos.pixels >= triggerThreshold &&
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
    final currentIndex = (_currentScrollOffset / itemHeight).floor();
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
    final currentIndex = (_currentScrollOffset / itemHeight).floor();
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
      // 🚀 GUEST & RELATIVE FIX: For relative browse mode, ensure relative filters are applied only if user has no own profile
      final cachedProfile = _ownProfile ?? (LocalCacheService().getOwnProfile() != null ? ProfileModel.fromJson(LocalCacheService().getOwnProfile()!) : null);
      final bool hasOwnProfile = cachedProfile != null && !isGuest;

      FilterCriteria applyFilters = _currentFilters;
      if (!hasOwnProfile && LocalCacheService().isRelativeBrowseMode()) {
        final intent = LocalCacheService().getRelativeIntent();
        if (intent != null) {
          final targetGender = intent['target_gender'] ?? intent['targetGender'];
          final state = intent['state'];
          final district = intent['district'];
          applyFilters = applyFilters.copyWith(
            gender: applyFilters.gender ?? targetGender,
            state: applyFilters.state ?? state,
            district: applyFilters.district ?? district,
          );
        }
      } else if (hasOwnProfile &&
          !_isLocationOverridden &&
          _currentFilters.state == null &&
          _currentFilters.district == null &&
          _currentFilters.taluka == null) {
        applyFilters = _currentFilters.copyWith(
          state: cachedProfile.state,
          district: cachedProfile.district,
          taluka: cachedProfile.taluka,
        );
      }

      // 🚀 GUEST FIX: Wrap in tight timeout to prevent 235s hang for guest users
      final result = await _profileRepository.getProfiles(
        // 🚨 SIGNAL 3 FIX: Use smaller page for initial load to reduce concurrent image decodes
        limit: isLoadMore ? _pageSize : _initialPageSize,
        lastCreatedAt: isLoadMore ? _lastCreatedAt : null,
        filters: applyFilters,
        searchQuery: _searchController.text,
        forceRefresh: clearCache,
      ).timeout(
        Duration(seconds: isGuest ? 10 : 30),
        onTimeout: () {
          AppLogger.debug('HomeScreen', '⚠️ _loadData: Timed out${isGuest ? " (guest mode)" : ""}');
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
                if (changed && mounted) {
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
              _isDistrictFallback = _profileRepository.isDistrictFallback;
              _fallbackDistrict = _profileRepository.lastRequestedDistrict;
              _fallbackState = _profileRepository.lastSelectedState;
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
    if (LocalCacheService().isGuestMode() || LocalCacheService().isRelativeBrowseMode()) {
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
          AppLogger.error('HomeScreen', '[BOOKMARK] HomeScreen > toggle($profileId) > FAILED | $e');
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
    HapticFeedback.selectionClick();
    final Map<String, String?>? result =
        await Navigator.push<Map<String, String?>>(
          context,
          PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) =>
                const LocationSelectionScreen(),
            transitionsBuilder:
                (context, animation, secondaryAnimation, child) {
              const begin = Offset(0.0, 0.08);
              const end = Offset.zero;
              final curve = CurvedAnimation(
                parent: animation,
                curve: Curves.easeOutCubic,
              );
              return SlideTransition(
                position: Tween<Offset>(begin: begin, end: end).animate(curve),
                child: FadeTransition(
                  opacity: curve,
                  child: child,
                ),
              );
            },
            transitionDuration: const Duration(milliseconds: 260),
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
    // 🔍 PATHWAY A: Relative browse users CAN view profile details (read-only).
    // This is the core use case — they're searching on behalf of someone.

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
    HomeSharingSheet.show(
      context,
      profile: profile,
      shareRepository: _shareRepository,
      usageRepository: _usageRepository,
    );
  }

  void _handleInterest(ProfileModel profile) {
    if (LocalCacheService().isRelativeBrowseMode()) {
      GuestRestrictedDialog.show(context);
      return;
    }
    HomeInterestHandler.show(
      context: context,
      profile: profile,
      shareRepository: _shareRepository,
      usageRepository: _usageRepository,
    );
  }

  void _handleMessage(ProfileModel profile) async {
    if (LocalCacheService().isRelativeBrowseMode()) {
      GuestRestrictedDialog.show(context);
      return;
    }

    if (profile.isMatched) {
      final res = await ChatRepository().getOrCreateConversation(profile.userId);
      res.fold(
        onSuccess: (conversation) {
          if (mounted) {
            Navigator.pushNamed(
              context,
              AppRoutes.chatScreen,
              arguments: conversation,
            );
          }
        },
        onFailure: (err) {
          if (mounted) {
            Fluttertoast.showToast(
              msg: AppLocalizations.of(context)?.failedToStartChat(err.toString()) ?? 'Failed to start chat: $err',
            );
          }
        },
      );
    } else {
      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (ctx) => DirectNoteBottomSheet(
          profile: profile.toDisplayMap(),
          onSuccess: () => _handleInterest(profile),
        ),
      );
    }
  }

  String _getRelativeChipLabel() {
    final intent = LocalCacheService().getRelativeIntent();
    final relation = (intent?['relation'] ?? '').toString().toLowerCase();
    final gender = (intent?['target_gender'] ?? intent?['targetGender'] ?? '').toString().toLowerCase();
    final district = intent?['district'] ?? _currentFilters.district;
    final state = intent?['state'] ?? _currentFilters.state;

    String relText = 'नातेवाईक';
    if (relation.contains('son')) {
      relText = '👦 मुलासाठी (वधू शोध)';
    } else if (relation.contains('daughter')) {
      relText = '👧 मुलीसाठी (वर शोध)';
    } else if (relation.contains('sibling')) {
      relText = '👫 भावा/बहिणीसाठी';
    } else if (relation.contains('relative') || relation.isNotEmpty) {
      relText = '🚩 नातेवाईकांसाठी';
    } else if (gender == 'female' || gender == 'bride') {
      relText = '👧 वधू (मुली)';
    } else if (gender == 'male' || gender == 'groom') {
      relText = '👦 वर (मुले)';
    }

    String locText = '';
    if (district != null && district.isNotEmpty) {
      locText = ' • $district';
    } else if (state != null && state.isNotEmpty) {
      locText = ' • $state';
    }

    return '$relText$locText';
  }

  @override
  Widget build(BuildContext context) {
    // Bookmark UI updates via ref.watch(isBookmarkedProvider) per card - no ref.listen needed
    return Stack(
      children: [
        BrandedRefreshIndicator(
          onRefresh: _handleRefresh,
          child: CustomScrollView(
            controller: _scrollController,
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              HomeFeedHeader(
                locationLabel: _getUserLocationLabel(),
                onLocationTap: _openLocationSelection,
                onFilterTap: _openFilterSheet,
                searchController: _searchController,
                onSearchChanged: _onSearchChanged,
                onSearchClear: () {
                  _searchController.clear();
                  _loadData();
                },
                activeFilterCount: _activeFilterCount,
                dailyRewardStatus: _dailyRewardStatus,
                onRewardUpdated: (updated) {
                  if (updated != null && mounted) {
                    setState(() => _dailyRewardStatus = updated);
                  }
                },
                selectedTab: _selectedTab,
                // isSwipeMode: _isSwipeMode, // Commented out swipe mode
                onTabChanged: (tab) => Future.microtask(() => setState(() => _selectedTab = tab)),
                // onViewModeChanged: (swipe) => setState(() => _isSwipeMode = swipe), // Commented out swipe mode
              ),

              if (LocalCacheService().isRelativeBrowseMode())
                SliverToBoxAdapter(
                  child: RelativeBrowseHeroCard(
                    activeChipLabel: _getRelativeChipLabel(),
                  ),
                ),

              // Extracted: Applied filter chips
              HomeFilterChips(
                activeFiltersMap: _activeFiltersMap,
                onAdjustFilters: _openFilterSheet,
                onClearFilters: _clearFilters,
                onRemoveFilter: (key) {
                  setState(() {
                    if (key == 'Age') {
                      _currentFilters = _currentFilters.copyWith();
                    }
                    if (key == 'Education') {
                      _currentFilters = _currentFilters.copyWith(education: []);
                    }
                    if (key == 'Profession') {
                      _currentFilters = _currentFilters.copyWith(profession: []);
                    }
                    if (key == 'Marital') {
                      _currentFilters = _currentFilters.copyWith();
                    }
                  });
                  _loadData();
                },
              ),

              // 🎁 Dynamic Offer & Services Mini-Strip
              if (!_isLoading && _errorMessage == null && _selectedTab != 1)
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.only(top: 2.0, bottom: 2.0),
                    child: OfferBannerWidget(
                      gender: _ownProfile?.gender,
                      currentPlan: _ownProfile?.planType.name,
                    ),
                  ),
                ),
                
               // 📢 Interleaved Banner Ad (omitted for Premium subscribers)
               if (!_isLoading && _errorMessage == null && _selectedTab == 0 && !SessionManager.instance.isPremium)
                  const SliverToBoxAdapter(
                    child: BannerAdWidget(),
                  ),

              // ══════════════════════════════════════════════════════
              // RECOMMENDED / ALL MATCHES (0), NEAR ME (2), VIP (3)
              // ══════════════════════════════════════════════════════
              if (_selectedTab != 1) ...HomeRecommendedContent.buildSlivers(
                context: context,
                isLoading: _isLoading,
                errorMessage: _errorMessage,
                profiles: _getFilteredProfilesForTab(_selectedTab),
                isSwipeMode: false, // Commented out swipe mode
                activeFilterCount: _activeFilterCount,
                isFetchingMore: _isFetchingMore,
                isDistrictFallback: _isDistrictFallback,
                requestedDistrict: _fallbackDistrict ?? _currentFilters.district,
                selectedState: _fallbackState ?? _currentFilters.state,
                onLoadData: _loadData,
                onClearFilters: _clearFilters,
                onOpenFilterSheet: _openFilterSheet,
                onOpenProfileDetail: _openProfileDetail,
                onShowSharingOptions: _showSharingOptions,
                onHandleInterest: _handleInterest,
                onMessage: _handleMessage,
                onToggleBookmark: _toggleBookmark,
                onEnrichProfileLazy: _enrichProfileLazy,
                onLoadMoreProfiles: _loadMoreProfiles,
              ),

              // ══════════════════════════════════════════════════════
              // DAILY PICKS TAB (1)
              // ══════════════════════════════════════════════════════
              if (_selectedTab == 1) ...HomeDailyContent.buildSlivers(
                context: context,
                isLoading: _isLoading,
                errorMessage: _errorMessage,
                profiles: _profiles.take(10).toList(),
                onTap: _openProfileDetail,
                onInterest: _handleInterest,
                onToggleBookmark: _toggleBookmark,
                onShare: _showSharingOptions,
              ),
            ],
          ),
        ),

        // 🌟 Smart Floating Bottom Scroll Indicator (Auto-Fades on scroll)
        if (!_isLoading && _errorMessage == null && _profiles.isNotEmpty && _selectedTab != 1)
          _buildSmartFloatingScrollIndicator(),
      ],
    );
  }

  Widget _buildSmartFloatingScrollIndicator() {
    _initAnimations();
    return AnimatedBuilder(
      animation: _scrollController,
      builder: (context, child) {
        final offset = _currentScrollOffset;
        final isVisible = offset <= 50.0;

        return Positioned(
          bottom: 12.h,
          left: 0,
          right: 0,
          child: AnimatedOpacity(
            opacity: isVisible ? 1.0 : 0.0,
            duration: const Duration(milliseconds: 280),
            curve: Curves.easeInOut,
            child: IgnorePointer(
              ignoring: !isVisible,
              child: Center(
                child: TactilePressable(
                  onTap: () {
                    HapticFeedback.selectionClick();
                    if (_scrollController.hasClients && _scrollController.positions.isNotEmpty) {
                      final pos = _scrollController.positions.first;
                      _scrollController.animateTo(
                        math.min(
                          pos.pixels + 500.0,
                          pos.maxScrollExtent,
                        ),
                        duration: const Duration(milliseconds: 450),
                        curve: Curves.easeInOutCubic,
                      );
                    }
                  },
                  child: AnimatedBuilder(
                    animation: _bounceController!,
                    builder: (context, _) {
                      return Transform.scale(
                        scale: _pulseAnimation!.value,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(26),
                          child: BackdropFilter(
                            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
                              decoration: BoxDecoration(
                                color: Colors.black.withValues(alpha: AppColors.opacity35), // Ultra-transparent glass
                                borderRadius: BorderRadius.circular(26),
                                border: Border.all(
                                  color: AppColors.goldLemon.withValues(alpha: _glowAnimation!.value), // Pulsing aura rim
                                  width: 1.2,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: AppColors.opacity25),
                                    blurRadius: 12,
                                    offset: const Offset(0, 3),
                                  ),
                                  BoxShadow(
                                    color: AppColors.categoryAstro.withValues(alpha: _glowAnimation!.value * 0.4),
                                    blurRadius: 14,
                                    spreadRadius: 0.5,
                                  ),
                                ],
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Transform.translate(
                                    offset: Offset(0, _bounceAnimation!.value),
                                    child: const Icon(
                                      Icons.keyboard_arrow_down_rounded,
                                      color: AppColors.goldLemon,
                                      size: 20,
                                    ),
                                  ),
                                  const SizedBox(width: 5),
                                  Text(
                                    'Scroll for more',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: AppTypography.labelSmall,
                                      fontWeight: AppTypography.bold,
                                      letterSpacing: 0.3,
                                      shadows: [
                                        const Shadow(
                                          color: Colors.black87,
                                          blurRadius: 3,
                                          offset: Offset(0, 1),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  List<ProfileModel> _getFilteredProfilesForTab(int tab) {
    switch (tab) {
      case 2:
        // Near Me tab
        final userDistrict = _ownProfile?.district?.toLowerCase() ?? '';
        final userState = _ownProfile?.state?.toLowerCase() ?? '';
        final near = _profiles.where((p) {
          final pDist = p.district?.toLowerCase() ?? '';
          final pState = p.state?.toLowerCase() ?? '';
          return (userDistrict.isNotEmpty && pDist == userDistrict) ||
              (userState.isNotEmpty && pState == userState);
        }).toList();
        return near.isNotEmpty ? near : _profiles;
      case 3:
        // VIP Verified tab
        final vip = _profiles.where((p) => p.isVerified || p.isPremium).toList();
        return vip.isNotEmpty ? vip : _profiles;
      case 0:
      default:
        // All Matches
        return _profiles;
    }
  }
}

