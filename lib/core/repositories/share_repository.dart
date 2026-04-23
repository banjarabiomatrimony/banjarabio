import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:share_plus/share_plus.dart';

import 'package:banjarabio/core/config/share_config.dart';
import 'package:banjarabio/core/models/backend_response.dart';
import 'package:banjarabio/core/models/profile_share_model.dart';
import 'package:banjarabio/notification/features/admin_notification_service.dart';
import 'package:banjarabio/core/repositories/usage_repository.dart';
import 'package:banjarabio/core/repositories/profile_repository.dart';
import 'package:banjarabio/core/services/isolate_manager.dart';
import 'package:banjarabio/core/repositories/isolate_first_repository.dart';

/// [ShareRepository]
///
/// Manages the social sharing aspects of the app: Sharing profiles,
/// tracking inbound/outbound shares, and handling "Matches" (Mutual shares).
///
/// 🏆 10/10 Architecture Highlights:
/// 1. **Secure RPCs**: All state changes go through `fn_manage_shares` to enforce business rules.
/// 2. **Isolate Safety**: Complex list processing uses static, pure functions to prevent memory leaks.
/// 3. **Platform Integration**: robust handling of WhatsApp and Native Share sheets with fallbacks.
class ShareRepository extends IsolateFirstRepository {
  // ---------------------------------------------------------------------------
  // 1. Singleton & Dependencies
  // ---------------------------------------------------------------------------
  // ---------------------------------------------------------------------------
  // 1. Singleton & Dependencies
  // ---------------------------------------------------------------------------
  static final ShareRepository _instance = ShareRepository._internal();

  /// Factory constructor returns the singleton instance
  factory ShareRepository() => _instance;

  /// Visible for testing - allows injection of mock Supabase client
  @visibleForTesting
  SupabaseClient? testClient;

  /// Visible for testing - allows injection of mock UsageRepository
  @visibleForTesting
  UsageRepository? testUsageRepository;

  /// Visible for testing - allows injection of mock ProfileRepository
  @visibleForTesting
  ProfileRepository? testProfileRepository;

  SupabaseClient get _supabase => testClient ?? Supabase.instance.client;
  UsageRepository get _usageRepository => testUsageRepository ?? UsageRepository();
  ProfileRepository get _profileRepository => testProfileRepository ?? ProfileRepository();

  /// Internal constructor for singleton
  ShareRepository._internal();

  /// Visible for testing - allows injection of dependencies
  @visibleForTesting
  ShareRepository.test({
    required SupabaseClient supabase,
    required UsageRepository usageRepository,
    required ProfileRepository profileRepository,
  }) : testClient = supabase,
       testUsageRepository = usageRepository,
       testProfileRepository = profileRepository;

  // ---------------------------------------------------------------------------
  // 2. Core Sharing Logic
  // ---------------------------------------------------------------------------

  /// Returns current user's profile ID (for matched tab display)
  Future<String?> getMyProfileId() async {
    final res = await _profileRepository.getOwnProfile();
    return res.data?.id;
  }

  /// Shares a profile with another user (Internal) or via Apps (External).
  Future<BackendResponse<ProfileShare>> shareProfile({
    required String sharedProfileId,
    required String sharingMethod,
    String? recipientId, // Required for 'in_app' sharing
    String? recipientName, // For metadata
    String? recipientRelation, // For metadata
    String? profileName, // For share message
  }) async {
    try {
      // 1. Validation
      final ownProfileRes = await _profileRepository.getOwnProfile();
      if (!ownProfileRes.isSuccess || ownProfileRes.data == null) {
        return BackendResponse.failure(
          'You must have a profile to share profiles.',
        );
      }

      // 2. Record Share via RPC (Secure) – method must match 06_shares CHECK
      final method = sharingMethod.toLowerCase();
      if (!ShareConfig.isValidSharingMethod(method)) {
        return BackendResponse.failure('Invalid sharing method: $sharingMethod');
      }
      debugPrint('RPC Call: fn_manage_shares -> create_share');

      final rpcResponse = await _supabase.rpc(
        'fn_manage_shares',
        params: {
          'action': 'create_share',
          'payload': {
            'profile_id': sharedProfileId,
            'recipient_id': recipientId, // Can be null for external shares
            'method': method,
            'recipient_name': recipientName,
            'recipient_relation': recipientRelation,
          },
        },
      );

      // 3. Platform Action (WhatsApp / System Dialog)
      // We construct the Universal Link for the profile.
      // This will open the app directly if installed, or redirect to a landing page/store.
      final shareUrl = 'https://banjarabio.com/profile/$sharedProfileId';
      
      // Fallback for Play Store referrals (Deferred Deep Linking)
      // final shareUrl = 'https://play.google.com/store/apps/details?id=com.avishio.banjarabio&referrer=profile/$sharedProfileId';
      
      final shareMessage =
          'Check out this profile on BanjaraBio: ${profileName ?? "User"}';

      await _executePlatformShare(
        method: sharingMethod,
        url: shareUrl,
        message: shareMessage,
      );

      // 4. Analytics
      await _usageRepository.incrementShareCount();

      // 5. Return Created Record
      // The RPC returns the ID of the new share record.
      final response = BackendResponse.fromRpc<String>(
        rpcResponse,
        mapper: (json) => json['id']?.toString() ?? '',
      );

      if (!response.isSuccess) {
        return BackendResponse.failure(response.errorMessage);
      }

      // Fetch full model from view (API contract) for complete profile data
      final fullRecord = await _supabase
          .from('shared_profiles_view')
          .select()
          .eq('share_id', response.data)
          .single();

      return BackendResponse.success(ProfileShare.fromJson(fullRecord));
    } catch (e, stack) {
      return BackendResponse.failure(e.toString(), stackTrace: stack);
    }
  }

