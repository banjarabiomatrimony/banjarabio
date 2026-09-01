import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:banjarabio/core/models/backend_response.dart';
import 'package:banjarabio/core/models/filter_criteria.dart';
import 'package:banjarabio/core/models/profile_model.dart';
import 'package:banjarabio/core/services/bookmark_notifier.dart';
import 'package:banjarabio/core/repositories/photo_repository.dart';
import 'package:banjarabio/core/services/local_cache_service.dart';
import 'package:banjarabio/core/repositories/isolate_first_repository.dart';
import 'package:banjarabio/core/repositories/referral_repository.dart';
import 'package:banjarabio/core/repositories/subscription_repository.dart';
import 'package:banjarabio/notification/features/admin_notification_service.dart';
import 'package:banjarabio/core/repositories/influencer_repository.dart';
import 'package:banjarabio/core/session_manager.dart';

/// [ProfileRepository]
///
/// Manages all Profile-related data operations: Fetching, Caching, Updating, and Filtering.
///
/// 🏆 10/10 Architecture Highlights:
/// 1. **Triple-Layer Caching**: Serves data from Memory -> Disk (Hive) -> Network for instant UI.
/// 2. **N+1 Optimization**: Uses `Future.wait` to fetch Photos, Bookmarks, and Matches in parallel.
/// 3. **Isolate Offloading**: Parses large lists of JSON profiles on a background thread to prevent UI jank.
/// 4. **Singleton Pattern**: Ensures cache lifecycle is managed correctly across the app.
import 'package:banjarabio/core/services/read_replica_client.dart';
import 'package:banjarabio/core/services/app_logger.dart';

/// Repository for managing user profiles and discovery feed
class ProfileRepository extends IsolateFirstRepository {
  // ---------------------------------------------------------------------------
  // 1. Singleton Pattern & Dependencies
  // ---------------------------------------------------------------------------
  static final ProfileRepository _instance = ProfileRepository.internal();
  factory ProfileRepository() => _instance;

  @visibleForTesting
  ProfileRepository.internal() : super();

  SupabaseClient get _supabase => testClient ?? Supabase.instance.client;
  // 🌐 Replica client for Discovery Feed (O(1) read scaling)
  SupabaseClient get _readClient => testReadClient ?? ReadReplicaClient.getClient();
  PhotoRepository get _photoRepository => testPhotoRepository ?? PhotoRepository();
  LocalCacheService get _cacheService => testCacheService ?? LocalCacheService();
  ReferralRepository get _referralRepository => testReferralRepository ?? ReferralRepository();
  InfluencerRepository get _influencerRepository => testInfluencerRepository ?? InfluencerRepository();

  /// 🧪 TEST-ONLY: Inject mock dependencies to avoid touching real services.
  @visibleForTesting
  SupabaseClient? testClient;
  @visibleForTesting
  SupabaseClient? testReadClient;
  @visibleForTesting
  PhotoRepository? testPhotoRepository;
  @visibleForTesting
  LocalCacheService? testCacheService;
  @visibleForTesting
  ReferralRepository? testReferralRepository;
  @visibleForTesting
  InfluencerRepository? testInfluencerRepository;

  @visibleForTesting
  Future<void>? activeFetchFuture;

  // 🛡️ RECURSION GUARD: Prevents Stack Overflow during background refreshes
  bool _isPerformingBackgroundFetch = false;

  /// 🧪 TEST-ONLY: Clear memory cache to ensure test isolation.
  @visibleForTesting
  void clearMemoryCache() {
    _cachedFeed = null;
    _cachedOwnProfile = null;
    _feedCacheTimestamp = null;
    _lastFeedFilters = null;
    _lastSearchQuery = null;
    _lastSortBy = null;
    _isDistrictFallback = false;
    _lastRequestedDistrict = null;
    _lastSelectedState = null;
  }

  // ---------------------------------------------------------------------------
  // 2. Memory Cache State (Layer 1)
  // ---------------------------------------------------------------------------
  // Cache is valid for 5 minutes before forcing a background refresh
  static const _cacheDuration = Duration(minutes: 5);

  // Own Profile Cache (Layer 1)
  ProfileModel? _cachedOwnProfile;
  DateTime? _cacheTimestamp;

  // Feed Cache (Layer 1)
  List<ProfileModel>? _cachedFeed;
  FilterCriteria? _lastFeedFilters;
  String? _lastSearchQuery;
  String? _lastSortBy;
  DateTime? _feedCacheTimestamp;

  // District Fallback Discovery State
  bool _isDistrictFallback = false;
  String? _lastRequestedDistrict;
  String? _lastSelectedState;

  bool get isDistrictFallback => _isDistrictFallback;
  String? get lastRequestedDistrict => _lastRequestedDistrict;
  String? get lastSelectedState => _lastSelectedState;

  // Stream for live feed updates across the app (SWR background refresh sync).
  // Note: This broadcast StreamController is intentionally never closed.
  // ProfileRepository is a singleton — it lives for the app's entire process lifetime.
  // The isClosed guard in _notifyFeedUpdated provides safety if hot-restart disposes it.
  final StreamController<List<ProfileModel>> _feedStreamController =
      StreamController<List<ProfileModel>>.broadcast();

  /// Stream of feed updates broadcast whenever fresh profiles are fetched from API
  Stream<List<ProfileModel>> get onFeedUpdated => _feedStreamController.stream;

  void _notifyFeedUpdated(List<ProfileModel> profiles) {
    if (!_feedStreamController.isClosed) {
      _feedStreamController.add(profiles);
    }
  }

