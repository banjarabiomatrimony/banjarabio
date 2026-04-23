import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:banjarabio/notification/core/notification_payload.dart';

/// Tracks delivery status of push notifications for fallback logic.
///
/// When a push notification is sent, it's registered here. If the user
/// doesn't interact with or "see" the notification within the escalation
/// window, the omni-channel orchestrator can escalate to WhatsApp/SMS.
class DeliveryTracker {
  static final DeliveryTracker _instance = DeliveryTracker._internal();
  factory DeliveryTracker() => _instance;
  DeliveryTracker._internal();

  /// Notification ID → delivery record.
  final Map<String, _DeliveryRecord> _records = {};

  /// Callback when a notification is deemed "unseen" after the escalation window.
  void Function(NotificationPayload payload)? onEscalationNeeded;

  /// Default escalation window: if push isn't seen in 15 minutes, escalate.
  static const Duration _escalationWindow = Duration(minutes: 15);

  /// High-priority escalation: for matches and interests, escalate faster.
  static const Duration _highPriorityWindow = Duration(minutes: 5);

  /// Register a sent notification for tracking.
  void trackDelivery(NotificationPayload payload) {
    final id = payload.id ?? DateTime.now().millisecondsSinceEpoch.toString();

    final window = _getEscalationWindow(payload.category);

    final record = _DeliveryRecord(
      payload: payload,
      sentAt: DateTime.now(),
      escalationTimer: Timer(window, () {
        _escalate(id);
      }),
    );

    _records[id] = record;

    debugPrint(
        '📡 [Tracker] Tracking: $id (escalation in ${window.inMinutes}m)');
  }

  /// Mark a notification as seen/interacted — cancel escalation.
  void markAsSeen(String notificationId) {
    final record = _records.remove(notificationId);
    if (record != null) {
      record.escalationTimer.cancel();
      debugPrint('📡 [Tracker] Marked as seen: $notificationId');
    }
  }

  /// Mark all tracked notifications as seen (e.g., user opened Activity Hub).
  void markAllAsSeen() {
    for (final record in _records.values) {
      record.escalationTimer.cancel();
    }
    _records.clear();
    debugPrint('📡 [Tracker] All notifications marked as seen');
  }

  /// Called when escalation timer fires.
  void _escalate(String notificationId) {
    final record = _records.remove(notificationId);
    if (record == null) return;

    debugPrint(
        '📡 [Tracker] Escalating unseen notification: $notificationId');
    onEscalationNeeded?.call(record.payload);
  }

  Duration _getEscalationWindow(NotificationCategory category) {
    switch (category) {
      case NotificationCategory.interestReceived:
      case NotificationCategory.matchFound:
        return _highPriorityWindow; // 5 minutes
      case NotificationCategory.chatMessage:
        return const Duration(minutes: 10); // 10 minutes for chat
      default:
        return _escalationWindow; // 15 minutes default
    }
  }

  /// Number of currently tracked (unseen) notifications.
  int get pendingCount => _records.length;

  void dispose() {
    for (final record in _records.values) {
      record.escalationTimer.cancel();
    }
    _records.clear();
  }
}

class _DeliveryRecord {
  final NotificationPayload payload;
  final DateTime sentAt;
  final Timer escalationTimer;

  _DeliveryRecord({
    required this.payload,
    required this.sentAt,
    required this.escalationTimer,
  });
}
