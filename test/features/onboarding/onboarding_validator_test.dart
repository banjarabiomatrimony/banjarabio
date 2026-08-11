import 'package:flutter_test/flutter_test.dart';
import 'package:banjarabio/core/utils/onboarding_validator.dart';
import 'package:banjarabio/presentation/biodata_creation_screen/models/creation_step_config.dart';

void main() {
  group('OnboardingValidator Tests', () {
    group('Personal Details (Full Mode)', () {
      test('should return all missing fields when form is empty', () {
        final result = OnboardingValidator.getMissingFields(
          step: CreationStep.personal,
          formData: {},
        );

        expect(result, containsAll(['name', 'surname', 'gender', 'height']));
      });

      test('should require gotra only for specific surnames', () {
        // Rathod requires gotra
        final rathodResult = OnboardingValidator.getMissingFields(
          step: CreationStep.personal,
          formData: {
            'name': 'Rahul',
            'age': '28',
            'surname': 'Rathod',
            'gender': 'Male',
            'height': "5'8\"",
            'gotra': '', // Missing
          },
        );
        expect(rathodResult, contains('gotra'));

        // Ade requires gotra
        final adeResult = OnboardingValidator.getMissingFields(
          step: CreationStep.personal,
          formData: {
            'name': 'Rahul',
            'surname': 'Ade',
            'gotra': '', // Missing
          },
        );
        expect(adeResult, contains('gotra'));

        // Other surname does NOT require gotra (e.g. Bangar)
        final otherResult = OnboardingValidator.getMissingFields(
          step: CreationStep.personal,
          formData: {
            'name': 'Rahul',
            'age': '28',
            'surname': 'Bangar',
            'gender': 'Male',
            'height': "5'8\"",
            'gotra': '', // Missing but not required for this surname
          },
        );
        expect(otherResult, isNot(contains('gotra')));
      });

      test('should return empty list when all personal details are present', () {
        final result = OnboardingValidator.getMissingFields(
          step: CreationStep.personal,
          formData: {
            'name': 'Rahul',
            'phone_number': '1234567890',
            'age': '28',
            'surname': 'Pawar',
            'gotra': 'Pawar',
            'gender': 'Male',
            'height': "5'8\"",
          },
        );

        expect(result, isEmpty);
      });
    });

    group('Education & Profession', () {
      test('should return missing education fields', () {
        final result = OnboardingValidator.getMissingFields(
          step: CreationStep.education,
          formData: {},
        );

        expect(result, containsAll(['education', 'profession', 'annualIncome']));
      });

      test('should pass when all education fields are present', () {
        final result = OnboardingValidator.getMissingFields(
          step: CreationStep.education,
          formData: {
            'education': 'BE',
            'profession': 'Engineer',
            'annualIncome': '10 LPA',
          },
        );

        expect(result, isEmpty);
      });
    });

    group('Photos', () {
      test('should require at least one photo', () {
        expect(
          OnboardingValidator.getMissingFields(step: CreationStep.photo, formData: {}),
          contains('photos'),
        );
        expect(
          OnboardingValidator.getMissingFields(step: CreationStep.photo, formData: {'photos': []}),
          contains('photos'),
        );
      });

      test('should pass when photos are present', () {
        expect(
          OnboardingValidator.getMissingFields(
            step: CreationStep.photo, 
            formData: {'photos': ['url1']},
          ),
          isEmpty,
        );
      });
    });

    group('Location (Full Mode)', () {
      test('should require state and district', () {
        final result = OnboardingValidator.getMissingFields(
          step: CreationStep.location,
          formData: {},
        );

        expect(result, containsAll(['state', 'district']));
      });

      test('should pass when location details are present', () {
        final result = OnboardingValidator.getMissingFields(
          step: CreationStep.location,
          formData: {
            'state': 'Maharashtra',
            'district': 'Pune',
          },
        );

        expect(result, isEmpty);
      });
    });

    group('Lite Mode Behavior', () {
      test('lite mode personal step skips height requirement', () {
        final result = OnboardingValidator.getMissingFields(
          step: CreationStep.personal,
          formData: {
            'name': 'Test',
            'phone_number': '9876543210',
            'surname': 'Rathod',
            'gotra': 'Chauhan',
            'gender': 'Male',
          },
          isLite: true,
        );
        expect(result, isNot(contains('height')));
        expect(result, isEmpty);
      });

      test('lite mode location step skips district requirement', () {
        final result = OnboardingValidator.getMissingFields(
          step: CreationStep.location,
          formData: {'state': 'Maharashtra'},
          isLite: true,
        );
        expect(result, isNot(contains('district')));
        expect(result, isEmpty);
      });
    });
  });
}
