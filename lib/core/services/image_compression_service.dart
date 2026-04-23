import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:path/path.dart' as p;

class ImageCompressionService {
  // Singleton pattern
  static final ImageCompressionService _instance = ImageCompressionService._();
  factory ImageCompressionService() => _instance;
  ImageCompressionService._();

  @visibleForTesting
  Future<File?> Function(
    String path,
    String targetPath, {
    int? quality,
    int? minWidth,
    int? minHeight,
    int? rotate,
    bool? keepExif,
    dynamic format,
    bool? autoCorrectionAngle,
  })? testCompressor;

  /// 1. Native C++ Compression (No 'compute' needed)
  /// The plugin runs on a background thread natively.
  /// 1. Native C++ Compression (No 'compute' needed)
  /// The plugin runs on a background thread natively.
  Future<File> compressImageSafe(
    File originalFile, {
    int? qualityOverride,
    int? minWidth,
    int? minHeight,
  }) async {
    // Web check
    if (kIsWeb) return originalFile;

    try {
      final fileSize = originalFile.lengthSync();
      final fileSizeKB = fileSize / 1024;

      // Don't compress if smaller than 200KB
      if (fileSizeKB < 200) {
        return originalFile;
      }

      // Smart Heuristics: Calculate quality based on size
      // Bigger file = Needs lower quality to reach target size.
      int quality = qualityOverride ?? 75;
      if (qualityOverride == null) {
        if (fileSizeKB > 5000) {
          quality = 60; // > 5MB
        } else if (fileSizeKB > 2000) {
          quality = 70; // > 2MB
        }
      }

      final tempDir = await getTemporaryDirectory();

      // Unique name to prevent conflicts
      final targetPath = p.join(
        tempDir.path,
        'compressed_${DateTime.now().millisecondsSinceEpoch}.jpg',
      );

      // 2. Use compressAndGetFile (File -> File)
      // This is the most memory-efficient method. It streams data
      // from disk to disk via C++, bypassing Dart RAM entirely.
      XFile? result;
      if (testCompressor != null) {
        final file = await testCompressor!(
          originalFile.absolute.path,
          targetPath,
          quality: quality,
          minWidth: minWidth ?? 1200,
          minHeight: minHeight ?? 1200,
          rotate: 0,
          keepExif: true,
          format: CompressFormat.jpeg,
          autoCorrectionAngle: true,
        );
        result = file != null ? XFile(file.path) : null;
      } else {
        result = await FlutterImageCompress.compressAndGetFile(
          originalFile.absolute.path,
          targetPath,
          quality: quality,
          minWidth: minWidth ?? 1200, // HD Quality
          minHeight: minHeight ?? 1200,
        );
      }

      if (result == null) {
        // If native compression fails, return original rather than crashing
        debugPrint('Compression failed, using original');
        return originalFile;
      }

      return File(result.path);
    } catch (e) {
      debugPrint('Compression Error: $e');
      return originalFile; // Fail safe
    }
  }

  /// 3. Safe Cleanup
  /// Only deletes files created by THIS service
  Future<void> cleanupOldFiles() async {
    if (kIsWeb) return;
    try {
      final tempDir = await getTemporaryDirectory();
      final dir = Directory(tempDir.path);

      if (dir.existsSync()) {
        final now = DateTime.now();
        await for (var entity in dir.list()) {
          // Only delete files WE created
          if (entity is File &&
              p.basename(entity.path).startsWith('compressed_')) {
            final stat = entity.statSync();
            if (now.difference(stat.modified).inMinutes > 30) {
              entity.deleteSync();
            }
          }
        }
      }
    } catch (e) {
      debugPrint('Cleanup error: $e');
    }
  }
}
