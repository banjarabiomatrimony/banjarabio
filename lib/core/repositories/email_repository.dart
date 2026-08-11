import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:banjarabio/core/services/app_logger.dart';

class EmailRepository {
  final SupabaseClient _supabase = Supabase.instance.client;

  Future<Map<String, dynamic>> getPreferences() async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) return {};

      final response = await _supabase
          .from('email_preferences')
          .select()
          .eq('user_id', userId)
          .single();
      
      return response;
    } catch (e) {
      AppLogger.error('EmailRepository', 'Error fetching email preferences: $e');
      return {};
    }
  }

  Future<void> updatePreference(String column, bool value) async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) return;

      await _supabase
          .from('email_preferences')
          .update({column: value})
          .eq('user_id', userId);
    } catch (e) {
      AppLogger.error('EmailRepository', 'Error updating email preference ($column): $e');
    }
  }
}
