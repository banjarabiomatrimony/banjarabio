import 'dart:math' as math;
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';

/// ⚡ Layer 5: Progressive Micro-Placeholders & Smooth Skeleton Transitions
///
/// Portable & self-contained widget builders for network image placeholders,
/// animated shimmers, BlurHash decoders, and error states.
///
/// Why this matters:
/// Prevents the jarring "grey box pop-in" effect during fast list scrolling.
/// Provides perceived instant loading with silky smooth micro-animations and
/// zero-dependency BlurHash rendering.
///
/// Can be copied and pasted directly into any Flutter project.
class ProgressivePlaceholderBuilder {
  ProgressivePlaceholderBuilder._();

  /// Builds an adaptive progressive placeholder:
  /// Uses [blurHash] if provided and valid; otherwise renders an animated shimmer skeleton.
  static Widget buildAdaptivePlaceholder({
    String? blurHash,
    double? width,
    double? height,
    BorderRadius? borderRadius,
    Color? baseColor,
    Color? highlightColor,
  }) {
    if (blurHash != null && blurHash.trim().length >= 6) {
      return buildBlurHashPlaceholder(
        blurHash: blurHash.trim(),
        width: width,
        height: height,
        borderRadius: borderRadius,
      );
    }

    return buildShimmerPlaceholder(
      width: width,
      height: height,
      borderRadius: borderRadius,
      baseColor: baseColor,
      highlightColor: highlightColor,
    );
  }

  /// Builds a lightweight pulsing skeleton placeholder for loading images.
  static Widget buildShimmerPlaceholder({
    double? width,
    double? height,
    BorderRadius? borderRadius,
    Color? baseColor,
    Color? highlightColor,
  }) {
    return _PulsingSkeleton(
      width: width,
      height: height,
      borderRadius: borderRadius ?? BorderRadius.circular(8.0),
      baseColor: baseColor,
      highlightColor: highlightColor,
    );
  }

  /// Builds a zero-dependency progressive BlurHash placeholder.
  static Widget buildBlurHashPlaceholder({
    required String blurHash,
    double? width,
    double? height,
    BorderRadius? borderRadius,
    BoxFit fit = BoxFit.cover,
  }) {
    return ClipRRect(
      borderRadius: borderRadius ?? BorderRadius.circular(8.0),
      child: SizedBox(
        width: width,
        height: height,
        child: _BlurHashImageWidget(
          blurHash: blurHash,
          fit: fit,
        ),
      ),
    );
  }

  /// Builds a graceful, user-friendly error placeholder when an image fails to load.
  static Widget buildErrorFallback({
    double? width,
    double? height,
    IconData errorIcon = Icons.broken_image_rounded,
    String? fallbackLabel,
    BorderRadius? borderRadius,
  }) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E24),
        borderRadius: borderRadius ?? BorderRadius.circular(8.0),
      ),
      alignment: Alignment.center,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            errorIcon,
            color: Colors.white38,
            size: 28.0,
          ),
          if (fallbackLabel != null && fallbackLabel.isNotEmpty) ...[
            const SizedBox(height: 4.0),
            Text(
              fallbackLabel,
              style: const TextStyle(
                color: Colors.white38,
                fontSize: 11.0,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ],
      ),
    );
  }

  /// Standard placeholder builder compatible with CachedNetworkImage.placeholder.
  static Widget Function(BuildContext, String) placeholderCallback({
    String? blurHash,
    double? width,
    double? height,
    BorderRadius? borderRadius,
  }) {
    return (BuildContext context, String url) => buildAdaptivePlaceholder(
          blurHash: blurHash,
          width: width,
          height: height,
          borderRadius: borderRadius,
        );
  }

  /// Standard error builder compatible with CachedNetworkImage.errorWidget.
  static Widget Function(BuildContext, String, dynamic) errorCallback({
    double? width,
    double? height,
    BorderRadius? borderRadius,
  }) {
    return (BuildContext context, String url, dynamic error) => buildErrorFallback(
          width: width,
          height: height,
          borderRadius: borderRadius,
        );
  }
}

/// Internal self-contained pulsating skeleton with zero external package dependencies.
class _PulsingSkeleton extends StatefulWidget {
  final double? width;
  final double? height;
  final BorderRadius borderRadius;
  final Color? baseColor;
  final Color? highlightColor;

  const _PulsingSkeleton({
    this.width,
    this.height,
    required this.borderRadius,
    this.baseColor,
    this.highlightColor,
  });

  @override
  State<_PulsingSkeleton> createState() => _PulsingSkeletonState();
}

class _PulsingSkeletonState extends State<_PulsingSkeleton> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);

    _animation = Tween<double>(begin: 0.35, end: 0.85).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final defaultBase = isDark ? const Color(0xFF1E1E24) : const Color(0xFFE0E0E0);

    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Container(
          width: widget.width,
          height: widget.height,
          decoration: BoxDecoration(
            color: (widget.baseColor ?? defaultBase).withValues(alpha: _animation.value),
            borderRadius: widget.borderRadius,
          ),
        );
      },
    );
  }
}

