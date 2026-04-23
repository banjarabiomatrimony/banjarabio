import 'package:flutter_test/flutter_test.dart';
import 'package:banjarabio/core/repositories/staff_repository.dart';
import '../../helpers/supabase_fakes.dart';

void main() {
  group('StaffRepository Unit Tests', () {
    late StaffRepository repository;
    late FakeSupabaseClient fakeClient;

    setUp(() {
      fakeClient = FakeSupabaseClient();
      repository = StaffRepository();
      repository.testClient = fakeClient;
    });

    test('getMyLeads parses RPC response correctly', () async {
      fakeClient.rpcResponse = [
        {
          'id': 'lead-1',
          'user_id': 'user-1',
          'full_name': 'Rahul Rathod',
          'gender': 'Male',
          'age': 25,
          'profile_completion': 45,
          'surname': 'Rathod',
          'height': "5'8\"",
          'education': 'BE',
          'profession': 'Engineer',
        }
      ];

      final response = await repository.getMyLeads();

      expect(response.isSuccess, isTrue);
      expect(response.data.length, equals(1));
      expect(response.data.first.fullName, equals('Rahul Rathod'));
    });

    test('getMySummary returns staff metrics', () async {
      fakeClient.rpcResponse = {
        'total_assigned': 10,
        'not_called': 5,
        'called_today': 2,
      };

      final response = await repository.getMySummary();

      expect(response.isSuccess, isTrue);
      expect(response.data['total_assigned'], equals(10));
    });

    test('updateLeadProfile sends correct payload', () async {
      fakeClient.rpcResponse = {'success': true};

      final response = await repository.updateLeadProfile(
        'user-1',
        {'full_name': 'Updated Name'},
      );

      expect(response.isSuccess, isTrue);
    });

    test('logCall records staff interaction', () async {
      fakeClient.rpcResponse = {'success': true};

      final response = await repository.logCall(
        profileId: 'lead-1',
        actionType: 'call',
        outcome: 'busy',
        notes: 'User was busy',
      );

      expect(response.isSuccess, isTrue);
    });

    test('getWhatsAppTemplates parses response correctly', () async {
      fakeClient.rpcResponse = [
        {'id': 1, 'name': 'Intro', 'content': 'Hello!'}
      ];

      final response = await repository.getWhatsAppTemplates();

      expect(response.isSuccess, isTrue);
      expect(response.data.first['name'], equals('Intro'));
    });
  });
}
