import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Configures system-level UI chrome settings.
///
/// Extracted from main.dart for independent testing and per-device
/// customization at scale (e.g. different configs for tablets).
class SystemChromeConfig {
  SystemChromeConfig._();

  /// Configure modern edge-to-edge display (Android 15+ compliant) without
  /// deprecated setStatusBarColor / setNavigationBarColor APIs.
  static void configure() {
    // Modern edge-to-edge display (Android 15+)
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarIconBrightness: Brightness.dark,
        statusBarBrightness: Brightness.light,
        systemNavigationBarIconBrightness: Brightness.dark,
      ),
    );

    // Initial safe portrait orientation for smartphones
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  }

  /// Adapt screen orientations conditionally:
  /// - Smartphones (shortestSide < 600dp): Strictly locked to portraitUp.
  /// - Tablets / Large Screens / Foldables (shortestSide >= 600dp): Allow rotation.
  static void adaptOrientationForScreen(BuildContext context) {
    final double shortestSide = MediaQuery.of(context).size.shortestSide;
    if (shortestSide >= 600) {
      SystemChrome.setPreferredOrientations([
        DeviceOrientation.portraitUp,
        DeviceOrientation.portraitDown,
        DeviceOrientation.landscapeLeft,
        DeviceOrientation.landscapeRight,
      ]);
    } else {
      SystemChrome.setPreferredOrientations([
        DeviceOrientation.portraitUp,
      ]);
    }
  }
}

