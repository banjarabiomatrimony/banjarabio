import 'package:flutter/material.dart';
import 'package:banjarabio/l10n/app_localizations.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';

import 'package:banjarabio/widgets/custom_icon_widget.dart';

// Extracted widgets
import 'package:banjarabio/presentation/biodata_creation_screen/widgets/shared/biodata_text_field.dart';
import 'package:banjarabio/presentation/biodata_creation_screen/widgets/shared/biodata_dropdown_field.dart';
import 'package:banjarabio/presentation/biodata_creation_screen/widgets/personal_details/personal_section_header.dart';
import 'package:banjarabio/presentation/biodata_creation_screen/widgets/personal_details/premium_card_wrapper.dart';
import 'package:banjarabio/presentation/biodata_creation_screen/widgets/personal_details/gender_selector_widget.dart';
import 'package:banjarabio/presentation/biodata_creation_screen/widgets/personal_details/height_selector_widget.dart';
import 'package:banjarabio/presentation/biodata_creation_screen/widgets/personal_details/dob_field_widget.dart';
import 'package:banjarabio/presentation/biodata_creation_screen/widgets/personal_details/disability_status_widget.dart';
import 'package:banjarabio/presentation/biodata_creation_screen/widgets/personal_details/surname_gotra_selector_widget.dart';

/// Personal details section for biodata creation
/// Handles name, age, height, and surname selection
class PersonalDetailsSection extends StatefulWidget {
  final Map<String, dynamic> formData;
  final bool isAdminEdit;
  final bool isLite;
  final Function(String, dynamic) onUpdate;
  final Function(Map<String, dynamic>) onBatchUpdate;
  final Function(bool) onValidationChange;
  final ScrollController scrollController;

  const PersonalDetailsSection({
    super.key,
    required this.formData,
    this.isAdminEdit = false,
    this.isLite = false,
    required this.onUpdate,
    required this.onBatchUpdate,
    required this.onValidationChange,
    required this.scrollController,
  });

  @override
  State<PersonalDetailsSection> createState() => _PersonalDetailsSectionState();
}

class _PersonalDetailsSectionState extends State<PersonalDetailsSection> {
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _ageController = TextEditingController();
  final _customSurnameController = TextEditingController();

  DateTime? _selectedDOB;
  final _birthPlaceController = TextEditingController();
  final _birthTimeController = TextEditingController();
  String? _selectedSurname;
  String? _selectedGender;
  int _heightFeet = 5;
  int _heightInches = 0;

  String? _selectedComplexion;
  String? _selectedBloodGroup;
  String? _selectedMaritalStatus = 'Never Married';
  bool _showCustomSurname = false;

  String? _selectedGotra;
  List<String> _gotraOptions = [];
  bool _isDisabled = false;

  String? _selectedProfileBy;
  List<Map<String, String>> _getProfileByOptions(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return [
      {'key': 'Self', 'label': l10n?.self ?? 'Self', 'icon': 'person'},
      {'key': 'Son', 'label': l10n?.son ?? 'Son', 'icon': 'male'},
      {'key': 'Daughter', 'label': l10n?.daughter ?? 'Daughter', 'icon': 'female'},
      {'key': 'Brother', 'label': l10n?.brother ?? 'Brother', 'icon': 'boy'},
      {'key': 'Sister', 'label': l10n?.sister ?? 'Sister', 'icon': 'girl'},
      {'key': 'Friend', 'label': l10n?.friend ?? 'Friend', 'icon': 'people'},
      {'key': 'Relative', 'label': l10n?.relative ?? 'Relative', 'icon': 'family_restroom'},
    ];
  }

  // Complexion options (Stable keys)
  final List<String> _complexionKeys = [
    'Very Fair',
    'Fair',
    'Wheatish',
    'Dusky',
    'Dark',
  ];

  String _getLocalizedComplexion(BuildContext context, String key) {
    final l10n = AppLocalizations.of(context);
    switch (key) {
      case 'Very Fair': return l10n?.veryFair ?? 'Very Fair';
      case 'Fair': return l10n?.fair ?? 'Fair';
      case 'Wheatish': return l10n?.wheatish ?? 'Wheatish';
      case 'Dusky': return l10n?.dusky ?? 'Dusky';
      case 'Dark': return l10n?.dark ?? 'Dark';
      default: return key;
    }
  }

