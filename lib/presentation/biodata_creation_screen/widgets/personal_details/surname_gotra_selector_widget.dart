import 'package:banjarabio/core/constants/app_typography.dart';
import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import 'package:banjarabio/l10n/app_localizations.dart';
import 'package:banjarabio/widgets/custom_icon_widget.dart';

/// Surname and Gotra dropdown selector with custom surname support.
/// Extracted from PersonalDetailsSection: _buildSurnameDropdown,
/// _buildCustomSurnameField, and _buildGotraDropdown.
class SurnameGotraSelectorWidget extends StatelessWidget {
  final String? selectedSurname;
  final String? selectedGotra;
  final bool showCustomSurname;
  final bool isAdminEdit;
  final TextEditingController customSurnameController;
  final List<String> gotraOptions;
  final List<String> banjaraSurnames;
  final ValueChanged<String?> onSurnameChanged;
  final ValueChanged<String?> onGotraChanged;
  final ValueChanged<String> onCustomSurnameChanged;

  const SurnameGotraSelectorWidget({
    super.key,
    required this.selectedSurname,
    required this.selectedGotra,
    required this.showCustomSurname,
    required this.isAdminEdit,
    required this.customSurnameController,
    required this.gotraOptions,
    required this.banjaraSurnames,
    required this.onSurnameChanged,
    required this.onGotraChanged,
    required this.onCustomSurnameChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSurnameDropdown(context, theme),
        if (showCustomSurname) ...[
          SizedBox(height: 2.h),
          _buildCustomSurnameField(context, theme),
        ],
        if (gotraOptions.isNotEmpty) ...[
          SizedBox(height: 2.5.h),
          _buildGotraDropdown(context, theme),
        ],
      ],
    );
  }

  Widget _buildSurnameDropdown(BuildContext context, ThemeData theme) {
    // Ensure value is null if not in list (prevents dropdown assertion error)
    final dropdownValue = banjaraSurnames.contains(selectedSurname)
        ? selectedSurname
        : null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(AppLocalizations.of(context)?.surname ?? 'Surname', style: theme.textTheme.titleSmall?.copyWith(fontWeight: AppTypography.bold)),
            if (!isAdminEdit) ...[
              SizedBox(width: 1.w),
              Text('*', style: theme.textTheme.titleSmall?.copyWith(color: theme.colorScheme.error, fontWeight: AppTypography.bold)),
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
          items: banjaraSurnames.map((surname) {
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
          onChanged: onSurnameChanged,
        ),
      ],
    );
  }

  Widget _buildCustomSurnameField(BuildContext context, ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(AppLocalizations.of(context)?.surname ?? 'Surname', style: theme.textTheme.titleMedium),
        SizedBox(height: 1.h),
        TextFormField(
          controller: customSurnameController,
          decoration: InputDecoration(
            hintText: AppLocalizations.of(context)?.selectYourSurname ?? 'Select your surname',
            prefixIcon: CustomIconWidget(
              iconName: 'edit',
              color: theme.colorScheme.onSurfaceVariant,
              size: 20,
            ),
          ),
          onChanged: onCustomSurnameChanged,
        ),
      ],
    );
  }

  Widget _buildGotraDropdown(BuildContext context, ThemeData theme) {
    // Ensure value is null if not in list (prevents dropdown assertion error)
    final dropdownValue = gotraOptions.contains(selectedGotra)
        ? selectedGotra
        : null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(AppLocalizations.of(context)?.gotra ?? 'Gotra', style: theme.textTheme.titleSmall?.copyWith(fontWeight: AppTypography.bold)),
            if (!isAdminEdit) ...[
              SizedBox(width: 1.w),
              Text('*', style: theme.textTheme.titleSmall?.copyWith(color: theme.colorScheme.error, fontWeight: AppTypography.bold)),
            ],
          ],
        ),
        SizedBox(height: 1.h),
        DropdownButtonFormField<String>(
          key: ValueKey(selectedSurname),
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
          items: gotraOptions.map((gotra) {
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
          onChanged: onGotraChanged,
        ),
      ],
    );
  }
}
