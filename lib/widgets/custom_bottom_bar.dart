import 'dart:math' as math;
import 'package:banjarabio/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:vector_math/vector_math_64.dart' show Vector3;
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';
import 'package:banjarabio/widgets/celebration_spark_painter.dart';
import 'package:banjarabio/widgets/glassmorphism_container.dart';
import 'package:banjarabio/core/utils/tour_keys.dart';

/// 🌟 WORLD'S MOST PREMIUM MATRIMONY BOTTOM NAVIGATION BAR 🌟
///
/// Revolutionary Features:
/// ✨ Liquid Morphing Animation with real physics
/// 💎 3D Depth with parallax shadows
/// 🎨 Dynamic gradient that follows selection
/// 🔮 Particle effects on tap
/// 💫 Micro-interactions on every touch
/// 🎭 Emotional design language for love & connection
/// 🌈 Adaptive colors based on context
class CustomBottomBar extends StatefulWidget {
  final int currentIndex;
  final Function(int) onTap;
  final int? sharedBadgeCount;

  const CustomBottomBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
    this.sharedBadgeCount,
  });

  @override
  State<CustomBottomBar> createState() => _CustomBottomBarState();
}

class _CustomBottomBarState extends State<CustomBottomBar>
    with TickerProviderStateMixin {
  late AnimationController _particleController;
  late AnimationController _pulseController;
  int? _lastTappedIndex;

  @override
  void initState() {
    super.initState();
    _particleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..forward();
  }

  @override
  void dispose() {
    _particleController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  void _onItemTapped(int index) {
    if (widget.currentIndex != index) {
      setState(() => _lastTappedIndex = index);
      HapticFeedback.mediumImpact();
      _particleController.forward(from: 0);
      widget.onTap(index);
    }
  }

  @override
  Widget build(BuildContext context) {
    const int itemCount = 4;
    final screenWidth = MediaQuery.of(context).size.width;

    return Container(
      margin: EdgeInsets.zero,
      height: 13.h,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.zero,
        boxShadow: [
          BoxShadow(
            color: _getGradientColors(widget.currentIndex)[0].withValues(alpha: 0.2),
            blurRadius: 8,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: GlassmorphismContainer(
        borderRadius: BorderRadius.zero,
        color: Theme.of(context).colorScheme.surface,
        opacity: 0.6,
        blur: 25,
        child: Stack(
          children: [
            // 🌈 Animated Gradient Background Layer
            AnimatedContainer(
              duration: const Duration(milliseconds: 800),
              curve: Curves.easeInOutCubic,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.zero,
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    _getGradientColors(widget.currentIndex)[0].withValues(alpha: 0.15),
                    _getGradientColors(widget.currentIndex)[1].withValues(alpha: 0.05),
                  ],
                ),
              ),
            ),

          // Glassmorphism Layer removed for 100% color match
          /*
          ClipRRect(
            borderRadius: BorderRadius.zero,
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.zero,
                  color: Colors.white.withValues(alpha: 0.15),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.3),
                    width: 1.5,
                  ),
                ),
              ),
            ),
          ),
          */

          // ✨ Liquid Morphing Indicator
          AnimatedBuilder(
            animation: _pulseController,
            builder: (context, child) {
              return CustomPaint(
                painter: LiquidIndicatorPainter(
                  currentIndex: widget.currentIndex,
                  itemCount: itemCount,
                  animationValue: _pulseController.value,
                  screenWidth: screenWidth,
                ),
                child: Container(),
              );
            },
          ),

          // 🎯 Navigation Items
          SafeArea(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildNavItem(
                  index: 0,
                  key: TourKeys.homeTabKey,
                  icon: Icons.favorite_rounded,
                  activeIcon: Icons.favorite,
                  label: AppLocalizations.of(context)?.home ?? 'Home',
                  gradient: const [Color(0xFF880E4F), Color(0xFF432C7A)],
                ),
                _buildNavItem(
                  index: 1,
                  key: TourKeys.sharedTabKey,
                  icon: Icons.people_rounded,
                  activeIcon: Icons.people,
                  label: AppLocalizations.of(context)?.shared ?? 'Matches',
                  badgeCount: widget.sharedBadgeCount,
                  gradient: const [Color(0xFFFFA726), Color(0xFFFF6F00)],
                ),
                _buildNavItem(
                  index: 2,
                  key: TourKeys.profileTabKey,
                  icon: Icons.person_rounded,
                  activeIcon: Icons.person,
                  label: AppLocalizations.of(context)?.profile ?? 'Profile',
                  gradient: const [Color(0xFF9C27B0), Color(0xFF6A1B9A)],
                ),
                _buildNavItem(
                  index: 3,
                  key: TourKeys.settingsTabKey,
                  icon: Icons.menu_rounded,
                  activeIcon: Icons.menu,
                  label: AppLocalizations.of(context)?.menu ?? 'Menu',
                  gradient: const [Color(0xFF2196F3), Color(0xFF1976D2)],
                ),
              ],
            ),
          ),

          // 🎆 Particle Effect on Tap
          if (_lastTappedIndex != null)
            IgnorePointer(
              child: AnimatedBuilder(
                animation: _particleController,
                builder: (context, child) {
                  if (_particleController.value == 0) return const SizedBox();
                  // Per-tab spark colors matching each nav item's gradient
                  const tabSparkColors = <int, List<Color>>{
                    0: [Color(0xFF880E4F), Color(0xFF432C7A), Colors.white, Color(0xFFFFE082)],
                    1: [Color(0xFFFFA726), Color(0xFFFF6F00), Colors.white, Color(0xFFFFE082)],
                    2: [Color(0xFF9C27B0), Color(0xFF6A1B9A), Colors.white, Color(0xFFFFE082)],
                    3: [Color(0xFF2196F3), Color(0xFF1976D2), Colors.white, Color(0xFFFFE082)],
                  };
                  return CustomPaint(
                    size: Size(screenWidth, 13.h),
                    painter: CelebrationSparkPainter(
                      tappedIndex: _lastTappedIndex!,
                      itemCount: itemCount,
                      progress: _particleController.value,
                      screenWidth: screenWidth,
                      sparkColors: tabSparkColors[_lastTappedIndex!] ??
                          tabSparkColors[0]!,
                    ),
                  );
                },
              ),
            ),
        ],
      ),
      ),
    );
  }

  List<Color> _getGradientColors(int index) {
    switch (index) {
      case 0:
        return [const Color(0xFF432C7A), const Color(0xFF2A1B4D)];
      case 1:
        return [const Color(0xFF432C7A), const Color(0xFF2A1B4D)];
      case 2:
        return [const Color(0xFF432C7A), const Color(0xFF2A1B4D)];
      case 3:
        return [const Color(0xFF25376E), const Color(0xFF2F3F73)];
      default:
        return [const Color(0xFF432C7A), const Color(0xFF2A1B4D)];
    }
  }

  Widget _buildNavItem({
    required int index,
    required Key key,
    required IconData icon,
    required IconData activeIcon,
    required String label,
    required List<Color> gradient,
    int? badgeCount,
  }) {
    final bool isSelected = widget.currentIndex == index;
    final double scale = isSelected ? 1.0 : 0.85;

    return Expanded(
      child: GestureDetector(
        onTap: () => _onItemTapped(index),
        behavior: HitTestBehavior.opaque,
        child: Container(
          height: 13.h,
          alignment: Alignment.center,
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // 🎨 Icon Container with Morphing Animation
                AnimatedContainer(
                  duration: const Duration(milliseconds: 400),
                  curve: Curves.easeOutBack,
                  transform: Matrix4.identity()
                    ..scaleByVector3(Vector3.all(scale))
                    ..translateByVector3(Vector3.zero()),
                  child: Stack(
                    clipBehavior: Clip.none,
                    alignment: Alignment.center,
                    children: [
                      // Glow effect for selected item
                      if (isSelected)
                        Container(
                          width: 7.h,
                          height: 7.h,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: RadialGradient(
                              colors: [
                                gradient[0].withValues(alpha: 0.4),
                                gradient[1].withValues(alpha: 0.0),
                              ],
                            ),
                          ),
                        ),

                      // Icon background
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 400),
                        curve: Curves.easeOut,
                        width: isSelected ? 50 : 42,
                        height: isSelected ? 50 : 42,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: isSelected
                              ? LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: gradient,
                                )
                              : null,
                          color: isSelected ? null : Colors.transparent,
                          boxShadow: isSelected
                              ? [
                                  BoxShadow(
                                    color: gradient[0].withValues(alpha: 0.5),
                                    blurRadius: 15,
                                    offset: const Offset(0, 8),
                                  ),
                                ]
                              : [],
                        ),
                        child: Icon(
                          isSelected ? activeIcon : icon,
                          color: isSelected
                              ? Colors.white
                              : Theme.of(context).colorScheme.onSurfaceVariant.withValues(alpha: 0.8),
                          size: isSelected ? 26 : 22,
                        ),
                      ),

                      // Badge
                      if (badgeCount != null && badgeCount > 0)
                        Positioned(
                          top: -4,
                          right: -4,
                          child: AnimatedScale(
                            scale: isSelected ? 1.1 : 1.0,
                            duration: const Duration(milliseconds: 300),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 3,
                              ),
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  colors: [Color(0xFFFFD700), Color(0xFFFFAA00)],
                                ),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: Colors.white, width: 2),
                                boxShadow: [
                                  BoxShadow(
                                    color: const Color(
                                      0xFFFFD700,
                                    ).withValues(alpha: 0.6),
                                    blurRadius: 8,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              constraints: const BoxConstraints(minWidth: 20),
                              child: Text(
                                badgeCount > 99 ? '99+' : badgeCount.toString(),
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 8.sp,
                                  fontWeight: FontWeight.bold,
                                  height: 1.2,
                                ),
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),

                SizedBox(height: 0.8.h),

                AnimatedDefaultTextStyle(
                  duration: const Duration(milliseconds: 300),
                  style: TextStyle(
                    color: isSelected ? Colors.white : Theme.of(context).colorScheme.onSurfaceVariant,
                    fontSize: isSelected ? 15 : 13,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    letterSpacing: 0.5,
                    shadows: isSelected
                        ? [
                            Shadow(
                              color: Colors.black.withValues(alpha: 0.3),
                              blurRadius: 4,
                            ),
                          ]
                        : [],
                  ),
                  child: AnimatedOpacity(
                    opacity: isSelected ? 1.0 : 0.8,
                    duration: const Duration(milliseconds: 300),
                    child: Text(label),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// 🌊 Liquid Morphing Indicator Painter
class LiquidIndicatorPainter extends CustomPainter {
  final int currentIndex;
  final int itemCount;
  final double animationValue;
  final double screenWidth;

  LiquidIndicatorPainter({
    required this.currentIndex,
    required this.itemCount,
    required this.animationValue,
    required this.screenWidth,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final itemWidth = screenWidth / itemCount;
    final centerX = itemWidth * currentIndex + itemWidth / 2;
    final centerY = size.height / 2;

    // Pulsing glow effect
    final glowRadius = 35 + (animationValue * 5);
    final glowPaint = Paint()
      ..shader =
          RadialGradient(
            colors: [
              Colors.white.withValues(alpha: 0.2 * (1 - animationValue * 0.5)),
              Colors.transparent,
            ],
          ).createShader(
            Rect.fromCircle(
              center: Offset(centerX, centerY),
              radius: glowRadius,
            ),
          )
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 15);

    canvas.drawCircle(Offset(centerX, centerY), glowRadius, glowPaint);
  }

  @override
  bool shouldRepaint(LiquidIndicatorPainter oldDelegate) {
    return oldDelegate.currentIndex != currentIndex ||
        oldDelegate.animationValue != animationValue;
  }
}

// 🎆 Particle Effect Painter
class ParticleEffectPainter extends CustomPainter {
  final int currentIndex;
  final int itemCount;
  final double animationValue;
  final double screenWidth;

  ParticleEffectPainter({
    required this.currentIndex,
    required this.itemCount,
    required this.animationValue,
    required this.screenWidth,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final itemWidth = screenWidth / itemCount;
    final centerX = itemWidth * currentIndex + itemWidth / 2;
    final centerY = size.height / 2;

    final paint = Paint()
      ..color = Colors.white.withValues(alpha: 0.6 * (1 - animationValue))
      ..style = PaintingStyle.fill;

    // Create particle burst effect
    for (int i = 0; i < 12; i++) {
      final angle = (i / 12) * 2 * math.pi;
      final distance = animationValue * 40;
      final particleX = centerX + distance * math.cos(angle);
      final particleY = centerY + distance * math.sin(angle);
      final particleSize = 3 * (1 - animationValue);

      canvas.drawCircle(Offset(particleX, particleY), particleSize, paint);
    }
  }

  @override
  bool shouldRepaint(ParticleEffectPainter oldDelegate) {
    return oldDelegate.animationValue != animationValue;
  }
}
