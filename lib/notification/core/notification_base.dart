import 'package:banjarabio/notification/core/notification_payload.dart';

/// Abstract interface defining the standard contract for notification services.
abstract class NotificationBase {
  /// Initializes the service
  Future<void> initialize();

  /// Requests permissions from the user
  Future<bool> requestPermission();

  /// Shows a notification immediately
  Future<void> show(NotificationPayload payload);

  /// Cancels a specific notification by ID
  Future<void> cancel(int id);

  /// Cancels all notifications from this service
  Future<void> cancelAll();

  /// Disposes resources and stream subscriptions
  void dispose();
}
