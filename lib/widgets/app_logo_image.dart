import 'package:flutter/material.dart';

import 'package:banjarabio/core/services/app_logo_service.dart';

/// Displays the app logo from global cache when available for instant load;
/// falls back to asset otherwise.
class AppLogoImage extends StatelessWidget {
  const AppLogoImage({
    super.key,
    this.width,
    this.height,
    this.fit = BoxFit.contain,
    this.color,
    this.opacity,
  });

  final double? width;
  final double? height;
  final BoxFit fit;
  final Color? color;
  final double? opacity;

  @override
  Widget build(BuildContext context) {
    final bytes = AppLogoService.instance.logoBytes;
    Widget image;
    if (bytes != null) {
      image = Image.memory(
        bytes,
        width: width,
        height: height,
        fit: fit,
        color: color,
      );
    } else {
      image = Image.asset(
        'assets/logo/BanjaraBio.png',
        width: width,
        height: height,
        fit: fit,
        color: color,
      );
    }
    if (opacity != null) {
      image = Opacity(opacity: opacity!, child: image);
    }
    return image;
  }
}
