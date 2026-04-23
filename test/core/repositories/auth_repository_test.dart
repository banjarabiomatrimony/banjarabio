import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:banjarabio/core/repositories/auth_repository.dart';
import 'package:banjarabio/core/session_manager.dart';
import 'package:banjarabio/notification/features/admin_notification_service.dart';
import '../../helpers/supabase_fakes.dart';

class MockSessionManager extends Mock implements SessionManager {}

void main() {
  late FakeSupabaseClient fakeSupabase;
  late MockSessionManager mockSessionManager;
  late AuthRepository authRepository;

  setUp(() {
    fakeSupabase = FakeSupabaseClient();
    mockSessionManager = MockSessionManager();
    authRepository = AuthRepository(
      testClient: fakeSupabase,
      testSessionManager: mockSessionManager,
    );
    
    // Inject fake client into AdminNotificationService to prevent initialization errors
    AdminNotificationService().testClient = fakeSupabase;

    // Default mock setup for SessionManager
    when(() => mockSessionManager.setLoggedIn(any())).thenAnswer((_) async {});
    when(() => mockSessionManager.setEmail(any())).thenAnswer((_) async {});
    when(() => mockSessionManager.setUserId(any())).thenAnswer((_) async {});
    when(() => mockSessionManager.setLastLoginTime(any())).thenAnswer((_) async {});
    when(() => mockSessionManager.setUserToken(any())).thenAnswer((_) async {});
    when(() => mockSessionManager.clearSession()).thenAnswer((_) async {});
  });

  group('AuthRepository - signInWithEmail', () {
    test('returns success and saves session when user exists', () async {
      final mockUser = const User(
        id: 'user-123',
        appMetadata: {},
        userMetadata: {},
        aud: '',
        createdAt: '',
      );
      (fakeSupabase.auth as dynamic).mockUser = mockUser;
      (fakeSupabase.auth as dynamic).mockSession = Session(
        accessToken: 'token-123',
        tokenType: 'bearer',
        user: mockUser,
      );

      final result = await authRepository.signInWithEmail('test@test.com', 'password');

      expect(result.isSuccess, true);
      expect(result.data, true);
      verify(() => mockSessionManager.setLoggedIn(true)).called(1);
      verify(() => mockSessionManager.setUserId('user-123')).called(1);
    });

    test('returns failure on error', () async {
      (fakeSupabase.auth as dynamic).error = const AuthException('Invalid credentials');

      final result = await authRepository.signInWithEmail('test@test.com', 'password');

      expect(result.isSuccess, false);
      expect(result.errorMessage, contains('Invalid credentials'));
      verifyNever(() => mockSessionManager.setLoggedIn(any()));
    });

    test('returns false when user is null after sign in', () async {
      (fakeSupabase.auth as dynamic).mockUser = null;

      final result = await authRepository.signInWithEmail('test@test.com', 'password');

      expect(result.isSuccess, true);
      expect(result.data, false);
    });
  });

  group('AuthRepository - signUpWithEmail', () {
    test('returns success when user created', () async {
      (fakeSupabase.auth as dynamic).mockUser = const User(
        id: 'new-user',
        appMetadata: {},
        userMetadata: {},
        aud: '',
        createdAt: '',
      );

      final result = await authRepository.signUpWithEmail('new@test.com', 'password');

      expect(result.isSuccess, true);
      expect(result.data, true);
    });

    test('returns false when user is null', () async {
      (fakeSupabase.auth as dynamic).mockUser = null;

      final result = await authRepository.signUpWithEmail('new@test.com', 'password');

      expect(result.isSuccess, true);
      expect(result.data, false);
    });

    test('returns failure on error', () async {
      (fakeSupabase.auth as dynamic).error = const AuthException('Email taken');

      final result = await authRepository.signUpWithEmail('taken@test.com', 'password');

      expect(result.isSuccess, false);
      expect(result.errorMessage, contains('Email taken'));
    });
  });

  group('AuthRepository - signInWithPhone', () {
    test('returns success on OTP sent', () async {
      final result = await authRepository.signInWithPhone('1234567890');

      expect(result.isSuccess, true);
    });

    test('returns failure on error', () async {
      (fakeSupabase.auth as dynamic).error = const AuthException('Rate limited');

      final result = await authRepository.signInWithPhone('1234567890');

      expect(result.isSuccess, false);
      expect(result.errorMessage, contains('Rate limited'));
    });
  });

  group('AuthRepository - verifyPhoneOtp', () {
    test('saves session on success', () async {
      final mockUser = const User(
        id: 'phone-user',
        appMetadata: {},
        userMetadata: {},
        aud: '',
        createdAt: '',
      );
      (fakeSupabase.auth as dynamic).mockUser = mockUser;

      final result = await authRepository.verifyPhoneOtp('1234567890', '123456');

      expect(result.isSuccess, true);
      expect(result.data, true);
      verify(() => mockSessionManager.setUserId('phone-user')).called(1);
    });

    test('returns false when user is null', () async {
      (fakeSupabase.auth as dynamic).mockUser = null;

      final result = await authRepository.verifyPhoneOtp('1234567890', '123456');

      expect(result.isSuccess, true);
      expect(result.data, false);
    });

    test('returns failure on verification error', () async {
      (fakeSupabase.auth as dynamic).error = const AuthException('Invalid OTP');

      final result = await authRepository.verifyPhoneOtp('1234567890', 'wrong');

      expect(result.isSuccess, false);
      expect(result.errorMessage, contains('Invalid OTP'));
    });
  });

  group('AuthRepository - verifyEmailOtp', () {
    test('saves session on success', () async {
      final mockUser = const User(
        id: 'email-user',
        appMetadata: {},
        userMetadata: {},
        aud: '',
        createdAt: '',
      );
      (fakeSupabase.auth as dynamic).mockUser = mockUser;

      final result = await authRepository.verifyEmailOtp('test@test.com', '123456');

      expect(result.isSuccess, true);
      expect(result.data, true);
      verify(() => mockSessionManager.setEmail('test@test.com')).called(1);
    });

    test('returns false when user is null', () async {
      (fakeSupabase.auth as dynamic).mockUser = null;

      final result = await authRepository.verifyEmailOtp('test@test.com', '123456');

      expect(result.isSuccess, true);
      expect(result.data, false);
    });

    test('returns failure on error', () async {
      (fakeSupabase.auth as dynamic).error = const AuthException('Expired OTP');

      final result = await authRepository.verifyEmailOtp('test@test.com', 'expired');

      expect(result.isSuccess, false);
      expect(result.errorMessage, contains('Expired OTP'));
    });
  });

  group('AuthRepository - sendEmailOtp', () {
    test('returns success on OTP sent', () async {
      final result = await authRepository.sendEmailOtp('test@test.com');

      expect(result.isSuccess, true);
    });

    test('returns failure on error', () async {
      (fakeSupabase.auth as dynamic).error = const AuthException('Rate limited');

      final result = await authRepository.sendEmailOtp('test@test.com');

      expect(result.isSuccess, false);
      expect(result.errorMessage, contains('Rate limited'));
    });
  });

  group('AuthRepository - handleAuthCallback', () {
    test('returns true and saves session when session exists', () async {
      final mockUser = const User(
        id: 'oauth-user',
        appMetadata: {},
        userMetadata: {},
        aud: '',
        email: 'oauth@test.com',
        createdAt: '',
      );
      (fakeSupabase.auth as dynamic).mockUser = mockUser;
      (fakeSupabase.auth as dynamic).mockSession = Session(
        accessToken: 'oauth-token',
        tokenType: 'bearer',
        user: mockUser,
      );

      final result = await authRepository.handleAuthCallback();

      expect(result.isSuccess, true);
      expect(result.data, true);
      verify(() => mockSessionManager.setEmail('oauth@test.com')).called(1);
      verify(() => mockSessionManager.setUserId('oauth-user')).called(1);
    });

    test('returns false when no session', () async {
      (fakeSupabase.auth as dynamic).mockUser = null;
      (fakeSupabase.auth as dynamic).mockSession = null;

      final result = await authRepository.handleAuthCallback();

      expect(result.isSuccess, true);
      expect(result.data, false);
    });
  });

  group('AuthRepository - signOut', () {
    test('clears session', () async {
      final result = await authRepository.signOut();

      expect(result.isSuccess, true);
      verify(() => mockSessionManager.clearSession()).called(1);
    });

    test('returns failure on error', () async {
      (fakeSupabase.auth as dynamic).error = const AuthException('Sign out error');

      final result = await authRepository.signOut();

      expect(result.isSuccess, false);
      expect(result.errorMessage, contains('Sign out error'));
    });
  });

  group('AuthRepository - refreshSession', () {
    test('returns success on refresh', () async {
      final result = await authRepository.refreshSession();

      expect(result.isSuccess, true);
    });

    test('clears session and returns failure on error', () async {
      (fakeSupabase.auth as dynamic).error = const AuthException('Token expired');

      final result = await authRepository.refreshSession();

      expect(result.isSuccess, false);
      verify(() => mockSessionManager.clearSession()).called(1);
    });
  });
}
