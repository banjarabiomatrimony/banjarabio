import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';

import 'package:banjarabio/l10n/app_localizations.dart';
import 'package:banjarabio/widgets/custom_icon_widget.dart';

/// Reusable text field widget for biodata creation forms.
/// Extracted from PersonalDetailsSection._buildTextField.
class BiodataTextField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String hint;
  final String icon;
  final bool required;
  final bool isAdminEdit;
  final TextInputType? keyboardType;
  final List<TextInputFormatter>? inputFormatters;
  final Function(String)? onChanged;

  const BiodataTextField({
    super.key,
    required this.controller,
    required this.label,
    required this.hint,
    required this.icon,
    required this.required,
    this.isAdminEdit = false,
    this.keyboardType,
    this.inputFormatters,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(label, style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold)),
            if (required && !isAdminEdit) ...[
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
          validator: required && !isAdminEdit
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
}
