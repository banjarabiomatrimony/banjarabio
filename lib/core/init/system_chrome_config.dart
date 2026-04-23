import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Configures system-level UI chrome settings.
///
/// Extracted from main.dart for independent testing and per-device
/// customization at scale (e.g. different configs for tablets).
class SystemChromeConfig {
  SystemChromeConfig._();

  /// Configure edge-to-edge display, transparent system bars, and portrait lock.
  static void configure() {
    // Modern edge-to-edge display (Android 15+)
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        systemNavigationBarColor: Colors.transparent,
        systemNavigationBarDividerColor: Colors.transparent,
      ),
    );

    // Portrait-only orientation (non-blocking)
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  }
}
