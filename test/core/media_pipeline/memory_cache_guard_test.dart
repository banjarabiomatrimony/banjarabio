import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:banjarabio/core/media_pipeline/layer4_memory_cache_guard/memory_cache_guard.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('MemoryCacheGuard Tests', () {
    test('initializes and configures PaintingBinding imageCache limits', () {
      MemoryCacheGuard.initialize(
        maxSizeBytes: 50 * 1024 * 1024,
        maxImageCount: 75,
      );

      final cache = PaintingBinding.instance.imageCache;
      expect(cache.maximumSizeBytes, equals(50 * 1024 * 1024));
      expect(cache.maximumSize, equals(75));
    });

    test('clearMemoryCache executes without exceptions', () {
      expect(() => MemoryCacheGuard.clearMemoryCache(), returnsNormally);
    });

    test('getStats returns populated telemetry map', () {
      final stats = MemoryCacheGuard.getStats();
      expect(stats, contains('currentSizeBytes'));
      expect(stats, contains('currentSizeMB'));
      expect(stats, contains('maximumSizeBytes'));
      expect(stats, contains('currentImageCount'));
      expect(stats, contains('maximumImageCount'));
      expect(stats, contains('liveImageCount'));
      expect(stats, contains('pendingImageCount'));
    });
  });
}
