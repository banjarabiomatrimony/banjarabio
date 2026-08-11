import 'package:banjarabio/presentation/biodata_creation_screen/models/creation_step_config.dart';

class OnboardingValidator {
  /// Returns a list of required field keys that are missing or invalid
  /// based on the current [step] and form data.
  ///
  /// When [isLite] is true (signup mode), a reduced set of fields is required:
  /// - Personal: name, phone, surname, gotra (conditional), gender (no height, no age)
  /// - Family: skipped entirely (not in lite flow)
  /// - Education: skipped entirely (not in lite flow)
  /// - Photo: 1 photo (unchanged)
  /// - Location: state only (no district)
  static List<String> getMissingFields({
    required CreationStep step,
    required Map<String, dynamic> formData,
    bool isLite = false,
  }) {
    final missing = <String>[];

    switch (step) {
      case CreationStep.personal:
        if (_isEmpty(formData['name'])) missing.add('name');
        if (_isEmpty(formData['phone_number'])) missing.add('phone_number');
        if (_isEmpty(formData['surname'])) {
          missing.add('surname');
        } else {
          final surname = formData['surname'].toString();
          // Specific logic for Banjara gotras mapping
          final hasGotras = [
            'Rathod',
            'Pawar',
            'Chauhan',
            'Jadhav',
            'Ade',
          ].contains(surname);
          if (hasGotras && _isEmpty(formData['gotra'])) {
            missing.add('gotra');
          }
        }
        if (_isEmpty(formData['gender'])) missing.add('gender');

        // Full mode requires height; lite mode skips it
        if (!isLite) {
          if (_isEmpty(formData['height'])) missing.add('height');
        }
        break;

      case CreationStep.family: // Optional for now (both modes)
        break;

      case CreationStep.education:
        if (_isEmpty(formData['education'])) missing.add('education');
        if (_isEmpty(formData['profession'])) missing.add('profession');
        if (_isEmpty(formData['annualIncome'])) missing.add('annualIncome');
        break;

      case CreationStep.photo:
        final photos = formData['photos'];
        if (photos == null || (photos is List && photos.isEmpty)) {
          missing.add('photos');
        }
        break;

      case CreationStep.location:
        if (_isEmpty(formData['state'])) missing.add('state');
        // Full mode requires district; lite mode skips it
        if (!isLite) {
          if (_isEmpty(formData['district'])) missing.add('district');
        }
        break;
    }

    return missing;
  }

  /// Legacy integer-based API for backward compatibility.
  /// Maps integer step index to [CreationStep] using the full (edit) step list.
  static List<String> getMissingFieldsByIndex({
    required int step,
    required Map<String, dynamic> formData,
    bool isLite = false,
  }) {
    // Map legacy integer to CreationStep using the appropriate step list
    final steps = isLite
        ? CreationStepConfig.getSteps(CreationMode.signup)
        : CreationStepConfig.getSteps(CreationMode.editProfile);
    if (step < 0 || step >= steps.length) return [];
    return getMissingFields(
      step: steps[step],
      formData: formData,
      isLite: isLite,
    );
  }

  static bool _isEmpty(dynamic value) {
    if (value == null) return true;
    if (value is String) return value.trim().isEmpty;
    return false;
  }
}
