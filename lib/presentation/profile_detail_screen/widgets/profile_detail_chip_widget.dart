import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';

import 'package:banjarabio/widgets/custom_icon_widget.dart';
import 'package:banjarabio/core/constants/app_typography.dart';

/// A highly visual, luxury tactile mini-card for displaying profile details.
/// Features spring scale physics, soft ambient glow, glowing circular emblems,
/// and high-contrast typography matching the Settings/Menu design system.
class ProfileDetailChipWidget extends StatefulWidget {
  final String iconName;
  final String label;
  final String value;
  final Color tintColor;
  final bool fullWidth;
  final VoidCallback? onTap;
  final String? subtitle;
  final Widget? trailingBadge;

  const ProfileDetailChipWidget({
    super.key,
    required this.iconName,
    required this.label,
    required this.value,
    required this.tintColor,
    this.fullWidth = false,
    this.onTap,
    this.subtitle,
    this.trailingBadge,
  });

  @override
  State<ProfileDetailChipWidget> createState() =>
      _ProfileDetailChipWidgetState();
}

class _ProfileDetailChipWidgetState extends State<ProfileDetailChipWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
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
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return ScaleTransition(
      scale: _scaleAnimation,
      child: GestureDetector(
        onTapDown: (_) => _controller.forward(),
        onTapUp: (_) {
          _controller.reverse();
          if (widget.onTap != null) {
            HapticFeedback.lightImpact();
            widget.onTap!();
          }
        },
        onTapCancel: () => _controller.reverse(),
        child: Container(
          width: widget.fullWidth ? double.infinity : null,
          padding: EdgeInsets.symmetric(horizontal: 3.2.w, vertical: 1.3.h),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                widget.tintColor.withValues(alpha: isDark ? 0.12 : 0.07),
                widget.tintColor.withValues(alpha: isDark ? 0.04 : 0.02),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            color: theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: widget.tintColor.withValues(alpha: isDark ? 0.35 : 0.22),
              width: 1.1,
            ),
            boxShadow: [
              BoxShadow(
                color: widget.tintColor.withValues(alpha: isDark ? 0.12 : 0.05),
                blurRadius: 10,
                offset: const Offset(0, 3),
              ),
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.02),
                blurRadius: 4,
                offset: const Offset(0, 1),
              ),
            ],
          ),
          child: Row(
            children: [
              // Glowing Circular Emblem
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color:
                      widget.tintColor.withValues(alpha: isDark ? 0.22 : 0.12),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: widget.tintColor.withValues(alpha: 0.3),
                    width: 0.8,
                  ),
                ),
                child: Center(
                  child: CustomIconWidget(
                    iconName: widget.iconName,
                    color: widget.tintColor,
                    size: 19,
                  ),
                ),
              ),
              SizedBox(width: 3.w),

              // Text Content (Label + Main Value + Subtitle)
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            widget.label.toUpperCase(),
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant
                                  .withValues(alpha: 0.85),
                              fontWeight: AppTypography.extraBold,
                              letterSpacing: 0.4,
                              fontSize: AppTypography.labelSmall,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (widget.trailingBadge != null) widget.trailingBadge!,
                      ],
                    ),
                    SizedBox(height: 0.3.h),
                    Text(
                      widget.value,
                      style: theme.textTheme.titleSmall?.copyWith(
                        color: theme.colorScheme.onSurface,
                        fontWeight: AppTypography.extraBold,
                        fontSize: AppTypography.bodyMedium,
                        height: 1.2,
                        letterSpacing: -0.2,
                      ),
                      maxLines: widget.fullWidth ? 6 : 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (widget.subtitle != null &&
                        widget.subtitle!.isNotEmpty) ...[
                      SizedBox(height: 0.2.h),
                      Text(
                        widget.subtitle!,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant
                              .withValues(alpha: 0.75),
                          fontSize: AppTypography.labelTiny,
                          fontWeight: AppTypography.semiBold,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
