import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:banjarabio/core/models/backend_response.dart';
import 'package:banjarabio/core/models/profile_model.dart';
import 'package:banjarabio/core/repositories/isolate_first_repository.dart';
import 'package:banjarabio/core/services/app_logger.dart';

/// [AdminRepository]
///
/// A secure repository for high-privilege operations.
///
/// 🏆 10/10 Architecture Highlights:
/// 1. **Role-Based Security**: All writes are routed through `fn_admin_actions` RPC to ensure
///    the caller actually has the 'admin' role on the server. Direct DB updates are forbidden.
/// 2. **Isolate Parsing**: Large lists (like "All Profiles") are parsed in a background thread.
/// 3. **Fail-Safe URLs**: Automatically falls back to public URLs if signed URL generation fails.
class AdminRepository extends IsolateFirstRepository {
  // ---------------------------------------------------------------------------
  // 1. Singleton & Dependencies
  // ---------------------------------------------------------------------------
  static final AdminRepository _instance = AdminRepository._();
  factory AdminRepository() => _instance;
  AdminRepository._();

  SupabaseClient get _supabase => testClient ?? Supabase.instance.client;

  /// 🧪 TEST-ONLY: Inject a mock client to avoid touching real Supabase records.
  @visibleForTesting
  SupabaseClient? testClient;

  // ---------------------------------------------------------------------------
  // 2. Verification Management
  // ---------------------------------------------------------------------------

  /// Fetches all pending verification requests via fn_admin_actions.
  /// Uses RPC to bypass RLS (admin-only).
  Future<BackendResponse<List<Map<String, dynamic>>>>
  getPendingVerifications() async {
    return _callAdminRpcForList('get_pending_verifications', {});
  }

  /// Fetches admin dashboard statistics.
  Future<BackendResponse<Map<String, dynamic>>> getAdminStats() async {
    try {
      final response = await _supabase.rpc(
        'fn_admin_actions',
        params: {'action': 'get_admin_stats', 'p_payload': {}},
      );
      return BackendResponse.fromRpc<Map<String, dynamic>>(
        response,
        mapper: (json) {
          if (json is List && json.isNotEmpty) {
            return Map<String, dynamic>.from(json.first as Map);
          }
          return Map<String, dynamic>.from(json as Map);
        },
      );
    } catch (e) {
      AppLogger.error('AdminRepository', 'Error in getAdminStats: $e');
      return BackendResponse.failure(e.toString());
    }
  }

  /// Fetches a detailed list of all payments.
  Future<BackendResponse<List<Map<String, dynamic>>>> getPaymentsList({
    int limit = 100,
    int offset = 0,
  }) async {
    return _callAdminRpcForList('get_payments_list', {
      'limit': limit,
      'offset': offset,
    });
  }

  /// Approves or Rejects a verification request securely.
  Future<BackendResponse<void>> updateVerificationStatus({
    required String requestId,
    required String status, // 'approved' or 'rejected'
    String? adminNotes,
    String? rejectionReason,
  }) async {
    return _callAdminRpc('update_verification_status', {
      'request_id': requestId,
      'status': status,
      'notes': adminNotes,
      'rejection_reason': rejectionReason,
    });
  }

  /// Approves or Rejects a community reference.
  Future<BackendResponse<void>> updateReferenceStatus({
    required String referenceId,
    required String status, // 'verified' or 'rejected'
  }) async {
    return _callAdminRpc('update_reference_status', {
      'reference_id': referenceId,
      'status': status,
    });
  }

  // ---------------------------------------------------------------------------
  // 3. User Management
  // ---------------------------------------------------------------------------

  /// Fetches profiles with advanced search and pagination via fn_admin_actions.
  /// Uses RPC to bypass RLS (admin sees all profiles including inactive).
  Future<BackendResponse<List<ProfileModel>>> getAllProfiles({
    int limit = 100,
    int offset = 0,
    String? searchQuery,
    String? gender,
    bool? isPremium,
    bool? isActive,
    bool? onlyTesters,
  }) async {
    try {
      final response = await _supabase.rpc(
        'fn_admin_actions',
        params: {
          'action': 'get_all_profiles',
          'p_payload': {
            'limit': limit,
            'offset': offset,
            'search_query': (searchQuery == null || searchQuery.trim().isEmpty)
                ? null
                : searchQuery.trim(),
            'gender': gender,
            'is_premium': isPremium,
            'is_active': isActive,
            'only_testers': onlyTesters,
          },
        },
      );

      return BackendResponse.fromRpc<List<ProfileModel>>(
        response,
        mapper: (json) {
          final rawList = json is List ? json : [];
          return rawList
              .map((e) => ProfileModel.fromJson(Map<String, dynamic>.from(e as Map)))
              .toList();
        },
      );
    } catch (e) {
      return BackendResponse.failure(e.toString());
    }
  }

