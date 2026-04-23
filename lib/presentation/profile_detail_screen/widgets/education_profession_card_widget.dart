import 'package:flutter/material.dart';
import 'package:banjarabio/l10n/app_localizations.dart';
import 'package:sizer/sizer.dart';

import 'package:banjarabio/core/app_export.dart';
import 'package:banjarabio/widgets/custom_icon_widget.dart';
import 'package:banjarabio/presentation/profile_detail_screen/widgets/profile_detail_chip_widget.dart';

/// Education and profession card displaying academic and career information
/// Emphasizes professional background for family evaluation
class EducationProfessionCardWidget extends StatelessWidget {
  final Map<String, dynamic> profileData;
  final EdgeInsets? margin;

  const EducationProfessionCardWidget({
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
                  iconName: 'work',
                  color: tertiary,
                  size: 22,
                ),
              ),
              SizedBox(width: 2.w),
              Expanded(
                child: Text(AppLocalizations.of(context)?.educationProfession ?? 'Education & Profession',
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
                iconName: 'school',
                label: AppLocalizations.of(context)?.educationLabel ?? 'Education',
                value: _displayValue(context, profileData['education']),
                tintColor: primary,
                fullWidth: true,
              ),
              ProfileDetailChipWidget(
                iconName: 'work',
                label: AppLocalizations.of(context)?.occupationLabel ?? 'Occupation',
                value: _displayValue(context, profileData['job'] ?? profileData['occupation']),
                tintColor: secondary,
                fullWidth: true,
              ),
              ProfileDetailChipWidget(
                iconName: 'menu_book',
                label: AppLocalizations.of(context)?.educationDetails ?? 'Education Details',
                value: _displayValue(context, profileData['educationDetails']),
                tintColor: tertiary,
                fullWidth: true,
              ),
              ProfileDetailChipWidget(
                iconName: 'business_center',
                label: AppLocalizations.of(context)?.jobDetails ?? 'Job Details',
                value: _displayValue(context, profileData['jobDetails']),
                tintColor: primary,
                fullWidth: true,
              ),
              ProfileDetailChipWidget(
                iconName: 'location_city',
                label: AppLocalizations.of(context)?.company ?? 'Company',
                value: _displayValue(context, profileData['company']),
                tintColor: secondary,
              ),
              ProfileDetailChipWidget(
                iconName: 'attach_money',
                label: AppLocalizations.of(context)?.annualIncomeLabel ?? 'Annual Income',
                value: _displayValue(context, profileData['annualIncome']),
                tintColor: tertiary,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
