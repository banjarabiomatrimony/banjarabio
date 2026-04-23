import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:banjarabio/core/session_manager.dart';

void main() {
  late SessionManager sm;

  setUp(() async {
    sm = SessionManager.instance;
    sm.reset();
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    sm.testPrefs = prefs;
  });

  tearDown(() => sm.reset());

  group('Singleton', () {
    test('instance returns same object', () {
      expect(SessionManager.instance, same(sm));
    });
  });

  group('Login status', () {
    test('defaults to false', () => expect(sm.isLoggedIn, false));
    test('persists true', () async {
      await sm.setLoggedIn(true);
      expect(sm.isLoggedIn, true);
    });
  });

  group('User ID', () {
    test('defaults to null', () => expect(sm.userId, isNull));
    test('persists value', () async {
      await sm.setUserId('u1');
      expect(sm.userId, 'u1');
    });
  });

  group('Profile ID', () {
    test('defaults to null', () => expect(sm.profileId, isNull));
    test('persists value', () async {
      await sm.setProfileId('p1');
      expect(sm.profileId, 'p1');
    });
  });

  group('Email', () {
    test('defaults to null', () => expect(sm.email, isNull));
    test('persists value', () async {
      await sm.setEmail('e@e.com');
      expect(sm.email, 'e@e.com');
    });
  });

  group('User Token', () {
    test('defaults to null', () => expect(sm.userToken, isNull));
    test('persists value', () async {
      await sm.setUserToken('jwt');
      expect(sm.userToken, 'jwt');
    });
  });

  group('First Time', () {
    test('defaults to true', () => expect(sm.isFirstTime, true));
    test('persists false', () async {
      await sm.setFirstTime(false);
      expect(sm.isFirstTime, false);
    });
  });

  group('Biometric', () {
    test('defaults to false', () => expect(sm.isBiometricEnabled, false));
    test('persists true', () async {
      await sm.setBiometricEnabled(true);
      expect(sm.isBiometricEnabled, true);
    });
  });

  group('Last Login Time', () {
    test('defaults to null', () => expect(sm.lastLoginTime, isNull));
    test('persists value', () async {
      final t = DateTime(2025, 6, 1, 12);
      await sm.setLastLoginTime(t);
      expect(sm.lastLoginTime, t);
    });
  });

  group('clearSession', () {
    test('clears session but preserves isFirstTime and biometric', () async {
      await sm.setLoggedIn(true);
      await sm.setUserId('u1');
      await sm.setProfileId('p1');
      await sm.setUserToken('jwt');
      await sm.setEmail('e@e.com');
      await sm.setFirstTime(false);
      await sm.setBiometricEnabled(true);

      await sm.clearSession();

      expect(sm.isLoggedIn, false);
      expect(sm.userId, isNull);
      expect(sm.profileId, isNull);
      expect(sm.userToken, isNull);
      expect(sm.email, isNull);
      expect(sm.isFirstTime, false); // preserved
      expect(sm.isBiometricEnabled, true); // preserved
    });
  });

  group('clearAll', () {
    test('clears everything', () async {
      await sm.setFirstTime(false);
      await sm.setBiometricEnabled(true);
      await sm.clearAll();
      expect(sm.isFirstTime, true);
      expect(sm.isBiometricEnabled, false);
    });
  });

  group('currentProfile', () {
    test('defaults to null', () => expect(sm.currentProfile, isNull));
    test('setCurrentProfile works', () {
      sm.setCurrentProfile(null);
      expect(sm.currentProfile, isNull);
    });
  });
}