  /// Toggles Premium/Subscription status for a user.
  /// ⚠️ CRITICAL SECURITY: This must be an RPC. Never let a client update 'is_premium' directly.
  Future<BackendResponse<void>> togglePremiumStatus(
    String userId,
    bool isPremium,
  ) async {
    return _callAdminRpc('toggle_premium', {
      'target_user_id': userId,
      'is_premium': isPremium,
    });
  }

  /// Grants a special manual discount to a user with an optional expiry date.
  Future<BackendResponse<void>> grantSpecialDiscount({
    required String userId,
    required int percentage,
    required DateTime expiresAt,
  }) async {
    return _callAdminRpc('grant_special_discount', {
      'target_user_id': userId,
      'percentage': percentage,
      'expires_at': expiresAt.toIso8601String(),
    });
  }

  /// Manually overrides profile verification flags (e.g., if SMS fails but admin verifies manually).
  Future<BackendResponse<void>> verifyProfileManually(
    String userId, {
    bool email = false,
    bool phone = false,
  }) async {
    return _callAdminRpc('manual_verification', {
      'target_user_id': userId,
      'verify_email': email,
      'verify_phone': phone,
    });
  }

  /// Updates any user's profile data via admin RPC (bypasses RLS).
  /// Used when admin edits a user's biodata from the admin dashboard.
  Future<BackendResponse<void>> adminUpdateProfile(
    String userId,
    Map<String, dynamic> profileData,
  ) async {
    final payload = Map<String, dynamic>.from(profileData);
    payload['target_user_id'] = userId;
    // Remove fields that shouldn't be updated via this action
    payload.remove('user_id');
    payload.remove('id');
    payload.remove('created_at');
    payload.remove('is_premium');
    payload.remove('is_admin');
    payload.remove('trust_score');
    payload.remove('is_verified');
    payload.remove('is_pdf_unlocked');
    payload.remove('email_verified');
    payload.remove('phone_verified');
    return _callAdminRpc('admin_update_profile', payload);
  }

  // ---------------------------------------------------------------------------
  // 4. Content & References
  // ---------------------------------------------------------------------------

  /// Fetches pending reference checks via fn_admin_actions.
  /// Uses RPC to bypass RLS (admin-only).
  Future<BackendResponse<List<Map<String, dynamic>>>>
  getPendingReferences() async {
    return _callAdminRpcForList('get_pending_references', {});
  }

  /// Generates a temporary access URL for private admin-only files (e.g., ID proofs).
  Future<BackendResponse<String>> getSignedUrl(
    String bucket,
    String path,
  ) async {
    try {
      // Try to get a secure, time-limited URL (1 hour)
      final signedUrl = await _supabase.storage
          .from(bucket)
          .createSignedUrl(path, 3600);
      return BackendResponse.success(signedUrl);
    } catch (e) {
      AppLogger.error('AdminRepository', 'Error getting signed URL for $path: $e');

      // If object not found, return explicit failure rather than falling back
      // to a public URL that will also 404.
      if (e.toString().contains('Object not found')) {
        return BackendResponse.failure('Document not found in storage');
      }

      // Fallback for public buckets
      try {
        final publicUrl = _supabase.storage.from(bucket).getPublicUrl(path);
        return BackendResponse.success(publicUrl);
      } catch (e2) {
        return BackendResponse.failure('Could not generate URL: $e2');
      }
    }
  }

  // ---------------------------------------------------------------------------
  // 5. Private Helpers
  // ---------------------------------------------------------------------------

  /// Centralized handler for Admin RPC calls (void return).
  Future<BackendResponse<void>> _callAdminRpc(
    String action,
    Map<String, dynamic> payload,
  ) async {
    try {
      final response = await _supabase.rpc(
        'fn_admin_actions',
        params: {'action': action, 'p_payload': payload},
      );
      return BackendResponse.fromRpc(response);
    } catch (e) {
      AppLogger.error('AdminRepository', 'Admin Action Failed [$action]: $e');
      return BackendResponse.failure('Admin action failed: $e');
    }
  }

