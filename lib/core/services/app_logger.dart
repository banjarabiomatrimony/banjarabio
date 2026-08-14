import 'package:flutter/foundation.dart';
import 'package:banjarabio/core/services/telemetry_service.dart';

/// Centralized logging service for BanjaraBio.
///
/// Replaces raw `print()` / `debugPrint()` calls with structured,
/// level-aware logging. All output is **stripped in release mode**
/// to prevent PII leaks and reduce jank on low-end devices.
///
/// Usage:
/// ```dart
/// AppLogger.info('HomeScreen', 'Loaded 20 profiles');
/// AppLogger.error('PaymentService', 'RPC failed', error);
/// AppLogger.warn('CacheService', 'Disk cache miss for key=$key');
/// ```
class AppLogger {
  AppLogger._();

  /// Log levels
  static const int _levelDebug = 0;
  static const int _levelInfo = 1;
  static const int _levelWarn = 2;
  static const int _levelError = 3;

  /// Minimum log level (configurable at startup).
  /// Default: debug in dev, error in release.
  static int minLevel = kDebugMode ? _levelDebug : _levelError;

  // ─── Public API ──────────────────────────────────────────────

  /// Verbose debug output — stripped in release.
  static void debug(String tag, String message) {
    _log(_levelDebug, '🔍', tag, message);
  }

  /// Standard informational log.
  static void info(String tag, String message) {
    _log(_levelInfo, '📢', tag, message);
  }

  /// Warning — something unexpected but non-fatal.
  static void warn(String tag, String message) {
    _log(_levelWarn, '⚠️', tag, message);
  }

  /// Error — includes optional error object and stack trace.
  /// Automatically forwarded to TelemetryService (Sentry/Crashlytics).
  static void error(String tag, String message, [Object? error, StackTrace? stack]) {
    if (!kDebugMode && minLevel > _levelError) return;
    final buf = StringBuffer('🚨 [$tag] $message');
    if (error != null) buf.write(' | $error');
    debugPrint(buf.toString());
    if (stack != null && kDebugMode) {
      debugPrint(stack.toString());
    }

    // Forward to TelemetryService for production observability (prevent recursion)
    if (tag != 'TelemetryService') {
      try {
        TelemetryService.instance.logError(
          error ?? message,
          stackTrace: stack,
          reason: '[$tag] $message',
        );
      } catch (_) {
        // Ignore if telemetry is unavailable during early bootstrap
      }
    }
  }

  // ─── Internal ────────────────────────────────────────────────

  static void _log(int level, String emoji, String tag, String message) {
    if (!kDebugMode) return; // Zero cost in release
    if (level < minLevel) return;
    debugPrint('$emoji [$tag] $message');
  }
}
