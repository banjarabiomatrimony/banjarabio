import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:banjarabio/core/session_manager.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late SessionManager sessionManager;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    sessionManager = SessionManager.instance;
    sessionManager.reset();
    await sessionManager.init();
  });

  group('SessionManager - Basic Settings', () {
    test('isLoggedIn default should be false', () {
      expect(sessionManager.isLoggedIn, false);
    });

    test('setLoggedIn updates value', () async {
      await sessionManager.setLoggedIn(true);
      expect(sessionManager.isLoggedIn, true);
    });

    test('userId should be null initially', () {
      expect(sessionManager.userId, null);
    });

    test('setUserId updates value', () async {
      await sessionManager.setUserId('u123');
      expect(sessionManager.userId, 'u123');
    });

    test('email updates value', () async {
      await sessionManager.setEmail('test@example.com');
      expect(sessionManager.email, 'test@example.com');
    });

    test('isFirstTime default should be true', () {
      expect(sessionManager.isFirstTime, true);
    });

    test('setFirstTime updates value', () async {
      await sessionManager.setFirstTime(false);
      expect(sessionManager.isFirstTime, false);
    });
  });

  group('SessionManager - Date Handling', () {
    test('lastLoginTime updates correctly', () async {
      final now = DateTime.now();
      await sessionManager.setLastLoginTime(now);
      
      // Allow 1ms difference for precision safety if needed, 
      // but millisecondsSinceEpoch should be exact.
      expect(sessionManager.lastLoginTime?.millisecondsSinceEpoch, 
             now.millisecondsSinceEpoch);
    });
  });

  group('SessionManager - Session Lifecycle', () {
    test('clearSession removes only user data', () async {
      await sessionManager.setLoggedIn(true);
      await sessionManager.setUserId('u1');
      await sessionManager.setFirstTime(false);

      await sessionManager.clearSession();

      expect(sessionManager.isLoggedIn, false);
      expect(sessionManager.userId, null);
      // isFirstTime should be KEPT according to clearSession implementation
      expect(sessionManager.isFirstTime, false);
    });

    test('clearAll removes everything', () async {
      await sessionManager.setFirstTime(false);
      await sessionManager.clearAll();
      expect(sessionManager.isFirstTime, true);
    });
  });

  group('SessionManager - Draft Handling', () {
    test('saveBiodataDraft and getBiodataDraft work', () async {
      final data = {'name': 'John', 'age': 30};
      await sessionManager.saveBiodataDraft(data);
      
      final retrieved = await sessionManager.getBiodataDraft();
      expect(retrieved?['name'], 'John');
      expect(retrieved?['age'], 30);
    });

    test('saveBiodataDraft handles DateTime', () async {
      final now = DateTime.now();
      final data = {'birth_date': now};
      await sessionManager.saveBiodataDraft(data);
      
      final retrieved = await sessionManager.getBiodataDraft();
      // Date is converted to ISO8601 string in _encodeJsonSafe
      expect(retrieved?['birth_date'], now.toIso8601String());
    });

    test('clearBiodataDraft removes draft', () async {
      await sessionManager.saveBiodataDraft({'a': 1});
      await sessionManager.clearBiodataDraft();
      expect(await sessionManager.getBiodataDraft(), null);
    });
  });

  group('SessionManager - Initialization Guard', () {
    test('throws exception if accessed before init', () {
      sessionManager.reset();
      expect(() => sessionManager.isLoggedIn, throwsException);
    });
  });
}
