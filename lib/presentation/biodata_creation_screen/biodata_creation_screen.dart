import 'dart:async';
import 'dart:io' as io;
import 'package:banjarabio/l10n/app_localizations.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:sizer/sizer.dart';

import 'package:banjarabio/core/app_export.dart';
import 'package:banjarabio/core/models/profile_model.dart';

import 'package:banjarabio/core/repositories/admin_repository.dart';
import 'package:banjarabio/core/repositories/staff_repository.dart';
import 'package:banjarabio/core/repositories/profile_repository.dart';
import 'package:banjarabio/core/repositories/photo_repository.dart';

import 'package:banjarabio/core/config/admin_config.dart';
import 'package:banjarabio/core/supabase_client.dart';
import 'package:banjarabio/core/services/analytics_service.dart';
import 'package:banjarabio/widgets/custom_app_bar.dart';
import 'package:banjarabio/presentation/biodata_creation_screen/widgets/education_profession_section.dart';
import 'package:banjarabio/presentation/biodata_creation_screen/widgets/family_details_section.dart';
import 'package:banjarabio/presentation/biodata_creation_screen/widgets/location_preferences_section.dart';
import 'package:banjarabio/presentation/biodata_creation_screen/widgets/personal_details_section.dart';
import 'package:banjarabio/presentation/biodata_creation_screen/widgets/photo_upload_section.dart';
import 'package:banjarabio/presentation/biodata_creation_screen/widgets/creation_progress_indicator.dart';
import 'package:banjarabio/presentation/biodata_creation_screen/widgets/creation_navigation_buttons.dart';
import 'package:banjarabio/presentation/biodata_creation_screen/widgets/creation_discard_dialog.dart';
import 'package:banjarabio/presentation/biodata_creation_screen/widgets/creation_form_data_mapper.dart';
import 'package:banjarabio/presentation/biodata_creation_screen/models/creation_step_config.dart';
import 'package:banjarabio/core/services/app_logger.dart';

/// Biodata Creation Screen for structured profile building
/// Implements traditional matrimonial format with mobile-optimized input
/// Supports multi-step form with auto-save and validation
class BiodataCreationScreen extends StatefulWidget {
  const BiodataCreationScreen({super.key});

  @override
  State<BiodataCreationScreen> createState() => _BiodataCreationScreenState();
}