  /// Checks whether a given phone number is available for registration/update.
  /// Returns `true` if available (not used by any other account), `false` if taken.
  Future<BackendResponse<bool>> checkPhoneAvailable({
    required String phoneNumber,
    String? excludeUserId,
  }) async {
    try {
      final cleaned = phoneNumber.replaceAll(RegExp(r'\D'), '');
      if (cleaned.length < 10) {
        return BackendResponse.success(true);
      }

      final normalized = cleaned.length >= 10 ? cleaned.substring(cleaned.length - 10) : cleaned;

      final res = await _supabase.rpc('fn_check_phone_available', params: {
        'p_phone': normalized,
        if (excludeUserId != null || _supabase.auth.currentUser?.id != null)
          'p_exclude_user_id': excludeUserId ?? _supabase.auth.currentUser?.id,
      });

      return BackendResponse.success(res == true);
    } catch (e) {
      AppLogger.error('ProfileRepository', 'Error checking phone availability: $e');
      return BackendResponse.failure(e.toString());
    }
  }

  // ---------------------------------------------------------------------------
  // 3. Write Operations (Create / Update / Delete)
  // ---------------------------------------------------------------------------

  /// Creates a new profile in the `profiles` table.
  /// Automatically checks for and completes any pending referrals.
  Future<BackendResponse<ProfileModel>> createProfile(
    Map<String, dynamic> profileData,
  ) async {
    try {
      // Normalize gender if provided
      if (profileData.containsKey('gender') && profileData['gender'] != null) {
        final g = profileData['gender'].toString().trim().toLowerCase();
        if (g == 'male' || g == 'men' || g == 'groom' || g == 'm') {
          profileData['gender'] = 'Male';
        } else if (g == 'female' || g == 'women' || g == 'bride' || g == 'f') {
          profileData['gender'] = 'Female';
        }
      }

      // Normalize surname if Chauhan
      if (profileData.containsKey('surname') && profileData['surname'] != null) {
        if (profileData['surname'].toString().trim().toLowerCase() == 'chauhan') {
          profileData['surname'] = 'Chavhan';
        }
      }

      // Normalize phone number to 10 digits
      if (profileData.containsKey('phone_number') && profileData['phone_number'] != null) {
        final rawPhone = profileData['phone_number'].toString().replaceAll(RegExp(r'\D'), '');
        if (rawPhone.length >= 10) {
          profileData['phone_number'] = rawPhone.substring(rawPhone.length - 10);
        }
      }

      // Auto-calculate age from date_of_birth if age is missing or 0
      if ((profileData['age'] == null || (profileData['age'] is int && (profileData['age'] as int) <= 0)) && profileData['date_of_birth'] != null) {
        final dob = DateTime.tryParse(profileData['date_of_birth'].toString());
        if (dob != null) {
          final now = DateTime.now();
          int derivedAge = now.year - dob.year;
          if (now.month < dob.month || (now.month == dob.month && now.day < dob.day)) {
            derivedAge--;
          }
          if (derivedAge >= 18) {
            profileData['age'] = derivedAge;
          }
        }
      }

      final response = await _supabase
          .from('profiles')
          .upsert(profileData, onConflict: 'user_id')
          .select()
          .single();

      final profile = ProfileModel.fromJson(response);
      _updateMemoryCache(profile);
      clearFeedCache();
      await _cacheService.clearHomeFeed();

      // Check and complete referral flow if applicable
      await _checkPendingReferral(profile.userId);
      await _checkPendingPromoCode();

      // 🔔 Admin Alert: Profile created
      AdminNotificationService().notifyProfileCreated(
        userId: profile.userId,
        name: profile.fullName,
        gender: profile.gender,
      );

      return BackendResponse.success(profile);
    } catch (e) {
      AppLogger.error('ProfileRepository', 'Error creating profile: $e');
      return BackendResponse.failure(e.toString());
    }
  }

  /// Updates generic profile fields.
  Future<BackendResponse<ProfileModel>> updateProfile(
    String userId,
    Map<String, dynamic> updates,
  ) async {
    try {
      if (updates.containsKey('gender') && updates['gender'] != null) {
        final g = updates['gender'].toString().trim().toLowerCase();
        if (g == 'male' || g == 'men' || g == 'groom' || g == 'm') {
          updates['gender'] = 'Male';
        } else if (g == 'female' || g == 'women' || g == 'bride' || g == 'f') {
          updates['gender'] = 'Female';
        }
      }

      if (updates.containsKey('surname') && updates['surname'] != null) {
        if (updates['surname'].toString().trim().toLowerCase() == 'chauhan') {
          updates['surname'] = 'Chavhan';
        }
      }

      // Normalize phone number to 10 digits
      if (updates.containsKey('phone_number') && updates['phone_number'] != null) {
        final rawPhone = updates['phone_number'].toString().replaceAll(RegExp(r'\D'), '');
        if (rawPhone.length >= 10) {
          updates['phone_number'] = rawPhone.substring(rawPhone.length - 10);
        }
      }

      // Auto-calculate age from date_of_birth if age is missing or 0
      if ((updates['age'] == null || (updates['age'] is int && (updates['age'] as int) <= 0)) && updates['date_of_birth'] != null) {
        final dob = DateTime.tryParse(updates['date_of_birth'].toString());
        if (dob != null) {
          final now = DateTime.now();
          int derivedAge = now.year - dob.year;
          if (now.month < dob.month || (now.month == dob.month && now.day < dob.day)) {
            derivedAge--;
          }
          if (derivedAge >= 18) {
            updates['age'] = derivedAge;
          }
        }
      }

      final response = await _supabase
          .from('profiles')
          .update(updates)
          .eq('user_id', userId)
          .select()
          .single();

      var profile = ProfileModel.fromJson(response);
      
      // Preserve and attach photos
      final photosRes = await _photoRepository.getPhotos(profile.id);
      photosRes.fold(
        onSuccess: (photos) => profile = profile.copyWith(photos: photos),
        onFailure: (_) {},
      );

      _updateMemoryCache(profile);
      clearFeedCache();
      await _cacheService.clearHomeFeed();

      // Update local storage to keep offline data in sync
      await _cacheService.saveOwnProfile(profile.toJson());

      return BackendResponse.success(profile);
    } catch (e) {
      return BackendResponse.failure(e.toString());
    }
  }

