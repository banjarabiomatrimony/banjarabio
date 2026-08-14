import 'dart:io';
import 'package:banjarabio/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import 'package:banjarabio/core/repositories/profile_repository.dart';
import 'package:banjarabio/core/repositories/trust_score_repository.dart';
import 'package:banjarabio/core/supabase_client.dart';
import 'package:banjarabio/widgets/custom_app_bar.dart';
import 'package:banjarabio/services/photo_picker_service.dart';
import 'package:banjarabio/core/services/app_logger.dart';
import 'package:banjarabio/core/constants/app_typography.dart';
import 'package:banjarabio/routes/app_routes.dart';

class CommunityIdScreen extends StatefulWidget {
  const CommunityIdScreen({super.key});

  @override
  State<CommunityIdScreen> createState() => _CommunityIdScreenState();
}

class _CommunityIdScreenState extends State<CommunityIdScreen> {
  final TrustScoreRepository _repository = TrustScoreRepository();
  final ProfileRepository _profileRepository = ProfileRepository();
  final PhotoPickerService _photoService = PhotoPickerService();

  final TextEditingController _memberIdController = TextEditingController();
  final TextEditingController _gotraController = TextEditingController();
  final TextEditingController _villageController = TextEditingController();

  File? _proofImage;
  bool _isLoading = false;
  bool _isLoadingProfile = true;

  @override
  void initState() {
    super.initState();
    _loadProfileData();
  }

