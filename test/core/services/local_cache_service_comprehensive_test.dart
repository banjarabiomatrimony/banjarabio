import 'package:flutter_test/flutter_test.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:mocktail/mocktail.dart';
import 'package:banjarabio/core/services/local_cache_service.dart';

class MockBox extends Mock implements Box<dynamic> {}

void main() {
  late LocalCacheService cache;
  late Map<String, MockBox> boxes;

  setUp(() {
    cache = LocalCacheService();
    boxes = {};

    cache.testBoxOpener = (name) {
      boxes.putIfAbsent(name, () => MockBox());
      return boxes[name]!;
    };
  });

  tearDown(() {
    cache.reset();
  });

  /// Helper: set up a MockBox to accept put/get/delete with given key/value.
  void stubBoxGet(MockBox box, String key, dynamic value) {
    when(() => box.get(key)).thenReturn(value);
    when(() => box.get(key, defaultValue: any(named: 'defaultValue')))
        .thenAnswer((inv) => value ?? inv.namedArguments[#defaultValue]);
  }

  void stubBoxPut(MockBox box) {
    when(() => box.put(any(), any())).thenAnswer((_) async {});
  }

  void stubBoxDelete(MockBox box) {
    when(() => box.delete(any())).thenAnswer((_) async {});
  }

  group('LocalCacheService - box names', () {
    test('has correct box name constants', () {
      expect(LocalCacheService.boxAppMetadata, 'app_metadata');
      expect(LocalCacheService.boxOwnProfile, 'own_profile');
      expect(LocalCacheService.boxBookmarks, 'bookmarks');
      expect(LocalCacheService.boxHomeFeed, 'home_feed');
      expect(LocalCacheService.boxSearchHistory, 'search_history');
    });
  });

  group('LocalCacheService - pending referral', () {
    test('savePendingReferralId calls box.put', () async {
      final box = MockBox();
      boxes[LocalCacheService.boxAppMetadata] = box;
      stubBoxPut(box);

      await cache.savePendingReferralId('ref123');

      verify(() => box.put('pending_referral_id', 'ref123')).called(1);
    });

    test('getPendingReferralId calls box.get', () {
      final box = MockBox();
      boxes[LocalCacheService.boxAppMetadata] = box;
      stubBoxGet(box, 'pending_referral_id', 'ref123');

      expect(cache.getPendingReferralId(), 'ref123');
    });

    test('getPendingReferralId returns null when not set', () {
      final box = MockBox();
      boxes[LocalCacheService.boxAppMetadata] = box;
      stubBoxGet(box, 'pending_referral_id', null);

      expect(cache.getPendingReferralId(), isNull);
    });

    test('clearPendingReferralId calls box.delete', () async {
      final box = MockBox();
      boxes[LocalCacheService.boxAppMetadata] = box;
      stubBoxDelete(box);

      await cache.clearPendingReferralId();

      verify(() => box.delete('pending_referral_id')).called(1);
    });
  });

  group('LocalCacheService - pending profile ID', () {
    test('save and get profile ID', () async {
      final box = MockBox();
      boxes[LocalCacheService.boxAppMetadata] = box;
      stubBoxPut(box);
      stubBoxGet(box, 'pending_profile_id', 'p_abc');

      await cache.savePendingProfileId('p_abc');
      expect(cache.getPendingProfileId(), 'p_abc');
    });
  });

  group('LocalCacheService - pending promo code', () {
    test('save and get promo code', () async {
      final box = MockBox();
      boxes[LocalCacheService.boxAppMetadata] = box;
      stubBoxPut(box);
      stubBoxGet(box, 'pending_promo_code', 'PROMO50');

      await cache.savePendingPromoCode('PROMO50');
      expect(cache.getPendingPromoCode(), 'PROMO50');
    });
  });

  group('LocalCacheService - rewards flag', () {
    test('save and get flag', () async {
      final box = MockBox();
      boxes[LocalCacheService.boxAppMetadata] = box;
      stubBoxPut(box);
      stubBoxGet(box, 'pending_rewards_flag', true);

      await cache.savePendingRewardsFlag(true);
      expect(cache.getPendingRewardsFlag(), true);
    });

    test('defaults to false', () {
      final box = MockBox();
      boxes[LocalCacheService.boxAppMetadata] = box;
      stubBoxGet(box, 'pending_rewards_flag', null);

      expect(cache.getPendingRewardsFlag(), false);
    });
  });

  group('LocalCacheService - Instagram prompt date', () {
    test('save and get date', () async {
      final box = MockBox();
      boxes[LocalCacheService.boxAppMetadata] = box;
      stubBoxPut(box);
      stubBoxGet(box, 'last_instagram_prompt_date', '2025-06-15T10:30:00.000');

      await cache.saveLastInstagramPromptDate(DateTime(2025, 6, 15, 10, 30));

      final retrieved = cache.getLastInstagramPromptDate();
      expect(retrieved, isNotNull);
      expect(retrieved!.year, 2025);
      expect(retrieved.month, 6);
    });

    test('returns null when not set', () {
      final box = MockBox();
      boxes[LocalCacheService.boxAppMetadata] = box;
      stubBoxGet(box, 'last_instagram_prompt_date', null);

      expect(cache.getLastInstagramPromptDate(), isNull);
    });
  });

  group('LocalCacheService - own profile', () {
    test('save calls box.put', () async {
      final box = MockBox();
      boxes[LocalCacheService.boxOwnProfile] = box;
      stubBoxPut(box);

      await cache.saveOwnProfile({'id': 'p1', 'name': 'Test'});

      verify(() => box.put('profile', {'id': 'p1', 'name': 'Test'})).called(1);
    });

    test('getOwnProfile returns null when not set', () {
      final box = MockBox();
      boxes[LocalCacheService.boxOwnProfile] = box;
      when(() => box.get('profile')).thenReturn(null);

      expect(cache.getOwnProfile(), isNull);
    });

    test('clearOwnProfile calls delete', () async {
      final box = MockBox();
      boxes[LocalCacheService.boxOwnProfile] = box;
      stubBoxDelete(box);

      await cache.clearOwnProfile();

      verify(() => box.delete('profile')).called(1);
    });
  });

  group('LocalCacheService - bookmarks', () {
    test('getBookmarks returns empty when not set', () {
      final box = MockBox();
      boxes[LocalCacheService.boxBookmarks] = box;
      when(() => box.get('list')).thenReturn(null);

      expect(cache.getBookmarks(), isEmpty);
    });
  });

  group('LocalCacheService - home feed', () {
    test('getHomeFeed returns empty when not set', () {
      final box = MockBox();
      boxes[LocalCacheService.boxHomeFeed] = box;
      when(() => box.get('initial_page')).thenReturn(null);

      expect(cache.getHomeFeed(), isEmpty);
    });

    test('clearHomeFeed calls delete', () async {
      final box = MockBox();
      boxes[LocalCacheService.boxHomeFeed] = box;
      stubBoxDelete(box);

      await cache.clearHomeFeed();

      verify(() => box.delete('initial_page')).called(1);
    });
  });

  group('LocalCacheService - guest mode', () {
    test('setGuestMode calls box.put', () async {
      final box = MockBox();
      boxes[LocalCacheService.boxAppMetadata] = box;
      stubBoxPut(box);

      await cache.setGuestMode(true);

      verify(() => box.put('is_guest_mode', true)).called(1);
    });

    test('isGuestMode returns value from box', () {
      final box = MockBox();
      boxes[LocalCacheService.boxAppMetadata] = box;
      stubBoxGet(box, 'is_guest_mode', true);

      expect(cache.isGuestMode(), true);
    });

    test('isGuestMode defaults to false', () {
      final box = MockBox();
      boxes[LocalCacheService.boxAppMetadata] = box;
      stubBoxGet(box, 'is_guest_mode', null);

      expect(cache.isGuestMode(), false);
    });
  });

  group('LocalCacheService - guest tour', () {
    test('setGuestTourCompleted calls box.put', () async {
      final box = MockBox();
      boxes[LocalCacheService.boxAppMetadata] = box;
      stubBoxPut(box);

      await cache.setGuestTourCompleted(true);

      verify(() => box.put('is_guest_tour_completed', true)).called(1);
    });

    test('isGuestTourCompleted defaults to false', () {
      final box = MockBox();
      boxes[LocalCacheService.boxAppMetadata] = box;
      stubBoxGet(box, 'is_guest_tour_completed', null);

      expect(cache.isGuestTourCompleted(), false);
    });
  });

  group('LocalCacheService - tour stages', () {
    test('setTourStageCompleted stores with prefixed key', () async {
      final box = MockBox();
      boxes[LocalCacheService.boxAppMetadata] = box;
      stubBoxPut(box);

      await cache.setTourStageCompleted('filter', true);

      verify(() => box.put('tour_filter_completed', true)).called(1);
    });

    test('isTourStageCompleted reads with prefixed key', () {
      final box = MockBox();
      boxes[LocalCacheService.boxAppMetadata] = box;
      stubBoxGet(box, 'tour_filter_completed', true);

      expect(cache.isTourStageCompleted('filter'), true);
    });

    test('isTourStageCompleted defaults to false', () {
      final box = MockBox();
      boxes[LocalCacheService.boxAppMetadata] = box;
      stubBoxGet(box, 'tour_unknown_completed', null);

      expect(cache.isTourStageCompleted('unknown'), false);
    });
  });

  group('LocalCacheService - search history', () {
    test('addSearchTerm ignores empty strings', () async {
      // empty strings return early before accessing box
      await cache.addSearchTerm('');
      await cache.addSearchTerm('   ');

      // No box access should have occurred for search_history
      // (no mock set up, so it would throw if accessed)
    });
  });

  group('LocalCacheService - theme mode', () {
    test('saveThemeMode calls box.put', () async {
      final box = MockBox();
      boxes[LocalCacheService.boxAppMetadata] = box;
      stubBoxPut(box);

      await cache.saveThemeMode('dark');

      verify(() => box.put('theme_mode', 'dark')).called(1);
    });

    test('getThemeMode calls box.get', () {
      final box = MockBox();
      boxes[LocalCacheService.boxAppMetadata] = box;
      stubBoxGet(box, 'theme_mode', 'system');

      expect(cache.getThemeMode(), 'system');
    });

    test('getThemeMode returns null when not set', () {
      final box = MockBox();
      boxes[LocalCacheService.boxAppMetadata] = box;
      stubBoxGet(box, 'theme_mode', null);

      expect(cache.getThemeMode(), isNull);
    });

    test('clearThemeMode calls box.delete', () async {
      final box = MockBox();
      boxes[LocalCacheService.boxAppMetadata] = box;
      stubBoxDelete(box);

      await cache.clearThemeMode();

      verify(() => box.delete('theme_mode')).called(1);
    });
  });

  group('LocalCacheService - reset', () {
    test('reset clears testBoxOpener', () {
      cache.reset();

      // After reset, testBoxOpener is null, so _getBox will try Hive directly
      // which is not initialized in tests — this verifies cleanup
      expect(() => cache.getPendingReferralId(), throwsA(anything));
    });
  });
}

