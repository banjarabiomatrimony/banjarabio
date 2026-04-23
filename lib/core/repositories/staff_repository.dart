import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:banjarabio/core/models/backend_response.dart';
import 'package:banjarabio/core/models/profile_model.dart';

/// [StaffRepository]
///
/// Repository for telecaller (staff) operations.
/// All data flows through [fn_staff_actions] RPC — telecallers can only
/// access profiles assigned to them.
///
/// Visibility: Telecallers see ONLY their work queue — no earnings,
/// no leaderboards, no reports. All analytics are admin-only.
class StaffRepository {
  // ---------------------------------------------------------------------------
  // 1. Singleton & Dependencies
  // ---------------------------------------------------------------------------
  static final StaffRepository _instance = StaffRepository._();
  factory StaffRepository() => _instance;
  StaffRepository._();

  SupabaseClient get _supabase => testClient ?? Supabase.instance.client;

  /// 🧪 TEST-ONLY: Inject a mock client.
  @visibleForTesting
  SupabaseClient? testClient;

  // ---------------------------------------------------------------------------
  // 2. Lead Management (Telecaller View)
  // ---------------------------------------------------------------------------

  /// Get leads assigned to the current telecaller, sorted by priority.
  /// Returns profiles with a computed [lead_score] for auto-sorting.
  Future<BackendResponse<List<ProfileModel>>> getMyLeads({
    int limit = 100,
    int offset = 0,
  }) async {
    try {
      final response = await _supabase.rpc(
        'fn_staff_actions',
        params: {
          'action': 'get_my_leads',
          'p_payload': {'limit': limit, 'offset': offset},
        },
      );

      return BackendResponse.fromRpc<List<ProfileModel>>(
        response,
        mapper: (json) {
          final rawList = json is List ? json : [];
          return rawList
              .map((e) =>
                  ProfileModel.fromJson(Map<String, dynamic>.from(e as Map)))
              .toList();
        },
      );
    } catch (e) {
      debugPrint('Error in getMyLeads: $e');
      return BackendResponse.failure(e.toString());
    }
  }

  /// Get simple summary counts for the telecaller's queue.
  /// Returns: total_assigned, not_called, follow_up, converted, calls_today.
  Future<BackendResponse<Map<String, dynamic>>> getMySummary() async {
    return _callStaffRpc('get_my_summary', {});
  }

  // ---------------------------------------------------------------------------
  // 3. Profile Editing (Full Edit Permission)
  // ---------------------------------------------------------------------------

  /// Update a lead's profile. Telecaller has full edit access to their
  /// assigned profiles only. The RPC enforces assignment check.
  Future<BackendResponse<void>> updateLeadProfile(
    String userId,
    Map<String, dynamic> profileData,
  ) async {
    final payload = Map<String, dynamic>.from(profileData);
    payload['target_user_id'] = userId;
    // Strip fields telecaller should never touch
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
    payload.remove('role');
    payload.remove('assigned_to');
    payload.remove('special_discount');
    return _callStaffRpcVoid('update_lead_profile', payload);
  }

  // ---------------------------------------------------------------------------
  // 4. Call Logging
  // ---------------------------------------------------------------------------

  /// Log a call or WhatsApp action.
  /// [actionType]: 'call', 'whatsapp', 'profile_edit'
  /// [outcome]: 'connected', 'busy', 'not_answered', 'not_interested',
  ///            'follow_up', 'converted'
  Future<BackendResponse<void>> logCall({
    required String profileId,
    required String actionType,
    String? outcome,
    String? notes,
  }) async {
    return _callStaffRpcVoid('log_call', {
      'profile_id': profileId,
      'action_type': actionType,
      'outcome': outcome,
      'notes': notes,
    });
  }

  // ---------------------------------------------------------------------------
  // 5. WhatsApp Templates (Phase 2)
  // ---------------------------------------------------------------------------

  /// Get all active WhatsApp message templates.
  Future<BackendResponse<List<Map<String, dynamic>>>> getWhatsAppTemplates() async {
    try {
      final response = await _supabase.rpc(
        'fn_staff_actions',
        params: {'action': 'get_whatsapp_templates', 'p_payload': {}},
      );
      return BackendResponse.fromRpc<List<Map<String, dynamic>>>(
        response,
        mapper: (json) {
          final raw = json is List ? json : [];
          return raw.map((e) => Map<String, dynamic>.from(e as Map)).toList();
        },
      );
    } catch (e) {
      debugPrint('Error in getWhatsAppTemplates: $e');
      return BackendResponse.failure(e.toString());
    }
  }

  /// Get profile data for template variable substitution.
  Future<BackendResponse<Map<String, dynamic>>> getLeadForTemplate(
    String profileId,
  ) async {
    return _callStaffRpc('get_lead_for_template', {'profile_id': profileId});
  }

  // ---------------------------------------------------------------------------
  // 6. Private Helpers
  // ---------------------------------------------------------------------------

  Future<BackendResponse<Map<String, dynamic>>> _callStaffRpc(
    String action,
    Map<String, dynamic> payload,
  ) async {
    try {
      final response = await _supabase.rpc(
        'fn_staff_actions',
        params: {'action': action, 'p_payload': payload},
      );
      debugPrint('🧪 StaffRepository._callStaffRpc: action=$action, response type=${response.runtimeType}');
      return BackendResponse.fromRpc<Map<String, dynamic>>(
        response,
        mapper: (json) => Map<String, dynamic>.from(json as Map),
      );
    } catch (e) {
      debugPrint('Staff Action Failed [$action]: $e');
      return BackendResponse.failure('Staff action failed: $e');
    }
  }

  Future<BackendResponse<void>> _callStaffRpcVoid(
    String action,
    Map<String, dynamic> payload,
  ) async {
    try {
      final response = await _supabase.rpc(
        'fn_staff_actions',
        params: {'action': action, 'p_payload': payload},
      );
      return BackendResponse.fromRpc(response);
    } catch (e) {
      debugPrint('Staff Action Failed [$action]: $e');
      return BackendResponse.failure('Staff action failed: $e');
    }
  }
}

