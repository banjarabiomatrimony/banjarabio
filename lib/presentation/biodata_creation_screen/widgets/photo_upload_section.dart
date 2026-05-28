import 'dart:io' as io;
import 'package:banjarabio/l10n/app_localizations.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:sizer/sizer.dart';
import 'package:banjarabio/services/photo_picker_service.dart';

/// Robust photo upload section with crash-resistant processing
/// Uses isolate-based compression via PhotoPickerService
class PhotoUploadSection extends StatefulWidget {
  final PhotoPickerService? photoPickerService;
  final List<String> photos;
  final String gender;
  final Function(List<String>) onPhotosUpdate;

  const PhotoUploadSection({
    super.key,
    this.photoPickerService,
    required this.photos,
    required this.gender,
    required this.onPhotosUpdate,
    this.isPremium = false,
    this.isAdminEdit = false,
  });

  final bool isPremium;
  final bool isAdminEdit;

  @override
  State<PhotoUploadSection> createState() => _PhotoUploadSectionState();
}

class _PhotoUploadSectionState extends State<PhotoUploadSection> {
  late final PhotoPickerService _photoService;
  final int _freePhotoLimit = 1;
  final int _premiumPhotoLimit = 5;
  bool get _isPremiumUser => widget.isPremium;

  bool _isProcessing = false;
  String? _processingError;
  String _processingStatus = '';

  // Store photos locally to prevent parent rebuilds
  late List<String> _localPhotos;

