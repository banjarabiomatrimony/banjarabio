import 'package:flutter/foundation.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';

/// 🧹 Layer 6: Disk Cache Lifespan & Storage Auto-Pruning Manager
///
/// Portable & self-contained CacheManager configuration with strict lifespan
/// and LRU storage constraints.
///
/// Why this matters:
/// Default cache implementations can grow indefinitely until the device runs
/// out of storage, triggering user uninstalls.
///
/// AppDiskCacheManager automatically enforces:
/// - Max 200 cached image objects.
/// - 7-day maximum stale lifetime for downloaded images.
/// - Self-pruning background sweep.
///
/// Can be copied and pasted directly into any Flutter project.
class AppDiskCacheManager {
  AppDiskCacheManager._();

  static const String key = 'app_media_disk_cache';

  /// Singleton custom cache manager instance
  static final CacheManager instance = CacheManager(
    Config(
      key,
      stalePeriod: const Duration(days: 7),
      maxNrOfCacheObjects: 200,
      repo: JsonCacheInfoRepository(databaseName: key),
      fileService: HttpFileService(),
    ),
  );

  /// Empties the entire media disk cache manually (e.g. from a user "Clear Cache" setting).
  static Future<void> emptyCache() async {
    try {
      await instance.emptyCache();
      debugPrint('🧹 [AppDiskCacheManager] Disk cache successfully cleared.');
    } catch (e) {
      debugPrint('⚠️ [AppDiskCacheManager] Error emptying disk cache: $e');
    }
  }

  /// Removes a single specific URL from disk cache.
  static Future<void> removeFile(String url) async {
    try {
      await instance.removeFile(url);
    } catch (e) {
      debugPrint('⚠️ [AppDiskCacheManager] Error removing file $url: $e');
    }
  }
}
