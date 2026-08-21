import 'package:banjarabio/core/constants/app_typography.dart';
import 'package:flutter/material.dart';
import 'package:banjarabio/l10n/app_localizations.dart';
import 'package:sizer/sizer.dart';
import 'package:banjarabio/core/models/sibling_model.dart';
import 'package:banjarabio/core/repositories/subscription_repository.dart';
import 'package:banjarabio/core/services/bio_synthesis_service.dart';
import 'package:banjarabio/widgets/custom_icon_widget.dart';

/// Family details section for biodata creation
/// Handles about self description
class FamilyDetailsSection extends StatefulWidget {
  final Map<String, dynamic> formData;
  final bool isAdminEdit;
  final Function(String, dynamic) onUpdate;
  final Function(Map<String, dynamic>) onBatchUpdate;
  final Function(bool) onValidationChange;
  final SubscriptionRepository? subscriptionRepository;
  final ScrollController scrollController;

  const FamilyDetailsSection({
    super.key,
    required this.formData,
    this.isAdminEdit = false,
    required this.onUpdate,
    required this.onBatchUpdate,
    required this.onValidationChange,
    this.subscriptionRepository,
    required this.scrollController,
  });

  @override
  State<FamilyDetailsSection> createState() => _FamilyDetailsSectionState();
}

class _FamilyDetailsSectionState extends State<FamilyDetailsSection> {
  final _fatherNameController = TextEditingController();
  final _fatherOccupationController = TextEditingController();
  final _motherNameController = TextEditingController();
  final _motherOccupationController = TextEditingController();
  final _aboutSelfController = TextEditingController();

  // Dynamic Siblings State
  List<SiblingModel> _siblingsList = [];

  final List<String> _relationKeys = [
    'Elder Brother',
    'Younger Brother',
    'Elder Sister',
    'Younger Sister',
    'Self',
  ];

  String _getLocalizedRelation(BuildContext context, String key) {
    final l10n = AppLocalizations.of(context);
    switch (key) {
      case 'Elder Brother': return l10n?.elderBrother ?? 'Elder Brother';
      case 'Younger Brother': return l10n?.youngerBrother ?? 'Younger Brother';
      case 'Elder Sister': return l10n?.elderSister ?? 'Elder Sister';
      case 'Younger Sister': return l10n?.youngerSister ?? 'Younger Sister';
      case 'Self': return l10n?.self ?? 'Self';
      default: return key;
    }
  }

  String? _selectedFamilyType;
  String? _selectedFamilyStatus;

  final List<String> _familyStatusKeys = [
    'Middle Class',
    'Upper Middle Class',
    'Rich',
    'Affluent',
  ];

  String _getLocalizedFamilyStatus(BuildContext context, String key) {
    final l10n = AppLocalizations.of(context);
    switch (key) {
      case 'Middle Class': return l10n?.middleClass ?? 'Middle Class';
      case 'Upper Middle Class': return l10n?.upperMiddleClass ?? 'Upper Middle Class';
      case 'Rich': return l10n?.rich ?? 'Rich';
      case 'Affluent': return l10n?.affluent ?? 'Affluent';
      default: return key;
    }
  }

  final int _maxCharacters = 500;
  final List<String> _familyTypeKeys = [
    'Nuclear',
    'Joint',
  ];

  String _getLocalizedFamilyType(BuildContext context, String key) {
    final l10n = AppLocalizations.of(context);
    switch (key) {
      case 'Nuclear': return l10n?.nuclearFamily ?? 'Nuclear';
      case 'Joint': return l10n?.jointFamily ?? 'Joint';
      default: return key;
    }
  }

  bool _isGeneratingBio = false;
  bool _isPremiumUser = false;

  @override
  void initState() {
    super.initState();
    _initializeData();
    _checkSubscriptionStatus();
    _fatherNameController.addListener(_validateForm);
    _fatherOccupationController.addListener(_validateForm);
    _motherNameController.addListener(_validateForm);
    _motherOccupationController.addListener(_validateForm);
    _aboutSelfController.addListener(_validateForm);
    // Trigger initial validation
    WidgetsBinding.instance.addPostFrameCallback((_) => _validateForm());
  }

