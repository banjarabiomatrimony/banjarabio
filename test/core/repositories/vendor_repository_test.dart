import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:banjarabio/core/repositories/vendor_repository.dart';
import '../../helpers/supabase_fakes.dart';

void main() {
  late FakeSupabaseClient fakeSupabase;
  late VendorRepository vendorRepository;

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    fakeSupabase = FakeSupabaseClient();
    VendorRepository.testClient = fakeSupabase;
    vendorRepository = VendorRepository.instance;
  });

  tearDown(() {
    VendorRepository.testClient = null;
  });

  group('VendorRepository Tests', () {
    test('registerVendor creates and locally caches vendor profile', () async {
      final response = await vendorRepository.registerVendor(
        businessName: 'Royal Banjara Caterers',
        ownerName: 'Vijay Rathod',
        phone: '9876543210',
        whatsapp: '9876543210',
        category: 'catering',
        categoryLabel: 'Catering & Food',
        state: 'Maharashtra',
        district: 'Pune',
        city: 'Pune',
        address: 'Hinjawadi',
        experienceYears: 5,
        startingPrice: 25000,
      );

      expect(response.isSuccess, isTrue);
      expect(response.data.businessName, equals('Royal Banjara Caterers'));
      expect(response.data.category, equals('catering'));

      // Check local cache retrieval
      final cachedVendor = await vendorRepository.getCurrentVendorProfile();
      expect(cachedVendor, isNotNull);
      expect(cachedVendor?.ownerName, equals('Vijay Rathod'));
    });

    test('getCurrentVendorProfile returns null when no vendor registered locally', () async {
      final cached = await vendorRepository.getCurrentVendorProfile();
      expect(cached, isNull);
    });
  });
}
