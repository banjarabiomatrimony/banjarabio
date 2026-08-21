import 'dart:convert';

import 'package:sentry_flutter/sentry_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sizer/sizer.dart';

import 'package:banjarabio/core/app_export.dart';
import 'package:banjarabio/core/init/app_initializer.dart';
import 'package:banjarabio/core/init/app_navigator_key.dart';
import 'package:banjarabio/core/providers/locale_provider.dart';
import 'package:banjarabio/core/services/deep_link_service.dart';
import 'package:banjarabio/core/services/app_logger.dart';
import 'package:banjarabio/core/utils/text_scale_config.dart';
import 'package:banjarabio/l10n/app_localizations.dart';
import 'package:banjarabio/services/ads/app_open_ad_manager.dart';

import 'package:banjarabio/core/init/system_chrome_config.dart';
import 'package:banjarabio/core/config/sentry_config.dart';

void main() async {
  // 🚀 Use SentryWidgetsFlutterBinding to enable FramesTrackingIntegration.
  // This hooks into Flutter's rendering pipeline from the earliest point,
  // allowing Sentry to capture frame-level performance metrics (slow/frozen).
  SentryWidgetsFlutterBinding.ensureInitialized();

  // ── Load environment config for dynamic Sentry DSN ──────────────────
  // Must happen before SentryFlutter.init so the SDK knows whether to
  // transmit envelopes or run in disabled (no-op) mode.
  try {
    final envString = await rootBundle.loadString('assets/env.json');
    final envMap = json.decode(envString) as Map<String, dynamic>;
    SentryConfig.load(envMap);
  } catch (e) {
    AppLogger.warn('main', '⚠️ Could not load env.json for Sentry config: $e');
    // SentryConfig defaults to disabled (empty DSN) — safe to continue.
  }

  // Single call replaces ~180 lines of inline initialization.
  // See lib/core/init/ for details.
  AppInitializer.initialize();

  // 🚀 Run app IMMEDIATELY — first frame renders within ~100ms.
  // All heavy initialization now runs inside the splash screen.
  await SentryFlutter.init(
    (options) {
      options.dsn = SentryConfig.dsn;
      options.tracesSampleRate = SentryConfig.tracesSampleRate;
      options.debug = SentryConfig.debug;

      // Attach environment tag for Sentry dashboard filtering
      options.environment = 'production';
    },
    appRunner: () => runApp(const MyApp()),
  );
}


// 🚨 CRITICAL: DO NOT use timed markBackground/markIdle here!
// Previously: Future.delayed(5s, markBackground) → raced with BOOTING (5.2s)
// in splash screen, advancing orchestrator to BACKGROUND (index 4) and
// silently skipping CRITICAL (index 2). Supabase/Firebase never initialized!
// The BACKGROUND/IDLE phases are now advanced properly from
// startup_workflow.dart after INTERACTIVE completes.

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> with WidgetsBindingObserver {
  late AppOpenAdManager _appOpenAdManager;
  bool _hasBeenResumed = false; // Track if app has been to background at least once

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _appOpenAdManager = AppOpenAdManager();

    // 🚨 CRITICAL ANR FIX: All heavy background tasks moved to IDLE phase (20s)
    // in startup_tasks.dart / startup_workflow.dart. This includes:
    // - Firebase / AppCheck / Crashlytics
    // - NotificationBridge (FCM background engine)
    // - IsolateManager (compute worker)
    // - Analytics / Install Notifications

    // Initialize Deep Link Service
    DeepLinkService().init(navigatorKey);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      // Only show AppOpen ad on RESUME, never on first cold launch.
      // The first cold launch has native layer initialization that conflicts with WebView.
      if (_hasBeenResumed && !SessionManager.instance.isPremium) {
        _appOpenAdManager.showAdIfAvailable();
      }
    } else if (state == AppLifecycleState.paused) {
      _hasBeenResumed = true;
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    DeepLinkService().dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Sizer(
      builder: (context, orientation, screenType) {
        return ProviderScope(
          child: Consumer(
            builder: (context, ref, _) {
              final locale = ref.watch(localeProvider);
              return MaterialApp(
                title: 'BanjaraBio',
                navigatorKey: navigatorKey,
                theme: AppTheme.lightTheme,
                darkTheme: AppTheme.darkTheme,
                themeMode: ThemeMode.light,
                // --- Localization ---
                localizationsDelegates: const [
                  AppLocalizations.delegate,
                  GlobalMaterialLocalizations.delegate,
                  GlobalWidgetsLocalizations.delegate,
                  GlobalCupertinoLocalizations.delegate,
                ],
                supportedLocales: appSupportedLocales,
                locale: locale, // null = auto from device
                // --- End Localization ---
                // 🚨 CRITICAL: NEVER REMOVE OR MODIFY
                builder: (context, child) {
                  // 🩺 L10n health check — debug only, zero cost in release
                  assert(() {
                    if (AppLocalizations.of(context) == null) {
                      debugPrint('🔴 CRITICAL: AppLocalizations delegate failed to load! '
                          'UI will fall back to English hardcoded strings.');
                    }
                    return true;
                  }());

                  final double screenWidth = MediaQuery.of(context).size.width;
                  final bool isLargeScreen = screenWidth > 600;
                  SystemChromeConfig.adaptOrientationForScreen(context);

                  return MediaQuery(
                    data: MediaQuery.of(context).copyWith(
                      textScaler: TextScaleConfig.getClampedTextScaler(context),
                    ),
                    child: Center(
                      child: ConstrainedBox(
                        constraints: BoxConstraints(
                          maxWidth: isLargeScreen ? 600 : double.infinity,
                        ),
                        child: child!,
                      ),
                    ),
                  );
                },
                // 🚨 END CRITICAL SECTION
                debugShowCheckedModeBanner: false,
                onGenerateRoute: AppRoutes.onGenerateRoute,
                initialRoute: AppRoutes.initial, // Always start with splash
              );
            },
          ),
        );
      },
    );
  }
}
