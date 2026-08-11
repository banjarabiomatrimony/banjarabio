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
import 'package:banjarabio/core/services/app_logger.dart';
import 'package:banjarabio/core/theme/app_gradients.dart';

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

    AppLogger.debug('NotificationBridge', '🌉 [NotificationBridge] Starting orchestration...');

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
      AppLogger.debug('NotificationBridge', '🌉 [Bridge] Smart pipeline processing...');

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

    final shouldAsk = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        final theme = Theme.of(ctx);
        return Container(
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.25),
                blurRadius: 30,
                spreadRadius: 5,
                offset: const Offset(0, -5),
              ),
            ],
          ),
          child: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Grab handle
                  Container(
                    width: 44,
                    height: 5,
                    decoration: BoxDecoration(
                      color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.3),
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Animated Bell Header with Glowing Rings
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      Container(
                        width: 90,
                        height: 90,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: theme.colorScheme.primary.withValues(alpha: 0.1),
                        ),
                      ),
                      Container(
                        width: 72,
                        height: 72,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: AppGradients.romance,
                          boxShadow: [
                            BoxShadow(
                              color: theme.colorScheme.primary.withValues(alpha: 0.4),
                              blurRadius: 16,
                              offset: const Offset(0, 6),
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.notifications_active_rounded,
                          size: 36,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Title & Tagline
                  Text(
                    'Stay Connected on BanjaraBio',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: 'Outfit',
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      color: theme.colorScheme.onSurface,
                      letterSpacing: -0.4,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Never miss a verified match, instant message, or profile update.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 13.5,
                      color: theme.colorScheme.onSurfaceVariant,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Feature Cards
                  const _PermissionBenefitTile(
                    icon: Icons.favorite_rounded,
                    iconColor: Color(0xFFE91E63),
                    title: 'Instant Match Alerts',
                    subtitle: 'Get notified immediately when mutual interest is accepted.',
                  ),
                  const SizedBox(height: 12),
                  const _PermissionBenefitTile(
                    icon: Icons.chat_bubble_rounded,
                    iconColor: Color(0xFF009688),
                    title: 'Direct Messages',
                    subtitle: 'Stay responsive when your match sends you a message.',
                  ),
                  const SizedBox(height: 12),
                  const _PermissionBenefitTile(
                    icon: Icons.auto_awesome_rounded,
                    iconColor: Color(0xFFFF9800),
                    title: 'Smart Recommendations',
                    subtitle: 'Receive curated bio recommendations tailored for you.',
                  ),
                  const SizedBox(height: 18),

                  // Strict Privacy Box
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: theme.colorScheme.outlineVariant.withValues(alpha: 0.5),
                      ),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(
                          Icons.lock_outline_rounded,
                          size: 18,
                          color: Colors.green,
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            '100% Strict Privacy: Bookmarks & profile views are completely private and never triggered as notifications.',
                            style: TextStyle(
                              fontSize: 11.5,
                              fontWeight: FontWeight.w500,
                              color: theme.colorScheme.onSurfaceVariant,
                              height: 1.35,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // CTA Buttons
                  Container(
                    width: double.infinity,
                    height: 52,
                    decoration: BoxDecoration(
                      gradient: AppGradients.romance,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: theme.colorScheme.primary.withValues(alpha: 0.35),
                          blurRadius: 12,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: ElevatedButton(
                      onPressed: () => Navigator.of(ctx).pop(true),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        shadowColor: Colors.transparent,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.notifications_active_rounded, color: Colors.white, size: 20),
                          SizedBox(width: 8),
                          Text(
                            'Enable Notifications',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),

                  TextButton(
                    onPressed: () => Navigator.of(ctx).pop(false),
                    style: TextButton.styleFrom(
                      minimumSize: const Size(double.infinity, 44),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: Text(
                      'Maybe Later',
                      style: TextStyle(
                        fontSize: 14.5,
                        fontWeight: FontWeight.w600,
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
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

/// Upgraded benefit tile widget for notification permission screen.
class _PermissionBenefitTile extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String subtitle;

  const _PermissionBenefitTile({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: theme.colorScheme.outlineVariant.withValues(alpha: 0.4),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              size: 22,
              color: iconColor,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 12,
                    color: theme.colorScheme.onSurfaceVariant,
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
