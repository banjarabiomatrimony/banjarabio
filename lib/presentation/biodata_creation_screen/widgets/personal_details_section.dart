import 'package:flutter/material.dart';
import 'package:banjarabio/l10n/app_localizations.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';

import 'package:banjarabio/core/app_export.dart';
import 'package:banjarabio/widgets/custom_icon_widget.dart';

/// Personal details section for biodata creation
/// Handles name, age, height, and surname selection
class PersonalDetailsSection extends StatefulWidget {
  final Map<String, dynamic> formData;
  final bool isAdminEdit;
  final Function(String, dynamic) onUpdate;
  final Function(Map<String, dynamic>) onBatchUpdate;
  final Function(bool) onValidationChange;
  final ScrollController scrollController;

  const PersonalDetailsSection({
    super.key,
    required this.formData,
    this.isAdminEdit = false,
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
  
  late TextEditingController _feetController;
  late TextEditingController _inchesController;

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

  // Gender options (Stable keys)
  final List<String> _genderKeys = ['Female', 'Male'];

  String _getLocalizedGender(BuildContext context, String key) {
    final l10n = AppLocalizations.of(context);
    if (key == 'Female') return l10n?.female ?? 'Female';
    if (key == 'Male') return l10n?.male ?? 'Male';
    return key;
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
    _feetController = TextEditingController(text: _heightFeet.toString());
    _inchesController = TextEditingController(text: _heightInches.toString());
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
    if (gotra != null && gotra.isNotEmpty && _gotraOptions.contains(gotra)) {
      _selectedGotra = gotra;
    } else {
      _selectedGotra = null;
    }

    final createdBy = widget.formData['profileCreatedBy']?.toString();
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
        _feetController.text = _heightFeet.toString();
        _inchesController.text = _heightInches.toString();
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

    _isDisabled = widget.formData['isDisabled'] as bool? ?? false;
  }

  @override
  void didUpdateWidget(covariant PersonalDetailsSection oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.formData != oldWidget.formData) {
      _initializeData();
    }
  }

  @override
  void dispose() {
    _nameController.removeListener(_validateForm);
    _phoneController.removeListener(_validateForm);
    _ageController.removeListener(_validateForm);
    _customSurnameController.removeListener(_validateForm);
    _feetController.dispose();
    _inchesController.dispose();
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
    final isValid =
        _nameController.text.isNotEmpty &&
        _phoneController.text.length >= 10 &&
        _ageController.text.isNotEmpty &&
        _selectedSurname != null &&
        (_selectedSurname != 'Other' || _customSurnameController.text.isNotEmpty) &&
        _selectedGender != null &&
        _selectedProfileBy != null &&
        (!isGotraRequired || _selectedGotra != null);
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

  void _updateHeight() {
    final heightStr = "$_heightFeet'$_heightInches\"";
    widget.onUpdate('height', heightStr);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // 📃 Define our premium sections
    final sections = [
      // 📇 Card 1: Basic Identity & Gender
      _buildPremiumCard(
        theme: theme,
        title: 'Basic Information',
        icon: Icons.person_outline_rounded,
        children: [
          _buildDropdownField(
            theme: theme,
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
          SizedBox(height: 2.5.h),
          _buildGenderSelector(theme),
        ],
      ),

      // 👤 Card 2: Personal Identity
      _buildPremiumCard(
        theme: theme,
        title: 'Identity Details',
        icon: Icons.badge_outlined,
        children: [
          _buildTextField(
            controller: _nameController,
            label: AppLocalizations.of(context)?.fullName ?? 'Full Name',
            hint: AppLocalizations.of(context)?.enterFullName ?? 'Enter your full name',
            icon: 'badge',
            required: true,
            onChanged: (value) => widget.onUpdate('name', value),
            theme: theme,
          ),
          SizedBox(height: 2.5.h),
          _buildTextField(
            controller: _phoneController,
            label: AppLocalizations.of(context)?.mobileNumber ?? 'Mobile Number',
            hint: '9876543210',
            icon: 'phone_android',
            required: true,
            keyboardType: TextInputType.phone,
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
              LengthLimitingTextInputFormatter(10),
            ],
            onChanged: (value) => widget.onUpdate('phone_number', value),
            theme: theme,
          ),
          SizedBox(height: 2.5.h),
          _buildSurnameDropdown(theme),
          if (_showCustomSurname) ...[
            SizedBox(height: 2.h),
            _buildCustomSurnameField(theme),
          ],
          if (_gotraOptions.isNotEmpty) ...[
            SizedBox(height: 2.5.h),
            _buildGotraDropdown(theme),
          ],
        ],
      ),

      // 📅 Card 3: Chronology & Birth
      _buildPremiumCard(
        theme: theme,
        title: AppLocalizations.of(context)?.birthDetails ?? 'Birth & Age Details',
        icon: Icons.calendar_today_outlined,
        children: [
          _buildTextField(
            controller: _ageController,
            label: AppLocalizations.of(context)?.age ?? 'Age',
            hint: '25',
            icon: 'cake',
            required: true,
            keyboardType: TextInputType.number,
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
              LengthLimitingTextInputFormatter(2),
            ],
            onChanged: (value) => widget.onUpdate('age', value),
            theme: theme,
          ),
          SizedBox(height: 2.h),
          _buildDOBField(theme),
          SizedBox(height: 2.2.h),
          // 📍 Simplified Birth Details (Permanently Visible)
          Row(
            children: [
              Expanded(
                child: _buildTextField(
                  controller: _birthPlaceController,
                  label: AppLocalizations.of(context)?.birthPlace ?? 'Birth Place',
                  hint: 'Nagpur',
                  icon: 'location_on',
                  required: false,
                  onChanged: (value) => widget.onUpdate('birthPlace', value),
                  theme: theme,
                ),
              ),
              SizedBox(width: 4.w),
              Expanded(
                child: _buildTextField(
                  controller: _birthTimeController,
                  label: AppLocalizations.of(context)?.birthTime ?? 'Birth Time',
                  hint: '10:30 AM',
                  icon: 'schedule',
                  required: false,
                  onChanged: (value) => widget.onUpdate('birthTime', value),
                  theme: theme,
                ),
              ),
            ],
          ),
        ],
      ),

      // 📏 Card 4: Physical & Social Attributes
      _buildPremiumCard(
        theme: theme,
        title: AppLocalizations.of(context)?.physicalSocialAttributes ?? 'Physical & Social',
        icon: Icons.straighten_rounded,
        children: [
          _buildHeightSelector(theme),
          SizedBox(height: 3.h),
          Row(
            children: [
              Expanded(
                child: _buildDropdownField(
                  theme: theme,
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
                child: _buildDropdownField(
                  theme: theme,
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
          _buildDropdownField(
            theme: theme,
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
          _buildDisabilityStatus(theme),
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
          _buildHeader(theme, context),
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

  // ✨ PREMIUM UI HELPERS

  Widget _buildHeader(ThemeData theme, BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppLocalizations.of(context)?.personalDetails ?? 'Personal Details',
          style: theme.textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.w900,
            color: theme.colorScheme.primary,
          ),
        ),
        SizedBox(height: 0.8.h),
        Text(
          AppLocalizations.of(context)?.enterYourBasicInformationAsItAppearsInOf ?? 'Enter your basic information faithfully',
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.7),
            letterSpacing: 0.2,
          ),
        ),
      ],
    );
  }

  Widget _buildPremiumCard({
    required ThemeData theme,
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: theme.colorScheme.outline.withValues(alpha: 0.1),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.fromLTRB(4.w, 1.8.h, 4.w, 0.8.h),
            child: Row(
              children: [
                Icon(icon, color: theme.colorScheme.primary, size: 18),
                SizedBox(width: 2.5.w),
                Text(
                  title.toUpperCase(),
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: theme.colorScheme.primary,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.0,
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.5.h),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: children,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDOBField(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(AppLocalizations.of(context)?.dateOfBirth ?? 'Date of Birth', style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold)),
        SizedBox(height: 1.h),
        InkWell(
          onTap: () => _selectDate(context),
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: EdgeInsets.symmetric(
              horizontal: 4.w,
              vertical: 2.1.h,
            ),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: theme.colorScheme.outline.withValues(alpha: 0.3)),
            ),
            child: Row(
              children: [
                Icon(Icons.calendar_month_outlined, color: theme.colorScheme.onSurfaceVariant, size: 20),
                SizedBox(width: 3.w),
                Expanded(
                  child: Text(
                    _selectedDOB == null
                        ? AppLocalizations.of(context)?.selectDate ?? 'Select Date'
                        : "${_selectedDOB!.day.toString().padLeft(2, '0')}/${_selectedDOB!.month.toString().padLeft(2, '0')}/${_selectedDOB!.year}",
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: _selectedDOB == null ? theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.5) : theme.colorScheme.onSurface,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }


  Widget _buildDisabilityStatus(ThemeData theme) {
    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: theme.colorScheme.outline.withValues(alpha: 0.15)),
      ),
      child: SwitchListTile(
        secondary: CustomIconWidget(
          iconName: 'accessible',
          color: theme.colorScheme.primary.withValues(alpha: 0.7),
        ),
        subtitle: Text(
          AppLocalizations.of(context)?.disabledHint ?? 'Optional field',
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.6),
          ),
        ),
        title: Text(
          AppLocalizations.of(context)?.isDisabledPerson ?? 'Physical Status (Disabled)',
          style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
        ),
        value: _isDisabled,
        onChanged: (val) {
          setState(() => _isDisabled = val);
          widget.onUpdate('isDisabled', val);
        },
        activeThumbColor: theme.colorScheme.primary,
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required String icon,
    required bool required,
    required ThemeData theme,
    TextInputType? keyboardType,
    List<TextInputFormatter>? inputFormatters,
    Function(String)? onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(label, style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold)),
            if (required && !widget.isAdminEdit) ...[
              SizedBox(width: 1.w),
              Text(
                '*',
                style: theme.textTheme.titleSmall?.copyWith(
                  color: theme.colorScheme.error,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ],
        ),
        SizedBox(height: 1.h),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          inputFormatters: inputFormatters,
          style: theme.textTheme.bodyLarge,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: theme.textTheme.bodyLarge?.copyWith(
              color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.4),
            ),
            prefixIcon: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: CustomIconWidget(
                iconName: icon,
                color: theme.colorScheme.primary.withValues(alpha: 0.7),
                size: 20,
              ),
            ),
            prefixIconConstraints: const BoxConstraints(minWidth: 40),
            filled: true,
            fillColor: theme.colorScheme.surface,
            contentPadding: EdgeInsets.symmetric(vertical: 2.h, horizontal: 4.w),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(color: theme.colorScheme.outline.withValues(alpha: 0.2)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(color: theme.colorScheme.primary, width: 1.5),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(color: theme.colorScheme.error),
            ),
          ),
          validator: required && !widget.isAdminEdit
              ? (value) {
                  if (value == null || value.isEmpty) {
                    return AppLocalizations.of(context)?.thisFieldIsRequired ?? 'Required';
                  }
                  return null;
                }
              : null,
          onChanged: onChanged,
        ),
      ],
    );
  }

  Widget _buildDropdownField({
    required ThemeData theme,
    required String label,
    required String? value,
    required List<DropdownMenuItem<String>> items,
    required String icon,
    required Function(String?) onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold)),
        SizedBox(height: 1.h),
        DropdownButtonFormField<String>(
          initialValue: value != null && items.any((i) => i.value == value) ? value : null,
          isExpanded: true,
          style: theme.textTheme.bodyLarge,
          icon: Icon(Icons.keyboard_arrow_down_rounded, color: theme.colorScheme.primary),
          decoration: InputDecoration(
            filled: true,
            fillColor: theme.colorScheme.surface,
            prefixIcon: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: CustomIconWidget(
                iconName: icon,
                color: theme.colorScheme.primary.withValues(alpha: 0.7),
                size: 20,
              ),
            ),
            prefixIconConstraints: const BoxConstraints(minWidth: 40),
            contentPadding: EdgeInsets.symmetric(vertical: 2.h, horizontal: 4.w),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(color: theme.colorScheme.outline.withValues(alpha: 0.2)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(color: theme.colorScheme.primary, width: 1.5),
            ),
          ),
          items: items,
          onChanged: onChanged,
        ),
      ],
    );
  }

  Widget _buildSurnameDropdown(ThemeData theme) {
    // Ensure value is null if not in list (prevents dropdown assertion error)
    final dropdownValue = _banjaraSurnames.contains(_selectedSurname)
        ? _selectedSurname
        : null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(AppLocalizations.of(context)?.surname ?? 'Surname', style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold)),
            if (!widget.isAdminEdit) ...[
              SizedBox(width: 1.w),
              Text('*', style: theme.textTheme.titleSmall?.copyWith(color: theme.colorScheme.error, fontWeight: FontWeight.bold)),
            ],
          ],
        ),
        SizedBox(height: 1.h),
        DropdownButtonFormField<String>(
          initialValue: dropdownValue,
          isExpanded: true,
          style: theme.textTheme.bodyLarge,
          icon: Icon(Icons.keyboard_arrow_down_rounded, color: theme.colorScheme.primary),
          decoration: InputDecoration(
            hintText: AppLocalizations.of(context)?.selectYourSurname ?? 'Select Surname',
            filled: true,
            fillColor: theme.colorScheme.surface,
            prefixIcon: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: CustomIconWidget(
                iconName: 'family_restroom',
                color: theme.colorScheme.primary.withValues(alpha: 0.7),
                size: 20,
              ),
            ),
            prefixIconConstraints: const BoxConstraints(minWidth: 40),
            contentPadding: EdgeInsets.symmetric(vertical: 2.h, horizontal: 4.w),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(color: theme.colorScheme.outline.withValues(alpha: 0.2)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(color: theme.colorScheme.primary, width: 1.5),
            ),
          ),
          items: _banjaraSurnames.map((surname) {
            return DropdownMenuItem(
              value: surname,
              child: Row(
                children: [
                  CustomIconWidget(
                    iconName: 'family_restroom',
                    color: theme.colorScheme.primary.withValues(alpha: 0.6),
                    size: 18,
                  ),
                  SizedBox(width: 3.w),
                  Text(surname, overflow: TextOverflow.ellipsis),
                ],
              ),
            );
          }).toList(),
          onChanged: (value) {
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
        ),
      ],
    );
  }

  Widget _buildCustomSurnameField(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(AppLocalizations.of(context)?.surname ?? 'Surname', style: theme.textTheme.titleMedium),
        SizedBox(height: 1.h),
        TextFormField(
          controller: _customSurnameController,
          decoration: InputDecoration(
            hintText: AppLocalizations.of(context)?.selectYourSurname ?? 'Select your surname',
            prefixIcon: CustomIconWidget(
              iconName: 'edit',
              color: theme.colorScheme.onSurfaceVariant,
              size: 20,
            ),
          ),
          onChanged: (value) {
            widget.onUpdate('surname', value);
          },
        ),
      ],
    );
  }

  List<String> _getGotrasForSurname(String surname) {
    return _surnameGotraMap[surname] ?? [];
  }

  Widget _buildGotraDropdown(ThemeData theme) {
    // Ensure value is null if not in list (prevents dropdown assertion error)
    final dropdownValue = _gotraOptions.contains(_selectedGotra)
        ? _selectedGotra
        : null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(AppLocalizations.of(context)?.gotra ?? 'Gotra', style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold)),
            if (!widget.isAdminEdit) ...[
              SizedBox(width: 1.w),
              Text('*', style: theme.textTheme.titleSmall?.copyWith(color: theme.colorScheme.error, fontWeight: FontWeight.bold)),
            ],
          ],
        ),
        SizedBox(height: 1.h),
        DropdownButtonFormField<String>(
          key: ValueKey(_selectedSurname),
          initialValue: dropdownValue,
          isExpanded: true,
          style: theme.textTheme.bodyLarge,
          icon: Icon(Icons.keyboard_arrow_down_rounded, color: theme.colorScheme.primary),
          decoration: InputDecoration(
            hintText: AppLocalizations.of(context)?.selectYourGotra ?? 'Select Gotra',
            filled: true,
            fillColor: theme.colorScheme.surface,
            prefixIcon: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: CustomIconWidget(
                iconName: 'diversity_3',
                color: theme.colorScheme.primary.withValues(alpha: 0.7),
                size: 20,
              ),
            ),
            prefixIconConstraints: const BoxConstraints(minWidth: 40),
            contentPadding: EdgeInsets.symmetric(vertical: 2.h, horizontal: 4.w),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(color: theme.colorScheme.outline.withValues(alpha: 0.2)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(color: theme.colorScheme.primary, width: 1.5),
            ),
          ),
          items: _gotraOptions.map((gotra) {
            return DropdownMenuItem(
              value: gotra,
              child: Row(
                children: [
                  CustomIconWidget(
                    iconName: 'groups',
                    color: theme.colorScheme.primary.withValues(alpha: 0.6),
                    size: 18,
                  ),
                  SizedBox(width: 3.w),
                  Text(gotra, overflow: TextOverflow.ellipsis),
                ],
              ),
            );
          }).toList(),
          onChanged: (value) {
            setState(() => _selectedGotra = value);
            widget.onUpdate('gotra', value);
            _validateForm();
          },
        ),
      ],
    );
  }

  Widget _buildGenderSelector(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              AppLocalizations.of(context)?.genderSelectHeading ?? 'Your Gender is',
              style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
            ),
            if (!widget.isAdminEdit) ...[
              SizedBox(width: 1.w),
              Text(
                '*',
                style: theme.textTheme.titleSmall?.copyWith(
                  color: theme.colorScheme.error,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ],
        ),
          SizedBox(height: 1.5.h),
        Row(
          children: _genderKeys.map((gender) {
            final isSelected = _selectedGender == gender;
            final isMale = gender == 'Male';
            
            // 🧬 PRO SCALE: High-visibility image-based backgrounds
            final imagePath = isMale ? 'assets/images/gender_male.png' : 'assets/images/gender_female.png';
            final baseColor = isMale ? Colors.blue.shade700 : Colors.pink.shade600;

            return Expanded(
              child: Padding(
                padding: EdgeInsets.only(right: !isMale ? 2.w : 0),
                child: InkWell(
                  onTap: () {
                    setState(() => _selectedGender = gender);
                    widget.onUpdate('gender', gender);
                    _validateForm();
                  },
                  borderRadius: BorderRadius.circular(24),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                    height: 17.h, // Significantly reduced from 22.h for compactness
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(
                        color: isSelected ? baseColor : theme.colorScheme.outline.withValues(alpha: 0.2),
                        width: isSelected ? 4.0 : 1.5,
                      ),
                      boxShadow: isSelected
                          ? [
                              BoxShadow(
                                color: baseColor.withValues(alpha: 0.3),
                                blurRadius: 15,
                                offset: const Offset(0, 8),
                              ),
                            ]
                          : null,
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          // 📸 Background Image
                          Image.asset(
                            imagePath,
                            fit: BoxFit.cover,
                          ),
                          // 🌑 Gradient Overlay for Legibility
                          Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [
                                  Colors.transparent,
                                  Colors.black.withValues(alpha: 0.7),
                                ],
                              ),
                            ),
                          ),
                          // 📝 Centered Gender Text
                          Column(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Text(
                                _getLocalizedGender(context, gender).toUpperCase(),
                                style: theme.textTheme.headlineSmall?.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: 2.0,
                                  shadows: [
                                    const Shadow(
                                      color: Colors.black54,
                                      blurRadius: 4,
                                      offset: Offset(0, 2),
                                    ),
                                  ],
                                ),
                              ),
                              SizedBox(height: 1.5.h),
                              if (isSelected)
                                Container(
                                  margin: EdgeInsets.only(bottom: 1.5.h),
                                  padding: const EdgeInsets.all(4),
                                  decoration: const BoxDecoration(
                                    color: Colors.white,
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(
                                    Icons.check,
                                    color: baseColor,
                                    size: 16,
                                  ),
                                )
                              else
                                SizedBox(height: 3.5.h),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildHeightSelector(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: EdgeInsets.all(4.w),
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: theme.colorScheme.outline.withValues(alpha: 0.15), width: 1.5),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.02),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            children: [
              Row(
                children: [
                  CustomIconWidget(
                    iconName: 'height',
                    color: theme.colorScheme.onSurfaceVariant,
                    size: 20,
                  ),
                  SizedBox(width: 3.w),
                  Text(
                    AppLocalizations.of(context)?.height ?? 'Height',
                    style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const Spacer(),
                  Text(
                    "$_heightFeet'$_heightInches\"",
                    style: theme.textTheme.titleLarge?.copyWith(
                      color: theme.colorScheme.primary,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 2.h),
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(AppLocalizations.of(context)?.feet ?? 'Feet', style: theme.textTheme.bodySmall?.copyWith(fontWeight: FontWeight.bold)),
                            SizedBox(
                              width: 12.w,
                              height: 4.h,
                              child: TextField(
                                controller: _feetController,
                                keyboardType: TextInputType.number,
                                textAlign: TextAlign.center,
                                style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold),
                                decoration: InputDecoration(
                                  contentPadding: EdgeInsets.zero,
                                  filled: true,
                                  fillColor: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
                                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
                                ),
                                onChanged: (val) {
                                  final n = int.tryParse(val);
                                  if (n != null && n >= 4 && n <= 7) {
                                    setState(() => _heightFeet = n);
                                    _updateHeight();
                                  }
                                },
                              ),
                            ),
                          ],
                        ),
                        Slider(
                          value: _heightFeet.toDouble(),
                          min: 4,
                          max: 7,
                          divisions: 3,
                          label: _heightFeet.toString(),
                          onChanged: (value) {
                            setState(() {
                              _heightFeet = value.toInt();
                              _feetController.text = _heightFeet.toString();
                            });
                            _updateHeight();
                          },
                        ),
                      ],
                    ),
                  ),
                  SizedBox(width: 4.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(AppLocalizations.of(context)?.inches ?? 'Inches', style: theme.textTheme.bodySmall?.copyWith(fontWeight: FontWeight.bold)),
                            SizedBox(
                              width: 12.w,
                              height: 4.h,
                              child: TextField(
                                controller: _inchesController,
                                keyboardType: TextInputType.number,
                                textAlign: TextAlign.center,
                                style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold),
                                decoration: InputDecoration(
                                  contentPadding: EdgeInsets.zero,
                                  filled: true,
                                  fillColor: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
                                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
                                ),
                                onChanged: (val) {
                                  final n = int.tryParse(val);
                                  if (n != null && n >= 0 && n <= 11) {
                                    setState(() => _heightInches = n);
                                    _updateHeight();
                                  }
                                },
                              ),
                            ),
                          ],
                        ),
                        Slider(
                          value: _heightInches.toDouble(),
                          max: 11,
                          divisions: 11,
                          label: _heightInches.toString(),
                          onChanged: (value) {
                            setState(() {
                              _heightInches = value.toInt();
                              _inchesController.text = _heightInches.toString();
                            });
                            _updateHeight();
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}
