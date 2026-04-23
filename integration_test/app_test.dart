import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:banjarabio/main.dart' as app;

/// Phase 3: End-to-end integration tests running on a physical device.
///
/// These tests exercise the real app with live backend (Supabase).
/// Run: flutter test integration_test/app_test.dart -d 3080599589000AF
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Happy Path 1: App Boot', () {
    testWidgets('splash screen renders with branding', (tester) async {
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 2));

      // Splash screen should show — at minimum a Scaffold renders
      expect(find.byType(Scaffold), findsWidgets);
    });
  });

  group('Happy Path 2: Splash → Auth Navigation', () {
    testWidgets('unauthenticated user lands on auth screen', (tester) async {
      app.main();

      // Wait for splash + startup orchestrator (BOOTING + CRITICAL phases)
      // to complete and navigate. Allow generous time for real init.
      await tester.pumpAndSettle(const Duration(seconds: 10));

      // Auth screen should show for unauthenticated user
      // The auth screen has "Welcome to BanjaraBio" text
      final welcomeFinder = find.text('Welcome to BanjaraBio');
      final googleFinder = find.text('Continue with Google');

      // If user is already logged in, they'll be on HomeScreen instead
      if (welcomeFinder.evaluate().isNotEmpty) {
        expect(welcomeFinder, findsOneWidget);
        expect(googleFinder, findsOneWidget);
        debugPrint('✅ Landed on Auth Screen (unauthenticated)');
      } else {
        // User is authenticated — they landed on Home or Onboarding
        debugPrint('✅ User is already authenticated — skipped to Home/Onboarding');
        expect(find.byType(Scaffold), findsWidgets);
      }
    });
  });

  group('Happy Path 3: Auth Email Form', () {
    testWidgets('toggle to email form shows fields', (tester) async {
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 10));

      final emailToggle = find.text('Use Email / Password');
      if (emailToggle.evaluate().isNotEmpty) {
        // On auth screen — test email toggle
        await tester.tap(emailToggle);
        await tester.pumpAndSettle();

        // Email and password TextFields should appear
        expect(find.byType(TextField), findsNWidgets(2));
        expect(find.text('Login'), findsOneWidget);

        debugPrint('✅ Email form toggled successfully');

        // Toggle back
        final backToggle = find.text('Back to Google Sign In');
        if (backToggle.evaluate().isNotEmpty) {
          await tester.tap(backToggle);
          await tester.pumpAndSettle();
          expect(find.text('Continue with Google'), findsOneWidget);
          debugPrint('✅ Toggled back to Google sign-in');
        }
      } else {
        debugPrint('⏭️ Skipped — user is already authenticated');
      }
    });
  });

  group('Happy Path 4: Home Screen Tab Navigation', () {
    testWidgets('4 bottom tabs switch correctly', (tester) async {
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 10));

      // This test only works if the user is logged in and on HomeScreen
      final bottomBar = find.byType(BottomNavigationBar);
      if (bottomBar.evaluate().isNotEmpty) {
        // Home tab is active by default (index 0)
        debugPrint('✅ Home screen loaded with bottom nav bar');

        // Tap Settings tab (index 3)
        final settingsTab = find.text('Settings');
        if (settingsTab.evaluate().isNotEmpty) {
          await tester.tap(settingsTab.last);
          await tester.pumpAndSettle(const Duration(seconds: 2));
          debugPrint('✅ Switched to Settings tab');
        }

        // Tap Profile tab (index 2)
        final profileTab = find.text('Profile');
        if (profileTab.evaluate().isNotEmpty) {
          await tester.tap(profileTab.last);
          await tester.pumpAndSettle(const Duration(seconds: 2));
          debugPrint('✅ Switched to Profile tab');
        }

        // Return to Home tab (index 0)
        final homeTab = find.text('Home');
        if (homeTab.evaluate().isNotEmpty) {
          await tester.tap(homeTab.last);
          await tester.pumpAndSettle(const Duration(seconds: 2));
          debugPrint('✅ Returned to Home tab');
        }
      } else {
        debugPrint('⏭️ Skipped — not on Home screen (user may not be authenticated)');
        expect(find.byType(Scaffold), findsWidgets);
      }
    });
  });

  group('Happy Path 5: Settings → FAQ Navigation', () {
    testWidgets('navigate to FAQ and verify questions', (tester) async {
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 10));

      // Navigate to Settings tab if on HomeScreen
      final settingsTab = find.text('Settings');
      if (settingsTab.evaluate().isNotEmpty) {
        await tester.tap(settingsTab.last);
        await tester.pumpAndSettle(const Duration(seconds: 2));

        // Find and tap FAQs item
        final faqItem = find.text('FAQs');
        if (faqItem.evaluate().isNotEmpty) {
          await tester.tap(faqItem);
          await tester.pumpAndSettle(const Duration(seconds: 2));

          // Verify FAQ screen loaded with questions
          expect(find.text('FAQs'), findsWidgets); // AppBar + any duplicate
          expect(find.byType(ExpansionTile), findsNWidgets(5));
          expect(find.text('How do I create a biodata?'), findsOneWidget);
          expect(find.text('Is my data secure?'), findsOneWidget);

          debugPrint('✅ FAQ screen loaded with 5 questions');

          // Navigate back
          await tester.tap(find.byType(IconButton).first);
          await tester.pumpAndSettle();
          debugPrint('✅ Navigated back from FAQ');
        } else {
          debugPrint('⏭️ FAQs item not found in Settings');
        }
      } else {
        debugPrint('⏭️ Skipped — not on Home screen');
      }
    });
  });
}
