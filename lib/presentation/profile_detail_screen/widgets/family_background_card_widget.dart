import 'package:flutter/material.dart';
import 'package:banjarabio/l10n/app_localizations.dart';
import 'package:sizer/sizer.dart';

import 'package:banjarabio/core/app_export.dart';
import 'package:banjarabio/widgets/custom_icon_widget.dart';
import 'package:banjarabio/presentation/profile_detail_screen/widgets/profile_detail_chip_widget.dart';

/// Family background card displaying detailed family information
/// Critical for arranged marriage evaluation in Banjara community
class FamilyBackgroundCardWidget extends StatelessWidget {
  final Map<String, dynamic> profileData;
  final EdgeInsets? margin;

  const FamilyBackgroundCardWidget({
    super.key,
    required this.profileData,
    this.margin,
  });

  /// Returns AppLocalizations.of(context).notEntered for null or empty values, otherwise the value string.
  String _displayValue(BuildContext context, dynamic value) {
    if (value == null) return AppLocalizations.of(context)?.notEntered ?? 'Not Entered';
    final str = value.toString().trim();
    return str.isEmpty ? AppLocalizations.of(context)?.notEntered ?? 'Not Entered' : str;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primary = theme.colorScheme.primary;
    final secondary = theme.colorScheme.secondary;
    final tertiary = theme.colorScheme.tertiary;

    return Container(
      margin: margin ?? EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.2.h),
      padding: EdgeInsets.symmetric(horizontal: 3.2.w, vertical: 1.5.h),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: tertiary.withValues(alpha: 0.05),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(
          color: tertiary.withValues(alpha: 0.45),
          width: 1.2,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(0.8.h),
                decoration: BoxDecoration(
                  color: tertiary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: CustomIconWidget(
                  iconName: 'family_restroom',
                  color: tertiary,
                  size: 22,
                ),
              ),
              SizedBox(width: 2.w),
              Expanded(
                child: Text(AppLocalizations.of(context)?.familyBackground ?? 'Family Background',
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: theme.colorScheme.onSurface,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 0.4,
                    fontSize: 14.5.sp,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          SizedBox(height: 1.5.h),
          
          Wrap(
            spacing: 2.w,
            runSpacing: 2.w,
            children: [
              ProfileDetailChipWidget(
                iconName: 'person',
                label: AppLocalizations.of(context)?.fatherName ?? 'Father\'s Name',
                value: _displayValue(context, profileData['fatherName']),
                tintColor: primary,
                fullWidth: true,
              ),
              ProfileDetailChipWidget(
                iconName: 'work',
                label: AppLocalizations.of(context)?.fatherOccupation ?? 'Father\'s Job',
                value: _displayValue(context, profileData['fatherOccupation']),
                tintColor: secondary,
                fullWidth: true,
              ),
              ProfileDetailChipWidget(
                iconName: 'person',
                label: AppLocalizations.of(context)?.motherName ?? 'Mother\'s Name',
                value: _displayValue(context, profileData['motherName']),
                tintColor: primary,
                fullWidth: true,
              ),
              ProfileDetailChipWidget(
                iconName: 'work_outline',
                label: AppLocalizations.of(context)?.motherOccupation ?? 'Mother\'s Job',
                value: _displayValue(context, profileData['motherOccupation']),
                tintColor: tertiary,
                fullWidth: true,
              ),
              ProfileDetailChipWidget(
                iconName: 'groups',
                label: AppLocalizations.of(context)?.familyType ?? 'Family Type',
                value: _displayValue(context, profileData['familyType']),
                tintColor: secondary,
              ),
              ProfileDetailChipWidget(
                iconName: 'home',
                label: AppLocalizations.of(context)?.familyStatus ?? 'Family Status',
                value: _displayValue(context, profileData['familyStatus']),
                tintColor: primary,
              ),
              ProfileDetailChipWidget(
                iconName: 'location_on',
                label: AppLocalizations.of(context)?.nativePlace ?? 'Native Place',
                value: _displayValue(context, profileData['nativePlace']),
                tintColor: tertiary,
                fullWidth: true,
              ),
              ProfileDetailChipWidget(
                iconName: 'group_add',
                label: AppLocalizations.of(context)?.siblingsLabel ?? 'Siblings',
                value: _getSiblingsSummary(context, profileData),
                tintColor: secondary,
                fullWidth: true,
              ),
            ],
          ),
          
          if (profileData['about'] != null &&
              profileData['about'].toString().isNotEmpty) ...[
            SizedBox(height: 3.h),
            Text(AppLocalizations.of(context)?.aboutSelf ?? 'About Self',
              style: theme.textTheme.titleSmall?.copyWith(
                color: theme.colorScheme.primary,
                fontWeight: FontWeight.w900,
              ),
            ),
            SizedBox(height: 1.h),
            Container(
              padding: EdgeInsets.all(4.w),
              width: double.infinity,
              decoration: BoxDecoration(
                color: primary.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(16),
                border: Border(
                  left: BorderSide(
                    color: primary.withValues(alpha: 0.6),
                    width: 4,
                  ),
                ),
              ),
              child: Text(
                profileData['about'].toString(),
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.9),
                  height: 1.5,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  String _getSiblingsSummary(BuildContext context, Map<String, dynamic> data) {
    final l10n = AppLocalizations.of(context);
    final count = int.tryParse(data['siblingsCount']?.toString() ?? '0') ?? 0;
    if (count == 0) return l10n?.none ?? 'None';

    final sisters = int.tryParse(data['sisterCount']?.toString() ?? '0') ?? 0;
    final brothers = int.tryParse(data['brotherCount']?.toString() ?? '0') ?? 0;

    String summary = l10n?.siblingsCount(count) ?? '$count siblings';

    final List<String> breakdown = [];
    if (brothers > 0) {
      breakdown.add(l10n?.brothersCount(brothers) ?? '$brothers brothers');
    }
    if (sisters > 0) {
      breakdown.add(l10n?.sistersCount(sisters) ?? '$sisters sisters');
    }

    if (breakdown.isNotEmpty) {
      summary += ' (${breakdown.join(', ')})';
    }

    return summary;
  }
}
