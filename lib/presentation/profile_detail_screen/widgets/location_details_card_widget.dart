import 'package:flutter/material.dart';
import 'package:banjarabio/l10n/app_localizations.dart';
import 'package:sizer/sizer.dart';

import 'package:banjarabio/core/app_export.dart';
import 'package:banjarabio/widgets/custom_icon_widget.dart';
import 'package:banjarabio/presentation/profile_detail_screen/widgets/profile_detail_chip_widget.dart';
import 'package:banjarabio/core/constants/app_typography.dart';

/// Location details card displaying current and permanent residence information
/// Important for regional and distance preferences in matrimonial matching
class LocationDetailsCardWidget extends StatelessWidget {
  final Map<String, dynamic> profileData;
  final EdgeInsets? margin;

  const LocationDetailsCardWidget({
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
                  iconName: 'location_on',
                  color: primary,
                  size: 22,
                ),
              ),
              SizedBox(width: 2.w),
              Expanded(
                child: Text(AppLocalizations.of(context)?.locationDetails ?? 'Location Details',
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: theme.colorScheme.onSurface,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 0.4,
                    fontSize: AppTypography.headingSmall,
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
                iconName: 'home',
                label: AppLocalizations.of(context)?.currentResidence ?? 'Current Residence',
                value: _displayValue(context, profileData['location'] ?? profileData['currentLocation']),
                tintColor: primary,
                fullWidth: true,
              ),
              ProfileDetailChipWidget(
                iconName: 'place',
                label: AppLocalizations.of(context)?.nativePlace ?? 'Native Place',
                value: _displayValue(context, profileData['nativePlace']),
                tintColor: secondary,
                fullWidth: true,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
