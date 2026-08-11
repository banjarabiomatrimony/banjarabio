import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import 'package:banjarabio/l10n/app_localizations.dart';
import 'package:banjarabio/presentation/biodata_editor_screen/widgets/biodata_ui_helpers.dart';
import 'package:banjarabio/core/constants/app_typography.dart';

/// Horizontal language picker for the Biodata Editor.
/// Extracted from BiodataEditorScreen._buildLanguagePicker.
class EditorLanguagePickerWidget extends StatelessWidget {
  final String selectedLanguage;
  final ValueChanged<String> onLanguageSelected;

  const EditorLanguagePickerWidget({
    super.key,
    required this.selectedLanguage,
    required this.onLanguageSelected,
  });

  static const List<String> _languages = ['English', 'Hindi', 'Marathi', 'Telugu', 'Kannada'];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.fromLTRB(4.w, 2.h, 4.w, 1.h),
          child: Text(
            AppLocalizations.of(context)?.selectLanguage ?? 'Select Language',
            style: BiodataTheme.subHeaderStyle.copyWith(
              color: const Color.fromRGBO(26, 26, 26, 0.85),
            ),
          ),
        ),
        SizedBox(
          height: 6.h,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: EdgeInsets.symmetric(horizontal: 4.w),
            itemCount: _languages.length,
            itemBuilder: (context, index) {
              final lang = _languages[index];
              final isSelected = selectedLanguage == lang;
              return Padding(
                padding: EdgeInsets.only(right: 3.w),
                child: Semantics(
                  label: 'Language: $lang',
                  selected: isSelected,
                  button: true,
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () {
                        if (!isSelected) {
                          onLanguageSelected(lang);
                        }
                      },
                      borderRadius: BorderRadius.circular(BiodataTheme.radiusPill),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 250),
                        padding: EdgeInsets.symmetric(horizontal: 6.w),
                        constraints: const BoxConstraints(minWidth: 48),
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          gradient: isSelected ? BiodataTheme.goldGradient : null,
                          color: isSelected ? null : BiodataTheme.surfaceWhite,
                          borderRadius: BorderRadius.circular(BiodataTheme.radiusPill),
                          border: Border.all(
                            color: isSelected
                                ? Colors.transparent
                                : const Color.fromRGBO(212, 175, 55, 0.25),
                          ),
                          boxShadow: isSelected
                              ? [
                                  BoxShadow(
                                    color: BiodataTheme.royalGold.withValues(alpha: 0.25),
                                    blurRadius: 8,
                                    offset: const Offset(0, 2),
                                  ),
                                ]
                              : [
                                  BoxShadow(
                                    color: BiodataTheme.deepCharcoal.withValues(alpha: 0.04),
                                    blurRadius: 4,
                                    offset: const Offset(0, 1),
                                  ),
                                ],
                        ),
                        child: Text(
                          lang,
                          style: BiodataTheme.subHeaderStyle.copyWith(
                            color: isSelected
                                ? Colors.white
                                : BiodataTheme.deepCharcoal,
                            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                            fontSize: AppTypography.bodyMedium,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        SizedBox(height: 1.h),
      ],
    );
  }
}
