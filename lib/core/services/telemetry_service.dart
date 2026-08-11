import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:sentry_flutter/sentry_flutter.dart';
import 'package:banjarabio/core/services/app_logger.dart';

/// A singleton service to handle centralized logging and error reporting.
/// This can be easily connected to Sentry, Firebase Crashlytics, or other telemetry tools.
class TelemetryService {
  static TelemetryService _instance = _initInstance();

  static TelemetryService _initInstance() {
    try {
      if (!kIsWeb && Platform.environment.containsKey('FLUTTER_TEST')) {
        return _NoOpTelemetryService();
      }
    } catch (_) {
      // In case platform/environment check is unsupported
    }
    return TelemetryService.internal();
  }

  factory TelemetryService() {
    return _instance;
  }
  
  static set instance(TelemetryService service) {
    _instance = service;
  }

  TelemetryService.internal();


  /// Log a non-fatal error to telemetry.
  void logError(dynamic error, {StackTrace? stackTrace, String? reason}) {
    // Local debug logging
    AppLogger.error('TelemetryService', '🚨 [TELEMETRY ERROR]: $error');
    AppLogger.error('TelemetryService', '🔍 [ERROR TYPE]: ${error.runtimeType}');
    AppLogger.error('TelemetryService', '🔍 [ERROR DETAILS]: ${error.toString()}');
    if (reason != null) AppLogger.debug('TelemetryService', 'Context: $reason');
    if (stackTrace != null) AppLogger.debug('TelemetryService', stackTrace.toString());

    // 🚀 Route to Sentry SDK for production observability
    try {
      if (error is Exception || error is Error) {
        Sentry.captureException(
          error,
          stackTrace: stackTrace,
          hint: reason != null ? Hint.withMap({'reason': reason}) : null,
        );
      } else {
        Sentry.captureMessage(
          error.toString(),
          level: SentryLevel.error,
        );
      }
    } catch (_) {
      // Sentry may not be initialised yet during early startup — swallow.
    }
  }

  /// Log a business event or user interaction.
  void logEvent(String name, {Map<String, dynamic>? parameters}) {
    AppLogger.debug('TelemetryService', '📊 [TELEMETRY EVENT]: $name');
    if (parameters != null) AppLogger.debug('TelemetryService', 'Params: $parameters');
  }

  /// Add a breadcrumb to the current session (useful for debugging crashes).
  void logBreadcrumb(
    String message, {
    String? category,
    Map<String, dynamic>? data,
  }) {
    AppLogger.debug('TelemetryService', '📍 [BREADCRUMB]: $message');

    // 🚀 Route breadcrumbs to Sentry for crash context
    try {
      Sentry.addBreadcrumb(Breadcrumb(
        message: message,
        category: category,
        data: data,
      ));
    } catch (_) {
      // Sentry may not be initialised yet — swallow.
    }
  }
}

class _NoOpTelemetryService extends TelemetryService {
  _NoOpTelemetryService() : super.internal();

  @override
  void logError(dynamic error, {StackTrace? stackTrace, String? reason}) {}

  @override
  void logEvent(String name, {Map<String, dynamic>? parameters}) {}

  @override
  void logBreadcrumb(String message, {String? category, Map<String, dynamic>? data}) {}
}

