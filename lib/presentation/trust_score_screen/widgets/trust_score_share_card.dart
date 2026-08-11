import 'package:flutter/material.dart';
import 'package:banjarabio/l10n/app_localizations.dart';
import 'package:sizer/sizer.dart';
import 'package:banjarabio/core/app_export.dart';
import 'package:banjarabio/core/constants/app_typography.dart';

class TrustScoreShareCard extends StatelessWidget {
  final int score;
  final String userName;
  final String? profileImageUrl;

  const TrustScoreShareCard({
    super.key,
    required this.score,
    required this.userName,
    this.profileImageUrl,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = _getScoreColor(score);

    return Container(
      width: 90.w,
      padding: EdgeInsets.all(24.sp),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            theme.colorScheme.primary,
            theme.colorScheme.primary.withAlpha(200),
          ],
        ),
        borderRadius: BorderRadius.circular(24.sp),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(50),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(AppLocalizations.of(context)?.banjarabio ?? 'BanjaraBio',
                    style: TextStyle(fontFamily: AppTheme.headingFontFamily,
                      color: Colors.white,
                      fontSize: AppTypography.headingMedium,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.2,
                    ),
                  ),
                  Text(AppLocalizations.of(context)?.verifiedCommunityMember ?? 'Verified Community Member',
                    style: TextStyle(fontFamily: AppTheme.bodyFontFamily,
                      color: Colors.white70,
                      fontSize: AppTypography.bodySmall,
                    ),
                  ),
                ],
              ),
              const Icon(Icons.verified_rounded, color: Colors.white, size: 30),
            ],
          ),
          SizedBox(height: 30.sp),
          _buildScoreCircle(context, theme, color),
          SizedBox(height: 30.sp),
          Text(
            userName,
            style: TextStyle(fontFamily: AppTheme.headingFontFamily,
              color: Colors.white,
              fontSize: AppTypography.headingMedium,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 8.sp),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 16.sp, vertical: 6.sp),
            decoration: BoxDecoration(
              color: Colors.white.withAlpha(50),
              borderRadius: BorderRadius.circular(20.sp),
            ),
            child: Text(
              _getBadgeLabel(context, score),
              style: TextStyle(fontFamily: AppTheme.bodyFontFamily,
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: AppTypography.bodyMedium,
              ),
            ),
          ),
          SizedBox(height: 40.sp),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(AppLocalizations.of(context)?.joinMeOnBanjarabio ?? 'Join me on BanjaraBio',
                style: TextStyle(fontFamily: AppTheme.bodyFontFamily,
                  color: Colors.white70,
                  fontSize: AppTypography.bodySmall,
                ),
              ),
              SizedBox(width: 8.sp),
              const Icon(Icons.favorite, color: Colors.white, size: 14),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildScoreCircle(BuildContext context, ThemeData theme, Color color) {
    return Stack(
      alignment: Alignment.center,
      children: [
        SizedBox(
          width: 45.w,
          height: 45.w,
          child: CircularProgressIndicator(
            value: score / 100,
            strokeWidth: 12.sp,
            backgroundColor: Colors.white.withAlpha(30),
            valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
          ),
        ),
        Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '$score',
              style: TextStyle(fontFamily: AppTheme.headingFontFamily,
                color: Colors.white,
                fontSize: AppTypography.displayLarge,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(AppLocalizations.of(context)?.trustScore ?? 'TRUST SCORE',
              style: TextStyle(fontFamily: AppTheme.bodyFontFamily,
                color: Colors.white70,
                fontSize: AppTypography.bodySmall,
                fontWeight: FontWeight.w500,
                letterSpacing: 2,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Color _getScoreColor(int score) {
    if (score >= 80) return Colors.green;
    if (score >= 50) return Colors.orange;
    return Colors.red;
  }

  String _getBadgeLabel(BuildContext context, int score) {
    if (score >= 80) return AppLocalizations.of(context)?.goldVerified ?? 'GOLD VERIFIED';
    if (score >= 50) return AppLocalizations.of(context)?.trustedMember ?? 'TRUSTED MEMBER';
    return AppLocalizations.of(context)?.communityMember ?? 'COMMUNITY MEMBER';
  }
}
