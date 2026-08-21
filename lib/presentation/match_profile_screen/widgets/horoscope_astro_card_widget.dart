import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:banjarabio/l10n/app_localizations.dart';
import 'package:sizer/sizer.dart';

import 'package:banjarabio/core/constants/app_typography.dart';
import 'package:banjarabio/theme/app_category_theme.dart';
import 'package:banjarabio/widgets/tactile/tactile_category_card.dart';
import 'package:banjarabio/widgets/tactile/tactile_detail_chip.dart';
import 'package:banjarabio/widgets/tactile/tactile_pressable.dart';
import 'package:banjarabio/presentation/match_profile_screen/widgets/staggered_fade_slide_widget.dart';
import 'package:banjarabio/theme/app_colors.dart';

/// 🔮 Elevated Horoscope & Astro Card displaying astrological biodata, Manglik status,
/// Rashi, Nakshatra, animated 36 Guna Milan gauge, and interactive Kundali preview.
class HoroscopeAstroCardWidget extends StatelessWidget {
  final Map<String, dynamic> profileData;
  final EdgeInsets? margin;
  final VoidCallback? onEdit;
  final VoidCallback? onViewKundali;

  const HoroscopeAstroCardWidget({
    super.key,
    required this.profileData,
    this.margin,
    this.onEdit,
    this.onViewKundali,
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

  Color _resolveManglikColor(String status) {
    final lower = status.toLowerCase();
    if (lower.contains('non') || lower == 'no' || lower.contains('not')) {
      return AppColors.categoryLocation; // Emerald Green
    } else if (lower.contains('anshik') || lower.contains('partial') || lower.contains('mild')) {
      return AppColors.categoryAstro; // Amber Gold
    } else if (lower.contains('manglik') || lower == 'yes') {
      return AppColors.trustLow; // Crimson
    }
    return AppColors.categoryFamily; // Purple default
  }

  void _showKundaliBottomSheet(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final rashi = _displayValue(context, profileData['rashi'] ?? profileData['moonSign']);
    final nakshatra = _displayValue(context, profileData['nakshatra'] ?? profileData['birthStar']);
    final birthTime = _displayValue(context, profileData['birthTime'] ?? profileData['timeOfBirth']);
    final birthPlace = _displayValue(context, profileData['birthPlace'] ?? profileData['placeOfBirth']);

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) => Container(
        padding: EdgeInsets.symmetric(horizontal: 5.w, vertical: 2.5.h),
        decoration: BoxDecoration(
          color: isDark ? AppColors.canvasMidnight : Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
          border: Border.all(
            color: AppColors.categoryFamily.withValues(alpha: AppColors.opacity30),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 12.w,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.withValues(alpha: AppColors.opacity30),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            SizedBox(height: 2.h),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColors.categoryFamily.withValues(alpha: AppColors.opacity15),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.auto_awesome_rounded, color: AppColors.categoryFamily, size: 22),
                ),
                SizedBox(width: 3.w),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      AppLocalizations.of(context)?.horoscopeKundali ?? 'Horoscope & Kundali Chart',
                      style:                       AppTypography.displayStyle(
                        fontSize: AppTypography.headingSmall,
                      ),
                    ),
                    Text(
                      AppLocalizations.of(context)?.planetaryLagnaAlignment ?? 'Planetary Lagna & Ashtakoot Alignment',
                      style:                       AppTypography.bodyStyle(
                        color: Colors.grey,
                        fontWeight: AppTypography.semiBold,
                        fontSize: AppTypography.labelSmall,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            SizedBox(height: 2.5.h),

            // Astro Grid
            Container(
              padding: EdgeInsets.all(4.w),
              decoration: BoxDecoration(
                color: isDark ? AppColors.slate900 : AppColors.slate50,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: AppColors.categoryFamily.withValues(alpha: AppColors.opacity20),
                ),
              ),
              child: Column(
                children: [
                  _buildKundaliRow(context, AppLocalizations.of(context)?.rashiMoonSign ?? 'Moon Sign (राशी)', rashi, Icons.brightness_2_rounded),
                  const Divider(height: 20),
                  _buildKundaliRow(context, AppLocalizations.of(context)?.nakshatraStar ?? 'Birth Star (नक्षत्र)', nakshatra, Icons.star_rounded),
                  const Divider(height: 20),
                  _buildKundaliRow(context, AppLocalizations.of(context)?.birthTimeLabel ?? 'Time of Birth', birthTime, Icons.access_time_rounded),
                  const Divider(height: 20),
                  _buildKundaliRow(context, AppLocalizations.of(context)?.birthPlaceLabel ?? 'Place of Birth', birthPlace, Icons.place_rounded),
                ],
              ),
            ),
            SizedBox(height: 3.h),
            SizedBox(
              width: double.infinity,
              height: 6.h,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.categoryFamilyDark,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
                onPressed: () => Navigator.of(ctx).pop(),
                child: Text(AppLocalizations.of(context)?.closePreview ?? 'Close Preview', style:  AppTypography.bodyStyle(
   fontWeight: AppTypography.extraBold),
 ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  static Widget _buildKundaliRow(BuildContext context, String title, String value, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 16, color: AppColors.categoryFamily),
        const SizedBox(width: 8),
        Text(
          title,
          style:           AppTypography.labelStyle(
            color: Colors.grey,
            fontSize: AppTypography.labelSmall,
          ),
        ),
        const Spacer(),
        Text(
          value,
          style:           AppTypography.buttonStyle(
            fontSize: AppTypography.bodyMedium,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final catTheme = AppCategoryTheme.of(context).astro;

    final manglikStatus = (profileData['manglik'] ??
            profileData['manglikStatus'] ??
            profileData['dosha'])
        ?.toString();
    final hasManglik = manglikStatus != null && manglikStatus.trim().isNotEmpty;
    final manglikColor = hasManglik ? _resolveManglikColor(manglikStatus) : catTheme.primary;

    final rashi = profileData['rashi'] ?? profileData['moonSign'];
    final nakshatra = profileData['nakshatra'] ?? profileData['birthStar'];
    final birthTime = profileData['birthTime'] ?? profileData['timeOfBirth'];
    final birthPlace = profileData['birthPlace'] ?? profileData['placeOfBirth'];
    final gunaScore = profileData['gunaScore'] ?? profileData['minGunaScore'] ?? profileData['gunaMilanScore'];
    final hasKundali = profileData['hasHoroscope'] == true ||
        profileData['kundaliAttached'] == true ||
        profileData['horoscopeUrl'] != null;

    final parsedGuna = double.tryParse(gunaScore?.toString() ?? '28') ?? 28;

    return TactileCategoryCard(
      categoryType: CategoryType.astro,
      title: AppLocalizations.of(context)?.horoscopeKundali ?? 'Horoscope & Kundali (कुंडली)',
      icon: Icons.auto_awesome_rounded,
      onEdit: onEdit,
      margin: margin,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Row 0: Manglik Status (Full Width Hero Chip)
          StaggeredFadeSlideWidget(
            index: 0,
            child: TactileDetailChip(
              iconName: 'wb_sunny',
              label: AppLocalizations.of(context)?.manglikDosha ?? 'Manglik / Kuja Dosha',
              value: hasManglik ? manglikStatus : (AppLocalizations.of(context)?.notSpecified ?? 'Not Specified'),
              tintColor: manglikColor,
              fullWidth: true,
              trailingBadge: hasManglik
                  ? Container(
                      padding: EdgeInsets.symmetric(horizontal: 2.2.w, vertical: 0.3.h),
                      decoration: BoxDecoration(
                        color: manglikColor.withValues(alpha: AppColors.opacity15),
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(
                          color: manglikColor.withValues(alpha: AppColors.opacity35),
                          width: 0.8,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            manglikColor == AppColors.categoryLocation
                                ? Icons.check_circle_rounded
                                : Icons.info_outline_rounded,
                            size: 12,
                            color: manglikColor,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            manglikStatus.toUpperCase(),
                            style:                             AppTypography.buttonStyle(
                              color: manglikColor,
                              fontSize: AppTypography.labelSmall,
                              letterSpacing: 0.4,
                            ),
                          ),
                        ],
                      ),
                    )
                  : null,
            ),
          ),
          SizedBox(height: 0.9.h),

          // Row 1: Rashi (Moon Sign) & Nakshatra (Birth Star)
          StaggeredFadeSlideWidget(
            index: 1,
            child: Row(
              children: [
                Expanded(
                  child: TactileDetailChip(
                    iconName: 'brightness_2',
                    label: AppLocalizations.of(context)?.rashiMoonSign ?? 'Rashi (Moon Sign)',
                    value: _displayValue(context, rashi),
                    tintColor: catTheme.primary,
                  ),
                ),
                SizedBox(width: 2.2.w),
                Expanded(
                  child: TactileDetailChip(
                    iconName: 'star',
                    label: AppLocalizations.of(context)?.nakshatraStar ?? 'Nakshatra (Star)',
                    value: _displayValue(context, nakshatra),
                    tintColor: catTheme.secondary,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 0.9.h),

          // Row 2: Birth Time & Date of Birth
          StaggeredFadeSlideWidget(
            index: 2,
            child: Row(
              children: [
                Expanded(
                  child: TactileDetailChip(
                    iconName: 'access_time',
                    label: AppLocalizations.of(context)?.birthTimeLabel ?? 'Birth Time',
                    value: _displayValue(context, birthTime),
                    tintColor: catTheme.tertiary,
                  ),
                ),
                SizedBox(width: 2.2.w),
                Expanded(
                  child: TactileDetailChip(
                    iconName: 'calendar_month',
                    label: AppLocalizations.of(context)?.dateOfBirthLabel ?? 'Date of Birth',
                    value: _displayValue(context, profileData['dateOfBirth'] ?? profileData['dob']),
                    tintColor: catTheme.primary,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 0.9.h),

          // Row 3: Birth Place (Full Width)
          StaggeredFadeSlideWidget(
            index: 3,
            child: TactileDetailChip(
              iconName: 'place',
              label: AppLocalizations.of(context)?.birthPlaceLabel ?? 'Birth Place',
              value: _displayValue(context, birthPlace),
              tintColor: catTheme.secondary,
              fullWidth: true,
            ),
          ),

          // Row 4: 🌟 Animated 36 Guna Milan Gauge
          SizedBox(height: 1.h),
          StaggeredFadeSlideWidget(
            index: 4,
            child: _GunaMilanGaugeCard(score: parsedGuna),
          ),

          // Kundali Document Preview / Action
          SizedBox(height: 1.2.h),
          StaggeredFadeSlideWidget(
            index: 5,
            child: TactilePressable(
              onTap: () {
                if (onViewKundali != null) {
                  onViewKundali!();
                } else {
                  _showKundaliBottomSheet(context);
                }
              },
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 3.5.w, vertical: 1.2.h),
                decoration: BoxDecoration(
                  color: Theme.of(context).brightness == Brightness.dark
                      ? AppColors.canvasMidnight.withValues(alpha: AppColors.opacity60)
                      : AppColors.infoLight,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: AppColors.categorySecurity.withValues(alpha: AppColors.opacity25),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      hasKundali ? Icons.description_rounded : Icons.lock_outline_rounded,
                      color: AppColors.categorySecurity,
                      size: 20,
                    ),
                    SizedBox(width: 3.w),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            hasKundali
                                ? (AppLocalizations.of(context)?.horoscopeKundaliAttached ?? 'Horoscope / Kundali Attached')
                                : (AppLocalizations.of(context)?.kundaliOnRequest ?? 'Kundali Available on Request'),
                            style: TextStyle(
                              color: Theme.of(context).brightness == Brightness.dark
                                  ? Colors.white
                                  : AppColors.canvasMidnight,
                              fontSize: AppTypography.bodySmall,
                              fontWeight: AppTypography.extraBold,
                            ),
                          ),
                          Text(
                            hasKundali
                                ? (AppLocalizations.of(context)?.tapToPreviewKundali ?? 'Tap to preview Kundali chart & planetary alignments')
                                : (AppLocalizations.of(context)?.verifiedHoroscopeOnMutual ?? 'Verified horoscope chart on mutual match interest'),
                            style: TextStyle(
                              color: Theme.of(context).brightness == Brightness.dark
                                  ? AppColors.slate400
                                  : AppColors.slate500,
                              fontSize: AppTypography.labelSmall,
                              fontWeight: AppTypography.semiBold,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Icon(
                      Icons.arrow_forward_ios_rounded,
                      size: 14,
                      color: Theme.of(context).brightness == Brightness.dark
                          ? AppColors.slate400
                          : AppColors.slate500,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// 🌟 Animated 36 Guna Milan Radial / Compatibility Dial Card
class _GunaMilanGaugeCard extends StatefulWidget {
  final double score;

  const _GunaMilanGaugeCard({required this.score});

  @override
  State<_GunaMilanGaugeCard> createState() => _GunaMilanGaugeCardState();
}

class _GunaMilanGaugeCardState extends State<_GunaMilanGaugeCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    _animation = Tween<double>(begin: 0.0, end: widget.score).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic),
    );
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        final currentVal = _animation.value;
        final percentage = (currentVal / 36.0).clamp(0.0, 1.0);
        final isHigh = widget.score >= 24;

        return Container(
          padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.4.h),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: isDark
                  ? [AppColors.deepIndigo, AppColors.deepIndigo]
                  : [AppColors.violetBgSoft, AppColors.violetBg],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: AppColors.categoryFamily.withValues(alpha: AppColors.opacity35),
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.categoryFamily.withValues(alpha: AppColors.opacity10),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              // Radial Gauge Circle
              SizedBox(
                width: 48,
                height: 48,
                child: CustomPaint(
                  painter: _RadialDialPainter(
                    progress: percentage,
                    color: isHigh ? AppColors.categoryLocation : AppColors.categoryFamily,
                    trackColor: AppColors.categoryFamily.withValues(alpha: AppColors.opacity20),
                  ),
                  child: Center(
                    child: Text(
                      currentVal.toStringAsFixed(0),
                      style: TextStyle(
                        color: isDark ? Colors.white : AppColors.deepIndigo,
                        fontWeight: AppTypography.black,
                        fontSize: AppTypography.bodyMedium,
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(width: 3.5.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          AppLocalizations.of(context)?.gunaMilanScore ?? '36 GUNA MILAN (अष्टकूट जुळणी)',
                          style: TextStyle(
                            color: isDark ? AppColors.categoryFamily : AppColors.violetDeep,
                            fontSize: AppTypography.labelTiny,
                            fontWeight: AppTypography.black,
                            letterSpacing: 0.5,
                          ),
                        ),
                        const Spacer(),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: (isHigh ? AppColors.categoryLocation : AppColors.categoryFamily)
                                .withValues(alpha: AppColors.opacity15),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            isHigh
                                ? (AppLocalizations.of(context)?.highMatch ?? 'HIGH MATCH')
                                : (AppLocalizations.of(context)?.goodMatch ?? 'GOOD MATCH'),
                            style: TextStyle(
                              color: isHigh ? AppColors.categoryLocation : AppColors.categoryFamily,
                              fontSize: AppTypography.labelTiny,
                              fontWeight: AppTypography.black,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 3),
                    Text(
                      AppLocalizations.of(context)?.gunasMatchedCount(
                            currentVal.toInt(),
                            (percentage * 100).toInt(),
                          ) ??
                          '${currentVal.toStringAsFixed(0)} / 36 Gunas Matched (${(percentage * 100).toStringAsFixed(0)}%)',
                      style: TextStyle(
                        color: isDark ? Colors.white : AppColors.deepIndigo,
                        fontSize: AppTypography.bodyMedium,
                        fontWeight: AppTypography.black,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _RadialDialPainter extends CustomPainter {
  final double progress;
  final Color color;
  final Color trackColor;

  _RadialDialPainter({
    required this.progress,
    required this.color,
    required this.trackColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 3;

    final trackPaint = Paint()
      ..color = trackColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4.5
      ..strokeCap = StrokeCap.round;

    final progPaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4.5
      ..strokeCap = StrokeCap.round;

    canvas.drawCircle(center, radius, trackPaint);

    final sweepAngle = 2 * math.pi * progress;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -math.pi / 2,
      sweepAngle,
      false,
      progPaint,
    );
  }

  @override
  bool shouldRepaint(covariant _RadialDialPainter oldDelegate) =>
      oldDelegate.progress != progress || oldDelegate.color != color;
}
