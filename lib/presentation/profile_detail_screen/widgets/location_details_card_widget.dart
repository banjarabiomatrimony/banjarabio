import 'package:flutter/material.dart';
import 'package:banjarabio/l10n/app_localizations.dart';
import 'package:sizer/sizer.dart';

import 'package:banjarabio/theme/app_category_theme.dart';
import 'package:banjarabio/widgets/tactile/tactile_category_card.dart';
import 'package:banjarabio/widgets/tactile/tactile_detail_chip.dart';
import 'package:banjarabio/presentation/profile_detail_screen/widgets/staggered_fade_slide_widget.dart';

/// 📍 Location Details Card displaying current and permanent residence information.
/// Consumes centralized AppCategoryTheme and shared Tactile components.
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

    return TactileCategoryCard(
      categoryType: CategoryType.location,
      title: AppLocalizations.of(context)?.locationDetails ?? 'Location Details',
      icon: Icons.location_on_rounded,
      onEdit: onEdit,
      margin: margin,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Row 0: Current City & Current State
          StaggeredFadeSlideWidget(
            index: 0,
            child: Row(
              children: [
                Expanded(
                  child: TactileDetailChip(
                    iconName: 'location_city',
                    label: 'Current City',
                    value: _displayValue(context, profileData['city']),
                    tintColor: catTheme.primary,
                  ),
                ),
                SizedBox(width: 2.2.w),
                Expanded(
                  child: TactileDetailChip(
                    iconName: 'map',
                    label: 'Current State',
                    value: _displayValue(context, profileData['state']),
                    tintColor: catTheme.secondary,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 0.9.h),

          // Row 1: Country & Pincode
          StaggeredFadeSlideWidget(
            index: 1,
            child: Row(
              children: [
                Expanded(
                  child: TactileDetailChip(
                    iconName: 'public',
                    label: 'Country',
                    value: _displayValue(context, profileData['country']),
                    tintColor: catTheme.tertiary,
                  ),
                ),
                SizedBox(width: 2.2.w),
                Expanded(
                  child: TactileDetailChip(
                    iconName: 'pin_drop',
                    label: 'Pin Code',
                    value: _displayValue(context, profileData['pincode']),
                    tintColor: catTheme.primary,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 0.9.h),

          // Row 2: Native Place & Native District / Tanda
          StaggeredFadeSlideWidget(
            index: 2,
            child: Row(
              children: [
                Expanded(
                  child: TactileDetailChip(
                    iconName: 'holiday_village',
                    label: AppLocalizations.of(context)?.nativePlace ??
                        'Native Place',
                    value: _displayValue(context, profileData['nativePlace']),
                    tintColor: catTheme.secondary,
                  ),
                ),
                SizedBox(width: 2.2.w),
                Expanded(
                  child: TactileDetailChip(
                    iconName: 'terrain',
                    label: 'Native District',
                    value: _displayValue(
                        context,
                        profileData['nativeDistrict'] ??
                            profileData['nativeTaluka']),
                    tintColor: catTheme.tertiary,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 0.9.h),

          // Row 3: Complete Residential Address (Full Width)
          StaggeredFadeSlideWidget(
            index: 3,
            child: TactileDetailChip(
              iconName: 'home',
              label: 'Full Address',
              value: _displayValue(
                  context,
                  profileData['address'] ??
                      profileData['residentialAddress']),
              tintColor: catTheme.primary,
              fullWidth: true,
            ),
          ),
        ],
      ),
    );
  }
}
