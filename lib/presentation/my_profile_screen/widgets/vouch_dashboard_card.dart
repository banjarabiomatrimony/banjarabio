import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:sizer/sizer.dart';
import 'package:banjarabio/l10n/app_localizations.dart';
import 'package:banjarabio/core/models/profile_model.dart';
import 'package:banjarabio/theme/app_theme.dart';
import 'package:banjarabio/widgets/glassmorphism_container.dart';
import 'package:banjarabio/presentation/home_screen/widgets/community_trusted_badge.dart';
import 'package:banjarabio/core/constants/app_typography.dart';
import 'package:banjarabio/theme/app_colors.dart';

class VouchDashboardCard extends StatelessWidget {
  final ProfileModel profile;
  final VoidCallback onInviteTap;

  const VouchDashboardCard({
    super.key,
    required this.profile,
    required this.onInviteTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return GlassmorphismContainer(
      borderRadius: BorderRadius.circular(24),
      padding: EdgeInsets.all(4.w),
      color: AppTheme.primaryLight,
      opacity: isDark ? 0.1 : 0.05,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Social Proof',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: AppTypography.bold,
                      color: AppTheme.primaryLight,
                    ),
                  ),
                  Text(
                    'Community Vouches',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
              if (profile.isCommunityTrusted)
                const CommunityTrustedBadge()
              else
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    'Pending Trust',
                    style: TextStyle(
                      fontSize: AppTypography.labelMedium,
                      fontWeight: AppTypography.semiBold,
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
            ],
          ),
          SizedBox(height: 2.h),
          Row(
            children: [
              _buildStatItem(
                context,
                count: profile.vouchCount.toString(),
                label: 'Vouches',
                icon: Icons.how_to_reg,
              ),
              const Spacer(),
              _buildStatItem(
                context,
                count: '${(profile.vouchCount / 5 * 100).clamp(0, 100).toInt()}%',
                label: 'Trust Level',
                icon: FontAwesomeIcons.shieldHeart,
              ),
            ],
          ),
          SizedBox(height: 1.5.h),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: (profile.vouchCount / 5).clamp(0.0, 1.0),
              minHeight: 8,
              backgroundColor: theme.colorScheme.primary.withValues(alpha: AppColors.opacity10),
              valueColor: const AlwaysStoppedAnimation<Color>(AppColors.green500),
            ),
          ),
          SizedBox(height: 2.h),
          SizedBox(
            width: double.infinity,
            height: 5.5.h,
            child: ElevatedButton.icon(
              onPressed: onInviteTap,
              icon: const Icon(FontAwesomeIcons.whatsapp, size: 18),
              label: Text(
                AppLocalizations.of(context)?.inviteRelativesToVouch ?? 'Invite Relatives to Vouch',
                style: TextStyle(
                  fontWeight: AppTypography.extraBold,
                  fontSize: AppTypography.headingSmall,
                  letterSpacing: 0.3,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.whatsapp,
                foregroundColor: Colors.white,
                elevation: 3,
                shadowColor: AppColors.whatsapp.withValues(alpha: AppColors.opacity40),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            ),
          ),
          if (!profile.isCommunityTrusted) ...[
            SizedBox(height: 1.5.h),
            Text(
              AppLocalizations.of(context)?.vouchBadgeRequirementNotice ??
                  'Get 5 vouches from verified members to earn the "Community Trusted" badge.',
              style: TextStyle(
                fontSize: AppTypography.labelMedium,
                color: theme.colorScheme.onSurfaceVariant,
                fontStyle: FontStyle.italic,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildStatItem(
    BuildContext context, {
    required String count,
    required String label,
    required IconData icon,
  }) {
    final theme = Theme.of(context);
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppTheme.primaryLight.withValues(alpha: AppColors.opacity10),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: AppTheme.primaryLight, size: 16),
        ),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              count,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: AppTypography.bold,
              ),
            ),
            Text(
              label,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
