import 'package:flutter/material.dart';
import 'package:banjarabio/l10n/app_localizations.dart';
import 'package:sizer/sizer.dart';

import 'package:banjarabio/core/app_export.dart';
import 'package:banjarabio/widgets/custom_icon_widget.dart';
import 'package:banjarabio/presentation/profile_detail_screen/widgets/profile_detail_chip_widget.dart';

/// Personal details card displaying basic biodata information
/// Follows traditional matrimonial biodata format with clear hierarchy
class PersonalDetailsCardWidget extends StatelessWidget {
  final Map<String, dynamic> profileData;
  final EdgeInsets? margin;

  const PersonalDetailsCardWidget({
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
            color: primary.withValues(alpha: 0.05),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(
          color: primary.withValues(alpha: 0.45),
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
                  color: primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: CustomIconWidget(
                  iconName: 'person',
                  color: primary,
                  size: 22,
                ),
              ),
              SizedBox(width: 2.w),
              Expanded(
                child: Text(AppLocalizations.of(context)?.personalDetails ?? 'Personal Details',
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: theme.colorScheme.onSurface,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 0.4,
                    fontSize: 14.5.sp, // Slightly reduced for narrow columns
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
                iconName: 'badge',
                label: AppLocalizations.of(context)?.fullName ?? 'Full Name',
                value: _displayValue(context, profileData['name']),
                tintColor: primary,
                fullWidth: true,
              ),
              ProfileDetailChipWidget(
                iconName: 'cake',
                label: AppLocalizations.of(context)?.ageLabel ?? 'Age',
                value: profileData['age'] != null
                    ? AppLocalizations.of(context)?.yearsOld(profileData['age'].toString()) ?? '${profileData['age']} Years'
                    : AppLocalizations.of(context)?.notEntered ?? 'Not Entered',
                tintColor: secondary,
              ),
              ProfileDetailChipWidget(
                iconName: (profileData['gender']?.toString().toLowerCase() == 'male') ? 'male' : 'female',
                label: AppLocalizations.of(context)?.gender ?? 'Gender',
                value: _displayValue(context, profileData['gender']),
                tintColor: (profileData['gender']?.toString().toLowerCase() == 'male') ? theme.colorScheme.primary : const Color(0xFFE91E63),
              ),
              ProfileDetailChipWidget(
                iconName: 'height',
                label: AppLocalizations.of(context)?.heightLabel ?? 'Height',
                value: _displayValue(context, profileData['height']),
                tintColor: tertiary,
              ),
              ProfileDetailChipWidget(
                iconName: 'family_restroom',
                label: AppLocalizations.of(context)?.surnameLabel ?? 'Surname',
                value: _displayValue(context, profileData['surname']),
                tintColor: primary,
              ),
              ProfileDetailChipWidget(
                iconName: 'favorite',
                label: AppLocalizations.of(context)?.maritalStatusLabel ?? 'Marital Status',
                value: _displayValue(context, profileData['maritalStatus']),
                tintColor: secondary,
              ),
              ProfileDetailChipWidget(
                iconName: 'calendar_month',
                label: AppLocalizations.of(context)?.dateOfBirthLabel ?? 'Date of Birth',
                value: _displayValue(context, profileData['dateOfBirth']),
                tintColor: tertiary,
              ),
              ProfileDetailChipWidget(
                iconName: 'access_time',
                label: AppLocalizations.of(context)?.birthTimeLabel ?? 'Birth Time',
                value: _displayValue(context, profileData['birthTime']),
                tintColor: primary,
              ),
              ProfileDetailChipWidget(
                iconName: 'place',
                label: AppLocalizations.of(context)?.birthPlaceLabel ?? 'Birth Place',
                value: _displayValue(context, profileData['birthPlace']),
                tintColor: secondary,
                fullWidth: true,
              ),
              ProfileDetailChipWidget(
                iconName: 'face',
                label: AppLocalizations.of(context)?.complexion ?? 'Complexion',
                value: _displayValue(context, profileData['complexion']),
                tintColor: tertiary,
              ),
              ProfileDetailChipWidget(
                iconName: 'bloodtype',
                label: AppLocalizations.of(context)?.bloodGroupLabel ?? 'Blood Group',
                value: _displayValue(context, profileData['bloodGroup']),
                tintColor: primary,
              ),
            ],
          ),
          
          if (profileData['expectation'] != null &&
              profileData['expectation'].toString().isNotEmpty) ...[
            SizedBox(height: 3.h),
            Text(AppLocalizations.of(context)?.partnerExpectations ?? 'Partner Expectations',
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
                profileData['expectation'].toString(),
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.9),
                  height: 1.5,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
          if (profileData['partnerExpectations'] != null &&
              profileData['partnerExpectations'].toString().isNotEmpty) ...[
            SizedBox(height: 3.h),
            Text(AppLocalizations.of(context)?.additionalPreferences ?? 'Additional Preferences',
              style: theme.textTheme.titleSmall?.copyWith(
                color: theme.colorScheme.secondary,
                fontWeight: FontWeight.w900,
              ),
            ),
            SizedBox(height: 1.h),
            Container(
              padding: EdgeInsets.all(4.w),
              width: double.infinity,
              decoration: BoxDecoration(
                color: secondary.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(16),
                border: Border(
                  left: BorderSide(
                    color: secondary.withValues(alpha: 0.6),
                    width: 4,
                  ),
                ),
              ),
              child: Text(
                profileData['partnerExpectations'].toString(),
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
}
