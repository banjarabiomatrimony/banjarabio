import 'package:flutter/material.dart';
import 'package:banjarabio/core/app_export.dart';
import 'package:banjarabio/core/services/global_watchdog.dart';
import 'package:banjarabio/core/init/startup_tasks.dart';
import 'package:banjarabio/core/init/error_handling.dart';
import 'package:banjarabio/core/init/system_chrome_config.dart';

/// Top-level initialization orchestrator for BanjaraBio.
///
/// Called once from `main()` before `runApp()`. Delegates to
/// purpose-specific modules so each concern can be profiled
/// and tested in isolation.
class AppInitializer {
  AppInitializer._();

  /// Run all pre-runApp initialization in the correct order.
  ///
  /// Execution order:
  /// 1. Disable runtime font fetching (synchronous)
  /// 2. Start global watchdog (main-thread health monitor)
  /// 3. Register all phased startup tasks
  /// 4. Set image cache limits for low-end devices
  /// 5. Install custom error widget
  /// 6. Configure system chrome (edge-to-edge, orientation)
  static void initialize() {
    // 🚀 Disable GoogleFonts runtime fetching (use local bundled fonts)
    GoogleFonts.config.allowRuntimeFetching = false;

    // 🛡️ Global Watchdog monitors the main thread immediately
    GlobalWatchdog().initialize();

    // 🚀 Register all phased startup tasks with the orchestrator
    StartupTasks.registerAll();

    // 🚨 SIGNAL 3 FIX: Strict image cache limits for low-end devices
    PaintingBinding.instance.imageCache.maximumSize = 50;
    PaintingBinding.instance.imageCache.maximumSizeBytes = 20 << 20; // 20MB

    // 🚨 Custom error handling (Crashlytics + debounced error widget)
    ErrorHandlingConfig.configure();

    // 📱 System chrome (edge-to-edge, transparent bars, portrait lock)
    SystemChromeConfig.configure();
  }
}