  @override
  void dispose() {
    _fatherNameController.removeListener(_validateForm);
    _fatherOccupationController.removeListener(_validateForm);
    _motherNameController.removeListener(_validateForm);
    _motherOccupationController.removeListener(_validateForm);
    _aboutSelfController.removeListener(_validateForm);
    _fatherNameController.dispose();
    _fatherOccupationController.dispose();
    _motherNameController.dispose();
    _motherOccupationController.dispose();
    _aboutSelfController.dispose();
    super.dispose();
  }

  void _initializeData() {
    _fatherNameController.text = widget.formData['fatherName'] ?? '';
    _fatherOccupationController.text =
        widget.formData['fatherOccupation'] ?? '';
    _motherNameController.text = widget.formData['motherName'] ?? '';
    _motherOccupationController.text =
        widget.formData['motherOccupation'] ?? '';

    // Initialize Siblings List
    final dynamic siblingsData =
        widget.formData['siblings'] ?? widget.formData['siblingsData'];
    if (siblingsData is List) {
      _siblingsList = siblingsData
          .map((s) {
            if (s is SiblingModel) return s;
            if (s is Map) {
              return SiblingModel.fromJson(Map<String, dynamic>.from(s));
            }
            return null;
          })
          .whereType<SiblingModel>()
          .toList();

      // Sort by position
      _siblingsList.sort((a, b) => a.position.compareTo(b.position));
    } else {
      _siblingsList = [];
    }

    _aboutSelfController.text =
        (widget.formData['aboutSelf'] ??
                widget.formData['about'] ??
                widget.formData['about_self'])
            ?.toString() ??
        '';

    _selectedFamilyType = widget.formData['familyType']?.toString();
    _selectedFamilyStatus = widget.formData['familyStatus']?.toString();
  }

