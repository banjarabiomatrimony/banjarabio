import 'package:flutter_test/flutter_test.dart';
import 'package:banjarabio/core/models/profile_model.dart';
import 'package:banjarabio/core/models/subscription_model.dart';
import 'package:banjarabio/core/models/sibling_model.dart';

/// Helper to build a minimal valid JSON for ProfileModel.fromJson.
Map<String, dynamic> _baseJson({Map<String, dynamic>? overrides}) {
  return {
    'id': 'p1',
    'user_id': 'u1',
    'full_name': 'Rahul Patil',
    'surname': 'Patil',
    'age': 25,
    'gender': 'Male',
    'height': "5'10\"",
    'education': 'B.Tech',
    'profession': 'Engineer',
    'created_at': '2025-01-01T00:00:00Z',
    'updated_at': '2025-06-01T00:00:00Z',
    ...?overrides,
  };
}

void main() {
  group('ProfileModel.fromJson', () {
    test('parses minimal JSON correctly', () {
      final p = ProfileModel.fromJson(_baseJson());
      expect(p.id, 'p1');
      expect(p.userId, 'u1');
      expect(p.fullName, 'Rahul Patil');
      expect(p.surname, 'Patil');
      expect(p.age, 25);
      expect(p.gender, 'Male');
      expect(p.education, 'B.Tech');
      expect(p.profession, 'Engineer');
    });

    test('parses all optional fields', () {
      final p = ProfileModel.fromJson(_baseJson(overrides: {
        'email': 'test@test.com',
        'gotra': 'Kashyap',
        'date_of_birth': '2000-01-15T00:00:00Z',
        'complexion': 'Fair',
        'blood_group': 'B+',
        'marital_status': 'Divorced',
        'annual_income': '10-15 LPA',
        'state': 'Maharashtra',
        'district': 'Pune',
        'taluka': 'Haveli',
        'village': 'Wagholi',
        'phone_number': '9876543210',
        'permanent_location': 'Pune, MH',
        'native_place': 'Satara',
        'father_name': 'Suresh',
        'father_occupation': 'Farmer',
        'mother_name': 'Sunita',
        'mother_occupation': 'Homemaker',
        'siblings_count': 2,
        'sister_count': 1,
        'brother_count': 1,
        'family_type': 'Joint',
        'family_status': 'Middle Class',
        'birth_place': 'Pune',
        'birth_time': '10:30 AM',
        'education_details': 'IIT Bombay',
        'job_details': 'Software Dev',
        'company': 'Google',
        'marriage_readiness': 'Immediately',
        'about_self': 'Friendly person',
        'partner_expectations': 'Kind natured',
        'expectation': 'Caring spouse',
        'is_premium': true,
        'is_admin': true,
        'is_verified': true,
        'is_active': true,
        'is_pdf_unlocked': true,
        'trust_score': 85,
        'email_verified': true,
        'phone_verified': true,
        'is_bookmarked': true,
        'is_matched': true,
        'has_followed_instagram': true,
        'profile_created_by': 'Self',
        'is_disabled': false,
        'fcm_token': 'token123',
        'plan_type': 'gold',
      }));
      expect(p.email, 'test@test.com');
      expect(p.gotra, 'Kashyap');
      expect(p.complexion, 'Fair');
      expect(p.bloodGroup, 'B+');
      expect(p.maritalStatus, 'Divorced');
      expect(p.state, 'Maharashtra');
      expect(p.district, 'Pune');
      expect(p.fatherName, 'Suresh');
      expect(p.motherName, 'Sunita');
      expect(p.isPremium, true);
      expect(p.isAdmin, true);
      expect(p.isVerified, true);
      expect(p.trustScore, 85);
      expect(p.planType, PlanType.gold);
      expect(p.fcmToken, 'token123');
      expect(p.hasFollowedInstagram, true);
    });

    test('defaults work for missing fields', () {
      final p = ProfileModel.fromJson({});
      expect(p.id, '');
      expect(p.fullName, '');
      expect(p.age, 18);
      expect(p.gender, 'Female');
      expect(p.maritalStatus, 'Never Married');
      expect(p.isPremium, false);
      expect(p.isAdmin, false);
      expect(p.trustScore, 0);
      expect(p.planType, PlanType.free);
    });

    test('parses photos from JSON', () {
      final p = ProfileModel.fromJson(_baseJson(overrides: {
        'photos': [
          {'id': 'ph1', 'profile_id': 'p1', 'storage_path': '/photos/1.jpg', 'public_url': 'https://cdn.test/1.jpg', 'is_primary': true, 'is_approved': true, 'uploaded_at': '2025-01-01T00:00:00Z'}
        ],
      }));
      expect(p.photos.length, 1);
      expect(p.photos.first.publicUrl, 'https://cdn.test/1.jpg');
    });

    test('parses siblings_data', () {
      final p = ProfileModel.fromJson(_baseJson(overrides: {
        'siblings_data': [
          {'position': 1, 'relation': 'Brother', 'is_married': true},
          {'position': 2, 'relation': 'Sister', 'is_married': false},
        ],
      }));
      expect(p.siblings.length, 2);
      expect(p.siblings[0].relation, 'Brother');
      expect(p.siblings[1].isMarried, false);
    });

    test('handles invalid date with fallback', () {
      final p = ProfileModel.fromJson(_baseJson(overrides: {'created_at': 'invalid-date'}));
      expect(p.createdAt.year, DateTime.now().year);
    });
  });

  group('ProfileModel.toJson', () {
    test('round-trips through fromJson → toJson', () {
      final json = ProfileModel.fromJson(_baseJson()).toJson();
      expect(json['id'], 'p1');
      expect(json['full_name'], 'Rahul Patil');
      expect(json['plan_type'], 'free');
    });
  });

  group('ProfileModel.copyWith', () {
    test('copies with new values', () {
      final copy = ProfileModel.fromJson(_baseJson()).copyWith(fullName: 'Amit', age: 30, isPremium: true);
      expect(copy.fullName, 'Amit');
      expect(copy.age, 30);
      expect(copy.isPremium, true);
      expect(copy.id, 'p1');
    });
  });

  group('ProfileModel computed fields', () {
    test('maskedPhoneNumber masks last 5 digits', () {
      final p = ProfileModel.fromJson(_baseJson(overrides: {'phone_number': '9876543210'}));
      expect(p.maskedPhoneNumber, '98765*****');
    });

    test('maskedPhoneNumber handles short numbers', () {
      final p = ProfileModel.fromJson(_baseJson(overrides: {'phone_number': '123'}));
      expect(p.maskedPhoneNumber, '123');
    });

    test('maskedPhoneNumber handles null', () {
      expect(ProfileModel.fromJson(_baseJson()).maskedPhoneNumber, '');
    });

    test('formattedLocation builds Village, Taluka, District, State', () {
      final p = ProfileModel.fromJson(_baseJson(overrides: {'state': 'Maharashtra', 'district': 'Pune', 'taluka': 'Haveli', 'village': 'Wagholi'}));
      expect(p.formattedLocation, 'Wagholi, Haveli, Pune, Maharashtra');
    });

    test('formattedLocation falls back to permanentLocation', () {
      final p = ProfileModel.fromJson(_baseJson(overrides: {'permanent_location': 'Custom Address'}));
      expect(p.formattedLocation, 'Custom Address');
    });

    test('locationExcludingVillage excludes village', () {
      final p = ProfileModel.fromJson(_baseJson(overrides: {'state': 'MH', 'district': 'P', 'taluka': 'H', 'village': 'W'}));
      expect(p.locationExcludingVillage, 'H, P, MH');
    });

    test('formattedDOB returns formatted date', () {
      expect(ProfileModel.fromJson(_baseJson(overrides: {'date_of_birth': '2000-01-15'})).formattedDOB, '15 Jan 2000');
    });

    test('formattedDOB returns Not Entered when null', () {
      expect(ProfileModel.fromJson(_baseJson()).formattedDOB, 'Not Entered');
    });

    test('isEnriched returns true with photos', () {
      final p = ProfileModel.fromJson(_baseJson(overrides: {
        'photos': [{'id': 'ph1', 'profile_id': 'p1', 'storage_path': '/a', 'public_url': 'https://cdn/a', 'uploaded_at': '2025-01-01T00:00:00Z'}],
      }));
      expect(p.isEnriched, true);
    });

    test('isEnriched returns false with no photos and no match', () {
      expect(ProfileModel.fromJson(_baseJson()).isEnriched, false);
    });

    test('completionPercentage >= 60 when all required filled', () {
      final p = ProfileModel.fromJson(_baseJson(overrides: {
        'state': 'MH',
        'district': 'P',
        'taluka': 'H',
        'annual_income': '10 LPA',
        'about_self': 'Friendly person',
        'father_name': 'Suresh',
      }));
      expect(p.completionPercentage, greaterThanOrEqualTo(60));
    });

    test('completionPercentage < 60 when required fields missing', () {
      expect(ProfileModel.fromJson({}).completionPercentage, lessThan(60));
    });
  });

  group('ProfileModel.toDisplayMap', () {
    test('populates cache and returns map', () {
      final map = ProfileModel.fromJson(_baseJson(overrides: {'about_self': 'Hi'})).toDisplayMap();
      expect(map['name'], 'Rahul Patil');
      expect(map['about'], 'Hi');
    });

    test('returns cached result on second call', () {
      final p = ProfileModel.fromJson(_baseJson());
      expect(identical(p.toDisplayMap(), p.toDisplayMap()), true);
    });
  });

  group('PhotoModel', () {
    test('fromJson parses correctly', () {
      final photo = PhotoModel.fromJson({'id': 'ph1', 'profile_id': 'p1', 'storage_path': '/a', 'public_url': 'https://cdn/a', 'semantic_label': 'Profile', 'is_primary': false, 'is_approved': false, 'uploaded_at': '2025-06-01T00:00:00Z'});
      expect(photo.isPrimary, false);
      expect(photo.isApproved, false);
      expect(photo.semanticLabel, 'Profile');
    });

    test('toJson round-trips', () {
      final json = PhotoModel.fromJson({'id': 'ph1', 'profile_id': 'p1', 'storage_path': '/a', 'public_url': 'https://cdn/a', 'uploaded_at': '2025-06-01T00:00:00Z'}).toJson();
      expect(json['is_primary'], true);
    });

    test('defaults for missing fields', () {
      final photo = PhotoModel.fromJson({});
      expect(photo.isPrimary, true);
      expect(photo.isApproved, true);
    });
  });

  group('SiblingModel', () {
    test('fromJson parses correctly', () {
      final s = SiblingModel.fromJson({'position': 1, 'relation': 'Brother', 'is_married': true});
      expect(s.position, 1);
      expect(s.relation, 'Brother');
      expect(s.isMarried, true);
    });

    test('toJson round-trips', () {
      final json = SiblingModel.fromJson({'position': 2, 'relation': 'Sister', 'is_married': false}).toJson();
      expect(json['position'], 2);
      expect(json['relation'], 'Sister');
      expect(json['is_married'], false);
    });

    test('defaults for missing fields', () {
      final s = SiblingModel.fromJson({});
      expect(s.position, 1);
      expect(s.relation, 'Self');
      expect(s.isMarried, false);
    });
  });
}
