import 'package:flutter/foundation.dart';

/// A singleton service to handle centralized logging and error reporting.
/// This can be easily connected to Sentry, Firebase Crashlytics, or other telemetry tools.
class TelemetryService {
  static TelemetryService _instance = TelemetryService.internal();

  factory TelemetryService() {
    return _instance;
  }
  
  static set instance(TelemetryService service) {
    _instance = service;
  }

  TelemetryService.internal();

  /// Log a non-fatal error to telemetry.
  void logError(dynamic error, {StackTrace? stackTrace, String? reason}) {
    // In production, send to Sentry/Crashlytics
    // for now, we use debugPrint
    debugPrint('🚨 [TELEMETRY ERROR]: $error');
    debugPrint('🔍 [ERROR TYPE]: ${error.runtimeType}');
    debugPrint('🔍 [ERROR DETAILS]: ${error.toString()}');
    if (reason != null) debugPrint('Context: $reason');
    if (stackTrace != null) debugPrint(stackTrace.toString());
  }

  /// Log a business event or user interaction.
  void logEvent(String name, {Map<String, dynamic>? parameters}) {
    debugPrint('📊 [TELEMETRY EVENT]: $name');
    if (parameters != null) debugPrint('Params: $parameters');
  }

  /// Add a breadcrumb to the current session (useful for debugging crashes).
  void logBreadcrumb(
    String message, {
    String? category,
    Map<String, dynamic>? data,
  }) {
    debugPrint('📍 [BREADCRUMB]: $message');
  }
}
