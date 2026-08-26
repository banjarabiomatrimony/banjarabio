import 'package:flutter_test/flutter_test.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:banjarabio/core/repositories/vouch_repository.dart';
import '../../helpers/supabase_fakes.dart';

void main() {
  late FakeSupabaseClient fakeSupabase;
  late VouchRepository vouchRepository;

  const testUser = User(
    id: 'user_1',
    appMetadata: {},
    userMetadata: {},
    aud: '',
    createdAt: '',
  );

  setUp(() {
    fakeSupabase = FakeSupabaseClient();
    VouchRepository.testClient = fakeSupabase;
    vouchRepository = VouchRepository.internal();
  });

  tearDown(() {
    VouchRepository.testClient = null;
  });

  group('VouchRepository Tests', () {
    test('vouchForProfile returns failure when unauthenticated', () async {
      (fakeSupabase.auth as dynamic).mockUser = null;

      final result = await vouchRepository.vouchForProfile(
        vouchedId: 'profile_2',
        relation: 'Brother',
      );

      expect(result.isSuccess, isFalse);
      expect(result.errorMessage, equals('Not authenticated'));
    });

    test('vouchForProfile inserts vouch record for authenticated user', () async {
      (fakeSupabase.auth as dynamic).mockUser = testUser;
      fakeSupabase.setTableData('profiles', [
        {'id': 'profile_1', 'user_id': 'user_1'}
      ]);

      final result = await vouchRepository.vouchForProfile(
        vouchedId: 'profile_2',
        relation: 'Sister',
      );

      expect(result.isSuccess, isTrue);
    });

    test('hasVouched returns boolean vouch status', () async {
      (fakeSupabase.auth as dynamic).mockUser = testUser;
      fakeSupabase.setTableData('profiles', [
        {'id': 'profile_1', 'user_id': 'user_1'}
      ]);
      fakeSupabase.setTableData('vouches', [
        {'id': 'v_1', 'vouch_id': 'profile_1', 'vouched_id': 'profile_2'}
      ]);

      final hasVouched = await vouchRepository.hasVouched('profile_2');
      expect(hasVouched, isTrue);
    });

    test('getVouches returns list of enriched vouches', () async {
      fakeSupabase.setTableData('vouches', [
        {
          'relation': 'Friend',
          'created_at': DateTime.now().toIso8601String(),
          'vouched_id': 'profile_2',
          'profiles': {
            'full_name': 'Kavita',
            'surname': 'Jadhav',
            'is_verified': true,
          }
        }
      ]);

      final result = await vouchRepository.getVouches('profile_2');
      expect(result.isSuccess, isTrue);
      expect(result.data.first['relation'], equals('Friend'));
    });
  });
}
