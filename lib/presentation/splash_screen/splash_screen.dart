import 'package:banjarabio/l10n/app_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:sizer/sizer.dart';
import 'package:banjarabio/core/constants/app_typography.dart';

import 'package:banjarabio/core/app_export.dart';
import 'package:banjarabio/core/utils/startup_workflow.dart';
import 'package:banjarabio/core/services/startup_orchestrator.dart';
import 'package:banjarabio/widgets/app_logo_image.dart';
import 'package:banjarabio/core/services/app_logger.dart';

/// 🚨 ANR-SAFE SPLASH SCREEN
/// 
/// ZERO AnimationControllers. ZERO GPU buffer allocations (gralloc4).
/// Uses TweenAnimationBuilder (implicit, single-shot) for a subtle
/// scale+fade reveal that runs for exactly 1 transition — safe on MediaTek.
/// 
/// On MediaTek Vivo V2105, animated splash screens generate 100+ gralloc4
/// GPU buffer allocations per second via AnimatedBuilder/FadeTransition.
/// Combined with the 4+ second BOOTING phase, these GPU allocations push
/// cumulative resource usage past the OEM kill threshold (Signal 3).
/// 
/// TweenAnimationBuilder is safe because:
/// - It's an implicit animation (no ticker/AnimationController)
/// - Runs exactly once on build, then stops (no continuous loop)
/// - Zero overhead after the initial ~600ms transition completes
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    // Defer ALL heavy init to after the first frame has painted.
    // This ensures the Android Activity has a visible frame within ~16ms.
    SchedulerBinding.instance.addPostFrameCallback((_) {
      _initializeApp();
    });
  }

  Future<void> _initializeApp() async {
    try {
      // 🚨 CRITICAL OEM FIX: Run initialization phases HERE, AFTER the splash
      // screen has rendered its STATIC first frame. The Activity now has a
      // visible frame within ~16ms, satisfying all OEM process managers:
      //   - Vivo FunTouch PerfThread
      //   - Samsung One UI ANR watchdog
      //   - Xiaomi MIUI battery optimization
      //   - Oppo ColorOS / Realme UI power manager
      await StartupOrchestrator().advanceToPhase(StartupPhase.booting);
      await StartupOrchestrator().advanceToPhase(StartupPhase.critical);
    } catch (e) {
      AppLogger.error('SplashScreen', 'Initialization error: $e');
    }

    if (mounted) {
      final prefs = await SharedPreferences.getInstance();
      final hasSavedLocale = prefs.getString('selected_locale') != null;

      if (hasSavedLocale) {
        AppLogger.debug('SplashScreen', 'Splash: Locale already saved, jumping to status-based navigation');
        if (mounted) {
          await StartupWorkflow.navigateBasedOnStatus(context);
        }
      } else {
        AppLogger.debug('SplashScreen', 'Splash: No locale saved, showing Language Selection');
        if (mounted) {
          Navigator.of(context).pushReplacementNamed(AppRoutes.initialLanguageSelection);
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // 🚨 ANR-SAFE: TweenAnimationBuilder is an implicit animation.
    // No AnimationController, no ticker, no continuous GPU allocations.
    // Runs once for 600ms then becomes a static widget tree.
    final iconSize = (40.w).clamp(120.0, 180.0);

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              AppTheme.primaryLight,        // Midnight Amethyst
              AppTheme.primaryVariantLight,  // Deeper Amethyst
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: Center(
            // Single-shot scale+fade animation — safe on all OEM devices
            child: TweenAnimationBuilder<double>(
              tween: Tween(begin: 0.0, end: 1.0),
              duration: const Duration(milliseconds: 600),
              curve: Curves.easeOutCubic,
              builder: (context, value, child) {
                return Opacity(
                  opacity: value,
                  child: Transform.scale(
                    scale: 0.85 + (0.15 * value), // 0.85 → 1.0
                    child: child,
                  ),
                );
              },
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // ── Logo with glow ──
                  Container(
                    width: iconSize,
                    height: iconSize,
                    padding: EdgeInsets.all(2.5.h),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: AppTheme.secondaryLight.withValues(alpha: 0.3),
                          blurRadius: 24,
                          spreadRadius: 4,
                          offset: const Offset(0, 4),
                        ),
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.15),
                          blurRadius: 12,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: const Center(
                      child: AppLogoImage(),
                    ),
                  ),

                  SizedBox(height: 4.h),

                  // ── App name ──
                  Text(
                    AppLocalizations.of(context)?.banjarabio ?? 'BanjaraBio',
                    style: TextStyle(
                      fontFamily: AppTheme.headingFontFamily,
                      fontSize: AppTypography.headingLarge,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      letterSpacing: 1.2,
                    ),
                  ),

                  SizedBox(height: 1.h),

                  // ── Tagline ──
                  Text(
                    'Connect with your community',
                    style: TextStyle(
                      fontFamily: AppTheme.headingFontFamily,
                      fontSize: AppTypography.bodyMedium,
                      fontWeight: FontWeight.w400,
                      color: Colors.white.withValues(alpha: 0.9),
                    ),
                  ),

                  SizedBox(height: 6.h),

                  // ── Animated loading indicator ──
                  // Uses implicit staggered animation — no AnimationController
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(3, (i) => TweenAnimationBuilder<double>(
                      tween: Tween(begin: 0.3, end: 0.8),
                      duration: Duration(milliseconds: 600 + (i * 200)),
                      curve: Curves.easeInOut,
                      builder: (context, opacity, child) {
                        return Container(
                          margin: const EdgeInsets.symmetric(horizontal: 4),
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: AppTheme.secondaryLight.withValues(alpha: opacity),
                            shape: BoxShape.circle,
                          ),
                        );
                      },
                    )),
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
