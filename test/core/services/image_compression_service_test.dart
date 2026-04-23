// Phase 11: ImageCompressionService unit tests
// Tests image optimization logic, size-based quality heuristics, and temporary file cleanup.
// Uses direct function injection for compression mocking and isolated test directories.

import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:path_provider_platform_interface/path_provider_platform_interface.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';
import 'package:banjarabio/core/services/image_compression_service.dart';
import 'package:path/path.dart' as p;

class MockPathProviderPlatform extends Fake
    with MockPlatformInterfaceMixin
    implements PathProviderPlatform {
  final String tempPath;
  MockPathProviderPlatform(this.tempPath);

  @override
  Future<String?> getTemporaryPath() async => tempPath;
  @override
  Future<String?> getApplicationDocumentsPath() async => null;
  @override
  Future<String?> getApplicationSupportPath() async => null;
  @override
  Future<String?> getLibraryPath() async => null;
  @override
  Future<String?> getExternalStoragePath() async => null;
  @override
  Future<List<String>?> getExternalCachePaths() async => null;
  @override
  Future<List<String>?> getExternalStoragePaths({StorageDirectory? type}) async => null;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late ImageCompressionService service;
  late Directory testDir;

  setUp(() async {
    testDir = Directory(p.join(Directory.systemTemp.path, 'bjb_compress_test_${DateTime.now().microsecondsSinceEpoch}'));
    if (!testDir.existsSync()) testDir.createSync(recursive: true);
    
    PathProviderPlatform.instance = MockPathProviderPlatform(testDir.path);
    service = ImageCompressionService();
    service.testCompressor = null;
  });

  tearDown(() async {
    if (testDir.existsSync()) testDir.deleteSync(recursive: true);
  });

  group('ImageCompressionService', () {
    test('bypass compression for small files (<200KB)', () async {
      final file = File(p.join(testDir.path, 'small_test.jpg'));
      await file.writeAsBytes(List.generate(100 * 1024, (i) => 0)); // 100KB

      final result = await service.compressImageSafe(file);
      expect(result.path, equals(file.path));
    });

    test('calculate correct quality based on file size (Heuristics)', () async {
      int capturedQuality = -1;
      service.testCompressor = (path, targetPath, {
        quality,
        minWidth,
        minHeight,
        rotate,
        keepExif,
        format,
        autoCorrectionAngle,
      }) async {
        capturedQuality = quality ?? -1;
        return File(targetPath);
      };

      // 1. > 5MB test (60 quality)
      final bigFile = File(p.join(testDir.path, 'big_test.jpg'));
      await bigFile.writeAsBytes(List.generate(6 * 1024 * 1024, (i) => 0));
      await service.compressImageSafe(bigFile);
      expect(capturedQuality, 60);

      // 2. > 2MB test (70 quality)
      final midFile = File(p.join(testDir.path, 'mid_test.jpg'));
      await midFile.writeAsBytes(List.generate(3 * 1024 * 1024, (i) => 0));
      await service.compressImageSafe(midFile);
      expect(capturedQuality, 70);

      // 3. Normal size (75 quality)
      final normalFile = File(p.join(testDir.path, 'normal_test.jpg'));
      await normalFile.writeAsBytes(List.generate(500 * 1024, (i) => 0));
      await service.compressImageSafe(normalFile);
      expect(capturedQuality, 75);
    });

    test('cleanupOldFiles deletes only expired "compressed_" files', () async {
      final oldFile = File(p.join(testDir.path, 'compressed_old.jpg'));
      await oldFile.create();
      await oldFile.setLastModified(DateTime.now().subtract(const Duration(minutes: 40)));

      final newFile = File(p.join(testDir.path, 'compressed_new.jpg'));
      await newFile.create();

      final otherFile = File(p.join(testDir.path, 'donotdelete.jpg'));
      await otherFile.create();
      await otherFile.setLastModified(DateTime.now().subtract(const Duration(minutes: 40)));

      await service.cleanupOldFiles();

      expect(oldFile.existsSync(), isFalse, reason: 'Old compressed file should be deleted');
      expect(newFile.existsSync(), isTrue, reason: 'New compressed file should be kept');
      expect(otherFile.existsSync(), isTrue, reason: 'Non-compressed file should be ignored');
    });

    test('handles compression failure gracefully', () async {
      service.testCompressor = (path, targetPath, {
        quality,
        minWidth,
        minHeight,
        rotate,
        keepExif,
        format,
        autoCorrectionAngle,
      }) async => null;

      final file = File(p.join(testDir.path, 'fail_test.jpg'));
      await file.writeAsBytes(List.generate(500 * 1024, (i) => 0));
      final result = await service.compressImageSafe(file);
      expect(result.path, equals(file.path));
    });
  });
}
