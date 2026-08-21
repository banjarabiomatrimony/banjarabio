import 'package:flutter/material.dart';
import 'package:banjarabio/l10n/app_localizations.dart';
import 'package:sizer/sizer.dart';

import 'package:banjarabio/core/app_export.dart';
import 'package:banjarabio/widgets/custom_icon_widget.dart';

/// Education and profession section for biodata creation
/// Handles educational qualification and professional details
class EducationProfessionSection extends StatefulWidget {
  final Map<String, dynamic> formData;
  final bool isAdminEdit;
  final bool isLite;
  final Function(String, dynamic) onUpdate;
  final Function(Map<String, dynamic>) onBatchUpdate;
  final Function(bool) onValidationChange;

  const EducationProfessionSection({
    super.key,
    required this.formData,
    this.isAdminEdit = false,
    this.isLite = false,
    required this.onUpdate,
    required this.onBatchUpdate,
    required this.onValidationChange,
    required this.scrollController,
  });

  final ScrollController scrollController;

  @override
  State<EducationProfessionSection> createState() =>
      _EducationProfessionSectionState();
}

class _EducationProfessionSectionState
    extends State<EducationProfessionSection> {
  final _customEducationController = TextEditingController();
  final _customProfessionController = TextEditingController();
  final _educationDetailsController = TextEditingController();
  final _jobDetailsController = TextEditingController();
  final _companyController = TextEditingController();

  String? _selectedEducation;
  String? _selectedProfession;
  String? _selectedIncome;
  bool _showCustomEducation = false;
  bool _showCustomProfession = false;

  final List<String> _educationKeys = [
    'High School',
    'Diploma',
    'Bachelors Degree',
    'Masters Degree',
    'Doctorate',
    'Professional Degree',
    'Other',
  ];

  String _getLocalizedEducation(BuildContext context, String key) {
    final l10n = AppLocalizations.of(context);
    switch (key) {
      case 'High School': return l10n?.highSchool ?? 'High School';
      case 'Diploma': return l10n?.diploma ?? 'Diploma';
      case 'Bachelors Degree': return l10n?.bachelorsDegree ?? 'Bachelor\'s Degree';
      case 'Masters Degree': return l10n?.mastersDegree ?? 'Master\'s Degree';
      case 'Doctorate': return l10n?.doctorate ?? 'Doctorate';
      case 'Professional Degree': return l10n?.professionalDegree ?? 'Professional Degree';
      case 'Other': return l10n?.other ?? 'Other';
      default: return key;
    }
  }

  final List<String> _professionKeys = [
    'Business Owner',
    'Private Sector Employee',
    'Government Employee',
    'Self Employed',
    'Professional (Doctor/Engineer/Lawyer)',
    'Teacher/Professor',
    'Farmer',
    'Homemaker',
    'Student',
    'Other',
  ];

  String _getLocalizedProfession(BuildContext context, String key) {
    final l10n = AppLocalizations.of(context);
    switch (key) {
      case 'Business Owner': return l10n?.businessOwner ?? 'Business Owner';
      case 'Private Sector Employee': return l10n?.privateSectorEmployee ?? 'Private Sector Employee';
      case 'Government Employee': return l10n?.governmentEmployee ?? 'Government Employee';
      case 'Self Employed': return l10n?.selfEmployed ?? 'Self Employed';
      case 'Professional (Doctor/Engineer/Lawyer)': return l10n?.professionalDoctorEngineerLawyer ?? 'Professional (Doctor/Engineer/Lawyer)';
      case 'Teacher/Professor': return l10n?.teacherProfessor ?? 'Teacher/Professor';
      case 'Farmer': return l10n?.farmer ?? 'Farmer';
      case 'Homemaker': return l10n?.homemaker ?? 'Homemaker';
      case 'Student': return l10n?.student ?? 'Student';
      case 'Other': return l10n?.other ?? 'Other';
      default: return key;
    }
  }

  List<String> get _incomeOptions => [
    'noIncome',
    'under2Lakh',
    'twoToFiveLakh',
    'fiveToSevenHalfLakh',
    'sevenHalfToTenLakh',
    'tenToFifteenLakh',
    'fifteenToTwentyLakh',
    'twentyLakhPlus',
  ];

  String _getLocalizedIncome(String key) {
    switch (key) {
      case 'noIncome':
        return '₹0 (No Income)';
      case 'under2Lakh':
        return '₹0 - ₹2,00,000 / Year';
      case 'twoToFiveLakh':
        return '₹2,00,000 - ₹5,00,000 / Year';
      case 'fiveToSevenHalfLakh':
        return '₹5,00,000 - ₹7,50,000 / Year';
      case 'sevenHalfToTenLakh':
        return '₹7,50,000 - ₹10,00,000 / Year';
      case 'tenToFifteenLakh':
        return '₹10,00,000 - ₹15,00,000 / Year';
      case 'fifteenToTwentyLakh':
        return '₹15,00,000 - ₹20,00,000 / Year';
      case 'twentyLakhPlus':
        return '₹20,00,000+ / Year';
      default:
        return key;
    }
  }

  @override
  void initState() {
    super.initState();
    _initializeData();
    _customEducationController.addListener(_validateForm);
    _educationDetailsController.addListener(_validateForm);
    _jobDetailsController.addListener(_validateForm);
    _companyController.addListener(_validateForm);
    // Trigger initial validation
    WidgetsBinding.instance.addPostFrameCallback((_) => _validateForm());
  }

  void _initializeData() {
    // Ensure empty string is treated as null for dropdown
    final education = widget.formData['education'];
    final profession = widget.formData['profession'];
    final income = widget.formData['annualIncome'];

    _selectedEducation = (education != null && education.toString().isNotEmpty)
        ? education
        : null;
    _selectedProfession =
        (profession != null && profession.toString().isNotEmpty)
        ? profession
        : null;
    _selectedIncome = (income != null && income.toString().isNotEmpty)
        ? income
        : null;

    if (_selectedEducation != null &&
        !_educationKeys.contains(_selectedEducation)) {
      _showCustomEducation = true;
      if (_customEducationController.text != _selectedEducation) {
        _customEducationController.text = _selectedEducation!;
      }
      _selectedEducation = 'Other';
    } else {
      _showCustomEducation = false;
      _customEducationController.clear();
    }

    if (_selectedProfession != null &&
        !_professionKeys.contains(_selectedProfession)) {
      _showCustomProfession = true;
      if (_customProfessionController.text != _selectedProfession) {
        _customProfessionController.text = _selectedProfession!;
      }
      _selectedProfession = 'Other';
    } else {
      _showCustomProfession = false;
      _customProfessionController.clear();
    }

    final educationDetails =
        widget.formData['educationDetails']?.toString() ?? '';
    if (_educationDetailsController.text != educationDetails) {
      _educationDetailsController.text = educationDetails;
    }

    final jobDetails = widget.formData['jobDetails']?.toString() ?? '';
    if (_jobDetailsController.text != jobDetails) {
      _jobDetailsController.text = jobDetails;
    }

    final company = widget.formData['company']?.toString() ?? '';
    if (_companyController.text != company) {
      _companyController.text = company;
    }
  }

  @override
  void didUpdateWidget(covariant EducationProfessionSection oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.formData != oldWidget.formData ||
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
    _customEducationController.removeListener(_validateForm);
    _educationDetailsController.removeListener(_validateForm);
    _jobDetailsController.removeListener(_validateForm);
    _companyController.removeListener(_validateForm);
    _customEducationController.dispose();
    _customProfessionController.dispose();
    _educationDetailsController.dispose();
    _jobDetailsController.dispose();
    _companyController.dispose();
    super.dispose();
  }

  void _validateForm() {
    if (widget.isAdminEdit) {
      widget.onValidationChange(true);
      return;
    }
    
    final educationValid =
        _selectedEducation != null &&
        (_selectedEducation != 'Other' ||
            _customEducationController.text.isNotEmpty);
    final professionValid =
        _selectedProfession != null &&
        (_selectedProfession != 'Other' ||
            _customProfessionController.text.isNotEmpty);
    final incomeValid = _selectedIncome != null;

    widget.onValidationChange(educationValid && professionValid && incomeValid);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);

    return SingleChildScrollView(
      controller: widget.scrollController,
      padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(theme, l10n),
          SizedBox(height: 3.h),
          
          _buildPremiumCard(
            theme: theme,
            title: l10n?.educationProfession ?? 'Education',
            icon: 'school',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildEducationDropdown(theme),
                if (_showCustomEducation) ...[
                  SizedBox(height: 2.h),
                  _buildCustomEducationField(theme),
                ],
                SizedBox(height: 2.h),
                _buildTextField(
                  theme: theme,
                  label: l10n?.educationDetails ?? 'Education Details',
                  controller: _educationDetailsController,
                  hint: l10n?.egSpecializationOrHonors ?? 'e.g. Specialization or Honors',
                  icon: 'menu_book',
                  onChanged: (val) => widget.onUpdate('educationDetails', val),
                ),
              ],
            ),
          ),
          
          SizedBox(height: 2.h),

          _buildPremiumCard(
            theme: theme,
            title: l10n?.profession ?? 'Profession & Income',
            icon: 'work',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildProfessionDropdown(theme),
                if (_showCustomProfession) ...[
                  SizedBox(height: 2.h),
                  _buildCustomProfessionField(theme),
                ],
                SizedBox(height: 2.h),
                _buildTextField(
                  theme: theme,
                  label: l10n?.jobDetails ?? 'Job Details',
                  controller: _jobDetailsController,
                  hint: l10n?.egSeniorSoftwareEngineer ?? 'e.g. Senior Software Engineer',
                  icon: 'business_center',
                  onChanged: (val) => widget.onUpdate('jobDetails', val),
                ),
                SizedBox(height: 2.h),
                _buildTextField(
                  theme: theme,
                  label: l10n?.companyName ?? 'Company Name',
                  controller: _companyController,
                  hint: l10n?.whereDoYouWork ?? 'Where do you work?',
                  icon: 'location_city',
                  onChanged: (val) => widget.onUpdate('company', val),
                ),
                SizedBox(height: 2.h),
                _buildIncomeDropdown(theme, l10n),
              ],
            ),
          ),
          
          SizedBox(height: 4.h),
        ],
      ),
    );
  }

  Widget _buildHeader(ThemeData theme, AppLocalizations? l10n) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n?.educationProfession ?? 'Education & Profession',
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: AppTypography.extraBold,
            letterSpacing: -0.5,
          ),
        ),
        SizedBox(height: 0.5.h),
        Text(
          l10n?.shareYourEducationalBackgroundAndProfess ?? 'Share your educational background and professional details',
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
            height: 1.4,
          ),
        ),
      ],
    );
  }

  Widget _buildPremiumCard({
    required ThemeData theme,
    required String title,
    required String icon,
    required Widget child,
  }) {
    return Container(
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface.withValues(alpha: 0.7),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: theme.colorScheme.outline.withValues(alpha: 0.1),
        ),
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.shadow.withValues(alpha: 0.03),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primaryContainer.withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: CustomIconWidget(
                  iconName: icon,
                  color: theme.colorScheme.primary,
                  size: 20,
                ),
              ),
              SizedBox(width: 3.w),
              Text(
                title,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: AppTypography.bold,
                  letterSpacing: -0.2,
                ),
              ),
            ],
          ),
          SizedBox(height: 2.h),
          child,
        ],
      ),
    );
  }

  Widget _buildIncomeDropdown(ThemeData theme, AppLocalizations? l10n) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(l10n?.annualIncome ?? 'Annual Income', style: theme.textTheme.titleSmall?.copyWith(fontWeight: AppTypography.bold)),
            if (!widget.isAdminEdit) ...[
              SizedBox(width: 1.w),
              Text('*', style: theme.textTheme.titleSmall?.copyWith(color: theme.colorScheme.error, fontWeight: AppTypography.bold)),
            ],
          ],
        ),
        SizedBox(height: 1.h),
        DropdownButtonFormField<String>(
          initialValue: _selectedIncome != null && _incomeOptions.contains(_selectedIncome) ? _selectedIncome : null,
          isExpanded: true,
          style: theme.textTheme.bodyLarge,
          icon: Icon(Icons.keyboard_arrow_down_rounded, color: theme.colorScheme.primary),
          decoration: InputDecoration(
            hintText: l10n?.selectAnnualIncomeRange ?? 'Select annual income range',
            filled: true,
            fillColor: theme.colorScheme.surface,
            prefixIcon: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: CustomIconWidget(
                iconName: 'currency_rupee',
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
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(color: theme.colorScheme.error),
            ),
          ),
          items: _incomeOptions.map((key) {
            String iconPath = 'payments';
            if (key == 'noIncome') iconPath = 'money_off';
            if (key == 'twentyLakhPlus') iconPath = 'account_balance';
            
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
                  Text(_getLocalizedIncome(key), overflow: TextOverflow.ellipsis),
                ],
              ),
            );
          }).toList(),
          onChanged: (value) {
            setState(() => _selectedIncome = value);
            widget.onUpdate('annualIncome', value);
            _validateForm();
          },
          validator: (value) {
            if (widget.isAdminEdit) return null;
            if (value == null || value.isEmpty) {
              return AppLocalizations.of(context)?.annualIncome ?? 'Please select your annual income';
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildEducationDropdown(ThemeData theme) {
    // Ensure value is null if not in list (prevents dropdown assertion error)
    final dropdownValue = _educationKeys.contains(_selectedEducation)
        ? _selectedEducation
        : null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(AppLocalizations.of(context)?.educationalQualification ?? 'Educational Qualification',
              style: theme.textTheme.titleSmall?.copyWith(fontWeight: AppTypography.bold),
            ),
            if (!widget.isAdminEdit) ...[
              SizedBox(width: 1.w),
              Text(AppLocalizations.of(context)?.emptyStr ?? '*',
                style: theme.textTheme.titleSmall?.copyWith(color: theme.colorScheme.error, fontWeight: AppTypography.bold),
              ),
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
            hintText: AppLocalizations.of(context)?.selectYourEducationLevel ?? 'Select your education level',
            filled: true,
            fillColor: theme.colorScheme.surface,
            prefixIcon: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: CustomIconWidget(
                iconName: 'school',
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
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(color: theme.colorScheme.error),
            ),
          ),
          items: _educationKeys.map((education) {
            String iconPath = 'school';
            if (education == 'High School') iconPath = 'menu_book';
            if (education == 'Diploma') iconPath = 'workspace_premium';
            if (education == 'Other') iconPath = 'more_horiz';

            return DropdownMenuItem(
              value: education,
              child: Row(
                children: [
                  CustomIconWidget(
                    iconName: iconPath,
                    color: theme.colorScheme.primary.withValues(alpha: 0.6),
                    size: 18,
                  ),
                  SizedBox(width: 3.w),
                  Text(_getLocalizedEducation(context, education), overflow: TextOverflow.ellipsis),
                ],
              ),
            );
          }).toList(),
          onChanged: (value) {
            setState(() {
              _selectedEducation = value;
              _showCustomEducation = value == 'Other';
              if (value != 'Other') {
                widget.onUpdate('education', value);
              }
            });
            _validateForm();
          },
          validator: (value) {
            if (widget.isAdminEdit) return null;
            if (value == null || value.isEmpty) {
              return AppLocalizations.of(context)?.educationalQualification ?? 'Please select your education level';
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildCustomEducationField(ThemeData theme) {
    final l10n = AppLocalizations.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(l10n?.specifyEducation ?? 'Specify Education', style: theme.textTheme.titleSmall?.copyWith(fontWeight: AppTypography.bold)),
        SizedBox(height: 1.h),
        TextFormField(
          controller: _customEducationController,
          decoration: InputDecoration(
            hintText: l10n?.educationDetails ?? 'Enter your education details',
            filled: true,
            fillColor: theme.colorScheme.surface,
            prefixIcon: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: CustomIconWidget(
                iconName: 'edit',
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
          validator: (value) {
            if (widget.isAdminEdit) return null;
            if (_selectedEducation == 'Other' &&
                (value == null || value.isEmpty)) {
              return l10n?.pleaseSpecifyEducation ?? 'Please specify your education';
            }
            return null;
          },
          onChanged: (value) {
            widget.onUpdate('education', value);
          },
        ),
      ],
    );
  }


  Widget _buildProfessionDropdown(ThemeData theme) {
    // Ensure value is null if not in list (prevents dropdown assertion error)
    final dropdownValue = _professionKeys.contains(_selectedProfession)
        ? _selectedProfession
        : null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(AppLocalizations.of(context)?.profession ?? 'Profession', style: theme.textTheme.titleSmall?.copyWith(fontWeight: AppTypography.bold)),
            if (!widget.isAdminEdit) ...[
              SizedBox(width: 1.w),
              Text(AppLocalizations.of(context)?.emptyStr ?? '*',
                style: theme.textTheme.titleSmall?.copyWith(color: theme.colorScheme.error, fontWeight: AppTypography.bold),
              ),
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
            hintText: AppLocalizations.of(context)?.selectYourProfession ?? 'Select your profession',
            filled: true,
            fillColor: theme.colorScheme.surface,
            prefixIcon: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: CustomIconWidget(
                iconName: 'work',
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
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(color: theme.colorScheme.error),
            ),
          ),
          items: _professionKeys.map((profession) {
             String iconPath = 'business_center';
            if (profession == 'Business Owner') iconPath = 'store';
            if (profession == 'Government Employee') iconPath = 'account_balance';
            if (profession == 'Farmer') iconPath = 'agriculture';
            if (profession == 'Student') iconPath = 'local_library';
            if (profession == 'Homemaker') iconPath = 'home';
            if (profession == 'Other') iconPath = 'more_horiz';

            return DropdownMenuItem(
              value: profession,
              child: Row(
                children: [
                  CustomIconWidget(
                    iconName: iconPath,
                    color: theme.colorScheme.primary.withValues(alpha: 0.6),
                    size: 18,
                  ),
                  SizedBox(width: 3.w),
                  Text(_getLocalizedProfession(context, profession), overflow: TextOverflow.ellipsis),
                ],
              ),
            );
          }).toList(),
          onChanged: (value) {
            setState(() {
              _selectedProfession = value;
              _showCustomProfession = value == 'Other';
              if (value != 'Other') {
                widget.onUpdate('profession', value);
              }
            });
            _validateForm();
          },
          validator: (value) {
            if (widget.isAdminEdit) return null;
            if (value == null || value.isEmpty) {
              return AppLocalizations.of(context)?.profession ?? 'Please select your profession';
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildCustomProfessionField(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(AppLocalizations.of(context)?.specifyProfession ?? 'Specify Profession', style: theme.textTheme.titleSmall?.copyWith(fontWeight: AppTypography.bold)),
        SizedBox(height: 1.h),
        TextFormField(
          controller: _customProfessionController,
          decoration: InputDecoration(
            hintText: AppLocalizations.of(context)?.enterProfessionDetails ?? 'Enter your profession details',
            filled: true,
            fillColor: theme.colorScheme.surface,
            prefixIcon: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: CustomIconWidget(
                iconName: 'edit',
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
          validator: (value) {
            if (widget.isAdminEdit) return null;
            if (_selectedProfession == 'Other' &&
                (value == null || value.isEmpty)) {
              return AppLocalizations.of(context)?.profession ?? 'Please specify your profession';
            }
            return null;
          },
          onChanged: (value) {
            widget.onUpdate('profession', value);
          },
        ),
      ],
    );
  }

  Widget _buildTextField({
    required ThemeData theme,
    required String label,
    required TextEditingController controller,
    required String hint,
    required String icon,
    int maxLines = 1,
    Function(String)? onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: theme.textTheme.titleSmall?.copyWith(fontWeight: AppTypography.bold)),
        SizedBox(height: 1.h),
        TextFormField(
          controller: controller,
          maxLines: maxLines,
          decoration: InputDecoration(
            hintText: hint,
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
          onChanged: onChanged,
        ),
      ],
    );
  }
}
