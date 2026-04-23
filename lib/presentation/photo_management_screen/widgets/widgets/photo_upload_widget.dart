import 'package:flutter/material.dart';
import 'package:banjarabio/l10n/app_localizations.dart';
import 'package:sizer/sizer.dart';

import 'package:banjarabio/core/app_export.dart';

class PhotoUploadWidget extends StatelessWidget {
  final VoidCallback onAddPhoto;
  final bool isPremium;

  const PhotoUploadWidget({
    super.key,
    required this.onAddPhoto,
    required this.isPremium,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: SingleChildScrollView(
        padding: EdgeInsets.all(6.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 60.w,
              height: 60.w,
              decoration: BoxDecoration(
                color: theme.colorScheme.primaryContainer.withValues(
                  alpha: 0.2,
                ),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: CustomIconWidget(
                  iconName: 'add_photo_alternate',
                  color: theme.colorScheme.primary,
                  size: 64,
                ),
              ),
            ),
            SizedBox(height: 4.h),
            Text(AppLocalizations.of(context)?.noPhotosYet ?? 'No Photos Yet',
              style: theme.textTheme.headlineSmall,
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 2.h),
            Text(AppLocalizations.of(context)?.addPhotosToYourBiodataProfileToIncreaseV ?? 'Add photos to your biodata profile to increase visibility and trust',
              style: theme.textTheme.bodyLarge?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 4.h),
            ElevatedButton.icon(
              onPressed: onAddPhoto,
              icon: CustomIconWidget(
                iconName: 'add_a_photo',
                color: theme.colorScheme.onPrimary,
              ),
              label: Text(AppLocalizations.of(context)?.addYourFirstPhoto ?? 'Add Your First Photo'),
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 2.h),
              ),
            ),
            SizedBox(height: 3.h),
            Container(
              padding: EdgeInsets.all(4.w),
              decoration: BoxDecoration(
                color: theme.colorScheme.surface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: theme.dividerColor),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      CustomIconWidget(
                        iconName: 'info_outline',
                        color: theme.colorScheme.primary,
                        size: 20,
                      ),
                      SizedBox(width: 2.w),
                      Text(AppLocalizations.of(context)?.photoGuidelines ?? 'Photo Guidelines',
                        style: theme.textTheme.titleSmall?.copyWith(
                          color: theme.colorScheme.primary,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 2.h),
                  _buildGuidelineItem(
                    context,
                    AppLocalizations.of(context)?.clearWellLitPhotos ?? 'Clear, well-lit photos with visible face',
                  ),
                  _buildGuidelineItem(
                    context,
                    AppLocalizations.of(context)?.traditionalFormalAttire ?? 'Traditional or formal attire preferred',
                  ),
                  _buildGuidelineItem(
                    context,
                    AppLocalizations.of(context)?.naturalPosesRespectful ?? 'Respectful poses maintaining cultural values',
                  ),
                  _buildGuidelineItem(
                    context,
                    AppLocalizations.of(context)?.recentPhotosSixMonths ?? 'Recent photos (within last 6 months)',
                  ),
                  if (!isPremium) ...[
                    SizedBox(height: 2.h),
                    Container(
                      padding: EdgeInsets.all(3.w),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primaryContainer.withValues(
                          alpha: 0.3,
                        ),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          CustomIconWidget(
                            iconName: 'workspace_premium',
                            color: theme.colorScheme.primary,
                            size: 20,
                          ),
                          SizedBox(width: 2.w),
                          Expanded(
                            child: Text(AppLocalizations.of(context)?.free1PhotonpremiumUpTo6Photos ?? 'Free: 1 photo\nPremium: Up to 6 photos',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.colorScheme.primary,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGuidelineItem(BuildContext context, String text) {
    final theme = Theme.of(context);

    return Padding(
      padding: EdgeInsets.only(bottom: 1.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            margin: EdgeInsets.only(top: 0.5.h),
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              color: theme.colorScheme.primary,
              shape: BoxShape.circle,
            ),
          ),
          SizedBox(width: 2.w),
          Expanded(child: Text(text, style: theme.textTheme.bodyMedium)),
        ],
      ),
    );
  }
}
