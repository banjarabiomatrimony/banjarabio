import 'package:flutter_test/flutter_test.dart';
import 'package:banjarabio/core/services/network_aware_quality_service.dart';

void main() {
  group('NetworkAwareQualityService - getOptimizationParams', () {
    late NetworkAwareQualityService service;

    setUp(() {
      service = NetworkAwareQualityService();
      service.lowRamMode = false;
    });

    test('fast speed returns high quality params', () {
      final params = service.getOptimizationParams(forcedSpeed: NetworkSpeed.fast);

      expect(params['quality'], 85);
      expect(params['targetWidth'], 1080);
    });

    test('fast speed with highQuality returns maximum params', () {
      final params = service.getOptimizationParams(
        isHighQuality: true,
        forcedSpeed: NetworkSpeed.fast,
      );

      expect(params['quality'], 95);
      expect(params['targetWidth'], 1200);
    });

    test('medium speed returns medium quality params', () {
      final params = service.getOptimizationParams(forcedSpeed: NetworkSpeed.medium);

      expect(params['quality'], 75);
      expect(params['targetWidth'], 800);
    });

    test('medium speed with highQuality returns better params', () {
      final params = service.getOptimizationParams(
        isHighQuality: true,
        forcedSpeed: NetworkSpeed.medium,
      );

      expect(params['quality'], 85);
      expect(params['targetWidth'], 1000);
    });

    test('slow speed returns low quality params', () {
      final params = service.getOptimizationParams(forcedSpeed: NetworkSpeed.slow);

      expect(params['quality'], 60);
      expect(params['targetWidth'], 600);
    });

    test('slow speed with highQuality still returns low params', () {
      final params = service.getOptimizationParams(
        isHighQuality: true,
        forcedSpeed: NetworkSpeed.slow,
      );

      expect(params['quality'], 60);
      expect(params['targetWidth'], 600);
    });

    test('lowRamMode downgrades fast to medium', () {
      service.lowRamMode = true;
      final params = service.getOptimizationParams(forcedSpeed: NetworkSpeed.fast);

      expect(params['quality'], 75);
      expect(params['targetWidth'], 800);
    });

    test('lowRamMode downgrades medium to slow', () {
      service.lowRamMode = true;
      final params = service.getOptimizationParams(forcedSpeed: NetworkSpeed.medium);

      expect(params['quality'], 60);
      expect(params['targetWidth'], 600);
    });

    test('lowRamMode keeps slow as slow', () {
      service.lowRamMode = true;
      final params = service.getOptimizationParams(forcedSpeed: NetworkSpeed.slow);

      expect(params['quality'], 60);
      expect(params['targetWidth'], 600);
    });
  });

  group('NetworkSpeed enum', () {
    test('has exactly 3 values', () {
      expect(NetworkSpeed.values.length, 3);
    });

    test('contains slow, medium, fast', () {
      final names = NetworkSpeed.values.map((e) => e.name).toSet();
      expect(names, containsAll(['slow', 'medium', 'fast']));
    });
  });
}
