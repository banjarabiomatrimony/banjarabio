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
import 'package:banjarabio/core/services/app_logger.dart';
import 'package:banjarabio/core/constants/app_typography.dart';


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

class CustomImageWidget extends StatefulWidget {
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
            AppLogger.error('CustomImageWidget', 'Precache Background Error ($optimizedUrl): $exception');
          },
        );
      } catch (e) {
        AppLogger.error('CustomImageWidget', 'Precache Sync Error ($optimizedUrl): $e');
      }
    }
  }

  @override
  State<CustomImageWidget> createState() => _CustomImageWidgetState();
}

class _CustomImageWidgetState extends State<CustomImageWidget> {
  String? _currentUrl;
  bool _hasFailedOptimized = false;

  @override
  void initState() {
    super.initState();
    _currentUrl = widget.imageUrl;
  }

  @override
  void didUpdateWidget(CustomImageWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.imageUrl != widget.imageUrl) {
      _currentUrl = widget.imageUrl;
      _hasFailedOptimized = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return widget.alignment != null
        ? Align(alignment: widget.alignment!, child: _buildWidget(context))
        : _buildWidget(context);
  }

  Widget _buildWidget(BuildContext context) {
    return Padding(
      padding: widget.margin ?? EdgeInsets.zero,
      child: Material(
        type: MaterialType.transparency,
        child: InkWell(
          onTap: widget.onTap,
          borderRadius: widget.radius,
          child: _buildCircleImage(context),
        ),
      ),
    );
  }

  Widget _buildCircleImage(BuildContext context) {
    if (widget.radius != null) {
      return ClipRRect(
        borderRadius: widget.radius ?? BorderRadius.zero,
        child: _buildImageWithBorder(context),
      );
    } else {
      return _buildImageWithBorder(context);
    }
  }

  Widget _buildImageWithBorder(BuildContext context) {
    if (widget.border != null) {
      return Container(
        decoration: BoxDecoration(border: widget.border, borderRadius: widget.radius),
        child: _buildImageView(context),
      );
    } else {
      return _buildImageView(context);
    }
  }

