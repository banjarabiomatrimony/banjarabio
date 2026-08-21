import 'package:banjarabio/core/constants/app_typography.dart';
import 'package:flutter/material.dart';
import 'package:banjarabio/l10n/app_localizations.dart';
import 'package:sizer/sizer.dart';

import 'package:banjarabio/core/models/profile_model.dart';
import 'package:banjarabio/theme/app_category_theme.dart';
import 'package:banjarabio/widgets/tactile/tactile_category_card.dart';
import 'package:banjarabio/widgets/tactile/tactile_detail_chip.dart';
import 'package:banjarabio/presentation/profile_detail_screen/widgets/staggered_fade_slide_widget.dart';

/// 💼 Education and Profession Card displaying academic and career information.
/// Consumes centralized AppCategoryTheme and shared Tactile components.
class EducationProfessionCardWidget extends StatelessWidget {
  final Map<String, dynamic> profileData;
  final EdgeInsets? margin;
  final VoidCallback? onEdit;

  const EducationProfessionCardWidget({
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

  /// Formats annual income to pure numeric rupee representation.
  String _displayIncome(BuildContext context, dynamic value) {
    if (value == null) {
      return AppLocalizations.of(context)?.notEntered ?? 'Not Entered';
    }
    final formatted = ProfileModel.formatAnnualIncome(value);
    return formatted == 'Not Entered'
        ? (AppLocalizations.of(context)?.notEntered ?? 'Not Entered')
        : formatted;
  }

  @override
  Widget build(BuildContext context) {
    final catTheme = AppCategoryTheme.of(context).career;
    final incomeColor = FieldColorResolver.resolveIncome(context);
    final incomeText = _displayIncome(context, profileData['income']);
    final hasIncome =
        incomeText != (AppLocalizations.of(context)?.notEntered ?? 'Not Entered');

    return TactileCategoryCard(
      categoryType: CategoryType.career,
      title: AppLocalizations.of(context)?.educationProfession ??
          'Education & Profession',
      icon: Icons.work_rounded,
      onEdit: onEdit,
      margin: margin,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Row 0: Highest Education (Full Width)
          StaggeredFadeSlideWidget(
            index: 0,
            child: TactileDetailChip(
              iconName: 'school',
              label: AppLocalizations.of(context)?.education ?? 'Education',
              value: _displayValue(context, profileData['education']),
              tintColor: catTheme.primary,
              fullWidth: true,
            ),
          ),
          SizedBox(height: 0.9.h),

          // Row 1: College / University & Degree Detail
          StaggeredFadeSlideWidget(
            index: 1,
            child: Row(
              children: [
                Expanded(
                  child: TactileDetailChip(
                    iconName: 'menu_book',
                    label: 'Degree / Field',
                    value: _displayValue(
                        context,
                        profileData['degree'] ??
                            profileData['educationDetail']),
                    tintColor: catTheme.secondary,
                  ),
                ),
                SizedBox(width: 2.2.w),
                Expanded(
                  child: TactileDetailChip(
                    iconName: 'account_balance',
                    label: 'College / Institute',
                    value: _displayValue(
                        context,
                        profileData['college'] ??
                            profileData['collegeName']),
                    tintColor: catTheme.tertiary,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 0.9.h),

          // Row 2: Profession / Occupation (Full Width)
          StaggeredFadeSlideWidget(
            index: 2,
            child: TactileDetailChip(
              iconName: 'business_center',
              label: AppLocalizations.of(context)?.occupationLabel ??
                  'Profession / Occupation',
              value: _displayValue(context,
                  profileData['profession'] ?? profileData['occupation']),
              tintColor: catTheme.primary,
              fullWidth: true,
            ),
          ),
          SizedBox(height: 0.9.h),

          // Row 3: Organization & Employed In
          StaggeredFadeSlideWidget(
            index: 3,
            child: Row(
              children: [
                Expanded(
                  child: TactileDetailChip(
                    iconName: 'corporate_fare',
                    label: 'Company / Org',
                    value: _displayValue(
                        context,
                        profileData['company'] ??
                            profileData['organization']),
                    tintColor: catTheme.secondary,
                  ),
                ),
                SizedBox(width: 2.2.w),
                Expanded(
                  child: TactileDetailChip(
                    iconName: 'domain',
                    label: 'Employed In',
                    value: _displayValue(
                        context,
                        profileData['employedIn'] ??
                            profileData['employmentType']),
                    tintColor: catTheme.tertiary,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 0.9.h),

          // Row 4: Annual Income (Dynamic Gold Hero Chip)
          StaggeredFadeSlideWidget(
            index: 4,
            child: TactileDetailChip(
              iconName: 'payments',
              label: AppLocalizations.of(context)?.annualIncome ??
                  'Annual Income',
              value: incomeText,
              tintColor: incomeColor,
              fullWidth: true,
              trailingBadge: hasIncome
                  ? Container(
                      padding: EdgeInsets.symmetric(
                          horizontal: 2.w, vertical: 0.2.h),
                      decoration: BoxDecoration(
                        color: incomeColor.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(
                          color: incomeColor.withValues(alpha: 0.3),
                          width: 0.8,
                        ),
                      ),
                      child: Text(
                        'VERIFIED PACKAGE',
                        style: TextStyle(
                          color: incomeColor,
                          fontSize: AppTypography.labelTiny,
                          fontWeight: AppTypography.extraBold,
                        ),
                      ),
                    )
                  : null,
            ),
          ),
        ],
      ),
    );
  }
}