  @override
  void initState() {
    super.initState();
    _photoService = widget.photoPickerService ?? PhotoPickerService();
    _localPhotos = List<String>.from(widget.photos);

    // Clean up old temp files on init
    _photoService.cleanupAllTempFiles();

    // Trigger initial validation update to sync parent state
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) widget.onPhotosUpdate(_localPhotos);
    });
  }

  @override
  void didUpdateWidget(covariant PhotoUploadSection oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Sync local photos if parent list changes (e.g. from population)
    if (!listEquals(widget.photos, oldWidget.photos)) {
      setState(() {
        _localPhotos = List<String>.from(widget.photos);
      });
    }
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> _pickImage(ImageSource source) async {
    if (_isProcessing) return;

    setState(() {
      _isProcessing = true;
      _processingError = null;
      _processingStatus = AppLocalizations.of(context)?.processingStatusPreparing ?? 'Preparing...';
    });

    try {
      final maxPhotos = widget.isAdminEdit ? _premiumPhotoLimit : (_isPremiumUser ? _premiumPhotoLimit : _freePhotoLimit);
      if (_localPhotos.length >= maxPhotos) {
        if (mounted) _showUpgradeDialog();
        return;
      }

      setState(() {
        _processingStatus = AppLocalizations.of(context)?.processingStatusSelecting ?? 'Selecting image...';
      });

      // Use the PhotoPickerService for robust processing
      final PhotoPickResult result;
      if (source == ImageSource.camera) {
        result = await _photoService.pickFromCamera();
      } else {
        result = await _photoService.pickFromGallery();
      }

      if (!result.isSuccess) {
        if (result.error != null && result.error != 'No image selected') {
          throw Exception(result.error);
        }
        // User cancelled - not an error
        return;
      }

      setState(() {
        _processingStatus = AppLocalizations.of(context)?.processingStatusCompressing ?? 'Compressing...';
      });

      // Log compression results
      if (result.originalSizeKB != null && result.compressedSizeKB != null) {
        debugPrint(
          'PhotoUploadSection: Compressed from ${result.originalSizeKB}KB '
          'to ${result.compressedSizeKB}KB',
        );
      }

      // Add the processed photo
      await _addPhotoToList(result.filePath!);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              result.compressedSizeKB != null
                  ? AppLocalizations.of(context)?.photoAddedWithKb(result.compressedSizeKB.toString()) ?? 'Photo added (${result.compressedSizeKB}KB)'
                  : AppLocalizations.of(context)?.photoAdded ?? 'Photo added successfully',
            ),
            backgroundColor: Theme.of(context).colorScheme.primary,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      debugPrint('PhotoUploadSection: Error in _pickImage: $e');
      setState(() {
        _processingError = AppLocalizations.of(context)?.failedToProcessImage ?? 'Failed to process image. Please try again.';
      });

      if (mounted) {
        final errorMessage = e.toString().replaceAll('Exception: ', '');
        final isPermissionError = errorMessage.toLowerCase().contains(
          'permission',
        );

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              isPermissionError
                  ? AppLocalizations.of(context)?.permissionDeniedSettings ?? 'Permission denied. Please enable access in Settings.'
                  : 'Error: $errorMessage',
            ),
            backgroundColor: Theme.of(context).colorScheme.error,
            action: isPermissionError
                ? SnackBarAction(
                    label: AppLocalizations.of(context)?.openSettings ?? 'Open Settings',
                    textColor: Colors.white,
                    onPressed: () => openAppSettings(),
                  )
                : null,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isProcessing = false;
          _processingStatus = '';
        });
      }
    }
  }

  Future<void> _addPhotoToList(String filePath) async {
    // Update local list first
    _localPhotos = List<String>.from(_localPhotos)..add(filePath);

    // Small delay before notifying parent to prevent rapid rebuilds
    await Future.delayed(const Duration(milliseconds: 500));

    if (mounted) {
      // Update local state
      setState(() {});

      // Notify parent
      widget.onPhotosUpdate(_localPhotos);
    }
  }

  void _removePhoto(int index) async {
    try {
      final photoPath = _localPhotos[index];
      _localPhotos = List<String>.from(_localPhotos)..removeAt(index);
      setState(() {});

      widget.onPhotosUpdate(_localPhotos);

      // Clean up file if it's a local temp file
      if (!kIsWeb &&
          !photoPath.startsWith('http') &&
          (photoPath.contains('compressed_') || photoPath.contains('temp'))) {
        try {
          final file = io.File(photoPath);
          if (file.existsSync()) {
            file.deleteSync();
          }
        } catch (e) {
          debugPrint('Could not delete removed photo file: $e');
        }
      }
    } catch (e) {
      debugPrint('Error removing photo: $e');
    }
  }

  void _showUpgradeDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(AppLocalizations.of(context)?.upgradeToPremium ?? 'Upgrade to Premium'),
        content: Text(AppLocalizations.of(context)?.freeUsersCanUpload1PhotoUpgradeToUploadU ?? 'Free users can upload 1 photo. Upgrade to upload up to 5 photos.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(AppLocalizations.of(context)?.cancel ?? 'Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              // Navigate to subscription screen
            },
            child: Text(AppLocalizations.of(context)?.upgrade ?? 'Upgrade'),
          ),
        ],
      ),
    );
  }

  void _showImageSourceDialog() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              margin: const EdgeInsets.only(top: 12),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Theme.of(context).dividerColor,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: Text(AppLocalizations.of(context)?.takePhoto ?? 'Take Photo'),
              subtitle: Text(AppLocalizations.of(context)?.useCameraToCapture ?? 'Use camera to capture'),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.camera);
              },
            ),
            const Divider(height: 1),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: Text(AppLocalizations.of(context)?.chooseFromGallery ?? 'Choose from Gallery'),
              subtitle: Text(AppLocalizations.of(context)?.selectFromYourPhotos ?? 'Select from your photos'),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.gallery);
              },
            ),
            SizedBox(height: 2.h),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final maxPhotos = _isPremiumUser ? _premiumPhotoLimit : _freePhotoLimit;

    return SingleChildScrollView(
      padding: EdgeInsets.all(4.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(AppLocalizations.of(context)?.profilePhotos ?? 'Profile Photos',
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 0.5.h),
          Text(
            AppLocalizations.of(context)?.addClearPhotos(maxPhotos.toString()) ?? 'Add clear photos ($maxPhotos max)',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          SizedBox(height: 2.h),

          // Processing indicator
          if (_isProcessing) ...[
            _buildProcessingIndicator(theme),
            SizedBox(height: 2.h),
          ],

          // Error message
          if (_processingError != null) ...[
            Container(
              padding: EdgeInsets.all(3.w),
              decoration: BoxDecoration(
                color: theme.colorScheme.errorContainer,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(Icons.error_outline, color: theme.colorScheme.error),
                  SizedBox(width: 2.w),
                  Expanded(
                    child: Text(
                      _processingError!,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onErrorContainer,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, size: 18),
                    onPressed: () => setState(() => _processingError = null),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ],
              ),
            ),
            SizedBox(height: 2.h),
          ],

          // Photo grid
          GridView.builder(
            key: ValueKey('PhotoGrid_${_localPhotos.length}'),
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: 2.w,
              mainAxisSpacing: 2.w,
              childAspectRatio: 0.85,
            ),
            itemCount:
                _localPhotos.length +
                (_localPhotos.length < maxPhotos && !_isProcessing ? 1 : 0),
            itemBuilder: (context, index) {
              if (index < _localPhotos.length) {
                return _buildPhotoThumbnail(_localPhotos[index], index, theme);
              } else {
                return _buildAddButton(theme);
              }
            },
          ),

          // Empty state
          if (_localPhotos.isEmpty && !_isProcessing) ...[
            SizedBox(height: 5.h),
            Center(
              child: Column(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: Stack(
                      children: [
                        Image.asset(
                          widget.gender == 'Female' ? 'assets/images/gender_female.png' : 'assets/images/gender_male.png',
                          width: 20.w,
                          height: 20.w,
                          fit: BoxFit.cover,
                        ),
                        Container(
                          width: 20.w,
                          height: 20.w,
                          decoration: BoxDecoration(
                            color: Colors.black.withValues(alpha: 0.1),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 2.h),
                  Text(AppLocalizations.of(context)?.noPhotosAdded ?? 'No photos added',
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  SizedBox(height: 1.h),
                  Text(AppLocalizations.of(context)?.tapTheButtonToAddAPhoto ?? 'Tap the + button to add a photo',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.7),
                    ),
                  ),
                ],
              ),
            ),
          ],

          // Info box
          SizedBox(height: 3.h),
          Container(
            padding: EdgeInsets.all(3.w),
            decoration: BoxDecoration(
              color: theme.colorScheme.primaryContainer.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: theme.colorScheme.primary.withValues(alpha: 0.3),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.info_outline,
                  color: theme.colorScheme.primary,
                  size: 20,
                ),
                SizedBox(width: 2.w),
                Expanded(
                  child: Text(AppLocalizations.of(context)?.photosAreAutomaticallyCompressedToEnsure ?? 'Photos are automatically compressed to ensure fast upload',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.primary,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProcessingIndicator(ThemeData theme) {
    return Container(
      padding: EdgeInsets.all(3.w),
      decoration: BoxDecoration(
        color: theme.colorScheme.primaryContainer.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          const SizedBox(
            width: 24,
            height: 24,
            child: CircularProgressIndicator(strokeWidth: 2.5),
          ),
          SizedBox(width: 3.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(AppLocalizations.of(context)?.processingImage ?? 'Processing Image',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: 0.5.h),
                Text(
                  _processingStatus.isNotEmpty
                      ? _processingStatus
                      : AppLocalizations.of(context)?.processingStatusCompressing ?? 'Compressing...',
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

  Widget _buildPhotoThumbnail(String photoPath, int index, ThemeData theme) {
    return Stack(
      children: [
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: theme.colorScheme.outline.withValues(alpha: 0.2),
            ),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: _buildImage(photoPath),
          ),
        ),
        // Delete button
        Positioned(
          top: 4,
          right: 4,
          child: GestureDetector(
            onTap: () => _removePhoto(index),
            child: Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                color: theme.colorScheme.error,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.3),
                    blurRadius: 4,
                  ),
                ],
              ),
              child: Icon(
                Icons.close,
                size: 16,
                color: theme.colorScheme.onError,
              ),
            ),
          ),
        ),
        // Main photo badge
        if (index == 0)
          Positioned(
            bottom: 4,
            left: 4,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: theme.colorScheme.primary,
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(AppLocalizations.of(context)?.main ?? 'Main',
                style: theme.textTheme.labelSmall?.copyWith(
                  color: theme.colorScheme.onPrimary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildImage(String photoPath) {
    if (kIsWeb || photoPath.startsWith('http')) {
      return CachedNetworkImage(
        imageUrl: photoPath,
        width: double.infinity,
        height: double.infinity,
        fit: BoxFit.cover,
        memCacheWidth: 200,
        memCacheHeight: 200,
        errorWidget: (context, url, error) => _buildPlaceholder(),
        placeholder: (context, url) => const Center(
          child: SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
        ),
      );
    }

    return Image.file(
      io.File(photoPath),
      width: double.infinity,
      height: double.infinity,
      fit: BoxFit.cover,
      cacheWidth: 200,
      cacheHeight: 200,
      errorBuilder: (context, error, stackTrace) => _buildPlaceholder(),
    );
  }

  Widget _buildPlaceholder() {
    return Container(
      color: Colors.grey.shade200,
      child: Center(
        child: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Image.asset(
            widget.gender == 'Female' ? 'assets/images/gender_female.png' : 'assets/images/gender_male.png',
            width: 40,
            height: 40,
            fit: BoxFit.cover,
          ),
        ),
      ),
    );
  }

  Widget _buildAddButton(ThemeData theme) {
    return GestureDetector(
      onTap: _isProcessing ? null : _showImageSourceDialog,
      child: Container(
        decoration: BoxDecoration(
          color: theme.colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: theme.colorScheme.outline.withValues(alpha: 0.3),
            width: 2,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.add_a_photo, size: 28, color: theme.colorScheme.primary),
            SizedBox(height: 1.h),
            Text(AppLocalizations.of(context)?.addPhoto ?? 'Add Photo',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.primary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