  Future<void> _loadProfileData() async {
    try {
      final profileRes = await _profileRepository.getOwnProfile();
      profileRes.fold(
        onSuccess: (profile) {
          if (mounted && profile != null) {
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

  @override
  void dispose() {
    _memberIdController.dispose();
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
      AppLogger.error('CommunityIdScreen', 'Error picking image: $e');
    }
  }

  void _launchBvsRegistration() {
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

      await _repository.submitVerificationRequest(
        type: 'communityId',
        payload: {
          'bvs_member_id': _memberIdController.text.trim(),
          'gotra': _gotraController.text.trim(),
          'village': _villageController.text.trim(),
          'proof_url': proofUrl,
          'verification_sub_type': 'bvs_membership_card',
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
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              title: Row(
                children: [
                  const Text('🚩 ', style: TextStyle(fontSize: 22)),
                  Expanded(
                    child: Text(
                      AppLocalizations.of(context)?.communityIdSubmitted ?? 'BVS Card Submitted',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
              content: Text(
                AppLocalizations.of(context)?.weWillVerifyYourCommunityDetailsShortly1 ??
                    'We will verify your BVS Membership Card shortly. +15 Points & ₹200/Year Plan unlocked upon approval.',
              ),
              actions: [
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).primaryColor,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
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

    return Scaffold(
      appBar: CustomAppBar(
        title: AppLocalizations.of(context)?.bvsMembershipCard ?? 'BVS Membership Card',
      ),
      body: _isLoadingProfile
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: 5.w, vertical: 2.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Header Card with Cultural Saffron Gradient
                  Container(
                    padding: EdgeInsets.all(4.w),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [
                          Color(0xFF8B1A2E), // BVS Crimson
                          Color(0xFFC0392B),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF8B1A2E).withValues(alpha: 0.3),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(3),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: Colors.amberAccent,
                                  width: 1.5,
                                ),
                              ),
                              child: ClipOval(
                                child: Image.asset(
                                  'assets/images/bvs_logo_gold.png',
                                  width: 30,
                                  height: 30,
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                            SizedBox(width: 3.w),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    AppLocalizations.of(context)?.bvsTitle ?? 'बणजारा विरासत संघ',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      letterSpacing: 0.5,
                                    ),
                                  ),
                                  Text(
                                    AppLocalizations.of(context)?.bvsConceptSubtitle.split('\n').first ??
                                        'ना. संजयभाऊ राठोड यांच्या संकल्पनेतून',
                                    style: TextStyle(
                                      color: Colors.white.withValues(alpha: 0.85),
                                      fontSize: 11,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 1.5.h),
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.h),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.stars_rounded, color: Colors.amberAccent, size: 20),
                              SizedBox(width: 2.w),
                              Expanded(
                                child: Text(
                                  AppLocalizations.of(context)?.bvsSubsidyCardSubtitle ??
                                      'कार्ड पडताळणीनंतर वार्षिक सबस्क्रिप्शन फक्त ₹२०० मध्ये उपलब्ध!',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: 3.h),

                  // BVS Member ID Field
                  TextField(
                    controller: _memberIdController,
                    decoration: InputDecoration(
                      labelText: AppLocalizations.of(context)?.bvsMemberId ??
                          'BVS Member ID No (e.g. 405812)',
                      hintText: 'उदा. 405812',
                      prefixIcon: const Icon(Icons.badge_outlined, color: Color(0xFF8B1A2E)),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: Color(0xFF8B1A2E), width: 2),
                      ),
                    ),
                  ),
                  SizedBox(height: 2.h),

                  // Gotra Field
                  TextField(
                    controller: _gotraController,
                    decoration: InputDecoration(
                      labelText: AppLocalizations.of(context)?.gotra ?? 'Gotra',
                      prefixIcon: const Icon(Icons.people_outline),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                  SizedBox(height: 2.h),

                  // Village / Tanda Field
                  TextField(
                    controller: _villageController,
                    decoration: InputDecoration(
                      labelText: AppLocalizations.of(context)?.villageTanda ?? 'Village / Tanda / Location',
                      prefixIcon: const Icon(Icons.location_on_outlined),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                  SizedBox(height: 2.5.h),

                  // Upload Card Picker Container
                  Text(
                    AppLocalizations.of(context)?.uploadBvsCardPrompt ??
                        'Upload your BVS Membership Card Photo',
                    style: TextStyle(
                      fontSize: AppTypography.bodyLarge,
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                  SizedBox(height: 1.h),

                  InkWell(
                    onTap: _pickImage,
                    borderRadius: BorderRadius.circular(16),
                    child: Container(
                      height: 24.h,
                      decoration: BoxDecoration(
                        color: Colors.grey[50],
                        border: Border.all(
                          color: _proofImage != null
                              ? const Color(0xFF8B1A2E)
                              : Colors.grey.withValues(alpha: 0.4),
                          width: _proofImage != null ? 2 : 1.5,
                        ),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: _proofImage != null
                          ? Stack(
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(15),
                                  child: Image.file(
                                    _proofImage!,
                                    fit: BoxFit.cover,
                                    width: double.infinity,
                                    height: double.infinity,
                                  ),
                                ),
                                Positioned(
                                  top: 10,
                                  right: 10,
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: Colors.black87,
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        const Icon(Icons.check_circle, color: Colors.greenAccent, size: 16),
                                        const SizedBox(width: 4),
                                        Text(
                                          AppLocalizations.of(context)?.bvsCardSelected ?? 'Card Selected',
                                          style: const TextStyle(color: Colors.white, fontSize: 11),
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
                                    color: const Color(0xFF8B1A2E).withValues(alpha: 0.1),
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    Icons.add_photo_alternate_rounded,
                                    size: 36,
                                    color: Color(0xFF8B1A2E),
                                  ),
                                ),
                                SizedBox(height: 1.2.h),
                                Text(
                                  AppLocalizations.of(context)?.uploadBvsCardPrompt ??
                                      'Upload BVS Membership Card Photo',
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                                ),
                                SizedBox(height: 0.5.h),
                                Text(
                                  AppLocalizations.of(context)?.bvsUploadCardPromptSubtitle ??
                                      'Select card photo from gallery (JPG/PNG)',
                                  style: TextStyle(color: Colors.grey[600], fontSize: 11),
                                ),
                              ],
                            ),
                    ),
                  ),

                  SizedBox(height: 2.h),

                  // Not a BVS member yet? Register here link
                  InkWell(
                    onTap: _launchBvsRegistration,
                    borderRadius: BorderRadius.circular(8),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.open_in_new_rounded, size: 16, color: Color(0xFF8B1A2E)),
                          SizedBox(width: 1.5.w),
                          Text(
                            AppLocalizations.of(context)?.bvsNotRegisteredYet ??
                                'Not a BVS member yet? Register here »',
                            style: const TextStyle(
                              color: Color(0xFF8B1A2E),
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                              decoration: TextDecoration.underline,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  SizedBox(height: 3.h),

                  // Submit Button
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _submit,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF8B1A2E),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        elevation: 3,
                      ),
                      child: _isLoading
                          ? const CircularProgressIndicator(color: Colors.white)
                          : Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(Icons.verified_user_rounded, color: Colors.white, size: 20),
                                SizedBox(width: 2.w),
                                Text(
                                  AppLocalizations.of(context)?.submitForVerification ?? 'Submit for Verification',
                                  style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                    ),
                  ),
                  SizedBox(height: 2.h),
                ],
              ),
            ),
    );
  }
}
