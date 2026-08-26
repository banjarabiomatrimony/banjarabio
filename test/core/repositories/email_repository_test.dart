import 'package:flutter_test/flutter_test.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:banjarabio/core/repositories/email_repository.dart';
import '../../helpers/supabase_fakes.dart';

void main() {
  late FakeSupabaseClient fakeSupabase;
  late EmailRepository emailRepository;

  const testUser = User(
    id: 'user_123',
    appMetadata: {},
    userMetadata: {},
    aud: '',
    createdAt: '',
  );

  setUp(() {
    fakeSupabase = FakeSupabaseClient();
    EmailRepository.testClient = fakeSupabase;
    emailRepository = EmailRepository();
  });

  tearDown(() {
    EmailRepository.testClient = null;
  });

  group('EmailRepository Tests', () {
    test('getPreferences returns empty map when user is unauthenticated', () async {
      (fakeSupabase.auth as dynamic).mockUser = null;
      final prefs = await emailRepository.getPreferences();
      expect(prefs, isEmpty);
    });

    test('getPreferences returns preferences map for authenticated user', () async {
      (fakeSupabase.auth as dynamic).mockUser = testUser;
      fakeSupabase.setTableData('email_preferences', [
        {
          'user_id': 'user_123',
          'promotions': true,
          'daily_matches': true,
          'newsletters': false,
        }
      ]);

      final prefs = await emailRepository.getPreferences();
      expect(prefs['user_id'], equals('user_123'));
      expect(prefs['promotions'], isTrue);
      expect(prefs['newsletters'], isFalse);
    });

    test('updatePreference executes gracefully when unauthenticated', () async {
      (fakeSupabase.auth as dynamic).mockUser = null;
      await expectLater(
        emailRepository.updatePreference('promotions', false),
        completes,
      );
    });

    test('updatePreference updates table data for authenticated user', () async {
      (fakeSupabase.auth as dynamic).mockUser = testUser;
      fakeSupabase.setTableData('email_preferences', [
        {
          'user_id': 'user_123',
          'promotions': true,
        }
      ]);

      await expectLater(
        emailRepository.updatePreference('promotions', false),
        completes,
      );
    });
  });
}
