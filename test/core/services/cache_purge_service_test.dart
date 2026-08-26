import 'package:flutter_test/flutter_test.dart';
import 'package:banjarabio/core/services/cache_purge_service.dart';

void main() {
  group('CachePurgeService Tests', () {
    test('PurgeResult model fields and isSuccess behavior', () {
      const successResult = PurgeResult(
        deviceCacheCleared: true,
        cdnObjectsPurged: 10,
        cdnObjectsFailed: 0,
        errors: [],
      );

      expect(successResult.isSuccess, isTrue);
      expect(successResult.deviceCacheCleared, isTrue);
      expect(successResult.cdnObjectsPurged, equals(10));
      expect(successResult.toString(), contains('cdnPurged: 10'));

      const failResult = PurgeResult(
        deviceCacheCleared: true,
        cdnObjectsPurged: 5,
        cdnObjectsFailed: 2,
        errors: ['Photo1: timeout'],
      );

      expect(failResult.isSuccess, isFalse);
      expect(failResult.cdnObjectsFailed, equals(2));
      expect(failResult.errors, hasLength(1));
    });
  });
}
