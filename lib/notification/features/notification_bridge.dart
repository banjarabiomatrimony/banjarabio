import 'dart:async';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:banjarabio/notification/features/fcm_service.dart';
import 'package:banjarabio/notification/features/local_notification_service.dart';
import 'package:banjarabio/notification/features/notification_navigator.dart';
import 'package:banjarabio/notification/features/notification_batcher.dart';
import 'package:banjarabio/notification/features/notification_personalizer.dart';
import 'package:banjarabio/notification/features/smart_delivery_gate.dart';
import 'package:banjarabio/notification/features/omni_channel_orchestrator.dart';
import 'package:banjarabio/notification/core/notification_history.dart';
import 'package:banjarabio/notification/core/notification_payload.dart';
import 'package:banjarabio/notification/widgets/in_app_notification_overlay.dart';

/// The Bridge orchestrates interaction between FCM (Push) and Local Notification (UI).
///
/// It ensures that foreground push notifications are shown as local alerts,
/// and provides a user-friendly permission request flow.
class NotificationBridge {
  static final NotificationBridge _instance = NotificationBridge._internal();
  factory NotificationBridge() => _instance;
  NotificationBridge._internal();

  final FCMService _fcm = FCMService();
  final LocalNotificationService _local = LocalNotificationService();
  final NotificationNavigator _navigator = NotificationNavigator();
  final NotificationHistoryStore _historyStore = NotificationHistoryStore();
  final InAppNotificationOverlay _overlay = InAppNotificationOverlay();

  // Phase 3: Smart Logic Pipeline
  final NotificationBatcher _batcher = NotificationBatcher();
  final NotificationPersonalizer _personalizer = NotificationPersonalizer();
  final SmartDeliveryGate _gate = SmartDeliveryGate();

  // Phase 4: Omni-channel Delivery
  final OmniChannelOrchestrator _omni = OmniChannelOrchestrator();

  /// Global navigator key for showing overlays from anywhere.
  GlobalKey<NavigatorState>? _navigatorKey;

  /// Set the navigator key for overlay support.
  void setNavigatorKey(GlobalKey<NavigatorState> key) {
    _navigatorKey = key;
  }

  /// Access the history store for the Activity Hub.
  NotificationHistoryStore get historyStore => _historyStore;

  bool _initialized = false;
  StreamSubscription? _fcmSubscription;
  StreamSubscription? _fcmTapSubscription;
  StreamSubscription? _localTapSubscription;

  static const _prefKeyPermissionAsked = 'notification_permission_asked';

  Future<void> initialize() async {
    if (_initialized) return;
    _initialized = true;

    debugPrint('🌉 [NotificationBridge] Starting orchestration...');

    // 1. Initialize underlying services
    await _local.initialize();
    await _fcm.initialize();
    _omni.initialize();

    // 2. Wire batcher callback — when a batch is ready, deliver it
    _batcher.onBatchReady = (batchedPayload) {
      _deliverNotification(batchedPayload);
    };

    // 3. Map Foreground FCM → Personalizer → Gate → Batcher → Delivery
    _fcmSubscription = _fcm.onMessage.listen((rawPayload) async {
      debugPrint('🌉 [Bridge] Smart pipeline processing...');

      // Step A: Personalize content
      final personalized = _personalizer.personalize(rawPayload);

      // Step B: Check delivery gate (quiet hours, category, rate limit)
      final shouldDeliver = await _gate.shouldDeliver(personalized);
      if (!shouldDeliver) return;

      // Step C: Try batching (returns true if batched/deferred)
      final wasBatched = _batcher.add(personalized);
      if (wasBatched) return; // Will be delivered when batch flushes

      // Step D: Immediate delivery for non-batchable notifications
      _deliverNotification(personalized);
    });

    // 4. Handle Taps from FCM (Background/Terminated/Foreground)
    _fcmTapSubscription = _fcm.onMessageOpenedApp.listen((payload) {
      // Cancel escalation — user saw the notification
      if (payload.id != null) _omni.onNotificationSeen(payload.id!);
      _navigator.handleNotificationTap(payload);
    });

    // 5. Handle Taps from Local UI (Foreground alerts)
    _localTapSubscription = _local.onNotificationTap.listen((payload) {
      // Cancel escalation — user saw the notification
      if (payload.id != null) _omni.onNotificationSeen(payload.id!);
      _navigator.handleNotificationTap(payload);
    });
  }

