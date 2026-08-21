import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:banjarabio/core/services/local_cache_service.dart';

class MockBox<T> extends Mock implements Box<T> {}

void main() {
  late LocalCacheService localCacheService;
  late MockBox<dynamic> mockAppMetadataBox;
  late MockBox<dynamic> mockOwnProfileBox;
  late MockBox<dynamic> mockBookmarksBox;
  late MockBox<dynamic> mockHomeFeedBox;
  late MockBox<dynamic> mockSearchHistoryBox;

  setUp(() {
    localCacheService = LocalCacheService();
    localCacheService.reset();

    mockAppMetadataBox = MockBox<dynamic>();
    mockOwnProfileBox = MockBox<dynamic>();
    mockBookmarksBox = MockBox<dynamic>();
    mockHomeFeedBox = MockBox<dynamic>();
    mockSearchHistoryBox = MockBox<dynamic>();

    localCacheService.testBoxOpener = (name) {
      switch (name) {
        case LocalCacheService.boxAppMetadata:
          return mockAppMetadataBox;
        case LocalCacheService.boxOwnProfile:
          return mockOwnProfileBox;
        case LocalCacheService.boxBookmarks:
          return mockBookmarksBox;
        case LocalCacheService.boxHomeFeed:
          return mockHomeFeedBox;
        case LocalCacheService.boxSearchHistory:
          return mockSearchHistoryBox;
        default:
          throw Exception('Box $name not mocked');
      }
    };
  });

  tearDown(() {
    localCacheService.reset();
  });

  group('App Metadata', () {
    test('savePendingReferralId puts data into box', () async {
      when(() => mockAppMetadataBox.put(any(), any())).thenAnswer((_) async => {});
      
      await localCacheService.savePendingReferralId('ref_123');
      
      verify(() => mockAppMetadataBox.put('pending_referral_id', 'ref_123')).called(1);
    });

    test('getPendingReferralId returns data from box', () async {
      when(() => mockAppMetadataBox.get(any(), defaultValue: any(named: 'defaultValue')))
          .thenReturn('ref_123');
      // Some calls Use get(key) without default value
      when(() => mockAppMetadataBox.get('pending_referral_id')).thenReturn('ref_123');
      
      final result = localCacheService.getPendingReferralId();
      
      expect(result, 'ref_123');
    });

    test('clearPendingReferralId deletes data from box', () async {
      when(() => mockAppMetadataBox.delete(any())).thenAnswer((_) async => {});
      
      await localCacheService.clearPendingReferralId();
      
      verify(() => mockAppMetadataBox.delete('pending_referral_id')).called(1);
    });
  });

  group('Own Profile', () {
    test('saveOwnProfile puts data into box', () async {
      when(() => mockOwnProfileBox.put(any(), any())).thenAnswer((_) async => {});
      final profile = {'name': 'Test User'};
      
      await localCacheService.saveOwnProfile(profile);
      
      verify(() => mockOwnProfileBox.put('profile', profile)).called(1);
    });

    test('getOwnProfile returns mapped data', () async {
      final profile = {'name': 'Test User'};
      when(() => mockOwnProfileBox.get('profile')).thenReturn(profile);
      
      final result = localCacheService.getOwnProfile();
      
      expect(result, profile);
    });

    test('clearOwnProfile deletes data', () async {
      when(() => mockOwnProfileBox.delete(any())).thenAnswer((_) async => {});
      
      await localCacheService.clearOwnProfile();
      
      verify(() => mockOwnProfileBox.delete('profile')).called(1);
    });
  });

  group('Search History', () {
    test('addSearchTerm adds unique term and limits count', () async {
      when(() => mockSearchHistoryBox.get('history', defaultValue: [])).thenReturn(['old']);
      when(() => mockSearchHistoryBox.put(any(), any())).thenAnswer((_) async => {});
      
      await localCacheService.addSearchTerm('new');
      
      verify(() => mockSearchHistoryBox.put('history', ['new', 'old'])).called(1);
    });

    test('clearSearchHistory deletes key', () async {
      when(() => mockSearchHistoryBox.delete(any())).thenAnswer((_) async => {});
      
      await localCacheService.clearSearchHistory();
      
      verify(() => mockSearchHistoryBox.delete('history')).called(1);
    });
  });

  group('Theme Mode', () {
    test('saveThemeMode puts theme_mode into boxAppMetadata', () async {
      when(() => mockAppMetadataBox.put(any(), any())).thenAnswer((_) async => {});

      await localCacheService.saveThemeMode('dark');

      verify(() => mockAppMetadataBox.put('theme_mode', 'dark')).called(1);
    });

    test('getThemeMode returns theme_mode string from boxAppMetadata', () {
      when(() => mockAppMetadataBox.get('theme_mode')).thenReturn('dark');

      final result = localCacheService.getThemeMode();

      expect(result, 'dark');
    });

    test('clearThemeMode deletes theme_mode from boxAppMetadata', () async {
      when(() => mockAppMetadataBox.delete(any())).thenAnswer((_) async => {});

      await localCacheService.clearThemeMode();

      verify(() => mockAppMetadataBox.delete('theme_mode')).called(1);
    });
  });
}

