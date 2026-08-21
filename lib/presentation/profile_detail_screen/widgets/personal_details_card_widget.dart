import 'package:flutter/material.dart';
import 'package:banjarabio/l10n/app_localizations.dart';
import 'package:sizer/sizer.dart';

import 'package:banjarabio/theme/app_category_theme.dart';
import 'package:banjarabio/widgets/tactile/tactile_category_card.dart';
import 'package:banjarabio/widgets/tactile/tactile_detail_chip.dart';
import 'package:banjarabio/widgets/tactile/tactile_quote_card.dart';
import 'package:banjarabio/presentation/profile_detail_screen/widgets/staggered_fade_slide_widget.dart';

/// 👤 Personal Details Card displaying core matrimonial biodata.
/// Consumes centralized AppCategoryTheme and shared Tactile components.
class PersonalDetailsCardWidget extends StatelessWidget {
  final Map<String, dynamic> profileData;
  final EdgeInsets? margin;
  final VoidCallback? onEdit;

  const PersonalDetailsCardWidget({
    super.key,
    required this.profileData,
    this.margin,
    this.onEdit,
  });

  /// Returns AppLocalizations.of(context).notEntered for null or empty values, otherwise the value string.
  String _displayValue(BuildContext context, dynamic value) {
    if (value == null) {
      return AppLocalizations.of(context)?.notEntered ?? 'Not Entered';
    }
    final str = value.toString().trim();
    return str.isEmpty
        ? AppLocalizations.of(context)?.notEntered ?? 'Not Entered'
        : str;
  }

