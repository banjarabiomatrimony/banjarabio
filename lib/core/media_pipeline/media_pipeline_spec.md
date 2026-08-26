# 🤖 AI Technical Specification & Protocol: `media_pipeline`
**Module Identifier:** `appansh_engine::media_pipeline`  
**Target Audience:** AI Coding Agents (Antigravity, Claude, Gemini, GPT), Monorepo Orchestrators, Senior Engineers  
**Strict Compliance Level:** MANDATORY FOR ALL DOWNSTREAM FLUTTER APPS  

---

## 1. 🚨 Core AI Directive & Constraints

When writing, generating, or refactoring Flutter code in ANY project consuming `appansh_engine`:

1. **NEVER RENDER RAW UNCONSTRAINED NETWORK IMAGES:**
   - ❌ FORBIDDEN: `Image.network(url)` without explicit `cacheWidth`/`cacheHeight`.
   - ❌ FORBIDDEN: `CachedNetworkImage(imageUrl: url)` without `memCacheWidth`.
   - **Reason:** Causes native $4000 \times 3000$ bitmap decoding ($48\text{ MB RAM}$ per card), triggering Android OOM crashes and frame drops.

2. **ALWAYS USE THE 6-LAYER MEDIA PIPELINE CONTRACT:**
   - Use `DisplayCachePolicy` for computing `memCacheWidth` & `memCacheHeight`.
   - Use `SupabaseImageTransformer` to fetch edge-resized thumbnails (`?width=450&quality=80`).
   - Use `ProgressivePlaceholderBuilder` for adaptive BlurHash / Shimmer placeholders.
   - Use `AppDiskCacheManager.instance` for long-term disk cache scoping.
   - Initialize `MemoryCacheGuard.initialize()` in app startup.

---

## 2. 📐 API Contract & Method Signatures

### Layer 1: Upload Compression (`ImageCompressionService`)
```dart
Future<File> compressImageSafe(
  File originalFile, {
  int? qualityOverride,
  int? minWidth = 1080,
  int? minHeight = 1080,
  CompressFormat format = CompressFormat.jpeg, // or CompressFormat.webp
});
Future<void> cleanupOldFiles(); // Safe non-blocking temp sweep
```

### Layer 2: Display Decoding (`DisplayCachePolicy`)
```dart
static int getCardCacheWidth([BuildContext? context]);       // Full bleed cards (480-1080px)
static int getThumbnailCacheWidth([BuildContext? context]);  // 2/3 column grids (240-540px)
static int getDualPaneCacheWidth([BuildContext? context, double paneFraction = 0.5]);
static int getAvatarCacheWidth([BuildContext? context, double displayDiameter = 60.0]);
static int computeCustomCacheWidth(double logicalWidth, [BuildContext? context]);
static bool isLandscape([BuildContext? context]);
static bool isTabletOrDesktop([BuildContext? context]);
```

### Layer 3: CDN Transformations (`SupabaseImageTransformer`)
```dart
static void addSupportedHost(String host);                   // Custom proxy registration
static bool isTransformable(String? url);                    // Validates CDN origin
static String getThumbnailUrl(String originalUrl, {int width = 320, int quality = 75});
static String getCardUrl(String originalUrl, {int width = 640, int quality = 80});
static String getAvatarUrl(String originalUrl, {int size = 180, int quality = 80});
static String getFullResUrl(String originalUrl, {int width = 1080, int quality = 85});
```

### Layer 4: Global In-Memory Ceiling (`MemoryCacheGuard`)
```dart
static void initialize({int maxSizeBytes = 40 * 1024 * 1024, int maxImageCount = 60});
static void clearMemoryCache();                              // Pressure relief valve
static Map<String, dynamic> getStats();                      // Telemetry & metrics
```

### Layer 5: Progressive Placeholders & BlurHash (`ProgressivePlaceholderBuilder`)
```dart
static Widget buildAdaptivePlaceholder({String? blurHash, double? width, double? height, BorderRadius? borderRadius});
static Widget buildShimmerPlaceholder({double? width, double? height, BorderRadius? borderRadius});
static Widget buildBlurHashPlaceholder({required String blurHash, double? width, double? height, BorderRadius? borderRadius});
static Widget Function(BuildContext, String) placeholderCallback({String? blurHash, double? width, double? height, BorderRadius? borderRadius});
static Widget Function(BuildContext, String, dynamic) errorCallback({double? width, double? height, BorderRadius? borderRadius});
```

### Layer 6: Disk Cache Lifespan (`AppDiskCacheManager`)
```dart
static final CacheManager instance;                          // 7-day stale period, 200 items max
static Future<void> emptyCache();                            // Clear all disk media
static Future<void> removeFile(String url);                  // Evict single asset
```

---

## 3. 🎯 Golden Pattern Implementation Template (Copy & Paste)

```dart
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:appansh_engine/appansh_engine.dart';

class StandardAppImage extends StatelessWidget {
  final String? imageUrl;
  final String? blurHash;
  final double? width;
  final double? height;
  final BorderRadius? borderRadius;
  final BoxFit fit;
  final bool isThumbnail;

  const StandardAppImage({
    super.key,
    required this.imageUrl,
    this.blurHash,
    this.width,
    this.height,
    this.borderRadius,
    this.fit = BoxFit.cover,
    this.isThumbnail = false,
  });

  @override
  Widget build(BuildContext context) {
    if (imageUrl == null || imageUrl!.isEmpty) {
      return ProgressivePlaceholderBuilder.buildErrorFallback(
        width: width,
        height: height,
        borderRadius: borderRadius,
      );
    }

    final effectiveUrl = isThumbnail 
        ? SupabaseImageTransformer.getThumbnailUrl(imageUrl!)
        : SupabaseImageTransformer.getCardUrl(imageUrl!);

    final targetCacheWidth = isThumbnail
        ? DisplayCachePolicy.getThumbnailCacheWidth(context)
        : (width != null && width!.isFinite 
            ? DisplayCachePolicy.computeCustomCacheWidth(width!, context)
            : DisplayCachePolicy.getCardCacheWidth(context));

    return ClipRRect(
      borderRadius: borderRadius ?? BorderRadius.zero,
      child: CachedNetworkImage(
        imageUrl: effectiveUrl,
        cacheManager: AppDiskCacheManager.instance,
        width: width,
        height: height,
        fit: fit,
        memCacheWidth: targetCacheWidth,
        placeholder: ProgressivePlaceholderBuilder.placeholderCallback(
          blurHash: blurHash,
          width: width,
          height: height,
          borderRadius: borderRadius,
        ),
        errorWidget: ProgressivePlaceholderBuilder.errorCallback(
          width: width,
          height: height,
          borderRadius: borderRadius,
        ),
      ),
    );
  }
}
```

---

## 4. 🧪 Verification & Health Check Checklist for AI
- [ ] Has `MemoryCacheGuard.initialize()` been called in `main.dart`?
- [ ] Are all remote image calls clamped via `DisplayCachePolicy`?
- [ ] Does the UI handle both `blurHash` and shimmering fallbacks gracefully?
- [ ] Does `flutter analyze` report 0 errors and 0 warnings?
