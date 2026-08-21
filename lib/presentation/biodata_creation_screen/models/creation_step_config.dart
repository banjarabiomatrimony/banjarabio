/// Defines the creation mode based on how the user entered the biodata form.
enum CreationMode {
  /// New user signup — minimal 3-step flow (Identity → Photo → Location)
  signup,

  /// Existing user editing their profile — full 5-step flow
  editProfile,

  /// Admin/Staff editing a lead's profile — full 5-step flow
  adminEdit,
}

/// Logical step identifiers decoupled from integer indices.
/// The step order is fixed; which steps are *active* depends on [CreationMode].
enum CreationStep {
  personal,
  family,
  education,
  photo,
  location;

  /// Returns a validation-map key for this step (matches existing keys).
  String get validationKey {
    switch (this) {
      case CreationStep.personal:
        return 'personal';
      case CreationStep.family:
        return 'family';
      case CreationStep.education:
        return 'education';
      case CreationStep.photo:
        return 'photo';
      case CreationStep.location:
        return 'location';
    }
  }
}

/// Centralized configuration for which steps are active in each mode.
///
/// This pattern makes it trivial to add future modes (e.g. "Quick Edit",
/// "Staff Intake") without touching section widgets.
class CreationStepConfig {
  CreationStepConfig._();

  /// Returns the ordered list of active steps for the given [mode].
  static List<CreationStep> getSteps(CreationMode mode) {
    switch (mode) {
      case CreationMode.signup:
        return const [
          CreationStep.personal,
          CreationStep.photo,
          CreationStep.location,
        ];
      case CreationMode.editProfile:
      case CreationMode.adminEdit:
        return const [
          CreationStep.personal,
          CreationStep.family,
          CreationStep.education,
          CreationStep.photo,
          CreationStep.location,
        ];
    }
  }

  /// Returns only the steps that have incomplete/pending fields in [formData].
  static List<CreationStep> getPendingSteps(Map<String, dynamic> data) {
    final List<CreationStep> pending = [];

    // 1. Personal details check
    if (isPersonalPending(data)) {
      pending.add(CreationStep.personal);
    }

    // 2. Family details check
    if (isFamilyPending(data)) {
      pending.add(CreationStep.family);
    }

    // 3. Education / Career check
    if (isEducationPending(data)) {
      pending.add(CreationStep.education);
    }

    // 4. Photo check (e.g. less than 2 photos)
    if (isPhotoPending(data)) {
      pending.add(CreationStep.photo);
    }

    // 5. Location & Preferences check
    if (isLocationPending(data)) {
      pending.add(CreationStep.location);
    }

    // Fallback: If everything is already complete, show standard edit steps
    if (pending.isEmpty) {
      return getSteps(CreationMode.editProfile);
    }

    return pending;
  }

  static bool _isEmpty(dynamic val) {
    if (val == null) return true;
    if (val is String) return val.trim().isEmpty;
    if (val is List) return val.isEmpty;
    if (val is Map) return val.isEmpty;
    return false;
  }

  static bool isPersonalPending(Map<String, dynamic> data) {
    if (_isEmpty(data['gotra'])) return true;
    if (_isEmpty(data['complexion'])) return true;
    if (_isEmpty(data['bloodGroup']) && _isEmpty(data['blood_group'])) return true;
    if (_isEmpty(data['birthPlace']) && _isEmpty(data['birth_place'])) return true;
    if (_isEmpty(data['birthTime']) && _isEmpty(data['birth_time'])) return true;
    if (_isEmpty(data['height'])) return true;
    return false;
  }

  static bool isFamilyPending(Map<String, dynamic> data) {
    if (_isEmpty(data['fatherName']) && _isEmpty(data['father_name'])) return true;
    if (_isEmpty(data['motherName']) && _isEmpty(data['mother_name'])) return true;
    if (_isEmpty(data['fatherOccupation']) && _isEmpty(data['father_occupation'])) return true;
    if (_isEmpty(data['motherOccupation']) && _isEmpty(data['mother_occupation'])) return true;
    if (_isEmpty(data['familyType']) && _isEmpty(data['family_type'])) return true;
    if (_isEmpty(data['familyStatus']) && _isEmpty(data['family_status'])) return true;
    return false;
  }

  static bool isEducationPending(Map<String, dynamic> data) {
    if (_isEmpty(data['education'])) return true;
    if (_isEmpty(data['profession'])) return true;
    if (_isEmpty(data['annualIncome']) && _isEmpty(data['annual_income'])) return true;
    if (_isEmpty(data['jobDetails']) && _isEmpty(data['job_details'])) return true;
    if (_isEmpty(data['educationDetails']) && _isEmpty(data['education_details'])) return true;
    return false;
  }

  static bool isPhotoPending(Map<String, dynamic> data) {
    final photos = data['photos'];
    if (photos == null) return true;
    if (photos is List) return photos.length < 2;
    return false;
  }

  static bool isLocationPending(Map<String, dynamic> data) {
    if (_isEmpty(data['state'])) return true;
    if (_isEmpty(data['district'])) return true;
    if (_isEmpty(data['taluka'])) return true;
    if (_isEmpty(data['nativePlace']) && _isEmpty(data['native_place'])) return true;
    if (_isEmpty(data['aboutSelf']) && _isEmpty(data['about_self'])) return true;
    if (_isEmpty(data['partnerExpectations']) &&
        _isEmpty(data['partner_expectations']) &&
        _isEmpty(data['expectation'])) {
      return true;
    }
    return false;
  }

  /// Whether this mode uses the "lite" (reduced fields) variant of sections.
  static bool isLiteMode(CreationMode mode) => mode == CreationMode.signup;

  /// Derives [CreationMode] from the existing boolean flags.
  static CreationMode modeFromFlags({
    required bool isEditMode,
    required bool isAdminEdit,
  }) {
    if (isAdminEdit) return CreationMode.adminEdit;
    if (isEditMode) return CreationMode.editProfile;
    return CreationMode.signup;
  }
}
