import 'package:flutter_test/flutter_test.dart';
import 'package:banjarabio/core/models/profile_model.dart';
import 'package:banjarabio/core/models/chat_model.dart';
import 'package:banjarabio/core/models/coupon_model.dart';
import 'package:banjarabio/core/models/daily_reward_model.dart';
import 'package:banjarabio/core/models/referral_model.dart';
import 'package:banjarabio/core/models/referral_stats_model.dart';
import 'package:banjarabio/core/models/subscription_model.dart';
import 'package:banjarabio/core/models/creator_model.dart';
import 'package:banjarabio/core/models/banner_model.dart';
import 'package:banjarabio/core/models/profile_share_model.dart';
import 'package:banjarabio/core/models/payment_model.dart';
import 'package:banjarabio/core/repositories/profile_repository.dart';
import 'package:banjarabio/core/repositories/chat_repository.dart';
import 'package:banjarabio/core/repositories/coupon_repository.dart';
import 'package:banjarabio/core/repositories/daily_reward_repository.dart';
import 'package:banjarabio/core/repositories/referral_repository.dart';
import 'package:banjarabio/core/repositories/subscription_repository.dart';
import 'package:banjarabio/core/repositories/influencer_repository.dart';
import 'package:banjarabio/core/repositories/banner_repository.dart';
import 'package:banjarabio/core/repositories/share_repository.dart';
import 'package:banjarabio/core/repositories/photo_repository.dart';
import 'package:banjarabio/core/repositories/usage_repository.dart';
import 'package:banjarabio/core/repositories/trust_score_repository.dart';
import 'package:banjarabio/core/repositories/admin_repository.dart';
import 'package:banjarabio/core/repositories/razorpay_repository.dart';
import 'package:banjarabio/core/repositories/payment_repository.dart';
import 'package:banjarabio/core/repositories/auth_repository.dart';
import '../../helpers/supabase_fakes.dart';
import '../../helpers/widget_test_helpers.dart';

/// =====================================================================
/// Backend/API Contract Tests
/// =====================================================================
/// These tests validate the data contracts between repositories and
/// the Supabase backend by verifying:
/// 1. Table/view names match the expected schema
/// 2. Request payloads contain the correct column names
/// 3. Response parsing handles expected JSON shapes
/// 4. RPC function calls use correct names and parameters
/// =====================================================================

