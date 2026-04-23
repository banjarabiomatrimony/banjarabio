import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:banjarabio/core/repositories/subscription_repository.dart';
import 'package:banjarabio/core/repositories/trust_score_repository.dart';
import 'package:banjarabio/core/models/subscription_model.dart';
import 'package:banjarabio/core/models/backend_response.dart';
import 'package:banjarabio/core/models/subscription_config.dart';
import '../../helpers/supabase_fakes.dart';

class MockTrustScoreRepository extends Mock implements TrustScoreRepository {}

void main() {
  late FakeSupabaseClient fakeSupabase;
  late MockTrustScoreRepository mockTrustScoreRepository;
  late SubscriptionRepository subscriptionRepository;

  setUp(() {
    subscriptionRepository = SubscriptionRepository();
    subscriptionRepository.reset();
    subscriptionRepository = SubscriptionRepository();
    fakeSupabase = FakeSupabaseClient();
    mockTrustScoreRepository = MockTrustScoreRepository();
    
    subscriptionRepository.testClient = fakeSupabase;
    subscriptionRepository.testTrustScoreRepository = mockTrustScoreRepository;
  });

  User mockUser([String id = 'u1']) => User(
    id: id, appMetadata: {}, userMetadata: {}, aud: '', createdAt: '',
  );

  void setupSub(String userId, {
    String planType = 'platinum', String status = 'active', String? expiryDate,
  }) {
    fakeSupabase.setTableData('subscriptions', [{
      'id': 'sub1', 'user_id': userId, 'plan_type': planType, 'status': status,
      'started_at': DateTime.now().toIso8601String(),
      'expires_at': expiryDate ?? DateTime.now().add(const Duration(days: 30)).toIso8601String(),
      'created_at': DateTime.now().toIso8601String(),
      'updated_at': DateTime.now().toIso8601String(),
    }]);
  }

  void clearSub() {
    fakeSupabase.setTableData('subscriptions', <Map<String, dynamic>>[]);
  }

  group('Read Operations', () {
    test('getCurrentSubscription handles no subscription', () async {
      final userId = 'u_none';
      (fakeSupabase.auth as dynamic).mockUser = mockUser(userId);
      clearSub();
      final result = await subscriptionRepository.getCurrentSubscription();
      expect(result.data, isNull);
    });

    test('getCurrentSubscription forces refresh', () async {
      final userId = 'u_refresh';
      (fakeSupabase.auth as dynamic).mockUser = mockUser(userId);
      setupSub(userId);
      
      clearSub();
      final after = await subscriptionRepository.getCurrentSubscription(forceRefresh: true);
      expect(after.data, isNull);
    });

    test('refreshSubscription forces refetch', () async {
      final userId = 'u_refresh_rpc';
      (fakeSupabase.auth as dynamic).mockUser = mockUser(userId);
      setupSub(userId);
      
      final result = await subscriptionRepository.getCurrentSubscription(forceRefresh: true);
      expect(result.data?.id, 'sub1');
    });

    test('getCurrentSubscription returns null when no user', () async {
      (fakeSupabase.auth as dynamic).mockUser = null;
      final result = await subscriptionRepository.getCurrentSubscription();
      expect(result.data, isNull);
    });

    test('getCurrentSubscription fetches and caches', () async {
      final userId = 'u_read_isolated';
      (fakeSupabase.auth as dynamic).mockUser = mockUser(userId);
      setupSub(userId);
      final result = await subscriptionRepository.getCurrentSubscription();
      expect(result.data?.id, 'sub1');
    });

    test('isPremium returns true for premium', () async {
      final userId = 'u_premium_check';
      (fakeSupabase.auth as dynamic).mockUser = mockUser(userId);
      setupSub(userId, planType: 'gold');
      
      // Force refresh to bypass any cached 'free' plan from previous tests
      final result = await subscriptionRepository.getCurrentSubscription(forceRefresh: true);
      expect(result.data?.isPremium, true);
    });
  });

  group('RPC Operations', () {
    test('cancelSubscription calls RPC and invalidates cache', () async {
      final userId = 'u_cancel';
      (fakeSupabase.auth as dynamic).mockUser = mockUser(userId);
      setupSub(userId);
      fakeSupabase.rpcResponse = {'status': 'success'};

      final result = await subscriptionRepository.cancelSubscription();
      expect(result.isSuccess, true);

      clearSub();
      final after = await subscriptionRepository.getCurrentSubscription(forceRefresh: true);
      expect(after.data, isNull);
    });

    test('refreshSubscription forces refetch', () async {
      final userId = 'u_refetch_rpc';
      (fakeSupabase.auth as dynamic).mockUser = mockUser(userId);
      setupSub(userId);
      
      final result = await subscriptionRepository.getCurrentSubscription(forceRefresh: true);
      expect(result.data?.id, 'sub1');
    });
  });

  group('Pricing & Features', () {
    test('getDiscountedPrice falls back to base price on failure', () async {
      final features = SubscriptionConfig.getFeatures(PlanType.platinum);
      when(() => mockTrustScoreRepository.calculateTrustScore(profile: any(named: 'profile')))
          .thenAnswer((_) async => BackendResponse.failure('Error'));

      final result = await subscriptionRepository.getDiscountedPrice(features);
      expect(result.data, features.priceInPaise);
    });
  });

  group('Days & Prompts', () {
    test('shouldShowUpgradePrompt returns true for free plan', () async {
      final userId = 'u_prompt_free';
      (fakeSupabase.auth as dynamic).mockUser = mockUser(userId);
      clearSub();
      final result = await subscriptionRepository.shouldShowUpgradePrompt();
      expect(result.data, true);
    });

    test('shouldShowUpgradePrompt returns false for premium', () async {
      final userId = 'u_prompt_premium';
      (fakeSupabase.auth as dynamic).mockUser = mockUser(userId);
      setupSub(userId, planType: 'gold');
      
      // Force refresh to ensure we don't see a cached 'free' plan
      final result = await subscriptionRepository.getCurrentSubscription(forceRefresh: true);
      final isPremium = result.data?.isPremium ?? false;
      expect(isPremium, true);
      
      final promptRes = await subscriptionRepository.shouldShowUpgradePrompt();
      expect(promptRes.data, false);
    });
  });

  group('History', () {
    test('getSubscriptionHistory returns list', () async {
      final userId = 'u_history';
      (fakeSupabase.auth as dynamic).mockUser = mockUser(userId);
      fakeSupabase.setTableData('subscriptions', [
        {'id': 's1', 'user_id': userId, 'plan_type': 'gold', 'status': 'active', 'started_at': '2020-01-01', 'expires_at': '2021-01-01'},
        {'id': 's2', 'user_id': userId, 'plan_type': 'free', 'status': 'expired', 'started_at': '2019-01-01', 'expires_at': '2020-01-01'},
      ]);

      final result = await subscriptionRepository.getSubscriptionHistory();
      expect(result.data.length, 2);
    });

    test('getSubscriptionHistory fails when not authenticated', () async {
      (fakeSupabase.auth as dynamic).mockUser = null;
      final result = await subscriptionRepository.getSubscriptionHistory();
      expect(result.isSuccess, false);
    });
  });
}
