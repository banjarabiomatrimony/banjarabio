import 'package:flutter/material.dart';

/// Wraps a child widget and animates it with a staggered slide-up + fade-in
/// cascade effect. Use this in lists/grids so items appear one after another.
///
/// ```dart
/// GridView.builder(
///   itemBuilder: (context, index) => StaggeredListItem(
///     index: index,
///     child: ProfileCardWidget(...),
///   ),
/// )
/// ```
class StaggeredListItem extends StatefulWidget {
  final int index;
  final Widget child;
  final Duration delay;
  final Duration animationDuration;
  final double slideOffset;

  const StaggeredListItem({
    super.key,
    required this.index,
    required this.child,
    this.delay = const Duration(milliseconds: 60),
    this.animationDuration = const Duration(milliseconds: 500),
    this.slideOffset = 40.0,
  });

  @override
  State<StaggeredListItem> createState() => _StaggeredListItemState();
}

class _StaggeredListItemState extends State<StaggeredListItem>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.animationDuration,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.8, curve: Curves.easeOut),
      ),
    );

    _slideAnimation = Tween<Offset>(
      begin: Offset(0, widget.slideOffset),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeOutCubic,
      ),
    );

    // Stagger the start based on index
    Future.delayed(widget.delay * widget.index, () {
      if (mounted) _controller.forward();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Transform.translate(
          offset: _slideAnimation.value,
          child: Opacity(
            opacity: _fadeAnimation.value,
            child: widget.child,
          ),
        );
      },
    );
  }
}

/// Animates an entire column of children with a staggered cascade.
/// Useful for settings screens, profile sections, etc.
class StaggeredColumn extends StatelessWidget {
  final List<Widget> children;
  final Duration delay;
  final Duration animationDuration;
  final CrossAxisAlignment crossAxisAlignment;
  final MainAxisAlignment mainAxisAlignment;
  final MainAxisSize mainAxisSize;

  const StaggeredColumn({
    super.key,
    required this.children,
    this.delay = const Duration(milliseconds: 80),
    this.animationDuration = const Duration(milliseconds: 500),
    this.crossAxisAlignment = CrossAxisAlignment.start,
    this.mainAxisAlignment = MainAxisAlignment.start,
    this.mainAxisSize = MainAxisSize.max,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: crossAxisAlignment,
      mainAxisAlignment: mainAxisAlignment,
      mainAxisSize: mainAxisSize,
      children: [
        for (int i = 0; i < children.length; i++)
          StaggeredListItem(
            index: i,
            delay: delay,
            animationDuration: animationDuration,
            child: children[i],
          ),
      ],
    );
  }
}
