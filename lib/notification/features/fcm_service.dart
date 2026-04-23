import 'dart:async';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:banjarabio/notification/core/notification_base.dart';
import 'package:banjarabio/notification/core/notification_payload.dart';

/// 🔔 Top-level background message handler.
///
/// MUST be a top-level function (not a class method) for Firebase to invoke it
/// when the app is terminated or in the background.
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // Background messages with a `notification` payload are auto-displayed by
  // the system tray. Data-only messages can be processed here if needed.
  debugPrint('🔔 [FCM-BG] Background message: ${message.messageId}');
}

/// Implementation of FCM (Firebase Cloud Messaging) Service.
///
/// Handles:
/// - Permission requests
/// - Token management with immediate sync + retry
/// - Foreground, background, and terminated message handling
/// - Stream-based event broadcasting
class FCMService implements NotificationBase {
  static final FCMService _instance = FCMService._internal();
  factory FCMService() => _instance;
  FCMService._internal();

  FirebaseMessaging? get _fcm {
    try {
      if (Firebase.apps.isNotEmpty) {
        return FirebaseMessaging.instance;
      }
    } catch (_) {}
    return null;
  }

  SupabaseClient get _supabase => Supabase.instance.client;

  bool _initialized = false;

  // Streams for external consumption
  final StreamController<NotificationPayload> _messageController =
      StreamController<NotificationPayload>.broadcast();
  Stream<NotificationPayload> get onMessage => _messageController.stream;

  final StreamController<NotificationPayload> _openedAppController =
      StreamController<NotificationPayload>.broadcast();
  Stream<NotificationPayload> get onMessageOpenedApp =>
      _openedAppController.stream;

  StreamSubscription<AuthState>? _authStateSubscription;
  StreamSubscription<String>? _tokenRefreshSubscription;
  StreamSubscription<RemoteMessage>? _foregroundSubscription;
  StreamSubscription<RemoteMessage>? _openedAppSubscription;

  /// Pending token that failed to sync — will be retried on next opportunity.
  String? _pendingToken;

  @override
  Future<void> initialize() async {
    if (_initialized) return;
    _initialized = true;

    debugPrint('🔔 [FCMService] Initializing...');

    try {
      // 0. Register background handler (must be done before any other FCM call)
      if (Firebase.apps.isNotEmpty) {
        FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
      }

    // 1. Initial configuration
    await _setupInteractions();

    // 2. Auth Context Sync — IMMEDIATE token sync on login
    _authStateSubscription =
        _supabase.auth.onAuthStateChange.listen((data) {
      if (data.session != null) {
        // ✅ IMMEDIATE sync (was 15s delay — now instant)
        syncToken(data.session!.user.id);
      }
    });

    // 3. Token Refresh listener — sync immediately when Firebase rotates token
    _tokenRefreshSubscription = _fcm?.onTokenRefresh.listen((token) {
      final userId = _supabase.auth.currentUser?.id;
      if (userId != null) {
        _updateTokenOnServer(userId, token);
      } else {
        // User not logged in yet — stash for later
        _pendingToken = token;
      }
    });

    // 4. Foreground Message Handler
    if (Firebase.apps.isNotEmpty) {
      _foregroundSubscription =
          FirebaseMessaging.onMessage.listen((RemoteMessage message) {
        debugPrint(
            '🔔 [FCMService] Foreground message: ${message.notification?.title}');
        _messageController.add(NotificationPayload.fromFcm(
          message.data,
          title: message.notification?.title,
          body: message.notification?.body,
        ));
      });
    }

    // 5. App Opened from Notification Handler (Stream)
    if (Firebase.apps.isNotEmpty) {
      _openedAppSubscription =
          FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
        debugPrint(
            '🔔 [FCMService] App opened from foreground/background notification');
        _openedAppController.add(NotificationPayload.fromFcm(
          message.data,
          title: message.notification?.title,
          body: message.notification?.body,
        ));
      });
    }

    // 6. Check for Initial Message (App launched from terminated state)
    final RemoteMessage? initialMessage = await _fcm?.getInitialMessage();
    if (initialMessage != null) {
      debugPrint(
          '🔔 [FCMService] App launched from terminated state via notification');
      _openedAppController.add(NotificationPayload.fromFcm(
        initialMessage.data,
        title: initialMessage.notification?.title,
        body: initialMessage.notification?.body,
      ));
    }
    } catch (e) {
      debugPrint('🔔 [FCMService] Bypassed Firebase for tests: $e');
    }
  }

  Future<void> _setupInteractions() async {
    // Ensure foreground notifications show heads-up on iOS
    await _fcm?.setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );
  }

  @override
  Future<bool> requestPermission() async {
    final NotificationSettings? settings = await _fcm?.requestPermission();
    final granted =
        settings?.authorizationStatus == AuthorizationStatus.authorized ||
            settings?.authorizationStatus == AuthorizationStatus.provisional;

    debugPrint('🔔 [FCMService] Permission granted: $granted');
    return granted;
  }

  /// Manually sync token for a specific user.
  /// Also drains any [_pendingToken] that was stashed before auth.
  Future<void> syncToken(String userId) async {
    try {
      // Drain pending token first (from onTokenRefresh before auth)
      if (_pendingToken != null) {
        await _updateTokenOnServer(userId, _pendingToken!);
        _pendingToken = null;
        return;
      }

      final String? token = await _fcm?.getToken();
      if (token != null) await _updateTokenOnServer(userId, token);
    } catch (e) {
      debugPrint('🔔 [FCMService] Error getting token (or test bypass): $e');
    }
  }

  /// Updates FCM token on the server with a simple retry mechanism.
  Future<void> _updateTokenOnServer(String userId, String token) async {
    const maxRetries = 3;
    for (int attempt = 1; attempt <= maxRetries; attempt++) {
      try {
        await _supabase.from('profiles').update({
          'fcm_token': token,
          'updated_at': DateTime.now().toIso8601String(),
        }).eq('user_id', userId);
        debugPrint('🔔 [FCMService] Token synced for user: $userId');
        return; // Success — exit retry loop
      } catch (e) {
        debugPrint(
            '🔔 [FCMService] Token sync attempt $attempt/$maxRetries failed: $e');
        if (attempt < maxRetries) {
          // Exponential backoff: 2s, 4s
          await Future.delayed(Duration(seconds: attempt * 2));
        } else {
          // Stash for next opportunity
          _pendingToken = token;
          debugPrint(
              '🔔 [FCMService] Token stashed. Will retry on next auth event.');
        }
      }
    }
  }

  @override
  Future<void> show(NotificationPayload payload) async {
    // FCM doesn't "show" notifications manually in the same way LocalNotifications do.
    // It receives them. However, we could implement a "send to self" via server if needed.
  }

  @override
  Future<void> cancel(int id) async {}

  @override
  Future<void> cancelAll() async {}

  @override
  void dispose() {
    _authStateSubscription?.cancel();
    _tokenRefreshSubscription?.cancel();
    _foregroundSubscription?.cancel();
    _openedAppSubscription?.cancel();
    _messageController.close();
    _openedAppController.close();
    _initialized = false;
  }
}

