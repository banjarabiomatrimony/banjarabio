import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:banjarabio/notification/core/notification_base.dart';
import 'package:banjarabio/notification/core/notification_payload.dart';
import 'package:banjarabio/core/services/app_logger.dart';
import 'package:banjarabio/theme/app_colors.dart';

/// Service to handle local notifications for foreground alerts and scheduled messages.
///
/// Supports:
/// - Rich media (BigPicture style with profile photos)
/// - Action buttons (Accept, View, Message)
/// - Multiple notification channels by category
class LocalNotificationService implements NotificationBase {
  static final LocalNotificationService _instance =
      LocalNotificationService._internal();
  factory LocalNotificationService() => _instance;
  LocalNotificationService._internal();

  final FlutterLocalNotificationsPlugin _localPlugin =
      FlutterLocalNotificationsPlugin();
  bool _initialized = false;

  final StreamController<NotificationPayload> _payloadController =
      StreamController<NotificationPayload>.broadcast();
  Stream<NotificationPayload> get onNotificationTap =>
      _payloadController.stream;

  // ---------------------------------------------------------------------------
  // Channel Configuration
  // ---------------------------------------------------------------------------

  /// High-importance channel for interests, matches, and messages.
  static const _matchesChannel = AndroidNotificationChannel(
    'matches_channel',
    'Matches & Interests',
    description: 'Notifications for new matches, interests, and messages.',
    importance: Importance.max,
    enableLights: true,
    ledColor: AppColors.softRed,
  );

  /// Medium-importance channel for profile views and nudges.
  static const _activityChannel = AndroidNotificationChannel(
    'activity_channel',
    'Profile Activity',
    description: 'Notifications for profile views and activity nudges.',
    importance: Importance.high,
  );

  /// Low-importance channel for system and promotional alerts.
  static const _systemChannel = AndroidNotificationChannel(
    'system_channel',
    'System Updates',
    description: 'Subscription reminders, tips, and system alerts.',
  );

  /// High-importance channel for staff task assignments.
  static const _staffChannel = AndroidNotificationChannel(
    'staff_channel',
    'Staff Tasks',
    description: 'Verification requests, reports, and assigned tasks.',
    importance: Importance.max,
    enableLights: true,
    ledColor: AppColors.materialBlue,
  );

  /// High-importance channel for admin alerts.
  static const _adminChannel = AndroidNotificationChannel(
    'admin_channel',
    'Admin Alerts',
    description: 'Payments, registrations, deletions, and critical events.',
    importance: Importance.max,
    enableLights: true,
    ledColor: AppColors.deepOrange,
  );

  @override
  Future<void> initialize() async {
    if (_initialized) return;
    _initialized = true;

    const AndroidInitializationSettings androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const DarwinInitializationSettings iosSettings =
        DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );

    const InitializationSettings settings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _localPlugin.initialize(
      settings,
      onDidReceiveNotificationResponse: _onTap,
    );