  /// [NEW] Updates the FCM token for push notifications.
  /// This is critical for the 10M DAU scaling optimization (batching).
  Future<BackendResponse<void>> updateFcmToken(String token) async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) return BackendResponse.failure('Not authenticated');

      AppLogger.debug('ProfileRepository', 'ProfileRepository: Updating FCM Token');
      
      final response = await _supabase
          .from('profiles')
          .update({'fcm_token': token})
          .eq('user_id', userId)
          .select()
          .single()
          .timeout(const Duration(seconds: 15));

      final profile = ProfileModel.fromJson(response);
      _updateMemoryCache(profile);
      await _cacheService.saveOwnProfile(profile.toJson());

      return BackendResponse.success(null);
    } catch (e) {
      AppLogger.error('ProfileRepository', 'ProfileRepository: updateFcmToken error: $e');
      return BackendResponse.failure(e.toString());
    }
  }

  /// [NEW] Logs user browse intent to Supabase for CRM and relative-search analytics.
  Future<BackendResponse<void>> logBrowseIntent({
    required String relation,
    String? targetGender,
    String? state,
    String? district,
  }) async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) return BackendResponse.failure('Not authenticated');

      AppLogger.debug('ProfileRepository', 'ProfileRepository: Logging browse intent for $relation ($targetGender)');
      await _supabase.rpc('fn_log_user_browse_intent', params: {
        'p_relation': relation,
        'p_target_gender': targetGender,
        'p_state': state,
        'p_district': district,
      });

      return BackendResponse.success(null);
    } catch (e) {
      AppLogger.error('ProfileRepository', 'ProfileRepository: logBrowseIntent error: $e');
      return BackendResponse.failure(e.toString());
    }
  }

  /// Updates personal details via Secure RPC `fn_manage_profile`.
  /// This ensures server-side validation rules are applied.
  Future<BackendResponse<void>> updatePersonalData({
    required String fullName,
    required String surname,
    required int age,
    String? gender,
  }) async {
    return _callManageProfileRpc('update_personal', {
      'full_name': fullName,
      'surname': surname,
      'age': age,
      'gender': gender,
    });
  }

  /// Updates bio/expectations via Secure RPC `fn_manage_profile`.
  Future<BackendResponse<void>> updateBio({
    String? aboutSelf,
    String? partnerExpectations,
    String? expectation,
  }) async {
    return _callManageProfileRpc('update_bio', {
      'about_self': aboutSelf,
      'partner_expectations': partnerExpectations,
      'expectation': expectation,
    });
  }

  /// Deletes the user account via Secure RPC.
  Future<BackendResponse<void>> deleteProfile() async {
    final result = await _callManageProfileRpc('delete_account', {});
    if (result.isSuccess) {
      clearCache(); // Wipe local data on successful delete
      await _cacheService.clearOwnProfile();
    }
    return result;
  }

  /// Updates the `has_followed_instagram` flag to true.
  /// This grants the user a 5% profile completion bonus.
  Future<BackendResponse<void>> followInstagram() async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) return BackendResponse.failure('Not authenticated');

      final response = await _supabase
          .from('profiles')
          .update({'has_followed_instagram': true})
          .eq('user_id', userId)
          .select()
          .single();

      final profile = ProfileModel.fromJson(response);
      _updateMemoryCache(profile);
      await _cacheService.saveOwnProfile(profile.toJson());

      return BackendResponse.success(null);
    } catch (e) {
      return BackendResponse.failure(e.toString());
    }
  }

  // ---------------------------------------------------------------------------
  // 4. Read Operations (The "Get" Logic)
  // ---------------------------------------------------------------------------

  /// Fetches a profile by ID (supports profile `id` OR auth `user_id`)
  Future<BackendResponse<ProfileModel?>> getProfileById(String idOrUserId) async {
    try {
      final cleanId = idOrUserId.trim();
      if (cleanId.isEmpty) return BackendResponse.success(null);

      // Check if input is a valid UUID
      final isUuid = RegExp(
        r'^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}$',
      ).hasMatch(cleanId);

      dynamic response;
      if (isUuid) {
        // Query by either table primary key 'id' OR 'user_id' for deep link parity
        response = await _readClient
            .from('profiles')
            .select()
            .or('id.eq.$cleanId,user_id.eq.$cleanId')
            .maybeSingle()
            .timeout(const Duration(seconds: 15));
      } else {
        // Fallback for human readable display ID (e.g. BBM-12345678 or short string)
        final shortUuid = cleanId.replaceAll(
          RegExp(r'^BB[MF]?-', caseSensitive: false),
          '',
        );
        response = await _readClient
            .from('profiles')
            .select()
            .ilike('id', '%$shortUuid%')
            .maybeSingle()
            .timeout(const Duration(seconds: 15));
      }

      if (response == null) return BackendResponse.success(null);

      var profile = ProfileModel.fromJson(response);
      final photosRes = await _photoRepository.getPhotos(profile.id);
      photosRes.fold(
        onSuccess: (photos) => profile = profile.copyWith(photos: photos),
        onFailure: (_) {},
      );

      return BackendResponse.success(profile);
    } catch (e) {
      AppLogger.error('ProfileRepository', 'Error in getProfileById: $e');
      return BackendResponse.failure(e.toString());
    }
  }

  /// Fetches the current user's profile using "Stale-While-Revalidate" strategy.
  /// 1. Returns Memory Cache (Instant).
  /// 2. Returns Disk Cache (Fast/Offline).
  /// 3. Fetches Network (Slow) and updates caches in background.
  ///
  /// Use [forceRefresh: true] after payment success to bypass cache and get
  /// fresh unlock status (e.g. is_pdf_unlocked).
  Future<BackendResponse<ProfileModel?>> getOwnProfile({
    bool forceRefresh = false,
  }) async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) return BackendResponse.success(null);

      // Force refresh: bypass all caches, fetch from network (e.g. after payment)
      if (forceRefresh) {
        clearCache();
        await _cacheService.clearOwnProfile();
        return await _fetchAndCacheOwnProfile(userId);
      }

      // Layer 1: Memory Cache (Valid for 5 mins)
      if (_isMemoryCacheValid(userId)) {
        return BackendResponse.success(_cachedOwnProfile);
      }

      // Layer 2: Disk Cache (Hive)
      final localJson = _cacheService.getOwnProfile();
      if (localJson != null && localJson['user_id'] == userId) {
        AppLogger.debug('ProfileRepository', 'ProfileRepository: Returning Hive cached profile');

        // Parse on main thread (single item is fast enough)
        final localProfile = ProfileModel.fromJson(localJson);
        _updateMemoryCache(localProfile);

        // Layer 3: Background Network Fetch (Refresh data silently)
        _fetchAndCacheOwnProfile(userId);

        return BackendResponse.success(localProfile);
      }

      // Layer 3: Foreground Network Fetch (If no cache exists)
      return await _fetchAndCacheOwnProfile(userId).catchError((e) {
        AppLogger.error('ProfileRepository', 'ProfileRepository.getOwnProfile fetch error: $e');
        return BackendResponse<ProfileModel?>.failure(e.toString());
      });
    } catch (e) {
      AppLogger.error('ProfileRepository', 'ProfileRepository.getOwnProfile Error: $e');
      return BackendResponse.failure(e.toString());
    }
  }

  /// Main Feed Fetching Logic.
  /// 🧬 PRO SCALE: Uses Cursor-based pagination and Batch Enrichment.
  /// 1. Cursor: Uses `lastCreatedAt` to fetch next page (O(1) index lookup).
  /// 2. Batch: Fetches Photos for ALL profiles in ONE network trip.
  Future<BackendResponse<List<ProfileModel>>> getProfiles({
    int limit = 20,
    String? lastCreatedAt,
    FilterCriteria? filters,
    String? searchQuery,
    String sortBy = 'smart',
    bool forceRefresh = false,
  }) async {
    try {


      // 🚀 GUEST FIX: Allow fetching profiles even if NOT authenticated (Guest Mode)
      // The RPC 'fn_get_filtered_feed' now handles v_user_id IS NULL correctly.


      // 0. 🧬 PRO SCALE: Stale-While-Revalidate (SWR) Caching
      // 1. Memory Cache (Valid for 5 mins)
      final isInitialLoad = lastCreatedAt == null;
      if (isInitialLoad && !forceRefresh && _isFeedCacheValid(filters, searchQuery, sortBy)) {
        AppLogger.debug('ProfileRepository', 'ProfileRepository: Returning Memory Cached Feed ($sortBy)');
        
        // Avoid duplicate background refreshes
        if (activeFetchFuture == null && !_isPerformingBackgroundFetch) {
          _fetchAndCacheProfiles(
            limit: limit,
            filters: filters,
            searchQuery: searchQuery,
            sortBy: sortBy,
          );
        }
        return BackendResponse.success(_cachedFeed!);
      }

        // 2. Disk Cache (Hive) - Persistent across app restarts
      if (isInitialLoad && !forceRefresh && sortBy == 'smart' && filters == null && (searchQuery == null || searchQuery.isEmpty)) {
        final diskFeedJson = _cacheService.getHomeFeed();
        if (diskFeedJson.isNotEmpty) {
          AppLogger.debug('ProfileRepository', 'ProfileRepository: Returning Disk Cached Feed (SWR)');
          
          final diskProfiles = await mapListInBackground<ProfileModel>(
            diskFeedJson,
            ProfileModel.fromJson,
          );
          
          _cachedFeed = diskProfiles;
          _lastSortBy = sortBy;
          _feedCacheTimestamp = DateTime.now(); // Mark as memory cached now

          // Trigger background refresh to get fresh data
          if (activeFetchFuture == null && !_isPerformingBackgroundFetch) {
            _fetchAndCacheProfiles(
              limit: limit,
              filters: filters,
              searchQuery: searchQuery,
              sortBy: sortBy,
            );
          }
          
          return BackendResponse.success(diskProfiles);
        }
      }

      // 1. 🧬 PRO SCALE: Parallel Initialization
      // 🚀 GUEST FIX: Skip getOwnProfile() for guests — they have no profile,
      // so calling it is wasteful and adds latency.
      final bool isGuest = _cacheService.isGuestMode();
      final bool isRelativeBrowse = _cacheService.isRelativeBrowseMode();
      
      final cleanGender = (filters?.gender != null &&
              filters!.gender!.trim().isNotEmpty &&
              filters.gender!.trim().toLowerCase() != 'all')
          ? filters.gender!.trim()
          : null;

      final rpcFuture = _readClient.rpc(
        'fn_get_filtered_feed',
        params: {
          'p_limit': limit,
          'p_last_created_at': lastCreatedAt,
          'p_search_query': searchQuery?.trim().isNotEmpty == true ? searchQuery!.trim() : null,
          'p_min_age': filters?.minAge,
          'p_max_age': filters?.maxAge,
          'p_state': filters?.state,
          'p_district': filters?.district,
          'p_taluka': filters?.taluka,
          // 🔍 PATHWAY A: Pass explicit gender for relative browse users
          // (they have no own profile, so auto-detection returns NULL)
          'p_gender': cleanGender,
          'p_sort_by': sortBy,
        },
      ).timeout(Duration(seconds: (isGuest || isRelativeBrowse) ? 10 : 20));

      ProfileModel? ownProfile;
      dynamic response;

      if (isGuest) {
        // Guest: Just fetch the feed, skip own profile entirely
        response = await rpcFuture.catchError((e) {
          AppLogger.error('ProfileRepository', 'ProfileRepository.getProfiles RPC error (Guest): $e');
          return []; // Return empty list on error
        });
      } else {
        // Logged-in: Fetch own profile and feed in parallel
        final results = await Future.wait<dynamic>([
          getOwnProfile().catchError((e) {
            AppLogger.error('ProfileRepository', 'ProfileRepository.getProfiles getOwnProfile error: $e');
            return BackendResponse<ProfileModel?>.failure(e.toString());
          }),
          rpcFuture.catchError((e) {
            AppLogger.error('ProfileRepository', 'ProfileRepository.getProfiles RPC error: $e');
            return []; // Return empty list on error
          }),
        ]);
        final ownProfileRes = results[0] as BackendResponse<ProfileModel?>;
        response = results[1];
        ownProfile = ownProfileRes.data;
        
        // Gracefully continue even if own profile fetch failed — feed can still render
        if (ownProfile == null && !ownProfileRes.isSuccess) {
          AppLogger.error('ProfileRepository', 'ProfileRepository: Own profile fetch failed, continuing with feed only');
        }
      }

      final List<dynamic> rawList = response as List;

      // 🔍 DISTRICT CASCADE FALLBACK: If district filter is active but yields 0 results,
      // retry without district to show state-wide or all-India profiles.
      // This prevents empty screens for relative browse users in smaller districts.
      if (rawList.isEmpty && filters?.district != null && lastCreatedAt == null) {
        AppLogger.debug('ProfileRepository', '🔍 District cascade: No profiles in ${filters!.district}, falling back to wider search');
        final fallbackResponse = await _readClient.rpc(
          'fn_get_filtered_feed',
          params: {
            'p_limit': limit,
            'p_last_created_at': null,
            'p_search_query': searchQuery?.trim().isNotEmpty == true ? searchQuery!.trim() : null,
            'p_min_age': filters.minAge,
            'p_max_age': filters.maxAge,
            'p_state': filters.state,
            'p_district': null, // Remove district filter
            'p_taluka': null,   // Remove taluka filter
            'p_gender': cleanGender,
            'p_sort_by': sortBy,
          },
        ).timeout(const Duration(seconds: 15));

        final fallbackList = fallbackResponse as List;
        if (fallbackList.isEmpty) {
          if (lastCreatedAt == null) {
            _isDistrictFallback = false;
            _lastRequestedDistrict = null;
            _lastSelectedState = null;
          }
          return BackendResponse.success([]);
        }

        final fallbackProfiles = await mapListInBackground<ProfileModel>(
          fallbackList, ProfileModel.fromJson,
        );
        final fallbackIds = fallbackProfiles.map((p) => p.id).toList();
        final fallbackPhotos = await _photoRepository.getPrimaryPhotosForProfiles(fallbackIds);
        List<ProfileModel> fallbackEnriched = fallbackProfiles;
        if (fallbackPhotos.isSuccess) {
          final photoMap = {for (var p in fallbackPhotos.data) p.profileId: p};
          fallbackEnriched = fallbackProfiles.map((p) {
            final primaryPhoto = photoMap[p.id];
            return primaryPhoto != null ? p.copyWith(photos: [primaryPhoto]) : p;
          }).toList();
        }

        if (lastCreatedAt == null) {
          _isDistrictFallback = true;
          _lastRequestedDistrict = filters.district;
          _lastSelectedState = filters.state;

          _cachedFeed = fallbackEnriched;
          _lastFeedFilters = filters;
          _lastSearchQuery = searchQuery;
          _feedCacheTimestamp = DateTime.now();
          _notifyFeedUpdated(fallbackEnriched);
        }
        return BackendResponse.success(fallbackEnriched);
      }

      if (rawList.isEmpty) {
        if (lastCreatedAt == null) {
          _isDistrictFallback = false;
          _lastRequestedDistrict = null;
          _lastSelectedState = null;
        }
        return BackendResponse.success([]);
      }

      if (lastCreatedAt == null) {
        _isDistrictFallback = false;
        _lastRequestedDistrict = null;
        _lastSelectedState = null;
      }

      // 4. Parse on Isolate (Background Thread)
      final List<ProfileModel> profiles =
          await mapListInBackground<ProfileModel>(
            rawList,
            ProfileModel.fromJson,
          );

      // 5. 🧬 PRO SCALE: Batch Enrichment (Photos)
      // This eliminates 20 separate photo API calls.
      final profileIds = profiles.map((p) => p.id).toList();
      final photosRes = await _photoRepository.getPrimaryPhotosForProfiles(profileIds);
      
      List<ProfileModel> enrichedProfiles = profiles;
      if (photosRes.isSuccess) {
        final photoMap = {for (var p in photosRes.data) p.profileId: p};
        enrichedProfiles = profiles.map((p) {
          final primaryPhoto = photoMap[p.id];
          return primaryPhoto != null ? p.copyWith(photos: [primaryPhoto]) : p;
        }).toList();
      }

      // 6. Update Feed Cache (Only for initial page loads)
      if (lastCreatedAt == null) {
        _cachedFeed = enrichedProfiles;
        _lastFeedFilters = filters;
        _lastSearchQuery = searchQuery;
        _lastSortBy = sortBy;
        _feedCacheTimestamp = DateTime.now();

        // 7. 🧬 PRO SCALE: Persist Default Feed to Disk
        // We only persist the "default" feed (no filters/search, smart sort) to drive instant startup.
        if (sortBy == 'smart' && filters == null && (searchQuery == null || searchQuery.isEmpty)) {
          final feedJson = enrichedProfiles.map((p) => p.toJson()).toList();
          _cacheService.saveHomeFeed(feedJson);
        }
        _notifyFeedUpdated(enrichedProfiles);
      }

      return BackendResponse.success(enrichedProfiles);
    } catch (e, stack) {
      AppLogger.error('ProfileRepository', 'ProfileRepository.getProfiles Error: $e\n$stack');
      return BackendResponse.failure(e.toString());
    }
  }

  /// Lazy enrichment for a single profile.
  /// Fetches photos, bookmark status, and match status.
  Future<ProfileModel> getProfileMetadata(
    ProfileModel profile,
  ) async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) return profile;

      final ownProfileRes = await getOwnProfile();
      final myProfileId = ownProfileRes.data?.id;
      if (myProfileId == null) return profile;

      // Parallel Execution for a SINGLE profile
      // 🌐 PRO SCALE: Use Read Replica for bookmark and match statuses
      final results = await Future.wait<dynamic>([
        _readClient
            .from('bookmarks')
            .select('profile_id')
            .eq('user_id', userId)
            .eq('profile_id', profile.id)
            .maybeSingle()
            .catchError((e) {
              AppLogger.error('ProfileRepository', 'Error fetching bookmark for ${profile.id}: $e');
              return null;
            }),
        _readClient
            .from('profile_shares')
            .select('sharer_id, recipient_id')
            .eq('status', 'matched')
            .or('and(sharer_id.eq.$myProfileId,recipient_id.eq.${profile.id}),and(sharer_id.eq.${profile.id},recipient_id.eq.$myProfileId)')
            .maybeSingle()
            .catchError((e) {
              AppLogger.error('ProfileRepository', 'Error fetching match for ${profile.id}: $e');
              return null;
            }),
        _photoRepository.getPhotos(profile.id).catchError((e) {
          AppLogger.error('ProfileRepository', 'Error fetching photos for ${profile.id}: $e');
          return BackendResponse<List<PhotoModel>>.success([]);
        }),
      ]);

      final isBookmarked = results[0] != null;
      final isMatched = results[1] != null;
      List<PhotoModel> photos = [];
      if (results[2] is BackendResponse<List<PhotoModel>>) {
        photos = (results[2] as BackendResponse<List<PhotoModel>>).data;
      }

      return profile.copyWith(
        isBookmarked: isBookmarked,
        isMatched: isMatched,
        photos: photos.isNotEmpty ? photos : profile.photos,
      );
    } catch (e) {
      AppLogger.error('ProfileRepository', 'Error in getProfileMetadata: $e');
      return profile;
    }
  }

  /// 🧬 EXTREME PERFORMANCE: Predictive Metadata Engine
  /// Fetches metadata for multiple profiles in parallel to prime the cache
  /// before the user even scrolls to them.
  Future<void> predictiveEnrichment(List<ProfileModel> upcomingProfiles) async {
    final idsToEnrich = upcomingProfiles
        .where((p) => !p.isEnriched)
        .map((p) => p.id)
        .toList();

    if (idsToEnrich.isEmpty) return;

    AppLogger.debug('ProfileRepository', 'ProfileRepository: Predictively enriching ${idsToEnrich.length} profiles');

    try {
      final userId = _supabase.auth.currentUser?.id;
      final ownProfileRes = await getOwnProfile();
      final myProfileId = ownProfileRes.data?.id;

      // 1. Parallel Batch Requests
      // 🌐 PRO SCALE: Use Read Replica for all batch metadata enrichment
      final results = await Future.wait([
        // Photos Batch
        _photoRepository.getPhotosBatch(idsToEnrich),
        // Bookmarks Batch
        if (userId != null)
          _readClient.from('bookmarks').select('profile_id').inFilter('profile_id', idsToEnrich).eq('user_id', userId)
        else
          Future.value([]),
        // Matches Batch
        if (myProfileId != null)
          _readClient.from('profile_shares')
            .select('sharer_id, recipient_id')
            .eq('status', 'matched')
            .or('and(sharer_id.in.(${idsToEnrich.join(",")}),recipient_id.eq.$myProfileId),and(sharer_id.eq.$myProfileId,recipient_id.in.(${idsToEnrich.join(",")}))')
        else
          Future.value([]),
      ]);

      final photosMap = (results[0] as BackendResponse<Map<String, List<PhotoModel>>>).data;
      final bookmarkedIds = (results[1] as List).map((e) => e['profile_id'].toString()).toSet();
      
      final matchesList = results[2] as List;
      final matchedIds = <String>{};
      for (final m in matchesList) {
        final sId = m['sharer_id'].toString();
        final rId = m['recipient_id'].toString();
        if (sId == myProfileId) {
          matchedIds.add(rId);
        } else {
          matchedIds.add(sId);
        }
      }

      // 2. Update Feed Cache
      if (_cachedFeed != null) {
        for (final id in idsToEnrich) {
          final idx = _cachedFeed!.indexWhere((p) => p.id == id);
          if (idx != -1) {
            final oldProfile = _cachedFeed![idx];
            _cachedFeed![idx] = oldProfile.copyWith(
              photos: photosMap[id] ?? oldProfile.photos,
              isBookmarked: bookmarkedIds.contains(id),
              isMatched: matchedIds.contains(id),
            );
            // Trigger pre-computation of UI data in the background isolate (simulated here by calling toDisplayMap)
            _cachedFeed![idx].toDisplayMap();
          }
        }
      }
    } catch (e) {
      AppLogger.error('ProfileRepository', 'ProfileRepository: Predictive enrichment failed: $e');
    }
  }

  // ---------------------------------------------------------------------------
  // 5. Bookmark & Block Operations
  // ---------------------------------------------------------------------------

  Future<BackendResponse<List<ProfileModel>>> getBookmarkedProfiles() async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) return BackendResponse.success([]);

      // Check Local Cache first
      final localData = _cacheService.getBookmarks();
      if (localData.isNotEmpty) {
        final cachedProfiles = await mapListInBackground<ProfileModel>(
          localData,
          ProfileModel.fromJson,
        );
        _fetchAndCacheBookmarks(userId); // Background Sync
        return BackendResponse.success(cachedProfiles);
      }

      return await _fetchAndCacheBookmarks(userId);
    } catch (e) {
      return BackendResponse.failure(e.toString());
    }
  }

  Future<BackendResponse<void>> toggleBookmark(
    String profileId,
    bool isAdd,
  ) async {
    final action = isAdd ? 'add' : 'remove';
    try {
      final response = await _supabase.rpc(
        'fn_manage_bookmarks',
        params: {
          'action': action,
          'payload': {'profile_id': profileId},
        },
      );
      BookmarkNotifier().updateBookmark(profileId, isAdd);
      return BackendResponse.fromRpc(response);
    } catch (e) {
      // Handle race condition where user double taps
      if (e.toString().contains('duplicate')) {
        BookmarkNotifier().updateBookmark(profileId, isAdd);
        return BackendResponse.success(null);
      }
      return BackendResponse.failure(e.toString());
    }
  }

  /// Block a user via fn_manage_safety RPC (07_blocks_reports.sql)
  Future<BackendResponse<void>> blockUser(String blockedUserId) async {
    try {
      final response = await _supabase.rpc(
        'fn_manage_safety',
        params: {
          'action': 'block',
          'payload': {'target_id': blockedUserId},
        },
      );
      clearCache();
      return BackendResponse.fromRpc(response);
    } catch (e) {
      return BackendResponse.failure(e.toString());
    }
  }

  /// Unblock a user via fn_manage_safety RPC
  Future<BackendResponse<void>> unblockUser(String blockedUserId) async {
    try {
      final response = await _supabase.rpc(
        'fn_manage_safety',
        params: {
          'action': 'unblock',
          'payload': {'target_id': blockedUserId},
        },
      );
      clearCache();
      return BackendResponse.fromRpc(response);
    } catch (e) {
      return BackendResponse.failure(e.toString());
    }
  }

  /// Report a user via fn_manage_safety RPC (07_blocks_reports.sql)
  Future<BackendResponse<void>> reportUser({
    required String reportedUserId,
    required String reason,
    String? details,
  }) async {
    try {
      final response = await _supabase.rpc(
        'fn_manage_safety',
        params: {
          'action': 'report',
          'payload': {
            'target_id': reportedUserId,
            'reason': reason,
            if (details != null) 'details': details,
          },
        },
      );
      return BackendResponse.fromRpc(response);
    } catch (e) {
      return BackendResponse.failure(e.toString());
    }
  }

  // ---------------------------------------------------------------------------
  // 6. Private Helpers & Query Logic
  // ---------------------------------------------------------------------------

  /// Helper to call the central RPC function
  Future<BackendResponse<void>> _callManageProfileRpc(
    String action,
    Map<String, dynamic> payload,
  ) async {
    try {
      AppLogger.debug('ProfileRepository', 'RPC Call: fn_manage_profile -> $action');
      final response = await _supabase.rpc(
        'fn_manage_profile',
        params: {'action': action, 'payload': payload},
      );
      clearCache(); // Force refresh after any update
      return BackendResponse.fromRpc(response);
    } catch (e) {
      return BackendResponse.failure(e.toString());
    }
  }

  // --- Filtering logic moved to server-side RPC (fn_get_filtered_feed) ---


  Future<BackendResponse<ProfileModel?>> _fetchAndCacheOwnProfile(
    String userId,
  ) async {
    try {
      final response = await _supabase
          .from('profiles')
          .select()
          .eq('user_id', userId)
          .maybeSingle()
          .timeout(const Duration(seconds: 15));

      if (response == null) {
        clearCache();
        return BackendResponse.success(null);
      }

      // Debug: log raw is_pdf_unlocked from DB (helps diagnose payment→unlock sync)
      AppLogger.debug('ProfileRepository', 'ProfileRepository: Raw DB is_pdf_unlocked=${response['is_pdf_unlocked']}');

      var profile = ProfileModel.fromJson(response);

      // Fetch Photos
      final photosRes = await _photoRepository.getPhotos(profile.id);
      photosRes.fold(
        onSuccess: (photos) => profile = profile.copyWith(photos: photos),
        onFailure: (_) {},
      );

      // Update Caches
      _updateMemoryCache(profile);
      await _cacheService.saveOwnProfile(profile.toJson());

      return BackendResponse.success(profile);
    } catch (e) {
      return BackendResponse.failure(e.toString());
    }
  }

  Future<BackendResponse<List<ProfileModel>>> _fetchAndCacheBookmarks(
    String userId,
  ) async {
    final response = await _supabase
        .from('bookmarks')
        .select('profile_id, profiles(*)')
        .eq('user_id', userId)
        .order('created_at', ascending: false);

    final profiles = await mapListInBackground<ProfileModel>(
      response as List,
      _mapBookmark, // Helper function defined below
    );

    await _cacheService.saveBookmarks(profiles.map((p) => p.toJson()).toList());
    return BackendResponse.success(profiles);
  }

  Future<void> _checkPendingReferral(String userId) async {
    final pendingReferralId = _cacheService.getPendingReferralId();
    if (pendingReferralId != null) {
      final result = await _referralRepository.completeReferral(
        pendingReferralId,
        userId,
      );

      result.fold(
        onSuccess: (_) async {
          AppLogger.debug('ProfileRepository', 'Referral completed successfully for $userId');
          await _cacheService.clearPendingReferralId();
        },
        onFailure: (err) => debugPrint('Failed to complete referral: $err'),
      );
    }
  }

  Future<void> _checkPendingPromoCode() async {
    final pendingPromoCode = _cacheService.getPendingPromoCode();
    if (pendingPromoCode != null) {
      AppLogger.debug('ProfileRepository', 'ProfileRepository: Registering pending promo code: $pendingPromoCode');
      final result =
          await _influencerRepository.registerCreatorReferral(pendingPromoCode);

      result.fold(
        onSuccess: (_) async {
          AppLogger.debug('ProfileRepository', 'Influencer referral registered successfully');
          await _cacheService.clearPendingPromoCode();
        },
        onFailure: (err) {
          AppLogger.error('ProfileRepository', 'Failed to register influencer referral: $err');
          if (err.contains('Invalid')) {
            _cacheService.clearPendingPromoCode();
          }
        },
      );
    }
  }

  // ---------------------------------------------------------------------------
  // 7. Cache State Management
  // ---------------------------------------------------------------------------

  void _updateMemoryCache(ProfileModel profile) {
    _cachedOwnProfile = profile;
    _cacheTimestamp = DateTime.now();
    // 🚀 Sync with SessionManager for global visibility (e.g., role-based UI checks)
    SessionManager.instance.setCurrentProfile(profile);
    // 🎁 Sync trial-aware premium status: paid subscription OR within 7-day trial
    SessionManager.instance.setPremium(
      profile.isPremium ||
          SubscriptionRepository.isWithinFreeTrial(profile.createdAt),
    );
  }

  bool _isMemoryCacheValid(String userId) {
    return _cachedOwnProfile != null &&
        _cachedOwnProfile!.userId == userId &&
        _cacheTimestamp != null &&
        DateTime.now().difference(_cacheTimestamp!) < _cacheDuration;
  }

  void clearCache() {
    _cachedOwnProfile = null;
    _cacheTimestamp = null;
    _cachedFeed = null;
    _feedCacheTimestamp = null;
  }

  void clearFeedCache() {
    _cachedFeed = null;
    _feedCacheTimestamp = null;
    _lastFeedFilters = null;
    _lastSearchQuery = null;
    _isDistrictFallback = false;
    _lastRequestedDistrict = null;
    _lastSelectedState = null;
  }

  bool _isFeedCacheValid(FilterCriteria? filters, String? query, [String sortBy = 'smart']) {
    return _cachedFeed != null &&
        _feedCacheTimestamp != null &&
        DateTime.now().difference(_feedCacheTimestamp!) < _cacheDuration &&
        _lastFeedFilters == filters &&
        _lastSearchQuery == query &&
        _lastSortBy == sortBy;
  }

  /// Background refresh helper for SWR
  Future<void> _fetchAndCacheProfiles({
    required int limit,
    FilterCriteria? filters,
    String? searchQuery,
    String sortBy = 'smart',
  }) async {
    // 🛡️ RECURSION & TEST GUARD: Block re-entry and skip background refresh in unit tests
    if (_isPerformingBackgroundFetch || testClient != null) return;
    _isPerformingBackgroundFetch = true;

    try {
      // 🧬 PRO SCALE: Use 'unawaited' or simply don't wait here if we want 
      // it to be truly background. However, since we want to capture the 
      // future for others to join, we store it.
      final fetchFuture = getProfiles(
        limit: limit,
        filters: filters,
        searchQuery: searchQuery,
        sortBy: sortBy,
        forceRefresh: true,
      );
      
      activeFetchFuture = fetchFuture;
      
      await fetchFuture;
    } catch (e) {
      AppLogger.error('ProfileRepository', 'ProfileRepository: Background refresh failed: $e');
    } finally {
      _isPerformingBackgroundFetch = false;
      activeFetchFuture = null;
    }
  }

  /// Applies an optimistic PDF unlock to the cached profile.
  /// Call after payment verification succeeds for biodata_unlock to ensure the UI
  /// shows unlocked immediately, regardless of DB replication lag or backend timing.
  void applyOptimisticPdfUnlock() {
    final profile = _cachedOwnProfile;
    if (profile == null) return;
    final updated = profile.copyWith(isPdfUnlocked: true);
    _updateMemoryCache(updated);
    _cacheService.saveOwnProfile(updated.toJson());
    AppLogger.debug('ProfileRepository', 'ProfileRepository: Optimistic PDF unlock applied to cache');
  }

  /// Static mapper for bookmarks (Must be static for Isolate)
  static ProfileModel _mapBookmark(Map<String, dynamic> bookmark) {
    final profileData = Map<String, dynamic>.from(bookmark['profiles']);
    return ProfileModel.fromJson(profileData).copyWith(isBookmarked: true);
  }
}
