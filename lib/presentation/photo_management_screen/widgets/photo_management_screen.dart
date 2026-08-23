// ignore_for_file: deprecated_member_use

import 'dart:io';
import 'package:banjarabio/core/models/profile_model.dart';
import 'package:banjarabio/l10n/app_localizations.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:sizer/sizer.dart';

import 'package:banjarabio/core/app_export.dart';
import 'package:banjarabio/services/photo_picker_service.dart';
import 'package:banjarabio/core/models/subscription_config.dart';
import 'package:banjarabio/core/repositories/subscription_repository.dart';
import 'package:banjarabio/core/repositories/usage_repository.dart';
import 'package:banjarabio/widgets/custom_app_bar.dart';
import 'package:banjarabio/widgets/upgrade_dialog.dart';
import 'package:banjarabio/presentation/photo_management_screen/widgets/widgets/cultural_guidelines_widget.dart';
import 'package:banjarabio/presentation/photo_management_screen/widgets/widgets/photo_grid_widget.dart';
import 'package:banjarabio/presentation/photo_management_screen/widgets/widgets/photo_upload_widget.dart';
import 'package:banjarabio/core/repositories/photo_repository.dart';
import 'package:banjarabio/core/repositories/profile_repository.dart';
import 'package:banjarabio/core/models/subscription_model.dart';
import 'package:banjarabio/core/services/app_logger.dart';

class PhotoManagementScreen extends StatefulWidget {
  const PhotoManagementScreen({super.key});

  @override
  State<PhotoManagementScreen> createState() => _PhotoManagementScreenState();
}

class _PhotoManagementScreenState extends State<PhotoManagementScreen> {
  final ImagePicker _imagePicker = ImagePicker();
  final PhotoPickerService _photoPickerService = PhotoPickerService();
  bool _isSelectionMode = false;
  bool _isPremiumUser = false;
  bool _isImageProcessing = false;

  final Set<String> _selectedPhotos = {};

  final UsageRepository _usageRepository = UsageRepository();
  final SubscriptionRepository _subscriptionRepository =
      SubscriptionRepository();
  final PhotoRepository _photoRepository = PhotoRepository();
  final ProfileRepository _profileRepository = ProfileRepository();

