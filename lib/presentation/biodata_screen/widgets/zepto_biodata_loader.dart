import 'package:banjarabio/core/constants/app_typography.dart';
import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import 'package:banjarabio/core/constants/biodata_templates.dart';
import 'package:banjarabio/theme/app_colors.dart';

/// 🚀 [ZeptoBiodataLoader]
///
/// Ultra-modern, high-delight loading canvas inspired by Zepto, Swiggy, and Zomato.
/// Features:
/// 1. ⚡ Holographic Laser Scanner Beam sweeping across A4 document blueprint
/// 2. 📊 Live Percentage Progress Engine (12% ➔ 99%)
/// 3. 🎯 4-Stage Matrimonial Crafting Pipeline with animated step badges
/// 4. 💡 Cultural Heritage & Proposal Boost Trivia Carousel (rotates every 2.4s)
/// 5. 🌸 Sacred Mandala & Avatar Shimmer Particles
class ZeptoBiodataLoader extends StatefulWidget {
  final int selectedTemplateIndex;
  final String selectedMantra;
  final bool isDark;

  const ZeptoBiodataLoader({
    super.key,
    required this.selectedTemplateIndex,
    required this.selectedMantra,
    required this.isDark,
  });

  @override
  State<ZeptoBiodataLoader> createState() => _ZeptoBiodataLoaderState();
}

