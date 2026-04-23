import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:banjarabio/notification/core/notification_payload.dart';
import 'package:banjarabio/notification/features/delivery_tracker.dart';
import 'package:banjarabio/notification/features/whatsapp_notification_service.dart';
import 'package:banjarabio/notification/features/sms_notification_service.dart';

/// Omni-channel Notification Orchestrator.
///
/// Manages the tiered delivery strategy:
///
/// ```
/// Push Notification (Tier 1)
///     ↓ unseen after 5-15 min
/// WhatsApp Message (Tier 2)
///     ↓ failed or unavailable
/// SMS (Tier 3 — last resort)
/// ```
///
/// Only escalates for high-value notifications (interests, matches, chat).
/// System/nudge notifications don't escalate beyond push.
class OmniChannelOrchestrator {
  static final OmniChannelOrchestrator _instance =
      OmniChannelOrchestrator._internal();
  factory OmniChannelOrchestrator() => _instance;
  OmniChannelOrchestrator._internal();

  final DeliveryTracker _tracker = DeliveryTracker();
  final WhatsAppNotificationService _whatsapp = WhatsAppNotificationService();
  final SmsNotificationService _sms = SmsNotificationService();

  SupabaseClient get _supabase => Supabase.instance.client;

  bool _initialized = false;

  /// Categories eligible for omni-channel escalation.
  static const _escalatableCategories = {
    NotificationCategory.interestReceived,
    NotificationCategory.matchFound,
    NotificationCategory.chatMessage,
  };

  /// Initialize the orchestrator — wires escalation callback.
  void initialize() {
    if (_initialized) return;
    _initialized = true;

    _tracker.onEscalationNeeded = _handleEscalation;
    debugPrint('🌐 [Omni] Orchestrator initialized');
  }

  /// Register a push notification for tracking.
  /// Only tracks escalatable categories.
  void trackPushDelivery(NotificationPayload payload) {
    if (!_escalatableCategories.contains(payload.category)) {
      return; // No escalation for nudges, system, etc.
    }

    _tracker.trackDelivery(payload);
  }

  /// Called when user interacts with a notification — cancel escalation.
  void onNotificationSeen(String notificationId) {
    _tracker.markAsSeen(notificationId);
  }

  /// Called when user opens the app — cancel all escalations.
  void onAppOpened() {
    _tracker.markAllAsSeen();
  }

  /// Escalation handler: Push wasn't seen → try WhatsApp → try SMS.
  Future<void> _handleEscalation(NotificationPayload payload) async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) {
      debugPrint('🌐 [Omni] No user ID — cannot escalate');
      return;
    }

    debugPrint(
        '🌐 [Omni] Escalating ${payload.category.name}: "${payload.title}"');

    // Tier 2: Try WhatsApp
    final whatsappAvailable = await _whatsapp.isAvailableForUser(userId);
    if (whatsappAvailable) {
      final sent = await _whatsapp.sendFallbackMessage(
        userId: userId,
        payload: payload,
      );
      if (sent) {
        debugPrint('🌐 [Omni] ✅ Escalated to WhatsApp');
        await _logEscalation(userId, payload, 'whatsapp', true);
        return;
      }
    }

    // Tier 3: Try SMS (last resort)
    final smsAvailable = await _sms.isAvailableForUser(userId);
    if (smsAvailable) {
      final sent = await _sms.sendFallbackSms(
        userId: userId,
        payload: payload,
      );
      if (sent) {
        debugPrint('🌐 [Omni] ✅ Escalated to SMS');
        await _logEscalation(userId, payload, 'sms', true);
        return;
      }
    }

    debugPrint(
        '🌐 [Omni] ⚠️ All escalation channels failed for: ${payload.id}');
    await _logEscalation(userId, payload, 'none', false);
  }

  /// Log escalation events for analytics.
  Future<void> _logEscalation(
    String userId,
    NotificationPayload payload,
    String channel,
    bool success,
  ) async {
    try {
      await _supabase.from('notification_escalations').insert({
        'user_id': userId,
        'notification_id': payload.id,
        'category': payload.category.name,
        'escalation_channel': channel,
        'success': success,
        'created_at': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      // Non-critical — don't let logging failures affect delivery
      debugPrint('🌐 [Omni] Failed to log escalation: $e');
    }
  }

  void dispose() {
    _tracker.dispose();
    _initialized = false;
  }
}
