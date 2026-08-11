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
