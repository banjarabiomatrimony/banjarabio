import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:banjarabio/notification/core/notification_payload.dart';

/// SMS Fallback Service for notification delivery.
///
/// Last-resort channel when both push and WhatsApp fail to reach the user.
/// Sends a concise SMS via Supabase Edge Function that integrates with
/// an SMS gateway (e.g., Twilio, MSG91, or Textlocal for India).
///
/// Escalation tier: Push → WhatsApp → **SMS**
class SmsNotificationService {
  static final SmsNotificationService _instance =
      SmsNotificationService._internal();
  factory SmsNotificationService() => _instance;
  SmsNotificationService._internal();

  SupabaseClient get _supabase => Supabase.instance.client;

  /// Send an SMS notification to the user.
  ///
  /// Messages are kept ultra-short (< 160 chars) to fit in a single SMS.
  /// The Edge Function handles phone number lookup and SMS gateway integration.
  ///
  /// Returns true if the SMS was sent successfully.
  Future<bool> sendFallbackSms({
    required String userId,
    required NotificationPayload payload,
  }) async {
    try {
      // Craft a concise SMS-friendly message
      final smsBody = _buildSmsBody(payload);

      final response = await _supabase.functions.invoke(
        'send-sms-notification',
        body: {
          'user_id': userId,
          'message': smsBody,
          'category': payload.category.name,
          'notification_id': payload.id ?? '',
        },
      );

      if (response.status == 200) {
        debugPrint('📨 [SMS] Fallback SMS sent for: ${payload.id}');
        return true;
      } else {
        debugPrint(
            '📨 [SMS] Failed to send (status ${response.status}): ${response.data}');
        return false;
      }
    } catch (e) {
      debugPrint('📨 [SMS] Error sending fallback: $e');
      return false;
    }
  }

  /// Build a concise SMS body (< 160 chars).
  String _buildSmsBody(NotificationPayload payload) {
    final title = payload.title ?? 'BanjaraBio';
    final body = payload.body ?? '';

    // Truncate to fit SMS limit with app name suffix
    const suffix = ' - BanjaraBio';
    final maxBodyLen = 160 - title.length - suffix.length - 3; // 3 for ": "

    if (body.length <= maxBodyLen) {
      return '$title: $body$suffix';
    }

    return '$title: ${body.substring(0, maxBodyLen)}...$suffix';
  }

  /// Check if SMS fallback is available for a user.
  /// Requires: verified phone number on profile.
  Future<bool> isAvailableForUser(String userId) async {
    try {
      final profile = await _supabase
          .from('profiles')
          .select('phone_number, phone_verified')
          .eq('user_id', userId)
          .maybeSingle();

      if (profile == null) return false;

      final hasPhone = profile['phone_number'] != null &&
          (profile['phone_number'] as String).isNotEmpty;
      final isVerified = profile['phone_verified'] as bool? ?? false;

      // Only send SMS to verified numbers to avoid spam
      return hasPhone && isVerified;
    } catch (e) {
      debugPrint('📨 [SMS] Error checking availability: $e');
      return false;
    }
  }
}
