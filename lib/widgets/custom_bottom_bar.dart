import 'dart:math' as math;
import 'package:banjarabio/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:vector_math/vector_math_64.dart' show Vector3;
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';
import 'package:banjarabio/widgets/celebration_spark_painter.dart';
import 'package:banjarabio/widgets/glassmorphism_container.dart';
import 'package:banjarabio/core/utils/tour_keys.dart';
import 'package:banjarabio/core/constants/app_typography.dart';
import 'package:banjarabio/theme/app_colors.dart';

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
    final double capsuleWidth = 16.w;
    final double capsuleHeight = 4.5.h;
    final double leftPosition = widget.currentIndex * itemWidth + (itemWidth - capsuleWidth) / 2;
    final double topPosition = (contentHeight - 1.5 - capsuleHeight) / 2;

    return Container(
      width: screenWidth,
      height: totalHeight,
      decoration: BoxDecoration(
        color: Colors.transparent,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: AppColors.opacity8),
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
            color: Theme.of(context).colorScheme.outlineVariant.withValues(alpha: AppColors.opacity25),
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
                        _getGradientColors(widget.currentIndex)[0].withValues(alpha: AppColors.opacity10),
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

                // 🎯 Navigation Items
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildNavItem(
                      index: 0,
                      key: TourKeys.homeTabKey,
                      icon: Icons.favorite_border_rounded,
                      activeIcon: Icons.favorite_rounded,
                      label: AppLocalizations.of(context)?.home ?? 'Home',
                      gradient: const [AppColors.primaryDark, AppColors.primary],
                      contentHeight: contentHeight - 1.5,
                    ),
                    _buildNavItem(
                      index: 1,
                      key: TourKeys.sharedTabKey,
                      icon: Icons.chat_bubble_outline_rounded,
                      activeIcon: Icons.chat_bubble_rounded,
                      label: AppLocalizations.of(context)?.inbox ?? 'Inbox',
                      badgeCount: widget.sharedBadgeCount,
                      gradient: const [AppColors.orange400, AppColors.orangeDark900],
                      contentHeight: contentHeight - 1.5,
                    ),
                    _buildNavItem(
                      index: 2,
                      key: TourKeys.melavaTabKey,
                      icon: Icons.description_outlined,
                      activeIcon: Icons.description_rounded,
                      label: AppLocalizations.of(context)?.biodata ?? 'Biodata',
                      gradient: const [AppColors.materialPurple, AppColors.violetDeep],
                      contentHeight: contentHeight - 1.5,
                    ),
                    _buildNavItem(
                      index: 3,
                      key: TourKeys.profileTabKey,
                      icon: Icons.storefront_outlined,
                      activeIcon: Icons.storefront_rounded,
                      label: AppLocalizations.of(context)?.services ?? 'Services',
                      gradient: const [AppColors.materialPurple700, AppColors.materialPurpleDark],
                      contentHeight: contentHeight - 1.5,
                    ),
                    _buildNavItem(
                      index: 4,
                      key: TourKeys.settingsTabKey,
                      icon: Icons.person_outline_rounded,
                      activeIcon: Icons.person_rounded,
                      label: AppLocalizations.of(context)?.account ?? 'Account',
                      gradient: const [AppColors.materialBlue, AppColors.materialBlueDark],
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
                          0: [AppColors.primaryDark, AppColors.primary, Colors.white, AppColors.goldGlow],
                          1: [AppColors.orange400, AppColors.orangeDark900, Colors.white, AppColors.goldGlow],
                          2: [AppColors.materialPurple, AppColors.violetDeep, Colors.white, AppColors.goldGlow],
                          3: [AppColors.materialPurple700, AppColors.materialPurpleDark, Colors.white, AppColors.goldGlow],
                          4: [AppColors.materialBlue, AppColors.materialBlueDark, Colors.white, AppColors.goldGlow],
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
        return [AppColors.primary, AppColors.primaryDark];
      case 1:
        return [AppColors.primary, AppColors.primaryDark];
      case 2:
        return [AppColors.primary, AppColors.primaryDark];
      case 3:
        return [AppColors.primary, AppColors.primaryDark];
      case 4:
        return [AppColors.primary, AppColors.primaryDark];
      default:
        return [AppColors.primary, AppColors.primaryDark];
    }
  }


  Widget _buildNavItem({
    required int index,
    required Key key,
    required IconData icon,
    required IconData activeIcon,
    required String label,
    required List<Color> gradient,
    required double contentHeight,
    int? badgeCount,
  }) {
    final bool isSelected = widget.currentIndex == index;
    final double scale = isSelected ? 1.05 : 0.85;

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
                              : Theme.of(context).colorScheme.onSurfaceVariant.withValues(alpha: AppColors.opacity60),
                          size: 22,
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
                                    colors: [AppColors.categoryVip, AppColors.categoryVipDark],
                                  ),
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(color: Colors.white, width: 1.5),
                                  boxShadow: [
                                    BoxShadow(
                                      color: AppColors.categoryVip.withValues(alpha: AppColors.opacity50),
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
  
                  SizedBox(height: 0.3.h),
  
                  AnimatedDefaultTextStyle(
                    duration: const Duration(milliseconds: 300),
                    style: TextStyle(
                      color: isSelected
                          ? Colors.white
                          : Theme.of(context).colorScheme.onSurfaceVariant.withValues(alpha: AppColors.opacity70),
                      fontSize: isSelected ? AppTypography.bodySmall : AppTypography.bodySmall,
                      fontWeight: isSelected ? AppTypography.bold : AppTypography.semiBold,
                      letterSpacing: 0.3,
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
