import 'dart:io';
import 'package:banjarabio/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:sizer/sizer.dart';
import 'package:banjarabio/core/repositories/trust_score_repository.dart';
import 'package:banjarabio/core/supabase_client.dart';
import 'package:banjarabio/widgets/custom_app_bar.dart';
import 'package:banjarabio/core/constants/app_typography.dart';

class VideoIntroScreen extends StatefulWidget {
  const VideoIntroScreen({super.key});

  @override
  State<VideoIntroScreen> createState() => _VideoIntroScreenState();
}

class _VideoIntroScreenState extends State<VideoIntroScreen> {
  final TrustScoreRepository _repository = TrustScoreRepository();
  final ImagePicker _picker = ImagePicker();

  File? _videoFile;
  bool _isLoading = false;

  Future<void> _recordVideo() async {
    try {
      final XFile? video = await _picker.pickVideo(
        source: ImageSource.camera,
        maxDuration: const Duration(seconds: 30),
      );

      if (video != null) {
        setState(() {
          _videoFile = File(video.path);
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(
          content: Text(
            AppLocalizations.of(context)?.errorWithLabel(e.toString()) ??
                'Error: $e',
          ),
        ));
      }
    }
  }

  Future<void> _submit() async {
    final userId = AppSupabaseClient.currentUserId;
    if (userId == null || _videoFile == null) return;

    setState(() => _isLoading = true);

    try {
      // Upload video
      final path =
          '$userId/video_bio_${DateTime.now().millisecondsSinceEpoch}.mp4';

      bool uploadSuccess = false;
      final uploadRes = await _repository.uploadVerificationDoc(file: _videoFile!, path: path);
      
      await uploadRes.fold(
        onSuccess: (_) async => uploadSuccess = true,
        onFailure: (error) async {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  AppLocalizations.of(context)?.uploadFailed(error) ??
                      'Video upload failed: $error',
                ),
              ),
            );
          }
          // Reset loading state on failure
          setState(() => _isLoading = false);
        },
      );

      if (!uploadSuccess) {
        setState(() => _isLoading = false);
        return;
      }

      // Submit request
      await _repository.submitVerificationRequest(
        type: 'videoBio',
        payload: {'video_url': path},
      );

      if (mounted) {
        setState(() => _isLoading = false);
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (dialogContext) => PopScope(
            canPop: false,
            child: AlertDialog(
              title: Text(AppLocalizations.of(context)?.uploadedSuccessfully ?? 'Uploaded Successfully'),
              content: Text(AppLocalizations.of(context)?.yourIntroVideoIsUnderReview10PointsPendi ?? 'Your intro video is under review. +10 Points pending approval.',
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(dialogContext).pop(); // Close dialog
                    Navigator.of(context).pop(true); // Close screen
                  },
                  child: Text(AppLocalizations.of(context)?.ok ?? 'OK'),
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
      appBar: CustomAppBar(
        title: AppLocalizations.of(context)?.videoBioIntro ??
            'Video Bio / Intro',
      ),
      body: Padding(
        padding: EdgeInsets.all(5.w),
        child: Column(
          children: [
            if (_videoFile == null) ...[
              const Icon(Icons.videocam, size: 80, color: Colors.pink),
              SizedBox(height: 2.h),
              Text(AppLocalizations.of(context)?.recordAShortIntro ?? 'Record a Short Intro',
                style: TextStyle(fontSize: AppTypography.headingSmall, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 1.h),
              Text(AppLocalizations.of(context)?.introduceYourselfIn30SecondsTalkAboutYou ?? 'Introduce yourself in 30 seconds. Talk about your family, profession, and expectations.',
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.grey),
              ),
              const Spacer(),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _recordVideo,
                  icon: const Icon(
                    Icons.fiber_manual_record,
                    color: Colors.red,
                  ),
                  label: Text(AppLocalizations.of(context)?.startRecording ?? 'Start Recording'),
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(vertical: 2.h),
                  ),
                ),
              ),
            ] else ...[
              const Icon(Icons.check_circle, size: 60, color: Colors.green),
              SizedBox(height: 2.h),
              Text(AppLocalizations.of(context)?.videoRecorded ?? 'Video Recorded!',
                style: TextStyle(fontSize: AppTypography.bodyLarge, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 1.h),
              Text(
                'File path: ${_videoFile!.path.split('/').last}',
                style: TextStyle(fontSize: AppTypography.bodySmall, color: Colors.grey),
              ),

              const Spacer(),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _recordVideo,
                      child: Text(AppLocalizations.of(context)?.rerecord ?? 'Re-record'),
                    ),
                  ),
                  SizedBox(width: 4.w),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _submit,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context).primaryColor,
                        foregroundColor: Colors.white,
                      ),
                      child: _isLoading
                          ? const CircularProgressIndicator(color: Colors.white)
                          : Text(AppLocalizations.of(context)?.submit ?? 'Submit'),
                    ),
                  ),
                ],
              ),
            ],
            SizedBox(height: 4.h),
          ],
        ),
      ),
    );
  }
}
