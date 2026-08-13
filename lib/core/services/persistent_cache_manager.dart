import 'dart:io';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:path_provider/path_provider.dart';
import 'package:file/file.dart' as f;
import 'package:file/local.dart';
import 'package:banjarabio/core/services/app_logger.dart';

/// A custom file system that stores files in a subfolder of the application
/// documents directory (or system temp directory in test environments).
class PersistentDocumentsFileSystem implements FileSystem {
  final Future<Directory> _directoryFuture;

  PersistentDocumentsFileSystem(String cacheKey)
      : _directoryFuture = _resolveDirectory(cacheKey);

  static Future<Directory> _resolveDirectory(String cacheKey) async {
    // If in test environment, use system temp directory to avoid MissingPluginException
    if (Platform.environment.containsKey('FLUTTER_TEST')) {
      final tempDir = Directory.systemTemp;
      final cacheDir = Directory('${tempDir.path}/$cacheKey');
      if (!cacheDir.existsSync()) {
        cacheDir.createSync(recursive: true);
      }
      return cacheDir;
    }

    final appDocDir = await getApplicationDocumentsDirectory();
    final cacheDir = Directory('${appDocDir.path}/$cacheKey');
    if (!cacheDir.existsSync()) {
      cacheDir.createSync(recursive: true);
    }
    return cacheDir;
  }

  @override
  Future<f.File> createFile(String name) async {
    final directory = await _directoryFuture;
    const localFs = LocalFileSystem();
    return localFs.file('${directory.path}/$name');
  }
}

/// [PersistentCacheManager]
///
/// **Goal: download each image ONCE. Never fetch it from Supabase again.**
///
/// ## Two key problems solved:
///
/// ### Problem 1 — OS eviction (app reopen re-downloads)
/// `DefaultCacheManager` stores in the OS **temp directory**, which gets
/// wiped on low memory or app restart. We store in the **app Documents
/// directory** which the OS never clears automatically.
///
/// ### Problem 2 — URL variation (same photo, different cache hits)
/// Supabase transformation URLs include query params:
///   `/render/image/public/…?width=400&quality=80`
/// If the width param changes (different screen, different widget), the full
/// URL is a different cache key → re-download despite having the same photo.
///
/// **Fix:** use [stableKeyFor] to strip query params and use only the path
/// as the cache key. Same photo = same key = always served from disk.
///
/// ## Config:
/// - **365-day TTL** — effectively permanent for all active users
/// - **2000 max objects** — ~200 profiles × 5 photos × 2 sizes with headroom
/// - **App Documents directory** — survives OS pressure and app restarts
class PersistentCacheManager {
  static const String _cacheKey = 'banjara_photos_v1';

  static final CacheManager instance = CacheManager(
    Config(
      _cacheKey,
      // 365 days = effectively permanent. A user who hasn't opened the app
      // in a year will re-download on next open — that is acceptable.
      stalePeriod: const Duration(days: 365),

      // 2000 images: 200 profiles × 5 photos = 1000, doubled for headroom.
      // At ~100KB avg per cached thumbnail, this is ~200MB max on disk.
      maxNrOfCacheObjects: 2000,

      // Cache metadata store: use robust transaction-backed SQLite on mobile, and
      // fallback to NonStoringObjectProvider in VM test environments.
      repo: Platform.environment.containsKey('FLUTTER_TEST')
          ? NonStoringObjectProvider()
          : CacheObjectProvider(databaseName: _cacheKey),
      
      // Store downloaded image files in persistent application documents directory
      fileSystem: PersistentDocumentsFileSystem(_cacheKey),
      fileService: HttpFileService(),
    ),
  );

  // Prevent instantiation — use PersistentCacheManager.instance
  PersistentCacheManager._();

  // ---------------------------------------------------------------------------
  // Stable Cache Key — THE core egress fix
  // ---------------------------------------------------------------------------

  /// Returns a stable, canonical cache key for any Supabase Storage URL.
  ///
  /// Strips all query parameters from the URL so that the same file is
  /// always mapped to the same local cache entry, regardless of what
  /// transformation params (?width=, ?quality=, etc.) are appended.
  ///
  /// Examples:
  /// ```
  /// stableKeyFor('https://…/render/image/public/profile-photos/abc.jpg?width=400&quality=80')
  /// → 'profile-photos/abc.jpg'
  ///
  /// stableKeyFor('https://…/object/public/profile-photos/abc.jpg')
  /// → 'profile-photos/abc.jpg'
  /// ```
  ///
  /// If the URL cannot be parsed, the original URL is returned as-is so
  /// the system still works (just without stable-key deduplication).
  static String stableKeyFor(String url) {
    try {
      final uri = Uri.parse(url);

      // Extract just the storage path after /profile-photos/ or similar
      // Works for both /object/public/ and /render/image/public/ URLs
      final path = uri.path;

      // Find the bucket name onwards — e.g. "profile-photos/uuid/filename.jpg"
      final objectPublicIdx = path.indexOf('/object/public/');
      if (objectPublicIdx != -1) {
        return path.substring(objectPublicIdx + '/object/public/'.length);
      }

      final renderImageIdx = path.indexOf('/render/image/public/');
      if (renderImageIdx != -1) {
        return path.substring(renderImageIdx + '/render/image/public/'.length);
      }

      // Fallback: path without query string (still strips params)
      return uri.replace(queryParameters: {}).toString();
    } catch (e) {
      AppLogger.error('PersistentCacheManager', '[PersistentCacheManager] stableKeyFor error: $e');
      return url; // Fail safe
    }
  }

  // ---------------------------------------------------------------------------
  // Cache Management Utilities
  // ---------------------------------------------------------------------------

  /// Clear ALL locally cached images from this manager.
  static Future<void> clearAll() async {
    try {
      await instance.emptyCache();
      AppLogger.debug('PersistentCacheManager', '[PersistentCacheManager] ✅ Local image cache cleared');
    } catch (e) {
      AppLogger.error('PersistentCacheManager', '[PersistentCacheManager] clearAll error: $e');
    }
  }

  /// Remove a single image from the local cache by its URL.
  /// Pass the original (untransformed) URL — stableKeyFor is applied internally.
  static Future<void> evictUrl(String url) async {
    try {
      await instance.removeFile(stableKeyFor(url));
      AppLogger.debug('PersistentCacheManager', '[PersistentCacheManager] Evicted: ${stableKeyFor(url)}');
    } catch (e) {
      AppLogger.error('PersistentCacheManager', '[PersistentCacheManager] evictUrl error: $e');
    }
  }

  /// Returns the approximate on-disk size of the image cache.
  ///
  /// Scans the cache directory for files and sums their sizes.
  static Future<String> getCacheSizeLabel() async {
    try {
      final dir = await getApplicationDocumentsDirectory();
      final cacheDir = Directory('${dir.path}/$_cacheKey');
      if (!cacheDir.existsSync()) return '0 KB';

      int totalBytes = 0;
      await for (final entity in cacheDir.list(recursive: true)) {
        if (entity is File) {
          totalBytes += await entity.length();
        }
      }

      if (totalBytes == 0) return '0 KB';
      if (totalBytes < 1024 * 1024) {
        return '${(totalBytes / 1024).toStringAsFixed(1)} KB';
      }
      return '${(totalBytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    } catch (e) {
      return 'Unknown';
    }
  }
}
