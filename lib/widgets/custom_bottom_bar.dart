import 'dart:math' as math;
import 'package:banjarabio/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:vector_math/vector_math_64.dart' show Vector3;
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';
import 'package:banjarabio/widgets/celebration_spark_painter.dart';
import 'package:banjarabio/widgets/glassmorphism_container.dart';
import 'package:banjarabio/core/constants/app_typography.dart';

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
  final int? chatBadgeCount;

  const CustomBottomBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
    this.sharedBadgeCount,
    this.chatBadgeCount,
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
    );
    // Run once on init, then stop to save ~60fps of idle repainting
    _triggerPulse();
  }

  @override
  void didUpdateWidget(covariant CustomBottomBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Re-trigger pulse only when the selected tab actually changes
    if (oldWidget.currentIndex != widget.currentIndex) {
      _triggerPulse();
    }
  }

  /// Runs the pulse animation once (1.5s), then stops the controller.
  /// This prevents continuous 60fps repainting of LiquidIndicatorPainter
  /// during idle scroll — saving significant GPU overhead on low-end devices.
  void _triggerPulse() {
    _pulseController.forward(from: 0);
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
    const int itemCount = 5;
    final screenWidth = MediaQuery.of(context).size.width;

    final double bottomPadding = MediaQuery.of(context).padding.bottom;
    final double contentHeight = 6.5.h;
    final double totalHeight = contentHeight + bottomPadding;

    final double barWidth = screenWidth;
    final double itemWidth = barWidth / itemCount;
    final double capsuleWidth = itemWidth - 4;
    final double capsuleHeight = 4.5.h;
    final double leftPosition = widget.currentIndex * itemWidth + (itemWidth - capsuleWidth) / 2;
    final double topPosition = (contentHeight - 1.5 - capsuleHeight) / 2;

    final int totalConnectBadge = (widget.sharedBadgeCount ?? 0) + (widget.chatBadgeCount ?? 0);

    return Container(
      width: screenWidth,
      height: totalHeight,
      decoration: BoxDecoration(
        color: Colors.transparent,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 12,
            offset: const Offset(0, -3),
          ),
        ],
      ),
      child: GlassmorphismContainer(
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
        color: Theme.of(context).colorScheme.surface,
        opacity: 0.85,
        blur: 25,
        border: Border(
          top: BorderSide(
            color: Theme.of(context).colorScheme.outlineVariant.withValues(alpha: 0.25),
            width: 1.5,
          ),
        ),
        child: Padding(
          padding: EdgeInsets.only(bottom: bottomPadding),
          child: SizedBox(
            height: contentHeight - 1.5,
            child: Stack(
              children: [
                // 🌈 Animated Gradient Background Layer (Soft Glow)
                AnimatedContainer(
                  duration: const Duration(milliseconds: 600),
                  curve: Curves.easeInOutCubic,
                  decoration: BoxDecoration(
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(20),
                      topRight: Radius.circular(20),
                    ),
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        _getGradientColors(widget.currentIndex)[0].withValues(alpha: 0.1),
                        _getGradientColors(widget.currentIndex)[1].withValues(alpha: 0.03),
                      ],
                    ),
                  ),
                ),

                // ✨ World-Class Sliding Active Capsule Background
                AnimatedPositioned(
                  duration: const Duration(milliseconds: 350),
                  curve: Curves.easeOutBack, // springy elastic curve
                  left: leftPosition,
                  top: topPosition,
                  width: capsuleWidth,
                  height: capsuleHeight,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 350),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          _getGradientColors(widget.currentIndex)[0],
                          _getGradientColors(widget.currentIndex)[1],
                        ],
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: _getGradientColors(widget.currentIndex)[0].withValues(alpha: 0.45),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                  ),
                ),

                // 🎯 Navigation Items (5 Tabs: Home, Connect, Biodata, Services, Menu)
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    // 0: Home (Discover)
                    _buildNavItem(
                      index: 0,
                      icon: Icons.favorite_rounded,
                      activeIcon: Icons.favorite,
                      label: AppLocalizations.of(context)?.home ?? 'Home',
                      gradient: const [Color(0xFF880E4F), Color(0xFF961B33)],
                      contentHeight: contentHeight - 1.5,
                    ),

                    // 1: Connect (Matches + Chat)
                    _buildNavItem(
                      index: 1,
                      icon: Icons.forum_outlined,
                      activeIcon: Icons.forum_rounded,
                      label: AppLocalizations.of(context)?.chat ?? 'Connect',
                      badgeCount: totalConnectBadge > 0 ? totalConnectBadge : null,
                      gradient: const [Color(0xFF00897B), Color(0xFF004D40)],
                      contentHeight: contentHeight - 1.5,
                    ),

                    // 2: Biodata (PDF Studio)
                    _buildNavItem(
                      index: 2,
                      icon: Icons.description_outlined,
                      activeIcon: Icons.description_rounded,
                      label: AppLocalizations.of(context)?.biodataPdf.replaceAll(' PDF', '') ?? 'Biodata',
                      gradient: const [Color(0xFFE65100), Color(0xFFBF360C)],
                      contentHeight: contentHeight - 1.5,
                    ),

                    // 3: Services (Melavas & Wedding Marketplace Hub)
                    _buildNavItem(
                      index: 3,
                      icon: Icons.hub_outlined,
                      activeIcon: Icons.hub_rounded,
                      label: 'Services',
                      gradient: const [Color(0xFF8E24AA), Color(0xFF5E35B1)],
                      contentHeight: contentHeight - 1.5,
                    ),

                    // 4: Menu / Profile
                    _buildNavItem(
                      index: 4,
                      icon: Icons.person_outline_rounded,
                      activeIcon: Icons.person_rounded,
                      label: AppLocalizations.of(context)?.menu ?? 'Menu',
                      gradient: const [Color(0xFF2196F3), Color(0xFF1976D2)],
                      contentHeight: contentHeight - 1.5,
                    ),
                  ],
                ),

                // 🎆 Particle Effect on Tap
                if (_lastTappedIndex != null)
                  IgnorePointer(
                    child: AnimatedBuilder(
                      animation: _particleController,
                      builder: (context, child) {
                        if (_particleController.value == 0) return const SizedBox();
                        const tabSparkColors = <int, List<Color>>{
                          0: [Color(0xFF880E4F), Color(0xFF961B33), Colors.white, Color(0xFFFFE082)],
                          1: [Color(0xFF00897B), Color(0xFF004D40), Colors.white, Color(0xFFFFE082)],
                          2: [Color(0xFFE65100), Color(0xFFBF360C), Colors.white, Color(0xFFFFE082)],
                          3: [Color(0xFF8E24AA), Color(0xFF5E35B1), Colors.white, Color(0xFFFFE082)],
                          4: [Color(0xFF2196F3), Color(0xFF1976D2), Colors.white, Color(0xFFFFE082)],
                        };
                        return CustomPaint(
                          size: Size(barWidth, contentHeight - 1.5),
                          painter: CelebrationSparkPainter(
                            tappedIndex: _lastTappedIndex!,
                            itemCount: itemCount,
                            progress: _particleController.value,
                            screenWidth: barWidth,
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
        ),
      ),
    );
  }

  List<Color> _getGradientColors(int index) {
    switch (index) {
      case 0:
        return [const Color(0xFF961B33), const Color(0xFF731224)];
      case 1:
        return [const Color(0xFF961B33), const Color(0xFF731224)];
      case 2:
        return [const Color(0xFF961B33), const Color(0xFF731224)];
      case 3:
        return [const Color(0xFF961B33), const Color(0xFF731224)];
      case 4:
        return [const Color(0xFF961B33), const Color(0xFF731224)];
      case 5:
        return [const Color(0xFF961B33), const Color(0xFF731224)];
      default:
        return [const Color(0xFF961B33), const Color(0xFF731224)];
    }
  }


  Widget _buildNavItem({
    required int index,
    required IconData icon,
    required IconData activeIcon,
    required String label,
    required List<Color> gradient,
    required double contentHeight,
    int? badgeCount,
  }) {
    final bool isSelected = widget.currentIndex == index;
    final double scale = isSelected ? 1.08 : 0.92;

    return Expanded(
      child: Semantics(
        label: '$label tab',
        selected: isSelected,
        button: true,
        hint: 'Double tap to open $label tab',
        child: GestureDetector(
          onTap: () => _onItemTapped(index),
          behavior: HitTestBehavior.opaque,
          child: Container(
            height: contentHeight,
            alignment: Alignment.center,
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // 🎨 Icon Container with Scale Animation
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeOut,
                    transform: Matrix4.identity()
                      ..scaleByVector3(Vector3.all(scale)),
                    child: Stack(
                      clipBehavior: Clip.none,
                      alignment: Alignment.center,
                      children: [
                        Icon(
                          isSelected ? activeIcon : icon,
                          color: isSelected
                              ? Colors.white
                              : Theme.of(context).colorScheme.onSurfaceVariant.withValues(alpha: 0.6),
                          size: 24,
                        ),
  
                        // Badge
                        if (badgeCount != null && badgeCount > 0)
                          Positioned(
                            top: -6,
                            right: -10,
                            child: AnimatedScale(
                              scale: isSelected ? 1.15 : 1.0,
                              duration: const Duration(milliseconds: 300),
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 5,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  gradient: const LinearGradient(
                                    colors: [Color(0xFFFFD700), Color(0xFFFFAA00)],
                                  ),
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(color: Colors.white, width: 1.5),
                                  boxShadow: [
                                    BoxShadow(
                                      color: const Color(0xFFFFD700).withValues(alpha: 0.5),
                                      blurRadius: 6,
                                      offset: const Offset(0, 1.5),
                                    ),
                                  ],
                                ),
                                constraints: const BoxConstraints(minWidth: 16),
                                child: Text(
                                  badgeCount > 99 ? '99+' : badgeCount.toString(),
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: AppTypography.labelSmall,
                                    fontWeight: AppTypography.bold,
                                    height: 1.1,
                                  ),
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
  
                  SizedBox(height: 0.15.h),
  
                  AnimatedDefaultTextStyle(
                    duration: const Duration(milliseconds: 300),
                    style: TextStyle(
                      color: isSelected
                          ? Colors.white
                          : Theme.of(context).colorScheme.onSurfaceVariant.withValues(alpha: 0.7),
                      fontSize: isSelected ? AppTypography.labelMedium : AppTypography.labelSmall,
                      fontWeight: isSelected ? AppTypography.bold : AppTypography.semiBold,
                      letterSpacing: 0.1,
                    ),
                    child: Text(label),
                  ),
                ],
              ),
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
