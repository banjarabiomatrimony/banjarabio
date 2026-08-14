import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';

import 'package:banjarabio/core/services/local_cache_service.dart';
import 'package:banjarabio/routes/app_routes.dart';

/// Premium Global-Standard Hero Banner for Relative Browse Mode.
/// Features a royal burgundy mesh gradient, frosted glassmorphic filter chip,
/// ambient glow accents, and a metallic gold CTA with subtle micro-animation.
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
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulseController;
  late final Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2400),
    )..repeat(reverse: true);

    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.03).animate(
      CurvedAnimation(
        parent: _pulseController,
        curve: Curves.easeInOutSine,
      ),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
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
      AppRoutes.onboardingSelection,
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
          borderRadius: BorderRadius.circular(20),
          gradient: const LinearGradient(
            colors: [
              Color(0xFF4A0012), // Deep Royal Velvet Burgundy
              Color(0xFF7B0024), // Rich Imperial Crimson
              Color(0xFFA10830), // Warm Radiant Ruby
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.18),
            width: 1.2,
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF5A0016).withValues(alpha: 0.40),
              blurRadius: 18,
              offset: const Offset(0, 6),
              spreadRadius: 1,
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
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
                        const Color(0xFFFFD700).withValues(alpha: 0.18),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
              ),
              Positioned(
                bottom: -40,
                left: -20,
                child: Container(
                  width: 110,
                  height: 110,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        Colors.white.withValues(alpha: 0.08),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
              ),

              // ── Main Content Body ──
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.6.h),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // ── Header Row: Frosted Filter Chip + Edit Button ──
                    Row(
                      children: [
                        // Frosted Glass Filter Pill
                        Flexible(
                          child: Container(
                            padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 0.55.h),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.14),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: Colors.white.withValues(alpha: 0.28),
                                width: 0.8,
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(
                                  Icons.explore_rounded,
                                  size: 14,
                                  color: Color(0xFFFFD700),
                                ),
                                SizedBox(width: 1.5.w),
                                Flexible(
                                  child: Text(
                                    chipLabel,
                                    style: TextStyle(
                                      fontSize: 8.8.sp,
                                      fontWeight: FontWeight.w700,
                                      color: Colors.white,
                                      letterSpacing: 0.1,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        SizedBox(width: 2.w),

                        // Edit Criteria Action Button
                        Material(
                          color: Colors.transparent,
                          child: InkWell(
                            onTap: _handleEditSearch,
                            borderRadius: BorderRadius.circular(20),
                            child: Container(
                              padding: EdgeInsets.symmetric(horizontal: 2.5.w, vertical: 0.5.h),
                              decoration: BoxDecoration(
                                color: Colors.black.withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: Colors.white.withValues(alpha: 0.20),
                                  width: 0.8,
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
                                      fontSize: 8.5.sp,
                                      fontWeight: FontWeight.w700,
                                      color: Colors.white.withValues(alpha: 0.95),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),

                    SizedBox(height: 1.3.h),

                    // ── Card Headline & Subtitle ──
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'उमेदवाराचा बायोडेटा उपलब्ध आहे का?',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 10.8.sp,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: -0.2,
                                  height: 1.2,
                                ),
                              ),
                              SizedBox(height: 0.4.h),
                              Text(
                                'इतर बंजारा परिवारांना स्थळ दाखवण्यासाठी बायोडेटा बनवा.',
                                style: TextStyle(
                                  color: Colors.white.withValues(alpha: 0.85),
                                  fontSize: 8.5.sp,
                                  fontWeight: FontWeight.w400,
                                  height: 1.25,
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(width: 2.5.w),

                        // ── Pulsing Metallic Gold CTA Button ──
                        AnimatedBuilder(
                          animation: _pulseController,
                          builder: (context, child) {
                            return Transform.scale(
                              scale: _scaleAnimation.value,
                              child: child,
                            );
                          },
                          child: Material(
                            color: Colors.transparent,
                            child: InkWell(
                              onTap: _handleCreateBiodata,
                              borderRadius: BorderRadius.circular(14),
                              child: Container(
                                padding: EdgeInsets.symmetric(horizontal: 3.5.w, vertical: 1.1.h),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(14),
                                  gradient: const LinearGradient(
                                    colors: [
                                      Color(0xFFFFE066), // Soft Bright Gold
                                      Color(0xFFFFC72C), // Rich Amber Gold
                                      Color(0xFFE5A100), // Deep Gold
                                    ],
                                    begin: Alignment.topCenter,
                                    end: Alignment.bottomCenter,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: const Color(0xFFFFB300).withValues(alpha: 0.45),
                                      blurRadius: 10,
                                      offset: const Offset(0, 3),
                                    ),
                                  ],
                                  border: Border.all(
                                    color: Colors.white.withValues(alpha: 0.6),
                                  ),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(
                                      Icons.auto_awesome_rounded,
                                      size: 15,
                                      color: Color(0xFF3E1700),
                                    ),
                                    SizedBox(width: 1.2.w),
                                    Text(
                                      'बायोडेटा बनवा',
                                      style: TextStyle(
                                        color: const Color(0xFF3E1700),
                                        fontSize: 9.5.sp,
                                        fontWeight: FontWeight.w900,
                                        letterSpacing: 0.1,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
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
