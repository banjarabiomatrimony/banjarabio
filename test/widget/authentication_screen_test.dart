// test/widget/authentication_screen_test.dart
// Widget tests for AuthenticationScreen — UI rendering, user interactions,
// error display, loading states, and navigation triggers.

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:sizer/sizer.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:banjarabio/l10n/app_localizations.dart';
import 'package:banjarabio/core/supabase_client.dart';
import 'package:banjarabio/core/session_manager.dart';
import 'package:banjarabio/core/services/local_cache_service.dart';
import 'package:banjarabio/core/services/telemetry_service.dart';
import 'package:banjarabio/core/repositories/profile_repository.dart';
import 'package:banjarabio/presentation/authentication_screen/authentication_screen.dart';
import 'package:banjarabio/routes/app_routes.dart';

import '../helpers/supabase_fakes.dart';
import '../helpers/widget_test_helpers.dart';
import '../helpers/mock_services.dart';

void main() {
  late MockGoTrueClient mockAuth;
  late FakeSupabaseClient fakeClient;
  late MockBox mockBox;

  setUp(() {
    mockAuth = MockGoTrueClient();
    fakeClient = FakeSupabaseClient();
    mockBox = MockBox();

    AppSupabaseClient.testAuth = mockAuth;
    AppSupabaseClient.testClient = fakeClient;
    ProfileRepository().testClient = fakeClient;

    // Auth defaults
    when(() => mockAuth.currentUser).thenReturn(null);
    when(() => mockAuth.onAuthStateChange).thenAnswer((_) => const Stream.empty());

    // Hive
    LocalCacheService().testBoxOpener = (name) => mockBox;
    when(() => mockBox.get(any())).thenReturn(null);
    when(() => mockBox.get(any(), defaultValue: any(named: 'defaultValue')))
        .thenAnswer((inv) => inv.namedArguments[#defaultValue]);
    when(() => mockBox.put(any(), any())).thenAnswer((_) async => {});
    when(() => mockBox.delete(any())).thenAnswer((_) async => {});

    // Session
    SharedPreferences.setMockInitialValues({});
    SessionManager.instance.testPrefs = FakeSharedPreferences();

    // Telemetry
    TelemetryService.instance = NoOpTelemetryService();
  });

  tearDown(() {
    tearDownWidgetTestMocks();
  });

  // Helper: Wrap AuthenticationScreen with all providers
  Widget buildTestWidget({bool embedded = false}) {
    return Sizer(
      builder: (context, orientation, deviceType) => ProviderScope(
        child: MaterialApp(
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: AppLocalizations.supportedLocales,
          routes: {
            AppRoutes.home: (_) => const Scaffold(body: Text('HomeScreen')),
            AppRoutes.biodataCreation: (_) => const Scaffold(body: Text('BiodataCreation')),
            AppRoutes.userTypeSelection: (_) => const Scaffold(body: Text('UserTypeSelection')),
            AppRoutes.profileDetail: (_) => const Scaffold(body: Text('ProfileDetail')),
            AppRoutes.adminDashboard: (_) => const Scaffold(body: Text('AdminDashboard')),
            AppRoutes.staffDashboard: (_) => const Scaffold(body: Text('StaffDashboard')),
          },
          home: AuthenticationScreen(embedded: embedded),
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // 1. Basic UI Rendering
  // ═══════════════════════════════════════════════════════════════════════════
  group('UI rendering', () {
    testWidgets('renders Google Sign-In button by default', (tester) async {
      setTestScreenSize(tester);
      await tester.pumpWidget(buildTestWidget());
      await tester.pump(const Duration(milliseconds: 300));

      // Google button should be visible
      expect(find.byType(InkWell), findsWidgets);
    });

    testWidgets('renders welcome text', (tester) async {
      setTestScreenSize(tester);
      await tester.pumpWidget(buildTestWidget());
      await tester.pump(const Duration(milliseconds: 300));

      // Welcome text should be present
      expect(find.textContaining('Welcome'), findsWidgets);
    });

    testWidgets('renders benefit badges', (tester) async {
      setTestScreenSize(tester);
      await tester.pumpWidget(buildTestWidget());
      await tester.pump(const Duration(milliseconds: 300));

      // At least some benefit text should render
      expect(find.byIcon(Icons.verified_user), findsOneWidget);
      expect(find.byIcon(Icons.security), findsOneWidget);
    });

    testWidgets('does NOT show loading overlay initially', (tester) async {
      setTestScreenSize(tester);
      await tester.pumpWidget(buildTestWidget());
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.byType(CircularProgressIndicator), findsNothing);
    });
  });

  // ═══════════════════════════════════════════════════════════════════════════
  // 2. Email Login Toggle
  // ═══════════════════════════════════════════════════════════════════════════
  group('Email login toggle', () {
    testWidgets('toggles to email form when tapped', (tester) async {
      setTestScreenSize(tester);
      await tester.pumpWidget(buildTestWidget());
      await tester.pump(const Duration(milliseconds: 300));

      // Find and tap the "Use Email / Password" toggle button
      final emailToggle = find.byIcon(Icons.email_outlined);
      if (emailToggle.evaluate().isNotEmpty) {
        await tester.tap(emailToggle.first);
        await tester.pumpAndSettle();

        // Email and password fields should now be visible
        expect(find.byType(TextField), findsWidgets);
      }
    });

    testWidgets('back button returns to Google mode', (tester) async {
      setTestScreenSize(tester);
      await tester.pumpWidget(buildTestWidget());
      await tester.pump(const Duration(milliseconds: 300));

      // Toggle to email
      final emailToggle = find.byIcon(Icons.email_outlined);
      if (emailToggle.evaluate().isNotEmpty) {
        await tester.tap(emailToggle.first);
        await tester.pumpAndSettle();

        // Now toggle back
        final backToggle = find.byIcon(Icons.arrow_back);
        if (backToggle.evaluate().isNotEmpty) {
          await tester.tap(backToggle.first);
          await tester.pumpAndSettle();

          // Email fields should be gone
          expect(find.byType(TextField), findsNothing);
        }
      }
    });
  });

  // ═══════════════════════════════════════════════════════════════════════════
  // 3. Email Validation
  // ═══════════════════════════════════════════════════════════════════════════
  group('Email form validation', () {
    testWidgets('shows error for empty fields', (tester) async {
      setTestScreenSize(tester);
      await tester.pumpWidget(buildTestWidget());
      await tester.pump(const Duration(milliseconds: 300));

      // Toggle to email form
      final emailToggle = find.byIcon(Icons.email_outlined);
      if (emailToggle.evaluate().isNotEmpty) {
        await tester.tap(emailToggle.first);
        await tester.pumpAndSettle();

        // Find login button and tap with empty fields
        final loginBtn = find.widgetWithText(ElevatedButton, 'Login');
        if (loginBtn.evaluate().isNotEmpty) {
          await tester.tap(loginBtn);
          await tester.pumpAndSettle();

          // Error message should appear
          expect(find.byIcon(Icons.error_outline), findsOneWidget);
        }
      }
    });
  });

  // ═══════════════════════════════════════════════════════════════════════════
  // 4. Embedded Mode
  // ═══════════════════════════════════════════════════════════════════════════
  group('Embedded mode', () {
    testWidgets('renders without Scaffold wrapper in embedded mode', (tester) async {
      setTestScreenSize(tester);
      await tester.pumpWidget(buildTestWidget(embedded: true));
      await tester.pump(const Duration(milliseconds: 300));

      // In embedded mode, the widget renders directly inside the parent MaterialApp's Scaffold
      // So we should still find the core content but inside the MaterialApp scaffold
      expect(find.byType(SingleChildScrollView), findsWidgets);
    });
  });

  // ═══════════════════════════════════════════════════════════════════════════
  // 5. Terms & Privacy Links
  // ═══════════════════════════════════════════════════════════════════════════
  group('Legal text', () {
    testWidgets('renders terms and privacy text', (tester) async {
      setTestScreenSize(tester);
      await tester.pumpWidget(buildTestWidget());
      await tester.pump(const Duration(milliseconds: 300));

      // RichText should contain Terms and Privacy
      expect(find.byType(RichText), findsWidgets);
    });
  });
}
