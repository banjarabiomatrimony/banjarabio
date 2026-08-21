import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import 'package:banjarabio/core/models/trust_score_config.dart';
import 'package:banjarabio/core/constants/app_typography.dart';
import 'package:banjarabio/theme/app_colors.dart';

/// A premium trust-score ring badge that shows a radial progress arc,
/// color-coded tier label, and optional sparkle overlay on Gold+ profiles.
class TrustScoreBadge extends StatefulWidget {
  final int score;

  /// Use [size] to control the overall diameter. Defaults to 5.h.
  final double? size;

  /// If true, show the tier label below the ring (for profile detail).
  final bool showLabel;

  /// 🧬 EXTREME PERFORMANCE: If true, disable animations and complex painting
  final bool isGhosting;

  const TrustScoreBadge({
    super.key,
    required this.score,
    this.size,
    this.showLabel = false,
    this.isGhosting = false,
  });

  @override
  State<TrustScoreBadge> createState() => _TrustScoreBadgeState();
}

class _TrustScoreBadgeState extends State<TrustScoreBadge>
    with SingleTickerProviderStateMixin {
  late AnimationController _sparkleController;
  late Animation<double> _sparkleAnimation;

  @override
  void initState() {
    super.initState();
    _sparkleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    );
    _sparkleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _sparkleController, curve: Curves.easeInOut),
    );
    // Only run sparkle on Trusted+ (score >= 75)
    if (widget.score >= TrustScoreConfig.level3Threshold) {
      _sparkleController.forward();
    }
  }

  @override
  void dispose() {
    _sparkleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final diameter = widget.size ?? 5.h;
    final levelName = TrustScoreConfig.getLevelName(widget.score) ?? 'Basic';
    final levelColor = TrustScoreConfig.getLevelColor(widget.score);
    final progress = (widget.score / TrustScoreConfig.maxScore).clamp(0.0, 1.0);

    final Widget badge = SizedBox(
      width: diameter,
      height: diameter,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Background ring
          SizedBox.expand(
            child: CircularProgressIndicator(
              value: 1.0,
              strokeWidth: 2.5,
              color: levelColor.withValues(alpha: AppColors.opacity15),
              strokeCap: StrokeCap.round,
            ),
          ),

          // Progress arc
          SizedBox.expand(
            child: CircularProgressIndicator(
              value: progress,
              strokeWidth: 2.5,
              color: levelColor,
              strokeCap: StrokeCap.round,
            ),
          ),

          // Shield icon
          Icon(
            widget.score >= TrustScoreConfig.level4Threshold
                ? Icons.verified
                : Icons.shield,
            color: levelColor,
            size: diameter * 0.45,
          ),

          // Sparkle overlay for Trusted+ scores
          // 🧬 EXTREME SCALE: Disable sparkle during hyper-scroll
          if (widget.score >= TrustScoreConfig.level3Threshold && !widget.isGhosting)
            AnimatedBuilder(
              animation: _sparkleAnimation,
              builder: (context, child) {
                return CustomPaint(
                  size: Size(diameter, diameter),
                  painter: _SparklePainter(
                    progress: _sparkleAnimation.value,
                    color: levelColor,
                  ),
                );
              },
            ),
        ],
      ),
    );

    final Widget result = widget.showLabel
        ? Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              badge,
              SizedBox(height: 0.3.h),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 1.5.w, vertical: 0.15.h),
                decoration: BoxDecoration(
                  color: levelColor.withValues(alpha: AppColors.opacity12),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  levelName,
                  style: TextStyle(
                    color: levelColor,
                    fontSize: AppTypography.labelSmall,
                    fontWeight: AppTypography.bold,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ],
          )
        : badge;

    return Semantics(
      label: 'Trust Score: ${widget.score} percent',
      child: result,
    );
  }
}

/// Paints tiny sparkle points around the badge ring.
class _SparklePainter extends CustomPainter {
  final double progress;
  final Color color;

  _SparklePainter({required this.progress, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;
    final paint = Paint()
      ..color = color.withValues(alpha: 0.3 + progress * 0.4)
      ..style = PaintingStyle.fill;

    // Draw 4 sparkle dots at cardinal offsets
    const sparkleCount = 4;
    for (int i = 0; i < sparkleCount; i++) {
      final angle = (i * math.pi / 2) + (progress * math.pi * 0.25);
      final sparkleRadius = 1.2 + progress * 0.8;
      final x = center.dx + (radius - 1) * math.cos(angle);
      final y = center.dy + (radius - 1) * math.sin(angle);
      canvas.drawCircle(Offset(x, y), sparkleRadius, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _SparklePainter oldDelegate) =>
      oldDelegate.progress != progress;
}