    // Create all channels for Android
    if (Platform.isAndroid) {
      final androidPlugin = _localPlugin
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>();

      await androidPlugin?.createNotificationChannel(_matchesChannel);
      await androidPlugin?.createNotificationChannel(_activityChannel);
      await androidPlugin?.createNotificationChannel(_systemChannel);
      await androidPlugin?.createNotificationChannel(_staffChannel);
      await androidPlugin?.createNotificationChannel(_adminChannel);
    }
  }

  void _onTap(NotificationResponse response) {
    if (response.payload != null) {
      final payload =
          NotificationPayload.fromJsonString(response.payload!);

      // Handle action button taps
      if (response.actionId != null && response.actionId!.isNotEmpty) {
        debugPrint(
            '🔔 [Local] Action tapped: ${response.actionId} for payload: ${payload.id}');
        // The action ID can carry routing info — enhance the payload
        final actionRoute = payload.actions
            .where((a) => a.id == response.actionId)
            .firstOrNull
            ?.route;
        if (actionRoute != null) {
          _payloadController.add(NotificationPayload(
            id: payload.id,
            title: payload.title,
            body: payload.body,
            route: actionRoute,
            category: payload.category,
            data: payload.data,
          ));
          return;
        }
      }

      _payloadController.add(payload);
    }
  }

  @override
  Future<bool> requestPermission() async {
    if (Platform.isIOS) {
      final bool? result = await _localPlugin
          .resolvePlatformSpecificImplementation<
              IOSFlutterLocalNotificationsPlugin>()
          ?.requestPermissions(alert: true, badge: true, sound: true);
      return result ?? false;
    } else if (Platform.isAndroid) {
      final bool? result = await _localPlugin
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>()
          ?.requestNotificationsPermission();
      return result ?? false;
    }
    return true;
  }

  @override
  Future<void> show(NotificationPayload payload) async {
    final int id =
        DateTime.now().millisecondsSinceEpoch.remainder(100000);

    // Select channel based on notification category
    final channel = _getChannelForCategory(payload.category);

    // Attempt to download profile image for rich notification
    BigPictureStyleInformation? bigPictureStyle;
    if (payload.hasImage) {
      bigPictureStyle = await _buildBigPictureStyle(payload.imageUrl!);
    }

    // Build action buttons if available
    final List<AndroidNotificationAction> androidActions = payload.actions
        .map((a) => AndroidNotificationAction(
              a.id,
              a.label,
              showsUserInterface: true,
            ))
        .toList();

    final AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
      channel.id,
      channel.name,
      channelDescription: channel.description,
      importance: channel.importance,
      priority: Priority.high,
      ticker: payload.title ?? 'BanjaraBio',
      styleInformation: bigPictureStyle,
      actions: androidActions.isNotEmpty ? androidActions : null,
      category: _getAndroidCategory(payload.category),
      vibrationPattern: Int64List.fromList([0, 500, 200, 500]),
      enableLights: true,
      ledColor: AppColors.softRed,
      ledOnMs: 1000,
      ledOffMs: 500,
      fullScreenIntent: _isHighPriority(payload.category),
    );

    final NotificationDetails details = NotificationDetails(
      android: androidDetails,
      iOS: const DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      ),
    );

    await _localPlugin.show(
      id,
      payload.title,
      payload.body,
      details,
      payload: payload.toJsonString(),
    );
  }

  /// Returns the appropriate Android notification channel for the category.
  AndroidNotificationChannel _getChannelForCategory(
      NotificationCategory category) {
    switch (category) {
      case NotificationCategory.interestReceived:
      case NotificationCategory.matchFound:
      case NotificationCategory.chatMessage:
        return _matchesChannel;
      case NotificationCategory.profileView:
      case NotificationCategory.nudge:
        return _activityChannel;
      case NotificationCategory.staffTask:
      case NotificationCategory.verificationReview:
        return _staffChannel;
      case NotificationCategory.adminAlert:
        return _adminChannel;
      case NotificationCategory.system:
      case NotificationCategory.general:
        return _systemChannel;
    }
  }

  /// Whether this category should trigger fullScreenIntent (lock-screen pop-up).
  bool _isHighPriority(NotificationCategory category) {
    return category == NotificationCategory.interestReceived ||
        category == NotificationCategory.matchFound ||
        category == NotificationCategory.chatMessage ||
        category == NotificationCategory.staffTask ||
        category == NotificationCategory.adminAlert;
  }

  /// Maps our category to an Android notification category string.
  AndroidNotificationCategory? _getAndroidCategory(
      NotificationCategory category) {
    switch (category) {
      case NotificationCategory.chatMessage:
        return AndroidNotificationCategory.message;
      case NotificationCategory.interestReceived:
      case NotificationCategory.matchFound:
        return AndroidNotificationCategory.social;
      case NotificationCategory.system:
      case NotificationCategory.adminAlert:
        return AndroidNotificationCategory.service;
      case NotificationCategory.staffTask:
      case NotificationCategory.verificationReview:
        return AndroidNotificationCategory.reminder;
      default:
        return null;
    }
  }

  /// Downloads the image at [url] and creates a BigPictureStyleInformation.
  /// Returns null on any failure (network, file, etc.) so the notification
  /// falls back to a text-only display gracefully.
  Future<BigPictureStyleInformation?> _buildBigPictureStyle(
      String url) async {
    try {
      final response = await http
          .get(Uri.parse(url))
          .timeout(const Duration(seconds: 5));
      if (response.statusCode != 200) return null;

      final tempDir = await getTemporaryDirectory();
      final filePath =
          '${tempDir.path}/notif_img_${DateTime.now().millisecondsSinceEpoch}.jpg';
      final file = File(filePath);
      await file.writeAsBytes(response.bodyBytes);

      return BigPictureStyleInformation(
        FilePathAndroidBitmap(filePath),
      );
    } catch (e) {
      AppLogger.error('LocalNotificationService', '🔔 [Local] Failed to download notification image: $e');
      return null;
    }
  }

  /// Schedules a daily repeating notification.
  Future<void> scheduleDaily({
    required int id,
    required String title,
    required String body,
    required NotificationPayload payload,
  }) async {
    final channel = _getChannelForCategory(payload.category);

    final AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      channel.id,
      channel.name,
      channelDescription: channel.description,
      importance: channel.importance,
      priority: Priority.high,
      ticker: title,
      category: AndroidNotificationCategory.reminder,
    );

    final NotificationDetails details = NotificationDetails(
      android: androidDetails,
      iOS: const DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      ),
    );

    try {
      await _localPlugin.periodicallyShow(
        id,
        title,
        body,
        RepeatInterval.daily,
        details,
        payload: payload.toJsonString(),
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      );
    } catch (e) {
      AppLogger.error(
        'LocalNotificationService',
        'Failed to schedule daily notification: $e',
      );
    }
  }

  @override
  Future<void> cancel(int id) async {
    await _localPlugin.cancel(id);
  }

  @override
  Future<void> cancelAll() async {
    await _localPlugin.cancelAll();
  }

  @override
  void dispose() {
    _payloadController.close();
    _initialized = false;
  }
}
