import 'package:flutter_test/flutter_test.dart';
import 'package:banjarabio/core/repositories/influencer_repository.dart';
import '../../helpers/supabase_fakes.dart';

void main() {
  late FakeSupabaseClient fakeSupabase;
  late InfluencerRepository repository;

  setUp(() {
    fakeSupabase = FakeSupabaseClient();
    repository = InfluencerRepository();
    repository.testClient = fakeSupabase;
  });

  group('InfluencerRepository - registerCreatorReferral', () {
    test('returns success on valid response', () async {
      fakeSupabase.rpcResponse = {'ok': true};

      final result = await repository.registerCreatorReferral('PROMO123');

      expect(result.isSuccess, true);
      expect(fakeSupabase.rpcFunction, 'fn_register_creator_referral');
      expect(fakeSupabase.rpcParams?['p_promo_code'], 'PROMO123');
    });

    test('returns failure when response indicates error', () async {
      fakeSupabase.rpcResponse = {'ok': false, 'error': 'Invalid promo code'};

      final result = await repository.registerCreatorReferral('INVALID');

      expect(result.isSuccess, false);
      expect(result.errorMessage, contains('Invalid promo code'));
    });

    test('returns failure on RPC exception', () async {
      fakeSupabase.rpcError = 'Network error';

      final result = await repository.registerCreatorReferral('CODE');

      expect(result.isSuccess, false);
      expect(result.errorMessage, contains('Network error'));
    });
  });

  group('InfluencerRepository - getAllCreators', () {
    test('returns list of creators on success', () async {
      final now = DateTime.now();
      fakeSupabase.rpcResponse = [
        {
          'id': 'c1',
          'name': 'Creator1',
          'promo_code': 'CODE1',
          'commission_pct': 10.0,
          'created_at': now.toIso8601String(),
          'updated_at': now.toIso8601String(),
        },
        {
          'id': 'c2',
          'name': 'Creator2',
          'promo_code': 'CODE2',
          'commission_pct': 15.0,
          'created_at': now.toIso8601String(),
          'updated_at': now.toIso8601String(),
        },
      ];

      final result = await repository.getAllCreators();

      expect(result.isSuccess, true);
      expect(result.data.length, 2);
      expect(result.data[0].name, 'Creator1');
      expect(result.data[1].promoCode, 'CODE2');
      expect(fakeSupabase.rpcFunction, 'fn_admin_actions');
      expect(fakeSupabase.rpcParams?['action'], 'get_creators');
    });

    test('returns empty list when no creators', () async {
      fakeSupabase.rpcResponse = [];

      final result = await repository.getAllCreators();

      expect(result.isSuccess, true);
      expect(result.data, isEmpty);
    });

    test('returns failure on RPC exception', () async {
      fakeSupabase.rpcError = 'DB Error';

      final result = await repository.getAllCreators();

      expect(result.isSuccess, false);
      expect(result.errorMessage, contains('DB Error'));
    });
  });

  group('InfluencerRepository - addCreator', () {
    test('sends correct RPC params', () async {
      fakeSupabase.rpcResponse = {'status': 'success'};

      final result = await repository.addCreator(
        name: 'NewCreator',
        promoCode: 'NEW123',
        commissionPct: 0.15,
        instagramHandle: '@newcreator',
      );

      expect(result.isSuccess, true);
      expect(fakeSupabase.rpcFunction, 'fn_admin_actions');
      expect(fakeSupabase.rpcParams?['action'], 'add_creator');

      final payload = fakeSupabase.rpcParams?['p_payload'] as Map<String, dynamic>;
      expect(payload['name'], 'NewCreator');
      expect(payload['promo_code'], 'NEW123');
      expect(payload['commission_pct'], 0.15);
      expect(payload['instagram_handle'], '@newcreator');
    });

    test('returns failure on RPC exception', () async {
      fakeSupabase.rpcError = 'Add failed';

      final result = await repository.addCreator(
        name: 'Test',
        promoCode: 'TEST',
      );

      expect(result.isSuccess, false);
    });
  });

  group('InfluencerRepository - updateCreator', () {
    test('sends correct RPC params with optional fields', () async {
      fakeSupabase.rpcResponse = {'status': 'success'};

      final result = await repository.updateCreator(
        id: 'c1',
        name: 'Updated',
        isActive: false,
      );

      expect(result.isSuccess, true);
      expect(fakeSupabase.rpcParams?['action'], 'update_creator');

      final payload = fakeSupabase.rpcParams?['p_payload'] as Map<String, dynamic>;
      expect(payload['id'], 'c1');
      expect(payload['name'], 'Updated');
      expect(payload['is_active'], false);
      // Optional fields not passed should not be present
      expect(payload.containsKey('commission_pct'), false);
      expect(payload.containsKey('instagram_handle'), false);
    });

    test('returns failure on RPC exception', () async {
      fakeSupabase.rpcError = 'Update failed';

      final result = await repository.updateCreator(id: 'c1');

      expect(result.isSuccess, false);
    });
  });
}
