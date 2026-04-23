// ignore_for_file: deprecated_member_use

import 'dart:io';
import 'package:banjarabio/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import 'package:banjarabio/core/repositories/trust_score_repository.dart';
import 'package:banjarabio/core/supabase_client.dart';
import 'package:banjarabio/widgets/custom_app_bar.dart';
import 'package:banjarabio/services/photo_picker_service.dart';

class GovtIdVerificationScreen extends StatefulWidget {
  const GovtIdVerificationScreen({super.key});

  @override
  State<GovtIdVerificationScreen> createState() =>
      _GovtIdVerificationScreenState();
}

class _GovtIdVerificationScreenState extends State<GovtIdVerificationScreen> {
  final TrustScoreRepository _repository = TrustScoreRepository();
  final PhotoPickerService _photoService = PhotoPickerService();

  int _currentStep = 0;
  String? _selectedDocType; // 'Aadhaar' or 'PAN'
  File? _frontImage;
  File? _backImage;
  final TextEditingController _idNumberController = TextEditingController();
  bool _isLoading = false;

  final List<String> _docTypes = ['Aadhaar Card', 'PAN Card'];

  @override
  void dispose() {
    _idNumberController.dispose();
    super.dispose();
  }

  void _nextStep() {
    setState(() => _currentStep++);
  }

  void _prevStep() {
    if (_currentStep > 0) setState(() => _currentStep--);
  }

  Future<void> _pickImage(bool isFront) async {
    try {
      final result = await _photoService.pickFromCamera();
      if (result.isSuccess && result.filePath != null) {
        setState(() {
          if (isFront) {
            _frontImage = File(result.filePath!);
          } else {
            _backImage = File(result.filePath!);
          }
        });
      }
    } catch (e) {
      debugPrint('Error picking image: $e');
    }
  }

