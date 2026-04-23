import 'package:flutter_test/flutter_test.dart';
import 'package:banjarabio/core/data/location_data.dart';

void main() {
  group('LocationData Tests', () {
    test('getDistricts returns correct districts for known state', () {
      final districts = LocationData.getDistricts('Maharashtra');
      expect(districts, isNotEmpty);
      expect(districts.contains('Pune'), isTrue);
      expect(districts.contains('Mumbai City'), isTrue);
    });

    test('getDistricts returns empty list for unknown state', () {
      final districts = LocationData.getDistricts('UnknownState');
      expect(districts, isEmpty);
    });

    test('getTalukas returns correct talukas for known district', () {
      final talukas = LocationData.getTalukas('Pune');
      expect(talukas, isNotEmpty);
      expect(talukas.contains('Baramati'), isTrue);
      expect(talukas.contains('Pune City'), isTrue);
    });

    test('getTalukas returns empty list for unknown district', () {
      final talukas = LocationData.getTalukas('UnknownDistrict');
      expect(talukas, isEmpty);
    });

    test('formatLocation formats all parts correctly', () {
      final formatted = LocationData.formatLocation(
        village: 'V1',
        taluka: 'T1',
        district: 'D1',
        state: 'S1',
      );
      expect(formatted, 'V1, T1, D1, S1');
    });

    test('formatLocation formats correctly with missing parts', () {
      final formatted1 = LocationData.formatLocation(
        taluka: 'T1',
        state: 'S1',
      );
      expect(formatted1, 'T1, S1');

      final formatted2 = LocationData.formatLocation(
        district: 'D1',
      );
      expect(formatted2, 'D1');
    });

    test('formatLocation handles empty strings gracefully', () {
      final formatted = LocationData.formatLocation(
        village: '',
        taluka: 'T1',
        district: '',
        state: 'S1',
      );
      expect(formatted, 'T1, S1');
    });
  });
}
