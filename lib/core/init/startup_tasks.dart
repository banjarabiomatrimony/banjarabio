import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:firebase_performance/firebase_performance.dart';
import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:firebase_core/firebase_core.dart';

import 'package:banjarabio/core/config/banjara_billing_config.dart';
import 'package:banjarabio/core/supabase_client.dart';
import 'package:banjarabio/core/update_ecosystem/update_ecosystem.dart';
import 'package:banjarabio/shared/billing/razorpay_billing_registry.dart';
import 'package:banjarabio/core/app_export.dart';
import 'package:banjarabio/core/services/local_cache_service.dart';
import 'package:banjarabio/core/services/performance_service.dart';
import 'package:banjarabio/core/services/isolate_manager.dart';
import 'package:banjarabio/core/services/startup_orchestrator.dart';
import 'package:banjarabio/core/services/image_compression_service.dart';
import 'package:banjarabio/core/services/app_logo_service.dart';
import 'package:banjarabio/core/services/analytics_service.dart';
import 'package:banjarabio/core/init/app_navigator_key.dart';
import 'package:banjarabio/firebase_options.dart';
import 'package:banjarabio/notification/features/notification_bridge.dart';
import 'package:banjarabio/notification/features/admin_notification_service.dart';
import 'package:banjarabio/services/ads/ad_service.dart';
import 'package:banjarabio/services/ads/app_open_ad_manager.dart';
import 'package:banjarabio/core/services/app_logger.dart';
import 'package:banjarabio/core/services/read_replica_client.dart';
import 'package:banjarabio/core/services/shader_warmup_service.dart';

/// Registers all phased startup tasks with the [StartupOrchestrator].
///
/// Each method corresponds to a lifecycle phase and is independently
/// testable and profilable. At 10M+ DAU, this separation enables
/// A/B testing different init strategies per device tier.
class StartupTasks {
  StartupTasks._();

  /// Register all tasks in the correct phase order.
  static void registerAll() {
    _registerBootingTasks();
    _registerCriticalTasks();
    _registerBackgroundTasks();
    _registerIdleHeavyTasks();
    _registerIdleFirebaseTasks();
  }

  // ─── BOOTING: Hive DB + Session + Shader Warm-up (required for navigation) ───

  static void _registerBootingTasks() {
    StartupOrchestrator().registerTask(StartupPhase.booting, () async {
      await Hive.initFlutter();
      await LocalCacheService().init();
      PerformanceService().initialize();
      await SessionManager.instance.init();
      // 🚀 Pre-warm Impeller/Skia shader pipelines & typography during splash window
      ShaderWarmupService().warmUp();
    }, name: 'Core DB, Session & Shader Warmup');
  }

  // ─── CRITICAL: Supabase (required for auth check) ──────────────────────

  static void _registerCriticalTasks() {
    StartupOrchestrator().registerTask(StartupPhase.critical, () async {
      try {
        await ReadReplicaClient.initialize();
        await AppSupabaseClient.initialize();

        // 🚀 Initialize Universal In-App Update Ecosystem
        await AppUpdateManager.instance.initialize(
          config: const AppUpdateConfig(
            source: SupabaseUpdateSource(),
          ),
        );
      } catch (e) {
        if (kDebugMode) AppLogger.error('StartupTasks', 'Failed to initialize Supabase / Update Ecosystem: $e');
      }
    }, name: 'Supabase & Update Init');
  }

  // ─── BACKGROUND: Lightweight warm-ups (8s after interactive) ───────────

  static void _registerBackgroundTasks() {
    StartupOrchestrator().registerTask(StartupPhase.background, () async {
      AppLogoService.instance.warmUp();
      PerformanceService().initialize();
      // Initialize AdMob SDK early in background so it's ready when user arrives at feed
      AppLogger.debug('StartupTasks', 'Ads: [ORCHESTRATOR] Initializing AdMob SDK in background phase...');
      await AdMobService.initialize();
    }, name: 'Background Warm-up & Ads');
  }

  // ─── IDLE (Heavy): Isolate + Image cleanup (20s after interactive) ─────

  static void _registerIdleHeavyTasks() {
    StartupOrchestrator().registerTask(StartupPhase.idle, () async {
      await IsolateManager.instance.init();
      ImageCompressionService().cleanupOldFiles();
    }, name: 'Deferred Heavy Init');
  }

  // ─── IDLE (Firebase): Firebase + Billing + Ads + Notifications ─────────

  static void _registerIdleFirebaseTasks() {
    StartupOrchestrator().registerTask(StartupPhase.idle, () async {
      try {
        // Razorpay billing config
        RazorpayBillingRegistry.register(BanjaraBillingConfig());

        // Firebase (heavy native library loading)
        await Firebase.initializeApp(
          options: DefaultFirebaseOptions.currentPlatform,
        );
        // 🧊 YIELD: Allow UI thread to breathe after native Firebase init
        await Future.delayed(const Duration(milliseconds: 300));

        // App Check
        await FirebaseAppCheck.instance.activate(
          androidProvider: kDebugMode
              ? AndroidProvider.debug
              : AndroidProvider.playIntegrity,
          appleProvider: AppleProvider.appAttest,
        );

        // Crashlytics error handlers (chained with Sentry to prevent overwriting)
        final originalOnError = FlutterError.onError;
        FlutterError.onError = (FlutterErrorDetails details) {
          FirebaseCrashlytics.instance.recordFlutterFatalError(details);
          originalOnError?.call(details);
        };
        
        final originalPlatformOnError = PlatformDispatcher.instance.onError;
        PlatformDispatcher.instance.onError = (Object error, StackTrace stack) {
          FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
          return originalPlatformOnError?.call(error, stack) ?? true;
        };

        // 🧊 YIELD: Native Crashlytics / AppCheck can be heavy on MediaTek
        await Future.delayed(const Duration(milliseconds: 300));

        // Notifications
        NotificationBridge().setNavigatorKey(navigatorKey);
        NotificationBridge().initialize();

        // 🧊 YIELD: Notification isolate spawning is memory-intensive
        await Future.delayed(const Duration(milliseconds: 500));

        // Analytics
        AnalyticsService.logAppOpen();

        // Install notification (fire once)
        if (!SessionManager.instance.hasNotifiedInstall) {
          final platform = defaultTargetPlatform == TargetPlatform.iOS
              ? 'iOS'
              : defaultTargetPlatform == TargetPlatform.android
                  ? 'Android'
                  : 'Other';
          AdminNotificationService().notifyAppInstall(platform: platform);
          SessionManager.instance.setHasNotifiedInstall(true);
        }

        // 🧊 YIELD: Network requests + Analytics settling
        await Future.delayed(const Duration(milliseconds: 300));

        // Performance monitoring
        await FirebasePerformance.instance
            .setPerformanceCollectionEnabled(!kDebugMode);

        // AdMob SDK
        AppLogger.debug('StartupTasks', 'Ads: [ORCHESTRATOR] Initializing AdMob SDK...');
        await AdMobService.initialize();

        // Pre-load AppOpen ad
        if (navigatorKey.currentState?.mounted ?? false) {
          AppOpenAdManager().loadAd();
        }
      } catch (e) {
        if (kDebugMode) {
          AppLogger.error('StartupTasks', 'Failed to initialize Firebase/Analytics/Ads: $e');
        }
      }
    }, name: 'Firebase & Billing');
  }
}