  Future<void> _submit() async {
    final userId = AppSupabaseClient.currentUserId;
    if (userId == null) return;

    setState(() => _isLoading = true);

    try {
      final List<String> uploadedUrls = [];

      // Upload front image
      if (_frontImage != null) {
        final frontPath =
            '$userId/govt_id_front_${DateTime.now().millisecondsSinceEpoch}.jpg';
        final uploadRes = await _repository.uploadVerificationDoc(
          file: _frontImage!,
          path: frontPath,
        );

        await uploadRes.fold(
          onSuccess: (_) async => uploadedUrls.add(frontPath),
          onFailure: (error) async =>
              throw Exception('Front image upload failed: $error'),
        );
      }

      // Upload back image
      if (_backImage != null) {
        final backPath =
            '$userId/govt_id_back_${DateTime.now().millisecondsSinceEpoch}.jpg';
        final uploadRes = await _repository.uploadVerificationDoc(
          file: _backImage!,
          path: backPath,
        );

        await uploadRes.fold(
          onSuccess: (_) async => uploadedUrls.add(backPath),
          onFailure: (error) async =>
              throw Exception('Back image upload failed: $error'),
        );
      }

      // Submit request to table
      final submitRes = await _repository.submitVerificationRequest(
        type: 'govtId',
        payload: {
          'doc_type': _selectedDocType,
          'id_number': _idNumberController.text,
          'image_urls': uploadedUrls,
        },
      );

      await submitRes.fold(
        onSuccess: (_) async {
          if (mounted) {
            setState(() => _isLoading = true);

            showDialog(
              context: context,
              barrierDismissible: false,
              builder: (dialogContext) => PopScope(
                canPop: false,
                child: AlertDialog(
                  title: Text(AppLocalizations.of(context)?.submittedForReview ?? 'Submitted for Review'),
                  content: Text(AppLocalizations.of(context)?.yourDocumentsHaveBeenSubmittedSecurelyWe ?? 'Your documents have been submitted securely. We will notify you once verified.',
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
        },
        onFailure: (error) async =>
            throw Exception('Submission failed: $error'),
      );
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
      appBar: CustomAppBar(title: AppLocalizations.of(context)?.govtIdVerification ?? 'Govt ID Verification'),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(5.w),
              child: _buildCurrentStep(),
            ),
          ),
          _buildBottomBar(),
        ],
      ),
    );
  }

  Widget _buildCurrentStep() {
    switch (_currentStep) {
      case 0: // Info & Select Type
        return Column(
          children: [
            const Icon(Icons.security, size: 60, color: Colors.blue),
            SizedBox(height: 2.h),
            Text(AppLocalizations.of(context)?.selectDocumentType ?? 'Select Document Type',
              style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 4.h),
            ..._docTypes.map(
              (type) {
                return RadioListTile<String>(
                  title: Text(type),
                  value: type,
                  groupValue: _selectedDocType,
                  onChanged: (val) => setState(() => _selectedDocType = val),
                  tileColor: _selectedDocType == type
                      ? Colors.blue.withValues(alpha: 0.1)
                      : null,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                );
              },
            ),
          ],
        );

      case 1: // Upload Photos
        return Column(
          children: [
            Text(
              'Upload $_selectedDocType Photos',
              style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 3.h),
            _buildPhotoUploadBox(
              AppLocalizations.of(context)?.frontSide ?? 'Front Side',
              _frontImage,
              () => _pickImage(true),
            ),
            if (_selectedDocType == 'Aadhaar Card') ...[
              SizedBox(height: 2.h),
              _buildPhotoUploadBox(
                AppLocalizations.of(context)?.backSide ?? 'Back Side',
                _backImage,
                () => _pickImage(false),
              ),
            ],
          ],
        );

      case 2: // Enter ID Number
        return Column(
          children: [
            Text(
              'Enter $_selectedDocType Number',
              style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 3.h),
            TextField(
              controller: _idNumberController,
              decoration: InputDecoration(
                labelText: AppLocalizations.of(context)?.idNumber ?? 'ID Number',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                prefixIcon: const Icon(Icons.pin),
              ),
              textCapitalization: TextCapitalization.characters,
            ),
          ],
        );

      case 3: // Review
        return Column(
          children: [
            Text(AppLocalizations.of(context)?.reviewDetails ?? 'Review Details',
              style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 3.h),
            ListTile(
              title: Text(AppLocalizations.of(context)?.documentType ?? 'Document Type'),
              subtitle: Text(_selectedDocType!),
              leading: const Icon(Icons.file_copy),
            ),
            ListTile(
              title: Text(AppLocalizations.of(context)?.idNumber ?? 'ID Number'),
              subtitle: Text(_idNumberController.text),
              leading: const Icon(Icons.numbers),
            ),
            SizedBox(height: 2.h),
            Text(AppLocalizations.of(context)?.photos ?? 'Photos:',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 1.h),
            Row(
              children: [
                if (_frontImage != null)
                  Expanded(
                    child: Image.file(
                      _frontImage!,
                      height: 12.h,
                      fit: BoxFit.cover,
                    ),
                  ),
                if (_backImage != null) ...[
                  SizedBox(width: 2.w),
                  Expanded(
                    child: Image.file(
                      _backImage!,
                      height: 12.h,
                      fit: BoxFit.cover,
                    ),
                  ),
                ],
              ],
            ),
          ],
        );

      default:
        return Container();
    }
  }

  Widget _buildPhotoUploadBox(String label, File? image, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Container(
        height: 18.h,
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.grey[100],
          border: Border.all(color: Colors.grey),
          borderRadius: BorderRadius.circular(12),
        ),
        child: image != null
            ? ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.file(image, fit: BoxFit.cover),
              )
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.camera_alt, size: 40, color: Colors.grey),
                  SizedBox(height: 1.h),
                  Text(label, style: const TextStyle(color: Colors.grey)),
                ],
              ),
      ),
    );
  }

  Widget _buildBottomBar() {
    return Container(
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        boxShadow: [BoxShadow(blurRadius: 10, color: Theme.of(context).shadowColor.withValues(alpha: 0.12))],
      ),
      child: Row(
        children: [
          if (_currentStep > 0)
            Expanded(
              child: OutlinedButton(
                onPressed: _prevStep,
                style: OutlinedButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: 2.h),
                ),
                child: Text(AppLocalizations.of(context)?.back ?? 'Back'),
              ),
            ),
          if (_currentStep > 0) SizedBox(width: 4.w),
          Expanded(
            flex: 2,
            child: ElevatedButton(
              onPressed: _canProceed()
                  ? (_currentStep == 3 ? _submit : _nextStep)
                  : null,
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(vertical: 2.h),
                backgroundColor: Theme.of(context).primaryColor,
                foregroundColor: Colors.white,
              ),
              child: _isLoading
                  ? SizedBox(
                      width: 2.5.h,
                      height: 2.5.h,
                      child: const CircularProgressIndicator(color: Colors.white),
                    )
                  : Text(
                      _currentStep == 3
                          ? (AppLocalizations.of(context)?.submitForVerification ??
                              'Submit for Verification')
                          : (AppLocalizations.of(context)?.next ?? 'Next'),
                    ),
            ),
          ),
        ],
      ),
    );
  }

  bool _canProceed() {
    if (_currentStep == 0) return _selectedDocType != null;
    if (_currentStep == 1) {
      if (_frontImage == null) return false;
      if (_selectedDocType == 'Aadhaar Card' && _backImage == null) {
        return false;
      }
      return true;
    }
    if (_currentStep == 2) return _idNumberController.text.isNotEmpty;
    return true;
  }
}
