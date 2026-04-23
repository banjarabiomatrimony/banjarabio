import 'package:flutter_test/flutter_test.dart';
import 'package:banjarabio/core/models/profile_model.dart';

void main() {
  group('ProfileModel DisplayId Tests', () {
    test('Should return BBM- for Male gender', () {
      final profile = ProfileModel(
        id: '12345678-abcd-efgh-ijkl-1234567890ab',
        userId: 'user1',
        fullName: 'John',
        surname: 'Doe',
        age: 25,
        gender: 'Male',
        height: "5'10\"",
        education: 'B.Tech',
        profession: 'Engineer',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      expect(profile.displayId, equals('BBM-12345678'));
    });

    test('Should return BBF- for Female gender', () {
      final profile = ProfileModel(
        id: '87654321-abcd-efgh-ijkl-1234567890ab',
        userId: 'user2',
        fullName: 'Jane',
        surname: 'Doe',
        age: 24,
        gender: 'Female',
        height: "5'4\"",
        education: 'MBBS',
        profession: 'Doctor',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      expect(profile.displayId, equals('BBF-87654321'));
    });

    test('Should return BB- for unknown or null gender', () {
      final profile = ProfileModel(
        id: 'abcdef12-abcd-efgh-ijkl-1234567890ab',
        userId: 'user3',
        fullName: 'Unknown',
        surname: 'User',
        age: 30,
        gender: 'Other',
        height: "5'6\"",
        education: 'None',
        profession: 'None',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      expect(profile.displayId, equals('BB-ABCDEF12'));
    });

    test('Should handle short IDs (though technically invalid UUIDs)', () {
      final profile = ProfileModel(
        id: 'code123',
        userId: 'user4',
        fullName: 'Short',
        surname: 'Id',
        age: 20,
        gender: 'Male',
        height: '5',
        education: 'N/A',
        profession: 'N/A',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      expect(profile.displayId, equals('BBM-CODE123'));
    });
  });
}
