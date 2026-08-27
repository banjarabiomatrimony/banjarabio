import 'package:flutter/material.dart';

/// 🎨 [UpdateModalTheme]
///
/// Encapsulates theme tokens for update dialogs, bottom sheets, and buttons.
/// Allows complete brand adaptation for any Flutter application.
@immutable
class UpdateModalTheme {
  final Color? primaryColor;
  final Color? backgroundColor;
  final Color? cardColor;
  final Color? titleColor;
  final Color? bodyColor;
  final Color? noteBulletColor;
  final Widget? customLogo;
  final double borderRadius;
  final Gradient? primaryGradient;
  final TextStyle? titleStyle;
  final TextStyle? bodyStyle;

  const UpdateModalTheme({
    this.primaryColor,
    this.backgroundColor,
    this.cardColor,
    this.titleColor,
    this.bodyColor,
    this.noteBulletColor,
    this.customLogo,
    this.borderRadius = 24.0,
    this.primaryGradient,
    this.titleStyle,
    this.bodyStyle,
  });

  /// Derives active theme from BuildContext if custom tokens are omitted
  Color getResolvedPrimary(BuildContext context) {
    return primaryColor ?? Theme.of(context).colorScheme.primary;
  }

  Color getResolvedBackground(BuildContext context) {
    return backgroundColor ?? Theme.of(context).scaffoldBackgroundColor;
  }

  Color getResolvedCard(BuildContext context) {
    return cardColor ?? Theme.of(context).cardColor;
  }

  Color getResolvedTitle(BuildContext context) {
    return titleColor ?? Theme.of(context).textTheme.titleLarge?.color ?? Colors.black87;
  }

  Color getResolvedBody(BuildContext context) {
    return bodyColor ?? Theme.of(context).textTheme.bodyMedium?.color ?? Colors.black54;
  }
}
