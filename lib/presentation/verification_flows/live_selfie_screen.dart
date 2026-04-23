import 'dart:io';
import 'package:banjarabio/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import 'package:banjarabio/core/repositories/trust_score_repository.dart';
import 'package:banjarabio/core/supabase_client.dart';
import 'package:banjarabio/widgets/custom_app_bar.dart';
import 'package:banjarabio/services/photo_picker_service.dart';

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
          builder: (dialogContext) => PopScope(
            canPop: false,
            child: AlertDialog(
              title: Text(AppLocalizations.of(context)?.selfieSubmitted ?? 'Selfie Submitted'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.check_circle, color: Colors.green, size: 60),
                  SizedBox(height: 2.h),
                  Text(AppLocalizations.of(context)?.yourSelfieHasBeenSubmittedOurTeamWillVer ?? 'Your selfie has been submitted. Our team will verify it against your profile photo.',
                  ),
                  SizedBox(height: 1.h),
                  Text(AppLocalizations.of(context)?.num15PointsPending ?? '+15 Points Pending',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.green,
                    ),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(dialogContext).pop(); // Close dialog
                    Navigator.of(context).pop(true); // Close screen
                  },
                  child: Text(AppLocalizations.of(context)?.great ?? 'Great!'),
                ),
              ],
            ),
          ),
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
    return Scaffold(
      appBar: CustomAppBar(title: AppLocalizations.of(context)?.liveSelfieVerification ?? 'Live Selfie Verification'),
      body: Padding(
        padding: EdgeInsets.all(5.w),
        child: Column(
          children: [
            if (_capturedImage == null) ...[
              const Spacer(),
              const Icon(
                Icons.face_retouching_natural,
                size: 80,
                color: Colors.blue,
              ),
              SizedBox(height: 3.h),
              Text(AppLocalizations.of(context)?.livenessCheck ?? 'Liveness Check',
                style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 2.h),
              Text(AppLocalizations.of(context)?.pleaseTakeASelfieToVerifyThatYouAreAReal ?? 'Please take a selfie to verify that you are a real person. Ensure you are in a well-lit area.',
                textAlign: TextAlign.center,
              ),
              const Spacer(),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _isLoading ? null : _captureSelfie,
                  icon: const Icon(Icons.camera_alt),
                  label: Text(AppLocalizations.of(context)?.openCamera ?? 'Open Camera'),
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(vertical: 2.h),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            ] else ...[
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.file(_capturedImage!, fit: BoxFit.cover),
                ),
              ),
              SizedBox(height: 3.h),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _isLoading ? null : _captureSelfie,
                      style: OutlinedButton.styleFrom(
                        padding: EdgeInsets.symmetric(vertical: 2.h),
                      ),
                      child: Text(AppLocalizations.of(context)?.retake ?? 'Retake'),
                    ),
                  ),
                  SizedBox(width: 4.w),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _submitVerification,
                      style: ElevatedButton.styleFrom(
                        padding: EdgeInsets.symmetric(vertical: 2.h),
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                      ),
                      child: _isLoading
                          ? SizedBox(
                              width: 2.5.h,
                              height: 2.5.h,
                              child: const CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                          : Text(AppLocalizations.of(context)?.verifyNow ?? 'Verify Now'),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}
