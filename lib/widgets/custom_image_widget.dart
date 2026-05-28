import 'dart:io' as io;
import 'package:banjarabio/l10n/app_localizations.dart';
import 'package:sizer/sizer.dart';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:banjarabio/core/repositories/photo_repository.dart';
import 'package:banjarabio/core/services/network_aware_quality_service.dart';
import 'package:banjarabio/core/services/persistent_cache_manager.dart';
import 'package:banjarabio/widgets/shimmer_widget.dart';


extension ImageTypeExtension on String {
  ImageType get imageType {
    if (startsWith('http') || startsWith('https')) {
      return ImageType.network;
    } else if (endsWith('.svg')) {
      return ImageType.svg;
    } else if (startsWith('file://') ||
        startsWith('/') ||
        startsWith('blob:')) {
      return ImageType.file;
    } else {
      return ImageType.png;
    }
  }
}

enum ImageType { svg, png, network, file, unknown }

class CustomImageWidget extends StatelessWidget {
  const CustomImageWidget({
    super.key,
    this.imageUrl,
    this.height,
    this.width,
    this.color,
    this.fit,
    this.alignment,
    this.onTap,
    this.radius,
    this.margin,
    this.border,
    this.placeHolder,
    this.errorWidget,
    this.semanticLabel,
    this.cacheWidth,
    this.cacheHeight,
    this.isHighQuality = false,
  });

  final String? imageUrl;
  final double? height;
  final double? width;
  final BoxFit? fit;
  final String? placeHolder;
  final Color? color;
  final Alignment? alignment;
  final VoidCallback? onTap;
  final BorderRadius? radius;
  final EdgeInsetsGeometry? margin;
  final BoxBorder? border;
  final Widget? errorWidget;
  final String? semanticLabel;
  final int? cacheWidth;
  final int? cacheHeight;
  final bool isHighQuality;