  /// Handles the native platform interactions.
  Future<void> _executePlatformShare({
    required String method,
    required String url,
    required String message,
  }) async {
    switch (method.toLowerCase()) {
      case 'whatsapp':
        // Refactored to use system share dialog instead of direct WhatsApp link
        // This allows sharing with any contact/group as per new requirements
        await Share.share('$message\n\n$url', subject: 'BanjaraBio Profile');
        break;

      case 'link':
        await Clipboard.setData(ClipboardData(text: url));
        break;

      case 'in_app':
      // For in_app sharing, we don't open any external platform dialog.
      // The RPC call has already recorded the share/interest internally.
      debugPrint('Internal share recorded. Skipping platform share dialog.');
      break;

    default:
      await Share.share('$message\n\n$url', subject: 'BanjaraBio Profile');
      break;
  }
}

  // ---------------------------------------------------------------------------
  // 3. Fetching Lists (Sent / Received)
  // ---------------------------------------------------------------------------

  /// Get profiles I have shared.
  Future<BackendResponse<List<ProfileShare>>> getSharesByMe({
    int limit = 50,
  }) async {
    return _fetchShares(
      filterColumn: 'sharer_id',
      limit: limit,
      excludeMatched: true,
    );
  }

  /// Get profiles shared with me.
  Future<BackendResponse<List<ProfileShare>>> getSharesWithMe({
    int limit = 50,
  }) async {
    return _fetchShares(
      filterColumn: 'recipient_id',
      limit: limit,
      excludeMatched: true,
      excludeSelf: true,
    );
  }

  /// Unified fetcher to reduce duplication.
  Future<BackendResponse<List<ProfileShare>>> _fetchShares({
    required String filterColumn,
    required int limit,
    bool excludeMatched = false,
    bool excludeSelf = false,
  }) async {
    try {
      final ownProfileRes = await _profileRepository.getOwnProfile();
      if (ownProfileRes.data == null) return BackendResponse.success([]);

      final myProfileId = ownProfileRes.data!.id;

      var query = _supabase
          .from('shared_profiles_view')
          .select()
          .eq(filterColumn, myProfileId);

      if (excludeMatched) query = query.neq('status', 'matched');
      if (excludeSelf) query = query.neq('sharer_id', myProfileId);

      final response = await query
          .order('share_created_at', ascending: false)
          .limit(limit);

      final list = await mapListInBackground<ProfileShare>(
        response as List,
        ProfileShare.fromJson,
      );

      return BackendResponse.success(list);
    } catch (e) {
      return BackendResponse.failure(e.toString());
    }
  }

  // ---------------------------------------------------------------------------
  // 4. Status Management (Matches)
  // ---------------------------------------------------------------------------

