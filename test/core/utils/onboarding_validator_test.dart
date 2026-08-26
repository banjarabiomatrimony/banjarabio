import 'package:flutter_test/flutter_test.dart';
import 'package:banjarabio/core/utils/onboarding_validator.dart';
import 'package:banjarabio/presentation/biodata_creation_screen/models/creation_step_config.dart';

void main() {
  group('OnboardingValidator Tests', () {
    test('detects missing personal fields in full mode', () {
      final missing = OnboardingValidator.getMissingFields(
        step: CreationStep.personal,
        formData: {},
      );

      expect(missing, contains('name'));
      expect(missing, contains('phone_number'));
      expect(missing, contains('surname'));
      expect(missing, contains('gender'));
      expect(missing, contains('age'));
      expect(missing, contains('height'));
    });

    test('detects gotra requirement for Banjara surnames', () {
      final missing = OnboardingValidator.getMissingFields(
        step: CreationStep.personal,
        formData: {
          'name': 'Rahul',
          'phone_number': '9876543210',
          'surname': 'Rathod',
          'gender': 'Male',
          'age': '26',
          'height': "5'8",
        },
      );

      expect(missing, contains('gotra'));
    });

    test('validates lite mode requires fewer personal fields', () {
      final missing = OnboardingValidator.getMissingFields(
        step: CreationStep.personal,
        formData: {
          'name': 'Pooja',
          'phone_number': '9876543210',
          'surname': 'Other',
          'gender': 'Female',
        },
        isLite: true,
      );

      expect(missing, isEmpty);
    });

    test('validates family and education steps', () {
      final missingFamily = OnboardingValidator.getMissingFields(
        step: CreationStep.family,
        formData: {'fatherName': 'Kalu'},
      );
      expect(missingFamily, contains('motherName'));

      final missingEdu = OnboardingValidator.getMissingFields(
        step: CreationStep.education,
        formData: {'education': 'B.Tech'},
      );
      expect(missingEdu, contains('profession'));
      expect(missingEdu, contains('annualIncome'));
    });

    test('validates photo and location steps', () {
      final missingPhoto = OnboardingValidator.getMissingFields(
        step: CreationStep.photo,
        formData: {'photos': []},
      );
      expect(missingPhoto, contains('photos'));

      final missingLoc = OnboardingValidator.getMissingFields(
        step: CreationStep.location,
        formData: {'state': 'Maharashtra'},
      );
      expect(missingLoc, contains('district'));
    });
  });
}
