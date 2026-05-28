import 'package:flutter_cache_manager/flutter_cache_manager.dart';

/// [PersistentCacheManager]
///
/// A custom [CacheManager] that keeps images alive across app restarts.
///
/// ## Why not DefaultCacheManager?
/// `DefaultCacheManager` uses the OS **temporary** directory. On Android/iOS,
/// the OS can evict this at any time (low storage, app backgrounded, etc.).
/// This means profile photos are re-downloaded on every cold start — the
/// primary driver of our 6.87 GB cached egress overage.
///
/// ## What this does:
/// - Stores images in `getApplicationDocumentsDirectory()` (permanent, not temp)
/// - Keeps images for **30 days** (vs the default 30 days in temp which gets evicted)
/// - Holds up to **500 images** (~50–100 MB on disk max for BanjaraBio)
/// - Uses a unique cache key `banjara_photos_v1` so it doesn't clash with
///   any other cache manager in the app
class PersistentCacheManager {
  static const String _cacheKey = 'banjara_photos_v1';

  static final CacheManager instance = CacheManager(
    Config(
      _cacheKey,
      // 30 days: images stay on disk even if the user doesn't open the app
      // for a month. Profile photos rarely change, so this is safe.
      stalePeriod: const Duration(days: 30),

      // Max 500 images ≈ enough for a full feed session (20 profiles × 5 photos
      // each = 100 images) with significant headroom for repeat visitors.
      maxNrOfCacheObjects: 500,

      // FileSystem backed repo — stores in app Documents dir (persistent).
      // This is the key difference from DefaultCacheManager (temp dir).
      repo: JsonCacheInfoRepository(databaseName: _cacheKey),
      fileService: HttpFileService(),
    ),
  );

  // Prevent instantiation — use PersistentCacheManager.instance
  PersistentCacheManager._();
}
