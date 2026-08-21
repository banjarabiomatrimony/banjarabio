import 'package:flutter/material.dart';
import 'package:banjarabio/l10n/app_localizations.dart';
import 'package:sizer/sizer.dart';

import 'package:banjarabio/core/constants/app_typography.dart';
import 'package:banjarabio/core/models/profile_model.dart';
import 'package:banjarabio/theme/app_category_theme.dart';
import 'package:banjarabio/widgets/tactile/tactile_category_card.dart';
import 'package:banjarabio/widgets/tactile/tactile_detail_chip.dart';
import 'package:banjarabio/presentation/match_profile_screen/widgets/staggered_fade_slide_widget.dart';
import 'package:banjarabio/theme/app_colors.dart';

/// 💼 Elevated Education, Career & Wealth Holdings Card displaying academic background,
/// employment organization, income with verification badge, and VIP Land/Property portfolio.
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
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final incomeColor = FieldColorResolver.resolveIncome(context);
    final incomeText = _displayIncome(
      context,
      profileData['income'] ?? profileData['annualIncome'],
    );
    final hasIncome =
        incomeText !=
        (AppLocalizations.of(context)?.notEntered ?? 'Not Entered');

    final ancestralLand =
        profileData['ancestralLand'] ??
        profileData['ancestral_land'] ??
        profileData['landHoldings'] ??
        profileData['land_holdings'] ??
        profileData['landAcres'];
    final hasLand =
        ancestralLand != null &&
        ancestralLand.toString().trim().isNotEmpty &&
        ancestralLand.toString() != '0';

    final houseOwnership =
        profileData['houseOwnership'] ??
        profileData['house_ownership'] ??
        (profileData['isHouseOwner'] == true
            ? (AppLocalizations.of(context)?.ownHouseVilla ??
                  'Own House / Villa')
            : null);

    final employmentSector =
        profileData['employmentSector'] ??
        profileData['employedIn'] ??
        profileData['employmentType'];

    final isGovtOrMnc =
        employmentSector != null &&
        (employmentSector.toString().toLowerCase().contains('govt') ||
            employmentSector.toString().toLowerCase().contains('psu') ||
            employmentSector.toString().toLowerCase().contains('mnc'));

    return TactileCategoryCard(
      categoryType: CategoryType.career,
      title:
          AppLocalizations.of(context)?.careerWealthHoldings ??
          'Career & Wealth Holdings',
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
                    label:
                        AppLocalizations.of(context)?.degreeField ??
                        'Degree / Field',
                    value: _displayValue(
                      context,
                      profileData['degree'] ??
                          profileData['educationDetail'] ??
                          profileData['educationDetails'],
                    ),
                    tintColor: catTheme.secondary,
                  ),
                ),
                SizedBox(width: 2.2.w),
                Expanded(
                  child: TactileDetailChip(
                    iconName: 'account_balance',
                    label:
                        AppLocalizations.of(context)?.collegeInstitute ??
                        'College / Institute',
                    value: _displayValue(
                      context,
                      profileData['college'] ?? profileData['collegeName'],
                    ),
                    tintColor: catTheme.tertiary,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 0.9.h),

          // Row 2: Profession / Occupation (Full Width Hero)
          StaggeredFadeSlideWidget(
            index: 2,
            child: TactileDetailChip(
              iconName: 'business_center',
              label:
                  AppLocalizations.of(context)?.occupationLabel ??
                  'Profession / Occupation',
              value: _displayValue(
                context,
                profileData['profession'] ?? profileData['occupation'],
              ),
              tintColor: catTheme.primary,
              fullWidth: true,
              trailingBadge: isGovtOrMnc
                  ? Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.categoryLocation.withValues(alpha: AppColors.opacity15),
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(
                          color: const Color(
                            0xFF10B981,
                          ).withValues(alpha: AppColors.opacity35),
                          width: 0.8,
                        ),
                      ),
                      child: Text(
                        employmentSector.toString().toUpperCase(),
                        style: TextStyle(
                          color: AppColors.categoryLocation,
                          fontSize: AppTypography.labelSmall,
                          fontWeight: AppTypography.black,
                        ),
                      ),
                    )
                  : null,
            ),
          ),

          // Row 3: Organization & Employment Sector
          StaggeredFadeSlideWidget(
            index: 3,
            child: Row(
              children: [
                Expanded(
                  child: TactileDetailChip(
                    iconName: 'corporate_fare',
                    label:
                        AppLocalizations.of(context)?.companyOrg ??
                        'Company / Org',
                    value: _displayValue(
                      context,
                      profileData['company'] ?? profileData['organization'],
                    ),
                    tintColor: catTheme.secondary,
                  ),
                ),
                SizedBox(width: 2.2.w),
                Expanded(
                  child: TactileDetailChip(
                    iconName: 'domain',
                    label:
                        AppLocalizations.of(context)?.employmentSector ??
                        'Employment Sector',
                    value: _displayValue(context, employmentSector),
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
              label:
                  AppLocalizations.of(context)?.annualIncome ?? 'Annual Income',
              value: incomeText,
              tintColor: incomeColor,
              fullWidth: true,
              trailingBadge: hasIncome
                  ? Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 2.w,
                        vertical: 0.2.h,
                      ),
                      decoration: BoxDecoration(
                        color: incomeColor.withValues(alpha: AppColors.opacity15),
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(
                          color: incomeColor.withValues(alpha: AppColors.opacity30),
                          width: 0.8,
                        ),
                      ),
                      child: Text(
                        AppLocalizations.of(context)?.verifiedSalary ??
                            'VERIFIED SALARY',
                        style: TextStyle(
                          fontFamily: AppTypography.bodyFontFamily,
                          color: incomeColor,
                          fontWeight: AppTypography.black,
                          fontSize: AppTypography.labelSmall,
                        ),
                      ),
                    )
                  : null,
            ),
          ),

          // Row 5: 👑 VIP Wealth & Socioeconomic Holdings Card (Land + House Assets)
          if (hasLand || houseOwnership != null) ...[
            SizedBox(height: 1.2.h),
            StaggeredFadeSlideWidget(
              index: 5,
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.4.h),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: isDark
                        ? [
                            AppColors.amberBgDark,
                            AppColors.amberDeepText,
                            AppColors.canvasMidnight,
                          ]
                        : [
                            AppColors.warningLight,
                            AppColors.goldTint100,
                            AppColors.violetBgSoft,
                          ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(
                    color: AppColors.categoryAstro.withValues(alpha: AppColors.opacity40),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.categoryAstro.withValues(alpha: AppColors.opacity10),
                      blurRadius: 10,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: const Color(
                              0xFFF59E0B,
                            ).withValues(alpha: 0.18),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.workspace_premium_rounded,
                            color: AppColors.categoryAstro,
                            size: 16,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          AppLocalizations.of(context)?.vipPropertyAssets ??
                              'VIP PROPERTY & ASSET HOLDINGS',
                          style: TextStyle(
                            color: isDark
                                ? AppColors.goldTint200
                                : AppColors.amberDark,
                            fontSize: AppTypography.labelSmall,
                            fontWeight: AppTypography.black,
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
                              0xFFF59E0B,
                            ).withValues(alpha: AppColors.opacity20),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            AppLocalizations.of(context)?.tier4Vip ??
                                'TIER 4 VIP',
                            style: TextStyle(
                              color: AppColors.categoryAstro,
                              fontSize: AppTypography.labelSmall,
                              fontWeight: AppTypography.black,
                            ),
                          ),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        if (hasLand)
                          Expanded(
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.landscape_rounded,
                                  size: 16,
                                  color: AppColors.categoryAstroDark,
                                ),
                                const SizedBox(width: 6),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        AppLocalizations.of(
                                              context,
                                            )?.ancestralLand ??
                                            'Ancestral Land',
                                        style: TextStyle(
                                          fontFamily:
                                              AppTypography.bodyFontFamily,
                                          fontWeight: AppTypography.bold,
                                          color: Colors.grey,
                                          fontSize: AppTypography.labelSmall,
                                        ),
                                      ),
                                      Text(
                                        '$ancestralLand ${AppLocalizations.of(context)?.acres ?? "Acres"}',
                                        style: TextStyle(
                                          fontFamily:
                                              AppTypography.bodyFontFamily,
                                          fontWeight: AppTypography.black,
                                          color: isDark
                                              ? Colors.white
                                              : AppColors.amberDeepText,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        if (hasLand && houseOwnership != null)
                          Container(
                            height: 28,
                            width: 1,
                            color: Colors.grey.withValues(alpha: AppColors.opacity30),
                            margin: EdgeInsets.symmetric(horizontal: 2.w),
                          ),
                        if (houseOwnership != null)
                          Expanded(
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.home_work_rounded,
                                  size: 16,
                                  color: AppColors.categoryAstroDark,
                                ),
                                const SizedBox(width: 6),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        AppLocalizations.of(
                                              context,
                                            )?.houseOwnership ??
                                            'House Ownership',
                                        style: TextStyle(
                                          fontFamily:
                                              AppTypography.bodyFontFamily,
                                          fontWeight: AppTypography.bold,
                                          color: Colors.grey,
                                          fontSize: AppTypography.labelSmall,
                                        ),
                                      ),
                                      Text(
                                        _displayValue(context, houseOwnership),
                                        style: TextStyle(
                                          fontFamily:
                                              AppTypography.bodyFontFamily,
                                          fontWeight: AppTypography.black,
                                          color: isDark
                                              ? Colors.white
                                              : AppColors.amberDeepText,
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
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
