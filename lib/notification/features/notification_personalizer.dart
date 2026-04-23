import 'dart:math';
import 'package:banjarabio/notification/core/notification_payload.dart';

/// AI-Driven Content Personalizer.
///
/// Transforms generic notification payloads into emotionally resonant,
/// context-aware messages that maximize engagement. Uses template-based
/// personalization with randomization to keep messages fresh.
///
/// Examples:
/// - "New interest" → "💕 Priya (95% match) is interested in you!"
/// - "Profile view" → "👀 Someone from your city just viewed your profile"
class NotificationPersonalizer {
  static final NotificationPersonalizer _instance =
      NotificationPersonalizer._internal();
  factory NotificationPersonalizer() => _instance;
  NotificationPersonalizer._internal();

  final _random = Random();

  /// Personalize a notification payload based on its category and data.
  NotificationPayload personalize(NotificationPayload payload) {
    switch (payload.category) {
      case NotificationCategory.interestReceived:
        return _personalizeInterest(payload);
      case NotificationCategory.matchFound:
        return _personalizeMatch(payload);
      case NotificationCategory.chatMessage:
        return _personalizeChat(payload);
      case NotificationCategory.profileView:
        return _personalizeProfileView(payload);
      case NotificationCategory.nudge:
        return payload; // Nudges are already personalized by NudgeEngine
      case NotificationCategory.system:
      case NotificationCategory.general:
      case NotificationCategory.staffTask:
      case NotificationCategory.adminAlert:
      case NotificationCategory.verificationReview:
        return payload; // No personalization needed
    }
  }

  NotificationPayload _personalizeInterest(NotificationPayload payload) {
    final senderName = payload.data['sender_name'] as String? ?? 'Someone';
    final compatibility = payload.data['compatibility_score'] as int?;
    final city = payload.data['sender_city'] as String?;

    final templates = [
      (
        '💕 $senderName is interested in you!',
        compatibility != null
            ? '$compatibility% compatibility match'
            : 'View their profile now'
      ),
      (
        '❤️ New interest from $senderName',
        city != null ? 'From $city' : 'Check out their profile'
      ),
      (
        '🌹 $senderName wants to connect!',
        'Don\'t keep them waiting'
      ),
      (
        '💍 Someone special noticed you!',
        '$senderName sent you an interest'
      ),
    ];

    if (compatibility != null && compatibility >= 90) {
      return _applyTemplate(payload, (
        '🌟 Wow! $senderName is a $compatibility% match!',
        'This could be the one — check their profile now!'
      ));
    }

    return _applyTemplate(payload, templates[_random.nextInt(templates.length)]);
  }

  NotificationPayload _personalizeMatch(NotificationPayload payload) {
    final senderName = payload.data['sender_name'] as String? ?? 'Someone';

    final templates = [
      (
        '🎉 It\'s a match with $senderName!',
        'You both showed mutual interest — start a conversation!'
      ),
      (
        '💍 Mutual interest confirmed!',
        '$senderName also liked you! Say hello 👋'
      ),
      (
        '✨ Great news! You matched with $senderName',
        'Break the ice with a message'
      ),
    ];

    return _applyTemplate(payload, templates[_random.nextInt(templates.length)]);
  }

  NotificationPayload _personalizeChat(NotificationPayload payload) {
    final senderName = payload.data['sender_name'] as String? ?? 'Your match';
    final preview = payload.data['message_preview'] as String?;

    if (preview != null && preview.length > 40) {
      return _applyTemplate(payload, (
        '💬 $senderName',
        '${preview.substring(0, 40)}...'
      ));
    }

    return _applyTemplate(payload, (
      '💬 $senderName',
      preview ?? 'Sent you a message'
    ));
  }

  NotificationPayload _personalizeProfileView(NotificationPayload payload) {
    final senderName = payload.data['sender_name'] as String?;
    final city = payload.data['sender_city'] as String?;

    final templates = senderName != null
        ? [
            (
              '👀 $senderName viewed your profile',
              city != null ? 'From $city' : 'They might be interested!'
            ),
            (
              '🔍 $senderName checked you out!',
              'Send them an interest?'
            ),
          ]
        : [
            (
              '👀 Someone viewed your profile',
              city != null
                  ? 'A match from $city is checking you out'
                  : 'You\'re getting noticed!'
            ),
            (
              '🔍 Your profile is getting attention!',
              'See who\'s interested in you'
            ),
          ];

    return _applyTemplate(payload, templates[_random.nextInt(templates.length)]);
  }

  NotificationPayload _applyTemplate(
    NotificationPayload payload,
    (String title, String body) template,
  ) {
    final (title, body) = template;
    return NotificationPayload(
      id: payload.id,
      title: title,
      body: body,
      imageUrl: payload.imageUrl,
      route: payload.route,
      category: payload.category,
      actions: payload.actions,
      data: payload.data,
    );
  }
}
