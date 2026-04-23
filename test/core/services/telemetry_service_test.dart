import 'package:flutter_test/flutter_test.dart';
import 'package:banjarabio/core/services/telemetry_service.dart';

void main() {
  group('TelemetryService', () {
    late TelemetryService service;

    setUp(() {
      service = TelemetryService();
    });

    test('is a singleton', () {
      final a = TelemetryService();
      final b = TelemetryService();

      expect(identical(a, b), true);
    });

    test('logError does not throw', () {
      expect(
        () => service.logError('test error'),
        returnsNormally,
      );
    });

    test('logError with stackTrace does not throw', () {
      expect(
        () => service.logError('test error', stackTrace: StackTrace.current),
        returnsNormally,
      );
    });

    test('logError with reason does not throw', () {
      expect(
        () => service.logError('test error', reason: 'test context'),
        returnsNormally,
      );
    });

    test('logEvent does not throw', () {
      expect(
        () => service.logEvent('test_event'),
        returnsNormally,
      );
    });

    test('logEvent with parameters does not throw', () {
      expect(
        () => service.logEvent('test_event', parameters: {'key': 'value'}),
        returnsNormally,
      );
    });

    test('logBreadcrumb does not throw', () {
      expect(
        () => service.logBreadcrumb('test breadcrumb'),
        returnsNormally,
      );
    });

    test('logBreadcrumb with category and data does not throw', () {
      expect(
        () => service.logBreadcrumb(
          'test breadcrumb',
          category: 'navigation',
          data: {'screen': 'home'},
        ),
        returnsNormally,
      );
    });
  });
}
