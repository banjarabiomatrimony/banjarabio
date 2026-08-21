import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// ⚡ Universal Tactile Spring Interactive Wrapper
/// Provides a snappy 100ms spring scale compression with light haptic feedback.
class TactilePressable extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final double pressedScale;
  final Duration duration;
  final HitTestBehavior behavior;

  const TactilePressable({
    super.key,
    required this.child,
    this.onTap,
    this.onLongPress,
    this.pressedScale = 0.94,
    this.duration = const Duration(milliseconds: 100),
    this.behavior = HitTestBehavior.opaque,
  });

  @override
  State<TactilePressable> createState() => _TactilePressableState();
}

class _TactilePressableState extends State<TactilePressable>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.duration,
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: widget.pressedScale,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleTapDown(TapDownDetails _) {
    if (widget.onTap != null || widget.onLongPress != null) {
      _controller.forward();
    }
  }

  void _handleTapUp(TapUpDetails _) {
    if (widget.onTap != null) {
      _controller.reverse();
      HapticFeedback.lightImpact();
      widget.onTap!();
    } else {
      _controller.reverse();
    }
  }

  void _handleTapCancel() {
    _controller.reverse();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.onTap == null && widget.onLongPress == null) {
      return widget.child;
    }

    return GestureDetector(
      behavior: widget.behavior,
      onTapDown: _handleTapDown,
      onTapUp: _handleTapUp,
      onTapCancel: _handleTapCancel,
      onLongPress: widget.onLongPress != null
          ? () {
              HapticFeedback.mediumImpact();
              widget.onLongPress!();
            }
          : null,
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: widget.child,
      ),
    );
  }
}
