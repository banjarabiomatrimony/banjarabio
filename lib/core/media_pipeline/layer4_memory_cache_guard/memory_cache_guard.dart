import 'package:flutter/widgets.dart';

/// 🛡️ Layer 4: Global In-Memory Cache Guard (PaintingBinding LRU Limiter)
///
/// Portable & self-contained controller for configuring Flutter's global in-memory
/// image cache (`PaintingBinding.instance.imageCache`).
///
/// Why this matters:
/// Flutter defaults to allowing 1,000 images / 100 MB in RAM before evicting.
/// On long scroll sessions or memory-constrained budget devices (2GB/3GB RAM),
/// this causes unevicted bitmaps to trigger Out-Of-Memory (OOM) app crashes.
///
/// MemoryCacheGuard establishes a hard ceiling (e.g. 40 MB / 60 images) with
/// automatic Least-Recently-Used (LRU) memory reclamation.
///
/// Can be copied and pasted directly into any Flutter project.
class MemoryCacheGuard {
  MemoryCacheGuard._();

  /// Default maximum memory footprint dedicated to decoded bitmaps (40 MB).
  static const int defaultMaxSizeBytes = 40 * 1024 * 1024;

  /// Default maximum number of decoded images simultaneously held in memory.
  static const int defaultMaxImageCount = 60;

  static bool _isInitialized = false;

  /// Initializes the global in-memory image cache bounds.
  /// Typically called once inside `main()` or during early app startup.
  static void initialize({
    int maxSizeBytes = defaultMaxSizeBytes,
    int maxImageCount = defaultMaxImageCount,
  }) {
    if (_isInitialized) return;

    try {
      final cache = PaintingBinding.instance.imageCache;
      cache.maximumSizeBytes = maxSizeBytes;
      cache.maximumSize = maxImageCount;
      _isInitialized = true;
      debugPrint('🛡️ [MemoryCacheGuard] Initialized: ${maxSizeBytes ~/ (1024 * 1024)}MB max / $maxImageCount images max');
    } catch (e) {
      debugPrint('⚠️ [MemoryCacheGuard] Failed to configure PaintingBinding: $e');
    }
  }

  /// Emergency memory pressure relief: clears all active in-memory decoded bitmaps.
  /// Useful when receiving OS low-memory warnings (`didHaveMemoryPressure`).
  static void clearMemoryCache() {
    try {
      final cache = PaintingBinding.instance.imageCache;
      cache.clear();
      cache.clearLiveImages();
      debugPrint('🧹 [MemoryCacheGuard] In-memory image cache cleared.');
    } catch (e) {
      debugPrint('⚠️ [MemoryCacheGuard] clearMemoryCache error: $e');
    }
  }

  /// Returns current memory statistics for debugging & telemetry.
  static Map<String, dynamic> getStats() {
    try {
      final cache = PaintingBinding.instance.imageCache;
      return {
        'currentSizeBytes': cache.currentSizeBytes,
        'currentSizeMB': (cache.currentSizeBytes / (1024 * 1024)).toStringAsFixed(2),
        'maximumSizeBytes': cache.maximumSizeBytes,
        'currentImageCount': cache.currentSize,
        'maximumImageCount': cache.maximumSize,
        'liveImageCount': cache.liveImageCount,
        'pendingImageCount': cache.pendingImageCount,
      };
    } catch (_) {
      return {'error': 'Unavailable'};
    }
  }
}
