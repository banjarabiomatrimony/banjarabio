import 'dart:ui' as ui;
import 'package:flutter/widgets.dart';

/// 📐 Layer 2: Display Decoding & GPU RAM Optimizer
///
/// Portable & self-contained policy for calculating optimal `memCacheWidth` and
/// `memCacheHeight` constraints on network images (such as CachedNetworkImage).
///
/// Why this matters:
/// Without decode constraints, Flutter decodes remote images at native resolution
/// (e.g. 4000x3000 = ~48 MB RAM per bitmap).
/// By computing the target screen render size multiplied by devicePixelRatio,
/// this policy restricts decoded bitmaps to ~1.2 MB – 2.5 MB with ZERO visual loss.
///
/// Can be copied and pasted directly into any Flutter project.
class DisplayCachePolicy {
  DisplayCachePolicy._();

  /// Default baseline target width for standard card/feed images (in physical pixels).
  static const int defaultCardWidth = 720;

  /// Default baseline target width for thumbnail/grid images.
  static const int defaultThumbnailWidth = 320;

  /// Default baseline target width for small avatars.
  static const int defaultAvatarWidth = 160;

  /// Resolves the current device pixel ratio safely.
  static double getDevicePixelRatio([BuildContext? context]) {
    if (context != null) {
      try {
        return MediaQuery.of(context).devicePixelRatio;
      } catch (_) {}
    }
    try {
      return ui.PlatformDispatcher.instance.views.first.devicePixelRatio;
    } catch (_) {
      return 2.0; // Standard modern fallback (HDPI)
    }
  }

  /// Checks if the device is currently in landscape orientation.
  static bool isLandscape([BuildContext? context]) {
    if (context != null) {
      try {
        return MediaQuery.of(context).orientation == Orientation.landscape;
      } catch (_) {}
    }
    try {
      final size = ui.PlatformDispatcher.instance.views.first.physicalSize;
      return size.width > size.height;
    } catch (_) {
      return false;
    }
  }

  /// Checks if the screen width represents a tablet, foldable, or desktop screen (width >= 600dp).
  static bool isTabletOrDesktop([BuildContext? context]) {
    if (context != null) {
      try {
        return MediaQuery.of(context).size.width >= 600;
      } catch (_) {}
    }
    try {
      final view = ui.PlatformDispatcher.instance.views.first;
      final logicalWidth = view.physicalSize.width / view.devicePixelRatio;
      return logicalWidth >= 600;
    } catch (_) {
      return false;
    }
  }

  /// Calculates optimal `memCacheWidth` for full-width feed / profile cards.
  /// Automatically adapts if device is in landscape or multi-pane tablet layout.
  static int getCardCacheWidth([BuildContext? context]) {
    if (context != null) {
      try {
        final screenWidth = MediaQuery.of(context).size.width;
        final dpr = MediaQuery.of(context).devicePixelRatio;
        final landscape = MediaQuery.of(context).orientation == Orientation.landscape;

        // In landscape or wide tablet view, cards typically occupy a multi-column pane (~40-50% width)
        final effectiveWidth = landscape || screenWidth >= 600 ? (screenWidth * 0.5) : screenWidth;
        final target = (effectiveWidth * dpr).round();
        return target.clamp(480, 1080);
      } catch (_) {}
    }
    return defaultCardWidth;
  }

  /// Calculates optimal `memCacheWidth` for 2-column or 3-column grid thumbnails.
  static int getThumbnailCacheWidth([BuildContext? context]) {
    if (context != null) {
      try {
        final screenWidth = MediaQuery.of(context).size.width;
        final dpr = MediaQuery.of(context).devicePixelRatio;
        final landscape = MediaQuery.of(context).orientation == Orientation.landscape;

        // Grid columns: 2 on portrait, 3 or 4 on landscape/tablet
        final columns = landscape || screenWidth >= 600 ? 3.0 : 2.0;
        final target = ((screenWidth / columns) * dpr).round();
        return target.clamp(240, 540);
      } catch (_) {}
    }
    return defaultThumbnailWidth;
  }

  /// Calculates optimal `memCacheWidth` specifically for dual-pane tablet / master-detail views.
  static int getDualPaneCacheWidth([BuildContext? context, double paneFraction = 0.5]) {
    if (context != null) {
      try {
        final screenWidth = MediaQuery.of(context).size.width;
        final dpr = MediaQuery.of(context).devicePixelRatio;
        final target = ((screenWidth * paneFraction) * dpr).round();
        return target.clamp(360, 960);
      } catch (_) {}
    }
    return defaultCardWidth;
  }

  /// Calculates optimal `memCacheWidth` for circular avatars / header icons.
  static int getAvatarCacheWidth([BuildContext? context, double displayDiameter = 60.0]) {
    final dpr = getDevicePixelRatio(context);
    final target = (displayDiameter * dpr).round();
    return target.clamp(96, 256);
  }

  /// Generic helper: computes physical pixel decode constraints for any custom widget size.
  static int computeCustomCacheWidth(double logicalWidth, [BuildContext? context]) {
    final dpr = getDevicePixelRatio(context);
    return (logicalWidth * dpr).round().clamp(64, 1440);
  }

  /// Generic helper: computes physical pixel decode height constraints for any custom widget size.
  static int computeCustomCacheHeight(double logicalHeight, [BuildContext? context]) {
    final dpr = getDevicePixelRatio(context);
    return (logicalHeight * dpr).round().clamp(64, 2560);
  }
}
