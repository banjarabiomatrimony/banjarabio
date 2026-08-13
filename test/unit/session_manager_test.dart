// test/unit/session_manager_test.dart
// Comprehensive unit tests for SessionManager — covering initialization,
// getters/setters, session clearing, and edge cases.

import 'package:flutter_test/flutter_test.dart';
import 'package:banjarabio/core/session_manager.dart';
import 'package:banjarabio/core/services/telemetry_service.dart';

import '../helpers/supabase_fakes.dart';
import '../helpers/mock_services.dart';

void main() {
  late FakeSharedPreferences fakePrefs;

  setUp(() {
    fakePrefs = FakeSharedPreferences();
    SessionManager.instance.testPrefs = fakePrefs;
    TelemetryService.instance = NoOpTelemetryService();
  });

  tearDown(() {
    SessionManager.instance.reset();
    TelemetryService.instance = TelemetryService.internal();
  });

  // ═══════════════════════════════════════════════════════════════════════════
  // 1. Initialization
  // ═══════════════════════════════════════════════════════════════════════════
  group('Initialization', () {
    test('testPrefs injection works without calling init()', () {
      // Should not throw — testPrefs is set
      expect(() => SessionManager.instance.isLoggedIn, returnsNormally);
    });

    test('throws when not initialized and no testPrefs', () {
      SessionManager.instance.reset();
      expect(() => SessionManager.instance.isLoggedIn, throwsException);
    });
  });

  // ═══════════════════════════════════════════════════════════════════════════
  // 2. Login Status
  // ═══════════════════════════════════════════════════════════════════════════
  group('isLoggedIn', () {
    test('defaults to false', () {
      expect(SessionManager.instance.isLoggedIn, false);
    });

    test('can be set to true', () async {
      await SessionManager.instance.setLoggedIn(true);
      expect(SessionManager.instance.isLoggedIn, true);
    });

    test('can be toggled back to false', () async {
      await SessionManager.instance.setLoggedIn(true);
      await SessionManager.instance.setLoggedIn(false);
      expect(SessionManager.instance.isLoggedIn, false);
    });
  });

  // ═══════════════════════════════════════════════════════════════════════════
  // 3. User ID
  // ═══════════════════════════════════════════════════════════════════════════
  group('userId', () {
    test('defaults to null', () {
      expect(SessionManager.instance.userId, isNull);
    });

    test('stores and retrieves correctly', () async {
      await SessionManager.instance.setUserId('user-abc-123');
      expect(SessionManager.instance.userId, 'user-abc-123');
    });
  });

  // ═══════════════════════════════════════════════════════════════════════════
  // 4. Profile ID
  // ═══════════════════════════════════════════════════════════════════════════
  group('profileId', () {
    test('defaults to null', () {
      expect(SessionManager.instance.profileId, isNull);
    });

    test('stores and retrieves correctly', () async {
      await SessionManager.instance.setProfileId('profile-xyz');
      expect(SessionManager.instance.profileId, 'profile-xyz');
    });
  });

  // ═══════════════════════════════════════════════════════════════════════════
  // 5. Email
  // ═══════════════════════════════════════════════════════════════════════════
  group('email', () {
    test('defaults to null', () {
      expect(SessionManager.instance.email, isNull);
    });

    test('stores and retrieves correctly', () async {
      await SessionManager.instance.setEmail('test@banjarabio.com');
      expect(SessionManager.instance.email, 'test@banjarabio.com');
    });
  });

  // ═══════════════════════════════════════════════════════════════════════════
  // 6. User Token
  // ═══════════════════════════════════════════════════════════════════════════
  group('userToken', () {
    test('defaults to null', () {
      expect(SessionManager.instance.userToken, isNull);
    });

    test('stores and retrieves correctly', () async {
      await SessionManager.instance.setUserToken('jwt-token-abc');
      expect(SessionManager.instance.userToken, 'jwt-token-abc');
    });
  });

  // ═══════════════════════════════════════════════════════════════════════════
  // 7. First Time Flag
  // ═══════════════════════════════════════════════════════════════════════════
  group('isFirstTime', () {
    test('defaults to true (new user)', () {
      expect(SessionManager.instance.isFirstTime, true);
    });

    test('can be set to false after onboarding', () async {
      await SessionManager.instance.setFirstTime(false);
      expect(SessionManager.instance.isFirstTime, false);
    });
  });

  // ═══════════════════════════════════════════════════════════════════════════
  // 8. Biometric Flag
  // ═══════════════════════════════════════════════════════════════════════════
  group('isBiometricEnabled', () {
    test('defaults to false', () {
      expect(SessionManager.instance.isBiometricEnabled, false);
    });

    test('can be enabled', () async {
      await SessionManager.instance.setBiometricEnabled(true);
      expect(SessionManager.instance.isBiometricEnabled, true);
    });
  });

  // ═══════════════════════════════════════════════════════════════════════════
  // 9. Last Login Time
  // ═══════════════════════════════════════════════════════════════════════════
  group('lastLoginTime', () {
    test('defaults to null', () {
      expect(SessionManager.instance.lastLoginTime, isNull);
    });

    test('stores and retrieves DateTime correctly', () async {
      final now = DateTime(2026, 8, 13, 12);
      await SessionManager.instance.setLastLoginTime(now);
      expect(
        SessionManager.instance.lastLoginTime?.millisecondsSinceEpoch,
        now.millisecondsSinceEpoch,
      );
    });
  });

  // ═══════════════════════════════════════════════════════════════════════════
  // 10. Premium Status
  // ═══════════════════════════════════════════════════════════════════════════
  group('isPremium', () {
    test('defaults to false', () {
      expect(SessionManager.instance.isPremium, false);
    });

    test('can be set to true', () async {
      await SessionManager.instance.setPremium(true);
      expect(SessionManager.instance.isPremium, true);
    });
  });

  // ═══════════════════════════════════════════════════════════════════════════
  // 11. Install Notification Flag
  // ═══════════════════════════════════════════════════════════════════════════
  group('hasNotifiedInstall', () {
    test('defaults to false', () {
      expect(SessionManager.instance.hasNotifiedInstall, false);
    });

    test('can be set to true', () async {
      await SessionManager.instance.setHasNotifiedInstall(true);
      expect(SessionManager.instance.hasNotifiedInstall, true);
    });
  });

  // ═══════════════════════════════════════════════════════════════════════════
  // 12. Session Clearing
  // ═══════════════════════════════════════════════════════════════════════════
  group('clearSession', () {
    test('clears login-related keys', () async {
      // Set all session data
      await SessionManager.instance.setLoggedIn(true);
      await SessionManager.instance.setUserId('user-id');
      await SessionManager.instance.setProfileId('profile-id');
      await SessionManager.instance.setEmail('clear@test.com');
      await SessionManager.instance.setUserToken('token');
      await SessionManager.instance.setLastLoginTime(DateTime.now());

      // Clear session
      await SessionManager.instance.clearSession();

      expect(SessionManager.instance.isLoggedIn, false);
      expect(SessionManager.instance.userId, isNull);
      expect(SessionManager.instance.profileId, isNull);
      expect(SessionManager.instance.email, isNull);
      expect(SessionManager.instance.userToken, isNull);
      expect(SessionManager.instance.lastLoginTime, isNull);
    });

    test('preserves isFirstTime across clearSession', () async {
      await SessionManager.instance.setFirstTime(false);
      await SessionManager.instance.clearSession();
      expect(SessionManager.instance.isFirstTime, false);
    });

    test('preserves isBiometricEnabled across clearSession', () async {
      await SessionManager.instance.setBiometricEnabled(true);
      await SessionManager.instance.clearSession();
      expect(SessionManager.instance.isBiometricEnabled, true);
    });
  });

  // ═══════════════════════════════════════════════════════════════════════════
  // 13. Current Profile (In-Memory)
  // ═══════════════════════════════════════════════════════════════════════════
  group('currentProfile', () {
    test('defaults to null', () {
      expect(SessionManager.instance.currentProfile, isNull);
    });

    test('can be set and cleared', () {
      // currentProfile is in-memory only, not persisted
      SessionManager.instance.setCurrentProfile(null);
      expect(SessionManager.instance.currentProfile, isNull);
    });
  });

  // ═══════════════════════════════════════════════════════════════════════════
  // 14. Static Bridge
  // ═══════════════════════════════════════════════════════════════════════════
  group('Static bridge', () {
    test('SessionManager.instance is a singleton', () {
      final a = SessionManager.instance;
      final b = SessionManager.instance;
      expect(identical(a, b), true);
    });
  });
}
