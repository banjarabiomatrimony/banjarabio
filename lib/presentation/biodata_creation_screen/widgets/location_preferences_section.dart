import 'package:flutter/material.dart';
import 'package:banjarabio/l10n/app_localizations.dart';
import 'package:sizer/sizer.dart';

import 'package:banjarabio/core/app_export.dart';
import 'package:banjarabio/core/data/location_data.dart';

/// Location and preferences section for biodata creation
/// Handles structured location input (State/District/Taluka) and marriage readiness status
class LocationPreferencesSection extends StatefulWidget {
  final Map<String, dynamic> formData;
  final Function(String, dynamic) onUpdate;
  final Function(Map<String, dynamic>) onBatchUpdate;
  final Function(bool) onValidationChange;
  final bool isLite;

  const LocationPreferencesSection({
    super.key,
    required this.formData,
    this.isAdminEdit = false,
    this.isLite = false,
    required this.onUpdate,
    required this.onBatchUpdate,
    required this.onValidationChange,
  });

  final bool isAdminEdit;

  @override
  State<LocationPreferencesSection> createState() =>
      _LocationPreferencesSectionState();
}

class _LocationPreferencesSectionState
    extends State<LocationPreferencesSection> {
  // Location dropdowns
  String? _selectedState;
  String? _selectedDistrict;
  String? _selectedTaluka;

  // Village text field
  final _villageController = TextEditingController();

  // Native Place text field
  final _nativePlaceController = TextEditingController();

  // Expectations
  final _partnerExpectationController = TextEditingController();

  bool _marriageReadiness = true;

  // Dynamic lists based on selection
  List<String> _districts = [];
  List<String> _talukas = [];

  @override
  void initState() {
    super.initState();
    _initializeData();
    _villageController.addListener(_validateForm);
    _nativePlaceController.addListener(_validateForm);
    _partnerExpectationController.addListener(_validateForm);
    WidgetsBinding.instance.addPostFrameCallback((_) => _validateForm());
  }

  void _initializeData() {
    // Initialize from form data
    _selectedState = widget.formData['state']?.toString();
    _selectedDistrict = widget.formData['district']?.toString();
    _selectedTaluka = widget.formData['taluka']?.toString();

    final village = widget.formData['village']?.toString() ?? '';
    if (_villageController.text != village) _villageController.text = village;

    final nativePlace = widget.formData['nativePlace']?.toString() ?? '';
    if (_nativePlaceController.text != nativePlace) {
      _nativePlaceController.text = nativePlace;
    }

    final partnerExpectations =
        (widget.formData['partnerExpectations'] ??
                widget.formData['partner_expectations'])
            ?.toString() ??
        '';
    if (_partnerExpectationController.text != partnerExpectations) {
      _partnerExpectationController.text = partnerExpectations;
    }

    _marriageReadiness = widget.formData['marriageReadiness'] ?? true;

    // Populate dependent dropdowns
    if (_selectedState != null && _selectedState!.isNotEmpty) {
      _districts = LocationData.getDistricts(_selectedState!);
    } else {
      _districts = [];
    }
    if (_selectedDistrict != null && _selectedDistrict!.isNotEmpty) {
      _talukas = LocationData.getTalukas(_selectedDistrict!);
    } else {
      _talukas = [];
    }
  }

  @override
  void didUpdateWidget(covariant LocationPreferencesSection oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.formData != oldWidget.formData ||
        widget.isAdminEdit != oldWidget.isAdminEdit ||
        widget.isLite != oldWidget.isLite) {
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
    _villageController.removeListener(_validateForm);
    _nativePlaceController.removeListener(_validateForm);
    _partnerExpectationController.removeListener(_validateForm);
    _villageController.dispose();
    _nativePlaceController.dispose();
    _partnerExpectationController.dispose();
    super.dispose();
  }

  void _validateForm() {
    if (widget.isAdminEdit) {
      widget.onValidationChange(true);
      return;
    }
    // At minimum, state must be selected
    final isValid = _selectedState != null && _selectedState!.isNotEmpty;
    widget.onValidationChange(isValid);
  }

  void _onStateChanged(String? value) {
    setState(() {
      _selectedState = value;
      _selectedDistrict = null;
      _selectedTaluka = null;
      _districts = value != null ? LocationData.getDistricts(value) : [];
      _talukas = [];
    });

    final legacyLocation = _getLegacyLocation();
    widget.onBatchUpdate({
      'state': value,
      'district': null,
      'taluka': null,
      'permanent_location': legacyLocation,
    });
    _validateForm();
  }

  void _onDistrictChanged(String? value) {
    setState(() {
      _selectedDistrict = value;
      _selectedTaluka = null;
      _talukas = value != null ? LocationData.getTalukas(value) : [];
    });

    final legacyLocation = _getLegacyLocation();
    widget.onBatchUpdate({
      'district': value,
      'taluka': null,
      'permanent_location': legacyLocation,
    });
    _validateForm();
  }

  void _onTalukaChanged(String? value) {
    setState(() {
      _selectedTaluka = value;
    });

    final legacyLocation = _getLegacyLocation();
    widget.onBatchUpdate({
      'taluka': value,
      'permanent_location': legacyLocation,
    });
    _validateForm();
  }

  String _getLegacyLocation() {
    return LocationData.formatLocation(
      taluka: _selectedTaluka,
      district: _selectedDistrict,
      state: _selectedState,
      village: _villageController.text,
    );
  }

  void _updateLegacyLocation() {
    // Update the legacy 'location' field with formatted location for backward compatibility
    final formatted = LocationData.formatLocation(
      taluka: _selectedTaluka,
      district: _selectedDistrict,
      state: _selectedState,
      village: _villageController.text,
    );
    widget.onUpdate(
      'permanent_location',
      formatted,
    ); // Map to permanent_location
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SingleChildScrollView(
      padding: EdgeInsets.all(4.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(AppLocalizations.of(context)?.locationPreferences ?? 'Location & Preferences', style: theme.textTheme.headlineSmall),
          SizedBox(height: 1.h),
          Text(AppLocalizations.of(context)?.selectYourLocationAndPreferences ?? 'Select your location and preferences',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          SizedBox(height: 3.h),

          // State Dropdown
          _buildDropdownField(
            theme: theme,
            label: AppLocalizations.of(context)?.currentResidenceState ?? 'Current Residence State',
            value: _selectedState,
            items: LocationData.states,
            isRequired: true,
            icon: 'public',
            onChanged: _onStateChanged,
            hintText: AppLocalizations.of(context)?.selectState ?? 'Select State',
          ),

          // --- Everything below is HIDDEN in lite signup mode ---
          if (!widget.isLite) ...[
          SizedBox(height: 2.h),

          // District Dropdown
          _buildDropdownField(
            theme: theme,
            label: AppLocalizations.of(context)?.district ?? 'District',
            value: _selectedDistrict,
            items: _districts,
            isRequired: true,
            icon: 'place',
            onChanged: _onDistrictChanged,
            hintText: _selectedState == null
                ? AppLocalizations.of(context)?.selectStateFirst ?? 'Select State first'
                : AppLocalizations.of(context)?.district ?? 'Select District',
            enabled: _selectedState != null,
          ),
          SizedBox(height: 2.h),

          // Taluka Dropdown
          _buildDropdownField(
            theme: theme,
            label: AppLocalizations.of(context)?.talukaOptional ?? 'Taluka (Optional)', // Explicitly labeled as Optional
            value: _selectedTaluka,
            items: _talukas,
            isRequired: false, // User requested optional
            icon: 'explore',
            onChanged: _onTalukaChanged,
            hintText: _selectedDistrict == null
                ? AppLocalizations.of(context)?.selectDistrictFirst ?? 'Select District first'
                : _talukas.isEmpty
                ? AppLocalizations.of(context)?.noTalukasAvailable ?? 'No talukas available'
                : AppLocalizations.of(context)?.selectTalukaOptional ?? 'Select Taluka (Optional)',
            enabled: _selectedDistrict != null && _talukas.isNotEmpty,
          ),
          SizedBox(height: 2.h),

          // Village & Native Place
          Row(
            children: [
              Expanded(
                child: _buildTextField(
                  theme: theme,
                  label: AppLocalizations.of(context)?.village ?? 'Village',
                  controller: _villageController,
                  hint: AppLocalizations.of(context)?.currentVillageHint ?? 'Current village',
                  iconData: Icons.home_rounded,
                  onChanged: (val) {
                    widget.onUpdate('village', val);
                    _updateLegacyLocation();
                  },
                ),
              ),
              SizedBox(width: 4.w),
              Expanded(
                child: _buildTextField(
                  theme: theme,
                  label: AppLocalizations.of(context)?.nativePlace ?? 'Native Place',
                  controller: _nativePlaceController,
                  hint: AppLocalizations.of(context)?.originalVillageHint ?? 'Original village',
                  iconData: Icons.location_city_rounded,
                  onChanged: (val) => widget.onUpdate('nativePlace', val),
                ),
              ),
            ],
          ),
          SizedBox(height: 3.h),

          // Partner Expectations Field
          _buildTextField(
            theme: theme,
            label: AppLocalizations.of(context)?.partnerExpectations ?? 'Partner Expectations',
            controller: _partnerExpectationController,
            hint: AppLocalizations.of(context)?.partnerExpectationsHint ?? 'Describe what you are looking for...',
            iconData: Icons.star_rounded,
            maxLines: 4,
            onChanged: (val) => widget.onUpdate('partnerExpectations', val),
          ),
          SizedBox(height: 3.h),



          // Marriage readiness toggle
          Container(
            padding: EdgeInsets.all(4.w),
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: theme.colorScheme.outline),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(AppLocalizations.of(context)?.readyForMarriage ?? 'Ready for Marriage',
                        style: theme.textTheme.titleMedium,
                      ),
                      Text(AppLocalizations.of(context)?.areYouReadyForDiscussions ?? 'Are you ready for discussions?',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                Switch(
                  value: _marriageReadiness,
                  onChanged: (value) {
                    setState(() => _marriageReadiness = value);
                    widget.onUpdate('marriageReadiness', value);
                  },
                ),
              ],
            ),
          ),
          SizedBox(height: 4.h),
          ], // end of !isLite conditional block

          // Selected Photos Preview (Phase 2.7)
          if ((widget.formData['photos'] as List?)?.isNotEmpty ?? false) ...[
            Text(AppLocalizations.of(context)?.selectedPhotos ?? 'Selected Photos', style: theme.textTheme.titleMedium),
            SizedBox(height: 1.h),
            SizedBox(
              height: 12.h,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: (widget.formData['photos'] as List).length,
                itemBuilder: (context, index) {
                  final photoPath = widget.formData['photos'][index].toString();
                  return Container(
                    width: 12.h,
                    margin: EdgeInsets.only(right: 2.w),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: theme.colorScheme.outline),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: CustomImageWidget(
                        imageUrl: photoPath,
                        fit: BoxFit.cover,
                        width: double.infinity,
                        height: double.infinity,
                      ),
                    ),
                  );
                },
              ),
            ),
            SizedBox(height: 3.h),
          ],

          // Location preview
          if (_selectedState != null) ...[
            Container(
              padding: EdgeInsets.all(4.w),
              decoration: BoxDecoration(
                color: theme.colorScheme.primaryContainer.withValues(
                  alpha: 0.3,
                ),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: theme.colorScheme.primary.withValues(alpha: AppColors.opacity30),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      CustomIconWidget(
                        iconName: 'location_on',
                        color: theme.colorScheme.primary,
                        size: 20,
                      ),
                      SizedBox(width: 2.w),
                      Text(AppLocalizations.of(context)?.locationPreview ?? 'Location Preview',
                        style: theme.textTheme.titleSmall?.copyWith(
                          color: theme.colorScheme.primary,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 1.5.h),
                  Text(
                    LocationData.formatLocation(
                      taluka: _selectedTaluka,
                      district: _selectedDistrict,
                      state: _selectedState,
                      village: _villageController.text,
                    ),
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: AppTypography.semiBold,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 3.h),
          ],

          // Completion summary
          Container(
            padding: EdgeInsets.all(4.w),
            decoration: BoxDecoration(
              color: theme.colorScheme.secondaryContainer.withValues(
                alpha: 0.3,
              ),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: theme.colorScheme.secondary.withValues(alpha: AppColors.opacity30),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    CustomIconWidget(
                      iconName: 'check_circle',
                      color: theme.colorScheme.secondary,
                      size: 20,
                    ),
                    SizedBox(width: 2.w),
                    Text(AppLocalizations.of(context)?.almostDone ?? 'Almost Done!',
                      style: theme.textTheme.titleSmall?.copyWith(
                        color: theme.colorScheme.secondary,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 1.5.h),
                Text(
                  AppLocalizations.of(context)?.almostDoneReview ?? 'Review all sections and click "Save Biodata" to complete your profile. Your biodata will be visible to other community members based on your privacy settings.',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required ThemeData theme,
    required String label,
    required TextEditingController controller,
    required String hint,
    String? icon,
    IconData? iconData,
    int maxLines = 1,
    Function(String)? onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: theme.textTheme.titleMedium),
        SizedBox(height: 1.h),
        TextFormField(
          controller: controller,
          maxLines: maxLines,
          decoration: InputDecoration(
            hintText: hint,
            prefixIcon: iconData != null
                ? Icon(
                    iconData,
                    color: theme.colorScheme.onSurfaceVariant,
                    size: 20,
                  )
                : CustomIconWidget(
                    iconName: icon ?? 'info_outline',
                    color: theme.colorScheme.onSurfaceVariant,
                    size: 20,
                  ),
          ),
          onChanged: onChanged,
        ),
      ],
    );
  }

  Widget _buildDropdownField({
    required ThemeData theme,
    required String label,
    required String? value,
    required List<String> items,
    required bool isRequired,
    String? icon,
    IconData? iconData,
    required Function(String?) onChanged,
    required String hintText,
    bool enabled = true,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(label, style: theme.textTheme.titleMedium),
            if (isRequired && !widget.isAdminEdit) ...[
              SizedBox(width: 1.w),
              Text('*',
                style: theme.textTheme.titleMedium?.copyWith(
                  color: theme.colorScheme.error,
                ),
              ),
            ],
          ],
        ),
        SizedBox(height: 1.h),
        DropdownButtonFormField<String>(
          initialValue: value != null && items.contains(value) ? value : null,
          isExpanded: true,
          decoration: InputDecoration(
            hintText: hintText,
            filled: true,
            prefixIcon: iconData != null
                ? Icon(
                    iconData,
                    color: theme.colorScheme.onSurfaceVariant,
                    size: 20,
                  )
                : CustomIconWidget(
                    iconName: icon ?? 'info_outline',
                    color: theme.colorScheme.onSurfaceVariant,
                    size: 20,
                  ),
            fillColor: enabled
                ? theme.colorScheme.surface
                : theme.colorScheme.surfaceContainerHighest.withValues(
                    alpha: 0.5,
                  ),
          ),
          items: items.map((item) {
            return DropdownMenuItem<String>(
              value: item,
              child: Text(item, overflow: TextOverflow.ellipsis),
            );
          }).toList(),
          onChanged: enabled ? onChanged : null,
          validator: isRequired && !widget.isAdminEdit
              ? (value) {
                  if (value == null || value.isEmpty) {
                    return AppLocalizations.of(context)?.fieldRequired(label) ?? '$label is required';
                  }
                  return null;
                }
              : null,
        ),
      ],
    );
  }
}
