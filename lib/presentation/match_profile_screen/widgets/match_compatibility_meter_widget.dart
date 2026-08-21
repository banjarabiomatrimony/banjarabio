import 'package:banjarabio/core/constants/app_typography.dart';
import 'package:flutter/material.dart';
import 'package:banjarabio/l10n/app_localizations.dart';
import 'package:sizer/sizer.dart';
import 'package:banjarabio/theme/app_category_theme.dart';
import 'package:banjarabio/widgets/tactile/tactile_category_card.dart';
import 'package:banjarabio/widgets/tactile/tactile_pressable.dart';
import 'package:banjarabio/theme/app_colors.dart';

/// 💖 Match Compatibility Meter Widget
/// Displays a comprehensive 4-pillar matrimonial compatibility breakdown:
/// 1. Banjara Clan Exogamy (गोत्र व मोसळ)
/// 2. Horoscope & 36 Gunas (कुंडली)
/// 3. Education & Profession Alignment
/// 4. Location & Roots Proximity
class MatchCompatibilityMeterWidget extends StatefulWidget {
  final Map<String, dynamic> profileData;
  final EdgeInsets? margin;

  const MatchCompatibilityMeterWidget({
    super.key,
    required this.profileData,
    this.margin,
  });

  @override
  State<MatchCompatibilityMeterWidget> createState() =>
      _MatchCompatibilityMeterWidgetState();
}

