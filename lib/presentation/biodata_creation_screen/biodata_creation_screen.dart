import 'dart:async';
import 'dart:io' as io;
import 'package:banjarabio/l10n/app_localizations.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import 'package:banjarabio/core/app_export.dart';
import 'package:banjarabio/core/models/profile_model.dart';
import 'package:banjarabio/core/models/sibling_model.dart';
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
  final int _totalSteps = 5;
  bool _isLoading = false;

  // Debouncing for auto-save
  Timer? _debounceTimer;
  final Duration _debounceDuration = const Duration(seconds: 2);

  // Scroll controller to hide selection toolbar on scroll (Mitigates Oppo/Android 14 crash)
  final ScrollController _scrollController = ScrollController();

  bool _isEditMode = false;
  bool _isAdminEdit = false; // Admin editing another user's profile
  bool _isInitialDataLoaded = false;
  bool _isPopulating = false; // Flag to prevent validation loops during population
  bool _isPointerDown = false; // Prevents programmatic scrolls from dismissing keyboard
  ProfileModel? _existingProfile;

  final ProfileRepository _profileRepository = ProfileRepository();
  final PhotoRepository _photoRepository = PhotoRepository();

  // Form data storage
  Map<String, dynamic> _formData = {
    'name': '',
    'phone_number': '',
    'surname': '',
    'gotra': '',
    'age': '',
    'dateOfBirth': null as DateTime?,
    'gender': 'Female',
    'height': "5'5\"",
    'complexion': '',
    'bloodGroup': '',
    'maritalStatus': 'Never Married',
    'education': '',
    'profession': '',
    'annualIncome': '',
    'state': '',
    'district': '',
    'taluka': '',
    'village': '',
    'location': '',
    'nativePlace': '',
    'fatherName': '',
    'fatherOccupation': '',
    'motherName': '',
    'jobDetails': '',
    'company': '',
    'siblingsCount': '0',
    'sisterCount': '0',
    'brotherCount': '0',
    'siblings': <SiblingModel>[],
    'birthPlace': '',
    'birthTime': '',
    'educationDetails': '',
    'familyType': '',
    'familyStatus': '',
    'marriageReadiness': true,
    'aboutSelf': '',
    'partnerExpectations': '',
    'photos': <String>[],
    'tempPhotos': <String>[], // Store temporary photo paths
  };

  // Validation states
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
        debugPrint('BiodataCreationScreen: Hiding keyboard on manual scroll');
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
    if (draft != null) {
      // If we are in edit mode, ensure draft matches this profile
      if (_isEditMode && _existingProfile != null) {
        if (draft['id'] != _existingProfile!.id) {
          debugPrint('Draft ID mismatch, not loading');
          return;
        }
      } else if (_isEditMode && !draft.containsKey('id')) {
        // Edit mode but draft has no ID... might be risky
        return;
      } else if (!_isEditMode && draft.containsKey('id')) {
        // Create mode but draft has an ID (it was an edit draft)
        return;
      }

      debugPrint('BiodataCreationScreen: Loading draft data');
      _populateFormFromMap(draft);
      if (mounted) {
        final l10n = AppLocalizations.of(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              l10n?.biodataDraftRestored ?? 'Biodata draft restored!',
            ),
            behavior: SnackBarBehavior.floating,
            action: SnackBarAction(
              label: l10n?.undo ?? 'Undo',
              onPressed: () {
                if (!mounted) return;
                setState(() {
                  _initializeForm();
                });
              },
            ),
          ),
        );
      }
    }
  }

  void _initializeForm() {
    _formData = {
      'name': '',
      'phone_number': '',
      'surname': '',
      'gotra': '',
      'age': '',
      'dateOfBirth': null as DateTime?,
      'gender': 'Female',
      'height': "5'5\"",
      'complexion': '',
      'bloodGroup': '',
      'maritalStatus': 'Never Married',
      'education': '',
      'profession': '',
      'annualIncome': '',
      'state': '',
      'district': '',
      'taluka': '',
      'village': '',
      'location': '',
      'nativePlace': '',
      'fatherName': '',
      'fatherOccupation': '',
      'motherName': '',
      'jobDetails': '',
      'company': '',
      'siblingsCount': '0',
      'sisterCount': '0',
      'brotherCount': '0',
      'siblings': <SiblingModel>[],
      'birthPlace': '',
      'birthTime': '',
      'educationDetails': '',
      'familyType': '',
      'familyStatus': '',
      'marriageReadiness': true,
      'aboutSelf': '',
      'partnerExpectations': '',
      'photos': <String>[],
      'tempPhotos': <String>[],
    };
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
          debugPrint('Error deleting temp file $path: $e');
        }
      }
    } catch (e) {
      debugPrint('Error in cleanupTempFiles: $e');
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
    final missingFields = _getMissingFields(step: _currentStep);
 
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

      debugPrint('BiodataCreationScreen: Auto-saving draft...');
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

      debugPrint('BiodataCreationScreen: Background auto-save for admin/staff: ${profileData.keys}');
      
      final currentProfile = SessionManager.instance.currentProfile;
      final currentRole = currentProfile?.role ?? 'user';
      final isStaff = currentRole == 'staff' || currentRole == 'telecaller';
      
      if (isStaff) {
        final staffRes = await StaffRepository().updateLeadProfile(
          _existingProfile!.userId,
          profileData,
        );
        if (!staffRes.isSuccess) {
          debugPrint('BiodataCreationScreen: Staff background save failed: ${staffRes.errorMessage}');
        } else {
          debugPrint('BiodataCreationScreen: Staff background save successful');
        }
      } else if (currentRole == 'admin' || AdminConfig.isAdminEmail(AppSupabaseClient.currentUser?.email ?? '')) {
        await AdminRepository().adminUpdateProfile(
          _existingProfile!.userId,
          profileData,
        );
        debugPrint('BiodataCreationScreen: Admin background save successful');
      } else {
        debugPrint('BiodataCreationScreen: Background save skipped - role "$currentRole" not authorized');
      }
    } catch (e) {
      debugPrint('BiodataCreationScreen: Background auto-save failed: $e');
    }
  }

  /// Builds a sparse map of profile data for updates.
  /// Only includes fields that are present in _formData.
  Map<String, dynamic> _buildSparseProfileData() {
    final userId = _isAdminEdit && _existingProfile != null
        ? _existingProfile!.userId
        : AppSupabaseClient.currentUserId;

    final data = <String, dynamic>{
      'user_id': userId,
    };

    if (_isAdminEdit) {
      data['target_user_id'] = userId;
    }

    // Helper to map and add if present
    void addIfPresent(String formKey, String dbKey, {dynamic Function(dynamic)? transform}) {
      if (_formData.containsKey(formKey)) {
        final val = _formData[formKey];
        data[dbKey] = transform != null ? transform(val) : val;
      }
    }

    addIfPresent('profileCreatedBy', 'profile_created_by');
    addIfPresent('name', 'full_name');
    addIfPresent('phone_number', 'phone_number');
    addIfPresent('surname', 'surname');
    addIfPresent('gotra', 'gotra');
    addIfPresent('age', 'age', transform: (v) => int.tryParse(v.toString()));
    addIfPresent('dateOfBirth', 'date_of_birth', transform: (v) => (v as DateTime?)?.toIso8601String());
    addIfPresent('gender', 'gender');
    addIfPresent('height', 'height');
    addIfPresent('complexion', 'complexion');
    addIfPresent('bloodGroup', 'blood_group');
    addIfPresent('maritalStatus', 'marital_status');
    addIfPresent('education', 'education');
    addIfPresent('profession', 'profession');
    addIfPresent('annualIncome', 'annual_income');
    addIfPresent('state', 'state');
    addIfPresent('district', 'district');
    addIfPresent('taluka', 'taluka');
    addIfPresent('village', 'village');
    addIfPresent('permanent_location', 'permanent_location');
    addIfPresent('permanent_location', 'current_location');
    addIfPresent('nativePlace', 'native_place');
    addIfPresent('birthPlace', 'birth_place');
    addIfPresent('birthTime', 'birth_time');
    addIfPresent('educationDetails', 'education_details');
    addIfPresent('jobDetails', 'job_details');
    addIfPresent('company', 'company');
    addIfPresent('fatherName', 'father_name');
    addIfPresent('fatherOccupation', 'father_occupation');
    addIfPresent('motherName', 'mother_name');
    addIfPresent('motherOccupation', 'mother_occupation');
    addIfPresent('siblingsCount', 'siblings_count', transform: (v) => int.tryParse(v.toString()));
    addIfPresent('sisterCount', 'sister_count', transform: (v) => int.tryParse(v.toString()));
    addIfPresent('brotherCount', 'brother_count', transform: (v) => int.tryParse(v.toString()));
    
    if (_formData.containsKey('siblings')) {
      data['siblings_data'] = ((_formData['siblings'] ?? []) as List).map((s) {
        if (s is SiblingModel) return s.toJson();
        if (s is Map<String, dynamic>) return s;
        return {};
      }).toList();
    }

    addIfPresent('familyType', 'family_type');
    addIfPresent('familyStatus', 'family_status');
    
    if (_formData.containsKey('marriageReadiness')) {
      final isMarriageReady = _formData['marriageReadiness'] == true;
      data['marriage_readiness'] = isMarriageReady ? 'Ready for marriage' : 'Not ready yet';
    }

    addIfPresent('aboutSelf', 'about_self');
    addIfPresent('partnerExpectations', 'partner_expectations');
    addIfPresent('expectation', 'expectation');

    data['updated_at'] = DateTime.now().toIso8601String();

    return data;
  }

  void _populateFormFromMap(Map<String, dynamic> data) {
    debugPrint('BiodataCreationScreen: Populating form from map data');

    try {
      final List<String> photoUrls = [];

      // Extract photo URLs
      if (data.containsKey('photos') && data['photos'] is List) {
        final List<dynamic> photoData = data['photos'] as List<dynamic>;
        for (final p in photoData) {
          if (p is Map<String, dynamic>) {
            if (p['url'] != null && p['url'] is String) {
              photoUrls.add(p['url'] as String);
            } else if (p['image_url'] != null && p['image_url'] is String) {
              photoUrls.add(p['image_url'] as String);
            }
          } else if (p is String && p.isNotEmpty) {
            photoUrls.add(p);
          }
        }
      }

      setState(() {
        _isPopulating = true; // Block validation callbacks
        final Map<String, dynamic> newData = Map<String, dynamic>.from(
          _formData,
        );

        newData['name'] =
            data['name']?.toString() ?? data['fullName']?.toString() ?? '';
        newData['phone_number'] = data['phone_number']?.toString() ?? '';
        newData['age'] = data['age']?.toString() ?? '';
        newData['height'] = data['height']?.toString() ?? '';
        newData['surname'] = data['surname']?.toString() ?? '';
        newData['gotra'] = data['gotra']?.toString() ?? '';
        newData['gender'] = data['gender']?.toString() ?? 'Female';
        newData['education'] = data['education']?.toString() ?? '';
        newData['profession'] = data['profession']?.toString() ?? '';
        newData['location'] =
            (data['location'] ?? data['current_location'])?.toString() ?? '';
        newData['aboutSelf'] =
            (data['aboutSelf'] ??
                    data['about'] ??
                    data['about_self'] ??
                    data['about_yourself'])
                ?.toString() ??
            '';
        newData['marriageReadiness'] =
            data['marriageReadiness'] == 'Ready for marriage' ||
            data['marriageReadiness'] == true;

        final dynamic dobData = data['dateOfBirth'] ?? data['dob'];
        if (dobData != null) {
          if (dobData is DateTime) {
            newData['dateOfBirth'] = dobData;
          } else {
            newData['dateOfBirth'] = DateTime.tryParse(dobData.toString());
          }
        }

        // Add other fields
        newData['complexion'] = data['complexion']?.toString() ?? '';
        newData['bloodGroup'] = data['bloodGroup']?.toString() ?? '';
        newData['maritalStatus'] =
            data['maritalStatus']?.toString() ?? 'Never Married';
        newData['annualIncome'] = data['annualIncome']?.toString() ?? '';
        newData['nativePlace'] =
            (data['nativePlace'] ?? data['native_place'])?.toString() ?? '';
        newData['state'] = data['state']?.toString() ?? '';
        newData['district'] = data['district']?.toString() ?? '';
        newData['taluka'] = data['taluka']?.toString() ?? '';
        newData['village'] = data['village']?.toString() ?? '';
        newData['fatherName'] = data['fatherName']?.toString() ?? '';
        newData['fatherOccupation'] =
            data['fatherOccupation']?.toString() ?? '';
        newData['motherName'] = data['motherName']?.toString() ?? '';
        newData['motherOccupation'] =
            data['motherOccupation']?.toString() ?? '';
        final dynamic sCount = data['siblingsCount'] ?? data['siblings_count'];
        if (sCount != null) {
          newData['siblingsCount'] = sCount.toString();
        } else if (data['siblings'] is List) {
          newData['siblingsCount'] = (data['siblings'] as List).length.toString();
        } else {
          newData['siblingsCount'] = data['siblings']?.toString() ?? '0';
        }
        newData['familyType'] = data['familyType']?.toString() ?? '';
        newData['familyStatus'] = data['familyStatus']?.toString() ?? '';
        newData['partnerExpectations'] =
            (data['partnerExpectations'] ?? data['partner_expectations'])
                ?.toString() ??
            '';
        newData['expectation'] = data['expectation']?.toString() ?? '';
        newData['birthPlace'] =
            (data['birthPlace'] ?? data['birth_place'])?.toString() ?? '';
        newData['birthTime'] =
            (data['birthTime'] ?? data['birth_time'])?.toString() ?? '';
        newData['educationDetails'] =
            (data['educationDetails'] ?? data['education_details'])
                ?.toString() ??
            '';
        // Safely extract sibling list, checking various possible keys
        final dynamic rawData =
            data['siblingsData'] ?? data['siblings_data'] ?? data['siblings'];

        final List rawSiblings = (rawData is List) ? rawData : [];
        newData['siblings'] = rawSiblings
            .map((s) {
              if (s is SiblingModel) return s;
              if (s is Map<String, dynamic>) return SiblingModel.fromJson(s);
              return null;
            })
            .whereType<SiblingModel>()
            .toList();
        newData['jobDetails'] =
            (data['jobDetails'] ?? data['job_details'])?.toString() ?? '';
        newData['company'] = data['company']?.toString() ?? '';

        // Set photos
        newData['photos'] = photoUrls;
        newData['tempPhotos'] = <String>[]; // Clear temp photos in edit mode

        // Update the reference
        _formData = newData;
        _isPopulating = false; // Unblock
      });
    } catch (e) {
      _isPopulating = false;
      debugPrint('Error populating form from map: $e');
    }
  }

  /// Returns a list of user-friendly names for missing required fields
  List<String> _getMissingFields({int? step}) {
    if (_isAdminEdit) return [];
    
    final l10n = AppLocalizations.of(context);
    if (l10n == null) return [];

    // If step is null, check all steps up to the current one
    final stepsToCheck =
        step != null ? [step] : List.generate(_currentStep + 1, (i) => i);

    final missingKeys = <String>[];
    for (final s in stepsToCheck) {
      missingKeys.addAll(
        OnboardingValidator.getMissingFields(step: s, formData: _formData),
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

      debugPrint('BiodataCreationScreen: Saving profile with data keys: ${profileData.keys}');

      final aboutSelf = _formData['aboutSelf']?.toString() ?? '';
      if (aboutSelf.isNotEmpty) {
        profileData['about_self'] = aboutSelf;
      }

      debugPrint('BiodataCreationScreen: Saving profile with data: $profileData');

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
          debugPrint('Profile saved successfully with ID: ${savedProfile.id}');

          // ✅ Photo Upload Logic (Only if on photo step or final save)
          if (_currentStep == 3 || isFinalSave) {
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

                  final uploadRes = await _photoRepository.uploadPhoto(
                    profileId: savedProfile.id,
                    imageFile: uploadFile!,
                    semanticLabel: 'Profile Photo ${i + 1}',
                  );

                  await uploadRes.fold(
                    onSuccess: (photo) async => debugPrint('Photo uploaded: ${photo.publicUrl}'),
                    onFailure: (error) async {
                      debugPrint('Failed to upload photo $photoPath: $error');
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(l10n?.failedToUploadPhoto(i + 1) ?? 'Failed to upload photo ${i + 1}'),
                            backgroundColor: Colors.orange,
                          ),
                        );
                      }
                    },
                  );
                } catch (e) {
                  debugPrint('Error uploading photo $photoPath: $e');
                }
              }
            }
          }

          // Clear cache to show fresh data
          _profileRepository.clearCache();
          // 🧬 PERFORMANCE: Removed global imageCache.clear() here.
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
      debugPrint('Error saving profile: $e');
      debugPrint('Stack trace: $stackTrace');
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
          final bool? shouldExit = await showDialog<bool>(
            context: context,
            builder: (context) => AlertDialog(
              title: Text(AppLocalizations.of(context)?.discardChanges ?? 'Discard Changes?'),
              content: Text(
                AppLocalizations.of(context)?.discardChangesBody ?? 'Are you sure you want to go back? Your progress is saved as a draft.',
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context, false),
                  child: Text(AppLocalizations.of(context)?.stay ?? 'Stay'),
                ),
                ElevatedButton(
                  onPressed: () => Navigator.pop(context, true),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: theme.colorScheme.error,
                    foregroundColor: Colors.white,
                  ),
                  child: Text(AppLocalizations.of(context)?.discard ?? 'Discard'),
                ),
              ],
            ),
          );

          if (shouldExit ?? false) {
            if (context.mounted) {
              if (_isAdminEdit) {
                // Admin Edit: Return to admin dashboard
                Navigator.of(context).pop();
              } else if (_isEditMode) {
                // Normal User Edit: Return to home screen, likely Profile Tab
                Navigator.of(context).pushNamedAndRemoveUntil(AppRoutes.home, (route) => false);
              } else {
                // New User / Cancelled creation: Return to auth
                Navigator.of(context).pushReplacementNamed(AppRoutes.authentication);
              }
            }
          }
        }
      },
      child: Listener(
        onPointerDown: (_) => _isPointerDown = true,
        onPointerUp: (_) => _isPointerDown = false,
        onPointerCancel: (_) => _isPointerDown = false,
        child: Scaffold(
          appBar: CustomAppBar(
            title: _isEditMode ? (AppLocalizations.of(context)?.editProfile ?? 'Edit Profile') : (AppLocalizations.of(context)?.createBiodata ?? 'Create Biodata'),
          subtitle: AppLocalizations.of(context)?.stepNOfTotal(_currentStep + 1, _totalSteps) ?? 'Step ${_currentStep + 1} of $_totalSteps',
          leading: _currentStep > 0
              ? IconButton(
                  icon: CustomIconWidget(
                    iconName: 'arrow_back',
                    color: theme.colorScheme.onSurface,
                  ),
                  onPressed: _previousStep,
                )
              : IconButton(
                  icon: CustomIconWidget(
                    iconName: 'close',
                    color: theme.colorScheme.onSurface,
                  ),
                  onPressed: () {
                    // Navigate to login screen for new users, home for existing, pop for admin
                    if (_isAdminEdit) {
                      Navigator.of(context).pop();
                    } else if (_isEditMode) {
                      Navigator.of(context).pushNamedAndRemoveUntil(AppRoutes.home, (route) => false);
                    } else {
                      Navigator.of(
                        context,
                      ).pushReplacementNamed(AppRoutes.authentication);
                    }
                  },
                ),
        ),
        body: Form(
          key: _formKey,
          child: Column(
            children: [
              // Progress indicator
              _buildProgressIndicator(theme),

              // Form sections - Replaced PageView with indexed renderer for memory performance
              Expanded(child: _buildCurrentSection()),

              // Navigation buttons
              _buildNavigationButtons(theme),
            ],
          ),
        ),
      ),
      ),
    );
  }

  Widget _buildProgressIndicator(ThemeData theme) {
    final percentage = _calculateCompletion();
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.5.h),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: theme.shadowColor.withValues(alpha: 0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                AppLocalizations.of(context)?.stepNOfTotal(_currentStep + 1, _totalSteps) ?? 'Step ${_currentStep + 1} of $_totalSteps',
                style: theme.textTheme.labelMedium?.copyWith(
                  color: theme.colorScheme.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                AppLocalizations.of(context)?.percentComplete(percentage) ?? '$percentage% Complete',
                style: theme.textTheme.labelSmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
          SizedBox(height: 1.h),
          Row(
            children: List.generate(_totalSteps, (index) {
              final isCurrent = index == _currentStep;
              String sectionKey = '';
              switch (index) {
                case 0: sectionKey = 'personal'; break;
                case 1: sectionKey = 'family'; break;
                case 2: sectionKey = 'education'; break;
                case 3: sectionKey = 'photo'; break;
                case 4: sectionKey = 'location'; break;
              }
              final isSectionValid = _sectionValidation[sectionKey] ?? false;

              return Expanded(
                child: Column(
                  children: [
                    Container(
                      height: 0.6.h,
                      margin: EdgeInsets.symmetric(horizontal: 0.5.w),
                      decoration: BoxDecoration(
                        color: isSectionValid || isCurrent
                            ? theme.colorScheme.primary
                            : theme.colorScheme.outline.withValues(alpha: 0.3),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    if (isSectionValid && !isCurrent)
                      Padding(
                        padding: const EdgeInsets.only(top: 2),
                        child: Icon(
                          Icons.check_circle,
                          size: 10,
                          color: theme.colorScheme.primary,
                        ),
                      ),
                  ],
                ),
              );
            }),
          ),
          SizedBox(height: 1.h),
          _buildProfileStrengthBadge(theme, percentage),
        ],
      ),
    );
  }

  Widget _buildProfileStrengthBadge(ThemeData theme, int percentage) {
    String badgeText;
    Color badgeColor;
    IconData badgeIcon;

    if (percentage < 40) {
      badgeText = AppLocalizations.of(context)?.bronze ?? 'Bronze';
      badgeColor = Colors.brown;
      badgeIcon = Icons.stars_outlined;
    } else if (percentage < 80) {
      badgeText = AppLocalizations.of(context)?.silver ?? 'Silver';
      badgeColor = Colors.grey;
      badgeIcon = Icons.stars;
    } else {
      badgeText = AppLocalizations.of(context)?.gold ?? 'Gold';
      badgeColor = Colors.orange;
      badgeIcon = Icons.stars;
    }

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 0.5.h),
      decoration: BoxDecoration(
        color: badgeColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: badgeColor.withValues(alpha: 0.5)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(badgeIcon, size: 14, color: badgeColor),
          SizedBox(width: 1.5.w),
          Text(
            AppLocalizations.of(context)?.profileStrengthLabel(badgeText) ?? 'Profile Strength: $badgeText',
            style: theme.textTheme.labelSmall?.copyWith(
              color: badgeColor,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  int _calculateCompletion() {
    return ProfileModel.calculateScore(_formData);
  }

  Widget _buildNavigationButtons(ThemeData theme) {
    return Container(
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: theme.shadowColor.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            if (_currentStep > 0)
              Expanded(
                child: OutlinedButton(
                  onPressed: _previousStep,
                  child: Text(AppLocalizations.of(context)?.previous ?? 'Previous'),
                ),
              ),
            if (_currentStep > 0) SizedBox(width: 3.w),
            Expanded(
              child: ElevatedButton(
                onPressed: _isLoading
                    ? null
                    : (_currentStep < _totalSteps - 1
                          ? _nextStep
                          : _validateAndSave),
                child: _isLoading
                    ? SizedBox(
                        height: 2.5.h,
                        width: 2.5.h,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: theme.colorScheme.onPrimary,
                        ),
                      )
                    : Text(
                        _currentStep < _totalSteps - 1
                            ? (AppLocalizations.of(context)?.next ?? 'Next')
                            : (_isEditMode ? (AppLocalizations.of(context)?.updateProfile ?? 'Update Profile') : (AppLocalizations.of(context)?.saveBiodata ?? 'Save Biodata')),
                        style: TextStyle(
                          color: theme.colorScheme.onPrimary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCurrentSection() {
    switch (_currentStep) {
      case 0:
        return PersonalDetailsSection(
          formData: _formData,
          isAdminEdit: _isAdminEdit,
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
      case 1:
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
      case 2:
        return EducationProfessionSection(
          formData: _formData,
          isAdminEdit: _isAdminEdit,
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
      case 3:
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
      case 4:
        return LocationPreferencesSection(
          formData: _formData,
          isAdminEdit: _isAdminEdit,
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
      default:
        return const SizedBox.shrink();
    }
  }
}