  @override
  void didUpdateWidget(covariant FamilyDetailsSection oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Only re-initialize if the map instance changed (e.g. from population)
    // or if specific critical fields changed externally
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

  void _validateForm() {
    if (widget.isAdminEdit) {
      widget.onValidationChange(true);
      return;
    }
    final isValid = _fatherNameController.text.isNotEmpty &&
        _motherNameController.text.isNotEmpty;
    widget.onValidationChange(isValid);
  }

  Future<void> _checkSubscriptionStatus() async {
    final repo = widget.subscriptionRepository ?? SubscriptionRepository();
    final res = await repo.isPremium();
    if (mounted) {
      setState(() {
        _isPremiumUser = res.fold(
          onSuccess: (isPremium) => isPremium,
          onFailure: (_) => false,
        );
      });
    }
  }

  void _generateBio() async {
    setState(() => _isGeneratingBio = true);

    // Simulate network/AI delay
    await Future.delayed(const Duration(seconds: 1));

    final bioService = BioSynthesisService();
    final generatedText = bioService.generateBio(
      data: widget.formData,
      isPremium: _isPremiumUser,
    );

    if (mounted) {
      setState(() {
        _aboutSelfController.text = generatedText;
        _isGeneratingBio = false;
      });
      widget.onUpdate('aboutSelf', generatedText);
    }
  }

  void _addSibling() {
    setState(() {
      final nextPosition = _siblingsList.length + 1;
      _siblingsList.add(
        SiblingModel(
          position: nextPosition,
          relation: 'Elder Brother',
          isMarried: false,
        ),
      );
    });
    _onSiblingsChanged();
  }

  void _removeSibling(int index) {
    setState(() {
      _siblingsList.removeAt(index);
      // Re-normalize positions
      for (int i = 0; i < _siblingsList.length; i++) {
        _siblingsList[i] = SiblingModel(
          position: i + 1,
          relation: _siblingsList[i].relation,
          isMarried: _siblingsList[i].isMarried,
        );
      }
    });
    _onSiblingsChanged();
  }

  void _updateSibling(int index, {String? relation, bool? isMarried}) {
    setState(() {
      // Rule: Only one "Self" allowed
      if (relation == 'Self') {
        for (int i = 0; i < _siblingsList.length; i++) {
          if (i != index && _siblingsList[i].relation == 'Self') {
            // Change previous Self to Brother by default
            _siblingsList[i] = SiblingModel(
              position: _siblingsList[i].position,
              relation: 'Elder Brother',
              isMarried: _siblingsList[i].isMarried,
            );
          }
        }
      }

      _siblingsList[index] = SiblingModel(
        position: _siblingsList[index].position,
        relation: relation ?? _siblingsList[index].relation,
        isMarried: isMarried ?? _siblingsList[index].isMarried,
      );
    });
    _onSiblingsChanged();
  }

  void _onSiblingsChanged() {
    // Auto-calculate Total, Sisters, Brothers
    final int total = _siblingsList.length;
    final int sisters = _siblingsList
        .where((s) => s.relation.contains('Sister'))
        .length;
    final int brothers = _siblingsList
        .where((s) => s.relation.contains('Brother'))
        .length;

    widget.onBatchUpdate({
      'siblings': _siblingsList.map((s) => s.toJson()).toList(),
      'siblingsCount': total,
      'sisterCount': sisters,
      'brotherCount': brothers,
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final currentLength = _aboutSelfController.text.length;

    return SingleChildScrollView(
      controller: widget.scrollController,
      padding: EdgeInsets.all(4.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(AppLocalizations.of(context)?.familyDetails ?? 'Family Details', style: theme.textTheme.headlineSmall),
          SizedBox(height: 1.h),
          Text(AppLocalizations.of(context)?.provideInformationAboutYourFamilyBackgro ?? 'Provide information about your family background',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          SizedBox(height: 3.h),

          // Father Details
          _buildTextField(
            controller: _fatherNameController,
            label: AppLocalizations.of(context)?.fatherName ?? "Father's Name",
            hint: AppLocalizations.of(context)?.fatherName ?? "Enter father's name",
            icon: 'person',
            required: true,
            onChanged: (val) => widget.onUpdate('fatherName', val),
            theme: theme,
          ),
          SizedBox(height: 2.h),
          _buildTextField(
            controller: _fatherOccupationController,
            label: AppLocalizations.of(context)?.fatherOccupation ?? "Father's Occupation",
            hint: AppLocalizations.of(context)?.profession ?? 'e.g. Retired Government Officer',
            icon: 'work',
            onChanged: (val) => widget.onUpdate('fatherOccupation', val),
            theme: theme,
          ),
          SizedBox(height: 3.h),

          // Mother Details
          _buildTextField(
            controller: _motherNameController,
            label: AppLocalizations.of(context)?.motherName ?? "Mother's Name",
            hint: AppLocalizations.of(context)?.motherName ?? "Enter mother's name",
            icon: 'person',
            required: true,
            onChanged: (val) => widget.onUpdate('motherName', val),
            theme: theme,
          ),
          SizedBox(height: 2.h),
          _buildTextField(
            controller: _motherOccupationController,
            label: AppLocalizations.of(context)?.motherOccupation ?? "Mother's Occupation",
            hint: AppLocalizations.of(context)?.homemaker ?? 'e.g. Homemaker',
            icon: 'work_outline',
            onChanged: (val) => widget.onUpdate('motherOccupation', val),
            theme: theme,
          ),
          SizedBox(height: 3.h),

          // Siblings Header & Total
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(AppLocalizations.of(context)?.siblingsLabel ?? 'Siblings', style: theme.textTheme.titleLarge),
                  Text(AppLocalizations.of(context)?.addYourBrothersAndSisters ?? 'Add your brothers and sisters',
                    style: theme.textTheme.bodySmall,
                  ),
                ],
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 0.5.h),
                decoration: BoxDecoration(
                  color: theme.colorScheme.secondaryContainer,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '${AppLocalizations.of(context)?.totalCount ?? 'Total:'} ${_siblingsList.length}',
                  style: theme.textTheme.labelLarge?.copyWith(
                    color: theme.colorScheme.onSecondaryContainer,
                    fontWeight: AppTypography.bold,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 2.h),

          // Dynamic Sibling List
          if (_siblingsList.isEmpty)
            Padding(
              padding: EdgeInsets.symmetric(vertical: 2.h),
              child: Center(
                child: Column(
                  children: [
                    CustomIconWidget(
                      iconName: 'groups',
                      color: theme.colorScheme.outline.withValues(alpha: 0.5),
                      size: 40,
                    ),
                    SizedBox(height: 1.h),
                    Text(AppLocalizations.of(context)?.noSiblingsAddedYet ?? 'No siblings added yet',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            )
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _siblingsList.length,
              separatorBuilder: (context, index) => SizedBox(height: 1.5.h),
              itemBuilder: (context, index) {
                final sibling = _siblingsList[index];
                return _buildSiblingRow(theme, index, sibling);
              },
            ),

          SizedBox(height: 2.h),

          // Add Sibling Button
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: _addSibling,
              icon: const Icon(Icons.add),
              label: Text(AppLocalizations.of(context)?.addSibling ?? 'Add Sibling'),
              style: OutlinedButton.styleFrom(
                padding: EdgeInsets.symmetric(vertical: 1.5.h),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
          SizedBox(height: 3.h),

          // Family Type & Status
          Row(
            children: [
              Expanded(
                child: _buildDropdownField(
                  theme: theme,
                  label: AppLocalizations.of(context)?.familyType ?? 'Family Type',
                  value: _selectedFamilyType,
                  items: _familyTypeKeys.map((key) => DropdownMenuItem(
                    value: key,
                    child: Text(_getLocalizedFamilyType(context, key), overflow: TextOverflow.ellipsis),
                  )).toList(),
                  icon: 'groups',
                  onChanged: (val) {
                    setState(() => _selectedFamilyType = val);
                    widget.onUpdate('familyType', val);
                  },
                ),
              ),
              SizedBox(width: 4.w),
              Expanded(
                child: _buildDropdownField(
                  theme: theme,
                  label: AppLocalizations.of(context)?.familyStatus ?? 'Family Status',
                  value: _selectedFamilyStatus,
                  items: _familyStatusKeys.map((key) => DropdownMenuItem(
                    value: key,
                    child: Text(_getLocalizedFamilyStatus(context, key), overflow: TextOverflow.ellipsis),
                  )).toList(),
                  icon: 'home',
                  onChanged: (val) {
                    setState(() => _selectedFamilyStatus = val);
                    widget.onUpdate('familyStatus', val);
                  },
                ),
              ),
            ],
          ),
          SizedBox(height: 2.h),

          SizedBox(height: 4.h),

          // About self section (kept at bottom)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(AppLocalizations.of(context)?.aboutYourself ?? 'About Yourself', style: theme.textTheme.titleLarge),
              TextButton.icon(
                onPressed: _isGeneratingBio ? null : _generateBio,
                icon: _isGeneratingBio
                    ? SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: theme.colorScheme.primary,
                        ),
                      )
                    : Icon(
                        Icons.auto_awesome,
                        size: 18,
                        color: _isPremiumUser ? Colors.amber[700] : theme.colorScheme.primary,
                      ),
                label: Text(
                  _isGeneratingBio
                      ? AppLocalizations.of(context)?.loading ?? 'Generating...'
                      : (_isPremiumUser 
                          ? '✨ ${AppLocalizations.of(context)?.aiBio ?? 'AI Bio'}' 
                          : '✨ ${AppLocalizations.of(context)?.generateBio ?? 'Generate Bio'}'),
                  style: TextStyle(
                    color: _isPremiumUser ? Colors.amber[800] : theme.colorScheme.primary,
                    fontWeight: AppTypography.bold,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 1.h),
          TextFormField(
            controller: _aboutSelfController,
            maxLines: 5,
            maxLength: _maxCharacters,
            decoration: InputDecoration(
              hintText: AppLocalizations.of(context)?.describeYourselfInterestsHobbies ?? 'Describe yourself, interests, hobbies...',
              alignLabelWithHint: true,
              prefixIcon: CustomIconWidget(
                iconName: 'notes',
                color: theme.colorScheme.onSurfaceVariant,
                size: 20,
              ),
              counterText: '$currentLength/$_maxCharacters',
            ),
            onChanged: (value) {
              widget.onUpdate('aboutSelf', value);
              setState(() {});
            },
          ),
          SizedBox(height: 3.h),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required String icon,
    required ThemeData theme,
    bool required = false,
    TextInputType? keyboardType,
    Function(String)? onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(label, style: theme.textTheme.titleMedium),
            if (required && !widget.isAdminEdit) ...[
              SizedBox(width: 1.w),
              Text(
                AppLocalizations.of(context)?.emptyStr ?? '*',
                style: theme.textTheme.titleMedium?.copyWith(
                  color: theme.colorScheme.error,
                ),
              ),
            ],
          ],
        ),
        SizedBox(height: 1.h),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          validator: required && !widget.isAdminEdit
              ? (value) {
                  if (value == null || value.isEmpty) {
                    return AppLocalizations.of(context)?.fieldRequired(label) ?? '$label is required';
                  }
                  return null;
                }
              : null,
          decoration: InputDecoration(
            hintText: hint,
            prefixIcon: CustomIconWidget(
              iconName: icon,
              color: theme.colorScheme.onSurfaceVariant,
              size: 20,
            ),
          ),
          onChanged: onChanged,
        ),
      ],
    );
  }

  Widget _buildSiblingRow(ThemeData theme, int index, SiblingModel sibling) {
    return Container(
      padding: EdgeInsets.all(3.w),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: theme.colorScheme.outline.withValues(alpha: 0.2)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              // Position Circle
              CircleAvatar(
                radius: 12,
                backgroundColor: theme.colorScheme.primary,
                child: Text(
                  '${sibling.position}',
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: theme.colorScheme.onPrimary,
                    fontWeight: AppTypography.bold,
                  ),
                ),
              ),
              SizedBox(width: 3.w),
              // Relation Dropdown
              Expanded(
                flex: 3,
                child: _buildInlineDropdown(
                  theme: theme,
                  value: sibling.relation,
                  items: _relationKeys.map((key) => DropdownMenuItem(
                    value: key,
                    child: Text(
                      _getLocalizedRelation(context, key),
                      style: theme.textTheme.bodySmall?.copyWith(
                        fontWeight: key == 'Self'
                            ? AppTypography.bold
                            : FontWeight.normal,
                        color: key == 'Self' ? theme.colorScheme.primary : null,
                      ),
                    ),
                  )).toList(),
                  onChanged: (val) => _updateSibling(index, relation: val),
                ),
              ),
              SizedBox(width: 3.w),
              // Married Toggle
              Row(
                children: [
                  Text(
                    sibling.isMarried ? (AppLocalizations.of(context)?.married ?? 'Married') : (AppLocalizations.of(context)?.unmarried ?? 'Unmarried'),
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: sibling.isMarried
                          ? theme.colorScheme.primary
                          : theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  Switch(
                    value: sibling.isMarried,
                    onChanged: sibling.relation == 'Self'
                        ? null // Self status usually fixed or handled elsewhere
                        : (val) => _updateSibling(index, isMarried: val),
                  ),
                ],
              ),
              // Delete Button
              IconButton(
                icon: const Icon(
                  Icons.delete_outline,
                  color: Colors.redAccent,
                  size: 20,
                ),
                onPressed: () => _removeSibling(index),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInlineDropdown({
    required ThemeData theme,
    required String value,
    required List<DropdownMenuItem<String>> items,
    required Function(String?) onChanged,
  }) {
    return DropdownButtonHideUnderline(
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 2.w),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: theme.colorScheme.outline.withValues(alpha: 0.3)),
        ),
        child: DropdownButton<String>(
          value: items.any((i) => i.value == value) ? value : items.first.value,
          isExpanded: true,
          icon: const Icon(Icons.arrow_drop_down, size: 20),
          items: items,
          onChanged: onChanged,
        ),
      ),
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
        Text(label, style: theme.textTheme.titleMedium),
        SizedBox(height: 1.h),
        DropdownButtonFormField<String>(
          initialValue: value != null && items.any((i) => i.value == value) ? value : null,
          isExpanded: true,
          decoration: InputDecoration(
            prefixIcon: CustomIconWidget(
              iconName: icon,
              color: theme.colorScheme.onSurfaceVariant,
              size: 20,
            ),
          ),
          items: items,
          onChanged: onChanged,
        ),
      ],
    );
  }
}
