// test/helpers/mock_services.dart
// Lightweight mock classes for services used in widget and unit tests.

import 'package:mocktail/mocktail.dart';
import 'package:banjarabio/core/services/local_cache_service.dart';
import 'package:banjarabio/core/services/telemetry_service.dart';

/// Mock for LocalCacheService — inject via `testBoxOpener`.
class MockLocalCacheService extends Mock implements LocalCacheService {}

/// No-op TelemetryService to prevent BackendResponse.failure from crashing.
class NoOpTelemetryService extends TelemetryService {
  NoOpTelemetryService() : super.internal();
  @override
  void logError(dynamic error, {StackTrace? stackTrace, String? reason}) {
    // No-op in tests
  }

  @override
  void logEvent(String name, {Map<String, dynamic>? parameters}) {
    // No-op in tests
  }

  @override
  void logBreadcrumb(String message,
      {String? category, Map<String, dynamic>? data}) {
    // No-op in tests
  }
}
