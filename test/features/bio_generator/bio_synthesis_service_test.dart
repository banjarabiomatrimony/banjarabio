import 'dart:math';
import 'package:flutter_test/flutter_test.dart';
import 'package:banjarabio/core/services/bio_synthesis_service.dart';

void main() {
  late BioSynthesisService bioService;

  setUp(() {
    // Use a fixed seed for deterministic results in tests
    bioService = BioSynthesisService(random: Random(42));
  });

  group('BioSynthesisService - Free Tier', () {
    test('generates a bio with essential professional details', () {
      final data = {
        'profession': 'Software Engineer',
        'education': 'B.Tech',
        'state': 'Maharashtra',
        'district': 'Pune',
        'gender': 'Male',
      };

      final bio = bioService.generateBio(data: data, isPremium: false);

      expect(bio, contains('Software Engineer'));
      expect(bio, contains('B.Tech'));
      expect(bio, contains('Pune'));
      expect(bio, contains('Maharashtra'));
      expect(bio, contains('man'));
    });

    test('uses fallback values for missing data', () {
      final data = <String, dynamic>{};

      final bio = bioService.generateBio(data: data, isPremium: false);

      expect(bio, contains('Professional'));
      expect(bio, contains('Qualified'));
      expect(bio, contains('City'));
    });
  });

  group('BioSynthesisService - Premium Tier', () {
    test('generates a high-quality narrative bio', () {
      final data = {
        'name': 'Rahul',
        'age': '28',
        'profession': 'Doctor',
        'education': 'MBBS',
        'state': 'Karnataka',
        'district': 'Bangalore',
        'familyType': 'Joint',
        'maritalStatus': 'Never Married',
        'gender': 'Male',
      };

      final bio = bioService.generateBio(data: data, isPremium: true);

      expect(bio, contains('Rahul'));
      expect(bio, contains('Doctor'));
      expect(bio, contains('MBBS'));
      expect(bio, contains('Joint family'));
      expect(bio, contains('Never Married'.toLowerCase()));
      // Premium bio is longer (contains 4 sections)
      expect(bio.split('. ').length, greaterThanOrEqualTo(3));
    });

    test('handles female gender correctly in narrative', () {
      final data = {
        'name': 'Priya',
        'gender': 'Female',
        'familyType': 'Nuclear',
      };

      final bio = bioService.generateBio(data: data, isPremium: true);

      expect(bio, contains('lady'));
      // Expect either "She" or "her" or the gendered noun to be present
      expect(
        bio.contains('She') || bio.contains('her') || bio.contains('lady'),
        isTrue,
        reason: 'Bio should contain female-specific pronouns or nouns',
      );
    });
  });
}
