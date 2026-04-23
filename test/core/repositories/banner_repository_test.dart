import 'package:flutter_test/flutter_test.dart';
import 'package:banjarabio/core/repositories/banner_repository.dart';
import 'package:banjarabio/core/models/banner_model.dart';
import '../../helpers/supabase_fakes.dart';

void main() {
  late FakeSupabaseClient fakeSupabase;
  late BannerRepository bannerRepository;

  setUp(() {
    fakeSupabase = FakeSupabaseClient();
    bannerRepository = BannerRepository();
    bannerRepository.testClient = fakeSupabase;
  });

  group('BannerRepository Tests', () {
    test('getActiveBanners returns list on success', () async {
      final now = DateTime.now();
      final mockData = [
        {
          'id': 'b1',
          'title': 'Sale',
          'image_url': 'http://img.com',
          'is_active': true,
          'priority': 0,
          'created_at': now.toIso8601String(),
        }
      ];
      
      fakeSupabase.rpcResponse = mockData;
      
      final result = await bannerRepository.getActiveBanners();
      
      expect(result.isSuccess, true);
      expect(result.data.length, 1);
      expect(result.data.first.title, 'Sale');
    });

    test('getActiveBanners handles server error', () async {
      fakeSupabase.rpcError = 'RPC Error';
      
      final result = await bannerRepository.getActiveBanners();
      
      expect(result.isSuccess, false);
      expect(result.errorMessage, contains('RPC Error'));
    });
  });

  group('BannerModel Tests', () {
    test('should parse fromJson correctly', () {
      final now = DateTime.now();
      final json = {
        'id': 'b1',
        'title': 'Test',
        'image_url': 'url',
        'is_active': true,
        'created_at': now.toIso8601String(),
      };
      
      final banner = BannerModel.fromJson(json);
      expect(banner.id, 'b1');
      expect(banner.title, 'Test');
    });
  });
}
