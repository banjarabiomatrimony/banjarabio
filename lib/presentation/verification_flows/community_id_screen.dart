// ignore_for_file: deprecated_member_use

import 'dart:io';
import 'package:banjarabio/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';
import 'package:banjarabio/core/models/profile_model.dart';
import 'package:banjarabio/core/repositories/profile_repository.dart';
import 'package:banjarabio/core/repositories/trust_score_repository.dart';
import 'package:banjarabio/core/supabase_client.dart';
import 'package:banjarabio/widgets/custom_app_bar.dart';
import 'package:banjarabio/services/photo_picker_service.dart';
import 'package:banjarabio/core/services/app_logger.dart';
import 'package:banjarabio/core/constants/app_typography.dart';
import 'package:banjarabio/routes/app_routes.dart';
import 'package:banjarabio/theme/app_colors.dart';

class CommunityIdScreen extends StatefulWidget {
  const CommunityIdScreen({super.key});

  @override
  State<CommunityIdScreen> createState() => _CommunityIdScreenState();
}

class _CommunityIdScreenState extends State<CommunityIdScreen>
    with SingleTickerProviderStateMixin {
  final TrustScoreRepository _repository = TrustScoreRepository();
  final ProfileRepository _profileRepository = ProfileRepository();
  final PhotoPickerService _photoService = PhotoPickerService();

  final TextEditingController _memberIdController = TextEditingController();
  final TextEditingController _gotraController = TextEditingController();
  final TextEditingController _villageController = TextEditingController();

  ProfileModel? _profile;
  File? _proofImage;
  bool _isLoading = false;
  bool _isLoadingProfile = true;

  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.06).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _loadProfileData();
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _memberIdController.dispose();
    _gotraController.dispose();
    _villageController.dispose();
    super.dispose();
  }

  Future<void> _loadProfileData() async {
    try {
      final profileRes = await _profileRepository.getOwnProfile();
      profileRes.fold(
        onSuccess: (profile) {
          if (mounted && profile != null) {
            setState(() => _profile = profile);
            if (_gotraController.text.isEmpty && profile.gotra?.isNotEmpty == true) {
              _gotraController.text = profile.gotra!;
            }
            if (_villageController.text.isEmpty) {
              final locationParts = <String>[
                if (profile.village != null && profile.village!.trim().isNotEmpty) profile.village!,
                if (profile.taluka != null && profile.taluka!.trim().isNotEmpty) profile.taluka!,
                if (profile.district != null && profile.district!.trim().isNotEmpty) profile.district!,
              ].join(', ');
              if (locationParts.isNotEmpty) {
                _villageController.text = locationParts;
              }
            }
          }
        },
        onFailure: (_) {},
      );
    } catch (e) {
      AppLogger.error('CommunityIdScreen', 'Error loading profile: $e');
    } finally {
      if (mounted) {
        setState(() => _isLoadingProfile = false);
      }
    }
  }

  Future<void> _showImagePickerSheet() async {
    HapticFeedback.selectionClick();
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        final theme = Theme.of(sheetContext);
        return Container(
          padding: EdgeInsets.symmetric(horizontal: 5.w, vertical: 2.5.h),
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: SafeArea(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.outline.withValues(alpha: AppColors.opacity30),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                SizedBox(height: 2.h),
                Text(
                  'Upload BVS Membership Card',
                  style: TextStyle(
                    fontSize: AppTypography.headingSmall,
                    fontWeight: AppTypography.bold,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
                SizedBox(height: 2.h),
                Row(
                  children: [
                    Expanded(
                      child: InkWell(
                        onTap: () {
                          Navigator.pop(sheetContext);
                          _pickImage(fromCamera: true);
                        },
                        borderRadius: BorderRadius.circular(16),
                        child: Container(
                          padding: EdgeInsets.symmetric(vertical: 2.h),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.primary.withValues(alpha: AppColors.opacity8),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: theme.colorScheme.primary.withValues(alpha: AppColors.opacity20),
                            ),
                          ),
                          child: Column(
                            children: [
                              Icon(
                                Icons.camera_alt_rounded,
                                size: 32,
                                color: theme.colorScheme.primary,
                              ),
                              SizedBox(height: 1.h),
                              Text(
                                'Take Photo',
                                style: TextStyle(
                                  fontSize: AppTypography.bodyMedium,
                                  fontWeight: AppTypography.bold,
                                  color: theme.colorScheme.primary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: 3.w),
                    Expanded(
                      child: InkWell(
                        onTap: () {
                          Navigator.pop(sheetContext);
                          _pickImage(fromCamera: false);
                        },
                        borderRadius: BorderRadius.circular(16),
                        child: Container(
                          padding: EdgeInsets.symmetric(vertical: 2.h),
                          decoration: BoxDecoration(
                            color: AppColors.crimsonDeep.withValues(alpha: AppColors.opacity8),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: AppColors.crimsonDeep.withValues(alpha: AppColors.opacity20),
                            ),
                          ),
                          child: Column(
                            children: [
                              const Icon(
                                Icons.photo_library_rounded,
                                size: 32,
                                color: AppColors.crimsonDeep,
                              ),
                              SizedBox(height: 1.h),
                              Text(
                                'Gallery',
                                style: TextStyle(
                                  fontSize: AppTypography.bodyMedium,
                                  fontWeight: AppTypography.bold,
                                  color: AppColors.crimsonDeep,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 1.h),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _pickImage({required bool fromCamera}) async {
    try {
      final result = fromCamera
          ? await _photoService.pickFromCamera()
          : await _photoService.pickFromGallery();
      if (result.isSuccess && result.filePath != null) {
        setState(() {
          _proofImage = File(result.filePath!);
        });
      }
    } catch (e) {
      AppLogger.error('CommunityIdScreen', 'Error picking image: $e');
    }
  }

  void _launchBvsRegistration() {
    HapticFeedback.lightImpact();
    final langCode = Localizations.localeOf(context).languageCode;
    final url = 'https://banjaravirasat.org.in/join_by_ref.php?ref_by=7020797849&lang=$langCode';
    Navigator.pushNamed(context, AppRoutes.bvsWebView, arguments: url);
  }

  Future<void> _submit() async {
    final userId = AppSupabaseClient.currentUserId;
    if (userId == null) return;

    if (_proofImage == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            AppLocalizations.of(context)?.uploadBvsCardPrompt ??
                'Please upload your Banjara Virasat Sangh (BVS) Membership Card',
          ),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      String? proofUrl;
      final path = '$userId/bvs_card_${DateTime.now().millisecondsSinceEpoch}.jpg';
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

      // If proof upload failed, stop
      if (proofUrl == null) {
        if (mounted) setState(() => _isLoading = false);
        return;
      }

      final submitRes = await _repository.submitVerificationRequest(
        type: 'communityId',
        payload: {
          'bvs_member_id': _memberIdController.text.trim(),
          'gotra': _gotraController.text.trim(),
          'village': _villageController.text.trim(),
          'proof_url': proofUrl,
          'verification_sub_type': 'bvs_membership_card',
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
                              color: AppColors.crimsonDeep.withValues(alpha: AppColors.opacity12),
                              shape: BoxShape.circle,
                            ),
                            child: Center(
                              child: Text(
                                '🚩',
                                style: TextStyle(fontSize: AppTypography.displayLarge),
                              ),
                            ),
                          ),
                          SizedBox(height: 2.h),
                          Text(
                            l10n?.communityIdSubmitted ?? 'BVS Card Submitted',
                            style: TextStyle(
                              fontSize: AppTypography.headingMedium,
                              fontWeight: AppTypography.black,
                              color: theme.colorScheme.onSurface,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          SizedBox(height: 1.2.h),
                          Text(
                            l10n?.weWillVerifyYourCommunityDetailsShortly1 ??
                                'We will verify your BVS Membership Card shortly. +15 Points & ₹200/Year Plan unlocked upon approval.',
                            style: TextStyle(
                              fontSize: AppTypography.bodyMedium,
                              color: theme.colorScheme.onSurfaceVariant,
                              height: 1.45,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          SizedBox(height: 2.h),
                          Wrap(
                            spacing: 2.w,
                            runSpacing: 1.h,
                            alignment: WrapAlignment.center,
                            children: [
                              Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: 3.w,
                                  vertical: 0.8.h,
                                ),
                                decoration: BoxDecoration(
                                  color: AppColors.categoryLocation.withValues(alpha: AppColors.opacity10),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: AppColors.categoryLocation.withValues(alpha: AppColors.opacity30),
                                  ),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(
                                      Icons.stars_rounded,
                                      color: AppColors.categoryLocationDark,
                                      size: 18,
                                    ),
                                    SizedBox(width: 1.5.w),
                                    Text(
                                      '+15 Points Pending',
                                      style: TextStyle(
                                        fontSize: AppTypography.labelMedium,
                                        fontWeight: AppTypography.extraBold,
                                        color: AppColors.categoryLocationDark,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: 3.w,
                                  vertical: 0.8.h,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.amber.withValues(alpha: AppColors.opacity15),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: Colors.amber.withValues(alpha: AppColors.opacity40),
                                  ),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(
                                      Icons.local_offer_rounded,
                                      color: AppColors.amberDark,
                                      size: 16,
                                    ),
                                    SizedBox(width: 1.5.w),
                                    Text(
                                      '₹200/Yr Special Plan',
                                      style: TextStyle(
                                        fontSize: AppTypography.labelMedium,
                                        fontWeight: AppTypography.extraBold,
                                        color: AppColors.amberDark,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
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
                                backgroundColor: AppColors.crimsonDeep,
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
        onFailure: (error) async {
          if (mounted) {
            setState(() => _isLoading = false);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  AppLocalizations.of(context)?.errorWithLabel(error) ??
                      'Submission failed: $error',
                ),
              ),
            );
          }
        },
      );
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              AppLocalizations.of(context)?.errorWithLabel(e.toString()) ??
                  'Error: ${e.toString()}',
            ),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      appBar: CustomAppBar(
        title: l10n?.bvsMembershipCard ?? 'BVS Membership Card',
      ),
      body: SafeArea(
        child: _isLoadingProfile
            ? const Center(child: CircularProgressIndicator())
            : Column(
                children: [
                  Expanded(
                    child: SingleChildScrollView(
                      padding: EdgeInsets.symmetric(horizontal: 5.w, vertical: 2.h),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          _buildAnimatedHeroHeader(theme, l10n),
                          SizedBox(height: 2.5.h),
                          _buildDigitalCardPreview(theme),
                          SizedBox(height: 3.h),
                          _buildInputForm(theme, l10n),
                          SizedBox(height: 2.5.h),
                          _buildPhotoUploadSection(theme, l10n),
                          SizedBox(height: 2.5.h),
                          _buildBvsRegistrationCard(theme, l10n),
                          SizedBox(height: 2.h),
                        ],
                      ),
                    ),
                  ),
                  _buildBottomBar(theme, l10n),
                ],
              ),
      ),
    );
  }

  Widget _buildAnimatedHeroHeader(ThemeData theme, AppLocalizations? l10n) {
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0.0, end: 1.0),
      duration: const Duration(milliseconds: 600),
      curve: Curves.easeOutCubic,
      builder: (context, value, child) {
        return Transform.translate(
          offset: Offset(0, 20 * (1 - value)),
          child: Opacity(
            opacity: value.clamp(0.0, 1.0),
            child: child,
          ),
        );
      },
      child: Container(
        padding: EdgeInsets.all(4.5.w),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [
              AppColors.crimsonDeep, // BVS Crimson
              AppColors.error, // Deep Coral Red
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: AppColors.crimsonDeep.withValues(alpha: AppColors.opacity35),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                ScaleTransition(
                  scale: _pulseAnimation,
                  child: Container(
                    padding: const EdgeInsets.all(3),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Colors.amberAccent,
                        width: 2,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: AppColors.opacity20),
                          blurRadius: 8,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: ClipOval(
                      child: Image.asset(
                        'assets/images/bvs_logo_gold.png',
                        width: 38,
                        height: 38,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => const Icon(
                          Icons.workspace_premium_rounded,
                          color: AppColors.crimsonDeep,
                          size: 32,
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 3.5.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n?.bvsTitle ?? 'बणजारा विरासत संघ',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: AppTypography.headingSmall,
                          fontWeight: AppTypography.black,
                          letterSpacing: 0.5,
                        ),
                      ),
                      SizedBox(height: 0.3.h),
                      Text(
                        l10n?.bvsConceptSubtitle.split('\n').first ??
                            'ना. संजयभाऊ राठोड यांच्या प्रेरणेतून',
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: AppColors.opacity90),
                          fontSize: AppTypography.bodySmall,
                          fontWeight: AppTypography.semiBold,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: 1.6.h),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 3.5.w, vertical: 1.2.h),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: AppColors.opacity15),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.white.withValues(alpha: AppColors.opacity25)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.stars_rounded, color: Colors.amberAccent, size: 22),
                  SizedBox(width: 2.5.w),
                  Expanded(
                    child: Text(
                      l10n?.bvsSubsidyCardSubtitle ??
                          'कार्ड पडताळणीनंतर वार्षिक सबस्क्रिप्शन फक्त ₹२०० मध्ये उपलब्ध!',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: AppTypography.bodyMedium,
                        fontWeight: AppTypography.bold,
                        height: 1.3,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDigitalCardPreview(ThemeData theme) {
    final memberId = _memberIdController.text.trim();
    final name = _profile?.fullName ?? 'Banjara Member';
    final gotra = _gotraController.text.trim().isNotEmpty
        ? _gotraController.text.trim()
        : (_profile?.gotra ?? 'Gor Banjara');
    final location = _villageController.text.trim().isNotEmpty
        ? _villageController.text.trim()
        : (_profile?.locationExcludingVillage ?? 'Maharashtra');

    return Container(
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            AppColors.deepIndigo, // Royal deep violet
            AppColors.deepIndigo,
            AppColors.materialPurpleDark,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.amber.withValues(alpha: AppColors.opacity40), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: AppColors.deepIndigo.withValues(alpha: AppColors.opacity25),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(Icons.credit_card_rounded, color: Colors.amberAccent, size: 18),
                  SizedBox(width: 2.w),
                  Text(
                    'DIGITAL COMMUNITY ID',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: AppTypography.black,
                      fontSize: AppTypography.labelMedium,
                      letterSpacing: 1.0,
                    ),
                  ),
                ],
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 2.5.w, vertical: 0.4.h),
                decoration: BoxDecoration(
                  color: Colors.amber,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  'BVS MEMBER',
                  style: TextStyle(
                    color: Colors.black,
                    fontWeight: AppTypography.black,
                    fontSize: AppTypography.labelSmall,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 1.8.h),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: AppTypography.headingSmall,
                        fontWeight: AppTypography.black,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: 0.4.h),
                    Text(
                      'Gotra: $gotra',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: AppColors.opacity85),
                        fontSize: AppTypography.bodySmall,
                        fontWeight: AppTypography.semiBold,
                      ),
                    ),
                    SizedBox(height: 0.2.h),
                    Text(
                      'Location: $location',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.75),
                        fontSize: AppTypography.labelSmall,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 0.8.h),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: AppColors.opacity12),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.white.withValues(alpha: AppColors.opacity20)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      'ID NUMBER',
                      style: TextStyle(
                        color: Colors.amberAccent,
                        fontSize: AppTypography.labelTiny,
                        fontWeight: AppTypography.bold,
                      ),
                    ),
                    SizedBox(height: 0.2.h),
                    Text(
                      memberId.isNotEmpty ? '#$memberId' : '#405812',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: AppTypography.bodyMedium,
                        fontWeight: AppTypography.black,
                        letterSpacing: 1.0,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInputForm(ThemeData theme, AppLocalizations? l10n) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Membership Details',
          style: TextStyle(
            fontSize: AppTypography.headingSmall,
            fontWeight: AppTypography.extraBold,
            color: theme.colorScheme.onSurface,
          ),
        ),
        SizedBox(height: 1.5.h),
        TextField(
          controller: _memberIdController,
          onChanged: (_) => setState(() {}),
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
            labelText: l10n?.bvsMemberId ?? 'BVS Member ID No (e.g. 405812)',
            hintText: 'उदा. 405812',
            prefixIcon: const Icon(Icons.badge_outlined, color: AppColors.crimsonDeep),
            filled: true,
            fillColor: theme.cardColor,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(color: AppColors.crimsonDeep, width: 2),
            ),
          ),
        ),
        SizedBox(height: 1.5.h),
        TextField(
          controller: _gotraController,
          onChanged: (_) => setState(() {}),
          decoration: InputDecoration(
            labelText: l10n?.gotra ?? 'Gotra',
            prefixIcon: const Icon(Icons.people_outline),
            filled: true,
            fillColor: theme.cardColor,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
            ),
          ),
        ),
        SizedBox(height: 1.5.h),
        TextField(
          controller: _villageController,
          onChanged: (_) => setState(() {}),
          decoration: InputDecoration(
            labelText: l10n?.villageTanda ?? 'Village / Tanda / Location',
            prefixIcon: const Icon(Icons.location_on_outlined),
            filled: true,
            fillColor: theme.cardColor,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPhotoUploadSection(ThemeData theme, AppLocalizations? l10n) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n?.uploadBvsCardPrompt ?? 'Upload your BVS Membership Card Photo',
          style: TextStyle(
            fontSize: AppTypography.headingSmall,
            fontWeight: AppTypography.extraBold,
            color: theme.colorScheme.onSurface,
          ),
        ),
        SizedBox(height: 0.6.h),
        Text(
          'Take a clear photo of your BVS card or upload from gallery.',
          style: TextStyle(
            fontSize: AppTypography.bodySmall,
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        SizedBox(height: 1.5.h),
        Container(
          decoration: BoxDecoration(
            color: _proofImage != null
                ? theme.cardColor
                : AppColors.crimsonDeep.withValues(alpha: 0.04),
            border: Border.all(
              color: _proofImage != null
                  ? AppColors.categoryLocation
                  : AppColors.crimsonDeep.withValues(alpha: AppColors.opacity35),
              width: 1.5,
            ),
            borderRadius: BorderRadius.circular(18),
          ),
          child: Material(
            color: Colors.transparent,
            borderRadius: BorderRadius.circular(18),
            child: InkWell(
              borderRadius: BorderRadius.circular(18),
              onTap: _showImagePickerSheet,
              child: Container(
                height: 22.h,
                width: double.infinity,
                padding: EdgeInsets.all(3.w),
                child: _proofImage != null
                    ? Stack(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(14),
                            child: Image.file(
                              _proofImage!,
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
                                horizontal: 10,
                                vertical: 5,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.black.withValues(alpha: AppColors.opacity70),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(Icons.edit_rounded, size: 14, color: Colors.white),
                                  const SizedBox(width: 4),
                                  Text(
                                    'Retake / Change',
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
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: AppColors.crimsonDeep.withValues(alpha: AppColors.opacity10),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.add_a_photo_rounded,
                              size: 32,
                              color: AppColors.crimsonDeep,
                            ),
                          ),
                          SizedBox(height: 1.2.h),
                          Text(
                            'Tap to Capture or Select Card Photo',
                            style: TextStyle(
                              color: AppColors.crimsonDeep,
                              fontWeight: AppTypography.bold,
                              fontSize: AppTypography.bodyMedium,
                            ),
                          ),
                          SizedBox(height: 0.4.h),
                          Text(
                            'Supports Camera & Gallery (JPG, PNG)',
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
        ),
      ],
    );
  }

  Widget _buildBvsRegistrationCard(ThemeData theme, AppLocalizations? l10n) {
    return Container(
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: theme.colorScheme.outline.withValues(alpha: AppColors.opacity12),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.crimsonDeep.withValues(alpha: AppColors.opacity10),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.app_registration_rounded,
              color: AppColors.crimsonDeep,
              size: 24,
            ),
          ),
          SizedBox(width: 3.5.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Don\'t have a BVS ID yet?',
                  style: TextStyle(
                    fontWeight: AppTypography.bold,
                    fontSize: AppTypography.bodyMedium,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
                SizedBox(height: 0.3.h),
                Text(
                  'Register online in 30 seconds on the official portal.',
                  style: TextStyle(
                    fontSize: AppTypography.bodySmall,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(width: 2.w),
          TextButton(
            onPressed: _launchBvsRegistration,
            style: TextButton.styleFrom(
              foregroundColor: AppColors.crimsonDeep,
              padding: EdgeInsets.symmetric(horizontal: 2.5.w, vertical: 0.8.h),
            ),
            child: const Row(
              children: [
                Text(
                  'Join BVS',
                  style: TextStyle(fontWeight: AppTypography.extraBold),
                ),
                SizedBox(width: 2),
                Icon(Icons.arrow_forward_ios_rounded, size: 12),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomBar(ThemeData theme, AppLocalizations? l10n) {
    final isReady = _proofImage != null;

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
      child: SizedBox(
        width: double.infinity,
        height: 52,
        child: ElevatedButton(
          onPressed: _isLoading ? null : (isReady ? _submit : _showImagePickerSheet),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.crimsonDeep,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
            elevation: 2,
          ),
          child: _isLoading
              ? const SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 2.5,
                  ),
                )
              : Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      isReady ? Icons.verified_user_rounded : Icons.camera_alt_rounded,
                      color: Colors.white,
                      size: 20,
                    ),
                    SizedBox(width: 2.w),
                    Text(
                      isReady
                          ? (l10n?.submitForVerification ?? 'Submit for Verification')
                          : 'Upload Card Photo',
                      style: TextStyle(
                        fontSize: AppTypography.headingSmall,
                        fontWeight: AppTypography.bold,
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}
