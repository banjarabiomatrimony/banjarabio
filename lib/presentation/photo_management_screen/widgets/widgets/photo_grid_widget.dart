import 'package:flutter/material.dart';
import 'package:banjarabio/l10n/app_localizations.dart';
import 'package:sizer/sizer.dart';

import 'package:banjarabio/core/app_export.dart';

class PhotoGridWidget extends StatelessWidget {
  final List<Map<String, dynamic>> photos;
  final bool isSelectionMode;
  final Function(Map<String, dynamic>) onPhotoTap;
  final Function(Map<String, dynamic>) onPhotoLongPress;
  final VoidCallback onAddPhoto;
  final bool isPremium;
  final int maxPhotos;

  const PhotoGridWidget({
    super.key,
    required this.photos,
    required this.isSelectionMode,
    required this.onPhotoTap,
    required this.onPhotoLongPress,
    required this.onAddPhoto,
    required this.isPremium,
    required this.maxPhotos,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SingleChildScrollView(
      padding: EdgeInsets.all(4.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (photos.any((p) => p['isPrimary'] == true)) ...[
            Text(AppLocalizations.of(context)?.primaryPhoto ?? 'Primary Photo', style: theme.textTheme.titleMedium),
            SizedBox(height: 2.h),
            _buildPrimaryPhoto(context),
            SizedBox(height: 3.h),
          ],
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                AppLocalizations.of(context)?.allPhotosCount(photos.length, maxPhotos) ?? 'All Photos (${photos.length}/$maxPhotos)',
                style: theme.textTheme.titleMedium,
              ),
              if (isSelectionMode)
                Text(
                  AppLocalizations.of(context)?.photosSelectedCount(photos.where((p) => p['isSelected'] == true).length) ?? '${photos.where((p) => p["isSelected"] == true).length} selected',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.primary,
                  ),
                ),
            ],
          ),
          SizedBox(height: 2.h),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: 2.w,
              mainAxisSpacing: 2.w,
              childAspectRatio: 0.75,
            ),
            itemCount: photos.length + (photos.length < maxPhotos ? 1 : 0),
            itemBuilder: (context, index) {
              if (index == photos.length) {
                return RepaintBoundary(child: _buildAddPhotoCard(context));
              }
              return RepaintBoundary(
                child: _buildPhotoCard(context, photos[index]),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildPrimaryPhoto(BuildContext context) {
    final theme = Theme.of(context);
    final primaryPhoto = photos.firstWhere((p) => p['isPrimary'] == true);

    return GestureDetector(
      onTap: () => onPhotoTap(primaryPhoto),
      onLongPress: () => onPhotoLongPress(primaryPhoto),
      child: Container(
        width: double.infinity,
        height: 40.h,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: theme.shadowColor.withValues(alpha: AppColors.opacity10),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Stack(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: CustomImageWidget(
                imageUrl: primaryPhoto['url'],
                width: double.infinity,
                height: 40.h,
                fit: BoxFit.cover,
                semanticLabel: primaryPhoto['semanticLabel'],
              ),
            ),
            if (primaryPhoto['uploadProgress'] < 1.0)
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: AppColors.opacity50),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        CircularProgressIndicator(
                          value: primaryPhoto['uploadProgress'],
                          color: theme.colorScheme.primary,
                        ),
                        SizedBox(height: 1.h),
                        Text(
                          '${(primaryPhoto["uploadProgress"] * 100).toInt()}%',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            Positioned(
              top: 2.w,
              left: 2.w,
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 1.h),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CustomIconWidget(
                      iconName: 'star',
                      color: theme.colorScheme.onPrimary,
                      size: 16,
                    ),
                    SizedBox(width: 1.w),
                    Text(AppLocalizations.of(context)?.primary ?? 'Primary',
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: theme.colorScheme.onPrimary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            if (primaryPhoto['privacyLevel'] == 'family')
              Positioned(
                top: 2.w,
                right: 2.w,
                child: Container(
                  padding: EdgeInsets.all(1.w),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: AppColors.opacity60),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const CustomIconWidget(
                    iconName: 'visibility_off',
                    color: Colors.white,
                    size: 20,
                  ),
                ),
              ),
            if (isSelectionMode)
              Positioned(
                bottom: 2.w,
                right: 2.w,
                child: Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    color: primaryPhoto['isSelected'] == true
                        ? theme.colorScheme.primary
                        : Colors.white,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: theme.colorScheme.primary,
                      width: 2,
                    ),
                  ),
                  child: primaryPhoto['isSelected'] == true
                      ? CustomIconWidget(
                          iconName: 'check',
                          color: theme.colorScheme.onPrimary,
                          size: 16,
                        )
                      : null,
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildPhotoCard(BuildContext context, Map<String, dynamic> photo) {
    final theme = Theme.of(context);

    return GestureDetector(
      onTap: () => onPhotoTap(photo),
      onLongPress: () => onPhotoLongPress(photo),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          boxShadow: [
            BoxShadow(
              color: theme.shadowColor.withValues(alpha: AppColors.opacity10),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Stack(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: CustomImageWidget(
                imageUrl: photo['url'],
                width: double.infinity,
                height: double.infinity,
                fit: BoxFit.cover,
                semanticLabel: photo['semanticLabel'],
              ),
            ),
            if (photo['uploadProgress'] < 1.0)
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: AppColors.opacity50),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Center(
                    child: CircularProgressIndicator(
                      value: photo['uploadProgress'],
                      color: theme.colorScheme.primary,
                      strokeWidth: 2,
                    ),
                  ),
                ),
              ),
            if (photo['isPrimary'] == true)
              Positioned(
                top: 1.w,
                left: 1.w,
                child: Container(
                  padding: EdgeInsets.all(1.w),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: CustomIconWidget(
                    iconName: 'star',
                    color: theme.colorScheme.onPrimary,
                    size: 12,
                  ),
                ),
              ),
            if (photo['privacyLevel'] == 'family')
              Positioned(
                top: 1.w,
                right: 1.w,
                child: Container(
                  padding: EdgeInsets.all(1.w),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: AppColors.opacity60),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: const CustomIconWidget(
                    iconName: 'visibility_off',
                    color: Colors.white,
                    size: 12,
                  ),
                ),
              ),
            if (isSelectionMode)
              Positioned(
                bottom: 1.w,
                right: 1.w,
                child: Container(
                  width: 20,
                  height: 20,
                  decoration: BoxDecoration(
                    color: photo['isSelected'] == true
                        ? theme.colorScheme.primary
                        : Colors.white,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: theme.colorScheme.primary,
                      width: 2,
                    ),
                  ),
                  child: photo['isSelected'] == true
                      ? CustomIconWidget(
                          iconName: 'check',
                          color: theme.colorScheme.onPrimary,
                          size: 12,
                        )
                      : null,
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildAddPhotoCard(BuildContext context) {
    final theme = Theme.of(context);

    return GestureDetector(
      onTap: onAddPhoto,
      child: Container(
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: theme.dividerColor,
            width: 2,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CustomIconWidget(
              iconName: 'add_photo_alternate',
              color: theme.colorScheme.primary,
              size: 32,
            ),
            SizedBox(height: 1.h),
            Text(AppLocalizations.of(context)?.addPhoto ?? 'Add Photo',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.primary,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