  // Blood group options (Stable keys - no localization needed)
  final List<String> _bloodGroupOptions = [
    'A+', 'A-', 'B+', 'B-', 'O+', 'O-', 'AB+', 'AB-',
  ];

  // Marital status options (Stable keys)
  final List<String> _maritalStatusKeys = [
    'Never Married',
    'Awaiting Divorce',
    'Divorced',
    'Widowed',
    'Annulled',
  ];

  String _getLocalizedMaritalStatus(BuildContext context, String key) {
    final l10n = AppLocalizations.of(context);
    switch (key) {
      case 'Never Married': return l10n?.neverMarried ?? 'Never Married';
      case 'Awaiting Divorce': return l10n?.awaitingDivorce ?? 'Awaiting Divorce';
      case 'Divorced': return l10n?.divorced ?? 'Divorced';
      case 'Widowed': return l10n?.widowed ?? 'Widowed';
      case 'Annulled': return l10n?.annulled ?? 'Annulled';
      default: return key;
    }
  }

  // Predefined Banjara community surnames
  final List<String> _banjaraSurnames = [
    'Rathod',
    'Chauhan',
    'Jadhav',
    'Pawar',
    'Ade',
    'Naik',
    'Other',
  ];

  // Surname to Gotra mapping
  final Map<String, List<String>> _surnameGotraMap = {
    'Rathod': [
      'Aaloth',
      'Bhaanaavath',
      'Bhilavath',
      'Degaavath',
      'Karamtoth',
      'Depaavath',
      'Devsoth',
      'Kodaavath',
      'Kumaavath',
      'Kholavath',
      'Meghaavath',
      'Meraajoth',
      'Meraavath',
      'Nenaavath',
      'Paathloth / Dungaavath',
      'Jhandavath',
      'Kaanaavath',
      'Khaatroth',
      'Khethaavath',
      'Khilaavath',
      'Pithaavath',
      'Raajavath',
      'Raamavath',
      'Raathla / Phulia',
      'Ranasoth / Ranavath',
      'Sangaavath',
      'Sotki',
    ],
    'Pawar': [
      'Aamgoth',
      'Aivath / Pammar',
      'Baanni',
      'Chaivoth / Pammar',
      'Injraavath',
      'Vankdoth',
      'Inloth Pammar',
      'Jharapla',
      'Lunsavath / Nunsavath',
      'Pamaadiyaa',
      'Tarabaanni',
      'Vislaavath',
    ],
    'Chauhan': [
      'Dumaavath / Chauradiya',
      'Keluth',
      'Lavidiya / Lavhadiya',
      'Korra / Kurra / Mood',
      'Paalthyaa',
      'Sabavat',
    ],
    'Jadhav': [
      'Ajmera',
      'Baadaavath',
      'Barmaavath',
      'Bhagvaandas',
      'Bharoth',
      'Bodaa',
      'Dhaaraavath',
      'Dungaroth',
      'Gangaavath',
      'Goraam',
      'Gugloth',
      'Halaavath',
      'Jaadhav',
      'Jaloth',
      'Jayt',
      'Kagla',
      'Kunsoth',
      'Lokaavath',
      'Lonaavath',
      'Loolaavath',
      'Maaloth',
      'Mohandas',
      'Pipaavath',
      'Poosnamal',
      'Salaavath',
      'Sejaavath',
      'Tejaavath',
      'Tepaavath',
      'Teraavath',
      'Tuvar',
      'Undaavath',
      'VaderJhaad',
      'Vadithya Jaajigiri',
    ],
    'Ade': [
      'Aadoth',
      'Ade',
      'Baanoth',
      'Bhojaavath',
      'Daanaavath',
      'Dharmasoth',
      'Dheeravath',
      'Jaatroth',
      'Karnaavath',
      'Kuntaavath',
      'Lavori',
      'Mudavath',
      'Paanaavath',
      'Rupavath',
      'Sabdasoth',
    ],
  };

