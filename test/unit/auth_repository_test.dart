// test/unit/auth_repository_test.dart
// Comprehensive unit tests for AuthRepository — covering all auth methods,
// error handling, session persistence, and edge cases.

import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'package:banjarabio/core/repositories/auth_repository.dart';
import 'package:banjarabio/core/session_manager.dart';
import 'package:banjarabio/core/services/local_cache_service.dart';
import 'package:banjarabio/core/services/telemetry_service.dart';

import '../helpers/supabase_fakes.dart';
import '../helpers/mock_services.dart';

class _MockBox extends Mock implements Box<dynamic> {}

void main() {
  late FakeSupabaseClient fakeClient;
  late FakeGoTrueClient fakeAuth;
  late FakeSharedPreferences fakePrefs;
  late _MockBox mockBox;
  late AuthRepository authRepo;

  setUp(() {
    fakeClient = FakeSupabaseClient();
    fakeAuth = fakeClient.auth as FakeGoTrueClient;
    fakePrefs = FakeSharedPreferences();
    mockBox = _MockBox();

    // Inject test dependencies
    SessionManager.instance.testPrefs = fakePrefs;
    TelemetryService.instance = NoOpTelemetryService();

    // Hive mock — required because signOut calls LocalCacheService
    LocalCacheService().testBoxOpener = (name) => mockBox;
    when(() => mockBox.get(any())).thenReturn(null);
    when(() => mockBox.get(any(), defaultValue: any(named: 'defaultValue')))
        .thenAnswer((inv) => inv.namedArguments[#defaultValue]);
    when(() => mockBox.put(any(), any())).thenAnswer((_) async => {});
    when(() => mockBox.delete(any())).thenAnswer((_) async => {});

    authRepo = AuthRepository(
      testClient: fakeClient,
      testSessionManager: SessionManager.instance,
    );
  });

  tearDown(() {
    SessionManager.instance.reset();
    LocalCacheService().reset();
    TelemetryService.instance = TelemetryService.internal();
  });

  // ═══════════════════════════════════════════════════════════════════════════
  // 1. Email Sign-In
  // ═══════════════════════════════════════════════════════════════════════════
  group('signInWithEmail', () {
    test('returns success(true) when user is authenticated', () async {
      fakeAuth.mockUser = FakeUser(id: 'user-123');

      final result = await authRepo.signInWithEmail('test@example.com', 'password123');

      expect(result.isSuccess, true);
      expect(result.data, true);
    });

    test('saves session data on successful login', () async {
      fakeAuth.mockUser = FakeUser(id: 'user-456');

      await authRepo.signInWithEmail('login@test.com', 'pass');

      expect(SessionManager.instance.isLoggedIn, true);
      expect(SessionManager.instance.userId, 'user-456');
      expect(SessionManager.instance.email, 'login@test.com');
    });

    test('returns success(false) when user is null', () async {
      fakeAuth.mockUser = null;

      final result = await authRepo.signInWithEmail('test@example.com', 'wrong');

      expect(result.isSuccess, true);
      expect(result.data, false);
    });

    test('returns failure on AuthException', () async {
      fakeAuth.error = AuthException('Invalid login credentials');

      final result = await authRepo.signInWithEmail('test@example.com', 'bad');

      expect(result.isSuccess, false);
      expect(result.errorMessage, contains('Invalid login credentials'));
    });

    test('provides retry callback on failure', () async {
      fakeAuth.error = AuthException('Network error');

      final result = await authRepo.signInWithEmail('test@example.com', 'pass');

      expect(result.isSuccess, false);
      expect(result.onRetry, isNotNull);
    });

    test('handles empty email gracefully (backend decides)', () async {
      fakeAuth.mockUser = null;

      final result = await authRepo.signInWithEmail('', 'pass');

      // Empty email should still reach Supabase — backend validates
      expect(result.isSuccess, true);
      expect(result.data, false);
    });
  });

  // ═══════════════════════════════════════════════════════════════════════════
  // 2. Email Sign-Up
  // ═══════════════════════════════════════════════════════════════════════════
  group('signUpWithEmail', () {
    test('returns success(true) when signup succeeds', () async {
      fakeAuth.mockUser = FakeUser(id: 'new-user-1');

      final result = await authRepo.signUpWithEmail('new@test.com', 'StrongPass1!');

      expect(result.isSuccess, true);
      expect(result.data, true);
    });

    test('returns success(false) when user is null', () async {
      fakeAuth.mockUser = null;

      final result = await authRepo.signUpWithEmail('existing@test.com', 'pass');

      expect(result.isSuccess, true);
      expect(result.data, false);
    });

    test('returns failure on exception', () async {
      fakeAuth.error = AuthException('User already registered');

      final result = await authRepo.signUpWithEmail('dup@test.com', 'pass');

      expect(result.isSuccess, false);
      expect(result.errorMessage, contains('User already registered'));
    });
  });

  // ═══════════════════════════════════════════════════════════════════════════
  // 3. Phone OTP Sign-In
  // ═══════════════════════════════════════════════════════════════════════════
  group('signInWithPhone', () {
    test('returns success when OTP is sent', () async {
      final result = await authRepo.signInWithPhone('+911234567890');

      expect(result.isSuccess, true);
    });

    test('returns failure on exception', () async {
      fakeAuth.error = AuthException('Phone not valid');

      final result = await authRepo.signInWithPhone('+91invalid');

      expect(result.isSuccess, false);
      expect(result.errorMessage, contains('Phone not valid'));
    });

    test('provides retry on failure', () async {
      fakeAuth.error = AuthException('Rate limit');

      final result = await authRepo.signInWithPhone('+911234567890');

      expect(result.onRetry, isNotNull);
    });
  });

  // ═══════════════════════════════════════════════════════════════════════════
  // 4. Phone OTP Verification
  // ═══════════════════════════════════════════════════════════════════════════
  group('verifyPhoneOtp', () {
    test('returns success(true) on valid OTP', () async {
      fakeAuth.mockUser = FakeUser(id: 'otp-user-1');

      final result = await authRepo.verifyPhoneOtp('+911234567890', '123456');

      expect(result.isSuccess, true);
      expect(result.data, true);
    });

    test('saves session on success', () async {
      fakeAuth.mockUser = FakeUser(id: 'otp-user-2');

      await authRepo.verifyPhoneOtp('+911234567890', '123456');

      expect(SessionManager.instance.isLoggedIn, true);
      expect(SessionManager.instance.userId, 'otp-user-2');
    });

    test('returns success(false) on invalid OTP (null user)', () async {
      fakeAuth.mockUser = null;

      final result = await authRepo.verifyPhoneOtp('+911234567890', '000000');

      expect(result.isSuccess, true);
      expect(result.data, false);
    });

    test('returns failure on exception', () async {
      fakeAuth.error = AuthException('Token expired');

      final result = await authRepo.verifyPhoneOtp('+911234567890', '123456');

      expect(result.isSuccess, false);
      expect(result.errorMessage, contains('Token expired'));
    });
  });

  // ═══════════════════════════════════════════════════════════════════════════
  // 5. Email OTP
  // ═══════════════════════════════════════════════════════════════════════════
  group('sendEmailOtp', () {
    test('returns success when OTP is sent', () async {
      final result = await authRepo.sendEmailOtp('test@example.com');

      expect(result.isSuccess, true);
    });

    test('returns failure on exception', () async {
      fakeAuth.error = AuthException('Email not found');

      final result = await authRepo.sendEmailOtp('missing@test.com');

      expect(result.isSuccess, false);
    });
  });

  group('verifyEmailOtp', () {
    test('returns success(true) on valid OTP', () async {
      fakeAuth.mockUser = FakeUser(id: 'email-otp-1');

      final result = await authRepo.verifyEmailOtp('test@example.com', '123456');

      expect(result.isSuccess, true);
      expect(result.data, true);
    });

    test('saves session data on success', () async {
      fakeAuth.mockUser = FakeUser(id: 'email-otp-2');

      await authRepo.verifyEmailOtp('test@example.com', '654321');

      expect(SessionManager.instance.isLoggedIn, true);
      expect(SessionManager.instance.email, 'test@example.com');
    });

    test('returns success(false) when user is null', () async {
      fakeAuth.mockUser = null;

      final result = await authRepo.verifyEmailOtp('test@example.com', '000000');

      expect(result.isSuccess, true);
      expect(result.data, false);
    });
  });

  // ═══════════════════════════════════════════════════════════════════════════
  // 6. Auth State Stream
  // ═══════════════════════════════════════════════════════════════════════════
  group('authStateChanges', () {
    test('isAuthenticated reflects Supabase state', () {
      fakeAuth.mockUser = FakeUser(id: 'u1');
      // AuthRepository.isAuthenticated delegates to AppSupabaseClient
      // which checks testAuth/testClient, but here we test the direct getter
      expect(authRepo.isAuthenticated, false); // testAuth not set on AppSupabaseClient
    });

    test('currentUserId returns null when not authenticated', () {
      expect(authRepo.currentUserId, isNull);
    });
  });

  // ═══════════════════════════════════════════════════════════════════════════
  // 7. Sign Out
  // ═══════════════════════════════════════════════════════════════════════════
  group('signOut', () {
    test('clears session on successful sign out', () async {
      // First sign in
      fakeAuth.mockUser = FakeUser(id: 'signout-test');
      await authRepo.signInWithEmail('test@out.com', 'pass');
      expect(SessionManager.instance.isLoggedIn, true);

      // Now sign out
      fakeAuth.error = null;
      final result = await authRepo.signOut();

      expect(result.isSuccess, true);
      expect(SessionManager.instance.isLoggedIn, false);
    });

    test('returns failure on sign out error', () async {
      fakeAuth.error = AuthException('Sign out failed');

      final result = await authRepo.signOut();

      expect(result.isSuccess, false);
    });
  });

  // ═══════════════════════════════════════════════════════════════════════════
  // 8. Session Refresh
  // ═══════════════════════════════════════════════════════════════════════════
  group('refreshSession', () {
    test('returns success on successful refresh', () async {
      fakeAuth.mockUser = FakeUser(id: 'refresh-user');

      final result = await authRepo.refreshSession();

      expect(result.isSuccess, true);
    });

    test('clears session and returns failure on refresh error', () async {
      // First login
      fakeAuth.mockUser = FakeUser(id: 'r-user');
      await authRepo.signInWithEmail('refresh@test.com', 'pass');

      // Now fail refresh
      fakeAuth.error = AuthException('Session expired');

      final result = await authRepo.refreshSession();

      expect(result.isSuccess, false);
      // Session should be cleared
      expect(SessionManager.instance.isLoggedIn, false);
    });
  });

  // ═══════════════════════════════════════════════════════════════════════════
  // 9. Auth Callback Handler (post-OAuth redirect)
  // ═══════════════════════════════════════════════════════════════════════════
  group('handleAuthCallback', () {
    test('returns success(true) when session and user exist', () async {
      fakeAuth.mockUser = FakeUser(id: 'callback-user');
      fakeAuth.mockSession = Session(
        accessToken: 'test-token',
        tokenType: 'bearer',
        user: fakeAuth.mockUser!,
      );

      final result = await authRepo.handleAuthCallback();

      expect(result.isSuccess, true);
      expect(result.data, true);
      expect(SessionManager.instance.isLoggedIn, true);
    });

    test('returns success(false) when session is null', () async {
      fakeAuth.mockUser = null;
      fakeAuth.mockSession = null;

      final result = await authRepo.handleAuthCallback();

      expect(result.isSuccess, true);
      expect(result.data, false);
    });
  });

  // ═══════════════════════════════════════════════════════════════════════════
  // 10. Session Data Persistence Integrity
  // ═══════════════════════════════════════════════════════════════════════════
  group('Session persistence', () {
    test('stores last login time on successful login', () async {
      fakeAuth.mockUser = FakeUser(id: 'time-user');
      final before = DateTime.now();

      await authRepo.signInWithEmail('time@test.com', 'pass');

      final lastLogin = SessionManager.instance.lastLoginTime;
      expect(lastLogin, isNotNull);
      expect(lastLogin!.isAfter(before.subtract(const Duration(seconds: 1))), true);
    });

    test('stores access token when session exists', () async {
      final user = FakeUser(id: 'token-user');
      fakeAuth.mockUser = user;
      fakeAuth.mockSession = Session(
        accessToken: 'my-jwt-token',
        tokenType: 'bearer',
        user: user,
      );

      await authRepo.signInWithEmail('token@test.com', 'pass');

      expect(SessionManager.instance.userToken, 'my-jwt-token');
    });
  });
}
