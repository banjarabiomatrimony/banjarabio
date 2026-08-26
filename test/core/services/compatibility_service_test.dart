import 'package:flutter_test/flutter_test.dart';
import 'package:banjarabio/core/services/compatibility_service.dart';
import 'package:banjarabio/core/models/profile_model.dart';

void main() {
  ProfileModel createTestProfile({
    required String id,
    required String userId,
    required String fullName,
    required String surname,
    required String gender,
    required int age,
    String? state,
    String? district,
    String education = 'B.Tech',
    String profession = 'Software Engineer',
    String maritalStatus = 'Never Married',
  }) {
    return ProfileModel(
      id: id,
      userId: userId,
      fullName: fullName,
      surname: surname,
      gender: gender,
      age: age,
      height: "5'8\"",
      state: state,
      district: district,
      education: education,
      profession: profession,
      maritalStatus: maritalStatus,
      createdAt: DateTime(2026),
      updatedAt: DateTime(2026),
    );
  }

  group('CompatibilityService Tests', () {
    test('returns 0 score for same gender profiles', () {
      final p1 = createTestProfile(
        id: 'u1',
        userId: 'auth_u1',
        fullName: 'Rahul',
        surname: 'Rathod',
        gender: 'Male',
        age: 26,
      );
      final p2 = createTestProfile(
        id: 'u2',
        userId: 'auth_u2',
        fullName: 'Sunil',
        surname: 'Jadhav',
        gender: 'Male',
        age: 27,
      );

      final score = CompatibilityService.calculateMatchingScore(p1, p2);
      expect(score, equals(0));
    });

    test('calculates high compatibility for close age, same location and education', () {
      final groom = createTestProfile(
        id: 'u_groom',
        userId: 'auth_groom',
        fullName: 'Rahul Rathod',
        surname: 'Rathod',
        gender: 'Male',
        age: 27,
        state: 'Maharashtra',
        district: 'Nanded',
      );

      final bride = createTestProfile(
        id: 'u_bride',
        userId: 'auth_bride',
        fullName: 'Pooja Jadhav',
        surname: 'Jadhav',
        gender: 'Female',
        age: 25,
        state: 'Maharashtra',
        district: 'Nanded',
        profession: 'IT Specialist',
      );

      final score = CompatibilityService.calculateMatchingScore(groom, bride);
      expect(score, greaterThanOrEqualTo(80));
    });
  });
}