  @override
  void initState() {
    super.initState();
    _initializeData();
    _nameController.addListener(_validateForm);
    _phoneController.addListener(_validateForm);
    _ageController.addListener(_validateForm);
    _customSurnameController.addListener(_validateForm);
    // Trigger initial validation for Edit Mode / Pre-filled data
    WidgetsBinding.instance.addPostFrameCallback((_) => _validateForm());
  }

  void _initializeData() {
    final name = widget.formData['name']?.toString() ?? '';
    if (_nameController.text != name) {
      _nameController.text = name;
    }

    final age = widget.formData['age']?.toString() ?? '';
    if (_ageController.text != age) {
      _ageController.text = age;
    }

    final phone = widget.formData['phone_number']?.toString() ?? '';
    if (_phoneController.text != phone) {
      _phoneController.text = phone;
    }

    // Safe DateTime parsing (handles both DateTime and String)
    final dynamic dob = widget.formData['dateOfBirth'];
    if (dob == null) {
      _selectedDOB = null;
    } else if (dob is DateTime) {
      _selectedDOB = dob;
    } else if (dob is String && dob.isNotEmpty) {
      _selectedDOB = DateTime.tryParse(dob);
    } else {
      _selectedDOB = null;
    }

    // Ensure empty string is treated as null for dropdown
    final surname = widget.formData['surname']?.toString();
    _selectedSurname = (surname != null && surname.isNotEmpty) ? surname : null;

    if (_selectedSurname != null) {
      if (!_banjaraSurnames.contains(_selectedSurname)) {
        _showCustomSurname = true;
        if (_customSurnameController.text != _selectedSurname) {
          _customSurnameController.text = _selectedSurname!;
        }
        _selectedSurname = 'Other';
      } else {
        _showCustomSurname = false;
        _customSurnameController.clear();
      }
      _gotraOptions = _getGotrasForSurname(
        _showCustomSurname ? _customSurnameController.text : _selectedSurname!,
      );
    } else {
      _showCustomSurname = false;
      _gotraOptions = [];
    }

    final gotra = widget.formData['gotra']?.toString();
    if (gotra != null && gotra.isNotEmpty) {
      if (_gotraOptions.contains(gotra)) {
        _selectedGotra = gotra;
      } else {
        _gotraOptions = [..._gotraOptions, gotra];
        _selectedGotra = gotra;
      }
    } else {
      _selectedGotra = null;
    }

    final createdBy = (widget.formData['profileCreatedBy'] ?? widget.formData['profile_created_by'])?.toString();
    _selectedProfileBy = (createdBy != null && createdBy.isNotEmpty) ? createdBy : null;

    final gender = widget.formData['gender']?.toString();
    _selectedGender = (gender != null && gender.isNotEmpty) ? gender : null;
    _selectedComplexion = widget.formData['complexion']?.toString();
    _selectedBloodGroup = widget.formData['bloodGroup']?.toString();
    _selectedMaritalStatus =
        widget.formData['maritalStatus']?.toString() ?? 'Never Married';

    final heightStr = widget.formData['height']?.toString() ?? '';
    if (heightStr.isNotEmpty) {
      final parts = heightStr.split("'");
      if (parts.length == 2) {
        _heightFeet = int.tryParse(parts[0]) ?? 5;
        _heightInches = int.tryParse(parts[1].replaceAll('"', '')) ?? 0;
      }
    }

    final birthPlace = widget.formData['birthPlace'] ?? '';
    if (_birthPlaceController.text != birthPlace) {
      _birthPlaceController.text = birthPlace;
    }

    final birthTime = widget.formData['birthTime'] ?? '';
    if (_birthTimeController.text != birthTime) {
      _birthTimeController.text = birthTime;
    }

    _isDisabled = widget.formData['isDisabled'] as bool? ?? widget.formData['is_disabled'] as bool? ?? false;
  }

