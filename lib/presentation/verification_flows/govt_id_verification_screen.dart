// ignore_for_file: deprecated_member_use

import 'dart:io';
import 'package:banjarabio/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';
import 'package:banjarabio/core/repositories/trust_score_repository.dart';
import 'package:banjarabio/core/supabase_client.dart';
import 'package:banjarabio/widgets/custom_app_bar.dart';
import 'package:banjarabio/presentation/verification_flows/document_camera_screen.dart';
import 'package:banjarabio/core/services/app_logger.dart';
import 'package:banjarabio/core/constants/app_typography.dart';
import 'package:banjarabio/theme/app_colors.dart';
import 'package:banjarabio/core/utils/app_feedback_service.dart';

class GovtIdVerificationScreen extends StatefulWidget {
  const GovtIdVerificationScreen({super.key});

  @override
  State<GovtIdVerificationScreen> createState() =>
      _GovtIdVerificationScreenState();
}

class _GovtIdVerificationScreenState extends State<GovtIdVerificationScreen> {
  final TrustScoreRepository _repository = TrustScoreRepository();

  int _currentStep = 0;
  String? _selectedDocType = 'Aadhaar Card';
  File? _frontImage;
  File? _backImage;
  final TextEditingController _idNumberController = TextEditingController();
  bool _isLoading = false;

  static const List<Map<String, dynamic>> _docTypes = [
    {
      'title': 'Aadhaar Card',
      'subtitle': 'Front & Back side photo required',
      'icon': Icons.credit_card_rounded,
      'hint': 'Enter 12-digit Aadhaar Number',
    },
    {
      'title': 'PAN Card',
      'subtitle': 'Front side photo required',
      'icon': Icons.badge_rounded,
      'hint': 'Enter 10-digit PAN (e.g. ABCDE1234F)',
    },
  ];

  @override
  void dispose() {
    _idNumberController.dispose();
    super.dispose();
  }

  void _nextStep() {
    if (_canProceed()) {
      HapticFeedback.lightImpact();
      setState(() => _currentStep++);
    }
  }

  void _prevStep() {
    if (_currentStep > 0) {
      HapticFeedback.lightImpact();
      setState(() => _currentStep--);
    }
  }

  Future<void> _pickImage(bool isFront) async {
    HapticFeedback.selectionClick();
    try {
      final File? result = await Navigator.of(context).push<File>(
        MaterialPageRoute(
          builder: (context) => DocumentCameraScreen(
            docType: _selectedDocType ?? 'Aadhaar Card',
            isFront: isFront,
          ),
        ),
      );

      if (result != null && mounted) {
        setState(() {
          if (isFront) {
            _frontImage = result;
          } else {
            _backImage = result;
          }
        });
      }
    } catch (e) {
      AppLogger.error('GovtIdVerificationScreen', 'Error picking image: $e');
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
          'id_number': _idNumberController.text.trim(),
          'image_urls': uploadedUrls,
        },
      );

