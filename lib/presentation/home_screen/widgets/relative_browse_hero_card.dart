import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';

import 'package:banjarabio/core/constants/app_typography.dart';
import 'package:banjarabio/core/services/local_cache_service.dart';
import 'package:banjarabio/core/session_manager.dart';
import 'package:banjarabio/routes/app_routes.dart';
import 'package:banjarabio/theme/app_colors.dart';
import 'package:banjarabio/widgets/tactile/tactile_pressable.dart';

/// Premium Global-Standard Hero Banner for Relative Browse Mode.
/// Features a royal burgundy mesh gradient, frosted glassmorphic filter chip,
/// ambient glow accents, shimmering glint sweep, and a metallic gold CTA with tactile micro-animation.
class RelativeBrowseHeroCard extends StatefulWidget {
  final String? activeChipLabel;
  final VoidCallback? onEditSearch;
  final VoidCallback? onCreateBiodata;

  const RelativeBrowseHeroCard({
    super.key,
    this.activeChipLabel,
    this.onEditSearch,
    this.onCreateBiodata,
  });

  @override
  State<RelativeBrowseHeroCard> createState() => _RelativeBrowseHeroCardState();
}

class _RelativeBrowseHeroCardState extends State<RelativeBrowseHeroCard>
    with TickerProviderStateMixin {
  late final AnimationController _pulseController;
  late final AnimationController _glintController;
  late final Animation<double> _scaleAnimation;
  bool _hasDraft = false;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2400),
    )..repeat(reverse: true);

    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.035).animate(
      CurvedAnimation(
        parent: _pulseController,
        curve: Curves.easeInOutSine,
      ),
    );

    _glintController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2800),
    )..repeat();

    _checkSavedDraft();
  }

  Future<void> _checkSavedDraft() async {
    try {
      final draft = await SessionManager.instance.getBiodataDraft();
      if (draft != null && draft.isNotEmpty) {
        final name = draft['name']?.toString() ?? '';
        final surname = draft['surname']?.toString() ?? '';
        final phone = draft['phone_number']?.toString() ?? '';
        if (name.isNotEmpty || surname.isNotEmpty || phone.isNotEmpty) {
          if (mounted) {
            setState(() => _hasDraft = true);
          }
        }
      }
    } catch (_) {}
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _glintController.dispose();
    super.dispose();
  }

  void _handleEditSearch() async {
    HapticFeedback.lightImpact();
    if (widget.onEditSearch != null) {
      widget.onEditSearch!();
      return;
    }
    await LocalCacheService().clearRelativeBrowseSession();
    if (!mounted) return;
    Navigator.of(context, rootNavigator: true).pushNamedAndRemoveUntil(
      AppRoutes.userTypeSelection,
      (route) => false,
    );
  }

  void _handleCreateBiodata() async {
    HapticFeedback.mediumImpact();
    if (widget.onCreateBiodata != null) {
      widget.onCreateBiodata!();
      return;
    }
    await LocalCacheService().clearRelativeBrowseSession();
    await LocalCacheService().setGuestMode(false);
    if (!mounted) return;
    Navigator.of(context, rootNavigator: true).pushNamed(AppRoutes.biodataCreation);
  }

  @override
  Widget build(BuildContext context) {
    final chipLabel = widget.activeChipLabel ?? 'नातेवाईकांसाठी शोध';

    return RepaintBoundary(
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 3.5.w, vertical: 1.h),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(22),
          gradient: const LinearGradient(
            colors: [
              AppColors.maroonDarkest, // Deep Royal Velvet Burgundy
              AppColors.burgundy, // Rich Imperial Crimson
              AppColors.wineRed, // Warm Radiant Ruby
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.22),
            width: 1.2,
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.maroonAccent.withValues(alpha: AppColors.opacity40),
              blurRadius: 18,
              offset: const Offset(0, 6),
              spreadRadius: 1,
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(22),
          child: Stack(
            children: [
              // ── Ambient Background Accents ──
              Positioned(
                top: -30,
                right: -25,
                child: Container(
                  width: 130,
                  height: 130,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        AppColors.categoryVip.withValues(alpha: 0.18),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
              ),
              Positioned(
                bottom: -20,
                left: -20,
                child: Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        Colors.white.withValues(alpha: AppColors.opacity8),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
              ),

              // ── Card Foreground Content ──
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.6.h),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ── Active Filter Chip + Edit Action Row ──
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Glassmorphic Active Filter Badge
                        Expanded(
                          child: Container(
                            padding: EdgeInsets.symmetric(horizontal: 2.8.w, vertical: 0.6.h),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(24),
                              border: Border.all(
                                color: Colors.white.withValues(alpha: AppColors.opacity30),
                              ),
                            ),
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.explore_rounded,
                                  size: 14,
                                  color: AppColors.categoryVip,
                                ),
                                SizedBox(width: 1.5.w),
                                Expanded(
                                  child: Text(
                                    chipLabel,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: AppTypography.labelMedium,
                                      fontWeight: AppTypography.extraBold,
                                      letterSpacing: 0.1,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),

                        SizedBox(width: 2.w),

                        // Change Filter Button ("बदला") with TactilePressable
                        TactilePressable(
                          onTap: _handleEditSearch,
                          child: Container(
                            padding: EdgeInsets.symmetric(horizontal: 2.8.w, vertical: 0.6.h),
                            decoration: BoxDecoration(
                              color: Colors.black.withValues(alpha: AppColors.opacity30),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: Colors.white.withValues(alpha: 0.25),
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.edit_note_rounded,
                                  size: 14,
                                  color: Colors.white.withValues(alpha: 0.95),
                                ),
                                SizedBox(width: 1.w),
                                Text(
                                  'बदला',
                                  style: TextStyle(
                                    fontFamily: AppTypography.headingFontFamily,
                                    color: Colors.white,
                                    fontSize: AppTypography.labelMedium,
                                    fontWeight: AppTypography.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),

                    SizedBox(height: 1.4.h),

                    // ── Card Headline & Subtitle + Pulsing Metallic Gold CTA ──
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _hasDraft
                                    ? 'अपूर्ण बायोडेटा पूर्ण करा'
                                    : 'उमेदवाराचा बायोडेटा उपलब्ध आहे का?',
                                style: TextStyle(
                                  fontFamily: AppTypography.headingFontFamily,
                                  color: Colors.white,
                                  fontSize: AppTypography.bodySmall,
                                  fontWeight: AppTypography.black,
                                  letterSpacing: -0.2,
                                  height: 1.2,
                                ),
                              ),
                              SizedBox(height: 0.4.h),
                              Text(
                                _hasDraft
                                    ? 'तुम्ही भरलेली माहिती सुरक्षित आहे. फक्त काही माहिती बाकी आहे.'
                                    : 'इतर बंजारा परिवारांना स्थळ दाखवण्यासाठी बायोडेटा बनवा.',
                                style: TextStyle(
                                  color: Colors.white.withValues(alpha: AppColors.opacity85),
                                  fontSize: AppTypography.labelMedium,
                                  fontWeight: AppTypography.medium,
                                  height: 1.25,
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(width: 2.5.w),

                        // ── Pulsing Metallic Gold CTA Button with Sheen Glint ──
                        AnimatedBuilder(
                          animation: _pulseController,
                          builder: (context, child) {
                            return Transform.scale(
                              scale: _scaleAnimation.value,
                              child: child,
                            );
                          },
                          child: TactilePressable(
                            onTap: _handleCreateBiodata,
                            child: Container(
                              padding: EdgeInsets.symmetric(horizontal: 3.5.w, vertical: 1.1.h),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(16),
                                gradient: const LinearGradient(
                                  colors: [
                                    AppColors.goldGlow, // Soft Bright Gold
                                    AppColors.goldSoft, // Rich Amber Gold
                                    AppColors.categoryAstro, // Deep Gold
                                  ],
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: AppColors.amber600.withValues(alpha: 0.45),
                                    blurRadius: 12,
                                    offset: const Offset(0, 3),
                                  ),
                                ],
                                border: Border.all(
                                  color: Colors.white.withValues(alpha: AppColors.opacity60),
                                ),
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(16),
                                child: Stack(
                                  children: [
                                    Positioned.fill(
                                      child: AnimatedBuilder(
                                        animation: _glintController,
                                        builder: (context, child) {
                                          return CustomPaint(
                                            painter: _HeroSheenGlintPainter(
                                              percent: _glintController.value,
                                            ),
                                          );
                                        },
                                      ),
                                    ),
                                    Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        const Icon(
                                          Icons.auto_awesome_rounded,
                                          size: 15,
                                          color: AppColors.amberBgDark,
                                        ),
                                        SizedBox(width: 1.2.w),
                                        Text(
                                          _hasDraft ? 'बायोडेटा पूर्ण करा' : 'बायोडेटा बनवा',
                                          style: TextStyle(
                                            fontFamily: AppTypography.headingFontFamily,
                                            color: AppColors.amberBgDark,
                                            fontSize: AppTypography.labelMedium,
                                            fontWeight: AppTypography.black,
                                            letterSpacing: 0.1,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),

                    SizedBox(height: 1.2.h),

                    // ── Bottom Completion Status Line ──
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 0.7.h),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.22),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: Colors.white.withValues(alpha: AppColors.opacity12),
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            _hasDraft ? Icons.edit_note_rounded : Icons.verified_user_rounded,
                            size: 13.5,
                            color: AppColors.categoryVip,
                          ),
                          SizedBox(width: 1.8.w),
                          Expanded(
                            child: Text(
                              _hasDraft
                                  ? '📝 तुमचा ड्राफ्ट सेव्ह आहे • २ मिनिटांत पूर्ण करा'
                                  : '🔒 बायोडेटा बनवल्याने इतर परिवार थेट तुमच्याशी संपर्क करू शकतील',
                              style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.92),
                                fontSize: AppTypography.labelSmall,
                                fontWeight: AppTypography.medium,
                              ),
                            ),
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
      ),
    );
  }
}

/// 🌟 Shimmering Diagonal Light-Sweep Glint Painter for Hero CTA
class _HeroSheenGlintPainter extends CustomPainter {
  final double percent;

  _HeroSheenGlintPainter({required this.percent});

  @override
  void paint(Canvas canvas, Size size) {
    final double glintWidth = size.width * 0.45;
    final double totalDistance = size.width + glintWidth * 2;
    final double currentX = -glintWidth + (totalDistance * percent);

    final Paint paint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Colors.white.withValues(alpha: 0.0),
          Colors.white.withValues(alpha: 0.35),
          Colors.white.withValues(alpha: 0.0),
        ],
        stops: const [0.0, 0.5, 1.0],
      ).createShader(Rect.fromLTWH(currentX, 0, glintWidth, size.height));

    final Path path = Path()
      ..moveTo(currentX, 0)
      ..lineTo(currentX + glintWidth, 0)
      ..lineTo(currentX + glintWidth - (size.height * math.tan(0.35)), size.height)
      ..lineTo(currentX - (size.height * math.tan(0.35)), size.height)
      ..close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _HeroSheenGlintPainter oldDelegate) =>
      oldDelegate.percent != percent;
}
