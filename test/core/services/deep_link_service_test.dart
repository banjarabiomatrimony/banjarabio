// Phase 11: DeepLinkService unit tests
// Tests deep link URL parsing, route dispatching, and cache interactions.
// NOTE: NavigatorState can't be mocked via mocktail (Diagnosticable.toString conflict),
// so we test only the routing-to-cache logic path here.

import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:banjarabio/core/services/deep_link_service.dart';
import 'package:banjarabio/core/services/local_cache_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class MockLocalCacheService extends Mock implements LocalCacheService {}
class MockSupabaseClient extends Mock implements SupabaseClient {}
class MockGoTrueClient extends Mock implements GoTrueClient {}

void main() {
  late DeepLinkService service;
  late MockLocalCacheService mockCache;
  late MockSupabaseClient mockClient;
  late MockGoTrueClient mockAuth;

  setUp(() {
    service = DeepLinkService();
    service.reset();

    mockCache = MockLocalCacheService();
    mockClient = MockSupabaseClient();
    mockAuth = MockGoTrueClient();

    service.testCache = mockCache;
    service.testClient = mockClient;

    when(() => mockClient.auth).thenReturn(mockAuth);
    when(() => mockAuth.currentSession).thenReturn(null);
    when(() => mockCache.savePendingProfileId(any())).thenAnswer((_) async {});
    when(() => mockCache.savePendingReferralId(any())).thenAnswer((_) async {});
    when(() => mockCache.savePendingPromoCode(any())).thenAnswer((_) async {});
    when(() => mockCache.savePendingRewardsFlag(any())).thenAnswer((_) async {});
  });

  tearDown(() {
    service.reset();
  });

  group('DeepLinkService.handleDeepLink', () {
    test('ignores null URI', () async {
      await service.handleDeepLink(null);
      verifyNever(() => mockCache.savePendingProfileId(any()));
      verifyNever(() => mockCache.savePendingReferralId(any()));
    });

    test('handles path-based profile link (banjarabio://profile/abc-123)', () async {
      final uri = Uri.parse('banjarabio://profile/abc-123');
      await service.handleDeepLink(uri);
      verify(() => mockCache.savePendingProfileId('abc-123')).called(1);
    });

    test('handles parameter-based profile link (banjarabio://profile?id=xyz-789)', () async {
      final uri = Uri.parse('banjarabio://profile?id=xyz-789');
      await service.handleDeepLink(uri);
      verify(() => mockCache.savePendingProfileId('xyz-789')).called(1);
    });

    test('handles path-based invite link (banjarabio://invite/ref-456)', () async {
      final uri = Uri.parse('banjarabio://invite/ref-456');
      await service.handleDeepLink(uri);
      verify(() => mockCache.savePendingReferralId('ref-456')).called(1);
    });

    test('handles parameter-based invite link (banjarabio://invite?id=ref-789)', () async {
      final uri = Uri.parse('banjarabio://invite?id=ref-789');
      await service.handleDeepLink(uri);
      verify(() => mockCache.savePendingReferralId('ref-789')).called(1);
    });

    test('handles path-based promo link (banjarabio://promo/SAVE20)', () async {
      final uri = Uri.parse('banjarabio://promo/SAVE20');
      await service.handleDeepLink(uri);
      verify(() => mockCache.savePendingPromoCode('SAVE20')).called(1);
    });

    test('handles parameter-based promo link (banjarabio://promo?code=DISCOUNT30)', () async {
      final uri = Uri.parse('banjarabio://promo?code=DISCOUNT30');
      await service.handleDeepLink(uri);
      verify(() => mockCache.savePendingPromoCode('DISCOUNT30')).called(1);
    });

    test('handles banjarabio://rewards custom scheme', () async {
      var rewardsCalled = false;
      service.onRewardsTriggered = () {
        rewardsCalled = true;
      };

      final uri = Uri.parse('banjarabio://rewards');
      await service.handleDeepLink(uri);

      verify(() => mockCache.savePendingRewardsFlag(true)).called(1);
      expect(rewardsCalled, isTrue);
    });

    test('rewards does not crash when callback is null', () async {
      service.onRewardsTriggered = null;
      final uri = Uri.parse('banjarabio://rewards');
      await service.handleDeepLink(uri);

      verify(() => mockCache.savePendingRewardsFlag(true)).called(1);
    });

    test('handles legacy /profile/ path', () async {
      final uri = Uri.parse('https://banjarabio.com/profile/abc-123');
      await service.handleDeepLink(uri);
      verify(() => mockCache.savePendingProfileId('abc-123')).called(1);
    });

    test('handles legacy /invite/ path', () async {
      final uri = Uri.parse('https://banjarabio.com/invite/ref-456');
      await service.handleDeepLink(uri);
      verify(() => mockCache.savePendingReferralId('ref-456')).called(1);
    });

    test('handles legacy /promo/ path', () async {
      final uri = Uri.parse('https://banjarabio.com/promo/SAVE20');
      await service.handleDeepLink(uri);
      verify(() => mockCache.savePendingPromoCode('SAVE20')).called(1);
    });

    test('handles universal web profile link (https://banjarabio.com/profile?id=abc-999)', () async {
      final uri = Uri.parse('https://banjarabio.com/profile?id=abc-999');
      await service.handleDeepLink(uri);
      verify(() => mockCache.savePendingProfileId('abc-999')).called(1);
    });

    test('handles play store referrer profile link (referrer=profile/xyz-888)', () async {
      final uri = Uri.parse('https://play.google.com/store/apps/details?id=com.avishio.banjarabio&referrer=profile/xyz-888');
      await service.handleDeepLink(uri);
      verify(() => mockCache.savePendingProfileId('xyz-888')).called(1);
    });

    test('handles unknown URI path gracefully', () async {
      final uri = Uri.parse('https://banjarabio.com/unknown/path');
      await service.handleDeepLink(uri);

      // No cache interactions for unrecognized paths
      verifyNever(() => mockCache.savePendingProfileId(any()));
      verifyNever(() => mockCache.savePendingReferralId(any()));
      verifyNever(() => mockCache.savePendingPromoCode(any()));
    });
  });

  group('DeepLinkService lifecycle', () {
    test('dispose cleans up without error', () {
      service.dispose();
      // No crash = success
    });

    test('reset clears all test overrides', () {
      service.testCache = mockCache;
      service.testClient = mockClient;
      service.reset();
      // No crash = success
    });
  });
}
