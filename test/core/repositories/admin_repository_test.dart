import 'package:flutter_test/flutter_test.dart';
import 'package:banjarabio/core/repositories/admin_repository.dart';
import '../../helpers/supabase_fakes.dart';

void main() {
  late FakeSupabaseClient fakeSupabase;
  late AdminRepository adminRepository;

  setUp(() {
    fakeSupabase = FakeSupabaseClient();
    adminRepository = AdminRepository();
    adminRepository.testClient = fakeSupabase;
  });

  group('AdminRepository - Stats & Lists', () {
    test('getAdminStats returns success when RPC returns data', () async {
      final mockData = {'total_users': 100};
      fakeSupabase.rpcResponse = mockData;

      final result = await adminRepository.getAdminStats();

      expect(result.isSuccess, true);
      expect(result.data['total_users'], 100);
      expect(fakeSupabase.rpcFunction, 'fn_admin_actions');
      expect(fakeSupabase.rpcParams?['action'], 'get_admin_stats');
    });

    test('getAdminStats returns failure when RPC throws', () async {
      fakeSupabase.rpcError = 'RPC Error';

      final result = await adminRepository.getAdminStats();

      expect(result.isSuccess, false);
      expect(result.errorMessage, contains('RPC Error'));
    });

    test('getPaymentsList calls correct RPC action', () async {
      fakeSupabase.rpcResponse = [
        {'id': 'pay1', 'amount': 100}
      ];

      final result = await adminRepository.getPaymentsList(limit: 10, offset: 5);

      expect(result.isSuccess, true);
      expect(result.data.first['id'], 'pay1');
      expect(fakeSupabase.rpcParams?['action'], 'get_payments_list');
      expect(fakeSupabase.rpcParams?['p_payload']['limit'], 10);
      expect(fakeSupabase.rpcParams?['p_payload']['offset'], 5);
    });
  });

  group('AdminRepository - User Management', () {
    test('getAllProfiles parses list successfully', () async {
      final now = DateTime.now();
      final mockProfiles = [
        {
          'id': '1',
          'user_id': 'u1',
          'full_name': 'Admin',
          'surname': 'Test',
          'age': 30,
          'gender': 'Male',
          'is_premium': false,
          'created_at': now.toIso8601String(),
          'updated_at': now.toIso8601String(),
          'trust_score': 0,
          'is_verified': false,
          'is_pdf_unlocked': false,
          'phone_verified': false,
          'email_verified': false,
          'is_admin': true,
        }
      ];

      fakeSupabase.rpcResponse = mockProfiles;

      final result = await adminRepository.getAllProfiles();

      expect(result.isSuccess, true);
      expect(result.data.length, 1);
      expect(result.data.first.fullName, 'Admin');
      expect(fakeSupabase.rpcParams?['action'], 'get_all_profiles');
    });

    test('togglePremiumStatus calls correct RPC', () async {
      fakeSupabase.rpcResponse = {'status': 'success'};

      final result = await adminRepository.togglePremiumStatus('u1', true);

      expect(result.isSuccess, true);
      expect(fakeSupabase.rpcParams?['action'], 'toggle_premium');
      expect(fakeSupabase.rpcParams?['p_payload']['target_user_id'], 'u1');
      expect(fakeSupabase.rpcParams?['p_payload']['is_premium'], true);
    });

    test('verifyProfileManually calls correct RPC', () async {
      fakeSupabase.rpcResponse = {'status': 'success'};

      final result = await adminRepository.verifyProfileManually('u1', email: true);

      expect(result.isSuccess, true);
      expect(fakeSupabase.rpcParams?['action'], 'manual_verification');
      expect(fakeSupabase.rpcParams?['p_payload']['verify_email'], true);
      expect(fakeSupabase.rpcParams?['p_payload']['verify_phone'], false);
    });

    test('adminUpdateProfile filters forbidden fields', () async {
      fakeSupabase.rpcResponse = {'status': 'success'};

      final updates = {
        'full_name': 'New Name',
        'is_premium': true,
        'is_admin': true,
        'trust_score': 100,
        'created_at': '2021-01-01',
      };

      await adminRepository.adminUpdateProfile('u1', updates);

      final payload = fakeSupabase.rpcParams?['p_payload'] as Map<String, dynamic>? ?? {};
      expect(payload['full_name'], 'New Name');
      expect(payload['target_user_id'], 'u1');

      expect(payload.containsKey('is_premium'), false);
      expect(payload.containsKey('is_admin'), false);
      expect(payload.containsKey('created_at'), false);
      expect(payload.containsKey('trust_score'), false);
    });
  });

  group('AdminRepository - Verifications & References', () {
    test('getPendingVerifications calls correct RPC action', () async {
      fakeSupabase.rpcResponse = [
        {'id': 'v1'}
      ];

      final result = await adminRepository.getPendingVerifications();

      expect(result.isSuccess, true);
      expect(result.data.first['id'], 'v1');
      expect(fakeSupabase.rpcParams?['action'], 'get_pending_verifications');
    });

    test('updateVerificationStatus sends full payload', () async {
      fakeSupabase.rpcResponse = {'status': 'success'};

      await adminRepository.updateVerificationStatus(
        requestId: 'v1',
        status: 'rejected',
        adminNotes: 'Bad quality',
        rejectionReason: 'ID unclear',
      );

      final payload = fakeSupabase.rpcParams?['p_payload'] as Map<String, dynamic>? ?? {};
      expect(payload['request_id'], 'v1');
      expect(payload['status'], 'rejected');
      expect(payload['notes'], 'Bad quality');
      expect(payload['rejection_reason'], 'ID unclear');
    });

    test('getPendingReferences calls correct RPC', () async {
      fakeSupabase.rpcResponse = [
        {'id': 'ref1'}
      ];

      final result = await adminRepository.getPendingReferences();

      expect(result.isSuccess, true);
      expect(fakeSupabase.rpcParams?['action'], 'get_pending_references');
    });

    test('updateReferenceStatus calls correct RPC', () async {
      fakeSupabase.rpcResponse = {'status': 'success'};

      final result = await adminRepository.updateReferenceStatus(
        referenceId: 'ref1',
        status: 'verified',
      );

      expect(result.isSuccess, true);
      expect(fakeSupabase.rpcParams?['action'], 'update_reference_status');
      expect(fakeSupabase.rpcParams?['p_payload']['reference_id'], 'ref1');
      expect(fakeSupabase.rpcParams?['p_payload']['status'], 'verified');
    });
  });

  group('AdminRepository - Storage', () {
    test('getSignedUrl returns success on valid URL', () async {
      final result = await adminRepository.getSignedUrl('proofs', 'id_card.png');

      expect(result.isSuccess, true);
      expect(result.data, contains('proofs'));
      expect(result.data, contains('id_card.png'));
      expect(result.data, contains('token=fake'));
    });

    test('getSignedUrl handles errors and falls back to public URL', () async {
      // Mock error on createSignedUrl
      ((fakeSupabase.storage.from('proofs')) as dynamic).error = Exception('Signed URL failed');

      final result = await adminRepository.getSignedUrl('proofs', 'id_card.png');

      expect(result.isSuccess, true);
      expect(result.data, contains('public'));
      expect(result.data, contains('id_card.png'));
    });
  });
}
