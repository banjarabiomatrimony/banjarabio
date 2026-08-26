import 'dart:math';
import 'package:flutter_test/flutter_test.dart';
import 'package:banjarabio/core/services/bio_synthesis_service.dart';

void main() {
  group('BioSynthesisService Tests', () {
    test('generateBio builds free template bio with user attributes', () {
      final service = BioSynthesisService(random: Random(42));
      final bio = service.generateBio(
        data: {
          'name': 'Pooja',
          'profession': 'Software Engineer',
          'education': 'B.Tech',
          'state': 'Maharashtra',
          'district': 'Pune',
          'gender': 'Female',
        },
        isPremium: false,
      );

      expect(bio, isNotEmpty);
      expect(bio, contains('Pooja'));
      expect(bio, contains('Software Engineer'));
    });

    test('generateBio builds premium AI bio with rich narrative', () {
      final service = BioSynthesisService(random: Random(42));
      final bio = service.generateBio(
        data: {
          'name': 'Rahul',
          'age': '27',
          'profession': 'Doctor',
          'education': 'MBBS',
          'state': 'Maharashtra',
          'district': 'Mumbai',
          'familyType': 'Nuclear',
          'maritalStatus': 'Never Married',
          'gender': 'Male',
        },
        isPremium: true,
      );

      expect(bio, isNotEmpty);
      expect(bio, contains('Rahul'));
      expect(bio, contains('Doctor'));
    });
  });
}
