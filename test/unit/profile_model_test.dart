import 'package:flutter_test/flutter_test.dart';
import 'package:banjarabio/core/models/profile_model.dart';
import 'package:banjarabio/core/models/subscription_model.dart';
import '../helpers/test_data_factory.dart';

void main() {
  group('ProfileModel.fromJson', () {
    test('maps all core fields from Supabase JSON', () {
      final json = {
        'id': 'p-001',
        'user_id': 'u-001',
        'full_name': 'Priya',
        'surname': 'Pawar',
        'gotra': 'Chauhan',
        'age': 24,
        'gender': 'Female',
        'height': "5'4\"",
        'complexion': 'Fair',
        'blood_group': 'B+',
        'marital_status': 'Never Married',
        'education': 'MBBS',
        'profession': 'Doctor',
        'annual_income': '10L-15L',
        'state': 'Maharashtra',
        'district': 'Pune',
        'taluka': 'Haveli',
        'village': 'Khed',
        'phone_number': '9876543210',
        'father_name': 'Vikram Pawar',
        'mother_name': 'Sunita Pawar',
        'about_self': 'Focused individual',
        'is_premium': true,
        'is_admin': false,
        'trust_score': 75,
        'plan_type': 'gold',
        'created_at': '2025-01-15T10:00:00.000Z',
        'updated_at': '2025-06-10T08:00:00.000Z',
      };

      final profile = ProfileModel.fromJson(json);

      expect(profile.id, 'p-001');
      expect(profile.userId, 'u-001');
      expect(profile.fullName, 'Priya');
      expect(profile.surname, 'Pawar');
      expect(profile.gotra, 'Chauhan');
      expect(profile.age, 24);
      expect(profile.gender, 'Female');
      expect(profile.complexion, 'Fair');
      expect(profile.bloodGroup, 'B+');
      expect(profile.education, 'MBBS');
      expect(profile.profession, 'Doctor');
      expect(profile.annualIncome, '10L-15L');
      expect(profile.state, 'Maharashtra');
      expect(profile.district, 'Pune');
      expect(profile.taluka, 'Haveli');
      expect(profile.village, 'Khed');
      expect(profile.phoneNumber, '9876543210');
      expect(profile.fatherName, 'Vikram Pawar');
      expect(profile.motherName, 'Sunita Pawar');
      expect(profile.aboutSelf, 'Focused individual');
      expect(profile.isPremium, true);
      expect(profile.isAdmin, false);
      expect(profile.trustScore, 75);
      expect(profile.planType, PlanType.gold);
    });

    test('handles null/missing fields with defaults', () {
      final json = <String, dynamic>{
        'id': 'p-002',
        'user_id': 'u-002',
      };

      final profile = ProfileModel.fromJson(json);

      expect(profile.fullName, '');
      expect(profile.surname, '');
      expect(profile.age, 18);
      expect(profile.gender, 'Female'); // default
      expect(profile.height, "5'5\""); // default
      expect(profile.maritalStatus, 'Never Married');
      expect(profile.isPremium, false);
      expect(profile.trustScore, 0);
      expect(profile.planType, PlanType.free);
      expect(profile.photos, isEmpty);
      expect(profile.siblings, isEmpty);
    });

    test('parses photos array', () {
      final json = {
        ...TestData.profileJson(),
        'photos': [
          {
            'id': 'photo-1',
            'profile_id': 'p-001',
            'storage_path': 'photos/1.jpg',
            'public_url': 'https://cdn.example.com/1.jpg',
            'is_primary': true,
            'is_approved': true,
            'uploaded_at': '2025-01-01T00:00:00.000Z',
          },
        ],
      };

      final profile = ProfileModel.fromJson(json);
      expect(profile.photos, hasLength(1));
      expect(profile.photos.first.publicUrl, 'https://cdn.example.com/1.jpg');
      expect(profile.photos.first.isPrimary, true);
    });
  });

  group('ProfileModel.toJson', () {
    test('round-trip: fromJson(toJson) preserves core fields', () {
      final original = TestData.profile(
        state: 'Maharashtra',
        district: 'Nagpur',
        taluka: 'Umred',
        village: 'Khed',
        aboutSelf: 'Hello',
        fatherName: 'Papa',
        motherName: 'Mama',
      );

      final json = original.toJson();
      final restored = ProfileModel.fromJson(json);

      expect(restored.id, original.id);
      expect(restored.fullName, original.fullName);
      expect(restored.surname, original.surname);
      expect(restored.age, original.age);
      expect(restored.gender, original.gender);
      expect(restored.state, original.state);
      expect(restored.district, original.district);
      expect(restored.fatherName, original.fatherName);
    });
  });

  group('ProfileModel.copyWith', () {
    test('overrides specific fields, keeps rest intact', () {
      final original = TestData.profile();
      final modified = original.copyWith(
        fullName: 'Vikram',
        age: 30,
        isPremium: true,
      );

      expect(modified.fullName, 'Vikram');
      expect(modified.age, 30);
      expect(modified.isPremium, true);
      // Unchanged
      expect(modified.surname, original.surname);
      expect(modified.id, original.id);
      expect(modified.gender, original.gender);
    });
  });

  group('ProfileModel.formattedLocation', () {
    test('concatenates village, taluka, district, state', () {
      final profile = TestData.profile(
        village: 'Khed',
        taluka: 'Haveli',
        district: 'Pune',
        state: 'Maharashtra',
      );
      expect(profile.formattedLocation, 'Khed, Haveli, Pune, Maharashtra');
    });

    test('skips null parts', () {
      final profile = TestData.profile(
        district: 'Pune',
        state: 'Maharashtra',
      );
      expect(profile.formattedLocation, 'Pune, Maharashtra');
    });

    test('falls back to permanentLocation when all parts null', () {
      final profile = ProfileModel(
        id: 'id',
        userId: 'uid',
        fullName: 'Test',
        surname: 'User',
        age: 25,
        gender: 'Male',
        height: "5'5\"",
        education: 'Grad',
        profession: 'Dev',
        permanentLocation: 'Some Manual Address',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      expect(profile.formattedLocation, 'Some Manual Address');
    });
  });

  group('ProfileModel.locationExcludingVillage', () {
    test('excludes village from formatted location', () {
      final profile = TestData.profile(
        village: 'Khed',
        taluka: 'Haveli',
        district: 'Pune',
        state: 'Maharashtra',
      );
      expect(profile.locationExcludingVillage, 'Haveli, Pune, Maharashtra');
    });
  });

  group('ProfileModel.maskedPhoneNumber', () {
    test('masks last 5 digits of 10-digit number', () {
      final profile = TestData.profile(phoneNumber: '9876543210');
      expect(profile.maskedPhoneNumber, '98765*****');
    });

    test('returns full number when 5 or fewer digits', () {
      final profile = TestData.profile(phoneNumber: '12345');
      expect(profile.maskedPhoneNumber, '12345');
    });

    test('returns empty for null phone', () {
      final profile = TestData.profile();
      expect(profile.maskedPhoneNumber, '');
    });
  });

  group('ProfileModel.formattedDOB', () {
    test('formats date as DD MMM YYYY', () {
      final profile = TestData.profile(
        dateOfBirth: DateTime(2000, 3, 15),
      );
      expect(profile.formattedDOB, '15 Mar 2000');
    });

    test('returns Not Entered when null', () {
      final profile = TestData.profile();
      expect(profile.formattedDOB, 'Not Entered');
    });
  });

  group('ProfileModel.displayId', () {
    test('BBM prefix for Male', () {
      final profile = TestData.profile();
      expect(profile.displayId, startsWith('BBM-'));
    });

    test('BBF prefix for Female', () {
      final profile = TestData.profile(gender: 'Female');
      expect(profile.displayId, startsWith('BBF-'));
    });

    test('BB prefix for Other', () {
      final profile = TestData.profile(gender: 'Other');
      expect(profile.displayId, startsWith('BB-'));
    });
  });

  group('PhotoModel', () {
    test('fromJson parses all fields', () {
      final json = {
        'id': 'photo-1',
        'profile_id': 'p-001',
        'storage_path': 'photos/1.jpg',
        'public_url': 'https://cdn.example.com/1.jpg',
        'semantic_label': 'Profile photo',
        'is_primary': true,
        'is_approved': false,
        'uploaded_at': '2025-01-01T00:00:00.000Z',
      };

      final photo = PhotoModel.fromJson(json);
      expect(photo.id, 'photo-1');
      expect(photo.publicUrl, 'https://cdn.example.com/1.jpg');
      expect(photo.semanticLabel, 'Profile photo');
      expect(photo.isPrimary, true);
      expect(photo.isApproved, false);
    });

    test('toJson round-trip', () {
      final photo = PhotoModel(
        id: 'p1',
        profileId: 'prof1',
        storagePath: 'path/to/img',
        publicUrl: 'https://example.com/img.jpg',
        uploadedAt: DateTime(2025),
      );

      final json = photo.toJson();
      expect(json['id'], 'p1');
      expect(json['public_url'], 'https://example.com/img.jpg');
      expect(json['is_primary'], true);
    });
  });
}
