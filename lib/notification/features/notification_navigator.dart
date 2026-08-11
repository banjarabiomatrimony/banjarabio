import 'package:banjarabio/core/services/deep_link_service.dart';
import 'package:banjarabio/notification/core/notification_payload.dart';
import 'package:banjarabio/core/services/app_logger.dart';

/// Specialized navigator for notifications, leveraging existing DeepLinkService.
class NotificationNavigator {
  static final NotificationNavigator _instance = NotificationNavigator._internal();
  factory NotificationNavigator() => _instance;
  NotificationNavigator._internal();

  /// Pass the notification payload to the deep link service for routing.
  void handleNotificationTap(NotificationPayload payload) {
    AppLogger.debug('NotificationNavigator', '🚀 [NotificationNavigator] Handling tap: ${payload.route}');
    
    if (payload.route != null) {
      final Uri? uri = Uri.tryParse(payload.route!);
      if (uri != null) {
        DeepLinkService().handleDeepLink(uri);
        return;
      }
    }
    
    // Fallback: If no explicit route, but we have data, we might infer it
    if (payload.data.containsKey('profile_id')) {
      final profileId = payload.data['profile_id'];
      final uri = Uri.parse('banjarabio://profile/$profileId');
      DeepLinkService().handleDeepLink(uri);
    }
  }
}
