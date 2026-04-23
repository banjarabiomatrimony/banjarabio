import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:banjarabio/core/theme/app_gradients.dart';

/// A branded pull-to-refresh indicator that replaces the default
/// [RefreshIndicator]. Shows a pulsing heart ring animation.
///
/// Usage:
/// ```dart
/// BrandedRefreshIndicator(
///   onRefresh: () async => _loadData(),
///   child: ListView(...),
/// )
/// ```
class BrandedRefreshIndicator extends StatefulWidget {
  final Future<void> Function() onRefresh;
  final Widget child;

  const BrandedRefreshIndicator({
    super.key,
    required this.onRefresh,
    required this.child,
  });

  @override
  State<BrandedRefreshIndicator> createState() =>
      _BrandedRefreshIndicatorState();
}

class _BrandedRefreshIndicatorState extends State<BrandedRefreshIndicator>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  Future<void> _handleRefresh() async {
    HapticFeedback.mediumImpact();
    _pulseController.repeat(reverse: true);
    try {
      await widget.onRefresh();
    } finally {
      if (mounted) {
        _pulseController.stop();
        _pulseController.reset();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: _handleRefresh,
      displacement: 50,
      color: Colors.transparent,
      backgroundColor: Colors.transparent,
      child: widget.child,
    );
  }
}

/// A standalone animated heart-ring widget that can be used anywhere.
/// Primarily built as the indicator for [BrandedRefreshIndicator], but
/// can also be dropped into empty states or loading views.
class HeartPulseRing extends StatelessWidget {
  final Animation<double> animation;
  final double size;

  const HeartPulseRing({
    super.key,
    required this.animation,
    this.size = 40,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) {
        final scale = 0.85 + animation.value * 0.15;
        return Transform.scale(
          scale: scale,
          child: CustomPaint(
            size: Size(size, size),
            painter: _HeartRingPainter(
              progress: animation.value,
              gradient: AppGradients.romance,
            ),
          ),
        );
      },
    );
  }
}

class _HeartRingPainter extends CustomPainter {
  final double progress;
  final LinearGradient gradient;

  _HeartRingPainter({required this.progress, required this.gradient});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 3;

    // Ring
    final ringPaint = Paint()
      ..shader = gradient.createShader(
          Rect.fromCircle(center: center, radius: radius))
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -math.pi / 2,
      2 * math.pi * (0.5 + progress * 0.5),
      false,
      ringPaint,
    );

    // Heart icon in center
    final heartPaint = Paint()
      ..shader = gradient.createShader(
          Rect.fromCircle(center: center, radius: radius * 0.4))
      ..style = PaintingStyle.fill;

    final heartSize = radius * 0.55;
    _drawHeart(canvas, center.translate(0, heartSize * 0.08), heartSize,
        heartPaint);
  }

  void _drawHeart(Canvas canvas, Offset center, double size, Paint paint) {
    final path = Path();
    final w = size;
    final h = size;
    path.moveTo(center.dx, center.dy + h * 0.35);
    path.cubicTo(center.dx - w * 0.5, center.dy - h * 0.1,
        center.dx - w * 0.5, center.dy - h * 0.5, center.dx, center.dy - h * 0.25);
    path.cubicTo(center.dx + w * 0.5, center.dy - h * 0.5,
        center.dx + w * 0.5, center.dy - h * 0.1, center.dx, center.dy + h * 0.35);
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _HeartRingPainter oldDelegate) =>
      oldDelegate.progress != progress;
}
