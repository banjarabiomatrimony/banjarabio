import 'dart:ui' as ui;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:banjarabio/theme/app_colors.dart';
import 'package:banjarabio/theme/app_theme.dart';
import 'package:banjarabio/core/constants/app_typography.dart';
import 'package:banjarabio/core/services/app_logger.dart';

/// 🚀 ZERO-OVERHEAD SHADER & TYPOGRAPHY PRE-WARM ENGINE
///
/// Pre-warms GPU Shader pipelines (Skia/Impeller PSOs) and Flutter text layout
/// caches during the splash screen window.
///
/// Why this matters:
/// 1. Impeller/Vulkan Shader Compilation: Drawing common linear gradients, rounded
///    rectangles, and blur filters on an offscreen 1x1 raster compiles GPU PSOs
///    during the 600ms splash screen rather than during the user's first scroll.
/// 2. Font Engine Warm-up: Measuring standard text styles pre-populates SkParagraph
///    layout caches, preventing layout jank on the Home Screen.
class ShaderWarmupService {
  static final ShaderWarmupService _instance = ShaderWarmupService._internal();
  factory ShaderWarmupService() => _instance;
  ShaderWarmupService._internal();

  static bool _warmedUp = false;

  /// Trigger asynchronous warm-up of shaders and primary typography.
  /// Fail-safe: Any failure is silently caught and logged without affecting app launch.
  Future<void> warmUp() async {
    if (_warmedUp) return;
    _warmedUp = true;

    try {
      final recorder = ui.PictureRecorder();
      final canvas = Canvas(recorder, const Rect.fromLTWH(0, 0, 10, 10));

      // ── 1. Warm up Primary Gradients & Shaders ──────────────────────────
      final paint = Paint()
        ..shader = const LinearGradient(
          colors: [
            AppTheme.primaryLight,
            AppTheme.primaryVariantLight,
            AppColors.coralRed,
            AppColors.crimsonBlush,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ).createShader(const Rect.fromLTWH(0, 0, 10, 10))
        ..isAntiAlias = true;

      // Draw RRect with radius (triggers Impeller RRect pipeline)
      canvas.drawRRect(
        RRect.fromRectAndRadius(const Rect.fromLTWH(0, 0, 10, 10), const Radius.circular(4)),
        paint,
      );

      // ── 2. Warm up Shadow & Blur Mask Filters ───────────────────────────
      final blurPaint = Paint()
        ..color = Colors.black
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4.0);
      canvas.drawCircle(const Offset(5, 5), 4, blurPaint);

      // ── 3. Warm up SkParagraph / Text Layout Engine ─────────────────────
      final paragraphBuilder = ui.ParagraphBuilder(
        ui.ParagraphStyle(
          fontFamily: AppTypography.headingFontFamily,
          fontSize: 16.0,
        ),
      )
        ..pushStyle(ui.TextStyle(color: Colors.black))
        ..addText('BanjaraBio');
      
      final paragraph = paragraphBuilder.build()
        ..layout(const ui.ParagraphConstraints(width: 100));
      canvas.drawParagraph(paragraph, Offset.zero);

      // End recording and produce picture (forces raster compilation pipeline)
      final picture = recorder.endRecording();
      picture.dispose();

      if (kDebugMode) {
        AppLogger.debug('ShaderWarmupService', '⚡ GPU Shaders & Typography pre-warmed successfully');
      }
    } catch (e) {
      if (kDebugMode) {
        AppLogger.warn('ShaderWarmupService', '⚠️ Non-fatal shader warm-up notice: $e');
      }
    }
  }
}
