import 'package:banjarabio/core/constants/app_typography.dart';
import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import 'package:banjarabio/core/constants/biodata_templates.dart';
import 'package:banjarabio/core/models/biodata_template_type.dart';
import 'package:banjarabio/presentation/biodata_editor_screen/widgets/biodata_ui_helpers.dart';

/// Horizontal template picker for the Biodata Editor.
/// Extracted from BiodataEditorScreen._buildTemplatePicker.
class EditorTemplatePickerWidget extends StatelessWidget {
  final BiodataTemplateType selectedTemplate;
  final bool isPremiumUnlocked;
  final ValueChanged<BiodataTemplateType> onTemplateSelected;

  const EditorTemplatePickerWidget({
    super.key,
    required this.selectedTemplate,
    required this.isPremiumUnlocked,
    required this.onTemplateSelected,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 18.h,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: kBiodataTemplates.length,
        padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
        itemBuilder: (context, index) {
          final template = kBiodataTemplates[index];
          final type = template.type;
          final isSelected = selectedTemplate == type;
          final isLockedTemplate = type.isPremium && !isPremiumUnlocked;

          return Padding(
            padding: EdgeInsets.only(right: 2.4.w),
            child: Semantics(
              label:
                  '${type.displayName} template${type.isPremium ? ', Premium' : ''}${isLockedTemplate ? ', locked' : ''}',
              selected: isSelected,
              button: true,
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(BiodataTheme.radiusLg),
                  onTap: () => onTemplateSelected(type),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 220),
                    curve: Curves.easeOutCubic,
                    width: 30.w,
                    padding: EdgeInsets.symmetric(
                      horizontal: 2.2.w,
                      vertical: 1.0.h,
                    ),
                    decoration: BoxDecoration(
                      color: BiodataTheme.surfaceWhite,
                      borderRadius:
                          BorderRadius.circular(BiodataTheme.radiusLg),
                      border: Border.all(
                        color: isSelected
                            ? BiodataTheme.royalGold
                            : BiodataTheme.deepCharcoal.withValues(alpha: 0.08),
                        width: isSelected ? 2 : 1,
                      ),
                      boxShadow: isSelected
                          ? const [
                              BoxShadow(
                                color: Color.fromRGBO(212, 175, 55, 0.25),
                                blurRadius: 14,
                                offset: Offset(0, 6),
                              ),
                            ]
                          : const [
                              BoxShadow(
                                color: Color.fromRGBO(30, 30, 30, 0.04),
                                blurRadius: 8,
                                offset: Offset(0, 3),
                              ),
                            ],
                    ),
                    child: AspectRatio(
                      aspectRatio: 3 / 4,
                      child: Stack(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(BiodataTheme.radiusSm),
                            child: Image.asset(
                              template.assetPath,
                              fit: BoxFit.cover,
                              width: double.infinity,
                              height: double.infinity,
                            ),
                          ),
                          Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(BiodataTheme.radiusSm),
                              color: Colors.black.withValues(alpha: 0.1),
                            ),
                          ),
                          // Template name stacked on the preview
                          Positioned(
                            left: 8,
                            right: 8,
                            bottom: 8,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.black.withValues(alpha: 0.45),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                type.displayName,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: BiodataTheme.captionStyle.copyWith(
                                  color: Colors.white,
                                  fontWeight: AppTypography.semiBold,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
