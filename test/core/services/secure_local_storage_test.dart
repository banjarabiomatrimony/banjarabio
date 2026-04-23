import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:banjarabio/core/services/secure_local_storage.dart';

class MockFlutterSecureStorage extends Mock implements FlutterSecureStorage {}

void main() {
  late MockFlutterSecureStorage mockStorage;
  late SecureLocalStorage secureLocalStorage;

  setUp(() {
    mockStorage = MockFlutterSecureStorage();
    secureLocalStorage = SecureLocalStorage(storage: mockStorage);
  });

  group('SecureLocalStorage', () {
    test('initialize does nothing and completes', () async {
      await expectLater(secureLocalStorage.initialize(), completes);
    });

    test('hasAccessToken returns true when session exists', () async {
      when(() => mockStorage.read(key: any(named: 'key')))
          .thenAnswer((_) async => '{"access_token": "abc"}');

      final result = await secureLocalStorage.hasAccessToken();

      expect(result, true);
      verify(() => mockStorage.read(key: supabasePersistSessionKey)).called(1);
    });

    test('hasAccessToken returns false when no session', () async {
      when(() => mockStorage.read(key: any(named: 'key')))
          .thenAnswer((_) async => null);

      final result = await secureLocalStorage.hasAccessToken();

      expect(result, false);
    });

    test('accessToken returns value from storage', () async {
      const sessionString = '{"access_token": "abc"}';
      when(() => mockStorage.read(key: any(named: 'key')))
          .thenAnswer((_) async => sessionString);

      final result = await secureLocalStorage.accessToken();

      expect(result, sessionString);
    });

    test('removePersistedSession deletes key from storage', () async {
      when(() => mockStorage.delete(key: any(named: 'key')))
          .thenAnswer((_) async {});

      await secureLocalStorage.removePersistedSession();

      verify(() => mockStorage.delete(key: supabasePersistSessionKey)).called(1);
    });

    test('persistSession writes to storage', () async {
      const sessionString = '{"access_token": "abc"}';
      when(() => mockStorage.write(key: any(named: 'key'), value: any(named: 'value')))
          .thenAnswer((_) async {});

      await secureLocalStorage.persistSession(sessionString);

      verify(() => mockStorage.write(
            key: supabasePersistSessionKey,
            value: sessionString,
          )).called(1);
    });
  });
}
