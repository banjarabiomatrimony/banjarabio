import 'package:flutter_test/flutter_test.dart';
import 'package:banjarabio/core/models/profile_model.dart';
import 'package:banjarabio/core/services/compatibility_service.dart';

void main() {
  group('CompatibilityService Tests', () {
    final now = DateTime.now();
    
    final myProfile = ProfileModel(
      id: 'me',
      userId: 'my-user',
      fullName: 'John Doe',
      surname: 'Rathod',
      age: 28,
      gender: 'Male',
      height: "5'10\"",
      education: 'B.Tech',
      profession: 'Software Engineer',
      state: 'Maharashtra',
      district: 'Pune',
      createdAt: now,
      updatedAt: now,
    );

    final perfectMatch = ProfileModel(
      id: 'them-1',
      userId: 'user-1',
      fullName: 'Jane Doe',
      surname: 'Pawar',
      age: 26, // within 5 years
      gender: 'Female',
      height: "5'5\"",
      education: 'B.Tech', // same
      profession: 'Software Engineer', // same
      state: 'Maharashtra',
      district: 'Pune', // same
      createdAt: now,
      updatedAt: now,
    );

    final partialMatch = ProfileModel(
      id: 'them-2',
      userId: 'user-2',
      fullName: 'Sara Smith',
      surname: 'Chavan',
      age: 35, // > 5 years difference
      gender: 'Female',
      height: "5'4\"",
      education: 'M.Com', // different
      profession: 'Accountant', // different
      state: 'Maharashtra', // same state
      district: 'Mumbai', // different district
      maritalStatus: 'Divorced', // different
      createdAt: now,
      updatedAt: now,
    );

    test('should return 100% for an ideal match', () {
      final score = CompatibilityService.calculateMatchingScore(myProfile, perfectMatch);
      expect(score, 100);
    });

    test('should return 0% if genders are the same', () {
      final sameGender = perfectMatch.copyWith(gender: 'Male');
      final score = CompatibilityService.calculateMatchingScore(myProfile, sameGender);
      expect(score, 0);
    });

    test('should calculate lower score for partial match', () {
      final score = CompatibilityService.calculateMatchingScore(myProfile, partialMatch);
      // Age 35 vs 28 = Diff 7 (15 pts)
      // Maharashtra vs Maharashtra (15 pts)
      // Education/Profession different (0 pts)
      // Marital different (0 pts)
      // Total = 30
      expect(score, 30);
    });

    test('should provide bonus for similar professions', () {
      final itProfessional = perfectMatch.copyWith(
        profession: 'IT Specialist',
        education: 'MCA',
        district: 'Nagpur',
      );
      final score = CompatibilityService.calculateMatchingScore(myProfile, itProfessional);
      // Age (25) + State (15) + Profession Similarity (5) + Marital (20) = 65
      expect(score, 65);
    });

    test('should handle null geographic data gracefully', () {
      final noLocation = ProfileModel(
        id: 'no-loc',
        userId: 'no-loc-user',
        gender: 'Female',
        fullName: 'No Loc',
        surname: 'User',
        height: "5'5\"",
        age: 26,
        education: 'B.Tech',
        profession: 'Software Engineer',
        createdAt: now,
        updatedAt: now,
      );
      final score = CompatibilityService.calculateMatchingScore(myProfile, noLocation);
      // Age (25) + Location (0) + Education (15) + Profession (10) + Marital (20) = 70
      expect(score, 70);
    });
  });
}