class _BiodataCreationScreenState extends State<BiodataCreationScreen>
    with WidgetsBindingObserver {
  final _formKey = GlobalKey<FormState>();

  int _currentStep = 0;
  bool _isLoading = false;

  // Debouncing for auto-save
  Timer? _debounceTimer;
  final Duration _debounceDuration = const Duration(seconds: 2);

  // Scroll controller to hide selection toolbar on scroll (Mitigates Oppo/Android 14 crash)
  final ScrollController _scrollController = ScrollController();

  bool _isEditMode = false;
  bool _isAdminEdit = false; // Admin editing another user's profile
  bool _onlyPendingFields = false; // Filter to show only pending/incomplete fields
  bool _isInitialDataLoaded = false;
  bool _isPopulating = false; // Flag to prevent validation loops during population
  bool _isPointerDown = false; // Prevents programmatic scrolls from dismissing keyboard
  ProfileModel? _existingProfile;

  final ProfileRepository _profileRepository = ProfileRepository();
  final PhotoRepository _photoRepository = PhotoRepository();

  // --- Dynamic Step Configuration ---
  /// Computed creation mode based on edit/admin flags
  CreationMode get _creationMode => CreationStepConfig.modeFromFlags(
        isEditMode: _isEditMode,
        isAdminEdit: _isAdminEdit,
      );

  /// Active steps for the current mode
  List<CreationStep> get _activeSteps {
    if (_onlyPendingFields) {
      return CreationStepConfig.getPendingSteps(_formData);
    }
    return CreationStepConfig.getSteps(_creationMode);
  }

  /// Total number of active steps
  int get _totalSteps => _activeSteps.length;

  /// Whether we're in lite (signup) mode
  bool get _isLite => CreationStepConfig.isLiteMode(_creationMode);

  /// The logical step for the current index
  CreationStep get _currentCreationStep => _activeSteps[_currentStep];

  // Form data storage
  Map<String, dynamic> _formData = CreationFormDataMapper.createEmptyFormData();

  // Validation states — initialized for all possible sections;
  // only the active ones are checked during navigation.
  final Map<String, bool> _sectionValidation = {
    'personal': false,
    'family': false,
    'education': false,
    'photo': false,
    'location': false,
  };

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _scrollController.addListener(_handleScroll);
    _checkAuthStatus();
  }

  void _handleScroll() {
    // Only unfocus if the user is explicitly dragging the screen.
    // By checking _isPointerDown, we avoid unfocusing when Flutter
    // automatically scrolls to keep textfields above the keyboard.
    if (_scrollController.hasClients && _isPointerDown) {
      final FocusScopeNode currentFocus = FocusScope.of(context);
      if (!currentFocus.hasPrimaryFocus && currentFocus.focusedChild != null) {
        AppLogger.debug('BiodataCreationScreen', 'BiodataCreationScreen: Hiding keyboard on manual scroll');
        currentFocus.focusedChild?.unfocus();
      }
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args = ModalRoute.of(context)?.settings.arguments;
    if (args != null && args is Map<String, dynamic> && !_isInitialDataLoaded) {
      _isInitialDataLoaded = true; // Guard to prevent multiple re-populations
      // Check for isEditMode flag
      _isEditMode = args['isEditMode'] as bool? ?? false;
      _isAdminEdit = args['isAdminEdit'] as bool? ?? false;
      _onlyPendingFields = args['onlyPendingFields'] as bool? ?? false;

      // Check if profile data is passed directly or
      final profileInput = args['profile'];
      if (profileInput is ProfileModel) {
        _existingProfile = profileInput;
        if (_isEditMode && _existingProfile != null) {
          // Sync population
          _populateFormFromMap(_existingProfile!.toDisplayMap());
        }
      } else if (args.containsKey('id')) {
        // Entire map is the profile data
        _populateFormFromMap(args);
      }

      // Draft Restoration: schedule after current build to avoid conflicts
      WidgetsBinding.instance.addPostFrameCallback((_) => _loadDraft());
    } else if (!_isInitialDataLoaded) {
      _isInitialDataLoaded = true;
      WidgetsBinding.instance.addPostFrameCallback((_) => _loadDraft());
    }
  }

  Future<void> _loadDraft() async {
    final draft = await SessionManager.instance.getBiodataDraft();
    if (draft != null && draft.isNotEmpty) {
      final draftId = draft['id']?.toString().trim();
      final hasDraftId = draftId != null && draftId.isNotEmpty;

      // If we are in edit mode, ensure draft matches this profile
      if (_isEditMode && _existingProfile != null) {
        if (draftId != _existingProfile!.id) {
          AppLogger.debug('BiodataCreationScreen', 'Draft ID mismatch, not loading');
          return;
        }
      } else if (_isEditMode && !hasDraftId) {
        // Edit mode but draft has no ID... might be risky
        return;
      } else if (!_isEditMode && hasDraftId) {
        // Create mode but draft has an ID (it was an edit draft)
        return;
      }

      AppLogger.debug('BiodataCreationScreen', 'BiodataCreationScreen: Loading draft data');
      _populateFormFromMap(draft);
      if (mounted) {
        final l10n = AppLocalizations.of(context);
        final biodataDraftRestoredMsg = l10n?.biodataDraftRestored ?? 'Biodata draft restored!';
        Fluttertoast.cancel();
        Fluttertoast.showToast(
          msg: '📝 $biodataDraftRestoredMsg',
          toastLength: Toast.LENGTH_SHORT,
          timeInSecForIosWeb: 2,
          gravity: ToastGravity.BOTTOM,
          backgroundColor: AppColors.categoryAstroDark,
          textColor: Colors.white,
        );
      }
    } else if (!_isEditMode) {
      // If no draft exists, pre-fill name from Google Account metadata if available
      final userMeta = AppSupabaseClient.currentUser?.userMetadata;
      final googleName = userMeta?['full_name']?.toString() ?? userMeta?['name']?.toString();
      if (googleName != null && googleName.trim().isNotEmpty && (_formData['name'] == null || _formData['name'].toString().isEmpty)) {
        if (mounted) {
          setState(() {
            _formData['name'] = googleName.trim();
          });
        }
      }
    }
  }

  /// Check and wait for authentication to be ready
  Future<void> _checkAuthStatus() async {
    // Admin editing another user's profile — skip target-user auth check
    if (_isAdminEdit) return;

    // Give Supabase time to process OAuth callback
    await Future.delayed(const Duration(milliseconds: 500));

    // If not authenticated, redirect to login
    if (!AppSupabaseClient.isAuthenticated) {
      if (mounted) {
        Navigator.of(context).pushReplacementNamed(AppRoutes.authentication);
      }
    }
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    _scrollController.removeListener(_handleScroll);
    _scrollController.dispose();
    WidgetsBinding.instance.removeObserver(this);

    // Clean up temporary files
    _cleanupTempFiles();

    super.dispose();
  }

  /// Clean up temporary image files
  void _cleanupTempFiles() {
    if (kIsWeb) return;
    try {
      final tempPhotos = _formData['tempPhotos'] is List
          ? List<String>.from(_formData['tempPhotos'] as List)
          : <String>[];
      for (final path in tempPhotos) {
        try {
          final file = io.File(path);
          if (file.existsSync() && path.contains('scaled_')) {
            file.deleteSync();
          }
        } catch (e) {
          AppLogger.error('BiodataCreationScreen', 'Error deleting temp file $path: $e');
        }
      }
    } catch (e) {
      AppLogger.error('BiodataCreationScreen', 'Error in cleanupTempFiles: $e');
    }
  }

  @override
  void didHaveMemoryPressure() {
    debugPrint(
      'BiodataCreationScreen: Memory pressure detected, clearing image cache',
    );
    // Use clearLiveImages instead of clear to preserve essential caches
    imageCache.clearLiveImages();
    super.didHaveMemoryPressure();
  }

  Future<void> _nextStep() async {
    final missingFields = _getMissingFields(step: _currentCreationStep);
 
    if (missingFields.isNotEmpty && !_isAdminEdit) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            AppLocalizations.of(context)?.pleaseComplete(missingFields.join(', ')) ??
                'Please complete: ${missingFields.join(', ')}',
          ),
          backgroundColor: Theme.of(context).colorScheme.error,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }
 
    if (_currentStep < _totalSteps - 1) {
      if (_isEditMode || _isAdminEdit) {
        setState(() => _isLoading = true);
        try {
          await _persistProfileData();
        } finally {
          if (mounted) setState(() => _isLoading = false);
        }
      }
      if (mounted) {
        setState(() => _currentStep++);
      }
    }
  }

  void _previousStep() {
    if (_currentStep > 0) {
      setState(() => _currentStep--);
    }
  }

  void _updateFormData(String key, dynamic value) {
    if (_formData[key] == value) return; // Skip redundant updates

    // ✅ Photo updates are heavy, don't trigger parent UI rebuild if not needed
    if (key == 'photos') {
      _formData[key] = value;
      _autoSaveProgress(); // Always save photos
      return;
    }

    setState(() {
      _formData[key] = value;
    });
    _autoSaveProgress();
  }

  /// Batch update multiple fields at once
  void _batchUpdateFormData(Map<String, dynamic> updates) {
    bool changed = false;
    updates.forEach((key, value) {
      if (_formData[key] != value) {
        _formData[key] = value;
        changed = true;
      }
    });

    if (changed) {
      setState(() {});
      _autoSaveProgress();
    }
  }

  void _autoSaveProgress() {
    // Debounce disk I/O to prevent ANRs and battery drain
    _debounceTimer?.cancel();
    _debounceTimer = Timer(_debounceDuration, () {
      if (!mounted) return;

      final dataToSave = Map<String, dynamic>.from(_formData);
      if (_isEditMode && _existingProfile != null) {
        dataToSave['id'] = _existingProfile!.id;
      } else {
        dataToSave.remove('id');
      }

      AppLogger.debug('BiodataCreationScreen', 'BiodataCreationScreen: Auto-saving draft...');
      SessionManager.instance.saveBiodataDraft(dataToSave);
      
      // ✅ Special for Staff: Immediate DB Persistence
      if (_isAdminEdit && _existingProfile != null) {
        _backgroundAdminSave();
      }
    });
  }

  /// Background persistence for admin edits to minimize interruptions
  Future<void> _backgroundAdminSave() async {
    if (!_isAdminEdit || _existingProfile == null) return;
    
    try {
      // 🧬 SPARSE UPDATE: Only send fields that exist in _formData to avoid overwriting with defaults
      final profileData = _buildSparseProfileData();
      
      // Safety check: if no fields were populated (besides IDs/updated_at), skip
      if (profileData.length <= 3) return;

      AppLogger.debug('BiodataCreationScreen', 'BiodataCreationScreen: Background auto-save for admin/staff: ${profileData.keys}');
      
      final currentProfile = SessionManager.instance.currentProfile;
      final currentRole = currentProfile?.role ?? 'user';
      final isStaff = currentRole == 'staff' || currentRole == 'telecaller';
      
      if (isStaff) {
        final staffRes = await StaffRepository().updateLeadProfile(
          _existingProfile!.userId,
          profileData,
        );
        if (!staffRes.isSuccess) {
          AppLogger.error('BiodataCreationScreen', 'BiodataCreationScreen: Staff background save failed: ${staffRes.errorMessage}');
        } else {
          AppLogger.debug('BiodataCreationScreen', 'BiodataCreationScreen: Staff background save successful');
        }
      } else if (currentRole == 'admin' || AdminConfig.isAdminEmail(AppSupabaseClient.currentUser?.email ?? '')) {
        await AdminRepository().adminUpdateProfile(
          _existingProfile!.userId,
          profileData,
        );
        AppLogger.debug('BiodataCreationScreen', 'BiodataCreationScreen: Admin background save successful');
      } else {
        AppLogger.warn('BiodataCreationScreen', 'BiodataCreationScreen: Background save skipped - role "$currentRole" not authorized');
      }
    } catch (e) {
      AppLogger.error('BiodataCreationScreen', 'BiodataCreationScreen: Background auto-save failed: $e');
    }
  }

  /// Delegates to CreationFormDataMapper for sparse profile data.
  Map<String, dynamic> _buildSparseProfileData() {
    return CreationFormDataMapper.buildSparseProfileData(
      formData: _formData,
      isAdminEdit: _isAdminEdit,
      existingProfileUserId: _existingProfile?.userId,
    );
  }

  void _populateFormFromMap(Map<String, dynamic> data) {
    try {
      setState(() {
        _isPopulating = true;
        _formData = CreationFormDataMapper.populateFromMap(_formData, data);
        _isPopulating = false;
      });
    } catch (e) {
      _isPopulating = false;
      AppLogger.error('BiodataCreationScreen', 'Error populating form from map: $e');
    }
  }

  /// Returns a list of user-friendly names for missing required fields
  List<String> _getMissingFields({CreationStep? step}) {
    if (_isAdminEdit) return [];
    
    final l10n = AppLocalizations.of(context);
    if (l10n == null) return [];

    // If step is null, check all active steps up to the current one
    final stepsToCheck =
        step != null ? [step] : _activeSteps.sublist(0, _currentStep + 1);

    final missingKeys = <String>[];
    for (final s in stepsToCheck) {
      missingKeys.addAll(
        OnboardingValidator.getMissingFields(
          step: s,
          formData: _formData,
          isLite: _isLite,
        ),
      );
    }

    // Map keys to localized labels
    return missingKeys.map((key) {
      switch (key) {
        case 'name': return l10n.fullName;
        case 'phone_number': return l10n.mobileNumber;
        case 'age': return l10n.age;
        case 'surname': return l10n.surname;
        case 'gotra': return l10n.gotra;
        case 'profileCreatedBy': return l10n.profileCreatedByTitle;
        case 'gender': return l10n.gender;
        case 'height': return l10n.height;
        case 'education': return l10n.education;
        case 'profession': return l10n.profession;
        case 'annualIncome': return l10n.annualIncome;
        case 'photos': return l10n.profilePhotos;
        case 'state': return l10n.state;
        case 'district': return l10n.district;
        default: return key;
      }
    }).toList();
  }

  /// Persists profile data to the database based on the current mode (create/edit/admin).
  /// Returns the saved profile if successful, null otherwise.
  Future<ProfileModel?> _persistProfileData({bool isFinalSave = false}) async {
    final tempLocalizations = AppLocalizations.of(context);
    final l10n = tempLocalizations;

    try {
      // 🧬 PERFORMANCE: Removed global imageCache.clear() here.
      // Image cache limits (20MB) are now enforced globally by PerformanceService.
      await Future.delayed(const Duration(milliseconds: 100));

      // For admin edit, use the target user's ID; otherwise use current user
      String? userId;
      if (_isAdminEdit && _existingProfile != null) {
        userId = _existingProfile!.userId;
      } else {
        userId = AppSupabaseClient.currentUserId;
        if (userId == null) {
          await Future.delayed(const Duration(milliseconds: 500));
          userId = AppSupabaseClient.currentUserId;
        }
      }

      if (userId == null) {
        throw Exception(l10n?.pleaseSignInAgain ?? 'Please sign in again to save your biodata');
      }

      // Prepare profile data
      final profileData = _buildSparseProfileData();
      
      // Ensure user_id is correct for regular save
      profileData['user_id'] = userId;

      AppLogger.debug('BiodataCreationScreen', 'BiodataCreationScreen: Saving profile with data keys: ${profileData.keys}');

      final aboutSelf = _formData['aboutSelf']?.toString() ?? '';
      if (aboutSelf.isNotEmpty) {
        profileData['about_self'] = aboutSelf;
      }

      AppLogger.debug('BiodataCreationScreen', 'BiodataCreationScreen: Saving profile with data: $profileData');

      final BackendResponse<ProfileModel> response;
      if (_isAdminEdit && _existingProfile != null) {
        // Admin/Staff edit: use specialized RPC to bypass RLS
        final currentProfile = SessionManager.instance.currentProfile;
        final currentRole = currentProfile?.role ?? 'user';
        final isStaff = currentRole == 'staff' || currentRole == 'telecaller';
        final BackendResponse<void> adminOrStaffRes;

        if (isStaff) {
          adminOrStaffRes = await StaffRepository().updateLeadProfile(
            _existingProfile!.userId,
            profileData,
          );
        } else if (currentRole == 'admin' || AdminConfig.isAdminEmail(AppSupabaseClient.currentUser?.email ?? '')) {
          adminOrStaffRes = await AdminRepository().adminUpdateProfile(
            _existingProfile!.userId,
            profileData,
          );
        } else {
          // If role is user but _isAdminEdit is true (e.g., bypass or stale session),
          // fallback to AdminRepository and let it fail or succeed based on true DB role
          adminOrStaffRes = await AdminRepository().adminUpdateProfile(
            _existingProfile!.userId,
            profileData,
          );
        }

        if (adminOrStaffRes.isSuccess) {
          response = BackendResponse.success(_existingProfile!.copyWith(
            fullName: profileData['full_name'] ?? _existingProfile!.fullName,
            updatedAt: DateTime.now(),
          ));
        } else {
          response = BackendResponse.failure(adminOrStaffRes.errorMessage);
        }
      } else if (_isEditMode && _existingProfile != null) {
        response = await _profileRepository.updateProfile(
          _existingProfile!.userId,
          profileData,
        );
      } else {
        response = await _profileRepository.createProfile(profileData);
      }

      ProfileModel? saved;
      await response.fold(
        onSuccess: (savedProfile) async {
          saved = savedProfile;
          AppLogger.debug('BiodataCreationScreen', 'Profile saved successfully with ID: ${savedProfile.id}');

          // ✅ Photo Upload Logic (Only if on photo step or final save)
          if (_currentCreationStep == CreationStep.photo || isFinalSave) {
            final allPhotos = List<String>.from(_formData['photos'] as List? ?? []);
            final newPhotos = allPhotos
                .where((p) => !p.startsWith('http') && !p.startsWith('https'))
                .toList();

            if (newPhotos.isNotEmpty) {
              for (int i = 0; i < newPhotos.length; i++) {
                final photoPath = newPhotos[i];
                try {
                  // 🧬 PERFORMANCE: Removed global imageCache.clearLiveImages() here.
                  await Future.delayed(const Duration(milliseconds: 100));
                  final uploadFile = kIsWeb ? null : io.File(photoPath);

                  if (!kIsWeb && (uploadFile == null || !uploadFile.existsSync())) {
                    continue;
                  }

                  final BackendResponse<PhotoModel> uploadRes;
                  if (_existingProfile != null &&
                      i < _existingProfile!.photos.length &&
                      _existingProfile!.photos[i].id.isNotEmpty) {
                    final existingPhoto = _existingProfile!.photos[i];
                    uploadRes = await _photoRepository.replacePhoto(
                      profileId: savedProfile.id,
                      existingPhotoId: existingPhoto.id,
                      existingStoragePath: existingPhoto.storagePath,
                      newImageFile: uploadFile!,
                      semanticLabel: 'Profile Photo ${i + 1}',
                    );
                  } else {
                    uploadRes = await _photoRepository.uploadPhoto(
                      profileId: savedProfile.id,
                      imageFile: uploadFile!,
                      semanticLabel: 'Profile Photo ${i + 1}',
                    );
                  }

                  await uploadRes.fold(
                    onSuccess: (photo) async => debugPrint('Photo uploaded: ${photo.publicUrl}'),
                    onFailure: (error) async {
                      AppLogger.error('BiodataCreationScreen', 'Failed to upload photo $photoPath: $error');
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(l10n?.failedToUploadPhoto((i + 1).toString()) ?? 'Failed to upload photo ${i + 1}'),
                            backgroundColor: Colors.orange,
                          ),
                        );
                      }
                    },
                  );
                } catch (e) {
                  AppLogger.error('BiodataCreationScreen', 'Error uploading photo $photoPath: $e');
                }
              }
            }
          }

          // Force refresh: sync fresh DB record with all photos, DOB and contacts into caches
          final freshRes = await _profileRepository.getOwnProfile(forceRefresh: true);
          freshRes.fold(
            onSuccess: (freshProfile) {
              if (freshProfile != null) {
                saved = freshProfile;
              }
            },
            onFailure: (_) {},
          );
        },
        onFailure: (error) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(l10n?.failedToSaveProfile(error.toString()) ?? 'Failed to save profile: $error'),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
      );
      return saved;
    } catch (e, stackTrace) {
      AppLogger.error('BiodataCreationScreen', 'Error saving profile: $e');
      AppLogger.debug('BiodataCreationScreen', 'Stack trace: $stackTrace');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n?.failedToSaveProfile(e.toString()) ?? 'Failed to save: ${e.toString()}'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
      return null;
    }
  }

  Future<void> _validateAndSave() async {
    if (_formKey.currentState?.validate() ?? false) {
      // Final validation
      final missingFields = _getMissingFields();
      if (missingFields.isNotEmpty && !_isAdminEdit) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              AppLocalizations.of(context)?.pleaseComplete(missingFields.join(', ')) ??
                  'Please complete: ${missingFields.join(', ')}',
            ),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
        return;
      }

      setState(() => _isLoading = true);

      try {
        final savedProfile = await _persistProfileData(isFinalSave: true);
        if (!mounted) return;

        if (savedProfile != null && mounted) {
          // Log Signup Complete (Only if not in edit mode and not admin edit)
          if (!_isEditMode && !_isAdminEdit) {
            AnalyticsService.logSignUpSuccess(savedProfile.id);
          }

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(AppLocalizations.of(context)?.biodataSavedSuccessfully ?? 'Biodata saved successfully!'),
            ),
          );

          // Wait before navigation
          await Future.delayed(const Duration(milliseconds: 1000));

          if (mounted) {
            _cleanupTempFiles();
            // ✅ Draft Cleanup: Clear draft after successful save (skip for admin edits)
            if (!_isAdminEdit) {
              SessionManager.instance.clearBiodataDraft();
            }

            if (_isEditMode || _isAdminEdit) {
              Navigator.of(context).pop(savedProfile);
            } else {
              Navigator.of(context).pushNamedAndRemoveUntil(AppRoutes.home, (route) => false);
            }
          }
        }
      } finally {
        if (mounted) {
          setState(() => _isLoading = false);
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;

        if (_currentStep > 0) {
          _previousStep();
        } else {
          if (!context.mounted) return;
          await CreationDiscardDialog.show(
            context: context,
            isEditMode: _isEditMode,
            isAdminEdit: _isAdminEdit,
          );
        }
      },
      child: Listener(
        onPointerDown: (_) => _isPointerDown = true,
        onPointerUp: (_) => _isPointerDown = false,
        onPointerCancel: (_) => _isPointerDown = false,
        child: Scaffold(
          appBar: CustomAppBar(
            title: _isEditMode ? (AppLocalizations.of(context)?.editProfile ?? 'Edit Profile') : (AppLocalizations.of(context)?.createBiodata ?? 'Create Biodata'),
          subtitle: AppLocalizations.of(context)?.stepNOfTotal((_currentStep + 1).toString(), _totalSteps.toString()) ?? 'Step ${_currentStep + 1} of $_totalSteps',
          leading: _currentStep > 0
              ? IconButton(
                  icon: CustomIconWidget(
                    iconName: 'arrow_back',
                    color: theme.appBarTheme.foregroundColor ?? theme.colorScheme.onSurface,
                  ),
                  onPressed: _previousStep,
                )
              : IconButton(
                  icon: CustomIconWidget(
                    iconName: 'close',
                    color: theme.appBarTheme.foregroundColor ?? theme.colorScheme.onSurface,
                  ),
                  onPressed: () {
                    final l10n = AppLocalizations.of(context);
                    final biodataDraftSavedMsg = l10n?.discardChangesBody ?? 'Your progress is saved as a draft.';
                    Fluttertoast.cancel();
                    Fluttertoast.showToast(
                      msg: '💾 $biodataDraftSavedMsg',
                      toastLength: Toast.LENGTH_SHORT,
                      timeInSecForIosWeb: 2,
                      gravity: ToastGravity.BOTTOM,
                      backgroundColor: AppColors.categoryLocation,
                      textColor: Colors.white,
                    );
                    // Navigate to user type selection for new users, home for existing, pop for admin
                    if (_isAdminEdit) {
                      Navigator.of(context).pop();
                    } else if (_isEditMode) {
                      Navigator.of(context).pushNamedAndRemoveUntil(AppRoutes.home, (route) => false);
                    } else {
                      Navigator.of(context).pushNamedAndRemoveUntil(AppRoutes.userTypeSelection, (route) => false);
                    }
                  },
                ),
        ),
        body: Form(
          key: _formKey,
          child: Column(
            children: [
              // Progress indicator — uses dynamic active steps with interactive tab switching in Edit Mode
              CreationProgressIndicator(
                currentStep: _currentStep,
                activeSteps: _activeSteps,
                formData: _formData,
                sectionValidation: _sectionValidation,
                isLite: _isLite,
                isEditMode: _isEditMode || _isAdminEdit,
                onStepTapped: (_isEditMode || _isAdminEdit)
                    ? (index) {
                        setState(() => _currentStep = index);
                      }
                    : null,
              ),

              if (_onlyPendingFields)
                Container(
                  margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 0.8.h),
                  padding: EdgeInsets.symmetric(horizontal: 3.5.w, vertical: 1.h),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        AppColors.gold.withValues(alpha: AppColors.opacity12),
                        theme.colorScheme.primary.withValues(alpha: 0.06),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: AppColors.gold.withValues(alpha: AppColors.opacity40),
                    ),
                  ),
                  child: Row(
                    children: [
                      Text('🎯', style: TextStyle(fontSize: AppTypography.headingMedium)),
                      SizedBox(width: 2.w),
                      Expanded(
                        child: Text(
                          'Showing pending sections to help boost your profile completion!',
                          style: TextStyle(
                            fontSize: AppTypography.labelMedium,
                            fontWeight: AppTypography.bold,
                            color: theme.colorScheme.onSurface,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

              // Form sections - Animated transition between form steps
              Expanded(
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 280),
                  switchInCurve: Curves.easeOutCubic,
                  switchOutCurve: Curves.easeInCubic,
                  transitionBuilder: (child, animation) {
                    return FadeTransition(
                      opacity: animation,
                      child: SlideTransition(
                        position: Tween<Offset>(
                          begin: const Offset(0.04, 0),
                          end: Offset.zero,
                        ).animate(animation),
                        child: child,
                      ),
                    );
                  },
                  child: KeyedSubtree(
                    key: ValueKey<int>(_currentStep),
                    child: _buildCurrentSection(),
                  ),
                ),
              ),

              // Navigation buttons — uses dynamic total steps
              CreationNavigationButtons(
                currentStep: _currentStep,
                totalSteps: _totalSteps,
                isLoading: _isLoading,
                isEditMode: _isEditMode,
                isLite: _isLite,
                onPrevious: _previousStep,
                onNext: _nextStep,
                onSave: _validateAndSave,
              ),
            ],
          ),
        ),
      ),
      ),
    );
  }





  Widget _buildCurrentSection() {
    final step = _currentCreationStep;

    switch (step) {
      case CreationStep.personal:
        return PersonalDetailsSection(
          formData: _formData,
          isAdminEdit: _isAdminEdit,
          isLite: _isLite,
          onUpdate: _updateFormData,
          onBatchUpdate: _batchUpdateFormData,
          scrollController: _scrollController,
          onValidationChange: (isValid) {
            if (_isPopulating) return; // Ignore during population
            if (_sectionValidation['personal'] == isValid) {
              return; // Skip if same
            }
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (mounted) {
                setState(() => _sectionValidation['personal'] = isValid);
              }
            });
          },
        );
      case CreationStep.family:
        return FamilyDetailsSection(
          formData: _formData,
          isAdminEdit: _isAdminEdit,
          onUpdate: _updateFormData,
          onBatchUpdate: _batchUpdateFormData,
          scrollController: _scrollController,
          onValidationChange: (isValid) {
            if (_isPopulating) return;
            if (_sectionValidation['family'] == isValid) return;
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (mounted) {
                setState(() => _sectionValidation['family'] = isValid);
              }
            });
          },
        );
      case CreationStep.education:
        return EducationProfessionSection(
          formData: _formData,
          isAdminEdit: _isAdminEdit,
          isLite: _isLite,
          onUpdate: _updateFormData,
          onBatchUpdate: _batchUpdateFormData,
          scrollController: _scrollController,
          onValidationChange: (isValid) {
            if (_isPopulating) return;
            if (_sectionValidation['education'] == isValid) return;
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (mounted) {
                setState(() => _sectionValidation['education'] = isValid);
              }
            });
          },
        );
      case CreationStep.photo:
        return PhotoUploadSection(
          photos: List<String>.from(_formData['photos'] as List? ?? []),
          gender: _formData['gender']?.toString() ?? 'Female',
          isPremium: _existingProfile?.isPremium ?? false,
          isAdminEdit: _isAdminEdit,
          onPhotosUpdate: (photos) {
            setState(() {
              _formData['photos'] = List<String>.from(photos);
              _sectionValidation['photo'] = _isAdminEdit || photos.isNotEmpty;
            });
          },
        );
      case CreationStep.location:
        return LocationPreferencesSection(
          formData: _formData,
          isAdminEdit: _isAdminEdit,
          isLite: _isLite,
          onUpdate: _updateFormData,
          onBatchUpdate: _batchUpdateFormData,
          onValidationChange: (isValid) {
            if (_isPopulating) return;
            if (_sectionValidation['location'] == isValid) return;
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (mounted) {
                setState(() => _sectionValidation['location'] = isValid);
              }
            });
          },
        );
    }
  }
}