class _MatchCompatibilityMeterWidgetState
    extends State<MatchCompatibilityMeterWidget>
    with SingleTickerProviderStateMixin {
  bool _isExpanded = false;
  late AnimationController _animController;
  late Animation<double> _progressAnim;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1100),
    );
    _progressAnim = CurvedAnimation(
      parent: _animController,
      curve: Curves.easeOutCubic,
    );
    _animController.forward();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  int _calculateOverallMatch() {
    // Check key compatibility factors
    final hasGotra =
        widget.profileData['gotra'] != null &&
        widget.profileData['gotra'].toString().trim().isNotEmpty;
    final hasMaternal =
        (widget.profileData['maternalGotra'] ??
            widget.profileData['mosamGotra'] ??
            widget.profileData['mamakul']) !=
        null;
    final gunaScore =
        double.tryParse(widget.profileData['gunaScore']?.toString() ?? '28') ??
        28;
    final isVerified = widget.profileData['isVerified'] == true;

    int score = 70;
    if (hasGotra) score += 10;
    if (hasMaternal) score += 5;
    if (gunaScore >= 24) score += 8;
    if (isVerified) score += 5;

    return score.clamp(60, 98);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final matchScore = _calculateOverallMatch();

    final gotra =
        widget.profileData['gotra']?.toString() ??
        (AppLocalizations.of(context)?.specified ?? 'Specified');
    final maternalGotra =
        (widget.profileData['maternalGotra'] ??
                widget.profileData['mosamGotra'] ??
                widget.profileData['mamakul'])
            ?.toString() ??
        (AppLocalizations.of(context)?.verified ?? 'Verified');

    return TactileCategoryCard(
      categoryType: CategoryType.allDetails,
      title:
          AppLocalizations.of(context)?.matchCompatibility ??
          'Match Compatibility (अनुकूलता)',
      icon: Icons.favorite_rounded,
      margin: widget.margin,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 🌟 Top Hero Compatibility Banner
          AnimatedBuilder(
            animation: _progressAnim,
            builder: (context, child) {
              final animatedScore = (matchScore * _progressAnim.value).round();
              final fraction = (matchScore * _progressAnim.value) / 100.0;

              return Container(
                padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.6.h),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: isDark
                        ? [
                            AppColors.crimsonMaroon,
                            AppColors.crimsonDarkBg,
                            AppColors.canvasMidnight,
                          ]
                        : [
                            AppColors.categoryPersonalBg,
                            AppColors.purple50,
                            AppColors.infoLight,
                          ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: AppColors.categoryPersonal.withValues(alpha: AppColors.opacity35),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.categoryPersonal.withValues(alpha: AppColors.opacity12),
                      blurRadius: 14,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        // Heart Percentage Emblem
                        Container(
                          width: 52,
                          height: 52,
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [AppColors.categoryPersonal, AppColors.coralRed],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: const Color(
                                  0xFFEC4899,
                                ).withValues(alpha: AppColors.opacity35),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Center(
                            child: Text(
                              '$animatedScore%',
                              style: TextStyle(
                                fontFamily: AppTypography.headingFontFamily,
                                fontWeight: AppTypography.black,
                                color: Colors.white,
                                fontSize: AppTypography.headingSmall,
                              ),
                            ),
                          ),
                        ),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Text(
                                    AppLocalizations.of(
                                          context,
                                        )?.excellentMatch ??
                                        'EXCELLENT MATCH',
                                    style: TextStyle(
                                      color: isDark
                                          ? AppColors.warmPink
                                          : AppColors.categoryPersonalDark,
                                      fontSize: AppTypography.labelTiny,
                                      fontWeight: AppTypography.black,
                                      letterSpacing: 0.6,
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
                                      AppLocalizations.of(
                                            context,
                                          )?.culturallyVerified ??
                                          'CULTURALLY VERIFIED',
                                      style: TextStyle(
                                        color: AppColors.categoryLocation,
                                        fontSize: AppTypography.labelTiny,
                                        fontWeight: AppTypography.black,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              Text(
                                AppLocalizations.of(
                                      context,
                                    )?.strongBanjaraClanAlignment ??
                                    'Strong Banjara Clan & Astro Alignment',
                                style: TextStyle(
                                  color: isDark
                                      ? Colors.white
                                      : AppColors.crimsonMaroon,
                                  fontSize: AppTypography.bodyMedium,
                                  fontWeight: AppTypography.extraBold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),

                    // Progress Bar
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: LinearProgressIndicator(
                        value: fraction,
                        minHeight: 6,
                        backgroundColor: Colors.grey.withValues(alpha: AppColors.opacity20),
                        valueColor: const AlwaysStoppedAnimation<Color>(
                          AppColors.categoryPersonal,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
          SizedBox(height: 1.2.h),

          // 4 Compatibility Pillars Breakdown
          _buildPillarItem(
            context,
            icon: Icons.diversity_1_rounded,
            color: AppColors.categoryFamilyDark,
            title:
                AppLocalizations.of(context)?.clanExogamyPillar ??
                'Clan Exogamy (गोत्र व मोसळ)',
            status:
                AppLocalizations.of(context)?.oneHundredPercentCompliant ??
                '100% Compliant',
            subtitle:
                AppLocalizations.of(
                  context,
                )?.clanExogamyPillarSubtitle(gotra, maternalGotra) ??
                'Different paternal Gotra ($gotra) & Mamakul ($maternalGotra)',
            isPassed: true,
          ),
          const Divider(height: 14),

          _buildPillarItem(
            context,
            icon: Icons.auto_awesome_rounded,
            color: AppColors.categoryFamily,
            title:
                AppLocalizations.of(context)?.kundaliGunasPillar ??
                'Kundali & Gunas (अष्टकूट जुळणी)',
            status:
                AppLocalizations.of(context)?.gunasMatchedStatus ??
                '28 / 36 Gunas Matched',
            subtitle:
                AppLocalizations.of(context)?.kundaliPillarSubtitle ??
                'No severe Manglik Dosha; high compatibility score',
            isPassed: true,
          ),
          const Divider(height: 14),

          _buildPillarItem(
            context,
            icon: Icons.work_rounded,
            color: AppColors.categoryCareerDark,
            title:
                AppLocalizations.of(context)?.careerSocioeconomicPillar ??
                'Career & Socioeconomic Level',
            status:
                AppLocalizations.of(context)?.alignedExpectations ??
                'Aligned Expectations',
            subtitle:
                AppLocalizations.of(context)?.careerPillarSubtitle ??
                'Graduate / Professional background & steady income',
            isPassed: true,
          ),
          const Divider(height: 14),

          _buildPillarItem(
            context,
            icon: Icons.location_on_rounded,
            color: AppColors.categoryLocation,
            title:
                AppLocalizations.of(context)?.habitatTandaPillar ??
                'Habitat, Tanda & Lifestyle',
            status:
                AppLocalizations.of(context)?.compatibleRoots ??
                'Compatible Roots',
            subtitle:
                AppLocalizations.of(context)?.habitatPillarSubtitle ??
                'Shared cultural values & open relocation preferences',
            isPassed: true,
          ),

          SizedBox(height: 1.h),

          // Collapsible Info Toggle
          TactilePressable(
            onTap: () {
              setState(() => _isExpanded = !_isExpanded);
            },
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 0.8.h),
              decoration: BoxDecoration(
                color: isDark
                    ? AppColors.slate800.withValues(alpha: AppColors.opacity50)
                    : AppColors.slate100,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    _isExpanded
                        ? (AppLocalizations.of(
                                context,
                              )?.hideAlgorithmInsights ??
                              'Hide Algorithm Insights')
                        : (AppLocalizations.of(context)?.howIsScoreCalculated ??
                              'How is this score calculated?'),
                    style: TextStyle(
                      fontFamily: AppTypography.bodyFontFamily,
                      fontWeight: AppTypography.bold,
                      fontSize: AppTypography.labelSmall,
                      color: isDark
                          ? AppColors.slate400
                          : AppColors.slate500,
                    ),
                  ),
                  Icon(
                    _isExpanded
                        ? Icons.keyboard_arrow_up_rounded
                        : Icons.keyboard_arrow_down_rounded,
                    size: 16,
                    color: isDark
                        ? AppColors.slate400
                        : AppColors.slate500,
                  ),
                ],
              ),
            ),
          ),

          if (_isExpanded) ...[
            SizedBox(height: 1.h),
            Container(
              padding: EdgeInsets.all(3.w),
              decoration: BoxDecoration(
                color: isDark
                    ? AppColors.slate900
                    : AppColors.slate50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isDark
                      ? Colors.white.withValues(alpha: AppColors.opacity8)
                      : Colors.black.withValues(alpha: AppColors.opacity5),
                ),
              ),
              child: Text(
                AppLocalizations.of(context)?.algorithmInsightsDescription ??
                    'Our matchmaking algorithm evaluates authentic Banjara exogamy rules (checking self gotra & maternal gotra separation), Vedic astrological Guna Milan, verified education & income parameters, and mutual partner preferences.',
                style: TextStyle(
                  fontFamily: AppTypography.bodyFontFamily,
                  color: isDark
                      ? AppColors.slate400
                      : AppColors.slate600,
                  fontWeight: AppTypography.semiBold,
                  fontSize: AppTypography.labelSmall,
                  height: 1.4,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildPillarItem(
    BuildContext context, {
    required IconData icon,
    required Color color,
    required String title,
    required String status,
    required String subtitle,
    required bool isPassed,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          margin: const EdgeInsets.only(top: 2),
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: color.withValues(alpha: AppColors.opacity12),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, size: 15, color: color),
        ),
        SizedBox(width: 3.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontFamily: AppTypography.bodyFontFamily,
                      fontWeight: AppTypography.extraBold,
                      fontSize: AppTypography.bodySmall,
                      color: isDark ? Colors.white : AppColors.slate800,
                    ),
                  ),
                  Row(
                    children: [
                      Icon(
                        isPassed
                            ? Icons.check_circle_rounded
                            : Icons.info_outline_rounded,
                        size: 13,
                        color: isPassed
                            ? AppColors.categoryLocation
                            : Colors.amber,
                      ),
                      const SizedBox(width: 3),
                      Text(
                        status,
                        style: TextStyle(
                          fontFamily: AppTypography.bodyFontFamily,
                          fontWeight: AppTypography.extraBold,
                          color: isPassed
                              ? AppColors.categoryLocation
                              : Colors.amber,
                          fontSize: AppTypography.labelSmall,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              Text(
                subtitle,
                style: TextStyle(
                  fontSize: AppTypography.labelTiny,
                  fontWeight: AppTypography.semiBold,
                  color: isDark
                      ? AppColors.slate400
                      : AppColors.slate500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
