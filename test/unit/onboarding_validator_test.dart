import 'package:flutter_test/flutter_test.dart';
import 'package:banjarabio/core/utils/onboarding_validator.dart';
import 'package:banjarabio/presentation/biodata_creation_screen/models/creation_step_config.dart';

void main() {
  group('OnboardingValidator — Personal Details (Full Mode)', () {
    test('empty form returns all required fields', () {
      final missing = OnboardingValidator.getMissingFields(
        step: CreationStep.personal,
        formData: {},
      );
      expect(missing, containsAll(['name', 'phone_number', 'surname', 'gender', 'height']));
    });

    test('complete form returns no missing fields', () {
      final missing = OnboardingValidator.getMissingFields(
        step: CreationStep.personal,
        formData: {
          'name': 'Rahul',
          'phone_number': '9876543210',
          'age': '25',
          'surname': 'Rathod',
          'gotra': 'Chauhan', // Required for Rathod
          'gender': 'Male',
          'height': "5'10\"",
          'profileCreatedBy': 'Self',
        },
      );
      expect(missing, isEmpty);
    });

    test('Rathod surname requires gotra', () {
      final missing = OnboardingValidator.getMissingFields(
        step: CreationStep.personal,
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
        step: CreationStep.personal,
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
        step: CreationStep.personal,
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

  group('OnboardingValidator — Personal Details (Lite Mode)', () {
    test('lite mode does NOT require height', () {
      final missing = OnboardingValidator.getMissingFields(
        step: CreationStep.personal,
        formData: {
          'name': 'Test',
          'phone_number': '9876543210',
          'surname': 'Rathod',
          'gotra': 'Chauhan',
          'gender': 'Male',
          // No height, no age
        },
        isLite: true,
      );
      expect(missing, isNot(contains('height')));
      expect(missing, isEmpty);
    });
  });

  group('OnboardingValidator — Family Details', () {
    test('no fields required (optional step)', () {
      final missing = OnboardingValidator.getMissingFields(
        step: CreationStep.family,
        formData: {},
      );
      expect(missing, isEmpty);
    });
  });

  group('OnboardingValidator — Education & Profession', () {
    test('empty form returns required fields', () {
      final missing = OnboardingValidator.getMissingFields(
        step: CreationStep.education,
        formData: {},
      );
      expect(missing, containsAll(['education', 'profession', 'annualIncome']));
    });

    test('complete form has no missing fields', () {
      final missing = OnboardingValidator.getMissingFields(
        step: CreationStep.education,
        formData: {
          'education': 'B.Tech',
          'profession': 'Engineer',
          'annualIncome': '5L-10L',
        },
      );
      expect(missing, isEmpty);
    });
  });

  group('OnboardingValidator — Photos', () {
    test('no photos = missing', () {
      final missing = OnboardingValidator.getMissingFields(
        step: CreationStep.photo,
        formData: {'photos': []},
      );
      expect(missing, contains('photos'));
    });

    test('null photos = missing', () {
      final missing = OnboardingValidator.getMissingFields(
        step: CreationStep.photo,
        formData: {},
      );
      expect(missing, contains('photos'));
    });

    test('has photos = not missing', () {
      final missing = OnboardingValidator.getMissingFields(
        step: CreationStep.photo,
        formData: {
          'photos': ['photo1.jpg'],
        },
      );
      expect(missing, isEmpty);
    });
  });

  group('OnboardingValidator — Location (Full Mode)', () {
    test('missing state and district', () {
      final missing = OnboardingValidator.getMissingFields(
        step: CreationStep.location,
        formData: {},
      );
      expect(missing, containsAll(['state', 'district']));
    });

    test('complete location has no missing', () {
      final missing = OnboardingValidator.getMissingFields(
        step: CreationStep.location,
        formData: {
          'state': 'Maharashtra',
          'district': 'Nagpur',
        },
      );
      expect(missing, isEmpty);
    });
  });

  group('OnboardingValidator — Location (Lite Mode)', () {
    test('lite mode does NOT require district', () {
      final missing = OnboardingValidator.getMissingFields(
        step: CreationStep.location,
        formData: {
          'state': 'Maharashtra',
          // No district
        },
        isLite: true,
      );
      expect(missing, isNot(contains('district')));
      expect(missing, isEmpty);
    });

    test('lite mode still requires state', () {
      final missing = OnboardingValidator.getMissingFields(
        step: CreationStep.location,
        formData: {},
        isLite: true,
      );
      expect(missing, contains('state'));
    });
  });

  group('CreationStepConfig', () {
    test('signup mode has 3 steps', () {
      final steps = CreationStepConfig.getSteps(CreationMode.signup);
      expect(steps.length, 3);
      expect(steps, [CreationStep.personal, CreationStep.photo, CreationStep.location]);
    });

    test('editProfile mode has 5 steps', () {
      final steps = CreationStepConfig.getSteps(CreationMode.editProfile);
      expect(steps.length, 5);
    });

    test('adminEdit mode has 5 steps', () {
      final steps = CreationStepConfig.getSteps(CreationMode.adminEdit);
      expect(steps.length, 5);
    });

    test('modeFromFlags returns signup for new users', () {
      final mode = CreationStepConfig.modeFromFlags(
        isEditMode: false,
        isAdminEdit: false,
      );
      expect(mode, CreationMode.signup);
    });

    test('modeFromFlags returns editProfile for edit mode', () {
      final mode = CreationStepConfig.modeFromFlags(
        isEditMode: true,
        isAdminEdit: false,
      );
      expect(mode, CreationMode.editProfile);
    });

    test('modeFromFlags returns adminEdit for admin mode', () {
      final mode = CreationStepConfig.modeFromFlags(
        isEditMode: false,
        isAdminEdit: true,
      );
      expect(mode, CreationMode.adminEdit);
    });
  });
}
