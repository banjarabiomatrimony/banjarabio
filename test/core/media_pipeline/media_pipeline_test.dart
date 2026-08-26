import 'package:flutter_test/flutter_test.dart';
import 'package:banjarabio/core/media_pipeline/media_pipeline.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Universal Media Pipeline Integration Exports', () {
    test('all 6 layers are accessible via media_pipeline.dart barrel file', () {
      // Layer 1
      expect(ImageCompressionService, isNotNull);
      // Layer 2
      expect(DisplayCachePolicy.defaultCardWidth, equals(720));
      // Layer 3
      expect(SupabaseImageTransformer.cardWidth, equals(640));
      // Layer 4
      expect(MemoryCacheGuard.defaultMaxImageCount, equals(60));
      // Layer 5
      expect(ProgressivePlaceholderBuilder, isNotNull);
      // Layer 6
      expect(AppDiskCacheManager.key, equals('app_media_disk_cache'));
    });
  });
}
