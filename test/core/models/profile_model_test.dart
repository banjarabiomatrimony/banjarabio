import 'package:flutter_test/flutter_test.dart';
import 'package:banjarabio/core/models/profile_model.dart';

void main() {
  group('ProfileModel Tests', () {
    final Map<String, dynamic> fullJson = {
      'id': 'uuid-123',
      'user_id': 'user-123',
      'full_name': 'John',
      'surname': 'Doe',
      'age': 25,
      'gender': 'Male',
      'height': '5\'10"',
      'education': 'B.Tech',
      'profession': 'Engineer',
      'phone_number': '1234567890',
      'date_of_birth': '1998-01-01T00:00:00.000Z',
      'state': 'Maharashtra',
      'district': 'Pune',
      'taluka': 'Haveli',
      'village': 'Wakad',
      'current_location': 'Wakad, Haveli, Pune, Maharashtra',
      'is_premium': true,
      'has_followed_instagram': true,
      'created_at': '2023-01-01T00:00:00.000Z',
      'updated_at': '2023-01-01T00:00:00.000Z',
      'photos': [
        {
          'id': 'photo-1',
          'profile_id': 'uuid-123',
          'storage_path': 'path/to/photo.jpg',
          'public_url': 'http://example.com/photo.jpg',
          'is_primary': true,
          'is_approved': true,
          'uploaded_at': '2023-01-01T00:00:00.000Z',
        }
      ]
    };

    test('should correctly parse full fromJson', () {
      final profile = ProfileModel.fromJson(fullJson);

      expect(profile.id, 'uuid-123');
      expect(profile.fullName, 'John');
      expect(profile.isPremium, true);
      expect(profile.hasFollowedInstagram, true);
      expect(profile.photos.length, 1);
      expect(profile.photos.first.publicUrl, 'http://example.com/photo.jpg');
    });

    test('should handle minimal fromJson payload safely', () {
      final minJson = {
        'id': 'uuid-min',
        'user_id': 'user-min',
        // Omitting optional fields to test fallbacks
      };
      
      final profile = ProfileModel.fromJson(minJson);
      
      expect(profile.id, 'uuid-min');
      expect(profile.fullName, ''); // Default fallback
      expect(profile.age, 18); // Default fallback
      expect(profile.photos, isEmpty);
    });

    test('toJson produces expected structure', () {
      final profile = ProfileModel.fromJson(fullJson);
      final json = profile.toJson();

      expect(json['id'], 'uuid-123');
      expect(json['full_name'], 'John');
      expect(json['phone_number'], '1234567890');
      expect(json['photos'], isNotNull);
      expect((json['photos'] as List).length, 1);
      expect(json['is_premium'], true);
    });

    test('formattedLocation includes village, taluka, district, state', () {
      final profile = ProfileModel.fromJson(fullJson);
      expect(profile.formattedLocation, 'Wakad, Haveli, Pune, Maharashtra');
      expect(profile.currentLocation, 'Wakad, Haveli, Pune, Maharashtra');
    });

    test('formattedLocation falls back to permanentLocation if empty', () {
      final json = Map<String, dynamic>.from(fullJson)
        ..remove('village')
        ..remove('taluka')
        ..remove('district')
        ..remove('state')
        ..['permanent_location'] = 'Custom Permanent Address';
      final profile = ProfileModel.fromJson(json);
      expect(profile.formattedLocation, 'Custom Permanent Address');
    });

    test('locationExcludingVillage omits village', () {
      final profile = ProfileModel.fromJson(fullJson);
      expect(profile.locationExcludingVillage, 'Haveli, Pune, Maharashtra');
    });

    test('locationExcludingVillage falls back to permanentLocation if empty', () {
      final json = Map<String, dynamic>.from(fullJson)
        ..remove('village')
        ..remove('taluka')
        ..remove('district')
        ..remove('state')
        ..['permanent_location'] = 'Custom Permanent Address';
      final profile = ProfileModel.fromJson(json);
      expect(profile.locationExcludingVillage, 'Custom Permanent Address');
    });

    test('formattedDOB formats date correctly', () {
      final profile = ProfileModel.fromJson(fullJson);
      expect(profile.formattedDOB, '01 Jan 1998');
    });

    test('formattedDOB returns Not Entered if null', () {
      final json = Map<String, dynamic>.from(fullJson)..remove('date_of_birth');
      final profile = ProfileModel.fromJson(json);
      expect(profile.formattedDOB, 'Not Entered');
    });

    test('maskedPhoneNumber masks last 5 digits', () {
      final profile = ProfileModel.fromJson(fullJson);
      expect(profile.maskedPhoneNumber, '12345*****');
    });

    test('maskedPhoneNumber handles short numbers safely', () {
      final json = Map<String, dynamic>.from(fullJson)..['phone_number'] = '1234';
      final profile = ProfileModel.fromJson(json);
      expect(profile.maskedPhoneNumber, '1234');
    });

    test('precomputeDisplayData generates correct map', () {
      final profile = ProfileModel.fromJson(fullJson);
      final map = profile.precomputeDisplayData();

      expect(map['id'], 'uuid-123');
      expect(map['name'], 'John');
      expect(map['location'], 'Haveli, Pune, Maharashtra');
      expect(map['photos'].length, 1);
      expect(map['profileCompletion'], profile.completionPercentage);
    });

    test('toDisplayMap uses cache when available', () {
      final profile = ProfileModel.fromJson(fullJson);
      final map1 = profile.toDisplayMap();
      final map2 = profile.toDisplayMap();

      expect(map1, same(map2)); // Should be same instance due to caching
    });

    test('isEnriched returns true when photos exist', () {
      final profile = ProfileModel.fromJson(fullJson);
      expect(profile.isEnriched, true);
    });

    test('isEnriched returns false when no photos, matches, or bookmarks', () {
      final json = Map<String, dynamic>.from(fullJson)..remove('photos');
      final profile = ProfileModel.fromJson(json);
      expect(profile.isEnriched, false);
    });

    test('copyWith updates fields while preserving others', () {
      final profile = ProfileModel.fromJson(fullJson);
      final updated = profile.copyWith(fullName: 'Jane', age: 30);

      expect(updated.fullName, 'Jane');
      expect(updated.age, 30);
      expect(updated.id, profile.id); // Preserved
    });
  });
}