  /// 🧬 PRO SCALE: Precache a list of photo URLs to ensure smooth zero-lag scrolling.
  static Future<void> precachePhotos(BuildContext context, List<String> urls, {bool isHighQuality = false}) async {
    // 🚨 MOTOROLA/ANDROID 15 FIX: Skip background precaching.
    // Motorola devices on Android 15 are aggressive at killing network connections 
    // when the app is in the background, leading to 'SocketException: Software caused connection abort'.
    if (WidgetsBinding.instance.lifecycleState != AppLifecycleState.resumed) {
      return;
    }

    final speed = await NetworkAwareQualityService().getSpeedProfile();
    final params = NetworkAwareQualityService().getOptimizationParams(
      isHighQuality: isHighQuality,
      forcedSpeed: speed,
    );
    
    if (!context.mounted) return;

    for (final url in urls) {
      if (!context.mounted) return;
      // Re-check lifecycle inside the loop to catch transitions during long precache batches
      if (WidgetsBinding.instance.lifecycleState != AppLifecycleState.resumed) return;
      if (url.isEmpty) continue;
      
      final optimizedUrl = PhotoRepository().getResizedUrl(
        url,
        width: params['targetWidth'],
        quality: params['quality']!,
      );
      
      try {
        // 🚨 CRASH FIX (OPPO/ANDROID 14): Added onError listener to catch
        // 'Decoded image has been disposed' exceptions during rapid scrolling.
        precacheImage(
          CachedNetworkImageProvider(
            optimizedUrl,
            maxWidth: params['targetWidth'],
            maxHeight: params['targetWidth'], // square crop for thumbs
            cacheManager: PersistentCacheManager.instance,
            // Stable key: strips ?width=&quality= so same photo = same cache hit
            cacheKey: PersistentCacheManager.stableKeyFor(optimizedUrl),
          ), 
          context,
          onError: (exception, stackTrace) {
            debugPrint('Precache Background Error ($optimizedUrl): $exception');
          },
        );
      } catch (e) {
        debugPrint('Precache Sync Error ($optimizedUrl): $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return alignment != null
        ? Align(alignment: alignment!, child: _buildWidget(context))
        : _buildWidget(context);
  }

  Widget _buildWidget(BuildContext context) {
    return Padding(
      padding: margin ?? EdgeInsets.zero,
      child: Material(
        type: MaterialType.transparency,
        child: InkWell(
          onTap: onTap,
          borderRadius: radius,
          child: _buildCircleImage(context),
        ),
      ),
    );
  }

  Widget _buildCircleImage(BuildContext context) {
    if (radius != null) {
      return ClipRRect(
        borderRadius: radius ?? BorderRadius.zero,
        child: _buildImageWithBorder(context),
      );
    } else {
      return _buildImageWithBorder(context);
    }
  }

  Widget _buildImageWithBorder(BuildContext context) {
    if (border != null) {
      return Container(
        decoration: BoxDecoration(border: border, borderRadius: radius),
        child: _buildImageView(context),
      );
    } else {
      return _buildImageView(context);
    }
  }

  Widget _buildImageView(BuildContext context) {
    if (imageUrl == null || imageUrl!.isEmpty) {
      return _buildPlaceholder(context);
    }

    switch (imageUrl!.imageType) {
      case ImageType.svg:
        return SizedBox(
          height: height,
          width: width,
          child: SvgPicture.asset(
            imageUrl!,
            height: height,
            width: width,
            fit: fit ?? BoxFit.contain,
            colorFilter: color != null
                ? ColorFilter.mode(color!, BlendMode.srcIn)
                : null,
            semanticsLabel: semanticLabel,
          ),
        );
      case ImageType.file:
        return _buildFileImage(context);
      case ImageType.network:
        return _buildNetworkImage(context);
      case ImageType.png:
      default:
        return _buildAssetImage(context);
    }
  }

  int _calculateOptimalCache(BuildContext context, double? dimension) {
    final double dpr = MediaQuery.maybeOf(context)?.devicePixelRatio ?? 1.0;
    
    // 🚨 SIGNAL 3 FIX: When dimension is null, infinity, or <= 0,
    // use the SCREEN width instead of hardcoded 1000-1500px defaults.
    // Previously, ProfileCardWidget passed double.infinity which caused
    // images to decode at 1000-1500px instead of ~360px display size.
    if (dimension == null || dimension <= 0 || !dimension.isFinite) {
      final screenWidth = MediaQuery.maybeOf(context)?.size.width ?? 360.0;
      final result = screenWidth * dpr;
      return result.isFinite ? result.round().clamp(100, 1500) : 500;
    }
    try {
      if (!dpr.isFinite) return 500;
      final double result = dimension * dpr;
      if (!result.isFinite) return 500;
      // Cap at 1500px to prevent memory pressure on low-end devices
      return result.round().clamp(100, 1500);
    } catch (_) {
      return 500;
    }
  }

  Widget _buildFileImage(BuildContext context) {
    if (kIsWeb) {
      return Image.network(
        imageUrl!,
        height: height,
        width: width,
        alignment: alignment ?? Alignment.center,
        fit: fit ?? BoxFit.cover,
        color: color,
        semanticLabel: semanticLabel,
        errorBuilder: (context, error, stackTrace) => _buildPlaceholder(context),
      );
    }

    return Image.file(
      io.File(imageUrl!.replaceFirst('file://', '')),
      height: height,
      width: width,
      alignment: alignment ?? Alignment.center,
      fit: fit ?? BoxFit.cover,
      color: color,
      semanticLabel: semanticLabel,
      cacheWidth: cacheWidth ?? _calculateOptimalCache(context, width),
      cacheHeight: cacheHeight ?? _calculateOptimalCache(context, height),
      gaplessPlayback: true,
      errorBuilder: (context, error, stackTrace) => _buildPlaceholder(context),
    );
  }

  Widget _buildNetworkImage(BuildContext context) {
    // 🧬 PRO SCALE: Append resizing parameters to the URL
    // This significantly reduces memory usage on low-end devices by delivering
    // an image that matches the widget's physical dimensions.
    String optimizedUrl = imageUrl!;
    try {
      final photoRepo = PhotoRepository();
      final networkService = NetworkAwareQualityService();
      
      final dpr = MediaQuery.maybeOf(context)?.devicePixelRatio ?? 1.0;
      final speed = networkService.cachedSpeed;
      final params = networkService.getOptimizationParams(
        isHighQuality: isHighQuality,
        forcedSpeed: speed,
      );
      
      // Calculate logical dimensions into physical pixels
      int? targetWidth;
      int? targetHeight;
      
      if (width != null && width! > 0 && width!.isFinite) {
        targetWidth = (width! * dpr).round();
      }
      if (height != null && height! > 0 && height!.isFinite) {
        targetHeight = (height! * dpr).round();
      }

      // If dimensions are missing, use network-aware defaults
      if (targetWidth == null && targetHeight == null) {
        targetWidth = params['targetWidth']; 
      }

      optimizedUrl = photoRepo.getResizedUrl(
        imageUrl!,
        width: targetWidth,
        height: targetHeight,
        quality: params['quality']!,
      );
    } catch (e) {
      debugPrint('Image Optimization Error: $e');
    }

    return CachedNetworkImage(
      height: height,
      width: width,
      fit: fit,
      alignment: alignment ?? Alignment.center,
      imageUrl: optimizedUrl,
      color: color,
      cacheManager: PersistentCacheManager.instance,
      // Stable key: strip ?width=&quality= so ANY transformation of the same
      // photo resolves to the SAME local disk entry. Once downloaded once,
      // this image is NEVER fetched from Supabase again (365-day TTL).
      cacheKey: PersistentCacheManager.stableKeyFor(optimizedUrl),
      memCacheWidth: cacheWidth ?? _calculateOptimalCache(context, width),
      memCacheHeight: cacheHeight ?? _calculateOptimalCache(context, height),
      // 🚨 SIGNAL 3 FIX: Removed LQIP (dual-image) placeholder.
      // Previously each card loaded BOTH a 50px thumbnail AND the full image
      // simultaneously, causing 40+ concurrent gralloc4 allocations with 20 cards.
      // Now uses shimmer-only placeholder to cut concurrent image ops in half.
      placeholder: (context, url) => ShimmerWidget.rectangular(
        height: height ?? double.infinity,
        width: width ?? double.infinity,
        shapeBorder: RoundedRectangleBorder(
          borderRadius: radius ?? BorderRadius.zero,
        ),
      ),
      errorWidget: (context, url, error) => errorWidget ?? _buildPlaceholder(context),
    );
  }

  Widget _buildAssetImage(BuildContext context) {
    return Image.asset(
      imageUrl!,
      height: height,
      width: width,
      alignment: alignment ?? Alignment.center,
      fit: fit ?? BoxFit.cover,
      color: color,
      semanticLabel: semanticLabel,
      cacheWidth: cacheWidth ?? _calculateOptimalCache(context, width),
      cacheHeight: cacheHeight ?? _calculateOptimalCache(context, height),
      errorBuilder: (context, error, stackTrace) => _buildPlaceholder(context),
    );
  }

  Widget _buildPlaceholder(BuildContext context) {
    return Container(
      height: height,
      width: width,
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: radius,
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.no_photography_outlined,
              size: (height != null && height!.isFinite) 
                  ? (height! * 0.2).clamp(20.0, 48.0) 
                  : 32.0,
              color: Colors.grey.shade400,
            ),
            if (height == null || height! > 60) ...[
              SizedBox(height: 0.5.h),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 2.w),
                child: Text(
                  AppLocalizations.of(context)?.userNotUploadedPhoto ?? 'No photo',
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: Colors.grey.shade500,
                    fontSize: 7.sp,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
