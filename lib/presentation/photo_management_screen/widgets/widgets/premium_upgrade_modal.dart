import 'package:flutter/material.dart';
import 'package:banjarabio/l10n/app_localizations.dart';
import 'package:sizer/sizer.dart';

import 'package:banjarabio/core/app_export.dart';

class PremiumUpgradeModal extends StatelessWidget {
  final VoidCallback onUpgrade;

  const PremiumUpgradeModal({super.key, required this.onUpgrade});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(6.w),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: EdgeInsets.all(4.w),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primaryContainer.withValues(
                    alpha: 0.3,
                  ),
                  shape: BoxShape.circle,
                ),
                child: CustomIconWidget(
                  iconName: 'workspace_premium',
                  color: theme.colorScheme.primary,
                  size: 48,
                ),
              ),
              SizedBox(height: 3.h),
              Text(AppLocalizations.of(context)?.upgradeToPremium ?? 'Upgrade to Premium',
                style: theme.textTheme.headlineSmall,
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 2.h),
              Text(AppLocalizations.of(context)?.unlockPremiumFeaturesToEnhanceYourBiodat ?? 'Unlock premium features to enhance your biodata profile',
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 3.h),
              _buildFeatureItem(
                context,
                'photo_library',
                'Upload up to 6 photos',
                'Showcase yourself better with multiple photos',
              ),
              _buildFeatureItem(
                context,
                'filter_alt',
                'Advanced filters',
                'Find matches with detailed search criteria',
              ),
              _buildFeatureItem(
                context,
                'verified',
                'Profile verification badge',
                'Stand out with verified profile status',
              ),
              _buildFeatureItem(
                context,
                'visibility',
                'Enhanced visibility',
                'Get more profile views and matches',
              ),
              SizedBox(height: 3.h),
              Container(
                padding: EdgeInsets.all(4.w),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primaryContainer.withValues(
                    alpha: 0.2,
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(AppLocalizations.of(context)?.emptyStr ?? '₹',
                          style: theme.textTheme.titleLarge?.copyWith(
                            color: theme.colorScheme.primary,
                          ),
                        ),
                        Text(AppLocalizations.of(context)?.num499 ?? '499',
                          style: theme.textTheme.displaySmall?.copyWith(
                            color: theme.colorScheme.primary,
                            fontWeight: AppTypography.bold,
                          ),
                        ),
                        Text(AppLocalizations.of(context)?.month ?? '/month',
                          style: theme.textTheme.bodyLarge?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 1.h),
                    Text(AppLocalizations.of(context)?.cancelAnytime ?? 'Cancel anytime',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 3.h),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: onUpgrade,
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(vertical: 2.h),
                  ),
                  child: Text(AppLocalizations.of(context)?.upgradeNow ?? 'Upgrade Now'),
                ),
              ),
              SizedBox(height: 2.h),
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(AppLocalizations.of(context)?.maybeLater ?? 'Maybe Later',
                  style: TextStyle(color: theme.colorScheme.onSurfaceVariant),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFeatureItem(
    BuildContext context,
    String iconName,
    String title,
    String description,
  ) {
    final theme = Theme.of(context);

    return Padding(
      padding: EdgeInsets.only(bottom: 2.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.all(2.w),
            decoration: BoxDecoration(
              color: theme.colorScheme.primaryContainer.withValues(alpha: AppColors.opacity30),
              borderRadius: BorderRadius.circular(8),
            ),
            child: CustomIconWidget(
              iconName: iconName,
              color: theme.colorScheme.primary,
            ),
          ),
          SizedBox(width: 3.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: theme.textTheme.titleSmall),
                SizedBox(height: 0.5.h),
                Text(
                  description,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
