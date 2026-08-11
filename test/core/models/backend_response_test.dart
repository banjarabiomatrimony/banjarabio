import 'package:flutter_test/flutter_test.dart';
import 'package:banjarabio/core/models/backend_response.dart';
import 'package:banjarabio/core/services/telemetry_service.dart';
import '../../helpers/mock_services.dart';

void main() {
  setUpAll(() {
    TelemetryService.instance = NoOpTelemetryService();
  });

  tearDownAll(() {
    TelemetryService.instance = TelemetryService.internal();
  });

  group('BackendResponse - Success', () {
    test('success factory creates a successful response with data', () {
      final response = BackendResponse.success('hello');

      expect(response.isSuccess, true);
      expect(response.data, 'hello');
    });

    test('success works with complex types', () {
      final data = {'key': 'value', 'count': 42};
      final response = BackendResponse.success(data);

      expect(response.isSuccess, true);
      expect(response.data['key'], 'value');
      expect(response.data['count'], 42);
    });

    test('success works with lists', () {
      final response = BackendResponse.success([1, 2, 3]);

      expect(response.isSuccess, true);
      expect(response.data, [1, 2, 3]);
    });

    test('success works with null data when T is nullable', () {
      final response = BackendResponse<String?>.success(null);

      expect(response.isSuccess, true);
      expect(response.data, isNull);
    });
  });

  group('BackendResponse - Failure', () {
    test('failure factory creates a failed response with error message', () {
      final response = BackendResponse<String>.failure('Something went wrong');

      expect(response.isSuccess, false);
      expect(response.errorMessage, 'Something went wrong');
    });

    test('accessing data on failure throws an exception', () {
      final response = BackendResponse<String>.failure('Error');

      expect(() => response.data, throwsA(isA<Exception>()));
    });

    test('errorMessage defaults to "Unknown error occurred" when null', () {
      // Via loading factory which has no error set
      final response = BackendResponse<String>.loading();

      expect(response.errorMessage, 'Unknown error occurred');
    });

    test('failure with onRetry stores retry callback', () async {
      int callCount = 0;
      final response = BackendResponse<String>.failure(
        'Error',
        onRetry: () async {
          callCount++;
          return BackendResponse.success('retried');
        },
      );

      expect(response.onRetry, isNotNull);
      await response.retry();
      expect(callCount, 1);
    });
  });

  group('BackendResponse - Loading', () {
    test('loading factory creates non-success state', () {
      final response = BackendResponse<String>.loading();

      expect(response.isSuccess, false);
    });
  });

  group('BackendResponse - fold', () {
    test('fold calls onSuccess for successful response', () {
      final response = BackendResponse.success(42);

      final result = response.fold(
        onSuccess: (data) => 'Success: $data',
        onFailure: (error) => 'Failure: $error',
      );

      expect(result, 'Success: 42');
    });

    test('fold calls onFailure for failed response', () {
      final response = BackendResponse<int>.failure('broken');

      final result = response.fold(
        onSuccess: (data) => 'Success: $data',
        onFailure: (error) => 'Failure: $error',
      );

      expect(result, 'Failure: broken');
    });
  });

  group('BackendResponse - map', () {
    test('map transforms success data', () {
      final response = BackendResponse.success(10);
      final mapped = response.map((data) => data * 2);

      expect(mapped.isSuccess, true);
      expect(mapped.data, 20);
    });

    test('map preserves failure and error message', () {
      final response = BackendResponse<int>.failure('oops');
      final mapped = response.map((data) => data * 2);

      expect(mapped.isSuccess, false);
      expect(mapped.errorMessage, 'oops');
    });

    test('map wraps retry function for failure', () async {
      final response = BackendResponse<int>.failure(
        'err',
        onRetry: () async => BackendResponse.success(5),
      );

      final mapped = response.map((data) => data.toString());
      expect(mapped.onRetry, isNotNull);

      final retried = await mapped.retry();
      expect(retried.isSuccess, true);
      expect(retried.data, '5');
    });

    test('map catches mapper exceptions and returns failure', () {
      final response = BackendResponse.success('not a number');
      final mapped = response.map<int>((data) => int.parse(data));

      expect(mapped.isSuccess, false);
      expect(mapped.errorMessage, contains('Mapping Error'));
    });
  });

  group('BackendResponse - retry', () {
    test('retry invokes onRetry callback', () async {
      final response = BackendResponse<String>.failure(
        'err',
        onRetry: () async => BackendResponse.success('recovered'),
      );

      final result = await response.retry();
      expect(result.isSuccess, true);
      expect(result.data, 'recovered');
    });

    test('retry returns self when no onRetry is set', () async {
      final response = BackendResponse<String>.failure('no retry');

      final result = await response.retry();
      expect(result.isSuccess, false);
      expect(result.errorMessage, 'no retry');
    });
  });

  group('BackendResponse - fromRpc', () {
    test('fromRpc returns failure on null response', () {
      final result = BackendResponse.fromRpc<String>(null);

      expect(result.isSuccess, false);
      expect(result.errorMessage, contains('null'));
    });

    test('fromRpc returns failure on error object', () {
      final result = BackendResponse.fromRpc<String>(
        {'status': 'error', 'message': 'Not found'},
      );

      expect(result.isSuccess, false);
      expect(result.errorMessage, 'Not found');
    });

    test('fromRpc returns failure with default message for error without message', () {
      final result = BackendResponse.fromRpc<String>(
        {'status': 'error'},
      );

      expect(result.isSuccess, false);
      expect(result.errorMessage, 'Unknown server error');
    });

    test('fromRpc uses mapper when provided', () {
      final result = BackendResponse.fromRpc<int>(
        {'count': 42},
        mapper: (json) => (json as Map)['count'] as int,
      );

      expect(result.isSuccess, true);
      expect(result.data, 42);
    });

    test('fromRpc does direct cast when no mapper', () {
      final result = BackendResponse.fromRpc<String>('hello');

      expect(result.isSuccess, true);
      expect(result.data, 'hello');
    });

    test('fromRpc handles parsing error', () {
      final result = BackendResponse.fromRpc<int>(
        'not an int',
        mapper: (json) => throw const FormatException('bad format'),
      );

      expect(result.isSuccess, false);
      expect(result.errorMessage, contains('Data Parsing Error'));
    });

    test('fromRpc preserves onRetry on failure', () async {
      int callCount = 0;
      final result = BackendResponse.fromRpc<String>(
        null,
        onRetry: () async {
          callCount++;
          return BackendResponse.success('ok');
        },
      );

      expect(result.isSuccess, false);
      expect(result.onRetry, isNotNull);
      await result.retry();
      expect(callCount, 1);
    });
  });
}
