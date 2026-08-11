import 'dart:async';
import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

/// A premium typing indicator with 3 bouncing dots.
///
/// Usage:
/// ```dart
/// TypingIndicator()
/// ```
class TypingIndicator extends StatefulWidget {
  final Color? dotColor;
  final double dotSize;

  const TypingIndicator({
    super.key,
    this.dotColor,
    this.dotSize = 8,
  });

  @override
  State<TypingIndicator> createState() => _TypingIndicatorState();
}

class _TypingIndicatorState extends State<TypingIndicator>
    with TickerProviderStateMixin {
  late List<AnimationController> _controllers;
  late List<Animation<double>> _animations;
  final List<Timer> _timers = [];

  @override
  void initState() {
    super.initState();
    _controllers = List.generate(
      3,
      (i) => AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 600),
      ),
    );

    _animations = _controllers.map((c) {
      return Tween<double>(begin: 0, end: -8).animate(
        CurvedAnimation(parent: c, curve: Curves.easeInOut),
      );
    }).toList();

    // Stagger the dot animations
    for (int i = 0; i < 3; i++) {
      _timers.add(Timer(Duration(milliseconds: i * 180), () {
        if (mounted) _controllers[i].repeat(reverse: true);
      }));
    }
  }

  @override
  void dispose() {
    for (final t in _timers) {
      t.cancel();
    }
    for (final c in _controllers) {
      c.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = widget.dotColor ?? theme.colorScheme.onSurfaceVariant;

    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: EdgeInsets.only(bottom: 1.h, right: 20.w),
        padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.5.h),
        decoration: BoxDecoration(
          color: theme.colorScheme.surfaceContainerHighest,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
            bottomRight: Radius.circular(20),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(3, (i) {
            return AnimatedBuilder(
              animation: _animations[i],
              builder: (context, child) {
                return Transform.translate(
                  offset: Offset(0, _animations[i].value),
                  child: Container(
                    margin: EdgeInsets.symmetric(horizontal: 1.w),
                    width: widget.dotSize,
                    height: widget.dotSize,
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.5 + (i * 0.15)),
                      shape: BoxShape.circle,
                    ),
                  ),
                );
              },
            );
          }),
        ),
      ),
    );
  }
}