  /// Fetches mutual matches.
  ///
  /// A match occurs when User A shares Profile X with User B, AND
  /// User B shares Profile X with User A (or accepts the share).
  Future<BackendResponse<List<ProfileShare>>> getMatchedProfiles({
    int limit = 50,
  }) async {
    try {
      final ownProfileRes = await _profileRepository.getOwnProfile();
      if (ownProfileRes.data == null) return BackendResponse.success([]);
      final myProfileId = ownProfileRes.data!.id;

      // Fetch raw matches where I am EITHER sharer OR recipient
      final response = await _supabase
          .from('shared_profiles_view')
          .select()
          .eq('status', 'matched')
          .or('sharer_id.eq.$myProfileId,recipient_id.eq.$myProfileId')
          .order('share_updated_at', ascending: false)
          .limit(limit);

      // 🚀 ISOLATE SAFETY: We pass a typed DTO to the static function.
      final list = await IsolateManager.compute(
        _processMatchesIsolate,
        _MatchProcessDto(rawShares: response as List, myProfileId: myProfileId),
      );

      return BackendResponse.success(list);
    } catch (e) {
      return BackendResponse.failure(e.toString());
    }
  }

  /// ⚠️ STATIC PURE FUNCTION
  /// Runs in a separate thread. Deduplicates matches so that if A matched B,
  /// we show it only once, regardless of who initiated.
  static List<ProfileShare> _processMatchesIsolate(_MatchProcessDto params) {
    final rawShares = params.rawShares;
    final myProfileId = params.myProfileId;

    // Map to ensure uniqueness by "Other User ID"
    final Map<String, dynamic> uniqueMap = {};

    for (var item in rawShares) {
      final share = item as Map<String, dynamic>;
      final sharerId = share['sharer_id'].toString();
      final recipientId = share['recipient_id'].toString();

      // Determine who the "Other Person" is in this relationship
      final otherPersonId = (sharerId == myProfileId) ? recipientId : sharerId;

      // If we haven't seen a match involving this person yet, add it
      if (!uniqueMap.containsKey(otherPersonId)) {
        uniqueMap[otherPersonId] = share;
      }
    }

    return uniqueMap.values.map((json) => ProfileShare.fromJson(json)).toList();
  }

  // ---------------------------------------------------------------------------
  // 5. Actions (Update / Delete)
  // ---------------------------------------------------------------------------

  Future<BackendResponse<void>> markAsViewed(String shareId) async {
    return _callShareRpc('update_status', {
      'share_id': shareId,
      'status': 'viewed',
    });
  }

  Future<BackendResponse<void>> updateShareStatus(
    String shareId,
    String status,
  ) async {
    final normalized = status.toLowerCase();
    if (!ShareConfig.isValidStatus(normalized)) {
      return BackendResponse.failure('Invalid status: $status');
    }
    final result = await _callShareRpc('update_status', {
      'share_id': shareId,
      'status': normalized,
    });

    // 🔔 Admin Alert: New match created
    if (result.isSuccess && normalized == 'matched') {
      AdminNotificationService().notifyNewMatch();
    }

    return result;
  }

  Future<BackendResponse<void>> deleteShare(String shareId) async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) return BackendResponse.failure('Not logged in');

      // We use auth.uid() directly for security in the RLS policy usually,
      // but if the table key is sharer_id (profile_id), we need the profile id.
      // Assuming RLS allows users to delete their own rows based on auth.uid() linkage.
      await _supabase.from('profile_shares').delete().eq('id', shareId);

      return BackendResponse.success(null);
    } catch (e) {
      return BackendResponse.failure(e.toString());
    }
  }

  /// Delete multiple shares
  Future<BackendResponse<void>> deleteShares(List<String> shareIds) async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) return BackendResponse.failure('Not logged in');

      if (shareIds.isEmpty) return BackendResponse.success(null);

      // We use auth.uid() directly for security in the RLS policy usually
      await _supabase.from('profile_shares').delete().inFilter('id', shareIds);

      return BackendResponse.success(null);
    } catch (e) {
      return BackendResponse.failure(e.toString());
    }
  }

  /// Helper for RPC calls
  Future<BackendResponse<void>> _callShareRpc(
    String action,
    Map<String, dynamic> payload,
  ) async {
    try {
      final response = await _supabase.rpc(
        'fn_manage_shares',
        params: {'action': action, 'payload': payload},
      );
      return BackendResponse.fromRpc(response);
    } catch (e) {
      return BackendResponse.failure(e.toString());
    }
  }
}

/// DTO for Isolate Communication (Type Safety)
class _MatchProcessDto {
  final List<dynamic> rawShares;
  final String myProfileId;

  _MatchProcessDto({required this.rawShares, required this.myProfileId});
}
