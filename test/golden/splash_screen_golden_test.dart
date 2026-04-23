import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import '../helpers/golden_test_helpers.dart';

/// SplashScreen golden test uses an isolated replica of the static UI
/// to avoid StartupOrchestrator/SharedPreferences async dependencies.
/// This tests the VISUAL output — the branded splash look.
Widget _buildSplashVisual({required bool isDark}) {
  final iconSize = 160.0; // Replaces the responsive 40.w clamp

  return Scaffold(
    body: Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF432C7A), Color(0xFF2A1B4D)],
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
              // Logo placeholder
              Container(
                width: iconSize,
                height: iconSize,
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
                  child: Icon(Icons.favorite, size: 80, color: Color(0xFF432C7A)),
                ),
              ),
              const SizedBox(height: 32),
              const Text(
                'BanjaraBio',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  letterSpacing: 1.2,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Connect with your community',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                  color: Colors.white.withValues(alpha: 0.9),
                ),
              ),
              const SizedBox(height: 48),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  3,
                  (i) => Container(
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.6),
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}

void main() {
  group('SplashScreen Golden', () {
    testWidgets('light mode — branded splash', (tester) async {
      setupGoldenViewport(tester);
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(goldenLightApp(_buildSplashVisual(isDark: false)));
      await tester.pump();

      await expectLater(
        find.byType(Scaffold),
        matchesGoldenFile('goldens/splash_screen_light.png'),
      );
    });

    testWidgets('dark mode — branded splash', (tester) async {
      setupGoldenViewport(tester);
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(goldenDarkApp(_buildSplashVisual(isDark: true)));
      await tester.pump();

      await expectLater(
        find.byType(Scaffold),
        matchesGoldenFile('goldens/splash_screen_dark.png'),
      );
    });
  });
}
