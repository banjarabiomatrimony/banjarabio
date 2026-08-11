import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:banjarabio/notification/core/notification_payload.dart';
import 'package:banjarabio/core/services/app_logger.dart';

/// WhatsApp Message Service for notification fallback.
///
/// Sends notification content via WhatsApp Business API as a fallback
/// when push notifications go unseen. Uses Supabase Edge Function
/// as the backend relay to avoid exposing API keys in the client.
///
/// Escalation tier: Push → **WhatsApp** → SMS
class WhatsAppNotificationService {
  static final WhatsAppNotificationService _instance =
      WhatsAppNotificationService._internal();
  factory WhatsAppNotificationService() => _instance;
  WhatsAppNotificationService._internal();

  SupabaseClient get _supabase => Supabase.instance.client;

  /// Send a WhatsApp message to the user for an unseen notification.
  ///
  /// Calls a Supabase Edge Function that handles the WhatsApp Business API
  /// integration. The Edge Function should:
  /// 1. Look up the user's phone number from their profile
  /// 2. Send a pre-approved WhatsApp template message
  /// 3. Return success/failure
  ///
  /// Returns true if the message was sent successfully.
  Future<bool> sendFallbackMessage({
    required String userId,
    required NotificationPayload payload,
  }) async {
    try {
      final response = await _supabase.functions.invoke(
        'send-whatsapp-notification',
        body: {
          'user_id': userId,
          'title': payload.title ?? '',
          'body': payload.body ?? '',
          'category': payload.category.name,
          'route': payload.route ?? '',
          'image_url': payload.imageUrl ?? '',
          'notification_id': payload.id ?? '',
        },
      );

      if (response.status == 200) {
        debugPrint(
            '📱 [WhatsApp] Fallback message sent for: ${payload.id}');
        return true;
      } else {
        debugPrint(
            '📱 [WhatsApp] Failed to send (status ${response.status}): ${response.data}');
        return false;
      }
    } catch (e) {
      AppLogger.error('WhatsappNotificationService', '📱 [WhatsApp] Error sending fallback: $e');
      return false;
    }
  }

  /// Check if WhatsApp fallback is available for a user.
  /// Requires: phone number on profile + WhatsApp opt-in.
  Future<bool> isAvailableForUser(String userId) async {
    try {
      final profile = await _supabase
          .from('profiles')
          .select('phone_number, whatsapp_opt_in')
          .eq('user_id', userId)
          .maybeSingle();

      if (profile == null) return false;

      final hasPhone = profile['phone_number'] != null &&
          (profile['phone_number'] as String).isNotEmpty;
      final optedIn = profile['whatsapp_opt_in'] as bool? ?? false;

      return hasPhone && optedIn;
    } catch (e) {
      AppLogger.error('WhatsappNotificationService', '📱 [WhatsApp] Error checking availability: $e');
      return false;
    }
  }
}