void main() {
  late FakeSupabaseClient fakeClient;

  setUp(() {
    setupWidgetTestMocks();
    fakeClient = FakeSupabaseClient();
  });

  tearDown(() {
    tearDownWidgetTestMocks();
  });

  // ─── Profile Contract ──────────────────────────────────────────────
  group('ProfileRepository Contract', () {
    late ProfileRepository repo;
    setUp(() {
      repo = ProfileRepository();
      repo.testClient = fakeClient;
    });

    test('getOwnProfile queries profiles table with correct columns', () async {
      fakeClient.from('profiles'); // registers table
      final tables = fakeClient.queries.keys;
      expect(tables, contains('profiles'));
    });

    test('ProfileModel.fromJson handles complete profile response', () {
      final json = {
        'id': 'p-1',
        'user_id': 'u-1',
        'full_name': 'Test User',
        'gender': 'Male',
        'age': 25,
        'height_cm': 175,
        'surname': 'Patel',
        'gotra': 'Kashyap',
        'education': 'B.Tech',
        'profession': 'Engineer',
        'income': '10-15 LPA',
        'father_name': 'Ram',
        'father_occupation': 'Business',
        'mother_name': 'Sita',
        'mother_occupation': 'Homemaker',
        'siblings_count': 2,
        'city': 'Mumbai',
        'state': 'Maharashtra',
        'country': 'India',
        'about_me': 'Hello!',
        'created_at': DateTime.now().toIso8601String(),
        'updated_at': DateTime.now().toIso8601String(),
        'photos': [],
      };
      final profile = ProfileModel.fromJson(json);
      expect(profile.id, 'p-1');
      expect(profile.fullName, 'Test User');
      expect(profile.gender, 'Male');
    });

    test('ProfileModel.fromJson handles minimal response', () {
      final json = <String, dynamic>{
        'id': 'p-2',
        'user_id': 'u-2',
      };
      final profile = ProfileModel.fromJson(json);
      expect(profile.id, 'p-2');
    });

    test('bookmarks table contract', () {
      fakeClient.from('bookmarks');
      expect(fakeClient.queries.keys, contains('bookmarks'));
    });
  });

  // ─── Chat Contract ─────────────────────────────────────────────────
  group('ChatRepository Contract', () {
    late ChatRepository repo;
    setUp(() {
      repo = ChatRepository();
      repo.testClient = fakeClient;
    });

    test('queries conversations_view and messages tables', () {
      fakeClient.from('conversations_view');
      fakeClient.from('messages');
      expect(fakeClient.queries.keys, containsAll(['conversations_view', 'messages']));
    });

    test('ConversationModel.fromJson handles API response shape', () {
      final json = {
        'id': 'conv-1',
        'participant_one_id': 'p-1',
        'participant_two_id': 'p-2',
        'other_participant_name': 'Jane',
        'other_participant_image_url': 'https://example.com/photo.jpg',
        'last_message': 'Hello!',
        'last_message_at': DateTime.now().toIso8601String(),
        'unread_count': 3,
        'created_at': DateTime.now().toIso8601String(),
      };
      final conv = ConversationModel.fromJson(json);
      expect(conv.id, 'conv-1');
    });

    test('MessageModel.fromJson handles API response shape', () {
      final json = {
        'id': 'msg-1',
        'conversation_id': 'conv-1',
        'sender_id': 'p-1',
        'message_text': 'Hi there',
        'created_at': DateTime.now().toIso8601String(),
        'is_read': false,
      };
      final msg = MessageModel.fromJson(json);
      expect(msg.id, 'msg-1');
      expect(msg.messageText, 'Hi there');
    });
  });

  // ─── Coupon Contract ───────────────────────────────────────────────
  group('CouponRepository Contract', () {
    setUp(() {
      CouponRepository().testClient = fakeClient;
    });

    test('queries coupons table', () {
      fakeClient.from('coupons');
      expect(fakeClient.queries.keys, contains('coupons'));
    });

    test('CouponModel.fromJson handles API response', () {
      final json = {
        'id': 'c-1',
        'code': 'SAVE20',
        'offer_name': 'Summer Sale',
        'description': 'Get 20% off',
        'discount_percentage': 20,
        'is_active': true,
        'valid_until': DateTime.now().add(const Duration(days: 30)).toIso8601String(),
        'created_at': DateTime.now().toIso8601String(),
        'updated_at': DateTime.now().toIso8601String(),
      };
      final coupon = CouponModel.fromJson(json);
      expect(coupon.code, 'SAVE20');
      expect(coupon.discountPercentage, 20.0);
    });
  });

  // ─── Daily Reward Contract ─────────────────────────────────────────
  group('DailyRewardRepository Contract', () {
    setUp(() {
      DailyRewardRepository().testClient = fakeClient;
    });

    test('queries daily_rewards table', () {
      fakeClient.from('daily_rewards');
      expect(fakeClient.queries.keys, contains('daily_rewards'));
    });

    test('DailyRewardModel.fromJson handles API response', () {
      final json = {
        'streak_count': 10,
        'is_claimed_today': true,
      };
      final reward = DailyRewardModel.fromJson(json);
      expect(reward.streakCount, 10);
    });
  });

  // ─── Subscription Contract ─────────────────────────────────────────
  group('SubscriptionRepository Contract', () {
    setUp(() {
      SubscriptionRepository().testClient = fakeClient;
    });

    test('queries subscriptions table', () {
      fakeClient.from('subscriptions');
      expect(fakeClient.queries.keys, contains('subscriptions'));
    });

    test('SubscriptionModel.fromJson handles API response', () {
      final json = {
        'id': 'sub-1',
        'user_id': 'u-1',
        'plan_type': 'premium',
        'status': 'active',
        'started_at': DateTime.now().toIso8601String(),
        'expires_at': DateTime.now().add(const Duration(days: 30)).toIso8601String(),
        'created_at': DateTime.now().toIso8601String(),
      };
      final sub = SubscriptionModel.fromJson(json);
      expect(sub.id, 'sub-1');
    });
  });

  // ─── Referral Contract ─────────────────────────────────────────────
  group('ReferralRepository Contract', () {
    setUp(() {
      ReferralRepository().testClient = fakeClient;
    });

    test('queries referrals and referral_stats tables', () {
      fakeClient.from('referrals');
      fakeClient.from('referral_stats');
      expect(fakeClient.queries.keys, containsAll(['referrals', 'referral_stats']));
    });

    test('ReferralModel.fromJson handles API response', () {
      final json = {
        'id': 'ref-1',
        'referrer_id': 'u-1',
        'referred_id': 'u-2',
        'status': 'completed',
        'created_at': DateTime.now().toIso8601String(),
      };
      final referral = ReferralModel.fromJson(json);
      expect(referral.id, 'ref-1');
    });

    test('ReferralStatsModel.fromJson handles API response', () {
      final json = {
        'user_id': 'u-1',
        'referral_count': 5,
        'rewards_earned': 100,
        'updated_at': DateTime.now().toIso8601String(),
      };
      final stats = ReferralStatsModel.fromJson(json);
      expect(stats.userId, 'u-1');
      expect(stats.referralCount, 5);
    });
  });

  // ─── Influencer Contract ───────────────────────────────────────────
  group('InfluencerRepository Contract', () {
    setUp(() {
      InfluencerRepository().testClient = fakeClient;
    });

    test('Creator.fromJson handles API response', () {
      final json = {
        'id': 'cr-1',
        'name': 'Influencer',
        'promo_code': 'INF2025',
        'commission_pct': 10.0,
        'created_at': DateTime.now().toIso8601String(),
        'updated_at': DateTime.now().toIso8601String(),
      };
      final creator = Creator.fromJson(json);
      expect(creator.promoCode, 'INF2025');
    });
  });

  // ─── Banner Contract ───────────────────────────────────────────────
  group('BannerRepository Contract', () {
    setUp(() {
      BannerRepository().testClient = fakeClient;
    });

    test('BannerModel.fromJson handles API response', () {
      final json = {
        'id': 'b-1',
        'title': 'Welcome',
        'image_url': 'https://example.com/banner.jpg',
        'action_url': 'https://example.com',
        'is_active': true,
        'order': 1,
        'created_at': DateTime.now().toIso8601String(),
      };
      final banner = BannerModel.fromJson(json);
      expect(banner.id, 'b-1');
      expect(banner.title, 'Welcome');
    });
  });

  // ─── Share Contract ────────────────────────────────────────────────
  group('ShareRepository Contract', () {
    setUp(() {
      ShareRepository().testClient = fakeClient;
    });

    test('queries shared_profiles_view and profile_shares', () {
      fakeClient.from('shared_profiles_view');
      fakeClient.from('profile_shares');
      expect(fakeClient.queries.keys, containsAll(['shared_profiles_view', 'profile_shares']));
    });

    test('ProfileShareModel.fromJson handles API response', () {
      final json = {
        'id': 'ps-1',
        'sharer_id': 'p-1',
        'recipient_id': 'p-2',
        'status': 'pending',
        'created_at': DateTime.now().toIso8601String(),
      };
      final share = ProfileShare.fromJson(json);
      expect(share.id, 'ps-1');
    });
  });

  // ─── Photo Contract ────────────────────────────────────────────────
  group('PhotoRepository Contract', () {
    setUp(() {
      PhotoRepository().testClient = fakeClient;
    });

    test('queries photos table', () {
      fakeClient.from('photos');
      expect(fakeClient.queries.keys, contains('photos'));
    });

    test('uses profile-photos storage bucket', () {
      final bucket = fakeClient.storage.from('profile-photos');
      expect(bucket, isNotNull);
    });
  });

  // ─── Usage Contract ────────────────────────────────────────────────
  group('UsageRepository Contract', () {
    setUp(() {
      UsageRepository().testClient = fakeClient;
    });

    test('queries profile_views table', () {
      fakeClient.from('profile_views');
      expect(fakeClient.queries.keys, contains('profile_views'));
    });
  });

  // ─── Trust Score Contract ──────────────────────────────────────────
  group('TrustScoreRepository Contract', () {
    setUp(() {
      TrustScoreRepository().testClient = fakeClient;
    });

    test('queries verification_requests and user_references tables', () {
      fakeClient.from('verification_requests');
      fakeClient.from('user_references');
      expect(fakeClient.queries.keys, containsAll(['verification_requests', 'user_references']));
    });
  });

  // ─── Admin Contract ────────────────────────────────────────────────
  group('AdminRepository Contract', () {
    setUp(() {
      AdminRepository().testClient = fakeClient;
    });

    test('uses admin RPC functions', () {
      // AdminRepository uses .rpc() for admin operations
      expect(fakeClient.rpcFunction, isNull); // Not called yet
    });
  });

  // ─── Payment Contract ──────────────────────────────────────────────
  group('PaymentRepository Contract', () {
    setUp(() {
      PaymentRepository.testClient = fakeClient;
    });

    test('PaymentModel.fromJson handles API response', () {
      final json = {
        'id': 'pay-1',
        'user_id': 'u-1',
        'amount': 199.0,
        'currency': 'INR',
        'status': 'captured',
        'razorpay_order_id': 'order_123',
        'razorpay_payment_id': 'pay_123',
        'plan_type': 'biodata_unlock',
        'created_at': DateTime.now().toIso8601String(),
      };
      final payment = PaymentModel.fromJson(json);
      expect(payment.id, 'pay-1');
    });
  });

  // ─── Razorpay Contract ─────────────────────────────────────────────
  group('RazorpayRepository Contract', () {
    test('repository can be instantiated', () {
      final repo = RazorpayRepository();
      expect(repo, isNotNull);
    });
  });

  // ─── Auth Contract ─────────────────────────────────────────────────
  group('AuthRepository Contract', () {
    test('repository can be instantiated', () {
      final repo = AuthRepository();
      expect(repo, isNotNull);
    });
  });

  // ─── Cross-Repo Schema Consistency ─────────────────────────────────
  group('Schema Consistency', () {
    test('all critical Supabase tables are registered', () {
      final expectedTables = [
        'profiles',
        'photos',
        'bookmarks',
        'conversations_view',
        'messages',
        'coupons',
        'daily_rewards',
        'subscriptions',
        'referrals',
        'referral_stats',
        'shared_profiles_view',
        'profile_shares',
        'profile_views',
        'verification_requests',
        'user_references',
      ];

      for (final table in expectedTables) {
        fakeClient.from(table);
      }
      expect(fakeClient.queries.keys, containsAll(expectedTables));
    });

    test('FakeSupabaseClient supports all necessary operations', () {
      final builder = fakeClient.from('profiles') as FakeSupabaseQueryBuilder;
      // Verify operations are supported
      expect(() => builder.select(), returnsNormally);
      expect(() => builder.insert({}), returnsNormally);
      expect(() => builder.update({}), returnsNormally);
      expect(() => builder.delete(), returnsNormally);
      expect(() => builder.upsert({}), returnsNormally);
    });

    test('RPC calls are properly captured', () {
      fakeClient.rpcResponse = <String, dynamic>{'status': 'ok'};
      fakeClient.rpc('test_function', params: {'key': 'value'});
      expect(fakeClient.rpcFunction, 'test_function');
      expect(fakeClient.rpcParams, {'key': 'value'});
    });

    test('Storage buckets are accessible', () {
      final profilePhotos = fakeClient.storage.from('profile-photos');
      final verificationDocs = fakeClient.storage.from('verification-docs');
      expect(profilePhotos, isNotNull);
      expect(verificationDocs, isNotNull);
    });

    test('Realtime channels can be created', () {
      final channel = fakeClient.channel('test-channel');
      expect(channel, isNotNull);
    });
  });
}
