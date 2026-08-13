// test/unit/backend_response_auth_test.dart
// Tests BackendResponse behavior specifically in auth-related scenarios:
// fold, retry, map, and error handling patterns used throughout auth flows.

import 'package:flutter_test/flutter_test.dart';
import 'package:banjarabio/core/models/backend_response.dart';
import 'package:banjarabio/core/services/telemetry_service.dart';

import '../helpers/mock_services.dart';

void main() {
  setUp(() {
    TelemetryService.instance = NoOpTelemetryService();
  });

  tearDown(() {
    TelemetryService.instance = TelemetryService.internal();
  });

  // ═══════════════════════════════════════════════════════════════════════════
  // 1. Auth-specific Success Patterns
  // ═══════════════════════════════════════════════════════════════════════════
  group('Auth success patterns', () {
    test('signInWithEmail success pattern: BackendResponse<bool>.success(true)', () {
      final result = BackendResponse<bool>.success(true);

      String route = '';
      result.fold(
        onSuccess: (success) => route = success ? '/home' : '/auth',
        onFailure: (error) => route = '/error',
      );

      expect(route, '/home');
    });

    test('signInWithEmail partial success: user not found', () {
      final result = BackendResponse<bool>.success(false);

      String route = '';
      result.fold(
        onSuccess: (success) => route = success ? '/home' : '/auth',
        onFailure: (error) => route = '/error',
      );

      expect(route, '/auth');
    });

    test('signInWithPhone success: void response', () {
      final result = BackendResponse<void>.success(null);

      expect(result.isSuccess, true);
    });
  });

  // ═══════════════════════════════════════════════════════════════════════════
  // 2. Auth Failure Patterns
  // ═══════════════════════════════════════════════════════════════════════════
  group('Auth failure patterns', () {
    test('invalid credentials error message', () {
      final result = BackendResponse<bool>.failure('Invalid login credentials');

      String errorMsg = '';
      result.fold(
        onSuccess: (_) {},
        onFailure: (error) => errorMsg = error,
      );

      expect(errorMsg, contains('Invalid login credentials'));
    });

    test('network error with retry', () async {
      int retryCount = 0;
      final result = BackendResponse<bool>.failure(
        'Network error',
        onRetry: () async {
          retryCount++;
          return BackendResponse<bool>.success(true);
        },
      );

      expect(result.onRetry, isNotNull);
      
      final retried = await result.retry();
      expect(retried.isSuccess, true);
      expect(retryCount, 1);
    });

    test('accessing data on failure throws', () {
      final result = BackendResponse<bool>.failure('auth error');

      expect(() => result.data, throwsException);
    });
  });

  // ═══════════════════════════════════════════════════════════════════════════
  // 3. Auth Response Chain (map)
  // ═══════════════════════════════════════════════════════════════════════════
  group('Auth response chaining', () {
    test('map success to navigation route', () {
      final authResult = BackendResponse<bool>.success(true);
      final routeResult = authResult.map((success) => success ? '/home' : '/auth');

      expect(routeResult.isSuccess, true);
      expect(routeResult.data, '/home');
    });

    test('map failure propagates error', () {
      final authResult = BackendResponse<bool>.failure('session expired');
      final routeResult = authResult.map((success) => '/home');

      expect(routeResult.isSuccess, false);
      expect(routeResult.errorMessage, contains('session expired'));
    });
  });

  // ═══════════════════════════════════════════════════════════════════════════
  // 4. Edge Cases in Auth Context
  // ═══════════════════════════════════════════════════════════════════════════
  group('Auth edge cases', () {
    test('loading state is treated as non-success', () {
      final result = BackendResponse<bool>.loading();
      expect(result.isSuccess, false);
    });

    test('retry returns self when no retry callback', () async {
      final result = BackendResponse<bool>.failure('no retry');
      final retried = await result.retry();

      // Same object returned
      expect(identical(result, retried), true);
    });
  });
}