class _ZeptoBiodataLoaderState extends State<ZeptoBiodataLoader>
    with TickerProviderStateMixin {
  late final AnimationController _laserController;
  late final AnimationController _progressController;
  late final AnimationController _shimmerController;
  late final AnimationController _pulseController;
  late final Animation<double> _progressAnimation;

  Timer? _triviaTimer;
  int _triviaIndex = 0;

  static const List<Map<String, dynamic>> _craftingStages = [
    {
      'icon': Icons.auto_awesome_rounded,
      'title': 'Invoking Sacred Blessings',
      'subtitle': 'Harmonizing Devanagari mantras & family traditions',
      'threshold': 0.25,
    },
    {
      'icon': Icons.brush_rounded,
      'title': 'Weaving Royal Borders',
      'subtitle': 'Applying handcrafted heritage gold & floral motifs',
      'threshold': 0.55,
    },
    {
      'icon': Icons.person_pin_circle_rounded,
      'title': 'Engraving Bio & Kundali',
      'subtitle': 'Styling portrait, Gotra, Rashi & matrimonial details',
      'threshold': 0.85,
    },
    {
      'icon': Icons.verified_rounded,
      'title': 'Finalizing 300 DPI Print PDF',
      'subtitle': 'Generating crystal-clear ultra-HD matrimonial layout',
      'threshold': 1.00,
    },
  ];

  static const List<Map<String, String>> _matrimonialTrivia = [
    {
      'tag': 'PROPOSAL BOOST',
      'icon': '💡',
      'text': 'Profiles with complete family & Kundali details receive 4.8x more verified marriage proposals!',
    },
    {
      'tag': 'HERITAGE TRADITION',
      'icon': '🪔',
      'text': 'Gor Banjara weddings traditionally celebrate with sacred Thali and ancestral Tanda blessings.',
    },
    {
      'tag': 'PRINT READY A4',
      'icon': '🖨️',
      'text': 'Your biodata is rendered at 300 DPI high-definition, ideal for vibrant WhatsApp sharing and color printing.',
    },
    {
      'tag': 'COMMUNITY TRUST',
      'icon': '💍',
      'text': 'Over 15,000+ Gor Banjara families have trusted BanjaraBio to find their ideal life partner.',
    },
  ];

  @override
  void initState() {
    super.initState();

    // 1. Holographic Laser Scanning Beam (continuous back and forth sweep)
    _laserController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat(reverse: true);

    // 2. Continuous Organic Shimmer
    _shimmerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2400),
    )..repeat();

    // 3. Ambient Glow Pulse
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1600),
    )..repeat(reverse: true);

    // 4. Percentage Progress Easing (12% -> 99%)
    _progressController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3600),
    )..forward();

    _progressAnimation = CurvedAnimation(
      parent: _progressController,
      curve: Curves.easeInOutCubic,
    );

    // 5. Trivia Carousel (Swaps every 2.4 seconds)
    _triviaTimer = Timer.periodic(const Duration(milliseconds: 2400), (_) {
      if (mounted) {
        setState(() {
          _triviaIndex = (_triviaIndex + 1) % _matrimonialTrivia.length;
        });
      }
    });
  }

  @override
  void dispose() {
    _laserController.dispose();
    _progressController.dispose();
    _shimmerController.dispose();
    _pulseController.dispose();
    _triviaTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final template = kBiodataTemplates[widget.selectedTemplateIndex];
    final activeColor = template.accentColor;
    final isDark = widget.isDark;

    return Center(
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // ─── 1. TOP LIVE STAGE INDICATOR & PERCENTAGE GAUGE ───
            _buildTopStatusHeader(activeColor, isDark, template.name),
            const SizedBox(height: 12),

            // ─── 2. MAIN A4 BLUEPRINT CANVAS WITH LASER SCANNER BEAM ───
            _buildA4DocumentBlueprint(activeColor, isDark),
            const SizedBox(height: 14),

            // ─── 3. ZEPTO-STYLE DYNAMIC STEP TRACKER BADGE ───
            _buildStageTrackerPill(activeColor, isDark),
            const SizedBox(height: 12),

            // ─── 4. SWIGGY/ZOMATO STYLE CULTURAL TRIVIA TICKER ───
            _buildTriviaTicker(activeColor, isDark),
          ],
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // 1. TOP STATUS HEADER (PERCENTAGE COUNTER + 4 STEP DOTS)
  // ═══════════════════════════════════════════════════════════════════════════
  Widget _buildTopStatusHeader(Color activeColor, bool isDark, String templateName) {
    return AnimatedBuilder(
      animation: _progressAnimation,
      builder: (context, child) {
        final progress = _progressAnimation.value;
        final percent = math.min(99, (progress * 100).toInt());

        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(
            color: isDark
                ? AppColors.canvasRichDark.withValues(alpha: AppColors.opacity90)
                : Colors.white.withValues(alpha: 0.95),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: activeColor.withValues(alpha: AppColors.opacity30),
              width: 1.1,
            ),
            boxShadow: [
              BoxShadow(
                color: activeColor.withValues(alpha: 0.18),
                blurRadius: 16,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              // Liquid Circular Percentage Counter
              Stack(
                alignment: Alignment.center,
                children: [
                  SizedBox(
                    width: 38,
                    height: 38,
                    child: CircularProgressIndicator(
                      value: progress,
                      strokeWidth: 3.2,
                      backgroundColor: activeColor.withValues(alpha: AppColors.opacity15),
                      valueColor: AlwaysStoppedAnimation<Color>(activeColor),
                    ),
                  ),
                  Text(
                    '$percent%',
                    style: TextStyle(
                       fontFamily: AppTypography.bodyFontFamily,
                       color: activeColor,
                       fontWeight: AppTypography.black,
                       fontSize: AppTypography.labelTiny,
                     ),
                  ),
                ],
              ),
              // Stage Title & Live Theme
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      children: [
                        Text(
                          'STUDIO CRAFTING',
                          style: TextStyle(
                             fontFamily: AppTypography.bodyFontFamily,
                             color: activeColor,
                             fontWeight: AppTypography.black,
                             fontSize: AppTypography.labelTiny,
                             letterSpacing: 1.1,
                           ),
                        ),
                        // 4 Step Pills
                        Row(
                          children: List.generate(_craftingStages.length, (idx) {
                            final stageThreshold = _craftingStages[idx]['threshold'] as double;
                            final isPassed = progress >= stageThreshold - 0.1;
                            return Container(
                              margin: const EdgeInsets.only(left: 4),
                              width: isPassed ? 12 : 5,
                              height: 5,
                              decoration: BoxDecoration(
                                color: isPassed
                                    ? activeColor
                                    : (isDark ? Colors.white24 : Colors.black12),
                                borderRadius: BorderRadius.circular(3),
                              ),
                            );
                          }),
                        ),
                      ],
                    ),
                    const SizedBox(height: 3),
                    Text(
                      'Rendering $templateName Matrimonial Template',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                         fontFamily: AppTypography.bodyFontFamily,
                         fontWeight: AppTypography.bold,
                           fontSize: AppTypography.labelSmall,
                         color: isDark ? Colors.white : AppColors.slate800,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // 2. MAIN A4 BLUEPRINT CANVAS WITH LASER SCANNER BEAM
  // ═══════════════════════════════════════════════════════════════════════════
  Widget _buildA4DocumentBlueprint(Color activeColor, bool isDark) {
    return AnimatedBuilder(
      animation: Listenable.merge([
        _laserController,
        _shimmerController,
        _pulseController,
      ]),
      builder: (context, child) {
        final laserProgress = _laserController.value;
        final shimmer = _shimmerController.value;
        final pulse = _pulseController.value;

        final shimmerGradient = LinearGradient(
          colors: isDark
              ? [
                  Colors.white.withValues(alpha: 0.04),
                  Colors.white.withValues(alpha: 0.16),
                  Colors.white.withValues(alpha: 0.04),
                ]
              : [
                  AppColors.slate200.withValues(alpha: AppColors.opacity40),
                  Colors.white.withValues(alpha: AppColors.opacity85),
                  AppColors.slate200.withValues(alpha: AppColors.opacity40),
                ],
          stops: const [0.1, 0.5, 0.9],
          transform: GradientRotation(shimmer * 2 * math.pi),
        );

        return Container(
          width: 82.w,
          height: 48.h,
          decoration: BoxDecoration(
            color: isDark ? AppColors.canvasDeepDark : Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: activeColor.withValues(alpha: 0.35 + (0.15 * pulse)),
              width: 1.3,
            ),
            boxShadow: [
              BoxShadow(
                color: activeColor.withValues(alpha: 0.15 + (0.10 * pulse)),
                blurRadius: 20 + (8 * pulse),
                offset: const Offset(0, 6),
              ),
              BoxShadow(
                color: Colors.black.withValues(alpha: isDark ? 0.45 : 0.08),
                blurRadius: 14,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(15),
            child: Stack(
              children: [
                // 1. Inner Decorative Matrimonial Double Border
                Positioned.fill(
                  child: Container(
                    margin: const EdgeInsets.all(5),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: activeColor.withValues(alpha: 0.22),
                        width: 0.8,
                      ),
                    ),
                  ),
                ),

                // 2. Simulated Matrimonial Document Content
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      // Top Sacred Mantra Pill
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                        decoration: BoxDecoration(
                          gradient: shimmerGradient,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: activeColor.withValues(alpha: AppColors.opacity30),
                            width: 0.8,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Transform.rotate(
                              angle: shimmer * 2 * math.pi,
                              child: Icon(
                                Icons.auto_awesome,
                                size: 10,
                                color: activeColor,
                              ),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              widget.selectedMantra,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                 fontFamily: AppTypography.bodyFontFamily,
                                 fontWeight: AppTypography.extraBold,
                                 color: activeColor,
                                 fontSize: AppTypography.labelTiny,
                                 letterSpacing: 0.2,
                               ),
                            ),
                            Transform.rotate(
                              angle: -shimmer * 2 * math.pi,
                              child: Icon(
                                Icons.auto_awesome,
                                size: 10,
                                color: activeColor,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),

                      // Avatar Silhouette + Candidate Title
                      Row(
                        children: [
                          Container(
                            width: 48,
                            height: 48,
                            padding: const EdgeInsets.all(2.5),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: SweepGradient(
                                colors: [
                                  activeColor,
                                  activeColor.withValues(alpha: AppColors.opacity15),
                                  activeColor,
                                ],
                                transform: GradientRotation(shimmer * 2 * math.pi),
                              ),
                            ),
                            child: Container(
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: isDark ? AppColors.canvasRichDark : AppColors.slate100,
                              ),
                              child: Icon(
                                Icons.person_rounded,
                                size: 24,
                                color: activeColor.withValues(alpha: AppColors.opacity50),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  height: 12,
                                  width: 45.w,
                                  decoration: BoxDecoration(
                                    gradient: shimmerGradient,
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Container(
                                  height: 8,
                                  width: 30.w,
                                  decoration: BoxDecoration(
                                    gradient: shimmerGradient,
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),

                      // Accent Divider
                      Container(
                        height: 1,
                        color: activeColor.withValues(alpha: AppColors.opacity20),
                      ),
                      const SizedBox(height: 10),

                      // 2-Column Fields
                      ...List.generate(3, (index) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4.5),
                          child: Row(
                            children: [
                              Container(
                                height: 8,
                                width: 20.w,
                                decoration: BoxDecoration(
                                  gradient: shimmerGradient,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                ':',
                                style: TextStyle(
                                   fontFamily: AppTypography.bodyFontFamily,
                                   fontWeight: AppTypography.bold,
                                   color: isDark ? Colors.white30 : Colors.black26,
                                   fontSize: AppTypography.labelTiny,
                                 ),
                              ),
                              Expanded(
                                child: Container(
                                  height: 8,
                                  decoration: BoxDecoration(
                                    gradient: shimmerGradient,
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      }),
                    ],
                  ),
                ),

                // 3. ⚡ HOLOGRAPHIC NEON LASER SCANNING BEAM (Zepto Scanner Effect)
                Positioned(
                  top: (48.h - 32) * laserProgress,
                  left: 0,
                  right: 0,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Laser Glow Aura
                      Container(
                        height: 24,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.transparent,
                              activeColor.withValues(alpha: AppColors.opacity8),
                              activeColor.withValues(alpha: AppColors.opacity35),
                            ],
                          ),
                        ),
                      ),
                      // Bright Laser Cutting Line
                      Container(
                        height: 2.2,
                        decoration: BoxDecoration(
                          color: activeColor,
                          boxShadow: [
                            BoxShadow(
                              color: activeColor.withValues(alpha: AppColors.opacity90),
                              blurRadius: 10,
                              spreadRadius: 1.5,
                            ),
                            BoxShadow(
                              color: Colors.white.withValues(alpha: AppColors.opacity80),
                              blurRadius: 4,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // 3. ZEPTO-STYLE DYNAMIC STEP TRACKER BADGE
  // ═══════════════════════════════════════════════════════════════════════════
  Widget _buildStageTrackerPill(Color activeColor, bool isDark) {
    return AnimatedBuilder(
      animation: _progressAnimation,
      builder: (context, child) {
        final progress = _progressAnimation.value;

        // Find active stage
        int currentStageIdx = 0;
        for (int i = 0; i < _craftingStages.length; i++) {
          if (progress <= (_craftingStages[i]['threshold'] as double)) {
            currentStageIdx = i;
            break;
          }
        }
        final stage = _craftingStages[currentStageIdx];

        return AnimatedSwitcher(
          duration: const Duration(milliseconds: 320),
          switchInCurve: Curves.easeOutBack,
          switchOutCurve: Curves.easeIn,
          transitionBuilder: (child, anim) {
            return SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0, 0.2),
                end: Offset.zero,
              ).animate(anim),
              child: FadeTransition(opacity: anim, child: child),
            );
          },
          child: Container(
            key: ValueKey('stage_$currentStageIdx'),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: isDark
                  ? AppColors.canvasRichDark.withValues(alpha: 0.92)
                  : Colors.white.withValues(alpha: 0.95),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: activeColor.withValues(alpha: AppColors.opacity40),
                width: 1.2,
              ),
              boxShadow: [
                BoxShadow(
                  color: activeColor.withValues(alpha: AppColors.opacity20),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              children: [
                // Glowing Pulsing Stage Icon
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: activeColor.withValues(alpha: 0.14),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    stage['icon'] as IconData,
                    size: 16,
                    color: activeColor,
                  ),
                ),
                const SizedBox(width: 10),
                // Stage Title & Subtitle
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        children: [
                          Text(
                            stage['title'] as String,
                            style: TextStyle(
                               fontFamily: AppTypography.bodyFontFamily,
                               color: isDark ? Colors.white : AppColors.slate800,
                               fontWeight: AppTypography.black,
                               fontSize: AppTypography.bodySmall,
                               letterSpacing: 0.2,
                             ),
                          ),
                          Text(
                            'Step ${currentStageIdx + 1}/4',
                            style: TextStyle(
                               fontFamily: AppTypography.bodyFontFamily,
                               fontWeight: AppTypography.extraBold,
                               color: activeColor,
                               fontSize: AppTypography.labelTiny,
                             ),
                          ),
                        ],
                      ),
                      Text(
                        stage['subtitle'] as String,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                           fontFamily: AppTypography.bodyFontFamily,
                           fontWeight: AppTypography.medium,
                             fontSize: AppTypography.labelTiny,
                           color: isDark ? Colors.white60 : AppColors.slate500,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // 4. SWIGGY/ZOMATO STYLE CULTURAL TRIVIA TICKER
  // ═══════════════════════════════════════════════════════════════════════════
  Widget _buildTriviaTicker(Color activeColor, bool isDark) {
    final trivia = _matrimonialTrivia[_triviaIndex];

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 400),
      switchInCurve: Curves.easeOutCubic,
      switchOutCurve: Curves.easeInCubic,
      transitionBuilder: (child, anim) {
        return SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0, 0.25),
            end: Offset.zero,
          ).animate(anim),
          child: FadeTransition(opacity: anim, child: child),
        );
      },
      child: Container(
        key: ValueKey('trivia_$_triviaIndex'),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
        decoration: BoxDecoration(
          color: isDark
              ? AppColors.canvasNearBlack.withValues(alpha: AppColors.opacity85)
              : AppColors.slate50,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isDark ? Colors.white10 : Colors.black.withValues(alpha: 0.06),
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              trivia['icon']!,
              style: TextStyle(fontSize: AppTypography.headingSmall),
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    trivia['tag']!,
                    style: TextStyle(
                       fontFamily: AppTypography.bodyFontFamily,
                       color: activeColor,
                       fontWeight: AppTypography.black,
                       fontSize: AppTypography.labelTiny,
                       letterSpacing: 0.8,
                     ),
                  ),
                  Text(
                    trivia['text']!,
                    style: TextStyle(
                       fontFamily: AppTypography.bodyFontFamily,
                       color: isDark ? Colors.white70 : AppColors.slate600,
                       fontWeight: AppTypography.semiBold,
                       fontSize: AppTypography.labelSmall,
                       height: 1.3,
                      ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
