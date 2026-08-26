import 'package:flutter_test/flutter_test.dart';
import 'package:banjarabio/core/repositories/volunteer_repository.dart';
import '../../helpers/supabase_fakes.dart';

void main() {
  late FakeSupabaseClient fakeSupabase;
  late VolunteerRepository volunteerRepository;

  setUp(() {
    fakeSupabase = FakeSupabaseClient();
    volunteerRepository = VolunteerRepository();
    volunteerRepository.testClient = fakeSupabase;
  });

  tearDown(() {
    volunteerRepository.testClient = null;
  });

  group('VolunteerRepository Tests', () {
    test('searchProfiles calls fn_volunteer_actions search_profiles action', () async {
      fakeSupabase.rpcResponse = [
        {
          'id': 'p1',
          'user_id': 'u1',
          'full_name': 'Ramesh',
          'surname': 'Pawar',
          'gender': 'Male',
          'age': 28,
        }
      ];

      final response = await volunteerRepository.searchProfiles('Ramesh');
      expect(response.isSuccess, isTrue);
      expect(response.data.first.fullName, equals('Ramesh'));
      expect(fakeSupabase.rpcFunction, equals('fn_volunteer_actions'));
      expect(fakeSupabase.rpcParams?['action'], equals('search_profiles'));
    });

    test('getProfileDetail calls fn_volunteer_actions get_profile_detail', () async {
      fakeSupabase.rpcResponse = {
        'id': 'p1',
        'user_id': 'u1',
        'full_name': 'Ramesh',
        'surname': 'Pawar',
        'gender': 'Male',
        'age': 28,
      };

      final response = await volunteerRepository.getProfileDetail('p1');
      expect(response.isSuccess, isTrue);
      expect(response.data.fullName, equals('Ramesh'));
    });

    test('registerProfile calls register_user action', () async {
      fakeSupabase.rpcResponse = {'profile_id': 'p_new', 'success': true};

      final response = await volunteerRepository.registerProfile({
        'full_name': 'Suresh',
        'surname': 'Chavan',
      });

      expect(response.isSuccess, isTrue);
      expect(fakeSupabase.rpcParams?['action'], equals('register_user'));
    });

    test('correctProfile sanitizes sensitive fields and calls update_user_profile', () async {
      fakeSupabase.rpcResponse = {'success': true};

      final response = await volunteerRepository.correctProfile(
        'p1',
        {
          'full_name': 'Ramesh Corrected',
          'is_admin': true, // should be removed
          'is_premium': true, // should be removed
          'trust_score': 100, // should be removed
        },
      );

      expect(response.isSuccess, isTrue);
      expect(fakeSupabase.rpcParams?['action'], equals('update_user_profile'));
      final payload = fakeSupabase.rpcParams?['p_payload'] as Map<String, dynamic>;
      expect(payload['full_name'], equals('Ramesh Corrected'));
      expect(payload.containsKey('is_admin'), isFalse);
      expect(payload.containsKey('is_premium'), isFalse);
      expect(payload.containsKey('trust_score'), isFalse);
    });

    test('getMyStats and logCall invoke appropriate RPC calls', () async {
      fakeSupabase.rpcResponse = {'registered_today': 3, 'corrected_today': 5};
      final statsRes = await volunteerRepository.getMyStats();
      expect(statsRes.isSuccess, isTrue);

      fakeSupabase.rpcResponse = {'success': true};
      final logRes = await volunteerRepository.logCall(
        profileId: 'p1',
        outcome: 'connected',
        notes: 'Followed up for biodata verification',
      );
      expect(logRes.isSuccess, isTrue);
    });

    test('getMyCallLogs and getMyRegistrations return mapped lists', () async {
      fakeSupabase.rpcResponse = [
        {'id': 'c1', 'profile_id': 'p1', 'outcome': 'interested'}
      ];
      final logs = await volunteerRepository.getMyCallLogs();
      expect(logs.isSuccess, isTrue);
      expect(logs.data.length, equals(1));

      fakeSupabase.rpcResponse = [
        {'id': 'r1', 'profile_id': 'p2', 'created_at': DateTime.now().toIso8601String()}
      ];
      final regs = await volunteerRepository.getMyRegistrations();
      expect(regs.isSuccess, isTrue);
      expect(regs.data.length, equals(1));
    });
  });
}
