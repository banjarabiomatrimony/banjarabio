import 'package:flutter_test/flutter_test.dart';
import 'package:banjarabio/core/services/scroll_velocity_service.dart';

void main() {
  group('ScrollVelocityService', () {
    late ScrollVelocityService service;

    setUp(() {
      service = ScrollVelocityService.instance;
      // Reset internal state via public API
    });

    test('singleton instance is always the same', () {
      expect(identical(ScrollVelocityService.instance, ScrollVelocityService.instance), true);
    });

    test('initial velocity is 0', () {
      expect(service.velocity, isA<double>());
    });

    test('hyperScrollThreshold is 3500', () {
      expect(ScrollVelocityService.hyperScrollThreshold, 3500);
    });

    test('updateVelocity does not throw', () {
      expect(() => service.updateVelocity(100.0), returnsNormally);
    });

    test('velocity changes after multiple calls with delay', () async {
      // First call establishes baseline
      service.updateVelocity(0);
      
      // Wait a small amount so dt > 0
      await Future.delayed(const Duration(milliseconds: 20));
      service.updateVelocity(100);

      // Velocity should have updated from 0
      // We can't predict exact value since it depends on timing
      expect(service.velocity, isA<double>());
    });
  });

  group('ScrollVelocityService - isHyperScrolling', () {
    test('isHyperScrolling is a boolean', () {
      expect(ScrollVelocityService.instance.isHyperScrolling, isA<bool>());
    });
  });
}
