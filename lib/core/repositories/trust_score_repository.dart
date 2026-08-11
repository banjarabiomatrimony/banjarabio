import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:banjarabio/core/config/storage_config.dart';
import 'package:banjarabio/core/models/backend_response.dart';
import 'package:banjarabio/core/models/profile_model.dart';
import 'package:banjarabio/core/models/trust_score_config.dart';
import 'package:banjarabio/notification/features/admin_notification_service.dart';
import 'package:banjarabio/core/repositories/profile_repository.dart';
import 'package:banjarabio/core/services/app_logger.dart';

class TrustScoreRepository {
  // ---------------------------------------------------------------------------
  // 1. Singleton Pattern & Dependencies
  // ---------------------------------------------------------------------------
  static final TrustScoreRepository _instance = TrustScoreRepository._();
  factory TrustScoreRepository() => _instance;
  TrustScoreRepository._();

  SupabaseClient get _supabase => testClient ?? Supabase.instance.client;

  @visibleForTesting
  SupabaseClient? testClient;

  @visibleForTesting
  ProfileRepository? testProfileRepository;

  ProfileRepository get _profileRepository =>
      testProfileRepository ?? ProfileRepository();

  @visibleForTesting
  void reset() {
    testClient = null;
    testProfileRepository = null;
  }

  static const String statusNotStarted = 'not_started';
  static const String statusInProgress = 'in_progress';
  static const String statusPendingReview = 'pending_review';
  static const String statusVerified = 'verified';
  static const String statusRejected = 'rejected';

  /// Calculate Trust Score for current user
  /// Now fetches trustScore directly from profiles table (updated by DB triggers)
  /// Calculate Trust Score for current user
  /// Logic moved to Dart for migration readiness (removes dependency on DB triggers)
  Future<BackendResponse<int>> calculateTrustScore({
    ProfileModel? profile,
  }) async {
    try {
      final statusRes = await getVerificationStatus(profile: profile);

      final BackendResponse<ProfileModel?> profileRes;
      if (profile != null) {
        profileRes = BackendResponse.success(profile);
      } else {
        profileRes = await _profileRepository.getOwnProfile();
      }

      return await statusRes.fold(
        onSuccess: (status) async {
          return profileRes.fold(
            onSuccess: (profile) {
              final score = TrustScoreConfig.calculateScore(
                hasMobile: status['mobile'] == statusVerified,
                hasEmail: status['email'] == statusVerified,
                hasPhoto: status['photo'] == statusVerified,
                hasCommunityId: status['communityId'] == statusVerified,
                hasGovtId: status['govtId'] == statusVerified,
                hasReference: status['reference'] == statusVerified,
                hasVideoBio: status['videoBio'] == statusVerified,
                isProfileComplete:
                    (profile?.calculateCompletionPercentage() ?? 0) >= 100,
              );
              return BackendResponse.success(score);
            },
            onFailure: (error) => BackendResponse.failure(error),
          );
        },
        onFailure: (error) => BackendResponse.failure(error),
      );
    } catch (e, stack) {
      AppLogger.error('TrustScoreRepository', 'Error calculating trust score: $e');
      return BackendResponse.failure(
        e.toString(),
        stackTrace: stack,
        onRetry: () => calculateTrustScore(),
      );
    }
  }