      await submitRes.fold(
        onSuccess: (_) async {
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
                              Icons.verified_user_rounded,
                              color: AppColors.categoryLocation,
                              size: 42,
                            ),
                          ),
                          SizedBox(height: 2.h),
                          Text(
                            l10n?.submittedForReview ?? 'Submitted for Review',
                            style: TextStyle(
                              fontSize: AppTypography.headingMedium,
                              fontWeight: AppTypography.black,
                              color: theme.colorScheme.onSurface,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          SizedBox(height: 1.2.h),
                          Text(
                            l10n?.yourDocumentsHaveBeenSubmittedSecurelyWe ??
                                'Your government ID documents have been submitted securely. Our team will verify them shortly.',
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
                                  '+15 Points Pending',
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
                                Navigator.of(dialogContext).pop();
                                Navigator.of(context).pop(true);
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
        },
        onFailure: (error) async =>
            throw Exception('Submission failed: $error'),
      );
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        AppFeedback.showError(
          context,
          e,
          contextTag: 'verification',
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      appBar: CustomAppBar(
        title: l10n?.govtIdVerification ?? 'Government ID Verification',
      ),
      body: SafeArea(
        child: Column(
          children: [
            _buildStepperHeader(),
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(horizontal: 5.w, vertical: 2.h),
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 350),
                  transitionBuilder: (child, animation) {
                    return SlideTransition(
                      position: Tween<Offset>(
                        begin: const Offset(0.08, 0.0),
                        end: Offset.zero,
                      ).animate(CurvedAnimation(
                        parent: animation,
                        curve: Curves.easeOutCubic,
                      )),
                      child: FadeTransition(
                        opacity: animation,
                        child: child,
                      ),
                    );
                  },
                  child: KeyedSubtree(
                    key: ValueKey<int>(_currentStep),
                    child: _buildCurrentStep(),
                  ),
                ),
              ),
            ),
            _buildBottomBar(),
          ],
        ),
      ),
    );
  }

  Widget _buildStepperHeader() {
    final theme = Theme.of(context);
    final steps = ['Document', 'Photos', 'ID Number', 'Review'];

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 5.w, vertical: 1.5.h),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        border: Border(
          bottom: BorderSide(
            color: theme.colorScheme.outline.withValues(alpha: AppColors.opacity8),
          ),
        ),
      ),
      child: Row(
        children: List.generate(steps.length, (index) {
          final isCompleted = index < _currentStep;
          final isCurrent = index == _currentStep;
          final color = isCompleted || isCurrent
              ? theme.colorScheme.primary
              : theme.colorScheme.outline.withValues(alpha: AppColors.opacity30);

          return Expanded(
            child: Row(
              children: [
                Container(
                  width: 26,
                  height: 26,
                  decoration: BoxDecoration(
                    color: isCompleted
                        ? theme.colorScheme.primary
                        : (isCurrent
                            ? theme.colorScheme.primary.withValues(alpha: AppColors.opacity15)
                            : Colors.transparent),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: color,
                      width: 2,
                    ),
                  ),
                  child: Center(
                    child: isCompleted
                        ? const Icon(Icons.check, size: 14, color: Colors.white)
                        : Text(
                            '${index + 1}',
                            style: TextStyle(
                              color: isCurrent
                                  ? theme.colorScheme.primary
                                  : theme.colorScheme.onSurfaceVariant,
                              fontSize: AppTypography.labelSmall,
                              fontWeight: AppTypography.bold,
                            ),
                          ),
                  ),
                ),
                if (index < steps.length - 1)
                  Expanded(
                    child: Container(
                      height: 3,
                      margin: EdgeInsets.symmetric(horizontal: 1.5.w),
                      decoration: BoxDecoration(
                        color: isCompleted
                            ? theme.colorScheme.primary
                            : theme.colorScheme.outline.withValues(alpha: AppColors.opacity15),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
              ],
            ),
          );
        }),
      ),
    );
  }

  Widget _buildCurrentStep() {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);

    switch (_currentStep) {
      case 0: // Step 1: Select Document Type
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary.withValues(alpha: AppColors.opacity10),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.security_rounded,
                  size: 32,
                  color: theme.colorScheme.primary,
                ),
              ),
            ),
            SizedBox(height: 2.h),
            Center(
              child: Text(
                l10n?.selectDocumentType ?? 'Select Document Type',
                style: TextStyle(
                  fontSize: AppTypography.headingMedium,
                  fontWeight: AppTypography.black,
                  color: theme.colorScheme.onSurface,
                ),
              ),
            ),
            SizedBox(height: 1.h),
            Center(
              child: Text(
                'Choose an official government ID for instant trust verification.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: AppTypography.bodyMedium,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ),
            SizedBox(height: 3.h),
            ..._docTypes.map((doc) {
              final isSelected = _selectedDocType == doc['title'];
              return Container(
                margin: EdgeInsets.only(bottom: 1.5.h),
                decoration: BoxDecoration(
                  color: isSelected
                      ? theme.colorScheme.primary.withValues(alpha: 0.06)
                      : theme.cardColor,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: isSelected
                        ? theme.colorScheme.primary
                        : theme.colorScheme.outline.withValues(alpha: AppColors.opacity15),
                    width: isSelected ? 2 : 1,
                  ),
                ),
                child: Material(
                  color: Colors.transparent,
                  borderRadius: BorderRadius.circular(16),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(16),
                    onTap: () {
                      HapticFeedback.selectionClick();
                      setState(() => _selectedDocType = doc['title'] as String);
                    },
                    child: Padding(
                      padding: EdgeInsets.all(4.w),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? theme.colorScheme.primary.withValues(alpha: AppColors.opacity15)
                                  : theme.colorScheme.surfaceContainerHighest,
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              doc['icon'] as IconData,
                              color: isSelected
                                  ? theme.colorScheme.primary
                                  : theme.colorScheme.onSurfaceVariant,
                              size: 24,
                            ),
                          ),
                          SizedBox(width: 3.5.w),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  doc['title'] as String,
                                  style: TextStyle(
                                    fontSize: AppTypography.bodyLarge,
                                    fontWeight: AppTypography.bold,
                                    color: theme.colorScheme.onSurface,
                                  ),
                                ),
                                SizedBox(height: 0.3.h),
                                Text(
                                  doc['subtitle'] as String,
                                  style: TextStyle(
                                    fontSize: AppTypography.bodySmall,
                                    color: theme.colorScheme.onSurfaceVariant,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Radio<String>(
                            value: doc['title'] as String,
                            groupValue: _selectedDocType,
                            onChanged: (val) {
                              HapticFeedback.selectionClick();
                              setState(() => _selectedDocType = val);
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            }),
          ],
        );

      case 1: // Step 2: Upload Photos
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Upload $_selectedDocType Photos',
              style: TextStyle(
                fontSize: AppTypography.headingMedium,
                fontWeight: AppTypography.black,
                color: theme.colorScheme.onSurface,
              ),
            ),
            SizedBox(height: 0.8.h),
            Text(
              'Ensure all details and your photo on the ID are clearly visible without glare.',
              style: TextStyle(
                fontSize: AppTypography.bodyMedium,
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            SizedBox(height: 2.5.h),
            _buildPhotoUploadBox(
              label: l10n?.frontSide ?? 'Front Side',
              image: _frontImage,
              onTap: () => _pickImage(true),
            ),
            if (_selectedDocType == 'Aadhaar Card') ...[
              SizedBox(height: 2.h),
              _buildPhotoUploadBox(
                label: l10n?.backSide ?? 'Back Side',
                image: _backImage,
                onTap: () => _pickImage(false),
              ),
            ],
          ],
        );

      case 2: // Step 3: Enter ID Number
        final hintText = _selectedDocType == 'Aadhaar Card'
            ? '12-digit Aadhaar number'
            : '10-character PAN number';

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Enter $_selectedDocType Number',
              style: TextStyle(
                fontSize: AppTypography.headingMedium,
                fontWeight: AppTypography.black,
                color: theme.colorScheme.onSurface,
              ),
            ),
            SizedBox(height: 0.8.h),
            Text(
              'This number will be securely matched with your ID card photos.',
              style: TextStyle(
                fontSize: AppTypography.bodyMedium,
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            SizedBox(height: 3.h),
            TextField(
              controller: _idNumberController,
              autofocus: true,
              onChanged: (_) => setState(() {}),
              decoration: InputDecoration(
                labelText: l10n?.idNumber ?? 'ID Number',
                hintText: hintText,
                prefixIcon: const Icon(Icons.credit_card_rounded),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                filled: true,
                fillColor: theme.cardColor,
              ),
              textCapitalization: TextCapitalization.characters,
            ),
          ],
        );

      case 3: // Step 4: Review Details
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n?.reviewDetails ?? 'Review Details',
              style: TextStyle(
                fontSize: AppTypography.headingMedium,
                fontWeight: AppTypography.black,
                color: theme.colorScheme.onSurface,
              ),
            ),
            SizedBox(height: 0.8.h),
            Text(
              'Please verify that all submitted details are accurate.',
              style: TextStyle(
                fontSize: AppTypography.bodyMedium,
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            SizedBox(height: 2.5.h),
            Container(
              decoration: BoxDecoration(
                color: theme.cardColor,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: theme.colorScheme.outline.withValues(alpha: AppColors.opacity12),
                ),
              ),
              child: Column(
                children: [
                  ListTile(
                    leading: const Icon(Icons.description_rounded),
                    title: Text(
                      l10n?.documentType ?? 'Document Type',
                      style: TextStyle(
                        fontSize: AppTypography.bodySmall,
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                    subtitle: Text(
                      _selectedDocType ?? '',
                      style: TextStyle(
                        fontSize: AppTypography.bodyMedium,
                        fontWeight: AppTypography.bold,
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: const Icon(Icons.pin_rounded),
                    title: Text(
                      l10n?.idNumber ?? 'ID Number',
                      style: TextStyle(
                        fontSize: AppTypography.bodySmall,
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                    subtitle: Text(
                      _idNumberController.text.trim(),
                      style: TextStyle(
                        fontSize: AppTypography.bodyMedium,
                        fontWeight: AppTypography.bold,
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 2.5.h),
            Text(
              l10n?.photos ?? 'Document Photos',
              style: TextStyle(
                fontWeight: AppTypography.extraBold,
                fontSize: AppTypography.bodyLarge,
              ),
            ),
            SizedBox(height: 1.2.h),
            Row(
              children: [
                if (_frontImage != null)
                  Expanded(
                    child: Container(
                      height: 14.h,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: theme.colorScheme.outline.withValues(alpha: AppColors.opacity20),
                        ),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.file(_frontImage!, fit: BoxFit.cover),
                      ),
                    ),
                  ),
                if (_backImage != null) ...[
                  SizedBox(width: 3.w),
                  Expanded(
                    child: Container(
                      height: 14.h,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: theme.colorScheme.outline.withValues(alpha: AppColors.opacity20),
                        ),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.file(_backImage!, fit: BoxFit.cover),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ],
        );

      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildPhotoUploadBox({
    required String label,
    required File? image,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);

    return Container(
      decoration: BoxDecoration(
        color: image != null
            ? theme.cardColor
            : theme.colorScheme.primary.withValues(alpha: 0.04),
        border: Border.all(
          color: image != null
              ? AppColors.categoryLocation
              : theme.colorScheme.primary.withValues(alpha: AppColors.opacity35),
          width: 1.5,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onTap,
          child: Container(
            height: 18.h,
            width: double.infinity,
            padding: EdgeInsets.all(3.w),
            child: image != null
                ? Stack(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.file(
                          image,
                          fit: BoxFit.cover,
                          width: double.infinity,
                          height: double.infinity,
                        ),
                      ),
                      Positioned(
                        top: 8,
                        right: 8,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.black.withValues(alpha: 0.65),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.edit, size: 14, color: Colors.white),
                              const SizedBox(width: 4),
                              Text(
                                'Retake',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: AppTypography.labelSmall,
                                  fontWeight: AppTypography.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  )
                : Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.primary.withValues(alpha: AppColors.opacity10),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.document_scanner_rounded,
                          size: 32,
                          color: theme.colorScheme.primary,
                        ),
                      ),
                      SizedBox(height: 1.2.h),
                      Text(
                        'Scan $label (Document Camera)',
                        style: TextStyle(
                          color: theme.colorScheme.primary,
                          fontWeight: AppTypography.extraBold,
                          fontSize: AppTypography.bodyMedium,
                        ),
                      ),
                      SizedBox(height: 0.4.h),
                      Text(
                        'Auto-crops ID card frame automatically',
                        style: TextStyle(
                          color: theme.colorScheme.onSurfaceVariant,
                          fontSize: AppTypography.labelSmall,
                        ),
                      ),
                    ],
                  ),
          ),
        ),
      ),
    );
  }

  Widget _buildBottomBar() {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);
    final canProceed = _canProceed();

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 5.w, vertical: 1.5.h),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        border: Border(
          top: BorderSide(
            color: theme.colorScheme.outline.withValues(alpha: AppColors.opacity10),
          ),
        ),
        boxShadow: [
          BoxShadow(
            blurRadius: 10,
            color: theme.shadowColor.withValues(alpha: AppColors.opacity8),
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          if (_currentStep > 0) ...[
            Expanded(
              child: OutlinedButton(
                onPressed: _isLoading ? null : _prevStep,
                style: OutlinedButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: 1.5.h),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: Text(
                  l10n?.back ?? 'Back',
                  style: TextStyle(
                    fontSize: AppTypography.headingSmall,
                    fontWeight: AppTypography.bold,
                  ),
                ),
              ),
            ),
            SizedBox(width: 3.w),
          ],
          Expanded(
            flex: _currentStep > 0 ? 2 : 1,
            child: ElevatedButton(
              onPressed: canProceed && !_isLoading
                  ? (_currentStep == 3 ? _submit : _nextStep)
                  : null,
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(vertical: 1.5.h),
                backgroundColor: _currentStep == 3
                    ? AppColors.categoryLocation
                    : theme.colorScheme.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              child: _isLoading
                  ? SizedBox(
                      width: 2.2.h,
                      height: 2.2.h,
                      child: const CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2.2,
                      ),
                    )
                  : Text(
                      _currentStep == 3
                          ? (l10n?.submitForVerification ?? 'Submit for Verification')
                          : (l10n?.next ?? 'Next'),
                      style: TextStyle(
                        fontSize: AppTypography.headingSmall,
                        fontWeight: AppTypography.bold,
                      ),
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
    if (_currentStep == 2) return _idNumberController.text.trim().isNotEmpty;
    return true;
  }
}
