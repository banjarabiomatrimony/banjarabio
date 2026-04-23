class OnboardingValidator {
  /// Returns a list of required field keys that are missing or invalid
  /// based on the current step and form data.
  static List<String> getMissingFields({
    required int step,
    required Map<String, dynamic> formData,
  }) {
    final missing = <String>[];

    switch (step) {
      case 0: // Personal Details
        if (_isEmpty(formData['name'])) missing.add('name');
        if (_isEmpty(formData['phone_number'])) missing.add('phone_number');
        if (_isEmpty(formData['age'])) missing.add('age');
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
        if (_isEmpty(formData['height'])) missing.add('height');
        break;

      case 1: // Family Details (Optional for now)
        break;

      case 2: // Education & Profession
        if (_isEmpty(formData['education'])) missing.add('education');
        if (_isEmpty(formData['profession'])) missing.add('profession');
        if (_isEmpty(formData['annualIncome'])) missing.add('annualIncome');
        break;

      case 3: // Photos
        final photos = formData['photos'];
        if (photos == null || (photos is List && photos.isEmpty)) {
          missing.add('photos');
        }
        break;

      case 4: // Location
        if (_isEmpty(formData['state'])) missing.add('state');
        if (_isEmpty(formData['district'])) missing.add('district');
        break;
      
      case 5: // Verification (Optional)
        break;
    }

    return missing;
  }

  static bool _isEmpty(dynamic value) {
    if (value == null) return true;
    if (value is String) return value.trim().isEmpty;
    return false;
  }
}
