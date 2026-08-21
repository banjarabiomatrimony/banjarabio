import 'package:flutter/material.dart';
import 'package:banjarabio/l10n/app_localizations.dart';
import 'package:sizer/sizer.dart';

import 'package:banjarabio/core/constants/app_typography.dart';
import 'package:banjarabio/theme/app_category_theme.dart';
import 'package:banjarabio/widgets/tactile/tactile_category_card.dart';
import 'package:banjarabio/widgets/tactile/tactile_detail_chip.dart';
import 'package:banjarabio/widgets/tactile/tactile_quote_card.dart';
import 'package:banjarabio/presentation/match_profile_screen/widgets/staggered_fade_slide_widget.dart';
import 'package:banjarabio/theme/app_colors.dart';

/// 👨‍👩‍👧 Elevated Family Background Card displaying detailed family heritage,
/// parents, siblings, Maternal Gotra (Mosam / Mamakul), Native Tanda, and family values.
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    const emeraldTeal = AppColors.categoryLocation;

    final maternalGotra =
        (profileData['maternalGotra'] ??
                profileData['mosamGotra'] ??
                profileData['mamakul'])
            ?.toString();
    final hasMaternalGotra =
        maternalGotra != null && maternalGotra.trim().isNotEmpty;

    final nativeTanda =
        profileData['tanda'] ??
        profileData['nativeTanda'] ??
        profileData['nativePlace'] ??
        profileData['village'];

    final isFamilyVetted =
        profileData['isFamilyVetted'] == true ||
        profileData['isVetted'] == true;

    return TactileCategoryCard(
      categoryType: CategoryType.family,
      title:
          AppLocalizations.of(context)?.familyBackground ??
          'Family Background & Roots',
      icon: Icons.family_restroom_rounded,
      onEdit: onEdit,
      margin: margin,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 🌟 Lineage & Roots Header Box (Gotra + Mamakul + Tanda)
          StaggeredFadeSlideWidget(
            index: 0,
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 3.5.w, vertical: 1.2.h),
              decoration: BoxDecoration(
                color: isDark
                    ? AppColors.slate900.withValues(alpha: AppColors.opacity70)
                    : AppColors.slate100,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isDark
                      ? Colors.white.withValues(alpha: AppColors.opacity10)
                      : Colors.black.withValues(alpha: 0.06),
                ),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: emeraldTeal.withValues(alpha: AppColors.opacity15),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.diversity_1_rounded,
                      color: emeraldTeal,
                      size: 18,
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
                              AppLocalizations.of(context)?.banjaraClanRoots ??
                                  'BANJARA CLAN ROOTS',
                              style: TextStyle(
                                fontFamily: AppTypography.bodyFontFamily,
                                color: emeraldTeal,
                                fontWeight: AppTypography.black,
                                fontSize: AppTypography.labelSmall,
                                letterSpacing: 0.5,
                              ),
                            ),
                            if (isFamilyVetted) ...[
                              const Spacer(),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 6,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: const Color(
                                    0xFFF59E0B,
                                  ).withValues(alpha: AppColors.opacity15),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  AppLocalizations.of(context)?.vettedFamily ??
                                      'VETTED FAMILY',
                                  style: TextStyle(
                                    color: AppColors.categoryAstro,
                                    fontSize: AppTypography.labelSmall,
                                    fontWeight: AppTypography.black,
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                        Text(
                          AppLocalizations.of(context)?.mamakulAndTandaSubtitle(
                                hasMaternalGotra
                                    ? maternalGotra
                                    : (AppLocalizations.of(
                                            context,
                                          )?.notEntered ??
                                          'Not Entered'),
                                _displayValue(context, nativeTanda),
                              ) ??
                              'Mamakul: ${hasMaternalGotra ? maternalGotra : (AppLocalizations.of(context)?.notEntered ?? 'Not Entered')} • Tanda: ${_displayValue(context, nativeTanda)}',
                          style: TextStyle(
                            fontFamily: AppTypography.bodyFontFamily,
                            fontWeight: AppTypography.extraBold,
                            color: isDark
                                ? Colors.white
                                : AppColors.slate800,
                            fontSize: AppTypography.bodyMedium,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(height: 1.h),

          // Row 1: Father Name & Father Occupation
          StaggeredFadeSlideWidget(
            index: 1,
            child: Row(
              children: [
                Expanded(
                  child: TactileDetailChip(
                    iconName: 'person',
                    label:
                        AppLocalizations.of(context)?.fatherName ??
                        'Father\'s Name',
                    value: _displayValue(context, profileData['fatherName']),
                    tintColor: catTheme.primary,
                  ),
                ),
                SizedBox(width: 2.2.w),
                Expanded(
                  child: TactileDetailChip(
                    iconName: 'work_outline',
                    label:
                        AppLocalizations.of(context)?.fatherOccupation ??
                        'Father\'s Occupation',
                    value: _displayValue(
                      context,
                      profileData['fatherOccupation'],
                    ),
                    tintColor: catTheme.secondary,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 0.9.h),

          // Row 2: Mother Name & Mother Occupation
          StaggeredFadeSlideWidget(
            index: 2,
            child: Row(
              children: [
                Expanded(
                  child: TactileDetailChip(
                    iconName: 'person_outline',
                    label:
                        AppLocalizations.of(context)?.motherName ??
                        'Mother\'s Name',
                    value: _displayValue(context, profileData['motherName']),
                    tintColor: catTheme.secondary,
                  ),
                ),
                SizedBox(width: 2.2.w),
                Expanded(
                  child: TactileDetailChip(
                    iconName: 'home_work',
                    label:
                        AppLocalizations.of(context)?.motherOccupation ??
                        'Mother\'s Occupation',
                    value: _displayValue(
                      context,
                      profileData['motherOccupation'],
                    ),
                    tintColor: catTheme.tertiary,
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
                    label:
                        AppLocalizations.of(context)?.brotherCount ??
                        'Brothers',
                    value: _displayValue(
                      context,
                      profileData['brothers'] ??
                          profileData['brotherCount'] ??
                          profileData['brother_count'],
                    ),
                    tintColor: catTheme.tertiary,
                  ),
                ),
                SizedBox(width: 2.2.w),
                Expanded(
                  child: TactileDetailChip(
                    iconName: 'groups_2',
                    label:
                        AppLocalizations.of(context)?.sisterCount ?? 'Sisters',
                    value: _displayValue(
                      context,
                      profileData['sisters'] ??
                          profileData['sisterCount'] ??
                          profileData['sister_count'],
                    ),
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
                    label:
                        AppLocalizations.of(context)?.familyType ??
                        'Family Type',
                    value: _displayValue(
                      context,
                      profileData['familyType'] ?? profileData['family_type'],
                    ),
                    tintColor: catTheme.primary,
                  ),
                ),
                SizedBox(width: 2.2.w),
                Expanded(
                  child: TactileDetailChip(
                    iconName: 'psychology',
                    label:
                        AppLocalizations.of(context)?.familyValues ??
                        'Family Values',
                    value: _displayValue(
                      context,
                      profileData['familyValues'] ??
                          profileData['family_values'],
                    ),
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
                title:
                    AppLocalizations.of(context)?.aboutFamily ?? 'About Family',
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