  @override
  void didUpdateWidget(covariant PersonalDetailsSection oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.formData != oldWidget.formData ||
        widget.isLite != oldWidget.isLite ||
        widget.isAdminEdit != oldWidget.isAdminEdit) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          _initializeData();
          _validateForm();
        }
      });
    }
  }

  @override
  void dispose() {
    _nameController.removeListener(_validateForm);
    _phoneController.removeListener(_validateForm);
    _ageController.removeListener(_validateForm);
    _customSurnameController.removeListener(_validateForm);
    _nameController.dispose();
    _phoneController.dispose();
    _ageController.dispose();
    _customSurnameController.dispose();
    _birthPlaceController.dispose();
    _birthTimeController.dispose();
    super.dispose();
  }

  void _validateForm() {
    if (widget.isAdminEdit) {
      widget.onValidationChange(true);
      return;
    }
    final isGotraRequired = _gotraOptions.isNotEmpty;

    final hasValidSurname = _selectedSurname != null &&
        (_selectedSurname != 'Other' || _customSurnameController.text.trim().isNotEmpty);

    // Core identity fields required in both lite and full modes
    final coreValid =
        _nameController.text.trim().isNotEmpty &&
        _phoneController.text.trim().length >= 10 &&
        hasValidSurname &&
        _selectedGender != null &&
        (!isGotraRequired || (_selectedGotra != null && _selectedGotra!.isNotEmpty));

    if (widget.isLite) {
      // Lite signup: skip age, height, profileCreatedBy validation
      widget.onValidationChange(coreValid);
      return;
    }

    // Full mode: also require age and profileCreatedBy
    final isValid = coreValid &&
        _ageController.text.trim().isNotEmpty &&
        _selectedProfileBy != null;
    widget.onValidationChange(isValid);
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDOB ?? DateTime(DateTime.now().year - 20),
      firstDate: DateTime(1950),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: Theme.of(context).colorScheme.primary,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _selectedDOB) {
      setState(() {
        _selectedDOB = picked;
        // Auto-calculate age
        final now = DateTime.now();
        int age = now.year - picked.year;
        if (now.month < picked.month || (now.month == picked.month && now.day < picked.day)) {
          age--;
        }
        if (age >= 0) {
          _ageController.text = age.toString();
          widget.onUpdate('age', age.toString());
        }
      });
      widget.onUpdate('dateOfBirth', picked);
      _validateForm();
    }
  }

  List<String> _getGotrasForSurname(String surname) {
    return _surnameGotraMap[surname] ?? [];
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // 📃 Define our premium sections
    final sections = <Widget>[
      // 📇 Card 1: Basic Identity & Gender
      PremiumCardWrapper(
        title: 'Basic Information',
        icon: Icons.person_outline_rounded,
        children: [
          // ProfileCreatedBy is optional in lite mode, shown but not required
          if (!widget.isLite)
            BiodataDropdownField(
              label: AppLocalizations.of(context)?.profileCreatedByTitle ?? 'Profile Created By',
              value: _selectedProfileBy,
              items: _getProfileByOptions(context).map((e) => DropdownMenuItem(
                value: e['key'],
                child: Row(
                  children: [
                    CustomIconWidget(
                      iconName: e['icon']!,
                      color: theme.colorScheme.primary.withValues(alpha: 0.6),
                      size: 18,
                    ),
                    SizedBox(width: 3.w),
                    Text(e['label']!, overflow: TextOverflow.ellipsis),
                  ],
                ),
              )).toList(),
              icon: 'account_circle',
              onChanged: (val) {
                setState(() {
                  _selectedProfileBy = val;
                });
                widget.onUpdate('profileCreatedBy', val);
                _validateForm();
              },
            ),
          if (!widget.isLite) SizedBox(height: 2.5.h),
          GenderSelectorWidget(
            selectedGender: _selectedGender,
            isAdminEdit: widget.isAdminEdit,
            onGenderSelected: (gender) {
              setState(() => _selectedGender = gender);
              widget.onUpdate('gender', gender);
              _validateForm();
            },
          ),
        ],
      ),

      // 👤 Card 2: Personal Identity
      PremiumCardWrapper(
        title: 'Identity Details',
        icon: Icons.badge_outlined,
        children: [
          BiodataTextField(
            controller: _nameController,
            label: AppLocalizations.of(context)?.fullName ?? 'Full Name',
            hint: AppLocalizations.of(context)?.enterFullName ?? 'Enter your full name',
            icon: 'badge',
            required: true,
            isAdminEdit: widget.isAdminEdit,
            onChanged: (value) => widget.onUpdate('name', value),
          ),
          SizedBox(height: 2.5.h),
          BiodataTextField(
            controller: _phoneController,
            label: AppLocalizations.of(context)?.mobileNumber ?? 'Mobile Number',
            hint: '9876543210',
            icon: 'phone_android',
            required: true,
            isAdminEdit: widget.isAdminEdit,
            keyboardType: TextInputType.phone,
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
              LengthLimitingTextInputFormatter(10),
            ],
            onChanged: (value) => widget.onUpdate('phone_number', value),
          ),
          SizedBox(height: 2.5.h),
          SurnameGotraSelectorWidget(
            selectedSurname: _selectedSurname,
            selectedGotra: _selectedGotra,
            showCustomSurname: _showCustomSurname,
            isAdminEdit: widget.isAdminEdit,
            customSurnameController: _customSurnameController,
            gotraOptions: _gotraOptions,
            banjaraSurnames: _banjaraSurnames,
            onSurnameChanged: (value) {
              setState(() {
                _selectedSurname = value;
                _showCustomSurname = value == 'Other';
                _selectedGotra = null;
                if (value != null && value != 'Other') {
                  _gotraOptions = _getGotrasForSurname(value);
                  widget.onUpdate('surname', value);
                } else if (value == 'Other') {
                  _gotraOptions = [];
                } else {
                  _gotraOptions = [];
                  widget.onUpdate('surname', null);
                }
              });
              widget.onUpdate('gotra', null);
              _validateForm();
            },
            onGotraChanged: (value) {
              setState(() => _selectedGotra = value);
              widget.onUpdate('gotra', value);
              _validateForm();
            },
            onCustomSurnameChanged: (value) {
              widget.onUpdate('surname', value);
            },
          ),
        ],
      ),

      // 📅 Card 3: Chronology & Birth — HIDDEN in lite mode
      if (!widget.isLite)
        PremiumCardWrapper(
          title: AppLocalizations.of(context)?.birthDetails ?? 'Birth & Age Details',
          icon: Icons.calendar_today_outlined,
          children: [
            BiodataTextField(
              controller: _ageController,
              label: AppLocalizations.of(context)?.age ?? 'Age',
              hint: '25',
              icon: 'cake',
              required: true,
              isAdminEdit: widget.isAdminEdit,
              keyboardType: TextInputType.number,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                LengthLimitingTextInputFormatter(2),
              ],
              onChanged: (value) => widget.onUpdate('age', value),
            ),
            SizedBox(height: 2.h),
            DobFieldWidget(
              selectedDOB: _selectedDOB,
              onTap: () => _selectDate(context),
            ),
            SizedBox(height: 2.2.h),
            // 📍 Simplified Birth Details (Permanently Visible)
            Row(
              children: [
                Expanded(
                  child: BiodataTextField(
                    controller: _birthPlaceController,
                    label: AppLocalizations.of(context)?.birthPlace ?? 'Birth Place',
                    hint: 'Nagpur',
                    icon: 'location_on',
                    required: false,
                    isAdminEdit: widget.isAdminEdit,
                    onChanged: (value) => widget.onUpdate('birthPlace', value),
                  ),
                ),
                SizedBox(width: 4.w),
                Expanded(
                  child: BiodataTextField(
                    controller: _birthTimeController,
                    label: AppLocalizations.of(context)?.birthTime ?? 'Birth Time',
                    hint: '10:30 AM',
                    icon: 'schedule',
                    required: false,
                    isAdminEdit: widget.isAdminEdit,
                    onChanged: (value) => widget.onUpdate('birthTime', value),
                  ),
                ),
              ],
            ),
          ],
        ),

      // 📏 Card 4: Physical & Social Attributes — HIDDEN in lite mode
      if (!widget.isLite)
        PremiumCardWrapper(
          title: AppLocalizations.of(context)?.physicalSocialAttributes ?? 'Physical & Social',
          icon: Icons.straighten_rounded,
          children: [
            HeightSelectorWidget(
              initialFeet: _heightFeet,
              initialInches: _heightInches,
              onHeightChanged: (heightStr) {
                widget.onUpdate('height', heightStr);
              },
            ),
            SizedBox(height: 3.h),
            Row(
              children: [
                Expanded(
                  child: BiodataDropdownField(
                    label: AppLocalizations.of(context)?.complexion ?? 'Complexion',
                    value: _selectedComplexion,
                    items: _complexionKeys.map((key) => DropdownMenuItem(
                      value: key,
                      child: Row(
                        children: [
                          CustomIconWidget(
                            iconName: 'face',
                            color: theme.colorScheme.primary.withValues(alpha: 0.6),
                            size: 18,
                          ),
                          SizedBox(width: 2.w),
                          Text(_getLocalizedComplexion(context, key), overflow: TextOverflow.ellipsis),
                        ],
                      ),
                    )).toList(),
                    icon: 'brush',
                    onChanged: (val) {
                      setState(() => _selectedComplexion = val);
                      widget.onUpdate('complexion', val);
                    },
                  ),
                ),
                SizedBox(width: 4.w),
                Expanded(
                  child: BiodataDropdownField(
                    label: AppLocalizations.of(context)?.bloodGroup ?? 'Blood Group',
                    value: _selectedBloodGroup,
                    items: _bloodGroupOptions.map((key) => DropdownMenuItem(
                      value: key,
                      child: Row(
                        children: [
                          CustomIconWidget(
                            iconName: 'bloodtype',
                            color: Colors.red.withValues(alpha: 0.7),
                            size: 18,
                          ),
                          SizedBox(width: 2.w),
                          Text(key, overflow: TextOverflow.ellipsis),
                        ],
                      ),
                    )).toList(),
                    icon: 'vaccines',
                    onChanged: (val) {
                      setState(() => _selectedBloodGroup = val);
                      widget.onUpdate('bloodGroup', val);
                    },
                  ),
                ),
              ],
            ),
            SizedBox(height: 2.5.h),
            BiodataDropdownField(
              label: AppLocalizations.of(context)?.maritalStatus ?? 'Marital Status',
              value: _selectedMaritalStatus,
              items: _maritalStatusKeys.map((key) {
                String iconPath = 'favorite';
                if (key == 'Awaiting Divorce') iconPath = 'gavel';
                if (key == 'Divorced') iconPath = 'content_cut';
                if (key == 'Widowed') iconPath = 'person_off';
                if (key == 'Annulled') iconPath = 'layers_clear';
                
                return DropdownMenuItem(
                  value: key,
                  child: Row(
                    children: [
                      CustomIconWidget(
                        iconName: iconPath,
                        color: theme.colorScheme.primary.withValues(alpha: 0.6),
                        size: 18,
                      ),
                      SizedBox(width: 3.w),
                      Text(_getLocalizedMaritalStatus(context, key), overflow: TextOverflow.ellipsis),
                    ],
                  ),
                );
              }).toList(),
              icon: 'favorite',
              onChanged: (val) {
                setState(() => _selectedMaritalStatus = val);
                widget.onUpdate('maritalStatus', val);
              },
            ),
            SizedBox(height: 2.5.h),
            DisabilityStatusWidget(
              isDisabled: _isDisabled,
              onChanged: (val) {
                setState(() => _isDisabled = val);
                widget.onUpdate('isDisabled', val);
              },
            ),
          ],
        ),
    ];

    return SingleChildScrollView(
      controller: widget.scrollController,
      physics: const BouncingScrollPhysics(),
      padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 🏆 Header Section
          const PersonalSectionHeader(),
          SizedBox(height: 3.h),

          // 🧱 Animated Sections
          ...sections.asMap().entries.map((entry) {
            final int idx = entry.key;
            final Widget section = entry.value;

            return TweenAnimationBuilder<double>(
              duration: Duration(milliseconds: 600 + (idx * 150)),
              tween: Tween(begin: 0.0, end: 1.0),
              curve: Curves.easeOutQuart,
              builder: (context, value, child) {
                return Opacity(
                  opacity: value,
                  child: Transform.translate(
                    offset: Offset(0, 30 * (1 - value)),
                    child: Padding(
                      padding: EdgeInsets.only(bottom: 2.h),
                      child: child,
                    ),
                  ),
                );
              },
              child: section,
            );
          }),
          
          SizedBox(height: 4.h),
        ],
      ),
    );
  }
}
