import 'package:flutter_test/flutter_test.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:banjarabio/core/repositories/referral_repository.dart';
import '../../helpers/supabase_fakes.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late FakeSupabaseClient fakeSupabase;
  late ReferralRepository repository;

  setUp(() {
    fakeSupabase = FakeSupabaseClient();
    repository = ReferralRepository()..testClient = fakeSupabase;

    // Setup authenticated user
    (fakeSupabase.auth as dynamic).mockUser = const User(
      id: 'test-user-id',
      appMetadata: {},
      userMetadata: {},
      aud: '',
      createdAt: '',
    );
  });

  // ═══════════════════════════════════════════════
  // getMyReferralCode
  // ═══════════════════════════════════════════════
  group('getMyReferralCode', () {
    test('returns existing referral code from profiles table', () async {
      fakeSupabase.setTableData('profiles', [
        {'user_id': 'test-user-id', 'referral_code': 'BANJARA-7X29'}
      ]);

      final result = await repository.getMyReferralCode();

      expect(result.isSuccess, true);
      expect(result.data, 'BANJARA-7X29');
    });

    test('generates new code via RPC when none exists', () async {
      fakeSupabase.setTableData('profiles', [
        {'user_id': 'test-user-id', 'referral_code': null}
      ]);
      fakeSupabase.rpcResponse = {'ok': true, 'code': 'BANJARA-NEW1'};

      final result = await repository.getMyReferralCode();

      expect(result.isSuccess, true);
      expect(result.data, 'BANJARA-NEW1');
      expect(fakeSupabase.rpcFunction, 'fn_process_referral');
      expect(fakeSupabase.rpcParams?['action'], 'generate_code');
    });

    test('returns failure when RPC returns invalid format', () async {
      fakeSupabase.setTableData('profiles', [
        {'user_id': 'test-user-id', 'referral_code': null}
      ]);
      fakeSupabase.rpcResponse = {'ok': true}; // Missing 'code' key

      final result = await repository.getMyReferralCode();

      expect(result.isSuccess, false);
      expect(result.errorMessage, contains('Invalid code format'));
    });

    test('returns failure when not authenticated', () async {
      (fakeSupabase.auth as dynamic).mockUser = null;

      final result = await repository.getMyReferralCode();

      expect(result.isSuccess, false);
      expect(result.errorMessage, contains('not authenticated'));
    });

    test('returns failure on exception', () async {
      fakeSupabase.setTableData('profiles', [
        {'referral_code': null}
      ]);
      fakeSupabase.rpcError = Exception('Network error');

      final result = await repository.getMyReferralCode();

      expect(result.isSuccess, false);
      expect(result.errorMessage, contains('Network error'));
    });

    test('returns failure when RPC generate_code fails', () async {
      fakeSupabase.setTableData('profiles', [
        {'referral_code': null}
      ]);
      fakeSupabase.rpcResponse = {'ok': false, 'error': 'Server busy'};

      final result = await repository.getMyReferralCode();

      expect(result.isSuccess, false);
      expect(result.errorMessage, contains('Server busy'));
    });
  });

  // ═══════════════════════════════════════════════
  // redeemReferralCode
  // ═══════════════════════════════════════════════
  group('redeemReferralCode', () {
    test('calls RPC with uppercased code and returns success', () async {
      fakeSupabase.rpcResponse = {'ok': true};

      final result = await repository.redeemReferralCode('banjara-abc1');

      expect(result.isSuccess, true);
      expect(fakeSupabase.rpcFunction, 'fn_process_referral');
      expect(fakeSupabase.rpcParams?['action'], 'redeem_code');
      expect(
        (fakeSupabase.rpcParams?['payload'] as Map)['code'],
        'BANJARA-ABC1',
      );
    });

    test('returns failure when code is invalid', () async {
      fakeSupabase.rpcResponse = {'ok': false, 'error': 'Code not found'};

      final result = await repository.redeemReferralCode('INVALID');

      expect(result.isSuccess, false);
      expect(result.errorMessage, contains('Code not found'));
    });

    test('returns failure on RPC exception', () async {
      fakeSupabase.rpcError = Exception('Network error');

      final result = await repository.redeemReferralCode('BANJARA-ABC1');

      expect(result.isSuccess, false);
    });
  });

  // ═══════════════════════════════════════════════
  // completeReferral
  // ═══════════════════════════════════════════════
  group('completeReferral', () {
    test('calls RPC with correct params and returns success', () async {
      fakeSupabase.rpcResponse = {'ok': true};

      final result = await repository.completeReferral('ref-1', 'new-user-id');

      expect(result.isSuccess, true);
      expect(fakeSupabase.rpcFunction, 'fn_process_referral');
      expect(fakeSupabase.rpcParams?['action'], 'complete_referral');
      final payload = fakeSupabase.rpcParams?['payload'] as Map;
      expect(payload['referral_id'], 'ref-1');
      expect(payload['referred_user_id'], 'new-user-id');
    });

    test('returns failure on RPC error', () async {
      fakeSupabase.rpcResponse = {'ok': false, 'error': 'Already completed'};

      final result = await repository.completeReferral('ref-1', 'new-user');

      expect(result.isSuccess, false);
      expect(result.errorMessage, contains('Already completed'));
    });

    test('returns failure on exception', () async {
      fakeSupabase.rpcError = Exception('Timeout');

      final result = await repository.completeReferral('ref-1', 'new-user');

      expect(result.isSuccess, false);
    });
  });

  // ═══════════════════════════════════════════════
  // getReferralStats
  // ═══════════════════════════════════════════════
  group('getReferralStats', () {
    test('returns stats when data exists', () async {
      fakeSupabase.setTableData('referral_stats', [
        {
          'user_id': 'test-user-id',
          'referral_count': 5,
          'rewards_earned': 250,
          'last_reward_at': '2026-01-15T10:00:00Z',
          'updated_at': '2026-03-01T12:00:00Z',
        }
      ]);

      final result = await repository.getReferralStats();

      expect(result.isSuccess, true);
      expect(result.data.referralCount, 5);
      expect(result.data.rewardsEarned, 250);
    });

    test('returns empty stats for new users (no record)', () async {
      fakeSupabase.setTableData('referral_stats', []);

      final result = await repository.getReferralStats();

      expect(result.isSuccess, true);
      expect(result.data.referralCount, 0);
      expect(result.data.rewardsEarned, 0);
    });

    test('returns failure when not authenticated', () async {
      (fakeSupabase.auth as dynamic).mockUser = null;

      final result = await repository.getReferralStats();

      expect(result.isSuccess, false);
      expect(result.errorMessage, contains('not authenticated'));
    });

    test('returns failure on exception', () async {
      final table = fakeSupabase.from('referral_stats');
      (table as dynamic).builder.error = Exception('DB down');

      final result = await repository.getReferralStats();

      expect(result.isSuccess, false);
    });
  });

  // ═══════════════════════════════════════════════
  // getMyReferrals
  // ═══════════════════════════════════════════════
  group('getMyReferrals', () {
    test('returns list of referral models', () async {
      fakeSupabase.setTableData('referrals', [
        {
          'id': 'r1',
          'referrer_id': 'test-user-id',
          'referred_user_id': 'u2',
          'status': 'completed',
          'created_at': '2026-02-10T10:00:00Z',
        },
        {
          'id': 'r2',
          'referrer_id': 'test-user-id',
          'referred_user_id': 'u3',
          'status': 'pending',
          'created_at': '2026-03-01T10:00:00Z',
        },
      ]);

      final result = await repository.getMyReferrals();

      expect(result.isSuccess, true);
      expect(result.data.length, 2);
      expect(result.data.first.id, 'r1');
      expect(result.data.first.status.name, 'completed');
      expect(result.data.last.status.name, 'pending');
    });

    test('returns empty list when no referrals', () async {
      fakeSupabase.setTableData('referrals', []);

      final result = await repository.getMyReferrals();

      expect(result.isSuccess, true);
      expect(result.data, isEmpty);
    });

    test('returns failure when not authenticated', () async {
      (fakeSupabase.auth as dynamic).mockUser = null;

      final result = await repository.getMyReferrals();

      expect(result.isSuccess, false);
      expect(result.errorMessage, contains('not authenticated'));
    });

    test('returns failure on exception', () async {
      final table = fakeSupabase.from('referrals');
      (table as dynamic).builder.error = Exception('Query failed');

      final result = await repository.getMyReferrals();

      expect(result.isSuccess, false);
    });
  });
}
