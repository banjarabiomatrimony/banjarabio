import 'package:flutter/material.dart';
import 'package:banjarabio/l10n/app_localizations.dart';
import 'package:sizer/sizer.dart';

import 'package:banjarabio/core/app_export.dart';

class CulturalGuidelinesWidget extends StatelessWidget {
  const CulturalGuidelinesWidget({super.key});

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
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(2.w),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primaryContainer.withValues(
                        alpha: 0.3,
                      ),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: CustomIconWidget(
                      iconName: 'info',
                      color: theme.colorScheme.primary,
                    ),
                  ),
                  SizedBox(width: 3.w),
                  Expanded(
                    child: Text(AppLocalizations.of(context)?.photoGuidelines ?? 'Photo Guidelines',
                      style: theme.textTheme.titleLarge,
                    ),
                  ),
                  IconButton(
                    icon: CustomIconWidget(
                      iconName: 'close',
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              SizedBox(height: 3.h),
              _buildSection(context, AppLocalizations.of(context)?.recommendedPhotos ?? 'Recommended Photos', 'check_circle', [
                AppLocalizations.of(context)?.clearWellLitPhotos ?? 'Clear, well-lit photos showing your face clearly',
                AppLocalizations.of(context)?.traditionalFormalAttire ?? 'Traditional or formal attire (saree, salwar kameez, kurta)',
                AppLocalizations.of(context)?.recentPhotosSixMonths ?? 'Recent photos taken within the last 6 months',
                AppLocalizations.of(context)?.naturalPosesRespectful ?? 'Natural poses with respectful expressions',
                AppLocalizations.of(context)?.professionalFamilyEventPhotos ?? 'Professional or family event photos',
                AppLocalizations.of(context)?.photosReflectPersonality ?? 'Photos that reflect your personality and values',
              ], true),
              SizedBox(height: 3.h),
              _buildSection(context, AppLocalizations.of(context)?.photosToAvoid ?? 'Photos to Avoid', 'cancel', [
                AppLocalizations.of(context)?.blurryLowQualityImages ?? 'Blurry, dark, or low-quality images',
                AppLocalizations.of(context)?.groupPhotosNotVisible ?? 'Group photos where you are not clearly visible',
                AppLocalizations.of(context)?.inappropriateBackgrounds ?? 'Photos with inappropriate backgrounds',
                AppLocalizations.of(context)?.heavilyFilteredEdited ?? 'Heavily filtered or edited photos',
                AppLocalizations.of(context)?.socialMediaTextOverlays ?? 'Photos from social media with text overlays',
                AppLocalizations.of(context)?.notRepresentAppearance ?? 'Photos that do not represent your current appearance',
              ], false),
              SizedBox(height: 3.h),
              Container(
                padding: EdgeInsets.all(4.w),
                decoration: BoxDecoration(
                  color: theme.colorScheme.secondaryContainer.withValues(
                    alpha: 0.3,
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        CustomIconWidget(
                          iconName: 'lightbulb',
                          color: theme.colorScheme.secondary,
                          size: 20,
                        ),
                        SizedBox(width: 2.w),
                        Text(AppLocalizations.of(context)?.proTips ?? 'Pro Tips',
                          style: theme.textTheme.titleSmall?.copyWith(
                            color: theme.colorScheme.secondary,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 2.h),
                    _buildTipItem(
                      context,
                      AppLocalizations.of(context)?.useNaturalLightingTip ?? 'Use natural lighting for best results',
                    ),
                    _buildTipItem(
                      context,
                      AppLocalizations.of(context)?.smileNaturallyTip ?? 'Smile naturally to appear approachable',
                    ),
                    _buildTipItem(
                      context,
                      AppLocalizations.of(context)?.differentSettingsTip ?? 'Include photos in different settings (formal, casual',
                    ),
                    _buildTipItem(
                      context,
                      AppLocalizations.of(context)?.askFamilySuggestionsTip ?? 'Ask family members for photo suggestions',
                    ),
                  ],
                ),
              ),
              SizedBox(height: 3.h),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(AppLocalizations.of(context)?.gotIt ?? 'Got It'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSection(
    BuildContext context,
    String title,
    String iconName,
    List<String> items,
    bool isPositive,
  ) {
    final theme = Theme.of(context);
    final color = isPositive
        ? theme.colorScheme.primary
        : theme.colorScheme.error;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            CustomIconWidget(iconName: iconName, color: color, size: 20),
            SizedBox(width: 2.w),
            Text(
              title,
              style: theme.textTheme.titleMedium?.copyWith(color: color),
            ),
          ],
        ),
        SizedBox(height: 2.h),
        ...items.map((item) => _buildGuidelineItem(context, item, color)),
      ],
    );
  }

  Widget _buildGuidelineItem(BuildContext context, String text, Color color) {
    final theme = Theme.of(context);

    return Padding(
      padding: EdgeInsets.only(bottom: 1.5.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            margin: EdgeInsets.only(top: 0.5.h),
            width: 6,
            height: 6,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          SizedBox(width: 3.w),
          Expanded(child: Text(text, style: theme.textTheme.bodyMedium)),
        ],
      ),
    );
  }

  Widget _buildTipItem(BuildContext context, String text) {
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
              color: theme.colorScheme.secondary,
              shape: BoxShape.circle,
            ),
          ),
          SizedBox(width: 2.w),
          Expanded(child: Text(text, style: theme.textTheme.bodySmall)),
        ],
      ),
    );
  }
}
