import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:banjarabio/core/models/backend_response.dart';
import 'package:banjarabio/core/services/read_replica_client.dart';

/// Repository for managing social proof "Vouches"
class VouchRepository {
  static final VouchRepository _instance = VouchRepository.internal();
  factory VouchRepository() => _instance;

  @visibleForTesting
  VouchRepository.internal();

  static SupabaseClient? testClient;
  SupabaseClient get _supabase => testClient ?? Supabase.instance.client;
  SupabaseClient get _readClient => testClient ?? ReadReplicaClient.getClient();

  /// Vouch for a profile
  /// [vouchedId] is the profile ID being vouched for
  /// [relation] is the relationship (Brother, Sister, Friend, etc.)
  Future<BackendResponse<void>> vouchForProfile({
    required String vouchedId,
    required String relation,
  }) async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) return BackendResponse.failure('Not authenticated');

      // Get sharer's profile ID
      final profileRes = await _supabase
          .from('profiles')
          .select('id')
          .eq('user_id', userId)
          .single();
      
      final vouchId = profileRes['id'];

      await _supabase.from('vouches').insert({
        'vouch_id': vouchId,
        'vouched_id': vouchedId,
        'relation': relation,
      });

      return BackendResponse.success(null);
    } catch (e) {
      if (e.toString().contains('duplicate')) {
        return BackendResponse.failure('You have already vouched for this profile');
      }
      return BackendResponse.failure(e.toString());
    }
  }

  /// Check if the current user has vouched for a profile
  Future<bool> hasVouched(String vouchedId) async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) return false;

      final profileRes = await _readClient
          .from('profiles')
          .select('id')
          .eq('user_id', userId)
          .maybeSingle();
      
      if (profileRes == null) return false;
      final vouchId = profileRes['id'];

      final response = await _readClient
          .from('vouches')
          .select('id')
          .eq('vouch_id', vouchId)
          .eq('vouched_id', vouchedId)
          .maybeSingle();

      return response != null;
    } catch (e) {
      return false;
    }
  }

  /// Get vouches for a profile with reporter names (Enrichment)
  Future<BackendResponse<List<Map<String, dynamic>>>> getVouches(String vouchedId) async {
    try {
      final response = await _readClient
          .from('vouches')
          .select('relation, created_at, profiles!vouches_vouch_id_fkey(full_name, surname, is_verified)')
          .eq('vouched_id', vouchedId)
          .order('created_at', ascending: false);

      return BackendResponse.success(List<Map<String, dynamic>>.from(response));
    } catch (e) {
      return BackendResponse.failure(e.toString());
    }
  }
}
