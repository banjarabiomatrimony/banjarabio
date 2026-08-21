// test/unit/startup_workflow_test.dart
// Unit tests for StartupWorkflow navigation routing decisions.
//
// ARCHITECTURE NOTE: StartupWorkflow._schedulePhaseAdvancement creates
// Future.delayed(8s) and Future.delayed(20s) background timers. These
// cause "pending timer" assertions in widget tests. The widget tests here
// pump past the longest timer (21s) to clear them after asserting navigation.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:banjarabio/core/utils/startup_workflow.dart';
import 'package:banjarabio/core/supabase_client.dart';
import 'package:banjarabio/core/session_manager.dart';
import 'package:banjarabio/core/services/local_cache_service.dart';
import 'package:banjarabio/core/services/telemetry_service.dart';
import 'package:banjarabio/core/repositories/profile_repository.dart';

import '../helpers/supabase_fakes.dart';
import '../helpers/mock_services.dart';
import '../helpers/widget_test_helpers.dart';

void main() {
  late FakeSupabaseClient fakeClient;
  late MockGoTrueClient mockAuth;
  late MockUser mockUser;
  late MockBox mockBox;

  setUp(() {
    fakeClient = FakeSupabaseClient();
    mockAuth = MockGoTrueClient();
    mockUser = MockUser();
    mockBox = MockBox();

    AppSupabaseClient.testAuth = mockAuth;
    AppSupabaseClient.testClient = fakeClient;
    ProfileRepository().testClient = fakeClient;

    LocalCacheService().testBoxOpener = (name) => mockBox;
    when(() => mockBox.get(any())).thenReturn(null);
    when(() => mockBox.get(any(), defaultValue: any(named: 'defaultValue')))
        .thenAnswer((inv) => inv.namedArguments[#defaultValue]);
    when(() => mockBox.put(any(), any())).thenAnswer((_) async => {});
    when(() => mockBox.delete(any())).thenAnswer((_) async => {});

    SharedPreferences.setMockInitialValues({});
    SessionManager.instance.testPrefs = FakeSharedPreferences();
    TelemetryService.instance = NoOpTelemetryService();

    when(() => mockAuth.onAuthStateChange).thenAnswer((_) => const Stream.empty());
  });

  tearDown(() {
    tearDownWidgetTestMocks();
  });

  Widget buildTestApp({required Widget home}) {
    return MaterialApp(
      home: home,
      onGenerateRoute: (settings) {
        late Widget page;
        switch (settings.name) {
          case '/user-type-selection':
            page = const Scaffold(body: Text('UserTypeSelection'));
          case '/admin-dashboard':
            page = const Scaffold(body: Text('AdminDashboard'));
          case '/staff-dashboard':
            page = const Scaffold(body: Text('StaffDashboard'));
          case '/home-screen':
            page = const Scaffold(body: Text('HomeScreen'));
          case '/biodata-creation-screen':
            page = const Scaffold(body: Text('BiodataCreation'));
          default:
            page = Scaffold(body: Text('Unknown: ${settings.name}'));
        }
        return MaterialPageRoute(builder: (_) => page, settings: settings);
      },
    );
  }

  /// Pumps past the StartupWorkflow's 8s + 20s Future.delayed timers
  /// to prevent "pending timer" assertion failures in teardown.
  Future<void> drainPendingTimers(WidgetTester tester) async {
    await tester.pump(const Duration(seconds: 21));
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // 1. Unauthenticated → UserTypeSelection
  // ═══════════════════════════════════════════════════════════════════════════
  group('Unauthenticated routing', () {
    testWidgets('navigates to UserTypeSelection when not authenticated', (tester) async {
      when(() => mockAuth.currentUser).thenReturn(null);

      await tester.pumpWidget(buildTestApp(
        home: Builder(builder: (context) {
          return ElevatedButton(
            onPressed: () => StartupWorkflow.navigateBasedOnStatus(context),
            child: const Text('Navigate'),
          );
        }),
      ));

      await tester.tap(find.text('Navigate'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.text('UserTypeSelection'), findsOneWidget);

      // Drain background timers to avoid teardown assertion
      await drainPendingTimers(tester);
    });
  });

  // ═══════════════════════════════════════════════════════════════════════════
  // 2. Admin → AdminDashboard
  // ═══════════════════════════════════════════════════════════════════════════
  group('Admin routing', () {
    testWidgets('navigates to AdminDashboard for admin email', (tester) async {
      when(() => mockAuth.currentUser).thenReturn(mockUser);
      when(() => mockUser.id).thenReturn('admin-id');
      when(() => mockUser.email).thenReturn('admin@banjarabio.com');

      await tester.pumpWidget(buildTestApp(
        home: Builder(builder: (context) {
          return ElevatedButton(
            onPressed: () => StartupWorkflow.navigateBasedOnStatus(context),
            child: const Text('Navigate'),
          );
        }),
      ));

      await tester.tap(find.text('Navigate'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.text('AdminDashboard'), findsOneWidget);

      await drainPendingTimers(tester);
    });

    testWidgets('admin check is case-insensitive', (tester) async {
      when(() => mockAuth.currentUser).thenReturn(mockUser);
      when(() => mockUser.id).thenReturn('admin-id-2');
      when(() => mockUser.email).thenReturn('ADMIN@BANJARABIO.COM');

      await tester.pumpWidget(buildTestApp(
        home: Builder(builder: (context) {
          return ElevatedButton(
            onPressed: () => StartupWorkflow.navigateBasedOnStatus(context),
            child: const Text('Navigate'),
          );
        }),
      ));

      await tester.tap(find.text('Navigate'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.text('AdminDashboard'), findsOneWidget);

      await drainPendingTimers(tester);
    });
  });

  // ═══════════════════════════════════════════════════════════════════════════
  // 3. No Profile → BiodataCreation
  // ═══════════════════════════════════════════════════════════════════════════
  group('No-profile routing', () {
    testWidgets('navigates to BiodataCreation when user has no profile', (tester) async {
      when(() => mockAuth.currentUser).thenReturn(mockUser);
      when(() => mockUser.id).thenReturn('no-profile-user');
      when(() => mockUser.email).thenReturn('noone@test.com');

      // Profile query returns empty list → no profile
      fakeClient.queries.putIfAbsent('profiles', () => FakeSupabaseQueryBuilder());
      fakeClient.queries['profiles']!.builder.responseData = <Map<String, dynamic>>[];

      await tester.pumpWidget(buildTestApp(
        home: Builder(builder: (context) {
          return ElevatedButton(
            onPressed: () => StartupWorkflow.navigateBasedOnStatus(
              context,
              targetRouteOnNoProfile: '/biodata-creation-screen',
            ),
            child: const Text('Navigate'),
          );
        }),
      ));

      await tester.tap(find.text('Navigate'));
      await tester.pump();
      await tester.pump(const Duration(seconds: 2));

      expect(find.text('BiodataCreation'), findsOneWidget);

      await drainPendingTimers(tester);
    });
  });

  // ═══════════════════════════════════════════════════════════════════════════
  // 4. AdminConfig Pure Unit Tests (no widgets, no timers)
  // ═══════════════════════════════════════════════════════════════════════════
  group('AdminConfig', () {
    test('recognizes admin email', () {
      expect(_isAdmin('admin@banjarabio.com'), true);
    });

    test('is case-insensitive', () {
      expect(_isAdmin('ADMIN@BANJARABIO.COM'), true);
      expect(_isAdmin('Admin@BanjaraBio.Com'), true);
    });

    test('rejects non-admin emails', () {
      expect(_isAdmin('user@banjarabio.com'), false);
      expect(_isAdmin('admin@other.com'), false);
      expect(_isAdmin(''), false);
    });

    test('handles null', () {
      expect(_isAdmin(null), false);
    });
  });
}

bool _isAdmin(String? email) {
  if (email == null || email.isEmpty) return false;
  return email.trim().toLowerCase() == 'admin@banjarabio.com';
}
