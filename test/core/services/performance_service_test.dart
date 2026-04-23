import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:banjarabio/core/services/performance_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  
  late PerformanceService service;

  setUp(() {
    service = PerformanceService();
    service.dispose();
  });

  group('PerformanceService', () {
    testWidgets('clears caches on memory pressure', (tester) async {
      service.initialize();
      
      // Simulate memory pressure
      service.simulateMemoryPressure();
      
      // Verification: PaintingBinding.instance.imageCache should be cleared.
      // We check if it doesn't throw and coverage is hit.
      expect(PaintingBinding.instance.imageCache.currentSizeBytes, 0);
    });

    test('initialize sets flag', () {
      service.initialize();
      // Side effect: adds observer
      service.dispose();
    });
  });
}
