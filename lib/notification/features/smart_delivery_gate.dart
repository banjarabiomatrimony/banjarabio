import 'package:flutter/foundation.dart';
import 'package:banjarabio/notification/core/notification_payload.dart';
import 'package:banjarabio/notification/features/notification_preferences.dart';

/// Smart Delivery Gate.
///
/// Acts as the final checkpoint before a notification is shown.
/// Checks:
/// 1. User hasn't opted out of this category
/// 2. Current time isn't within quiet hours (DND)
/// 3. Category-specific rate limits aren't exceeded
///
/// This ensures zero unwanted notifications reach the user.
class SmartDeliveryGate {
  static final SmartDeliveryGate _instance = SmartDeliveryGate._internal();
  factory SmartDeliveryGate() => _instance;
  SmartDeliveryGate._internal();

  final NotificationPreferences _prefs = NotificationPreferences();

  /// Rate limit tracking: category → last delivery timestamp.
  final Map<NotificationCategory, DateTime> _lastDelivery = {};

  /// Minimum interval between notifications per category.
  static const Map<NotificationCategory, Duration> _categoryRateLimits = {
    NotificationCategory.profileView: Duration(minutes: 5),
    NotificationCategory.nudge: Duration(hours: 4),
    NotificationCategory.general: Duration(minutes: 10),
    // High-priority categories have no rate limit:
    // interestReceived, matchFound, chatMessage
  };

  /// Returns true if the notification should be delivered.
  /// Returns false if it should be silently dropped.
  Future<bool> shouldDeliver(NotificationPayload payload) async {
    // 1. Check category opt-in
    final categoryEnabled = await _prefs.isCategoryEnabled(payload.category);
    if (!categoryEnabled) {
      debugPrint(
          '🚫 [Gate] Blocked ${payload.category.name}: category disabled by user');
      return false;
    }

    // 2. Check quiet hours (but ALWAYS allow chat messages through)
    if (payload.category != NotificationCategory.chatMessage) {
      final isQuiet = await _prefs.isQuietTime();
      if (isQuiet) {
        debugPrint(
            '🌙 [Gate] Blocked ${payload.category.name}: quiet hours active');
        return false;
      }
    }

    // 3. Check rate limit
    final rateLimit = _categoryRateLimits[payload.category];
    if (rateLimit != null) {
      final last = _lastDelivery[payload.category];
      if (last != null && DateTime.now().difference(last) < rateLimit) {
        debugPrint(
            '⏱️ [Gate] Blocked ${payload.category.name}: rate limited');
        return false;
      }
    }

    // ✅ Passed all checks — record delivery and allow
    _lastDelivery[payload.category] = DateTime.now();
    return true;
  }

  /// Reset rate limits (e.g., on app restart).
  void reset() {
    _lastDelivery.clear();
  }
}
