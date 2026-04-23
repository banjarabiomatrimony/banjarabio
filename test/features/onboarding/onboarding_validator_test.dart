import 'package:flutter_test/flutter_test.dart';
import 'package:banjarabio/core/utils/onboarding_validator.dart';

void main() {
  group('OnboardingValidator Tests', () {
    group('Step 0: Personal Details', () {
      test('should return all missing fields when form is empty', () {
        final result = OnboardingValidator.getMissingFields(
          step: 0,
          formData: {},
        );

        expect(result, containsAll(['name', 'age', 'surname', 'gender', 'height']));
      });

      test('should require gotra only for specific surnames', () {
        // Rathod requires gotra
        final rathodResult = OnboardingValidator.getMissingFields(
          step: 0,
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
          step: 0,
          formData: {
            'name': 'Rahul',
            'surname': 'Ade',
            'gotra': '', // Missing
          },
        );
        expect(adeResult, contains('gotra'));

        // Other surname does NOT require gotra (e.g. Bangar)
        final otherResult = OnboardingValidator.getMissingFields(
          step: 0,
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
          step: 0,
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

    group('Step 2: Education & Profession', () {
      test('should return missing education fields', () {
        final result = OnboardingValidator.getMissingFields(
          step: 2,
          formData: {},
        );

        expect(result, containsAll(['education', 'profession', 'annualIncome']));
      });

      test('should pass when all education fields are present', () {
        final result = OnboardingValidator.getMissingFields(
          step: 2,
          formData: {
            'education': 'BE',
            'profession': 'Engineer',
            'annualIncome': '10 LPA',
          },
        );

        expect(result, isEmpty);
      });
    });

    group('Step 3: Photos', () {
      test('should require at least one photo', () {
        expect(
          OnboardingValidator.getMissingFields(step: 3, formData: {}),
          contains('photos'),
        );
        expect(
          OnboardingValidator.getMissingFields(step: 3, formData: {'photos': []}),
          contains('photos'),
        );
      });

      test('should pass when photos are present', () {
        expect(
          OnboardingValidator.getMissingFields(
            step: 3, 
            formData: {'photos': ['url1']},
          ),
          isEmpty,
        );
      });
    });

    group('Step 4: Location', () {
      test('should require state and district', () {
        final result = OnboardingValidator.getMissingFields(
          step: 4,
          formData: {},
        );

        expect(result, containsAll(['state', 'district']));
      });

      test('should pass when location details are present', () {
        final result = OnboardingValidator.getMissingFields(
          step: 4,
          formData: {
            'state': 'Maharashtra',
            'district': 'Pune',
          },
        );

        expect(result, isEmpty);
      });
    });
  });
}
