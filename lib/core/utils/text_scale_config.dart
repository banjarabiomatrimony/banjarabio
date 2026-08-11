import 'package:flutter/material.dart';

/// Centralized configuration for the app's text scaling behavior.
/// This respects device accessibility text-scaling preferences (Android/iOS phone settings)
/// but applies safe upper/lower boundaries (0.8x to 1.3x) to protect layout integrity
/// from breaking under extreme sizes.
class TextScaleConfig {
  /// The maximum allowed text scale factor (1.3x).
  static const double maxScaleFactor = 1.3;

  /// The minimum allowed text scale factor (0.8x).
  static const double minScaleFactor = 0.8;

  /// Returns a [TextScaler] that is clamped within the safe range [minScaleFactor, maxScaleFactor].
  static TextScaler getClampedTextScaler(BuildContext context) {
    final mediaQueryData = MediaQuery.of(context);
    // Determine the original scale factor configured in the OS settings.
    final double originalScaleFactor = mediaQueryData.textScaler.scale(10.0) / 10.0;
    // Clamp it to be between minScaleFactor and maxScaleFactor
    final double clampedFactor = originalScaleFactor.clamp(minScaleFactor, maxScaleFactor);
    return TextScaler.linear(clampedFactor);
  }
}