  @override
  Widget build(BuildContext context) {
    final catTheme = AppCategoryTheme.of(context).personal;
    final genderColor =
        FieldColorResolver.resolveGender(context, profileData['gender']);

    return TactileCategoryCard(
      categoryType: CategoryType.personal,
      title: AppLocalizations.of(context)?.personalDetails ?? 'Personal Details',
      icon: Icons.person_rounded,
      onEdit: onEdit,
      margin: margin,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Row 0: Full Name (Full Width)
          StaggeredFadeSlideWidget(
            index: 0,
            child: TactileDetailChip(
              iconName: 'badge',
              label: AppLocalizations.of(context)?.fullName ?? 'Full Name',
              value: _displayValue(context, profileData['name']),
              tintColor: catTheme.primary,
              fullWidth: true,
            ),
          ),
          SizedBox(height: 0.9.h),

          // Row 1: Age & Gender (Dynamic Gender Coloring)
          StaggeredFadeSlideWidget(
            index: 1,
            child: Row(
              children: [
                Expanded(
                  child: TactileDetailChip(
                    iconName: 'cake',
                    label: AppLocalizations.of(context)?.ageLabel ?? 'Age',
                    value: profileData['age'] != null
                        ? AppLocalizations.of(context)
                                ?.yearsOld(profileData['age'].toString()) ??
                            '${profileData['age']} Years'
                        : AppLocalizations.of(context)?.notEntered ??
                            'Not Entered',
                    tintColor: catTheme.secondary,
                  ),
                ),
                SizedBox(width: 2.2.w),
                Expanded(
                  child: TactileDetailChip(
                    iconName: (profileData['gender']
                                ?.toString()
                                .toLowerCase() ==
                            'female')
                        ? 'female'
                        : 'male',
                    label: AppLocalizations.of(context)?.gender ?? 'Gender',
                    value: _displayValue(context, profileData['gender']),
                    tintColor: genderColor,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 0.9.h),

          // Row 2: Height & Surname
          StaggeredFadeSlideWidget(
            index: 2,
            child: Row(
              children: [
                Expanded(
                  child: TactileDetailChip(
                    iconName: 'height',
                    label:
                        AppLocalizations.of(context)?.heightLabel ?? 'Height',
                    value: _displayValue(context, profileData['height']),
                    tintColor: catTheme.tertiary,
                  ),
                ),
                SizedBox(width: 2.2.w),
                Expanded(
                  child: TactileDetailChip(
                    iconName: 'family_restroom',
                    label: AppLocalizations.of(context)?.surnameLabel ??
                        'Surname',
                    value: _displayValue(context, profileData['surname']),
                    tintColor: catTheme.primary,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 0.9.h),

          // Row 3: Marital Status & Date of Birth
          StaggeredFadeSlideWidget(
            index: 3,
            child: Row(
              children: [
                Expanded(
                  child: TactileDetailChip(
                    iconName: 'favorite',
                    label: AppLocalizations.of(context)?.maritalStatusLabel ??
                        'Marital Status',
                    value:
                        _displayValue(context, profileData['maritalStatus']),
                    tintColor: catTheme.secondary,
                  ),
                ),
                SizedBox(width: 2.2.w),
                Expanded(
                  child: TactileDetailChip(
                    iconName: 'calendar_month',
                    label: AppLocalizations.of(context)?.dateOfBirthLabel ??
                        'Date of Birth',
                    value: _displayValue(context, profileData['dateOfBirth']),
                    tintColor: catTheme.tertiary,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 0.9.h),

          // Row 4: Birth Time & Complexion
          StaggeredFadeSlideWidget(
            index: 4,
            child: Row(
              children: [
                Expanded(
                  child: TactileDetailChip(
                    iconName: 'access_time',
                    label: AppLocalizations.of(context)?.birthTimeLabel ??
                        'Birth Time',
                    value: _displayValue(context, profileData['birthTime']),
                    tintColor: AppCategoryTheme.of(context).allDetails.primary,
                  ),
                ),
                SizedBox(width: 2.2.w),
                Expanded(
                  child: TactileDetailChip(
                    iconName: 'face',
                    label: AppLocalizations.of(context)?.complexion ??
                        'Complexion',
                    value: _displayValue(context, profileData['complexion']),
                    tintColor: catTheme.tertiary,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 0.9.h),

          // Row 5: Birth Place (Full Width)
          StaggeredFadeSlideWidget(
            index: 5,
            child: TactileDetailChip(
              iconName: 'place',
              label: AppLocalizations.of(context)?.birthPlaceLabel ??
                  'Birth Place',
              value: _displayValue(context, profileData['birthPlace']),
              tintColor: catTheme.secondary,
              fullWidth: true,
            ),
          ),
          SizedBox(height: 0.9.h),

          // Row 6: Blood Group & Gotra
          StaggeredFadeSlideWidget(
            index: 6,
            child: Row(
              children: [
                Expanded(
                  child: TactileDetailChip(
                    iconName: 'bloodtype',
                    label: AppLocalizations.of(context)?.bloodGroupLabel ??
                        'Blood Group',
                    value: _displayValue(context, profileData['bloodGroup']),
                    tintColor: FieldColorResolver.resolveBloodGroup(context),
                  ),
                ),
                SizedBox(width: 2.2.w),
                Expanded(
                  child: TactileDetailChip(
                    iconName: 'auto_awesome',
                    label: AppLocalizations.of(context)?.gotra ?? 'Gotra',
                    value: _displayValue(context, profileData['gotra']),
                    tintColor: catTheme.primary,
                  ),
                ),
              ],
            ),
          ),

          // Partner Expectations Quote Card
          if (profileData['expectation'] != null &&
              profileData['expectation'].toString().isNotEmpty) ...[
            SizedBox(height: 1.8.h),
            StaggeredFadeSlideWidget(
              index: 7,
              child: TactileQuoteCard(
                title: AppLocalizations.of(context)?.partnerExpectations ??
                    'Partner Expectations',
                content: profileData['expectation'].toString(),
                color: catTheme.primary,
                icon: Icons.format_quote_rounded,
              ),
            ),
          ],
          if (profileData['partnerExpectations'] != null &&
              profileData['partnerExpectations'].toString().isNotEmpty) ...[
            SizedBox(height: 1.5.h),
            StaggeredFadeSlideWidget(
              index: 8,
              child: TactileQuoteCard(
                title: AppLocalizations.of(context)?.additionalPreferences ??
                    'Additional Preferences',
                content: profileData['partnerExpectations'].toString(),
                color: catTheme.secondary,
                icon: Icons.favorite_border_rounded,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