  /// Admin RPC that returns a list of maps (e.g. get_pending_verifications).
  Future<BackendResponse<List<Map<String, dynamic>>>> _callAdminRpcForList(
    String action,
    Map<String, dynamic> payload,
  ) async {
    try {
      final response = await _supabase.rpc(
        'fn_admin_actions',
        params: {'action': action, 'p_payload': payload},
      );
      return BackendResponse.fromRpc<List<Map<String, dynamic>>>(
        response,
        mapper: (json) {
          final raw = json is List ? json : [];
          return raw.map((e) => Map<String, dynamic>.from(e as Map)).toList();
        },
      );
    } catch (e) {
      AppLogger.error('AdminRepository', 'Admin Action Failed [$action]: $e');
      return BackendResponse.failure('Admin action failed: $e');
    }
  }

  // ---------------------------------------------------------------------------
  // 6. Coupon Management
  // ---------------------------------------------------------------------------

  Future<BackendResponse<List<Map<String, dynamic>>>> getCoupons() async {
    return _callAdminRpcForList('get_coupons', {});
  }

  Future<BackendResponse<void>> addCoupon({
    required String code,
    required String offerName,
    required String description,
    required DateTime validUntil,
    required int discountPercentage,
    String? bannerUrl,
    Map<String, dynamic>? targetFilters,
  }) async {
    return _callAdminRpc('add_coupon', {
      'code': code,
      'offer_name': offerName,
      'description': description,
      'valid_until': validUntil.toIso8601String(),
      'discount_percentage': discountPercentage,
      'banner_url': bannerUrl,
      'target_filters': targetFilters,
    });
  }

  Future<BackendResponse<void>> updateCoupon(
    String id, {
    String? offerName,
    String? description,
    DateTime? validUntil,
    int? discountPercentage,
    bool? isActive,
    String? bannerUrl,
    Map<String, dynamic>? targetFilters,
  }) async {
    return _callAdminRpc('update_coupon', {
      'id': id,
      if (offerName != null) 'offer_name': offerName,
      if (description != null) 'description': description,
      if (validUntil != null) 'valid_until': validUntil.toIso8601String(),
      if (discountPercentage != null) 'discount_percentage': discountPercentage,
      if (isActive != null) 'is_active': isActive,
      if (bannerUrl != null) 'banner_url': bannerUrl,
      if (targetFilters != null) 'target_filters': targetFilters,
    });
  }

  // ---------------------------------------------------------------------------
  // 7. Banner Management
  // ---------------------------------------------------------------------------

  Future<BackendResponse<List<Map<String, dynamic>>>> getBanners() async {
    return _callAdminRpcForList('get_banners', {});
  }

  Future<BackendResponse<void>> addBanner({
    required String title,
    required String imageUrl,
    String? actionUrl,
    String? targetGender,
    String? targetPlan,
    int priority = 0,
    DateTime? expiresAt,
  }) async {
    return _callAdminRpc('add_banner', {
      'title': title,
      'image_url': imageUrl,
      'action_url': actionUrl,
      'target_gender': targetGender,
      'target_plan': targetPlan,
      'priority': priority,
      'expires_at': expiresAt?.toIso8601String(),
    });
  }

  Future<BackendResponse<void>> updateBanner(
    String id, {
    String? title,
    String? imageUrl,
    String? actionUrl,
    String? targetGender,
    String? targetPlan,
    int? priority,
    bool? isActive,
    DateTime? expiresAt,
  }) async {
    return _callAdminRpc('update_banner', {
      'id': id,
      if (title != null) 'title': title,
      if (imageUrl != null) 'image_url': imageUrl,
      if (actionUrl != null) 'action_url': actionUrl,
      if (targetGender != null) 'target_gender': targetGender,
      if (targetPlan != null) 'target_plan': targetPlan,
      if (priority != null) 'priority': priority,
      if (isActive != null) 'is_active': isActive,
      if (expiresAt != null) 'expires_at': expiresAt.toIso8601String(),
    });
  }

  // ---------------------------------------------------------------------------
  // 8. Team Management (Admin-Only)
  // ---------------------------------------------------------------------------

  /// List all staff members (Team tab).
  Future<BackendResponse<List<Map<String, dynamic>>>> getTeam() async {
    return _callTeamAdminRpcForList('get_team', {});
  }

  /// Promote/demote a user to a staff role.
  /// [role]: 'user', 'staff', 'admin'
  Future<BackendResponse<void>> setUserRole(String userId, String role) async {
    return _callTeamAdminRpc('set_role', {
      'target_user_id': userId,
      'role': role,
    });
  }

  /// Bulk-assign profiles to a staff member.
  Future<BackendResponse<void>> assignLeads(
    String staffUserId,
    List<String> profileUserIds,
  ) async {
    return _callTeamAdminRpc('assign_leads', {
      'staff_user_id': staffUserId,
      'profile_user_ids': profileUserIds,
    });
  }

