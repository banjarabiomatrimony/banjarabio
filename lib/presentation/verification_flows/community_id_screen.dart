import 'dart:io';
import 'package:banjarabio/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import 'package:banjarabio/core/repositories/trust_score_repository.dart';
import 'package:banjarabio/core/supabase_client.dart';
import 'package:banjarabio/widgets/custom_app_bar.dart';
import 'package:banjarabio/services/photo_picker_service.dart';

class CommunityIdScreen extends StatefulWidget {
  const CommunityIdScreen({super.key});

  @override
  State<CommunityIdScreen> createState() => _CommunityIdScreenState();
}

class _CommunityIdScreenState extends State<CommunityIdScreen> {
  final TrustScoreRepository _repository = TrustScoreRepository();
  final PhotoPickerService _photoService = PhotoPickerService();

  final TextEditingController _gotraController = TextEditingController();
  final TextEditingController _villageController = TextEditingController();

  File? _proofImage;
  bool _isLoading = false;

  @override
  void dispose() {
    _gotraController.dispose();
    _villageController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    try {
      final result = await _photoService.pickFromGallery();
      if (result.isSuccess && result.filePath != null) {
        setState(() {
          _proofImage = File(result.filePath!);
        });
      }
    } catch (e) {
      debugPrint('Error picking image: $e');
    }
  }

  Future<void> _submit() async {
    final userId = AppSupabaseClient.currentUserId;
    if (userId == null) return;

    if (_gotraController.text.isEmpty || _villageController.text.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(AppLocalizations.of(context)?.pleaseFillAllFields ?? 'Please fill all fields')));
      return;
    }

    setState(() => _isLoading = true);

    try {
      String? proofUrl;
      if (_proofImage != null) {
        final path =
            '$userId/community_id_${DateTime.now().millisecondsSinceEpoch}.jpg';
        final uploadRes = await _repository.uploadVerificationDoc(file: _proofImage!, path: path);
        
        await uploadRes.fold(
          onSuccess: (p) async => proofUrl = p,
          onFailure: (error) async {
             if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    AppLocalizations.of(context)?.uploadFailed(error) ??
                        'Proof upload failed: $error',
                  ),
                ),
              );
            }
          },
        );
      }

      // If proof was required but failed, stop
      if (_proofImage != null && proofUrl == null) {
        setState(() => _isLoading = false);
        return;
      }

      await _repository.submitVerificationRequest(
        type: 'communityId',
        payload: {
          'gotra': _gotraController.text,
          'village': _villageController.text,
          if (proofUrl != null) 'proof_url': proofUrl,
        },
      );

      if (mounted) {
        setState(() => _isLoading = false);
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (dialogContext) => PopScope(
            canPop: false,
            child: AlertDialog(
              title: Text(AppLocalizations.of(context)?.communityIdSubmitted ?? 'Community ID Submitted'),
              content: Text(AppLocalizations.of(context)?.weWillVerifyYourCommunityDetailsShortly1 ?? 'We will verify your community details shortly. +15 Points Pending.',
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
      appBar: CustomAppBar(title: AppLocalizations.of(context)?.communityVerification ?? 'Community Verification'),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(5.w),
        child: Column(
          children: [
            const Icon(Icons.diversity_3, size: 60, color: Colors.orange),
            SizedBox(height: 3.h),
            Text(AppLocalizations.of(context)?.verifyYourCommunityStatus ?? 'Verify Your Community Status',
              style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 1.h),
            Text(AppLocalizations.of(context)?.provideDetailsAboutYourGotraAndVillageTo ?? 'Provide details about your Gotra and Village to get the Community Verified badge.',
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.grey),
            ),
            SizedBox(height: 4.h),
            TextField(
              controller: _gotraController,
              decoration: InputDecoration(
                labelText: AppLocalizations.of(context)?.gotra ?? 'Gotra',
                prefixIcon: const Icon(Icons.people),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            SizedBox(height: 2.h),
            TextField(
              controller: _villageController,
              decoration: InputDecoration(
                labelText: AppLocalizations.of(context)?.villageTanda ??
                    'Village / Tanda',
                prefixIcon: const Icon(Icons.home),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            SizedBox(height: 3.h),
            InkWell(
              onTap: _pickImage,
              child: Container(
                height: 18.h,
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: _proofImage != null
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.file(
                          _proofImage!,
                          fit: BoxFit.cover,
                          width: double.infinity,
                        ),
                      )
                    : Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.upload_file, size: 40, color: Colors.grey),
                          SizedBox(height: 1.h),
                          Text(AppLocalizations.of(context)?.uploadCommunityCertificateLetter ?? 'Upload Community Certificate / Letter',
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
              ),
            ),
            SizedBox(height: 4.h),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _submit,
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: 2.h),
                  backgroundColor: Theme.of(context).primaryColor,
                  foregroundColor: Colors.white,
                ),
                child: _isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : Text(AppLocalizations.of(context)?.submitForVerification ?? 'Submit for Verification'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
