import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import 'package:banjarabio/core/models/biodata_content.dart';
import 'package:banjarabio/presentation/biodata_editor_screen/widgets/biodata_ui_helpers.dart';
import 'package:banjarabio/core/constants/app_typography.dart';
import 'package:banjarabio/theme/app_colors.dart';

/// Details editor tab content for the Biodata Editor.
/// Extracted from BiodataEditorScreen._buildDetailsEditor,
/// _buildEditSection, and _buildMultilineEdit.
class EditorDetailsWidget extends StatelessWidget {
  final BiodataContent content;
  final Map<String, TextEditingController> controllers;
  final VoidCallback onContentChanged;
  final ValueChanged<BiodataContent> onContentUpdated;

  const EditorDetailsWidget({
    super.key,
    required this.content,
    required this.controllers,
    required this.onContentChanged,
    required this.onContentUpdated,
  });

  IconData _getSectionIcon(String title) {
    final lower = title.toLowerCase();
    if (lower.contains('personal')) return Icons.person_outline_rounded;
    if (lower.contains('family')) return Icons.favorite_outline_rounded;
    if (lower.contains('education') || lower.contains('career')) {
      return Icons.work_outline_rounded;
    }
    if (lower.contains('horoscope')) return Icons.auto_awesome_rounded;
    if (lower.contains('marriage')) return Icons.church_rounded;
    if (lower.contains('contact')) return Icons.contact_phone_outlined;
    return Icons.edit_note_rounded;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildEditSection(context, 'Personal Details', content.personalDetails),
        _buildEditSection(context, 'Education & Profession', content.educationProfession),
        _buildEditSection(context, 'Family Details', content.familyDetails),
        _buildEditSection(context, 'Location & Contact', content.locationContact),
        _buildMultilineEdit(context, 'Partner Expectations', 'partnerExpectations'),
        _buildMultilineEdit(context, 'About Me', 'aboutMe'),
        SizedBox(height: 2.h),
      ],
    );
  }

  Widget _buildEditSection(BuildContext context, String title, Map<String, String> data) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
      child: Container(
        decoration: BiodataTheme.sectionCardDecoration(),
        child: Theme(
          data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
          child: ExpansionTile(
            leading: Icon(
              _getSectionIcon(title),
              color: BiodataTheme.royalGold,
              size: 22.sp,
            ),
            title: Text(
              title,
              style: BiodataTheme.subHeaderStyle.copyWith(
                fontSize: AppTypography.bodyLarge,
                color: BiodataTheme.deepCharcoal,
              ),
            ),
            iconColor: BiodataTheme.royalGold,
            collapsedIconColor: BiodataTheme.deepCharcoal.withValues(alpha: AppColors.opacity50),
            childrenPadding: EdgeInsets.fromLTRB(4.w, 0, 4.w, 2.h),
            children: data.keys.map((key) {
              return Padding(
                padding: EdgeInsets.only(bottom: 1.2.h),
                child: TextField(
                  controller: controllers[key],
                  decoration: BiodataTheme.inputDecoration(labelText: key),
                  onChanged: (value) {
                    data[key] = value;
                    onContentChanged();
                  },
                ),
              );
            }).toList(),
          ),
        ),
      ),
    );
  }

  Widget _buildMultilineEdit(BuildContext context, String title, String key) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
      child: Container(
        padding: EdgeInsets.all(4.w),
        decoration: BiodataTheme.sectionCardDecoration(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Icon(
                  _getSectionIcon(title),
                  color: BiodataTheme.royalGold,
                  size: 22.sp,
                ),
                SizedBox(width: 3.w),
                Text(
                  title,
                  style: BiodataTheme.subHeaderStyle.copyWith(
                    fontSize: AppTypography.bodyLarge,
                    color: BiodataTheme.deepCharcoal,
                  ),
                ),
              ],
            ),
            SizedBox(height: 1.5.h),
            TextField(
              controller: controllers[key],
              maxLines: 4,
              decoration: BiodataTheme.inputDecoration(labelText: title).copyWith(
                alignLabelWithHint: true,
                contentPadding: const EdgeInsets.all(16),
              ),
              onChanged: (value) {
                if (key == 'partnerExpectations') {
                  onContentUpdated(content.copyWith(partnerExpectations: value));
                } else if (key == 'aboutMe') {
                  onContentUpdated(content.copyWith(aboutMe: value));
                }
                onContentChanged();
              },
            ),
          ],
        ),
      ),
    );
  }
}
