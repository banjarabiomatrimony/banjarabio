import 'dart:io';
import 'package:banjarabio/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import 'package:banjarabio/core/repositories/trust_score_repository.dart';
import 'package:banjarabio/core/supabase_client.dart';
import 'package:banjarabio/widgets/custom_app_bar.dart';
import 'package:banjarabio/services/photo_picker_service.dart';
import 'package:banjarabio/core/constants/app_typography.dart';
import 'package:banjarabio/theme/app_colors.dart';

class LiveSelfieScreen extends StatefulWidget {
  const LiveSelfieScreen({super.key});

  @override
  State<LiveSelfieScreen> createState() => _LiveSelfieScreenState();
}

class _LiveSelfieScreenState extends State<LiveSelfieScreen> {
  final PhotoPickerService _photoService = PhotoPickerService();
  final TrustScoreRepository _repository = TrustScoreRepository();

  File? _capturedImage;
  bool _isLoading = false;

  Future<void> _captureSelfie() async {
    setState(() => _isLoading = true);

    try {
      final result = await _photoService.pickFromCamera();
      if (result.isSuccess && result.filePath != null) {
        setState(() {
          _capturedImage = File(result.filePath!);
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(
          content: Text(
            AppLocalizations.of(context)?.errorWithLabel(e.toString()) ??
                'Error capturing photo: $e',
          ),
        ));
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _submitVerification() async {
    final userId = AppSupabaseClient.currentUserId;
    if (userId == null || _capturedImage == null) return;

    setState(() => _isLoading = true);

    try {
      // Upload selfie
      final path =
          '$userId/selfie_${DateTime.now().millisecondsSinceEpoch}.jpg';
      final uploadRes = await _repository.uploadVerificationDoc(
        file: _capturedImage!,
        path: path,
      );

      bool uploadSuccess = false;
      await uploadRes.fold(
        onSuccess: (_) async => uploadSuccess = true,
        onFailure: (error) async {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  AppLocalizations.of(context)?.uploadFailed(error) ??
                      'Upload failed: $error',
                ),
              ),
            );
          }
        },
      );

      if (!uploadSuccess) {
        setState(() => _isLoading = false); // Ensure loading state is reset on upload failure
        return;
      }

      // Submit request
      await _repository.submitVerificationRequest(
        type: 'photo',
        payload: {'selfie_url': path},
      );

      if (mounted) {
        setState(() => _isLoading = false);

        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (dialogContext) {
            final theme = Theme.of(dialogContext);
            final l10n = AppLocalizations.of(dialogContext);

            return PopScope(
              canPop: false,
              child: Dialog(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24),
                ),
                elevation: 10,
                backgroundColor: theme.colorScheme.surface,
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 3.h),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 72,
                        height: 72,
                        decoration: BoxDecoration(
                          color: AppColors.categoryLocation.withValues(alpha: AppColors.opacity12),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.verified_rounded,
                          color: AppColors.categoryLocation,
                          size: 44,
                        ),
                      ),
                      SizedBox(height: 2.h),
                      Text(
                        l10n?.selfieSubmitted ?? 'Selfie Submitted',
                        style: TextStyle(
                          fontSize: AppTypography.headingMedium,
                          fontWeight: AppTypography.black,
                          color: theme.colorScheme.onSurface,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: 1.2.h),
                      Text(
                        l10n?.yourSelfieHasBeenSubmittedOurTeamWillVer ??
                            'Your selfie has been submitted. Our team will verify it against your profile photo.',
                        style: TextStyle(
                          fontSize: AppTypography.bodyMedium,
                          color: theme.colorScheme.onSurfaceVariant,
                          height: 1.45,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: 2.h),
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 4.w,
                          vertical: 1.2.h,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.categoryLocation.withValues(alpha: AppColors.opacity8),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: AppColors.categoryLocation.withValues(alpha: AppColors.opacity25),
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.stars_rounded,
                              color: AppColors.categoryLocationDark,
                              size: 22,
                            ),
                            SizedBox(width: 2.w),
                            Text(
                              l10n?.num15PointsPending ?? '+15 Points Pending',
                              style: TextStyle(
                                fontSize: AppTypography.headingSmall,
                                fontWeight: AppTypography.extraBold,
                                color: AppColors.categoryLocationDark,
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 3.h),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.of(dialogContext).pop(); // Close dialog
                            Navigator.of(context).pop(true); // Close screen
                          },
                          style: ElevatedButton.styleFrom(
                            padding: EdgeInsets.symmetric(vertical: 1.6.h),
                            backgroundColor: AppColors.categoryLocation,
                            foregroundColor: Colors.white,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                          child: Text(
                            l10n?.great ?? 'Great!',
                            style: TextStyle(
                              fontSize: AppTypography.headingSmall,
                              fontWeight: AppTypography.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(
          content: Text(
            AppLocalizations.of(context)?.errorWithLabel(e.toString()) ??
                'Error: ${e.toString()}',
          ),
        ));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      appBar: CustomAppBar(
        title: l10n?.liveSelfieVerification ?? 'Live Selfie Verification',
      ),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 5.w, vertical: 2.h),
          child: _capturedImage == null
              ? Column(
                  children: [
                    const Spacer(),
                    Container(
                      padding: EdgeInsets.all(5.w),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primary.withValues(alpha: AppColors.opacity8),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.face_retouching_natural,
                        size: 70,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                    SizedBox(height: 3.h),
                    Text(
                      l10n?.livenessCheck ?? 'Liveness Check',
                      style: TextStyle(
                        fontSize: AppTypography.headingMedium,
                        fontWeight: AppTypography.bold,
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                    SizedBox(height: 1.5.h),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 4.w),
                      child: Text(
                        l10n?.pleaseTakeASelfieToVerifyThatYouAreAReal ??
                            'Please take a selfie to verify that you are a real person. Ensure you are in a well-lit area.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: AppTypography.bodyMedium,
                          color: theme.colorScheme.onSurfaceVariant,
                          height: 1.4,
                        ),
                      ),
                    ),
                    const Spacer(),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: _isLoading ? null : _captureSelfie,
                        icon: const Icon(Icons.camera_alt, size: 20),
                        label: Text(
                          l10n?.openCamera ?? 'Open Camera',
                          style: TextStyle(
                            fontSize: AppTypography.headingSmall,
                            fontWeight: AppTypography.bold,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          padding: EdgeInsets.symmetric(vertical: 1.6.h),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                      ),
                    ),
                  ],
                )
              : Column(
                  children: [
                    Expanded(
                      child: Container(
                        width: double.infinity,
                        margin: EdgeInsets.only(bottom: 2.h),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: theme.colorScheme.outline.withValues(alpha: AppColors.opacity20),
                            width: 2,
                          ),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(14),
                          child: Image.file(
                            _capturedImage!,
                            fit: BoxFit.cover,
                            width: double.infinity,
                          ),
                        ),
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.only(top: 0.5.h),
                      child: Row(
                        children: [
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: _isLoading ? null : _captureSelfie,
                              icon: const Icon(Icons.refresh_rounded, size: 18),
                              style: OutlinedButton.styleFrom(
                                padding: EdgeInsets.symmetric(vertical: 1.5.h),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              label: Text(
                                l10n?.retake ?? 'Retake',
                                style: TextStyle(
                                  fontSize: AppTypography.headingSmall,
                                  fontWeight: AppTypography.bold,
                                ),
                              ),
                            ),
                          ),
                          SizedBox(width: 3.w),
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: _isLoading ? null : _submitVerification,
                              icon: _isLoading
                                  ? const SizedBox.shrink()
                                  : const Icon(Icons.check_circle_outline, size: 18),
                              style: ElevatedButton.styleFrom(
                                padding: EdgeInsets.symmetric(vertical: 1.5.h),
                                backgroundColor: AppColors.success,
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              label: _isLoading
                                  ? SizedBox(
                                      width: 2.2.h,
                                      height: 2.2.h,
                                      child: const CircularProgressIndicator(
                                        color: Colors.white,
                                        strokeWidth: 2.2,
                                      ),
                                    )
                                  : Text(
                                      l10n?.verifyNow ?? 'Verify Now',
                                      style: TextStyle(
                                        fontSize: AppTypography.headingSmall,
                                        fontWeight: AppTypography.bold,
                                      ),
                                    ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}
