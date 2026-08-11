import 'package:flutter_test/flutter_test.dart';
import 'package:banjarabio/core/models/backend_response.dart';
import 'package:banjarabio/core/services/telemetry_service.dart';
import '../helpers/mock_services.dart';

void main() {
  setUpAll(() {
    TelemetryService.instance = NoOpTelemetryService();
  });

  tearDownAll(() {
    TelemetryService.instance = TelemetryService.internal();
  });

  group('BackendResponse.success', () {
    test('isSuccess is true', () {
      final response = BackendResponse.success('data');
      expect(response.isSuccess, true);
    });

    test('data accessor returns value', () {
      final response = BackendResponse.success(42);
      expect(response.data, 42);
    });

    test('works with complex types', () {
      final response = BackendResponse.success({'key': 'value'});
      expect(response.data, isA<Map<String, String>>());
    });
  });

  group('BackendResponse.failure', () {
    test('isSuccess is false', () {
      final response = BackendResponse<String>.failure('Error occurred');
      expect(response.isSuccess, false);
    });

    test('errorMessage returns the message', () {
      final response = BackendResponse<String>.failure('Network timeout');
      expect(response.errorMessage, 'Network timeout');
    });

    test('accessing data throws exception', () {
      final response = BackendResponse<String>.failure('Fail');
      expect(() => response.data, throwsException);
    });
  });

  group('BackendResponse.loading', () {
    test('is non-success state', () {
      final response = BackendResponse<String>.loading();
      expect(response.isSuccess, false);
    });

    test('errorMessage returns default', () {
      final response = BackendResponse<String>.loading();
      expect(response.errorMessage, 'Unknown error occurred');
    });
  });

  group('BackendResponse.fold', () {
    test('calls onSuccess for successful response', () {
      final response = BackendResponse.success(10);
      final result = response.fold(
        onSuccess: (data) => 'Got: $data',
        onFailure: (error) => 'Error: $error',
      );
      expect(result, 'Got: 10');
    });

    test('calls onFailure for failed response', () {
      final response = BackendResponse<int>.failure('Bad request');
      final result = response.fold(
        onSuccess: (data) => 'Got: $data',
        onFailure: (error) => 'Error: $error',
      );
      expect(result, 'Error: Bad request');
    });
  });

  group('BackendResponse.map', () {
    test('transforms success data', () {
      final response = BackendResponse.success(5);
      final mapped = response.map((data) => data * 2);
      expect(mapped.isSuccess, true);
      expect(mapped.data, 10);
    });

    test('passes through failure without calling mapper', () {
      final response = BackendResponse<int>.failure('Fail');
      final mapped = response.map((data) => data * 2);
      expect(mapped.isSuccess, false);
      expect(mapped.errorMessage, 'Fail');
    });
  });

  group('BackendResponse.fromRpc', () {
    test('null response = failure', () {
      final result = BackendResponse.fromRpc<String>(null);
      expect(result.isSuccess, false);
      expect(result.errorMessage, contains('null'));
    });

    test('error object = failure', () {
      final result = BackendResponse.fromRpc<String>(
        {'status': 'error', 'message': 'Server down'},
      );
      expect(result.isSuccess, false);
      expect(result.errorMessage, 'Server down');
    });

    test('valid response with mapper = success', () {
      final result = BackendResponse.fromRpc<int>(
        {'count': 42},
        mapper: (json) => (json as Map)['count'] as int,
      );
      expect(result.isSuccess, true);
      expect(result.data, 42);
    });

    test('valid response without mapper (direct cast) = success', () {
      final result = BackendResponse.fromRpc<String>('hello');
      expect(result.isSuccess, true);
      expect(result.data, 'hello');
    });

    test('mapper exception = failure with parse error', () {
      final result = BackendResponse.fromRpc<int>(
        'not a number',
        mapper: (json) => int.parse(json as String),
      );
      expect(result.isSuccess, false);
      expect(result.errorMessage, contains('Parsing Error'));
    });
  });

  group('BackendResponse.retry', () {
    test('retry without callback returns same response', () async {
      final response = BackendResponse<String>.failure('Fail');
      final retried = await response.retry();
      expect(retried.isSuccess, false);
      expect(retried.errorMessage, 'Fail');
    });

    test('retry with callback invokes it', () async {
      final response = BackendResponse<String>.failure(
        'Fail',
        onRetry: () async => BackendResponse.success('Recovered'),
      );
      final retried = await response.retry();
      expect(retried.isSuccess, true);
      expect(retried.data, 'Recovered');
    });
  });
}
