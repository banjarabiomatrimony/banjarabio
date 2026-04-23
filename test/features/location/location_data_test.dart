import 'package:flutter_test/flutter_test.dart';
import 'package:banjarabio/core/data/location_data.dart';

void main() {
  group('LocationData Tests', () {
    test('getDistricts should return correct districts for Maharashtra', () {
      final districts = LocationData.getDistricts('Maharashtra');
      expect(districts, contains('Pune'));
      expect(districts, contains('Nagpur'));
      expect(districts.length, greaterThan(30));
    });

    test('getTalukas should return correct talukas for Pune', () {
      final talukas = LocationData.getTalukas('Pune');
      expect(talukas, contains('Haveli'));
      expect(talukas, contains('Pune City'));
      expect(talukas.length, greaterThan(10));
    });

    test('getDistricts should return empty list for invalid state', () {
      final districts = LocationData.getDistricts('Invalid State');
      expect(districts, isEmpty);
    });

    test('formatLocation should join parts correctly', () {
      final formatted = LocationData.formatLocation(
        village: 'Pimpri',
        taluka: 'Haveli',
        district: 'Pune',
        state: 'Maharashtra',
      );
      expect(formatted, 'Pimpri, Haveli, Pune, Maharashtra');
    });

    test('formatLocation should handle missing parts gracefully', () {
      final formatted = LocationData.formatLocation(
        district: 'Pune',
        state: 'Maharashtra',
      );
      expect(formatted, 'Pune, Maharashtra');
    });

    test('formatLocation should handle empty strings', () {
      final formatted = LocationData.formatLocation(
        taluka: '',
        district: 'Pune',
        state: 'Maharashtra',
      );
      expect(formatted, 'Pune, Maharashtra');
    });
  });
}
