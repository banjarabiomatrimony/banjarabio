import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:banjarabio/core/media_pipeline/layer6_disk_cache_manager/app_disk_cache_manager.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(
      const MethodChannel('plugins.flutter.io/path_provider'),
      (MethodCall methodCall) async {
        return '/tmp/banjarabio_cache_test';
      },
    );
  });

  group('AppDiskCacheManager Tests', () {
    test('singleton instance is configured properly', () {
      expect(AppDiskCacheManager.instance, isNotNull);
      expect(AppDiskCacheManager.key, equals('app_media_disk_cache'));
    });

    test('emptyCache executes without crashing', () async {
      await expectLater(AppDiskCacheManager.emptyCache(), completes);
    });

    test('removeFile executes without crashing', () async {
      await expectLater(AppDiskCacheManager.removeFile('https://example.com/test.jpg'), completes);
    });
  });
}
