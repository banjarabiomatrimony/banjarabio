import 'package:flutter/material.dart';
import 'package:banjarabio/l10n/app_localizations.dart';
import 'package:sizer/sizer.dart';

import 'package:banjarabio/theme/app_category_theme.dart';
import 'package:banjarabio/widgets/tactile/tactile_category_card.dart';
import 'package:banjarabio/widgets/tactile/tactile_detail_chip.dart';
import 'package:banjarabio/widgets/tactile/tactile_quote_card.dart';
import 'package:banjarabio/presentation/profile_detail_screen/widgets/staggered_fade_slide_widget.dart';
import 'package:banjarabio/theme/app_colors.dart';

/// 👨👩👧 Family Background Card displaying detailed family information.
/// Consumes centralized AppCategoryTheme and shared Tactile components.
class FamilyBackgroundCardWidget extends StatelessWidget {
  final Map<String, dynamic> profileData;
  final EdgeInsets? margin;
  final VoidCallback? onEdit;

  const FamilyBackgroundCardWidget({
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
    final catTheme = AppCategoryTheme.of(context).family;
    const emeraldTeal = AppColors.categoryLocation;

    return TactileCategoryCard(
      categoryType: CategoryType.family,
      title: AppLocalizations.of(context)?.familyBackground ??
          'Family Background',
      icon: Icons.family_restroom_rounded,
      onEdit: onEdit,
      margin: margin,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Row 0: Father Name & Father Occupation
          StaggeredFadeSlideWidget(
            index: 0,
            child: Row(
              children: [
                Expanded(
                  child: TactileDetailChip(
                    iconName: 'person',
                    label: AppLocalizations.of(context)?.fatherName ??
                        'Father\'s Name',
                    value: _displayValue(context, profileData['fatherName']),
                    tintColor: catTheme.primary,
                  ),
                ),
                SizedBox(width: 2.2.w),
                Expanded(
                  child: TactileDetailChip(
                    iconName: 'work_outline',
                    label: AppLocalizations.of(context)?.fatherOccupation ??
                        'Father\'s Occupation',
                    value:
                        _displayValue(context, profileData['fatherOccupation']),
                    tintColor: catTheme.secondary,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 0.9.h),

          // Row 1: Mother Name & Mother Occupation
          StaggeredFadeSlideWidget(
            index: 1,
            child: Row(
              children: [
                Expanded(
                  child: TactileDetailChip(
                    iconName: 'person_outline',
                    label: AppLocalizations.of(context)?.motherName ??
                        'Mother\'s Name',
                    value: _displayValue(context, profileData['motherName']),
                    tintColor: catTheme.secondary,
                  ),
                ),
                SizedBox(width: 2.2.w),
                Expanded(
                  child: TactileDetailChip(
                    iconName: 'home_work',
                    label: AppLocalizations.of(context)?.motherOccupation ??
                        'Mother\'s Occupation',
                    value:
                        _displayValue(context, profileData['motherOccupation']),
                    tintColor: catTheme.tertiary,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 0.9.h),

          // Row 2: Gotra & Maternal Gotra (Mosam)
          StaggeredFadeSlideWidget(
            index: 2,
            child: Row(
              children: [
                Expanded(
                  child: TactileDetailChip(
                    iconName: 'diversity_3',
                    label: AppLocalizations.of(context)?.gotra ?? 'Gotra',
                    value: _displayValue(context, profileData['gotra']),
                    tintColor: catTheme.primary,
                  ),
                ),
                SizedBox(width: 2.2.w),
                Expanded(
                  child: TactileDetailChip(
                    iconName: 'diversity_1',
                    label: 'Maternal Gotra (Mosam)',
                    value: _displayValue(
                        context,
                        profileData['maternalGotra'] ??
                            profileData['mosamGotra']),
                    tintColor: emeraldTeal,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 0.9.h),

          // Row 3: Brothers & Sisters
          StaggeredFadeSlideWidget(
            index: 3,
            child: Row(
              children: [
                Expanded(
                  child: TactileDetailChip(
                    iconName: 'groups',
                    label: 'Brothers',
                    value: _displayValue(context,
                        profileData['brothers'] ?? profileData['brotherCount']),
                    tintColor: catTheme.tertiary,
                  ),
                ),
                SizedBox(width: 2.2.w),
                Expanded(
                  child: TactileDetailChip(
                    iconName: 'groups_2',
                    label: 'Sisters',
                    value: _displayValue(context,
                        profileData['sisters'] ?? profileData['sisterCount']),
                    tintColor: catTheme.secondary,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 0.9.h),

          // Row 4: Family Type & Family Values
          StaggeredFadeSlideWidget(
            index: 4,
            child: Row(
              children: [
                Expanded(
                  child: TactileDetailChip(
                    iconName: 'apartment',
                    label: 'Family Type',
                    value: _displayValue(context, profileData['familyType']),
                    tintColor: catTheme.primary,
                  ),
                ),
                SizedBox(width: 2.2.w),
                Expanded(
                  child: TactileDetailChip(
                    iconName: 'psychology',
                    label: 'Family Values',
                    value: _displayValue(context, profileData['familyValues']),
                    tintColor: emeraldTeal,
                  ),
                ),
              ],
            ),
          ),

          // About Family / Bio Container
          if (profileData['aboutFamily'] != null &&
              profileData['aboutFamily'].toString().isNotEmpty) ...[
            SizedBox(height: 1.8.h),
            StaggeredFadeSlideWidget(
              index: 5,
              child: TactileQuoteCard(
                title: AppLocalizations.of(context)?.aboutFamily ?? 'About Family',
                content: profileData['aboutFamily'].toString(),
                color: catTheme.primary,
                icon: Icons.family_restroom_rounded,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
