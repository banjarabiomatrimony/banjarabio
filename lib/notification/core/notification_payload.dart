import 'dart:convert';

/// Notification categories for grouping and priority logic.
enum NotificationCategory {
  /// New interest received from another user
  interestReceived,

  /// A mutual match has occurred
  matchFound,

  /// New chat message received
  chatMessage,

  /// Someone viewed your profile
  profileView,

  /// Profile completion or trust score nudges
  nudge,

  /// Subscription, payment, or system alerts
  system,

  /// General/unknown
  general,

  /// Staff task assignment (verification review, report handling)
  staffTask,

  /// Admin-level alert (payments, registrations, deletions)
  adminAlert,

  /// Verification review request
  verificationReview,
}


/// Action buttons that can appear on a notification.
class NotificationAction {
  final String id;
  final String label;
  final String? route;

  const NotificationAction({
    required this.id,
    required this.label,
    this.route,
  });

  factory NotificationAction.fromJson(Map<String, dynamic> json) {
    return NotificationAction(
      id: json['id'] ?? '',
      label: json['label'] ?? '',
      route: json['route'],
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'label': label,
        'route': route,
      };
}

/// Standardized notification payload for internal app routing and display.
///
/// Supports:
/// - Rich media (profile images via [imageUrl])
/// - Action buttons ([actions])
/// - Categorization for smart batching ([category])
/// - Deep metadata for AI-driven personalization ([data])
class NotificationPayload {
  final String? id;
  final String? title;
  final String? body;
  final String? imageUrl;
  final String? route;
  final NotificationCategory category;
  final List<NotificationAction> actions;
  final Map<String, dynamic> data;

  NotificationPayload({
    this.id,
    this.title,
    this.body,
    this.imageUrl,
    this.route,
    this.category = NotificationCategory.general,
    this.actions = const [],
    this.data = const {},
  });

  /// Factory to create from FCM RemoteMessage.data
  factory NotificationPayload.fromFcm(
    Map<String, dynamic> fcmData, {
    String? title,
    String? body,
  }) {
    // Parse category from string
    final categoryStr = fcmData['category'] ?? 'general';
    final category = NotificationCategory.values.firstWhere(
      (c) => c.name == categoryStr,
      orElse: () => NotificationCategory.general,
    );

    // Parse actions if present
    List<NotificationAction> actions = [];
    if (fcmData['actions'] != null) {
      try {
        final actionsList = fcmData['actions'] is String
            ? json.decode(fcmData['actions']) as List
            : fcmData['actions'] as List;
        actions = actionsList
            .map((a) => NotificationAction.fromJson(
                a is Map<String, dynamic> ? a : {}))
            .toList();
      } catch (_) {
        // Silently ignore malformed actions
      }
    }

    return NotificationPayload(
      id: fcmData['id'] ?? fcmData['message_id'],
      title: title ?? fcmData['title'],
      body: body ?? fcmData['body'],
      imageUrl: fcmData['image'] ?? fcmData['image_url'],
      route: fcmData['route'] ?? fcmData['click_action'],
      category: category,
      actions: actions,
      data: fcmData,
    );
  }

  /// Factory to create from a JSON string (used for local notification payloads)
  factory NotificationPayload.fromJsonString(String jsonStr) {
    try {
      final Map<String, dynamic> decoded = json.decode(jsonStr);

      final categoryStr = decoded['category'] ?? 'general';
      final category = NotificationCategory.values.firstWhere(
        (c) => c.name == categoryStr,
        orElse: () => NotificationCategory.general,
      );

      List<NotificationAction> actions = [];
      if (decoded['actions'] != null) {
        actions = (decoded['actions'] as List)
            .map((a) => NotificationAction.fromJson(a))
            .toList();
      }

      return NotificationPayload(
        id: decoded['id'],
        title: decoded['title'],
        body: decoded['body'],
        imageUrl: decoded['imageUrl'],
        route: decoded['route'],
        category: category,
        actions: actions,
        data: decoded['data'] ?? {},
      );
    } catch (_) {
      return NotificationPayload();
    }
  }

  String toJsonString() {
    return json.encode({
      'id': id,
      'title': title,
      'body': body,
      'imageUrl': imageUrl,
      'route': route,
      'category': category.name,
      'actions': actions.map((a) => a.toJson()).toList(),
      'data': data,
    });
  }

  /// Whether this notification has a profile image for rich display.
  bool get hasImage => imageUrl != null && imageUrl!.isNotEmpty;

  /// Whether this notification has action buttons.
  bool get hasActions => actions.isNotEmpty;

  /// Convenience: Get the sender's profile ID if present in data.
  String? get senderProfileId => data['sender_profile_id'] as String?;

  @override
  String toString() =>
      'NotificationPayload(id: $id, title: $title, category: ${category.name}, route: $route)';
}
