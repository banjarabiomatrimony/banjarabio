import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import 'package:banjarabio/widgets/custom_error_widget.dart';

/// Configures global error handling for the app.
///
/// Extracted from main.dart so error strategies (Crashlytics, Sentry, custom)
/// can be swapped or A/B tested independently.
class ErrorHandlingConfig {
  ErrorHandlingConfig._();

  static bool _hasShownError = false;

  /// Install the custom [ErrorWidget.builder] that:
  /// 1. Records non-fatal UI errors to Crashlytics (if initialized).
  /// 2. Records non-fatal UI errors to Sentry.
  /// 3. Shows a user-friendly error widget (debounced to 1 per 5 seconds).
  static void configure() {
    ErrorWidget.builder = (FlutterErrorDetails details) {
      // Record non-fatal UI errors to Crashlytics.
      // Crashlytics may not be initialized yet during splash — guard with try-catch.
      try {
        if (Firebase.apps.isNotEmpty) {
          FirebaseCrashlytics.instance.recordFlutterError(details);
        }
      } catch (_) {}

      // 🚀 Record non-fatal UI errors to Sentry.
      try {
        Sentry.captureException(
          details.exception,
          stackTrace: details.stack,
        );
      } catch (_) {}

      if (!_hasShownError) {
        _hasShownError = true;
        Future.delayed(const Duration(seconds: 5), () {
          _hasShownError = false;
        });
        return CustomErrorWidget(errorDetails: details);
      }
      return const SizedBox.shrink();
    };
  }
}