  String? _profileId;
  final List<Map<String, dynamic>> _photos = [];

  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }

  Future<void> _loadInitialData() async {
    await Future.wait([
      _loadSubscriptionStatus(),
      _loadProfileAndPhotos(),
    ]);
  }

  Future<void> _loadProfileAndPhotos() async {
    final result = await _profileRepository.getOwnProfile();
    if (!mounted) return;
    result.fold(
      onSuccess: (profile) async {
        if (profile != null) {
          _profileId = profile.id;
          await _loadPhotos();
        }
      },
      onFailure: (error) {
        _showErrorSnackBar(AppLocalizations.of(context)?.failedToLoadProfileInformation ?? 'Failed to load profile information');
      },
    );
  }

  Future<void> _loadPhotos() async {
    if (_profileId == null) return;

    final result = await _photoRepository.getPhotos(_profileId!);
    if (mounted) {
      result.fold(
        onSuccess: (photos) {
          setState(() {
            _photos.clear();
            _photos.addAll(
              photos.map(
                (p) => {
                  'id': p.id,
                  'url': p.publicUrl,
                  'storagePath': p.storagePath,
                  'semanticLabel': p.semanticLabel ?? '',
                  'isPrimary': p.isPrimary,
                  'isSelected': false,
                  'uploadProgress': 1.0,
                  'privacyLevel': 'public',
                  'uploadedAt': p.uploadedAt,
                },
              ),
            );
          });
        },
        onFailure: (error) {
          _showErrorSnackBar(AppLocalizations.of(context)?.failedToLoadPhotosError(error.toString()) ?? 'Failed to load photos: $error');
        },
      );
    }
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> _loadSubscriptionStatus() async {
    final result = await _subscriptionRepository.isPremium();
    if (mounted) {
      result.fold(
        onSuccess: (isPremium) {
          setState(() {
            _isPremiumUser = isPremium;
          });
        },
        onFailure: (error) {
          AppLogger.error('PhotoManagementScreen', 'Error loading subscription status: $error');
        },
      );
    }
  }



  Future<bool> _requestCameraPermission() async {
    if (kIsWeb) return true;
    final status = await Permission.camera.request();
    return status.isGranted;
  }

  Future<bool> _requestStoragePermission() async {
    if (kIsWeb) return true;
    final status = await Permission.storage.request();
    return status.isGranted;
  }

  void _showAddPhotoOptions() {
    final theme = Theme.of(context);

    showModalBottomSheet(
      context: context,
      backgroundColor: theme.colorScheme.surface,
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
                color: theme.dividerColor,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            ListTile(
              leading: CustomIconWidget(
                iconName: 'camera_alt',
                color: theme.colorScheme.primary,
              ),
              title: Text(AppLocalizations.of(context)?.takePhoto ?? 'Take Photo', style: theme.textTheme.bodyLarge),
              onTap: () {
                Navigator.pop(context);
                _capturePhoto();
              },
            ),
            ListTile(
              leading: CustomIconWidget(
                iconName: 'photo_library',
                color: theme.colorScheme.primary,
              ),
              title: Text(AppLocalizations.of(context)?.chooseFromGallery ?? 'Choose from Gallery',
                style: theme.textTheme.bodyLarge,
              ),
              onTap: () {
                Navigator.pop(context);
                _pickFromGallery();
              },
            ),
            ListTile(
              leading: CustomIconWidget(
                iconName: 'info_outline',
                color: theme.colorScheme.secondary,
              ),
              title: Text(AppLocalizations.of(context)?.photoGuidelines ?? 'Photo Guidelines', style: theme.textTheme.bodyLarge),
              onTap: () {
                Navigator.pop(context);
                _showCulturalGuidelines();
              },
            ),
            SizedBox(height: 2.h),
          ],
        ),
      ),
    );
  }

  void _showReplacePhotoPicker(Map<String, dynamic> photo) {
    final theme = Theme.of(context);

    showModalBottomSheet(
      context: context,
      backgroundColor: theme.colorScheme.surface,
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
                color: theme.dividerColor,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            ListTile(
              leading: CustomIconWidget(
                iconName: 'camera_alt',
                color: theme.colorScheme.primary,
              ),
              title: Text(AppLocalizations.of(context)?.takePhoto ?? 'Take Photo', style: theme.textTheme.bodyLarge),
              onTap: () {
                Navigator.pop(context);
                _capturePhoto(replacePhotoData: photo);
              },
            ),
            ListTile(
              leading: CustomIconWidget(
                iconName: 'photo_library',
                color: theme.colorScheme.primary,
              ),
              title: Text(AppLocalizations.of(context)?.chooseFromGallery ?? 'Choose from Gallery',
                style: theme.textTheme.bodyLarge,
              ),
              onTap: () {
                Navigator.pop(context);
                _pickFromGallery(replacePhotoData: photo);
              },
            ),
            SizedBox(height: 2.h),
          ],
        ),
      ),
    );
  }

  Future<void> _capturePhoto({Map<String, dynamic>? replacePhotoData}) async {
    if (_isImageProcessing) return;

    if (!await _requestCameraPermission()) {
      if (mounted) _showPermissionDeniedDialog('Camera');
      return;
    }

    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.camera,
        maxWidth: 1200,
        maxHeight: 1200,
        imageQuality: 80,
        requestFullMetadata: false,
      );

      if (image != null && mounted) {
        await _processCapturedImage(image.path, replacePhotoData: replacePhotoData);
      }
    } catch (e) {
      if (mounted) _showErrorSnackBar(e.toString());
    }
  }

  Future<void> _pickFromGallery({Map<String, dynamic>? replacePhotoData}) async {
    if (_isImageProcessing) return;

    if (!await _requestStoragePermission()) {
      if (mounted) _showPermissionDeniedDialog('Storage');
      return;
    }

    try {
      // Use lower quality settings to reduce memory pressure
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1200, // Reduced from 1920
        maxHeight: 1200, // Reduced from 1920
        imageQuality: 80, // Reduced from 85
        requestFullMetadata: false, // Don't load EXIF - saves memory
      );

      if (image != null && mounted) {
        await _processCapturedImage(image.path, replacePhotoData: replacePhotoData);
      }
    } catch (e) {
      if (mounted) _showErrorSnackBar(e.toString());
    }
  }

  Future<void> _processCapturedImage(String imagePath, {Map<String, dynamic>? replacePhotoData}) async {
    if (_isImageProcessing) return;

    setState(() => _isImageProcessing = true);

    try {
      final croppedFile = await ImageCropper().cropImage(
        sourcePath: imagePath,
        aspectRatio: const CropAspectRatio(ratioX: 3, ratioY: 4),
        uiSettings: [
          AndroidUiSettings(
            toolbarTitle: 'Crop Photo',
            toolbarColor: Theme.of(context).colorScheme.primary,
            toolbarWidgetColor: Theme.of(context).colorScheme.onPrimary,
            initAspectRatio: CropAspectRatioPreset.ratio3x2,
            lockAspectRatio: true,
          ),
          IOSUiSettings(
            title: AppLocalizations.of(context)?.cropPhoto ?? 'Crop Photo',
            aspectRatioLockEnabled: true,
            resetAspectRatioEnabled: false,
          ),
        ],
      );

      if (croppedFile != null && mounted) {
        await _uploadPhoto(croppedFile.path, replacePhotoData: replacePhotoData);
      }
    } catch (e) {
      AppLogger.error('PhotoManagementScreen', 'ImageCropper error: $e');
      if (mounted) _showErrorSnackBar(e.toString());
    } finally {
      if (mounted) {
        setState(() => _isImageProcessing = false);
      } else {
        _isImageProcessing = false;
      }
    }
  }

  Future<void> _uploadPhoto(String imagePath, {Map<String, dynamic>? replacePhotoData}) async {
    if (_profileId == null) {
      _showErrorSnackBar(AppLocalizations.of(context)?.failedToLoadProfileInformation ?? 'Check back after profile creation');
      return;
    }

    // Check photo limits
    final results = await Future.wait([
      _usageRepository.canUploadPhoto(),
      _usageRepository.getRemainingPhotos(),
      _subscriptionRepository.getPlanType(),
    ]);

    final canUploadRes = results[0] as BackendResponse<bool>;
    final remainingRes = results[1] as BackendResponse<int>;
    final planTypeRes = results[2] as BackendResponse<PlanType>;

    // We only fail UI validation if we aren't explicitly replacing a photo.
    if (replacePhotoData == null && (!canUploadRes.isSuccess || canUploadRes.data == false)) {
      if (mounted) {
        UpgradeDialog.showPhotoLimit(
          context,
          remainingRes.isSuccess ? remainingRes.data : 0,
          SubscriptionConfig.getFeatures(
            planTypeRes.isSuccess ? planTypeRes.data : PlanType.free,
          ).photosLimit,
        );
      }
      return;
    }

    setState(() {});

    try {
      String finalImagePath = imagePath;

      // Compress image using PhotoPickerService before upload
      if (!kIsWeb) {
        AppLogger.debug('PhotoManagementScreen', 'PhotoManagementScreen: Compressing image before upload...');
        final compressResult = await _photoPickerService.processImage(
          imagePath,
        );
        if (compressResult.isSuccess && compressResult.filePath != null) {
          finalImagePath = compressResult.filePath!;
          debugPrint(
            'PhotoManagementScreen: Compressed from ${compressResult.originalSizeKB}KB to ${compressResult.compressedSizeKB}KB',
          );
        }
      }

      final File imageFile = File(finalImagePath);
      final BackendResponse<PhotoModel> uploadRes;

      if (replacePhotoData != null) {
        // Run replace specific logic seamlessly
        uploadRes = await _photoRepository.replacePhoto(
          profileId: _profileId!,
          existingPhotoId: replacePhotoData['id'],
          existingStoragePath: replacePhotoData['storagePath'] ?? '',
          newImageFile: imageFile,
          semanticLabel: 'Profile Photo',
        );
      } else {
        uploadRes = await _photoRepository.uploadPhoto(
          profileId: _profileId!,
          imageFile: imageFile,
          semanticLabel: 'Profile Photo',
        );
      }

      uploadRes.fold(
        onSuccess: (photo) async {
          HapticFeedback.lightImpact();
          await _loadPhotos();
          if (mounted) {
            _showSuccessSnackBar(AppLocalizations.of(context)?.photoUploadedSuccessfully ?? 'Photo uploaded successfully');
          }
        },
        onFailure: (error) {
          _showErrorSnackBar(error);
        },
      );
    } catch (e) {
      _showErrorSnackBar(e.toString().replaceAll('Exception: ', ''));
    } finally {
      if (mounted) {
        setState(() {});
      }
    }
  }

  void _showCulturalGuidelines() {
    showDialog(
      context: context,
      builder: (context) => const CulturalGuidelinesWidget(),
    );
  }

  void _showPremiumUpgradeDialog() {
    Navigator.pushNamed(context, AppRoutes.subscription).then((_) {
      _loadSubscriptionStatus();
    });
  }

  void _toggleSelectionMode() {
    setState(() {
      _isSelectionMode = !_isSelectionMode;
      if (!_isSelectionMode) {
        _selectedPhotos.clear();
        for (var photo in _photos) {
          photo['isSelected'] = false;
        }
      }
    });
  }

  void _togglePhotoSelection(String photoId) {
    setState(() {
      if (_selectedPhotos.contains(photoId)) {
        _selectedPhotos.remove(photoId);
      } else {
        _selectedPhotos.add(photoId);
      }

      final index = _photos.indexWhere((p) => p['id'] == photoId);
      if (index != -1) {
        _photos[index]['isSelected'] = _selectedPhotos.contains(photoId);
      }
    });
  }

  void _deleteSelectedPhotos() {
    final theme = Theme.of(context);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(AppLocalizations.of(context)?.deletePhotos ?? 'Delete Photos', style: theme.textTheme.titleLarge),
        content: Text(
          AppLocalizations.of(context)?.areYouSureDeleteSelectedPhotos(_selectedPhotos.length) ?? 'Are you sure you want to delete ${_selectedPhotos.length} photo(s)?',
          style: theme.textTheme.bodyLarge,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(AppLocalizations.of(context)?.cancel ?? 'Cancel',
              style: TextStyle(color: theme.colorScheme.onSurfaceVariant),
            ),
          ),
          TextButton(
            onPressed: () {
              setState(() {
                _photos.removeWhere(
                  (photo) => _selectedPhotos.contains(photo['id']),
                );
                _selectedPhotos.clear();
                _isSelectionMode = false;
              });
              Navigator.pop(context);
              _showSuccessSnackBar(AppLocalizations.of(context)?.photosDeletedSuccessfully ?? 'Photos deleted successfully');
            },
            child: Text(AppLocalizations.of(context)?.delete ?? 'Delete',
              style: TextStyle(color: theme.colorScheme.error),
            ),
          ),
        ],
      ),
    );
  }

  void _setAsPrimary(String photoId) async {
    if (_profileId == null) return;
    final result = await _photoRepository.setAsPrimary(_profileId!, photoId);
    result.fold(
      onSuccess: (_) async {
        await _loadPhotos();
      if (mounted) {
        _showSuccessSnackBar(AppLocalizations.of(context)?.primaryPhotoUpdated ?? 'Primary photo updated');
      }
      },
      onFailure: (error) {
        _showErrorSnackBar(AppLocalizations.of(context)?.failedToUpdatePrimaryPhotoError(error.toString()) ?? 'Failed to update primary photo: $error');
      },
    );
  }

  void _updatePrivacyLevel(String photoId, String privacyLevel) {
    setState(() {
      final index = _photos.indexWhere((p) => p['id'] == photoId);
      if (index != -1) {
        _photos[index]['privacyLevel'] = privacyLevel;
      }
    });
    _showSuccessSnackBar(AppLocalizations.of(context)?.privacySettingsUpdated ?? 'Privacy settings updated');
  }

  void _showPhotoOptions(Map<String, dynamic> photo) {
    final theme = Theme.of(context);

    showModalBottomSheet(
      context: context,
      backgroundColor: theme.colorScheme.surface,
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
                color: theme.dividerColor,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            if (!photo['isPrimary'])
              ListTile(
                leading: CustomIconWidget(
                  iconName: 'star',
                  color: theme.colorScheme.primary,
                ),
                title: Text(AppLocalizations.of(context)?.setAsPrimary ?? 'Set as Primary', style: theme.textTheme.bodyLarge),
                onTap: () {
                  Navigator.pop(context);
                  _setAsPrimary(photo['id']);
                },
              ),
            ListTile(
              leading: CustomIconWidget(
                iconName: 'crop',
                color: theme.colorScheme.primary,
              ),
              title: Text(AppLocalizations.of(context)?.cropRotate ?? 'Crop & Rotate', style: theme.textTheme.bodyLarge),
              onTap: () {
                Navigator.pop(context);
                _processCapturedImage(photo['url'], replacePhotoData: photo);
              },
            ),
            ListTile(
              leading: CustomIconWidget(
                iconName: 'flip_camera_ios',
                color: theme.colorScheme.primary,
              ),
              title: Text(AppLocalizations.of(context)?.replacePhoto ?? 'Replace Photo', style: theme.textTheme.bodyLarge),
              onTap: () {
                Navigator.pop(context);
                _showReplacePhotoPicker(photo);
              },
            ),
            ListTile(
              leading: CustomIconWidget(
                iconName: photo['privacyLevel'] == 'public'
                    ? 'visibility'
                    : 'visibility_off',
                color: theme.colorScheme.primary,
              ),
              title: Text(AppLocalizations.of(context)?.privacySettings ?? 'Privacy Settings', style: theme.textTheme.bodyLarge),
              onTap: () {
                Navigator.pop(context);
                _showPrivacyOptions(photo);
              },
            ),
            ListTile(
              leading: CustomIconWidget(
                iconName: 'delete',
                color: theme.colorScheme.error,
              ),
              title: Text(AppLocalizations.of(context)?.deletePhoto ?? 'Delete Photo',
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: theme.colorScheme.error,
                ),
              ),
              onTap: () {
                Navigator.pop(context);
                _deletePhoto(photo['id']);
              },
            ),
            SizedBox(height: 2.h),
          ],
        ),
      ),
    );
  }

  void _showPrivacyOptions(Map<String, dynamic> photo) {
    final theme = Theme.of(context);

    showModalBottomSheet(
      context: context,
      backgroundColor: theme.colorScheme.surface,
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
                color: theme.dividerColor,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Padding(
              padding: EdgeInsets.all(4.w),
              child: Text(AppLocalizations.of(context)?.photoVisibility ?? 'Photo Visibility',
                style: theme.textTheme.titleMedium,
              ),
            ),
            RadioListTile<String>(
              value: 'public',
              groupValue: photo['privacyLevel'],
              title: Text(AppLocalizations.of(context)?.public ?? 'Public', style: theme.textTheme.bodyLarge),
              subtitle: Text(AppLocalizations.of(context)?.visibleToAllProfiles ?? 'Visible to all profiles',
                style: theme.textTheme.bodySmall,
              ),
              onChanged: (value) {
                Navigator.pop(context);
                if (value != null) {
                  _updatePrivacyLevel(photo['id'], value);
                }
              },
            ),
            RadioListTile<String>(
              value: 'family',
              groupValue: photo['privacyLevel'],
              title: Text(AppLocalizations.of(context)?.familyOnly ?? 'Family Only', style: theme.textTheme.bodyLarge),
              subtitle: Text(AppLocalizations.of(context)?.visibleToCloseMatchesOnly ?? 'Visible to close matches only',
                style: theme.textTheme.bodySmall,
              ),
              onChanged: (value) {
                Navigator.pop(context);
                if (value != null) {
                  _updatePrivacyLevel(photo['id'], value);
                }
              },
            ),
            SizedBox(height: 2.h),
          ],
        ),
      ),
    );
  }

  void _deletePhoto(String photoId) async {
    final photo = _photos.firstWhere((p) => p['id'] == photoId);
    final storagePath = photo['storagePath'] as String?;

    if (storagePath == null) return;

    final theme = Theme.of(context);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(AppLocalizations.of(context)?.deletePhoto ?? 'Delete Photo', style: theme.textTheme.titleLarge),
        content: Text(AppLocalizations.of(context)?.areYouSureYouWantToDeleteThisPhoto ?? 'Are you sure you want to delete this photo?',
          style: theme.textTheme.bodyLarge,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(AppLocalizations.of(context)?.cancel ?? 'Cancel',
              style: TextStyle(color: theme.colorScheme.onSurfaceVariant),
            ),
          ),
          TextButton(
            onPressed: () async {
              final l10n = AppLocalizations.of(context);
              Navigator.pop(context);
              setState(() {});
              final result = await _photoRepository.deletePhoto(
                photoId,
                storagePath,
              );
              result.fold(
                onSuccess: (_) async {
                  HapticFeedback.lightImpact();
                  await _loadPhotos();
                  if (mounted) {
                    _showSuccessSnackBar(l10n?.photosDeletedSuccessfully ?? 'Photo deleted successfully');
                  }
                },
                onFailure: (error) {
                  if (mounted) {
                    _showErrorSnackBar(l10n?.failedToDeletePhotoError(error.toString()) ?? 'Failed to delete photo: $error');
                  }
                },
              );
              if (mounted) setState(() {});
            },
            child: Text(AppLocalizations.of(context)?.delete ?? 'Delete',
              style: TextStyle(color: theme.colorScheme.error),
            ),
          ),
        ],
      ),
    );
  }

  void _showPermissionDeniedDialog(String permissionType) {
    final theme = Theme.of(context);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(AppLocalizations.of(context)?.permissionRequired ?? 'Permission Required', style: theme.textTheme.titleLarge),
        content: Text(
          AppLocalizations.of(context)?.permissionRequiredMessage(permissionType) ?? '$permissionType permission is required to upload photos. Please enable it in app settings.',
          style: theme.textTheme.bodyLarge,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(AppLocalizations.of(context)?.cancel ?? 'Cancel',
              style: TextStyle(color: theme.colorScheme.onSurfaceVariant),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              openAppSettings();
            },
            child: Text(AppLocalizations.of(context)?.openSettings ?? 'Open Settings',
              style: TextStyle(color: theme.colorScheme.primary),
            ),
          ),
        ],
      ),
    );
  }

  void _showSuccessSnackBar(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Theme.of(context).colorScheme.primary,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _showErrorSnackBar(String message) {
    if (!mounted) return;
    final isPermissionError =
        message.toLowerCase().contains('permission') ||
        message.toLowerCase().contains('denied');

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          isPermissionError
              ? 'Permission denied. Please enable access in Settings.'
              : message,
        ),
        backgroundColor: Theme.of(context).colorScheme.error,
        behavior: SnackBarBehavior.floating,
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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: CustomAppBar(
        title: AppLocalizations.of(context)?.photoManagement ?? 'Photo Management',
        subtitle: _isPremiumUser
            ? 'Premium (${_photos.length}/6)'
            : 'Free (${_photos.length}/1)',
        actions: [
          if (_photos.isNotEmpty)
            IconButton(
              icon: CustomIconWidget(
                iconName: _isSelectionMode ? 'close' : 'checklist',
                color:
                    theme.appBarTheme.foregroundColor ??
                    theme.colorScheme.onSurface,
              ),
              onPressed: _toggleSelectionMode,
              tooltip: _isSelectionMode ? 'Cancel selection' : 'Select photos',
            ),
          IconButton(
            icon: CustomIconWidget(
              iconName: 'info_outline',
              color:
                  theme.appBarTheme.foregroundColor ??
                  theme.colorScheme.onSurface,
            ),
            onPressed: _showCulturalGuidelines,
            tooltip: AppLocalizations.of(context)?.photoGuidelines ?? 'Photo guidelines',
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            if (!_isPremiumUser)
              Container(
                width: double.infinity,
                padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
                color: theme.colorScheme.primaryContainer.withValues(
                  alpha: 0.3,
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
                      child: Text(AppLocalizations.of(context)?.upgradeToPremiumFor6PhotosAdvancedFilter ?? 'Upgrade to Premium for 6 photos & advanced filters',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.primary,
                        ),
                      ),
                    ),
                    TextButton(
                      onPressed: _showPremiumUpgradeDialog,
                      child: Text(AppLocalizations.of(context)?.upgrade ?? 'Upgrade',
                        style: theme.textTheme.labelLarge?.copyWith(
                          color: theme.colorScheme.primary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            Expanded(
              child: _photos.isEmpty
                  ? PhotoUploadWidget(
                      onAddPhoto: _showAddPhotoOptions,
                      isPremium: _isPremiumUser,
                    )
                  : PhotoGridWidget(
                      photos: _photos,
                      isSelectionMode: _isSelectionMode,
                      onPhotoTap: (photo) {
                        if (_isSelectionMode) {
                          _togglePhotoSelection(photo['id']);
                        } else {
                          _showPhotoOptions(photo);
                        }
                      },
                      onPhotoLongPress: (photo) {
                        if (!_isSelectionMode) {
                          _toggleSelectionMode();
                          _togglePhotoSelection(photo['id']);
                        }
                      },
                      onAddPhoto: _showAddPhotoOptions,
                      isPremium: _isPremiumUser,
                      maxPhotos: _isPremiumUser ? 6 : 1,
                    ),
            ),
          ],
        ),
      ),
      floatingActionButton: _isSelectionMode && _selectedPhotos.isNotEmpty
          ? FloatingActionButton.extended(
              onPressed: _deleteSelectedPhotos,
              backgroundColor: theme.colorScheme.error,
              icon: CustomIconWidget(
                iconName: 'delete',
                color: theme.colorScheme.onError,
              ),
              label: Text(
                AppLocalizations.of(context)?.deleteCount(_selectedPhotos.length) ?? 'Delete (${_selectedPhotos.length})',
                style: TextStyle(color: theme.colorScheme.onError),
              ),
            )
          : null,
    );
  }
}
