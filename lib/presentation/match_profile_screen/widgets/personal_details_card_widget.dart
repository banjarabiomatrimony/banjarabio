import 'package:flutter/material.dart';
import 'package:banjarabio/l10n/app_localizations.dart';
import 'package:sizer/sizer.dart';

import 'package:banjarabio/core/constants/app_typography.dart';
import 'package:banjarabio/theme/app_category_theme.dart';
import 'package:banjarabio/widgets/tactile/tactile_category_card.dart';
import 'package:banjarabio/widgets/tactile/tactile_detail_chip.dart';
import 'package:banjarabio/widgets/tactile/tactile_quote_card.dart';
import 'package:banjarabio/widgets/tactile/tactile_pressable.dart';
import 'package:banjarabio/presentation/match_profile_screen/widgets/staggered_fade_slide_widget.dart';
import 'package:banjarabio/theme/app_colors.dart';

/// 👤 Personal Details Card displaying core matrimonial biodata,
/// Banjara Gotra customs (Self Clan & Mamakul / Mosam), lifestyle habits, and preferences.
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

  void _showExogamyInfoDialog(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: isDark ? AppColors.canvasMidnight : Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.categoryFamilyDark.withValues(alpha: AppColors.opacity15),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.diversity_1_rounded, color: AppColors.categoryFamilyDark, size: 22),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                AppLocalizations.of(context)?.banjaraGotraCustoms ?? 'Banjara Gotra Customs (गोत्र व मोसळ)',
                style:                 AppTypography.displayStyle(
                  fontSize: AppTypography.headingSmall,
                ),
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              AppLocalizations.of(context)?.exogamyRuleDescription ?? 'In traditional Banjara (Gor) culture, marriages follow strict Clan Exogamy (गोत्र बहिर्विवाह):',
              style:               AppTypography.bodyStyle(
                fontWeight: AppTypography.semiBold,
                fontSize: AppTypography.bodySmall,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 12),
            _buildCustomBullet(
              AppLocalizations.of(context)?.selfClanTitle ?? '1. Self Clan (गोत्र):',
              AppLocalizations.of(context)?.selfClanRule ?? 'Bride & Groom must not share the same paternal Gotra (e.g. Rathod, Pawar, Chavan, Jadhav).',
              AppColors.categoryFamilyDark,
            ),
            const SizedBox(height: 8),
            _buildCustomBullet(
              AppLocalizations.of(context)?.mamakulTitle ?? '2. Mamakul / Mosam (मोसळ):',
              AppLocalizations.of(context)?.mamakulRule ?? 'Maternal Gotras are verified to ensure complete cultural harmony and lineage respect.',
              AppColors.categoryLocation,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text(AppLocalizations.of(context)?.ok ?? 'Understood', style:  AppTypography.bodyStyle(
   fontWeight: AppTypography.extraBold),
 ),
          ),
        ],
      ),
    );
  }

  Widget _buildCustomBullet(String title, String description, Color color) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          margin: const EdgeInsets.only(top: 4),
          width: 8,
          height: 8,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: RichText(
            text: TextSpan(
              style: TextStyle(fontSize: AppTypography.labelSmall, color: Colors.grey, height: 1.3),
              children: [
                TextSpan(
                  text: '$title ',
                  style: TextStyle(fontWeight: AppTypography.extraBold, color: color),
                ),
                TextSpan(text: description),
              ],
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final catTheme = AppCategoryTheme.of(context).personal;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final genderColor =
        FieldColorResolver.resolveGender(context, profileData['gender']);
    const emeraldTeal = AppColors.categoryLocation;

    final gotra = (profileData['gotra'] ?? profileData['clan'])?.toString();
    final maternalGotra = (profileData['maternalGotra'] ??
            profileData['mosamGotra'] ??
            profileData['mamakul'])
        ?.toString();
    final hasGotra = gotra != null && gotra.trim().isNotEmpty;
    final hasMaternalGotra =
        maternalGotra != null && maternalGotra.trim().isNotEmpty;

    return TactileCategoryCard(
      categoryType: CategoryType.personal,
      title: AppLocalizations.of(context)?.personalDetails ?? 'Personal & Cultural Details',
      icon: Icons.person_rounded,
      onEdit: onEdit,
      margin: margin,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 🌟 Banjara Gotra Exogamy Interactive Banner
          if (hasGotra || hasMaternalGotra) ...[
            StaggeredFadeSlideWidget(
              index: 0,
              child: TactilePressable(
                onTap: () => _showExogamyInfoDialog(context),
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 3.5.w, vertical: 1.2.h),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: isDark
                          ? [AppColors.deepIndigo, AppColors.canvasMidnight]
                          : [AppColors.violetBgSoft, AppColors.infoLight],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: AppColors.categoryFamilyDark.withValues(alpha: AppColors.opacity35),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.categoryFamilyDark.withValues(alpha: AppColors.opacity8),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppColors.categoryFamilyDark.withValues(alpha: AppColors.opacity15),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.diversity_1_rounded,
                          color: AppColors.categoryFamilyDark,
                          size: 20,
                        ),
                      ),
                      SizedBox(width: 3.w),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text(
                                  AppLocalizations.of(context)?.banjaraClanRoots ?? 'BANJARA CLAN & GOTRA',
                                  style: TextStyle(
                                    color: isDark ? AppColors.categoryFamily : AppColors.violetDeep,
                                    fontSize: AppTypography.labelSmall,
                                    fontWeight: AppTypography.black,
                                    letterSpacing: 0.6,
                                  ),
                                ),
                                const SizedBox(width: 6),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1.5),
                                  decoration: BoxDecoration(
                                    color: emeraldTeal.withValues(alpha: AppColors.opacity15),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Text(
                                    AppLocalizations.of(context)?.exogamyCompliant ?? 'EXOGAMY COMPLIANT',
                                    style:                                     AppTypography.bodyStyle(
                                      color: emeraldTeal,
                                      fontWeight: AppTypography.black,
                                      fontSize: AppTypography.labelSmall,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 2),
                            Text(
                              AppLocalizations.of(context)?.selfAndMamakulSubtitle(
                                    hasGotra ? gotra : (AppLocalizations.of(context)?.notEntered ?? 'Not Entered'),
                                    hasMaternalGotra ? maternalGotra : (AppLocalizations.of(context)?.notEntered ?? 'Not Entered'),
                                  ) ??
                                  'Self: ${hasGotra ? gotra : (AppLocalizations.of(context)?.notEntered ?? 'Not Entered')} • Mamakul: ${hasMaternalGotra ? maternalGotra : (AppLocalizations.of(context)?.notEntered ?? 'Not Entered')}',
                              style: TextStyle(
                                color: isDark ? Colors.white : AppColors.canvasMidnight,
                                fontSize: AppTypography.bodyMedium,
                                fontWeight: AppTypography.extraBold,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Icon(
                        Icons.info_outline_rounded,
                        size: 16,
                        color: isDark ? AppColors.violetSoft : AppColors.categoryFamilyDark,
                      ),
                    ],
                  ),
                ),
              ),
            ),
            SizedBox(height: 1.2.h),
          ],

          // Row 0: Full Name & Sub-Caste
          StaggeredFadeSlideWidget(
            index: 1,
            child: Row(
              children: [
                Expanded(
                  flex: 3,
                  child: TactileDetailChip(
                    iconName: 'badge',
                    label: AppLocalizations.of(context)?.fullName ?? 'Full Name',
                    value: _displayValue(context, profileData['name'] ?? profileData['fullName']),
                    tintColor: catTheme.primary,
                  ),
                ),
                SizedBox(width: 2.2.w),
                Expanded(
                  flex: 2,
                  child: TactileDetailChip(
                    iconName: 'diversity_2',
                    label: AppLocalizations.of(context)?.subCaste ?? 'Sub-Caste',
                    value: _displayValue(context, profileData['subCaste'] ?? (AppLocalizations.of(context)?.gorBanjara ?? 'Gor / Banjara')),
                    tintColor: catTheme.secondary,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 0.9.h),

          // Row 1: Age & Gender (Dynamic Gender Coloring)
          StaggeredFadeSlideWidget(
            index: 2,
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
            index: 3,
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

          // Row 3: Gotra (Self Clan) & Maternal Gotra (Mamakul / मोसळ)
          StaggeredFadeSlideWidget(
            index: 4,
            child: Row(
              children: [
                Expanded(
                  child: TactileDetailChip(
                    iconName: 'auto_awesome',
                    label: AppLocalizations.of(context)?.banjaraGotraClan ?? 'Banjara Gotra (Clan)',
                    value: hasGotra ? gotra : (AppLocalizations.of(context)?.notEntered ?? 'Not Entered'),
                    tintColor: catTheme.primary,
                    trailingBadge: hasGotra
                        ? Container(
                            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                            decoration: BoxDecoration(
                              color: catTheme.primary.withValues(alpha: AppColors.opacity12),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              AppLocalizations.of(context)?.exogamous ?? 'EXOGAMOUS',
                              style:                               AppTypography.buttonStyle(
                                color: catTheme.primary,
                                fontSize: AppTypography.labelSmall,
                              ),
                            ),
                          )
                        : null,
                  ),
                ),
                SizedBox(width: 2.2.w),
                Expanded(
                  child: TactileDetailChip(
                    iconName: 'diversity_1',
                    label: AppLocalizations.of(context)?.mamakulLabel ?? 'Mamakul (मोसळ)',
                    value: hasMaternalGotra
                        ? maternalGotra
                        : (AppLocalizations.of(context)?.notEntered ?? 'Not Entered'),
                    tintColor: emeraldTeal,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 0.9.h),

          // Row 4: Marital Status & Date of Birth
          StaggeredFadeSlideWidget(
            index: 5,
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
                    value: _displayValue(context, profileData['dateOfBirth'] ?? profileData['dob']),
                    tintColor: catTheme.tertiary,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 0.9.h),

          // Row 5: Diet / Eating Habits & Physical Status
          StaggeredFadeSlideWidget(
            index: 6,
            child: Row(
              children: [
                Expanded(
                  child: TactileDetailChip(
                    iconName: 'restaurant',
                    label: AppLocalizations.of(context)?.dietHabits ?? 'Diet / Food Habits',
                    value: _displayValue(context, profileData['diet'] ?? profileData['dietType']),
                    tintColor: emeraldTeal,
                  ),
                ),
                SizedBox(width: 2.2.w),
                Expanded(
                  child: TactileDetailChip(
                    iconName: 'accessibility_new',
                    label: AppLocalizations.of(context)?.physicalStatus ?? 'Physical Status',
                    value: profileData['isDisabled'] == true
                        ? (AppLocalizations.of(context)?.physicallyChallenged ?? 'Physically Challenged')
                        : _displayValue(context, profileData['physicalStatus'] ?? (AppLocalizations.of(context)?.normalFit ?? 'Normal / Fit')),
                    tintColor: catTheme.tertiary,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 0.9.h),

          // Row 6: Smoking Habits & Drinking Habits
          StaggeredFadeSlideWidget(
            index: 7,
            child: Row(
              children: [
                Expanded(
                  child: TactileDetailChip(
                    iconName: 'smoke_free',
                    label: AppLocalizations.of(context)?.smokingHabits ?? 'Smoking Habits',
                    value: _displayValue(context, profileData['smokingHabits'] ?? profileData['smoking']),
                    tintColor: catTheme.primary,
                  ),
                ),
                SizedBox(width: 2.2.w),
                Expanded(
                  child: TactileDetailChip(
                    iconName: 'local_bar',
                    label: AppLocalizations.of(context)?.drinkingHabits ?? 'Drinking Habits',
                    value: _displayValue(context, profileData['drinkingHabits'] ?? profileData['drinking']),
                    tintColor: catTheme.secondary,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 0.9.h),

          // Row 7: Relocation Preference & Profile Managed By
          StaggeredFadeSlideWidget(
            index: 8,
            child: Row(
              children: [
                Expanded(
                  child: TactileDetailChip(
                    iconName: 'flight_takeoff',
                    label: AppLocalizations.of(context)?.relocationPreference ?? 'Relocation Preference',
                    value: _displayValue(context, profileData['relocationPreference'] ?? profileData['relocate']),
                    tintColor: catTheme.secondary,
                  ),
                ),
                SizedBox(width: 2.2.w),
                Expanded(
                  child: TactileDetailChip(
                    iconName: 'contact_page',
                    label: AppLocalizations.of(context)?.profileManagedBy ?? 'Profile Managed By',
                    value: _displayValue(context, profileData['profileCreatedBy'] ?? profileData['contactRelation'] ?? (AppLocalizations.of(context)?.self ?? 'Self')),
                    tintColor: catTheme.primary,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 0.9.h),

          // Row 8: Complexion & Blood Group
          StaggeredFadeSlideWidget(
            index: 9,
            child: Row(
              children: [
                Expanded(
                  child: TactileDetailChip(
                    iconName: 'face',
                    label: AppLocalizations.of(context)?.complexion ??
                        'Complexion',
                    value: _displayValue(context, profileData['complexion']),
                    tintColor: catTheme.tertiary,
                  ),
                ),
                SizedBox(width: 2.2.w),
                Expanded(
                  child: TactileDetailChip(
                    iconName: 'bloodtype',
                    label: AppLocalizations.of(context)?.bloodGroupLabel ??
                        'Blood Group',
                    value: _displayValue(context, profileData['bloodGroup']),
                    tintColor: FieldColorResolver.resolveBloodGroup(context),
                  ),
                ),
              ],
            ),
          ),

          // About Self Quote Card
          if (profileData['aboutSelf'] != null &&
              profileData['aboutSelf'].toString().isNotEmpty) ...[
            SizedBox(height: 1.8.h),
            StaggeredFadeSlideWidget(
              index: 10,
              child: TactileQuoteCard(
                title: AppLocalizations.of(context)?.aboutSelf ?? 'About Self',
                content: profileData['aboutSelf'].toString(),
                color: catTheme.primary,
                icon: Icons.person_outline_rounded,
              ),
            ),
          ],

          // Partner Expectations Quote Card
          if (profileData['expectation'] != null &&
              profileData['expectation'].toString().isNotEmpty) ...[
            SizedBox(height: 1.8.h),
            StaggeredFadeSlideWidget(
              index: 11,
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
              index: 12,
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