  /// Auto-assign all unassigned profiles to staff (round-robin).
  Future<BackendResponse<Map<String, dynamic>>> autoAssignLeads() async {
    try {
      final response = await _supabase.rpc(
        'fn_admin_team',
        params: {'action': 'auto_assign_leads', 'p_payload': {}},
      );
      return BackendResponse.fromRpc<Map<String, dynamic>>(
        response,
        mapper: (json) => Map<String, dynamic>.from(json as Map),
      );
    } catch (e) {
      AppLogger.error('AdminRepository', 'Auto-assign failed: $e');
      return BackendResponse.failure('Auto-assign failed: $e');
    }
  }

  /// Get performance report for a specific staff member (admin-only).
  Future<BackendResponse<Map<String, dynamic>>> getStaffReport(
    String staffUserId,
  ) async {
    try {
      final response = await _supabase.rpc(
        'fn_admin_team',
        params: {
          'action': 'get_staff_report',
          'p_payload': {'staff_user_id': staffUserId},
        },
      );
      return BackendResponse.fromRpc<Map<String, dynamic>>(
        response,
        mapper: (json) => Map<String, dynamic>.from(json as Map),
      );
    } catch (e) {
      AppLogger.error('AdminRepository', 'Staff report failed: $e');
      return BackendResponse.failure('Report failed: $e');
    }
  }

  /// Get all call logs across all telecallers (admin overview).
  Future<BackendResponse<List<Map<String, dynamic>>>> getAllCallLogs({
    int limit = 50,
    int offset = 0,
  }) async {
    return _callTeamAdminRpcForList('get_all_call_logs', {
      'limit': limit,
      'offset': offset,
    });
  }

  /// Reassign a single lead to a different telecaller.
  Future<BackendResponse<void>> reassignLead(
    String targetUserId,
    String newTelecallerId,
  ) async {
    return _callTeamAdminRpc('reassign_lead', {
      'target_user_id': targetUserId,
      'new_telecaller_id': newTelecallerId,
    });
  }

  /// Unassign all leads from a telecaller (e.g., when deactivating).
  Future<BackendResponse<void>> unassignAllLeads(
    String telecallerUserId,
  ) async {
    return _callTeamAdminRpc('unassign_all_leads', {
      'telecaller_user_id': telecallerUserId,
    });
  }

  // ---------------------------------------------------------------------------
  // 9. Hire Staff (Admin creates telecaller accounts)
  // ---------------------------------------------------------------------------

  /// Create a new telecaller account via the `hire-staff` Edge Function.
  /// This uses `admin.createUser` server-side so the admin stays logged in.
  Future<BackendResponse<Map<String, dynamic>>> hireStaff({
    required String email,
    required String password,
    required String fullName,
    required String department,
    required String designation,
  }) async {
    try {
      final response = await _supabase.functions.invoke(
        'hire-staff',
        body: {
          'email': email,
          'password': password,
          'full_name': fullName,
          'department': department,
          'designation': designation,
        },
      );
      final data = response.data as Map<String, dynamic>?;
      if (data != null && data['ok'] == true) {
        return BackendResponse.fromRpc<Map<String, dynamic>>(
          data,
          mapper: (json) => Map<String, dynamic>.from(json as Map),
        );
      } else {
        return BackendResponse.failure(data?['error']?.toString() ?? 'Hire failed');
      }
    } catch (e) {
      AppLogger.error('AdminRepository', 'Hire staff failed: $e');
      return BackendResponse.failure('Hire failed: $e');
    }
  }

  // ---------------------------------------------------------------------------
  // 10. Lead Scoring & Templates (Phase 2 — Admin)
  // ---------------------------------------------------------------------------

  /// Refresh lead scores across all assigned profiles.
  Future<BackendResponse<void>> refreshLeadScores() async {
    return _callTeamAdminRpc('refresh_lead_scores', {});
  }

  /// Add or update a WhatsApp template.
  Future<BackendResponse<void>> manageTemplate(Map<String, dynamic> templateData) async {
    return _callTeamAdminRpc('manage_templates', templateData);
  }

  // ---------------------------------------------------------------------------
  // 10. Incentive Calculator (Phase 3 — Admin-Only)
  // ---------------------------------------------------------------------------