  Widget _buildImageView(BuildContext context) {
    if (_currentUrl == null || _currentUrl!.isEmpty) {
      return _buildPlaceholder(context);
    }

    switch (_currentUrl!.imageType) {
      case ImageType.svg:
        return SizedBox(
          height: widget.height,
          width: widget.width,
          child: SvgPicture.asset(
            _currentUrl!,
            height: widget.height,
            width: widget.width,
            fit: widget.fit ?? BoxFit.contain,
            colorFilter: widget.color != null
                ? ColorFilter.mode(widget.color!, BlendMode.srcIn)
                : null,
            semanticsLabel: widget.semanticLabel,
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
        _currentUrl!,
        height: widget.height,
        width: widget.width,
        alignment: widget.alignment ?? Alignment.center,
        fit: widget.fit ?? BoxFit.cover,
        color: widget.color,
        semanticLabel: widget.semanticLabel,
        errorBuilder: (context, error, stackTrace) => _buildPlaceholder(context),
      );
    }

    return Image.file(
      io.File(_currentUrl!.replaceFirst('file://', '')),
      height: widget.height,
      width: widget.width,
      alignment: widget.alignment ?? Alignment.center,
      fit: widget.fit ?? BoxFit.cover,
      color: widget.color,
      semanticLabel: widget.semanticLabel,
      cacheWidth: widget.cacheWidth ?? _calculateOptimalCache(context, widget.width),
      cacheHeight: widget.cacheHeight ?? _calculateOptimalCache(context, widget.height),
      gaplessPlayback: true,
      errorBuilder: (context, error, stackTrace) => _buildPlaceholder(context),
    );
  }

  Widget _buildNetworkImage(BuildContext context) {
    // 🧬 PRO SCALE: Append resizing parameters to the URL
    // This significantly reduces memory usage on low-end devices by delivering
    // an image that matches the widget's physical dimensions.
    String optimizedUrl = _currentUrl!;
    if (!_hasFailedOptimized) {
      try {
        final photoRepo = PhotoRepository();
        final networkService = NetworkAwareQualityService();
        
        final dpr = MediaQuery.maybeOf(context)?.devicePixelRatio ?? 1.0;
        final speed = networkService.cachedSpeed;
        final params = networkService.getOptimizationParams(
          isHighQuality: widget.isHighQuality,
          forcedSpeed: speed,
        );
        
        // Calculate logical dimensions into physical pixels
        int? targetWidth;
        int? targetHeight;
        
        if (widget.width != null && widget.width! > 0 && widget.width!.isFinite) {
          targetWidth = (widget.width! * dpr).round();
        }
        if (widget.height != null && widget.height! > 0 && widget.height!.isFinite) {
          targetHeight = (widget.height! * dpr).round();
        }

        // If dimensions are missing, use network-aware defaults
        if (targetWidth == null && targetHeight == null) {
          targetWidth = params['targetWidth']; 
        }

        optimizedUrl = photoRepo.getResizedUrl(
          _currentUrl!,
          width: targetWidth,
          height: targetHeight,
          quality: params['quality']!,
        );
      } catch (e) {
        AppLogger.error('CustomImageWidget', 'Image Optimization Error: $e');
      }
    }

    return CachedNetworkImage(
      height: widget.height,
      width: widget.width,
      fit: widget.fit,
      alignment: widget.alignment ?? Alignment.center,
      imageUrl: optimizedUrl,
      color: widget.color,
      cacheManager: PersistentCacheManager.instance,
      // Stable key: strip ?width=&quality= so ANY transformation of the same
      // photo resolves to the SAME local disk entry. Once downloaded once,
      // this image is NEVER fetched from Supabase again (365-day TTL).
      cacheKey: PersistentCacheManager.stableKeyFor(optimizedUrl),
      memCacheWidth: widget.cacheWidth ?? _calculateOptimalCache(context, widget.width),
      memCacheHeight: widget.cacheHeight ?? _calculateOptimalCache(context, widget.height),
      // 🚨 SIGNAL 3 FIX: Removed LQIP (dual-image) placeholder.
      // Previously each card loaded BOTH a 50px thumbnail AND the full image
      // simultaneously, causing 40+ concurrent gralloc4 allocations with 20 cards.
      // Now uses shimmer-only placeholder to cut concurrent image ops in half.
      placeholder: (context, url) => ShimmerWidget.rectangular(
        height: widget.height ?? double.infinity,
        width: widget.width ?? double.infinity,
        shapeBorder: RoundedRectangleBorder(
          borderRadius: widget.radius ?? BorderRadius.zero,
        ),
      ),
      errorWidget: (context, url, error) {
        // Fall back to original URL if optimization failed
        if (!_hasFailedOptimized && widget.imageUrl != null && optimizedUrl != widget.imageUrl) {
          AppLogger.warn('CustomImageWidget', 'Optimized image failed to load ($optimizedUrl). Falling back to original.');
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) {
              setState(() {
                _currentUrl = widget.imageUrl;
                _hasFailedOptimized = true;
              });
            }
          });
        }
        return widget.errorWidget ?? _buildPlaceholder(context);
      },
    );
  }

  Widget _buildAssetImage(BuildContext context) {
    return Image.asset(
      _currentUrl!,
      height: widget.height,
      width: widget.width,
      alignment: widget.alignment ?? Alignment.center,
      fit: widget.fit ?? BoxFit.cover,
      color: widget.color,
      semanticLabel: widget.semanticLabel,
      cacheWidth: widget.cacheWidth ?? _calculateOptimalCache(context, widget.width),
      cacheHeight: widget.cacheHeight ?? _calculateOptimalCache(context, widget.height),
      errorBuilder: (context, error, stackTrace) => _buildPlaceholder(context),
    );
  }

  Widget _buildPlaceholder(BuildContext context) {
    return Container(
      height: widget.height,
      width: widget.width,
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: widget.radius,
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.no_photography_outlined,
              size: (widget.height != null && widget.height!.isFinite) 
                  ? (widget.height! * 0.2).clamp(20.0, 48.0) 
                  : 32.0,
              color: Colors.grey.shade400,
            ),
            if (widget.height == null || widget.height! > 60) ...[
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
                    fontSize: AppTypography.labelSmall,
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
