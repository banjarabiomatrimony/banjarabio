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

  group('BackendResponse.success', () {
    test('isSuccess and data work', () {
      final r = BackendResponse.success('data');
      expect(r.isSuccess, true);
      expect(r.data, 'data');
    });

    test('works with null (void)', () {
      final r = BackendResponse<void>.success(null);
      expect(r.isSuccess, true);
    });

    test('works with list', () {
      expect(BackendResponse.success([1, 2]).data, [1, 2]);
    });
  });

  group('BackendResponse.failure', () {
    test('isSuccess false, errorMessage works', () {
      final r = BackendResponse<String>.failure('err');
      expect(r.isSuccess, false);
      expect(r.errorMessage, 'err');
    });

    test('data throws on failure', () {
      expect(() => BackendResponse<String>.failure('x').data, throwsException);
    });
  });

  group('BackendResponse.loading', () {
    test('isSuccess false, default error', () {
      final r = BackendResponse<String>.loading();
      expect(r.isSuccess, false);
      expect(r.errorMessage, 'Unknown error occurred');
    });
  });

  group('fold', () {
    test('calls correct branch', () {
      expect(BackendResponse.success('ok').fold(onSuccess: (d) => 'S:$d', onFailure: (e) => 'F'), 'S:ok');
      expect(BackendResponse<String>.failure('x').fold(onSuccess: (d) => 'S', onFailure: (e) => 'F:$e'), 'F:x');
    });
  });

  group('map', () {
    test('transforms success', () {
      expect(BackendResponse.success(5).map((d) => d * 2).data, 10);
    });

    test('passes failure through', () {
      final m = BackendResponse<int>.failure('oops').map((d) => d * 2);
      expect(m.isSuccess, false);
      expect(m.errorMessage, 'oops');
    });

    test('catches mapper errors', () {
      final m = BackendResponse.success('x').map<int>((d) => throw const FormatException());
      expect(m.isSuccess, false);
      expect(m.errorMessage, contains('Mapping Error'));
    });
  });

  group('retry', () {
    test('calls callback', () async {
      final r = BackendResponse<int>.failure('f', onRetry: () async => BackendResponse.success(1));
      expect((await r.retry()).data, 1);
    });

    test('returns self when no callback', () async {
      final r = BackendResponse<int>.failure('f');
      expect(identical(await r.retry(), r), true);
    });
  });

  group('fromRpc', () {
    test('null → failure', () => expect(BackendResponse.fromRpc(null).isSuccess, false));
    test('error map → failure', () {
      final r = BackendResponse.fromRpc({'status': 'error', 'message': 'Bad'});
      expect(r.isSuccess, false);
      expect(r.errorMessage, 'Bad');
    });
    test('mapper works', () {
      final r = BackendResponse.fromRpc({'n': 'Amit'}, mapper: (j) => (j as Map)['n']);
      expect(r.data, 'Amit');
    });
    test('direct cast', () {
      expect(BackendResponse.fromRpc<String>('ok').data, 'ok');
    });
    test('mapper error', () {
      final r = BackendResponse.fromRpc('x', mapper: (_) => throw const FormatException());
      expect(r.isSuccess, false);
    });
    test('success non-error map', () {
      final r = BackendResponse.fromRpc<Map<String, dynamic>>({'status': 'ok', 'v': 1});
      expect(r.data['v'], 1);
    });
  });

  group('map + retry chaining', () {
    test('retries mapped failure', () async {
      final r = BackendResponse<int>.failure('f', onRetry: () async => BackendResponse.success(42));
      final m = r.map((v) => v.toString());
      expect((await m.retry()).data, '42');
    });
  });
}