  /// Calculate incentives for a telecaller in a given period.
  /// Returns breakdown: welcome calls, profiles, conversions, bonuses, total payout.
  Future<BackendResponse<Map<String, dynamic>>> calculateIncentives(
    String telecallerUserId, {
    DateTime? periodStart,
    DateTime? periodEnd,
  }) async {
    try {
      final payload = <String, dynamic>{
        'staff_user_id': telecallerUserId,
      };
      if (periodStart != null) payload['period_start'] = periodStart.toIso8601String();
      if (periodEnd != null) payload['period_end'] = periodEnd.toIso8601String();
      final response = await _supabase.rpc(
        'fn_admin_team',
        params: {'action': 'calculate_incentives', 'p_payload': payload},
      );
      return BackendResponse.fromRpc<Map<String, dynamic>>(
        response,
        mapper: (json) => Map<String, dynamic>.from(json as Map),
      );
    } catch (e) {
      AppLogger.error('AdminRepository', 'Incentive calc failed: $e');
      return BackendResponse.failure('Incentive calculation failed: $e');
    }
  }

  /// Get leaderboard: telecallers ranked by conversions.
  Future<BackendResponse<List<Map<String, dynamic>>>> getLeaderboard() async {
    return _callTeamAdminRpcForList('get_leaderboard', {});
  }

  /// Get ROI dashboard: total conversions, estimated revenue, cost, ROI %.
  Future<BackendResponse<Map<String, dynamic>>> getRoiDashboard() async {
    try {
      final response = await _supabase.rpc(
        'fn_admin_team',
        params: {'action': 'get_roi_dashboard', 'p_payload': {}},
      );
      return BackendResponse.fromRpc<Map<String, dynamic>>(
        response,
        mapper: (json) => Map<String, dynamic>.from(json as Map),
      );
    } catch (e) {
      AppLogger.error('AdminRepository', 'ROI dashboard failed: $e');
      return BackendResponse.failure('ROI dashboard failed: $e');
    }
  }

  // ---------------------------------------------------------------------------
  // 11. Team Admin RPC Helpers
  // ---------------------------------------------------------------------------

  Future<BackendResponse<void>> _callTeamAdminRpc(
    String action,
    Map<String, dynamic> payload,
  ) async {
    try {
      final response = await _supabase.rpc(
        'fn_admin_team',
        params: {'action': action, 'p_payload': payload},
      );
      return BackendResponse.fromRpc(response);
    } catch (e) {
      AppLogger.error('AdminRepository', 'Team Admin Action Failed [$action]: $e');
      return BackendResponse.failure('Team admin action failed: $e');
    }
  }

  Future<BackendResponse<List<Map<String, dynamic>>>>
  _callTeamAdminRpcForList(
    String action,
    Map<String, dynamic> payload,
  ) async {
    try {
      final response = await _supabase.rpc(
        'fn_admin_team',
        params: {'action': action, 'p_payload': payload},
      );
      return BackendResponse.fromRpc<List<Map<String, dynamic>>>(
        response,
        mapper: (json) {
          final raw = json is List ? json : [];
          return raw.map((e) => Map<String, dynamic>.from(e as Map)).toList();
        },
      );
    } catch (e) {
      AppLogger.error('AdminRepository', 'Team Admin Action Failed [$action]: $e');
      return BackendResponse.failure('Team admin action failed: $e');
    }
  }

  // ---------------------------------------------------------------------------
  // 12. Advanced Lead Management
  // ---------------------------------------------------------------------------

  /// Get counts of unassigned profiles grouped by stage (inventory).
  Future<BackendResponse<Map<String, dynamic>>> getLeadInventory() async {
    try {
      final response = await _supabase.rpc(
        'fn_admin_team',
        params: {'action': 'get_lead_inventory', 'p_payload': {}},
      );
      return BackendResponse.fromRpc<Map<String, dynamic>>(
        response,
        mapper: (json) => Map<String, dynamic>.from(json as Map),
      );
    } catch (e) {
      AppLogger.error('AdminRepository', 'Lead inventory failed: $e');
      return BackendResponse.failure('Inventory fetch failed: $e');
    }
  }

  /// Bulk-assign leads with granular filters (Manual Assignment).
  Future<BackendResponse<Map<String, dynamic>>> manualAssignLeads({
    required String staffUserId,
    required String stage,
    String? gender,
    int limit = 10,
  }) async {
    try {
      final response = await _supabase.rpc(
        'fn_admin_team',
        params: {
          'action': 'manual_assign',
          'p_payload': {
            'staff_user_id': staffUserId,
            'stage': stage,
            'gender': gender,
            'limit': limit,
          },
        },
      );
      return BackendResponse.fromRpc<Map<String, dynamic>>(
        response,
        mapper: (json) => Map<String, dynamic>.from(json as Map),
      );
    } catch (e) {
      AppLogger.error('AdminRepository', 'Manual assignment failed: $e');
      return BackendResponse.failure('Manual assignment failed: $e');
    }
  }
}
