import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:banjarabio/widgets/tactile/tactile_pressable.dart';
import 'package:banjarabio/theme/app_colors.dart';

/// 🔘 Universal Tactile Glassmorphic Action Button
/// Features a modern 36x36 rounded container with frosted backdrop,
/// subtle border, and 100ms spring scale physics for AppBar actions.
class TactileActionButton extends StatelessWidget {
  final Widget? icon;
  final IconData? iconData;
  final VoidCallback onPressed;
  final Color? iconColor;
  final Color? backgroundColor;
  final double size;
  final String? tooltip;
  final EdgeInsetsGeometry? margin;

  const TactileActionButton({
    super.key,
    this.icon,
    this.iconData,
    required this.onPressed,
    this.iconColor,
    this.backgroundColor,
    this.size = 38,
    this.tooltip,
    this.margin,
  }) : assert(icon != null || iconData != null, 'Either icon or iconData must be provided');

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final resolvedBg = backgroundColor ??
        (isDark
            ? AppColors.canvasNearBlack.withValues(alpha: 0.82)
            : Colors.white.withValues(alpha: AppColors.opacity90));

    final resolvedBorder = isDark
        ? Colors.white.withValues(alpha: AppColors.opacity15)
        : Colors.black.withValues(alpha: AppColors.opacity8);

    final resolvedIconColor = iconColor ?? theme.colorScheme.onSurface;

    final Widget button = Padding(
      padding: margin ?? const EdgeInsets.all(6.0),
      child: TactilePressable(
        onTap: onPressed,
        pressedScale: 0.92,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(size / 2),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Container(
              width: size,
              height: size,
              decoration: BoxDecoration(
                color: resolvedBg,
                shape: BoxShape.circle,
                border: Border.all(
                  color: resolvedBorder,
                  width: 1.1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: isDark ? 0.25 : 0.08),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Center(
                child: icon ??
                    Icon(
                      iconData,
                      size: 19,
                      color: resolvedIconColor,
                    ),
              ),
            ),
          ),
        ),
      ),
    );

    if (tooltip != null) {
      return Tooltip(message: tooltip!, child: button);
    }
    return button;
  }
}
