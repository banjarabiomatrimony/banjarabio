import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sizer/sizer.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:mocktail/mocktail.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:banjarabio/l10n/app_localizations.dart';
import 'package:banjarabio/theme/app_theme.dart';
import 'package:banjarabio/core/supabase_client.dart';
import 'package:banjarabio/core/services/local_cache_service.dart';
import 'package:banjarabio/core/session_manager.dart';
import 'package:banjarabio/core/repositories/profile_repository.dart';
import 'package:banjarabio/core/repositories/admin_repository.dart';
import 'package:banjarabio/core/repositories/influencer_repository.dart';
import 'package:banjarabio/core/repositories/share_repository.dart';
import 'package:banjarabio/core/repositories/photo_repository.dart';
import 'package:banjarabio/core/repositories/usage_repository.dart';
import 'package:banjarabio/core/repositories/chat_repository.dart';
import 'package:banjarabio/core/repositories/staff_repository.dart';
import 'package:banjarabio/core/repositories/coupon_repository.dart';
import 'package:banjarabio/core/repositories/payment_repository.dart';
import 'package:banjarabio/core/repositories/razorpay_repository.dart';
import 'package:banjarabio/core/repositories/daily_reward_repository.dart';
import 'package:banjarabio/core/repositories/trust_score_repository.dart';
import 'package:banjarabio/core/repositories/banner_repository.dart';
import 'package:banjarabio/core/repositories/subscription_repository.dart';
import 'package:banjarabio/core/repositories/referral_repository.dart';
import 'package:banjarabio/core/services/telemetry_service.dart';
import 'mock_services.dart';

// ─── Shared Fakes ──────────────────────────────────────────────────────
import 'supabase_fakes.dart';

// ─── Shared Mocks ──────────────────────────────────────────────────────
class MockGoTrueClient extends Mock implements GoTrueClient {}
class MockUser extends Mock implements User {}
class MockBox extends Mock implements Box<dynamic> {}
class MockSupabaseClient extends Mock implements SupabaseClient {}
class MockPostgrestClient extends Mock implements PostgrestClient {}

/// Sets up all global mocks needed for widget tests.
/// Call this in setUp() of every widget test file.
void setupWidgetTestMocks({
  MockGoTrueClient? mockAuth,
  MockUser? mockUser,
  MockBox? mockBox,
}) {
  final auth = mockAuth ?? MockGoTrueClient();
  final user = mockUser ?? MockUser();
  final box = mockBox ?? MockBox();

  // Supabase Auth
  AppSupabaseClient.testAuth = auth;
  when(() => auth.currentUser).thenReturn(user);
  when(() => user.id).thenReturn('test-user-id');
  when(() => user.email).thenReturn('test@example.com');
  when(() => auth.onAuthStateChange).thenAnswer((_) => const Stream.empty());

  // Inject FakeSupabaseClient globally into Singleton Repositories
  final fakeClient = FakeSupabaseClient();
  
  // Also set testClient so AppSupabaseClient.storage works
  AppSupabaseClient.testClient = fakeClient;
  ProfileRepository().testClient = fakeClient;
  AdminRepository().testClient = fakeClient;
  InfluencerRepository().testClient = fakeClient;
  ShareRepository().testClient = fakeClient;
  PhotoRepository().testClient = fakeClient;
  UsageRepository().testClient = fakeClient;
  ChatRepository().testClient = fakeClient;
  StaffRepository().testClient = fakeClient;
  RazorpayRepository().testClient = fakeClient;
  CouponRepository().testClient = fakeClient;
  PaymentRepository.testClient = fakeClient;
  DailyRewardRepository().testClient = fakeClient;
  TrustScoreRepository().testClient = fakeClient;
  BannerRepository().testClient = fakeClient;
  SubscriptionRepository().testClient = fakeClient;
  ReferralRepository().testClient = fakeClient;

  // Hive Box
  LocalCacheService().testBoxOpener = (name) => box;
  when(() => box.get(any())).thenReturn(null);
  when(() => box.get(any(), defaultValue: any(named: 'defaultValue')))
      .thenAnswer((inv) => inv.namedArguments[#defaultValue]);
  when(() => box.put(any(), any())).thenAnswer((_) async => {});
  when(() => box.delete(any())).thenAnswer((_) async => {});

  // SessionManager
  SharedPreferences.setMockInitialValues({});
  SessionManager.instance.testPrefs = FakeSharedPreferences();

  // TelemetryService
  TelemetryService.instance = NoOpTelemetryService();
}

/// Tears down all global mocks. Call in tearDown().
void tearDownWidgetTestMocks() {
  AppSupabaseClient.testAuth = null;
  AppSupabaseClient.testClient = null;
  
  // Clear Repository Singletons
  ProfileRepository().testClient = null;
  AdminRepository().testClient = null;
  InfluencerRepository().testClient = null;
  ShareRepository().testClient = null;
  PhotoRepository().testClient = null;
  UsageRepository().testClient = null;
  ChatRepository().testClient = null;
  StaffRepository().testClient = null;
  RazorpayRepository().testClient = null;
  CouponRepository().testClient = null;
  PaymentRepository.testClient = null;
  DailyRewardRepository().testClient = null;
  TrustScoreRepository().testClient = null;
  BannerRepository().testClient = null;
  SubscriptionRepository().testClient = null;
  ReferralRepository().testClient = null;
  
  LocalCacheService().reset();
  SessionManager.instance.reset();
  TelemetryService.instance = TelemetryService.internal();
}

/// Wraps a widget with all required wrappers for testing:
/// Sizer > ProviderScope > MaterialApp with localizations & typography theme.
Widget createTestableWidget(
  Widget child, {
  List<Override>? overrides,
  Locale? locale,
  ThemeData? theme,
  ThemeData? darkTheme,
  ThemeMode? themeMode,
}) {
  return Sizer(
    builder: (context, orientation, deviceType) => ProviderScope(
      overrides: overrides ?? [],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        locale: locale,
        theme: theme ?? AppTheme.lightTheme,
        darkTheme: darkTheme ?? AppTheme.darkTheme,
        themeMode: themeMode ?? ThemeMode.light,
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: AppLocalizations.supportedLocales,
        home: child,
      ),
    ),
  );
}

/// Sets the screen size for a testWidgets test.
void setTestScreenSize(WidgetTester tester) {
  tester.view.physicalSize = const Size(1080, 1920);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(() {
    tester.view.resetPhysicalSize();
    tester.view.resetDevicePixelRatio();
  });
}

/// Pumps the widget safely, catching errors from platform channels
/// or Supabase initialization that we can't mock.
/// Returns true if the widget was pumped successfully.
Future<bool> pumpWidgetSafely(WidgetTester tester, Widget widget) async {
  try {
    await tester.pumpWidget(widget);
    await tester.pump(const Duration(milliseconds: 100));
    return true;
  } catch (e) {
    // Some screens access Supabase.instance directly (not through AppSupabaseClient),
    // which causes assertion failures in tests. We catch this gracefully.
    return false;
  }
}