/// Internal lightweight zero-dependency BlurHash renderer
class _BlurHashImageWidget extends StatefulWidget {
  final String blurHash;
  final BoxFit fit;

  const _BlurHashImageWidget({
    required this.blurHash,
    this.fit = BoxFit.cover,
  });

  @override
  State<_BlurHashImageWidget> createState() => _BlurHashImageWidgetState();
}

class _BlurHashImageWidgetState extends State<_BlurHashImageWidget> {
  ui.Image? _decodedImage;

  @override
  void initState() {
    super.initState();
    _decodeBlurHash();
  }

  @override
  void didUpdateWidget(covariant _BlurHashImageWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.blurHash != widget.blurHash) {
      _decodeBlurHash();
    }
  }

  Future<void> _decodeBlurHash() async {
    try {
      final image = await _BlurHashDecoder.decodeToImage(widget.blurHash, 32, 32);
      if (mounted) {
        setState(() {
          _decodedImage = image;
        });
      }
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    if (_decodedImage == null) {
      return Container(color: const Color(0xFF23232A));
    }
    return RawImage(
      image: _decodedImage,
      fit: widget.fit,
      filterQuality: FilterQuality.low,
    );
  }
}

/// Compact BlurHash Base83 Algorithm Decoder in pure Dart
class _BlurHashDecoder {
  static const _characters = r'0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz#$%*+,-.:;=?@[]^_{|}~';

  static int _decode83(String str, int from, int to) {
    var result = 0;
    for (var i = from; i < to; i++) {
      final index = _characters.indexOf(str[i]);
      if (index != -1) {
        result = result * 83 + index;
      }
    }
    return result;
  }

  static double _srgbToLinear(int value) {
    final v = value / 255.0;
    return v <= 0.04045 ? v / 12.92 : math.pow((v + 0.055) / 1.055, 2.4).toDouble();
  }

  static int _linearToSrgb(double value) {
    final v = value.clamp(0.0, 1.0);
    return ((v <= 0.0031308 ? v * 12.92 : 1.055 * math.pow(v, 1 / 2.4) - 0.055) * 255 + 0.5).toInt();
  }

  static Future<ui.Image> decodeToImage(String blurHash, int width, int height) async {
    final sizeInfo = _decode83(blurHash, 0, 1);
    final sizeY = (sizeInfo ~/ 9) + 1;
    final sizeX = (sizeInfo % 9) + 1;

    final quantisedMaxAc = _decode83(blurHash, 1, 2);
    final maxValue = (quantisedMaxAc + 1) / 166.0;

    final colors = <List<double>>[];
    for (var i = 0; i < sizeX * sizeY; i++) {
      if (i == 0) {
        final value = _decode83(blurHash, 2, 6);
        colors.add([
          _srgbToLinear((value >> 16) & 255),
          _srgbToLinear((value >> 8) & 255),
          _srgbToLinear(value & 255),
        ]);
      } else {
        final value = _decode83(blurHash, 4 + i * 2, 6 + i * 2);
        colors.add([
          _signPow(((value ~/ (19 * 19)) - 9) / 9.0, 2.0) * maxValue,
          _signPow((((value ~/ 19) % 19) - 9) / 9.0, 2.0) * maxValue,
          _signPow(((value % 19) - 9) / 9.0, 2.0) * maxValue,
        ]);
      }
    }

    final pixels = Uint8List(width * height * 4);
    var pixelIndex = 0;

    for (var y = 0; y < height; y++) {
      for (var x = 0; x < width; x++) {
        var r = 0.0;
        var g = 0.0;
        var b = 0.0;

        for (var j = 0; j < sizeY; j++) {
          for (var i = 0; i < sizeX; i++) {
            final basis = math.cos((math.pi * x * i) / width) * math.cos((math.pi * y * j) / height);
            final color = colors[i + j * sizeX];
            r += color[0] * basis;
            g += color[1] * basis;
            b += color[2] * basis;
          }
        }

        pixels[pixelIndex++] = _linearToSrgb(r);
        pixels[pixelIndex++] = _linearToSrgb(g);
        pixels[pixelIndex++] = _linearToSrgb(b);
        pixels[pixelIndex++] = 255;
      }
    }

    final descriptor = await ui.ImmutableBuffer.fromUint8List(pixels);
    final imageDescriptor = ui.ImageDescriptor.raw(
      descriptor,
      width: width,
      height: height,
      pixelFormat: ui.PixelFormat.rgba8888,
    );
    final codec = await imageDescriptor.instantiateCodec();
    final frame = await codec.getNextFrame();
    return frame.image;
  }

  static double _signPow(double val, double exp) {
    return math.pow(val.abs(), exp).toDouble() * (val < 0 ? -1 : 1);
  }
}
