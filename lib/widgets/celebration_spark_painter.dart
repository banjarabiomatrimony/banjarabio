import 'dart:math' as math;
import 'package:flutter/material.dart';

/// 🎇 Premium Celebration Spark Painter
///
/// A physics-based particle burst that fires colored sparks upward
/// from a tapped nav-bar item. Each particle has:
///  • Randomised angle (biased upward)
///  • Randomised speed & size
///  • Gravity pull so sparks arc naturally
///  • Per-tab gradient colouring
///  • Mix of circles and 4-point sparkle stars
///  • Alpha fade-out over lifetime
class CelebrationSparkPainter extends CustomPainter {
  final int tappedIndex;
  final int itemCount;
  final double progress; // 0 → 1
  final double screenWidth;
  final List<Color> sparkColors;

  CelebrationSparkPainter({
    required this.tappedIndex,
    required this.itemCount,
    required this.progress,
    required this.screenWidth,
    required this.sparkColors,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (progress <= 0 || progress >= 1) return;

    final itemWidth = screenWidth / itemCount;
    final originX = itemWidth * tappedIndex + itemWidth / 2;
    final originY = size.height * 0.35; // burst from icon center area

    const int particleCount = 28;
    const double gravity = 220.0; // px/s² feel
    const double maxSpeed = 160.0;

    final rng = math.Random(tappedIndex * 1000 + 7);

    for (int i = 0; i < particleCount; i++) {
      // --- Angle: biased upward (–30° to –150° range) ---
      final baseAngle = -math.pi * 0.15 - rng.nextDouble() * math.pi * 0.7;
      // Add slight horizontal spread
      final angle = baseAngle + (rng.nextDouble() - 0.5) * 0.6;

      // --- Speed: varied ---
      final speed = 40 + rng.nextDouble() * maxSpeed;

      // --- Timing: stagger birth so they don't all fire at once ---
      final birthDelay = rng.nextDouble() * 0.15;
      final localT = (progress - birthDelay).clamp(0.0, 1.0);
      if (localT <= 0) continue;

      // --- Position with gravity ---
      final vx = speed * math.cos(angle);
      final vy = speed * math.sin(angle);
      final t = localT; // normalised time
      final px = originX + vx * t;
      final py = originY + vy * t + 0.5 * gravity * t * t;

      // --- Size: shrinks over lifetime ---
      final baseSize = 1.8 + rng.nextDouble() * 3.5;
      final particleSize = baseSize * (1.0 - localT * 0.7);
      if (particleSize <= 0.2) continue;

      // --- Alpha: fade out ---
      final alpha = (1.0 - localT).clamp(0.0, 1.0);
      if (alpha <= 0.02) continue;

      // --- Color: pick from spark gradient ---
      final colorIndex = i % sparkColors.length;
      final baseColor = sparkColors[colorIndex];
      final color = baseColor.withValues(alpha: alpha * 0.9);

      final paint = Paint()
        ..color = color
        ..style = PaintingStyle.fill;

      // --- Shape: alternate between circles and sparkle stars ---
      if (i % 4 == 0) {
        _drawSparkleStar(canvas, Offset(px, py), particleSize * 1.3, paint);
      } else {
        canvas.drawCircle(Offset(px, py), particleSize, paint);
      }
    }

    // --- Central glow flash (quick bright burst at origin) ---
    if (progress < 0.35) {
      final glowAlpha = (1.0 - progress / 0.35).clamp(0.0, 1.0);
      final glowPaint = Paint()
        ..shader = RadialGradient(
          colors: [
            sparkColors.first.withValues(alpha: glowAlpha * 0.6),
            Colors.transparent,
          ],
        ).createShader(
          Rect.fromCircle(center: Offset(originX, originY), radius: 30),
        )
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);
      canvas.drawCircle(Offset(originX, originY), 30, glowPaint);
    }
  }

  /// Draws a tiny 4-pointed sparkle star.
  void _drawSparkleStar(Canvas canvas, Offset center, double radius, Paint paint) {
    final path = Path();
    const int points = 4;
    const double innerRatio = 0.35;

    for (int i = 0; i < points * 2; i++) {
      final angle = (i * math.pi / points) - math.pi / 2;
      final r = (i.isEven) ? radius : radius * innerRatio;
      final x = center.dx + r * math.cos(angle);
      final y = center.dy + r * math.sin(angle);
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    path.close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(CelebrationSparkPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.tappedIndex != tappedIndex;
  }
}
