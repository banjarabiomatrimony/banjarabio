import 'package:flutter_test/flutter_test.dart';
import 'package:banjarabio/core/services/profile_display_policy.dart';
import 'package:banjarabio/core/models/profile_model.dart';
import 'package:banjarabio/core/models/subscription_model.dart';

void main() {
  ProfileModel createTestProfile({
    required String id,
    required String userId,
    required String fullName,
    required String surname,
    required String gender,
    required int age,
    String? gotra,
    String education = 'B.Tech',
    String? educationDetails,
    String profession = 'Software Engineer',
    PlanType planType = PlanType.free,
    bool isPremium = false,
    bool isVerified = false,
    bool isCommunityTrusted = false,
    String? phoneNumber,
    String? email,
    bool phoneVerified = false,
    bool emailVerified = false,
    List<PhotoModel> photos = const [],
    String? state,
    String? district,
    int profileCompletion = 0,
    int trustScore = 0,
  }) {
    return ProfileModel(
      id: id,
      userId: userId,
      fullName: fullName,
      surname: surname,
      gotra: gotra,
      gender: gender,
      age: age,
      height: "5'7\"",
      education: education,
      educationDetails: educationDetails,
      profession: profession,
      planType: planType,
      isPremium: isPremium,
      isVerified: isVerified,
      isCommunityTrusted: isCommunityTrusted,
      phoneNumber: phoneNumber,
      email: email,
      phoneVerified: phoneVerified,
      emailVerified: emailVerified,
      photos: photos,
      state: state,
      district: district,
      profileCompletion: profileCompletion,
      trustScore: trustScore,
      createdAt: DateTime(2026),
      updatedAt: DateTime(2026),
    );
  }

  group('ProfileDisplayPolicy Tests', () {
    test('Gender-Aware Display Name formats female vs male names', () {
      final femaleProfile = createTestProfile(
        id: 'user_f1',
        userId: 'auth_f1',
        fullName: 'Pooja Vijay Rathod',
        surname: 'Rathod',
        gender: 'Female',
        age: 24,
      );

      final maleProfile = createTestProfile(
        id: 'user_m1',
        userId: 'auth_m1',
        fullName: 'Rahul Vijay Rathod',
        surname: 'Rathod',
        gender: 'Male',
        age: 27,
      );

      expect(ProfileDisplayPolicy.getDisplayName(femaleProfile), equals('Pooja'));
      expect(ProfileDisplayPolicy.getDisplayName(maleProfile), equals('Rahul Vijay Rathod'));
    });

    test('3-Tier Gotra Display Info resolves correctly for free vs bvs vs premium', () {
      final profile = createTestProfile(
        id: 'user_g1',
        userId: 'auth_g1',
        fullName: 'Rahul Rathod',
        surname: 'Rathod',
        gotra: 'Rathod - Karamtoth',
        gender: 'Male',
        age: 26,
      );

      // Free user view
      final freeGotra = ProfileDisplayPolicy.getGotraInfo(profile);
      expect(freeGotra.isLocked, isTrue);
      expect(freeGotra.formattedText, equals('🔒 Premium'));

      // BVS subsidized plan view
      final bvsGotra = ProfileDisplayPolicy.getGotraInfo(profile, viewerPlan: PlanType.mass_market);
      expect(bvsGotra.isPartiallyLocked, isTrue);
      expect(bvsGotra.formattedText, equals('Rathod - 🔒 Premium'));

      // Premium view
      final goldGotra = ProfileDisplayPolicy.getGotraInfo(profile, viewerPlan: PlanType.gold);
      expect(goldGotra.isLocked, isFalse);
      expect(goldGotra.isPartiallyLocked, isFalse);
      expect(goldGotra.formattedText, equals('Rathod - Karamtoth'));
    });

    test('getFormattedEducation categorizes degrees and handles pursuing vs completed', () {
      final profileUg = createTestProfile(
        id: 'user_edu1',
        userId: 'auth_edu1',
        fullName: 'Kiran',
        surname: 'Jadhav',
        gender: 'Female',
        age: 23,
        education: 'B.Tech Computer Science',
      );

      final profilePg = createTestProfile(
        id: 'user_edu2',
        userId: 'auth_edu2',
        fullName: 'Sunil',
        surname: 'Chavan',
        gender: 'Male',
        age: 28,
        education: 'MBA Marketing',
      );

      final profilePursuing = createTestProfile(
        id: 'user_edu3',
        userId: 'auth_edu3',
        fullName: 'Anita',
        surname: 'Pawar',
        gender: 'Female',
        age: 21,
        education: 'Pursuing MBBS',
      );

      expect(ProfileDisplayPolicy.getFormattedEducation(profileUg), equals('Completed - Graduate (UG)'));
      expect(ProfileDisplayPolicy.getFormattedEducation(profilePg), equals('Completed - Post Graduate (PG)'));
      expect(ProfileDisplayPolicy.getFormattedEducation(profilePursuing), equals('Under - Graduate (UG)'));
    });

    test('getCandidateSubscriptionBadge returns proper badge for VIP, Gold, and Silver', () {
      final vipProfile = createTestProfile(
        id: 'user_vip',
        userId: 'auth_vip',
        fullName: 'Vip Member',
        surname: 'Rathod',
        gender: 'Male',
        age: 30,
        planType: PlanType.vip,
      );

      final goldProfile = createTestProfile(
        id: 'user_gold',
        userId: 'auth_gold',
        fullName: 'Gold Member',
        surname: 'Jadhav',
        gender: 'Female',
        age: 25,
        planType: PlanType.gold,
      );

      final freeProfile = createTestProfile(
        id: 'user_free',
        userId: 'auth_free',
        fullName: 'Free Member',
        surname: 'Pawar',
        gender: 'Male',
        age: 28,
      );

      expect(ProfileDisplayPolicy.getCandidateSubscriptionBadge(vipProfile)?.label, equals('VIP'));
      expect(ProfileDisplayPolicy.getCandidateSubscriptionBadge(goldProfile)?.label, equals('GOLD'));
      expect(ProfileDisplayPolicy.getCandidateSubscriptionBadge(freeProfile), isNull);
    });

    test('Dynamic Completion and Trust Score calculations', () {
      final fullProfile = createTestProfile(
        id: 'user_full',
        userId: 'auth_full',
        fullName: 'Rahul Rathod',
        surname: 'Rathod',
        gotra: 'Rathod',
        phoneNumber: '9876543210',
        email: 'test@example.com',
        phoneVerified: true,
        emailVerified: true,
        isVerified: true,
        isCommunityTrusted: true,
        gender: 'Male',
        age: 27,
        photos: [
          PhotoModel(
            id: 'photo_1',
            profileId: 'user_full',
            storagePath: 'photos/photo_1.jpg',
            publicUrl: 'https://example.com/photo_1.jpg',
            uploadedAt: DateTime(2026),
          ),
        ],
        state: 'Maharashtra',
        district: 'Pune',
      );

      final completion = ProfileDisplayPolicy.getCompletionPercentage(fullProfile);
      expect(completion, greaterThanOrEqualTo(50));
      expect(ProfileDisplayPolicy.getProfileCompletionLabel(fullProfile), contains('% Bio Complete'));

      final trustScore = ProfileDisplayPolicy.getDynamicTrustScore(fullProfile);
      expect(trustScore, greaterThanOrEqualTo(60));
    });
  });
}
