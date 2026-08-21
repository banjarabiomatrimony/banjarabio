import 'package:flutter/material.dart';

/// 🌊 High-Performance Staggered Entrance Animation Wrapper
/// Cascades items into view sequentially with smooth cubic deceleration and opacity fade.
class StaggeredFadeSlideWidget extends StatefulWidget {
  final int index;
  final Widget child;
  final Duration baseDelay;
  final Duration stepDelay;
  final Duration duration;
  final Offset slideOffset;

  const StaggeredFadeSlideWidget({
    super.key,
    required this.index,
    required this.child,
    this.baseDelay = Duration.zero,
    this.stepDelay = const Duration(milliseconds: 35),
    this.duration = const Duration(milliseconds: 300),
    this.slideOffset = const Offset(0, 0.08),
  });

  @override
  State<StaggeredFadeSlideWidget> createState() =>
      _StaggeredFadeSlideWidgetState();
}

class _StaggeredFadeSlideWidgetState extends State<StaggeredFadeSlideWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.duration,
    );
    _fadeAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
    );
    _slideAnimation = Tween<Offset>(
      begin: widget.slideOffset,
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
    ));

    final totalDelay = widget.baseDelay + (widget.stepDelay * widget.index);
    if (totalDelay == Duration.zero) {
      _controller.forward();
    } else {
      Future.delayed(totalDelay, () {
        if (mounted) {
          _controller.forward();
        }
      });
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: SlideTransition(
        position: _slideAnimation,
        child: widget.child,
      ),
    );
  }
}