  /// Get status of all verification steps from real backend
  Future<BackendResponse<Map<String, String>>> getVerificationStatus({
    ProfileModel? profile,
  }) async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) return BackendResponse.success(_emptyStatus());

    try {
      // Use provided profile or fetch fresh
      final BackendResponse<ProfileModel?> profileRes;
      if (profile != null) {
        profileRes = BackendResponse.success(profile);
      } else {
        profileRes = await _profileRepository.getOwnProfile();
      }

      return await profileRes.fold(
        onSuccess: (profile) async {
          if (profile == null) return BackendResponse.success(_emptyStatus());

          // Fetch manual verification requests
          final requestsResponse = await _supabase
              .from('verification_requests')
              .select('verification_type, status')
              .eq('user_id', userId);

          final List requests = requestsResponse as List;
          final Map<String, String> statuses = {};

          for (var req in requests) {
            statuses[req['verification_type']] = _mapDbStatusToAppStatus(
              req['status'],
            );
          }

          // Check references
          final refResponse = await _supabase
              .from('user_references')
              .select('status')
              .eq('user_id', userId);

          final List refs = refResponse as List;
          String refStatus = statusNotStarted;
          if (refs.isNotEmpty) {
            refStatus = refs.any((r) => r['status'] == 'verified')
                ? statusVerified
                : statusPendingReview;
          }

          final statusMap = {
            'mobile':
                (profile.phoneNumber != null && profile.phoneNumber!.isNotEmpty)
                ? statusVerified
                : statusNotStarted,
            'email': (profile.email != null && profile.email!.isNotEmpty)
                ? statusVerified
                : statusNotStarted,
            'photo': statuses['selfie'] ?? statusNotStarted,
            'communityId': statuses['community_id'] ?? statusNotStarted,
            'govtId': statuses['govt_id'] ?? statusNotStarted,
            'reference': refStatus,
            'videoBio': statuses['video_bio'] ?? statusNotStarted,
            'profileCompletion': profile.completionPercentage >= 100
                ? statusVerified
                : statusNotStarted,
          };
          return BackendResponse.success(statusMap);
        },
        onFailure: (error) => BackendResponse.failure(error),
      );
    } catch (e, stack) {
      AppLogger.error('TrustScoreRepository', 'Error getting verification status: $e');
      return BackendResponse.failure(
        e.toString(),
        stackTrace: stack,
        onRetry: () => getVerificationStatus(),
      );
    }
  }

  Map<String, String> _emptyStatus() {
    return {
      'mobile': statusNotStarted,
      'email': statusNotStarted,
      'photo': statusNotStarted,
      'communityId': statusNotStarted,
      'govtId': statusNotStarted,
      'reference': statusNotStarted,
      'videoBio': statusNotStarted,
      'profileCompletion': statusNotStarted,
    };
  }

  String _mapDbStatusToAppStatus(String dbStatus) {
    switch (dbStatus) {
      case 'approved':
        return statusVerified;
      case 'pending':
        return statusPendingReview;
      case 'rejected':
        return statusRejected;
      default:
        return statusNotStarted;
    }
  }

  /// Submit a manual verification request
  /// Migrated to Use RPC: fn_manage_verification
  Future<BackendResponse<void>> submitVerificationRequest({
    required String type,
    required Map<String, dynamic> payload,
  }) async {
    try {
      final dbType = _mapAppTypeToDbType(type);
      final response = await _supabase.rpc(
        'fn_manage_verification',
        params: {
          'action': 'submit_request',
          'p_payload': {'type': dbType, 'payload': payload},
        },
      );
      final result = BackendResponse.fromRpc(
        response,
        onRetry: () => submitVerificationRequest(type: type, payload: payload),
      );

      // 🔔 Admin Alert: Verification Submitted
      if (result.isSuccess) {
        AdminNotificationService().notifyVerificationSubmitted(
          userId: _supabase.auth.currentUser?.id ?? '',
          verificationType: type,
        );
      }

      return result;
    } catch (e, stack) {
      return BackendResponse.failure(
        e.toString(),
        stackTrace: stack,
        onRetry: () => submitVerificationRequest(type: type, payload: payload),
      );
    }
  }

  /// Add a reference
  /// Migrated to Use RPC: fn_manage_verification
  /// [referenceType] 'internal' = app user, 'external' = non-app contact (default)
  Future<BackendResponse<void>> addReference({
    required String name,
    required String phone,
    String? referencedUserId,
    String referenceType = 'external',
  }) async {
    try {
      final response = await _supabase.rpc(
        'fn_manage_verification',
        params: {
          'action': 'add_reference',
          'p_payload': {
            'type': referenceType,
            'name': name,
            'phone': phone,
            if (referencedUserId != null) 'referenced_user_id': referencedUserId,
          },
        },
      );
      final result = BackendResponse.fromRpc(
        response,
        onRetry: () => addReference(
          name: name,
          phone: phone,
          referencedUserId: referencedUserId,
        ),
      );

      // 🔔 Admin Alert: Reference Added
      if (result.isSuccess) {
        AdminNotificationService().notifyHighValueAction(
          eventType: 'reference_added',
          title: 'New Community Reference Added',
          body: 'Reference for $name ($phone) added.',
          triggeredByUserId: _supabase.auth.currentUser?.id,
          data: {'name': name, 'phone': phone},
        );
      }

      return result;
    } catch (e, stack) {
      return BackendResponse.failure(
        e.toString(),
        stackTrace: stack,
        onRetry: () => addReference(
          name: name,
          phone: phone,
          referencedUserId: referencedUserId,
        ),
      );
    }
  }

  String _mapAppTypeToDbType(String appType) {
    switch (appType) {
      case 'photo':
        return 'selfie';
      case 'communityId':
        return 'community_id';
      case 'govtId':
        return 'govt_id';
      case 'videoBio':
        return 'video_bio';
      default:
        return appType;
    }
  }

  // Deprecated: Kept for compatibility with existing UI calls during transition
  Future<void> setItemVerified(String item, bool isVerified) async {
    // This now does nothing as we need real uploads.
    // New screens should use submitVerificationRequest.
  }

  Future<void> setItemStatus(String item, String status) async {
    // This now does nothing as we need real uploads.
  }

  /// Upload a verification document (image or video)
  /// Returns the uploaded path
  Future<BackendResponse<String>> uploadVerificationDoc({
    required dynamic file, // File (IO) or Uint8List (Web)
    required String path,
  }) async {
    try {
      // Use standard storage bucket
      final storage = _supabase.storage.from(StorageConfig.verificationDocs);

      if (kIsWeb) {
        if (file is Uint8List) {
          await storage.uploadBinary(path, file);
        } else {
          return BackendResponse.failure('On Web, file must be Uint8List');
        }
      } else {
        if (file is File) {
          await storage.upload(path, file);
        } else {
          return BackendResponse.failure(
            'On Mobile, file must be dart:io.File',
          );
        }
      }
      return BackendResponse.success(path);
    } catch (e) {
      AppLogger.error('TrustScoreRepository', 'Error uploading verification doc: $e');
      return BackendResponse.failure(e.toString());
    }
  }
}
