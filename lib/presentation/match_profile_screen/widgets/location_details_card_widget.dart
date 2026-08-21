import 'package:flutter/material.dart';
import 'package:banjarabio/l10n/app_localizations.dart';
import 'package:sizer/sizer.dart';

import 'package:banjarabio/core/constants/app_typography.dart';
import 'package:banjarabio/theme/app_category_theme.dart';
import 'package:banjarabio/widgets/tactile/tactile_category_card.dart';
import 'package:banjarabio/widgets/tactile/tactile_detail_chip.dart';
import 'package:banjarabio/presentation/match_profile_screen/widgets/staggered_fade_slide_widget.dart';
import 'package:banjarabio/theme/app_colors.dart';

/// 📍 Location Details Card displaying current residence and ancestral roots.
/// Shows current location, native village/tanda, and relocation preferences.
class LocationDetailsCardWidget extends StatelessWidget {
  final Map<String, dynamic> profileData;
  final EdgeInsets? margin;
  final VoidCallback? onEdit;

  const LocationDetailsCardWidget({
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
    final catTheme = AppCategoryTheme.of(context).location;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final relocation =
        profileData['relocationPreference'] ??
        profileData['relocation_preference'] ??
        profileData['relocation'] ??
        (AppLocalizations.of(context)?.openToRelocate ?? 'Open to Relocate');

    final nativePlace =
        profileData['nativePlace'] ??
        profileData['nativeTanda'] ??
        profileData['tanda'] ??
        profileData['village'];

    return TactileCategoryCard(
      categoryType: CategoryType.location,
      title:
          AppLocalizations.of(context)?.locationDetails ?? 'Location & Roots',
      icon: Icons.location_on_rounded,
      onEdit: onEdit,
      margin: margin,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 📍 Top Location Overview Box
          StaggeredFadeSlideWidget(
            index: 0,
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 3.5.w, vertical: 1.2.h),
              decoration: BoxDecoration(
                color: isDark
                    ? AppColors.slate900.withValues(alpha: AppColors.opacity70)
                    : AppColors.infoLight,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isDark
                      ? Colors.white.withValues(alpha: AppColors.opacity10)
                      : AppColors.categoryCareer.withValues(alpha: AppColors.opacity20),
                ),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.categoryCareer.withValues(alpha: AppColors.opacity15),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.map_rounded,
                      color: AppColors.categoryCareer,
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
                              AppLocalizations.of(
                                    context,
                                  )?.currentNativeRegion ??
                                  'CURRENT & NATIVE REGION',
                              style: TextStyle(
                                fontFamily: AppTypography.bodyFontFamily,
                                color: AppColors.categoryCareer,
                                fontWeight: AppTypography.black,
                                fontSize: AppTypography.labelSmall,
                                letterSpacing: 0.5,
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(
                                  0xFF10B981,
                                ).withValues(alpha: AppColors.opacity15),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                _displayValue(context, relocation),
                                style: TextStyle(
                                  color: AppColors.categoryLocation,
                                  fontSize: AppTypography.labelSmall,
                                  fontWeight: AppTypography.black,
                                ),
                              ),
                            ),
                          ],
                        ),
                        Text(
                          '${_displayValue(context, profileData['city'])}, ${_displayValue(context, profileData['state'])}',
                          style: TextStyle(
                            fontFamily: AppTypography.bodyFontFamily,
                            fontWeight: AppTypography.extraBold,
                            fontSize: AppTypography.bodyMedium,
                            color: isDark
                                ? Colors.white
                                : AppColors.slate800,
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

          // Row 1: Current City & Current State
          StaggeredFadeSlideWidget(
            index: 1,
            child: Row(
              children: [
                Expanded(
                  child: TactileDetailChip(
                    iconName: 'location_city',
                    label:
                        AppLocalizations.of(context)?.currentCity ??
                        'Current City',
                    value: _displayValue(context, profileData['city']),
                    tintColor: catTheme.primary,
                  ),
                ),
                SizedBox(width: 2.2.w),
                Expanded(
                  child: TactileDetailChip(
                    iconName: 'map',
                    label:
                        AppLocalizations.of(context)?.currentState ??
                        'Current State',
                    value: _displayValue(context, profileData['state']),
                    tintColor: catTheme.secondary,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 0.9.h),

          // Row 2: Country & Pincode
          StaggeredFadeSlideWidget(
            index: 2,
            child: Row(
              children: [
                Expanded(
                  child: TactileDetailChip(
                    iconName: 'public',
                    label:
                        AppLocalizations.of(context)?.countryLabel ?? 'Country',
                    value: _displayValue(
                      context,
                      profileData['country'] ??
                          (AppLocalizations.of(context)?.india ?? 'India'),
                    ),
                    tintColor: catTheme.tertiary,
                  ),
                ),
                SizedBox(width: 2.2.w),
                Expanded(
                  child: TactileDetailChip(
                    iconName: 'pin_drop',
                    label:
                        AppLocalizations.of(context)?.pinCodeLabel ??
                        'Pin Code',
                    value: _displayValue(context, profileData['pincode']),
                    tintColor: catTheme.primary,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 0.9.h),

          // Row 3: Native Place & Native District / Tanda
          StaggeredFadeSlideWidget(
            index: 3,
            child: Row(
              children: [
                Expanded(
                  child: TactileDetailChip(
                    iconName: 'holiday_village',
                    label:
                        AppLocalizations.of(context)?.nativePlace ??
                        'Native Tanda / Place',
                    value: _displayValue(context, nativePlace),
                    tintColor: catTheme.secondary,
                  ),
                ),
                SizedBox(width: 2.2.w),
                Expanded(
                  child: TactileDetailChip(
                    iconName: 'terrain',
                    label:
                        AppLocalizations.of(context)?.nativeDistrict ??
                        'Native District',
                    value: _displayValue(
                      context,
                      profileData['nativeDistrict'] ??
                          profileData['district'] ??
                          profileData['nativeTaluka'],
                    ),
                    tintColor: catTheme.tertiary,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 0.9.h),

          // Row 4: Complete Residential Address (Full Width)
          if (profileData['address'] != null ||
              profileData['residentialAddress'] != null) ...[
            StaggeredFadeSlideWidget(
              index: 4,
              child: TactileDetailChip(
                iconName: 'home',
                label:
                    AppLocalizations.of(context)?.fullAddress ?? 'Full Address',
                value: _displayValue(
                  context,
                  profileData['address'] ?? profileData['residentialAddress'],
                ),
                tintColor: catTheme.primary,
                fullWidth: true,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
