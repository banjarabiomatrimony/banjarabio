import 'package:flutter_test/flutter_test.dart';
import 'package:banjarabio/core/utils/onboarding_validator.dart';

void main() {
  group('OnboardingValidator Step 0 — Personal Details', () {
    test('empty form returns all required fields', () {
      final missing = OnboardingValidator.getMissingFields(
        step: 0,
        formData: {},
      );
      expect(missing, containsAll(['name', 'phone_number', 'age', 'surname', 'gender', 'height']));
    });

    test('complete form returns no missing fields', () {
      final missing = OnboardingValidator.getMissingFields(
        step: 0,
        formData: {
          'name': 'Rahul',
          'phone_number': '9876543210',
          'age': '25',
          'surname': 'Rathod',
          'gotra': 'Chauhan', // Required for Rathod
          'gender': 'Male',
          'height': "5'10\"",
        },
      );
      expect(missing, isEmpty);
    });

    test('Rathod surname requires gotra', () {
      final missing = OnboardingValidator.getMissingFields(
        step: 0,
        formData: {
          'name': 'Rahul',
          'phone_number': '9876543210',
          'age': '25',
          'surname': 'Rathod',
          // gotra missing
          'gender': 'Male',
          'height': "5'10\"",
        },
      );
      expect(missing, contains('gotra'));
    });

    test('Pawar surname requires gotra', () {
      final missing = OnboardingValidator.getMissingFields(
        step: 0,
        formData: {
          'name': 'Test',
          'phone_number': '9876543210',
          'age': '25',
          'surname': 'Pawar',
          'gender': 'Male',
          'height': "5'10\"",
        },
      );
      expect(missing, contains('gotra'));
    });

    test('non-Banjara surname does NOT require gotra', () {
      final missing = OnboardingValidator.getMissingFields(
        step: 0,
        formData: {
          'name': 'Test',
          'phone_number': '9876543210',
          'age': '25',
          'surname': 'Sharma', // Not in Banjara list
          'gender': 'Female',
          'height': "5'4\"",
        },
      );
      expect(missing, isNot(contains('gotra')));
    });
  });

  group('OnboardingValidator Step 1 — Family Details', () {
    test('no fields required (optional step)', () {
      final missing = OnboardingValidator.getMissingFields(
        step: 1,
        formData: {},
      );
      expect(missing, isEmpty);
    });
  });

  group('OnboardingValidator Step 2 — Education & Profession', () {
    test('empty form returns required fields', () {
      final missing = OnboardingValidator.getMissingFields(
        step: 2,
        formData: {},
      );
      expect(missing, containsAll(['education', 'profession', 'annualIncome']));
    });

    test('complete form has no missing fields', () {
      final missing = OnboardingValidator.getMissingFields(
        step: 2,
        formData: {
          'education': 'B.Tech',
          'profession': 'Engineer',
          'annualIncome': '5L-10L',
        },
      );
      expect(missing, isEmpty);
    });
  });

  group('OnboardingValidator Step 3 — Photos', () {
    test('no photos = missing', () {
      final missing = OnboardingValidator.getMissingFields(
        step: 3,
        formData: {'photos': []},
      );
      expect(missing, contains('photos'));
    });

    test('null photos = missing', () {
      final missing = OnboardingValidator.getMissingFields(
        step: 3,
        formData: {},
      );
      expect(missing, contains('photos'));
    });

    test('has photos = not missing', () {
      final missing = OnboardingValidator.getMissingFields(
        step: 3,
        formData: {
          'photos': ['photo1.jpg'],
        },
      );
      expect(missing, isEmpty);
    });
  });

  group('OnboardingValidator Step 4 — Location', () {
    test('missing state and district', () {
      final missing = OnboardingValidator.getMissingFields(
        step: 4,
        formData: {},
      );
      expect(missing, containsAll(['state', 'district']));
    });

    test('complete location has no missing', () {
      final missing = OnboardingValidator.getMissingFields(
        step: 4,
        formData: {
          'state': 'Maharashtra',
          'district': 'Nagpur',
        },
      );
      expect(missing, isEmpty);
    });
  });

  group('OnboardingValidator Step 5 — Verification', () {
    test('no fields required (optional step)', () {
      final missing = OnboardingValidator.getMissingFields(
        step: 5,
        formData: {},
      );
      expect(missing, isEmpty);
    });
  });
}
