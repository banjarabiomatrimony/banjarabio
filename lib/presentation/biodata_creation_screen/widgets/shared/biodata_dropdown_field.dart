import 'package:banjarabio/core/constants/app_typography.dart';
import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import 'package:banjarabio/widgets/custom_icon_widget.dart';
import 'package:banjarabio/theme/app_colors.dart';

/// Reusable dropdown field widget for biodata creation forms.
/// Extracted from PersonalDetailsSection._buildDropdownField.
class BiodataDropdownField extends StatelessWidget {
  final String label;
  final String? value;
  final List<DropdownMenuItem<String>> items;
  final String? icon;
  final IconData? iconData;
  final bool required;
  final bool isAdminEdit;
  final Function(String?) onChanged;

  const BiodataDropdownField({
    super.key,
    required this.label,
    required this.value,
    required this.items,
    this.icon,
    this.iconData,
    this.required = false,
    this.isAdminEdit = false,
    required this.onChanged,
  }) : assert(icon != null || iconData != null, 'Must provide either icon or iconData');

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(label, style: theme.textTheme.titleSmall?.copyWith(fontWeight: AppTypography.bold)),
            if (required && !isAdminEdit) ...[
              SizedBox(width: 1.w),
              Text(
                '*',
                style: theme.textTheme.titleSmall?.copyWith(
                  color: theme.colorScheme.error,
                  fontWeight: AppTypography.bold,
                ),
              ),
            ],
          ],
        ),
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
              child: iconData != null
                  ? Icon(
                      iconData,
                      color: theme.colorScheme.primary.withValues(alpha: AppColors.opacity70),
                      size: 20,
                    )
                  : CustomIconWidget(
                      iconName: icon!,
                      color: theme.colorScheme.primary.withValues(alpha: AppColors.opacity70),
                      size: 20,
                    ),
            ),
            prefixIconConstraints: const BoxConstraints(minWidth: 40),
            contentPadding: EdgeInsets.symmetric(vertical: 2.h, horizontal: 4.w),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(color: theme.colorScheme.outline.withValues(alpha: AppColors.opacity20)),
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
}
