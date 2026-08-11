import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:banjarabio/core/models/backend_response.dart';
import 'package:banjarabio/core/models/profile_model.dart';
import 'package:banjarabio/core/services/app_logger.dart';

/// [VolunteerRepository]
///
/// Repository for volunteer field-agent operations.
/// All data flows through [fn_volunteer_actions] RPC — volunteers can
/// search any profile, register new users, and correct existing profiles.
///
/// Security: The PostgreSQL function enforces that only users with
/// role='volunteer' or role='admin' can invoke these actions.
class VolunteerRepository {
  // ---------------------------------------------------------------------------
  // 1. Singleton & Dependencies
  // ---------------------------------------------------------------------------
  static final VolunteerRepository _instance = VolunteerRepository._();
  factory VolunteerRepository() => _instance;
  VolunteerRepository._();

  SupabaseClient get _supabase => testClient ?? Supabase.instance.client;

  /// 🧪 TEST-ONLY: Inject a mock client.
  @visibleForTesting
  SupabaseClient? testClient;

  // ---------------------------------------------------------------------------
  // 2. Search Profiles
  // ---------------------------------------------------------------------------

  /// Search all profiles by name, phone, or BB-ID.
  Future<BackendResponse<List<ProfileModel>>> searchProfiles(
    String query, {
    int limit = 50,
    int offset = 0,
  }) async {
    try {
      final response = await _supabase.rpc(
        'fn_volunteer_actions',
        params: {
          'action': 'search_profiles',
          'p_payload': {
            'search_query': query,
            'limit': limit,
            'offset': offset,
          },
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
      AppLogger.error('VolunteerRepository', 'Error in searchProfiles: $e');
      return BackendResponse.failure(e.toString());
    }
  }

  // ---------------------------------------------------------------------------
  // 3. Get Profile Detail (for correction screen)
  // ---------------------------------------------------------------------------

  /// Fetch full profile data for the correction editor.
  Future<BackendResponse<ProfileModel>> getProfileDetail(
    String profileId,
  ) async {
    try {
      final response = await _supabase.rpc(
        'fn_volunteer_actions',
        params: {
          'action': 'get_profile_detail',
          'p_payload': {'profile_id': profileId},
        },
      );

      return BackendResponse.fromRpc<ProfileModel>(
        response,
        mapper: (json) =>
            ProfileModel.fromJson(Map<String, dynamic>.from(json as Map)),
      );
    } catch (e) {
      AppLogger.error('VolunteerRepository', 'Error in getProfileDetail: $e');
      return BackendResponse.failure(e.toString());
    }
  }

  // ---------------------------------------------------------------------------
  // 4. Register New Profile
  // ---------------------------------------------------------------------------

  /// Register a brand-new profile on behalf of a user in the field.
  /// The profile is created with `profile_created_by = 'Volunteer'`.
  Future<BackendResponse<Map<String, dynamic>>> registerProfile(
    Map<String, dynamic> profileData,
  ) async {
    return _callRpc('register_user', profileData);
  }

  // ---------------------------------------------------------------------------
  // 5. Update / Correct Existing Profile
  // ---------------------------------------------------------------------------

  /// Update fields on an existing profile. The volunteer can correct
  /// any profile data (name, age, phone, location, family, etc.).
  Future<BackendResponse<void>> correctProfile(
    String targetProfileId,
    Map<String, dynamic> corrections,
  ) async {
    final payload = Map<String, dynamic>.from(corrections);
    payload['target_profile_id'] = targetProfileId;

    // Strip fields a volunteer should never touch
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

    return _callRpcVoid('update_user_profile', payload);
  }

  // ---------------------------------------------------------------------------
  // 6. Volunteer Stats & Logs
  // ---------------------------------------------------------------------------

  /// Get the volunteer's own daily stats (registered_today, corrected_today, total).
  Future<BackendResponse<Map<String, dynamic>>> getMyStats() async {
    return _callRpc('get_my_stats', {});
  }

  /// Log a telecalling follow-up call.
  Future<BackendResponse<void>> logCall({
    required String profileId,
    required String outcome,
    required String notes,
  }) async {
    return _callRpcVoid('log_call', {
      'profile_id': profileId,
      'outcome': outcome,
      'notes': notes,
    });
  }

  /// Get recent call logs for the current volunteer.
  Future<BackendResponse<List<Map<String, dynamic>>>> getMyCallLogs() async {
    try {
      final response = await _supabase.rpc(
        'fn_volunteer_actions',
        params: {
          'action': 'get_my_call_logs',
          'p_payload': {},
        },
      );

      return BackendResponse.fromRpc<List<Map<String, dynamic>>>(
        response,
        mapper: (json) {
          final rawList = json is List ? json : [];
          return rawList.map((e) => Map<String, dynamic>.from(e as Map)).toList();
        },
      );
    } catch (e) {
      AppLogger.error('VolunteerRepository', 'Error in getMyCallLogs: $e');
      return BackendResponse.failure(e.toString());
    }
  }

  /// Get recent offline registrations by the current volunteer.
  Future<BackendResponse<List<Map<String, dynamic>>>> getMyRegistrations() async {
    try {
      final response = await _supabase.rpc(
        'fn_volunteer_actions',
        params: {
          'action': 'get_my_registrations',
          'p_payload': {},
        },
      );

      return BackendResponse.fromRpc<List<Map<String, dynamic>>>(
        response,
        mapper: (json) {
          final rawList = json is List ? json : [];
          return rawList.map((e) => Map<String, dynamic>.from(e as Map)).toList();
        },
      );
    } catch (e) {
      AppLogger.error('VolunteerRepository', 'Error in getMyRegistrations: $e');
      return BackendResponse.failure(e.toString());
    }
  }

  // ---------------------------------------------------------------------------
  // 7. Private Helpers
  // ---------------------------------------------------------------------------

  Future<BackendResponse<Map<String, dynamic>>> _callRpc(
    String action,
    Map<String, dynamic> payload,
  ) async {
    try {
      final response = await _supabase.rpc(
        'fn_volunteer_actions',
        params: {'action': action, 'p_payload': payload},
      );
      return BackendResponse.fromRpc<Map<String, dynamic>>(
        response,
        mapper: (json) => Map<String, dynamic>.from(json as Map),
      );
    } catch (e) {
      AppLogger.error('VolunteerRepository', 'Volunteer Action Failed [$action]: $e');
      return BackendResponse.failure('Volunteer action failed: $e');
    }
  }

  Future<BackendResponse<void>> _callRpcVoid(
    String action,
    Map<String, dynamic> payload,
  ) async {
    try {
      final response = await _supabase.rpc(
        'fn_volunteer_actions',
        params: {'action': action, 'p_payload': payload},
      );
      return BackendResponse.fromRpc(response);
    } catch (e) {
      AppLogger.error('VolunteerRepository', 'Volunteer Action Failed [$action]: $e');
      return BackendResponse.failure('Volunteer action failed: $e');
    }
  }
}
