import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:banjarabio/presentation/subscription_screen/subscription_screen.dart';
import 'package:banjarabio/presentation/settings_screen/settings_screen.dart';
import 'package:banjarabio/presentation/home_screen/home_screen.dart';
import 'package:banjarabio/presentation/profile_detail_screen/profile_detail_screen.dart';
import 'package:banjarabio/presentation/biodata_editor_screen/biodata_editor_screen.dart';
import 'package:banjarabio/presentation/authentication_screen/authentication_screen.dart';
import 'package:banjarabio/core/repositories/subscription_repository.dart';

import 'helpers/widget_test_helpers.dart';
import 'helpers/supabase_fakes.dart';

void main() {
  final locales = [
    const Locale('en'),
    const Locale('hi'),
    const Locale('kn'),
    const Locale('mr'),
    const Locale('te'),
  ];

  group('Visual Audit - Overflow Detection', () {
    setUp(() {
      setupWidgetTestMocks();
      
      // Inject dummy data for Subscription Screen
      final fakeClient = (SubscriptionRepository().testClient as FakeSupabaseClient);
      fakeClient.rpcResponse = []; // Ensure empty list for banners
      
      // Mock Subscription
      fakeClient.setTableData('subscriptions', [{
        'id': 'sub-1',
        'user_id': 'test-user-id',
        'plan_type': 'gold',
        'status': 'active',
        'starts_at': DateTime.now().toIso8601String(),
        'ends_at': DateTime.now().add(const Duration(days: 30)).toIso8601String(),
        'created_at': DateTime.now().toIso8601String(),
      }]);

      // Mock Verification Status for Trust Score
      fakeClient.setTableData('verification_requests', []);
      fakeClient.setTableData('user_references', []);
      
      // Mock Profile
      fakeClient.setTableData('profiles', [{
        'id': 'test-user-id',
        'full_name': 'Test User',
        'phone_number': '1234567890',
        'email': 'test@example.com',
      }]);
    });

    tearDown(() {
      tearDownWidgetTestMocks();
    });

    for (final locale in locales) {
      testWidgets('SubscriptionScreen renders without overflow in ${locale.languageCode}', (tester) async {
        setTestScreenSize(tester);

        final List<FlutterErrorDetails> errors = [];
        final originalOnError = FlutterError.onError;
        FlutterError.onError = (details) {
          errors.add(details);
          originalOnError?.call(details);
        };

        try {
          await tester.pumpWidget(createTestableWidget(const SubscriptionScreen(), locale: locale));
          // Use pump() instead of pumpAndSettle() because of infinite shimmber animations
          await tester.pump();
          await tester.pump(const Duration(milliseconds: 500));
        } finally {
          FlutterError.onError = originalOnError;
        }

        // Verify no overflows
        final overflows = errors.where((d) => 
          d.exception is FlutterError && 
          d.exception.toString().contains('A RenderFlex overflowed')
        );
        expect(overflows, isEmpty, reason: 'Overflows detected in SubscriptionScreen (${locale.languageCode})');
        
        expect(find.byType(SubscriptionScreen), findsOneWidget);
      });

      testWidgets('SettingsScreen renders without overflow in ${locale.languageCode}', (tester) async {
        setTestScreenSize(tester);

        final List<FlutterErrorDetails> errors = [];
        final originalOnError = FlutterError.onError;
        FlutterError.onError = (details) {
          errors.add(details);
          originalOnError?.call(details);
        };

        try {
          await tester.pumpWidget(createTestableWidget(const SettingsScreen(), locale: locale));
          await tester.pump();
          await tester.pump(const Duration(milliseconds: 500));
        } finally {
          FlutterError.onError = originalOnError;
        }

        // Verify no overflows
        final overflows = errors.where((d) => 
          d.exception is FlutterError && 
          d.exception.toString().contains('A RenderFlex overflowed')
        );
        expect(overflows, isEmpty, reason: 'Overflows detected in SettingsScreen (${locale.languageCode})');

        expect(find.byType(SettingsScreen), findsOneWidget);
      });

      testWidgets('HomeScreen renders without overflow in ${locale.languageCode}', (tester) async {
        setTestScreenSize(tester);
        final List<FlutterErrorDetails> errors = [];
        final originalOnError = FlutterError.onError;
        FlutterError.onError = (details) { errors.add(details); originalOnError?.call(details); };
        try {
          await tester.pumpWidget(createTestableWidget(const HomeScreen(), locale: locale));
          await tester.pump();
          await tester.pump(const Duration(milliseconds: 500));
        } finally { FlutterError.onError = originalOnError; }
        final overflows = errors.where((d) => d.exception is FlutterError && d.exception.toString().contains('A RenderFlex overflowed'));
        expect(overflows, isEmpty, reason: 'Overflows detected in HomeScreen (${locale.languageCode})');
      });

      testWidgets('ProfileDetailScreen renders without overflow in ${locale.languageCode}', (tester) async {
        setTestScreenSize(tester);
        final List<FlutterErrorDetails> errors = [];
        final originalOnError = FlutterError.onError;
        FlutterError.onError = (details) { errors.add(details); originalOnError?.call(details); };
        try {
          await tester.pumpWidget(createTestableWidget(const ProfileDetailScreen(), locale: locale));
          await tester.pump();
          await tester.pump(const Duration(milliseconds: 500));
        } finally { FlutterError.onError = originalOnError; }
        final overflows = errors.where((d) => d.exception is FlutterError && d.exception.toString().contains('A RenderFlex overflowed'));
        expect(overflows, isEmpty, reason: 'Overflows detected in ProfileDetailScreen (${locale.languageCode})');
      });

      testWidgets('BiodataEditorScreen renders without overflow in ${locale.languageCode}', (tester) async {
        setTestScreenSize(tester);
        final List<FlutterErrorDetails> errors = [];
        final originalOnError = FlutterError.onError;
        FlutterError.onError = (details) { errors.add(details); originalOnError?.call(details); };
        try {
          await tester.pumpWidget(createTestableWidget(const BiodataEditorScreen(), locale: locale));
          await tester.pump();
          await tester.pump(const Duration(milliseconds: 500));
        } finally { FlutterError.onError = originalOnError; }
        final overflows = errors.where((d) => d.exception is FlutterError && d.exception.toString().contains('A RenderFlex overflowed'));
        expect(overflows, isEmpty, reason: 'Overflows detected in BiodataEditorScreen (${locale.languageCode})');
      });

      testWidgets('AuthenticationScreen renders without overflow in ${locale.languageCode}', (tester) async {
        setTestScreenSize(tester);
        final List<FlutterErrorDetails> errors = [];
        final originalOnError = FlutterError.onError;
        FlutterError.onError = (details) { errors.add(details); originalOnError?.call(details); };
        try {
          await tester.pumpWidget(createTestableWidget(const AuthenticationScreen(), locale: locale));
          await tester.pump();
          await tester.pump(const Duration(milliseconds: 500));
        } finally { FlutterError.onError = originalOnError; }
        final overflows = errors.where((d) => d.exception is FlutterError && d.exception.toString().contains('A RenderFlex overflowed'));
        expect(overflows, isEmpty, reason: 'Overflows detected in AuthenticationScreen (${locale.languageCode})');
      });
    }
  });
}
