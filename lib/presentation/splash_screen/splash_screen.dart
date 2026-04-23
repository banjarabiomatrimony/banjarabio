import 'package:banjarabio/l10n/app_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:sizer/sizer.dart';

import 'package:banjarabio/core/app_export.dart';
import 'package:banjarabio/core/utils/startup_workflow.dart';
import 'package:banjarabio/core/services/startup_orchestrator.dart';
import 'package:banjarabio/widgets/app_logo_image.dart';

/// 🚨 ANR-SAFE SPLASH SCREEN
/// 
/// ZERO AnimationControllers. ZERO GPU buffer allocations (gralloc4).
/// Just a static branded screen that paints in a single frame.
/// 
/// On MediaTek Vivo V2105, animated splash screens generate 100+ gralloc4
/// GPU buffer allocations per second via AnimatedBuilder/FadeTransition.
/// Combined with the 4+ second BOOTING phase, these GPU allocations push
/// cumulative resource usage past the OEM kill threshold (Signal 3).
/// 
/// This screen renders instantly (<16ms), then runs BOOTING + CRITICAL
/// phases asynchronously while the user sees the branded splash.
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
      debugPrint('Initialization error: $e');
    }

    if (mounted) {
      final prefs = await SharedPreferences.getInstance();
      final hasSavedLocale = prefs.getString('selected_locale') != null;

      if (hasSavedLocale) {
        debugPrint('Splash: Locale already saved, jumping to status-based navigation');
        if (mounted) {
          await StartupWorkflow.navigateBasedOnStatus(context);
        }
      } else {
        debugPrint('Splash: No locale saved, showing Language Selection');
        if (mounted) {
          Navigator.of(context).pushReplacementNamed(AppRoutes.initialLanguageSelection);
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // 🚨 ZERO-GPU SPLASH: Completely static widget tree.
    // No AnimationController, no FadeTransition, no AnimatedBuilder.
    // Paints in a single frame (<16ms) with zero gralloc4 allocations.
    final iconSize = (40.w).clamp(120.0, 180.0);

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFF432C7A),
              Color(0xFF2A1B4D),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                // ── Logo ──
                Container(
                  width: iconSize,
                  height: iconSize,
                  padding: EdgeInsets.all(2.5.h),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.2),
                        blurRadius: 8,
                        offset: const Offset(0, 10),
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
                    fontFamily: 'Poppins',
                    fontSize: 24.sp,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    letterSpacing: 1.2,
                  ),
                ),

                SizedBox(height: 1.h),

                // ── Static tagline ──
                Text(
                  'Connect with your community',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w400,
                    color: Colors.white.withValues(alpha: 0.9),
                  ),
                ),

                SizedBox(height: 6.h),

                // ── Static loading dots (NO animation controller!) ──
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(3, (i) => Container(
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.6),
                      shape: BoxShape.circle,
                    ),
                  )),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