  /// Centralized delivery: System tray + Overlay + History + OmniTrack.
  void _deliverNotification(NotificationPayload payload) {
    // a) System tray notification
    _local.show(payload);

    // b) In-app overlay (Zomato-style)
    final ctx = _navigatorKey?.currentContext;
    if (ctx != null) {
      _overlay.show(
        context: ctx,
        payload: payload,
        onTap: () => _navigator.handleNotificationTap(payload),
      );
    }

    // c) Store in Activity Hub history
    _historyStore.add(NotificationItem(
      id: payload.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
      title: payload.title ?? '',
      body: payload.body ?? '',
      imageUrl: payload.imageUrl,
      route: payload.route,
      category: payload.category.name,
      createdAt: DateTime.now(),
    ));

    // d) Track for omni-channel fallback (Push → WhatsApp → SMS)
    _omni.trackPushDelivery(payload);
  }

  /// Request permissions across both services.
  /// Returns true if granted.
  Future<bool> requestPermissions() async {
    final fcmGranted = await _fcm.requestPermission();
    final localGranted = await _local.requestPermission();

    debugPrint(
        '🌉 [NotificationBridge] Permissions — FCM: $fcmGranted, Local: $localGranted');
    return fcmGranted && localGranted;
  }

  /// Shows a pre-permission dialog explaining the value of notifications,
  /// THEN triggers the actual system permission request.
  ///
  /// This "interstitial" pattern increases opt-in rates by 30-50% compared
  /// to just showing the raw system dialog.
  ///
  /// Only shows once per install (tracked via SharedPreferences).
  Future<void> askPermissionInterstitially(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    final alreadyAsked = prefs.getBool(_prefKeyPermissionAsked) ?? false;

    if (alreadyAsked) return;

    if (!context.mounted) return;

    final shouldAsk = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.red.shade50,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Text('💍', style: TextStyle(fontSize: 24)),
            ),
            const SizedBox(width: 12),
            const Expanded(
              child: Text(
                'Never Miss a Match!',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _PermissionBenefit(
              icon: '❤️',
              text: 'Instant alerts when someone shows interest',
            ),
            SizedBox(height: 12),
            _PermissionBenefit(
              icon: '💬',
              text: 'Never miss a message from your match',
            ),
            SizedBox(height: 12),
            _PermissionBenefit(
              icon: '⭐',
              text: 'Get notified about compatible profiles',
            ),
            SizedBox(height: 16),
            Text(
              'You can change this anytime in Settings.',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Not Now',
                style: TextStyle(color: Colors.grey)),
          ),
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            style: FilledButton.styleFrom(
              backgroundColor: const Color(0xFFC94B4B),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text('Enable Notifications'),
          ),
        ],
      ),
    );

    // Mark as asked regardless of user choice
    await prefs.setBool(_prefKeyPermissionAsked, true);

    if (shouldAsk == true) {
      await requestPermissions();
    }
  }

  void dispose() {
    _fcmSubscription?.cancel();
    _fcmTapSubscription?.cancel();
    _localTapSubscription?.cancel();
    _batcher.dispose();
    _fcm.dispose();
    _local.dispose();
    _initialized = false;
  }
}

/// Small widget for the permission explanation dialog.
class _PermissionBenefit extends StatelessWidget {
  final String icon;
  final String text;

  const _PermissionBenefit({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(icon, style: const TextStyle(fontSize: 20)),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(fontSize: 14, height: 1.3),
          ),
        ),
      ],
    );
  }
}
