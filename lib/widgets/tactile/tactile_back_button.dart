import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:banjarabio/widgets/tactile/tactile_pressable.dart';
import 'package:banjarabio/theme/app_colors.dart';

/// ⬅️ Universal Tactile Glassmorphic Back Button
/// Features a modern 36x36 rounded container with frosted backdrop,
/// subtle border, 100ms spring scale physics, and iOS-style chevron.
class TactileBackButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final Color? iconColor;
  final Color? backgroundColor;
  final double size;
  final EdgeInsetsGeometry? margin;

  const TactileBackButton({
    super.key,
    this.onPressed,
    this.iconColor,
    this.backgroundColor,
    this.size = 38,
    this.margin,
  });

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

    return Padding(
      padding: margin ?? const EdgeInsets.all(6.0),
      child: TactilePressable(
        onTap: onPressed ??
            () {
              Navigator.maybePop(context);
            },
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
                child: Padding(
                  padding: const EdgeInsets.only(right: 1.5),
                  child: Icon(
                    Icons.arrow_back_ios_new_rounded,
                    size: 17,
                    color: resolvedIconColor,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
