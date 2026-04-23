import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:banjarabio/notification/core/notification_payload.dart';

/// Smart Notification Batcher.
///
/// Groups rapid-fire notifications of the same category into a single
/// summary notification to avoid overwhelming the user.
///
/// Example:
/// - 5 profile views in 2 minutes → "5 people viewed your profile"
/// - 3 interests in 1 minute → "3 new interests today!"
class NotificationBatcher {
  static final NotificationBatcher _instance =
      NotificationBatcher._internal();
  factory NotificationBatcher() => _instance;
  NotificationBatcher._internal();

  /// Batching window: notifications of the same category within this
  /// duration are grouped together.
  static const Duration _batchWindow = Duration(seconds: 30);

  /// Category → list of pending payloads within the batch window.
  final Map<NotificationCategory, List<NotificationPayload>> _batches = {};

  /// Category → timer that fires when the batch window closes.
  final Map<NotificationCategory, Timer> _timers = {};

  /// Callback when a batch is ready to be displayed.
  void Function(NotificationPayload batched)? onBatchReady;

  /// Categories that should be batched. High-priority categories like
  /// chatMessage and matchFound are delivered immediately.
  static const _batchableCategories = {
    NotificationCategory.profileView,
    NotificationCategory.nudge,
    NotificationCategory.general,
  };

  /// Add a notification. Returns true if it was batched (deferred),
  /// false if it should be shown immediately.
  bool add(NotificationPayload payload) {
    // Immediate delivery for high-priority categories
    if (!_batchableCategories.contains(payload.category)) {
      return false; // Not batched — show immediately
    }

    final cat = payload.category;
    _batches.putIfAbsent(cat, () => []);
    _batches[cat]!.add(payload);

    // Start or reset the batch timer
    _timers[cat]?.cancel();
    _timers[cat] = Timer(_batchWindow, () => _flushBatch(cat));

    debugPrint(
        '🔔 [Batcher] Queued ${cat.name} notification (batch size: ${_batches[cat]!.length})');
    return true; // Batched — don't show individually
  }

  /// Flush a batch and emit a summary notification.
  void _flushBatch(NotificationCategory category) {
    final items = _batches.remove(category);
    _timers.remove(category);

    if (items == null || items.isEmpty) return;

    if (items.length == 1) {
      // Only 1 item — show as-is
      onBatchReady?.call(items.first);
      return;
    }

    // Create a summary notification
    final summary = _buildSummary(category, items);
    debugPrint(
        '🔔 [Batcher] Flushing batch: ${items.length} ${category.name} → "${summary.title}"');
    onBatchReady?.call(summary);
  }

  NotificationPayload _buildSummary(
    NotificationCategory category,
    List<NotificationPayload> items,
  ) {
    switch (category) {
      case NotificationCategory.profileView:
        return NotificationPayload(
          id: 'batch_${category.name}_${DateTime.now().millisecondsSinceEpoch}',
          title: '👀 ${items.length} people viewed your profile',
          body: _summarizeNames(items),
          category: category,
          route: '/who-viewed-me',
          data: {'batch_count': items.length},
        );

      case NotificationCategory.nudge:
        return NotificationPayload(
          id: 'batch_${category.name}_${DateTime.now().millisecondsSinceEpoch}',
          title: '⭐ ${items.length} tips to boost your profile',
          body: 'Complete your profile to get more matches!',
          category: category,
          data: {'batch_count': items.length},
        );

      default:
        return NotificationPayload(
          id: 'batch_${category.name}_${DateTime.now().millisecondsSinceEpoch}',
          title: '🔔 ${items.length} new notifications',
          body: items.map((i) => i.title ?? '').take(3).join(', '),
          category: category,
          route: '/activity-hub',
          data: {'batch_count': items.length},
        );
    }
  }

  /// Build a human-readable list of names from individual payloads.
  /// E.g., "Priya, Rahul, and 3 others"
  String _summarizeNames(List<NotificationPayload> items) {
    final names = items
        .map((p) => p.data['sender_name'] as String?)
        .where((n) => n != null && n.isNotEmpty)
        .toList();

    if (names.isEmpty) return 'Check who viewed your profile';
    if (names.length == 1) return '${names[0]} viewed your profile';
    if (names.length == 2) return '${names[0]} and ${names[1]}';
    return '${names[0]}, ${names[1]}, and ${names.length - 2} others';
  }

  /// Force-flush all pending batches (e.g., when app goes to background).
  void flushAll() {
    for (final cat in List.of(_batches.keys)) {
      _timers[cat]?.cancel();
      _flushBatch(cat);
    }
  }

  void dispose() {
    for (final timer in _timers.values) {
      timer.cancel();
    }
    _timers.clear();
    _batches.clear();
  }
}
