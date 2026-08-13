import 'package:banjarabio/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:printing/printing.dart';
import 'package:sizer/sizer.dart';

import 'package:banjarabio/core/constants/biodata_templates.dart';
import 'package:banjarabio/core/models/profile_model.dart';
import 'package:banjarabio/core/models/subscription_model.dart';
import 'package:banjarabio/core/repositories/profile_repository.dart';
import 'package:banjarabio/core/repositories/razorpay_repository.dart';
import 'package:banjarabio/core/services/pdf_assets_service.dart';
import 'package:banjarabio/core/services/pdf/biodata_translations.dart';
import 'package:banjarabio/core/services/pdf_service.dart';
import 'package:banjarabio/core/providers/profile_providers.dart';
import 'package:banjarabio/widgets/custom_app_bar.dart';
import 'package:banjarabio/core/models/coupon_model.dart';
import 'package:banjarabio/core/repositories/coupon_repository.dart';
import 'package:banjarabio/routes/app_routes.dart';
import 'package:banjarabio/core/models/subscription_config.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:banjarabio/core/services/app_logger.dart';

/// Biodata PDF screen – uses shared [RazorpayRepository] for unlock payment.
class BiodataPdfScreen extends ConsumerStatefulWidget {
  const BiodataPdfScreen({super.key});

  @override
  ConsumerState<BiodataPdfScreen> createState() =>
      _BiodataPdfScreenState();
}

class _BiodataPdfScreenState
    extends ConsumerState<BiodataPdfScreen> {
  late final ProfileRepository _profileRepository;
  final RazorpayRepository _razorpayRepository = RazorpayRepository();

  ProfileModel? _profile;
  bool _isLoading = true;
  bool _isPaid = false;
  bool _isPaymentInProgress = false;
  Uint8List? _pdfData;
  int _selectedTemplateIndex = 0;

  final TextEditingController _couponController = TextEditingController();
  CouponModel? _appliedCoupon;
  bool _isValidatingCoupon = false;
  final CouponRepository _couponRepository = CouponRepository();

  @override
  void initState() {
    super.initState();
    _profileRepository = ref.read(profileRepositoryProvider);
    _loadData();
  }

  Future<void> _loadData({bool forceRefreshProfile = false}) async {
    setState(() => _isLoading = true);
    try {
      final response = await _profileRepository.getOwnProfile(
        forceRefresh: forceRefreshProfile,
      );
      await response.fold(
        onSuccess: (profile) async {
          if (profile != null) {
            _profile = profile;
            // PDF is FREE for all registered profile owners (Paid only for guests / non-profile users)
            _isPaid = true;
            await _generatePdf();
          }
        },
        onFailure: (_) {},
      );
    } catch (_) {}
    finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _generatePdf() async {
    if (_profile == null) return;
    
    // Capture language code safely
    final locale = Localizations.maybeLocaleOf(context);
    final languageCode = locale?.languageCode ?? 'en';

    final assets = await PdfAssetsService.instance.getPdfAssets(_profile!);
    final template = kBiodataTemplates[_selectedTemplateIndex];

    // Load template background image
    Uint8List? templateImageBytes;
    try {
      final byteData = await rootBundle.load(template.assetPath);
      templateImageBytes = byteData.buffer.asUint8List();
    } catch (e) {
      AppLogger.error('BiodataPdfScreen', 'Error loading template image: $e');
    }

    _pdfData = await PdfService.generateBiodataPdfIsolate(
      _profile!,
      isLocked: !_isPaid,
      logoBytes: assets.logoBytes,
      profilePhotoBytes: assets.profilePhotoBytes,
      templateImageBytes: templateImageBytes,
      accentColor: template.accentColor,
      language: BiodataTranslations.fromLocale(languageCode),
      marginLeft: template.marginLeft,
      marginTop: template.marginTop,
      marginRight: template.marginRight,
      marginBottom: template.marginBottom,
    );
  }

  Future<void> _onTemplateSelected(int index) async {
    if (index == _selectedTemplateIndex) return;
    setState(() {
      _selectedTemplateIndex = index;
      _isLoading = true;
    });
    await _generatePdf();
    if (mounted) setState(() => _isLoading = false);
  }

  Future<void> _startPayment() async {
    if (_isPaymentInProgress || _profile == null) return;
    AppLogger.debug('BiodataPdfScreen', '[RAZORPAY] BiodataPdfScreen > User tapped Pay to unlock');
    setState(() => _isPaymentInProgress = true);

    final tempLocalizations = AppLocalizations.of(context);
    
    int? customAmountPaise;
    if (_appliedCoupon != null) {
      final originalPrice = SubscriptionConfig.biodataUnlock.price;
      final discount = originalPrice * (_appliedCoupon!.discountPercentage / 100);
      customAmountPaise = ((originalPrice - discount) * 100).toInt();
    }

    final response = await _razorpayRepository.startPayment(
      planType: PlanType.biodata_unlock,
      customAmountPaise: customAmountPaise,
    );

    if (mounted) {
      setState(() => _isPaymentInProgress = false);
      if (response.isSuccess) {
        AppLogger.debug('BiodataPdfScreen', '[RAZORPAY] BiodataPdfScreen > Payment SUCCESS | using cached profile (razorpay_repository already applied optimistic unlock)');
        await _loadData();
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(tempLocalizations?.paymentSuccessfulPdfUnlocked ?? 'Payment Successful! PDF Unlocked.'),
            backgroundColor: Colors.green,
          ),
        );
      } else if (!response.errorMessage.toLowerCase().contains('cancelled')) {
        AppLogger.error('BiodataPdfScreen', '[RAZORPAY] BiodataPdfScreen > Payment FAILED | ${response.errorMessage}');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Payment Failed: ${response.errorMessage}'),
            backgroundColor: Colors.red,
            action: response.errorMessage.toLowerCase().contains('timed out')
                ? SnackBarAction(
                    label: AppLocalizations.of(context)?.refresh ?? 'Refresh',
                    textColor: Colors.white,
                    onPressed: () => _loadData(forceRefreshProfile: true),
                  )
                : null,
          ),
        );
      }
    }
  }

  Future<void> _applyCoupon() async {
    final code = _couponController.text.trim();
    if (code.isEmpty) return;

    setState(() => _isValidatingCoupon = true);
    final response = await _couponRepository.validateCoupon(code);

    if (mounted) {
      setState(() => _isValidatingCoupon = false);
      response.fold(
        onSuccess: (coupon) {
          setState(() => _appliedCoupon = coupon);
          Fluttertoast.showToast(
            msg: 'Coupon applied: ${coupon?.discountPercentage}% off!',
            backgroundColor: Colors.green,
            textColor: Colors.white,
          );
        },
        onFailure: (error) {
          setState(() => _appliedCoupon = null);
          Fluttertoast.showToast(
            msg: error,
            backgroundColor: Colors.red,
            textColor: Colors.white,
          );
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: CustomAppBar(title: AppLocalizations.of(context)?.biodataPdf ?? 'Biodata PDF'),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _profile == null
              ? Center(child: Text(AppLocalizations.of(context)?.profileNotFound ?? 'Profile not found'))
              : Column(
                  children: [
                    // Template Selector
                    Container(
                      height: 13.5.h,
                      decoration: BoxDecoration(
                        color: theme.colorScheme.surface,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.08),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: EdgeInsets.fromLTRB(4.w, 0.8.h, 4.w, 0.3.h),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  AppLocalizations.of(context)?.chooseTemplate ?? 'Choose Template',
                                  style: theme.textTheme.labelMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: theme.colorScheme.onSurface,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFFFD700).withValues(alpha: 0.15),
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(color: const Color(0xFFFFD700), width: 0.8),
                                  ),
                                  child: Text(
                                    kBiodataTemplates[_selectedTemplateIndex].name,
                                    style: theme.textTheme.labelSmall?.copyWith(
                                      color: const Color(0xFF800000),
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Expanded(
                            child: ListView.builder(
                              scrollDirection: Axis.horizontal,
                              padding: EdgeInsets.symmetric(horizontal: 3.w),
                              itemCount: kBiodataTemplates.length,
                              itemBuilder: (context, index) {
                                final template = kBiodataTemplates[index];
                                final isSelected = index == _selectedTemplateIndex;

                                // Determine badge tag
                                String? badgeText;
                                if (index == 0) {
                                  badgeText = '👑 VIP';
                                } else if (index == 1) {
                                  badgeText = '🚩 Gor';
                                } else if (index == 2) {
                                  badgeText = '🔥 Popular';
                                }

                                return GestureDetector(
                                  onTap: () => _onTemplateSelected(index),
                                  child: AnimatedScale(
                                    scale: isSelected ? 1.04 : 0.94,
                                    duration: const Duration(milliseconds: 200),
                                    curve: Curves.easeOutCubic,
                                    child: Container(
                                      width: 17.w,
                                      margin: EdgeInsets.symmetric(horizontal: 1.w),
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(12),
                                        border: Border.all(
                                          color: isSelected
                                              ? template.accentColor
                                              : theme.colorScheme.outlineVariant
                                                  .withValues(alpha: 0.3),
                                          width: isSelected ? 2.5 : 1,
                                        ),
                                        boxShadow: isSelected
                                            ? [
                                                BoxShadow(
                                                  color: template.accentColor
                                                      .withValues(alpha: 0.35),
                                                  blurRadius: 10,
                                                  spreadRadius: 1,
                                                  offset: const Offset(0, 2),
                                                ),
                                              ]
                                            : null,
                                      ),
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(10),
                                        child: Stack(
                                          fit: StackFit.expand,
                                          children: [
                                            Image.asset(
                                              template.assetPath,
                                              fit: BoxFit.cover,
                                            ),
                                            if (badgeText != null)
                                              Positioned(
                                                top: 3,
                                                left: 3,
                                                child: Container(
                                                  padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                                                  decoration: BoxDecoration(
                                                    color: Colors.black.withValues(alpha: 0.75),
                                                    borderRadius: BorderRadius.circular(4),
                                                  ),
                                                  child: Text(
                                                    badgeText,
                                                    style: const TextStyle(
                                                      color: Color(0xFFFFD700),
                                                      fontSize: 8,
                                                      fontWeight: FontWeight.bold,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            if (isSelected)
                                              Positioned(
                                                top: 3,
                                                right: 3,
                                                child: Container(
                                                  padding: const EdgeInsets.all(2.5),
                                                  decoration: BoxDecoration(
                                                    color: template.accentColor,
                                                    shape: BoxShape.circle,
                                                  ),
                                                  child: const Icon(
                                                    Icons.check,
                                                    color: Colors.white,
                                                    size: 10,
                                                  ),
                                                ),
                                              ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                          SizedBox(height: 0.5.h),
                        ],
                      ),
                    ),

                    // PDF Preview
                    Expanded(
                      child: Stack(
                        children: [
                          if (_pdfData != null)
                            PdfPreview(
                              build: (format) => _pdfData!,
                              useActions: _isPaid,
                              canChangePageFormat: false,
                              canChangeOrientation: false,
                              canDebug: false,
                              pdfFileName: '${_profile?.fullName ?? "Candidate"}_BanjaraBio_Biodata.pdf',
                              actions: [
                                PdfPreviewAction(
                                  icon: const Icon(Icons.share),
                                  onPressed: (context, build, pageFormat) async {
                                    final pdfBytes = await build(pageFormat);
                                    await Printing.sharePdf(
                                      bytes: pdfBytes,
                                      filename: '${_profile?.fullName ?? "Candidate"}_BanjaraBio_Biodata.pdf',
                                      subject: '🚩 बंजाराबायो (BanjaraBio) मॅट्रीमोनी बायोडाटा',
                                    );
                                  },
                                ),
                              ],
                            )
                          else
                            Center(child: Text(AppLocalizations.of(context)?.failedToGeneratePdfPreview ?? 'Failed to generate PDF preview')),
                          // Live Page Indicator Badge
                          if (_pdfData != null)
                            Positioned(
                              top: 12,
                              right: 12,
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: Colors.black.withValues(alpha: 0.65),
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(color: Colors.white24, width: 0.8),
                                ),
                                child: const Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(Icons.layers_outlined, color: Color(0xFFFFD700), size: 12),
                                    SizedBox(width: 4),
                                    Text(
                                      '2-Page Biodata + Photo',
                                      style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w600),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          if (!_isPaid)
                            Positioned.fill(
                              child: IgnorePointer(
                                child: Container(
                                  color: Colors.black.withValues(alpha: 0.1),
                                ),
                              ),
                            ),
                          if (!_isPaid)
                            Center(
                              child: Card(
                                margin: EdgeInsets.symmetric(horizontal: 10.w),
                                elevation: 12,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: Padding(
                                  padding: EdgeInsets.all(6.w),
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        Icons.lock_outline,
                                        size: 48,
                                        color: Theme.of(context).primaryColor,
                                      ),
                                      SizedBox(height: 2.h),
                                      Text(AppLocalizations.of(context)?.unlockPremiumBiodata ?? 'Unlock Premium Biodata',
                                        style: Theme.of(context)
                                            .textTheme
                                            .titleLarge
                                            ?.copyWith(fontWeight: FontWeight.bold),
                                        textAlign: TextAlign.center,
                                      ),
                                      SizedBox(height: 1.h),
                                      Text(
                                        AppLocalizations.of(context)?.getAProfessionalWellformattedPdfWithoutW ?? 'Get a professional, well-formatted PDF without watermarks and with all details visible.',
                                        textAlign: TextAlign.center,
                                        style: Theme.of(context).textTheme.bodyMedium,
                                      ),
                                      SizedBox(height: 2.h),
                                      // Pro Tip for Free Profile Download
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                                        decoration: BoxDecoration(
                                          color: const Color(0xFFFFD700).withValues(alpha: 0.15),
                                          borderRadius: BorderRadius.circular(10),
                                          border: Border.all(color: const Color(0xFFFFD700), width: 0.8),
                                        ),
                                        child: const Row(
                                          children: [
                                            Icon(Icons.stars, color: Color(0xFF800000), size: 18),
                                            SizedBox(width: 8),
                                            Expanded(
                                              child: Text(
                                                '💡 Profile owners download all PDF templates 100% FREE!',
                                                style: TextStyle(
                                                  color: Color(0xFF800000),
                                                  fontSize: 11,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      SizedBox(height: 2.5.h),
                                      ElevatedButton(
                                        onPressed: () {
                                          Navigator.pushNamed(context, AppRoutes.biodataCreation);
                                        },
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: const Color(0xFF800000),
                                          foregroundColor: Colors.white,
                                          padding: EdgeInsets.symmetric(
                                            horizontal: 6.w,
                                            vertical: 1.2.h,
                                          ),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(30),
                                          ),
                                        ),
                                        child: const Text('✨ Create Free Profile & Download Free'),
                                      ),
                                      SizedBox(height: 1.h),
                                      OutlinedButton(
                                        onPressed:
                                            _isPaymentInProgress ? null : _startPayment,
                                        style: OutlinedButton.styleFrom(
                                          padding: EdgeInsets.symmetric(
                                            horizontal: 6.w,
                                            vertical: 1.2.h,
                                          ),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(30),
                                          ),
                                        ),
                                        child: _isPaymentInProgress
                                            ? SizedBox(
                                                width: 2.5.h,
                                                height: 2.5.h,
                                                child: const CircularProgressIndicator(
                                                  strokeWidth: 2,
                                                ),
                                              )
                                            : Text(_appliedCoupon != null 
                                                ? 'Pay ₹${(SubscriptionConfig.biodataUnlock.price * (1 - _appliedCoupon!.discountPercentage / 100)).toStringAsFixed(0)} Instant Unlock'
                                                : 'Pay ₹199 Instant Guest Download'),
                                      ),
                                      if (!_isPaymentInProgress) ...[
                                        SizedBox(height: 2.h),
                                        Row(
                                          children: [
                                            Expanded(
                                              child: TextField(
                                                controller: _couponController,
                                                decoration: InputDecoration(
                                                  hintText: 'Coupon code',
                                                  isDense: true,
                                                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                                                ),
                                                textCapitalization: TextCapitalization.characters,
                                                onChanged: (v) {
                                                  if (_appliedCoupon != null) {
                                                    setState(() => _appliedCoupon = null);
                                                  }
                                                },
                                              ),
                                            ),
                                            const SizedBox(width: 8),
                                            TextButton(
                                              onPressed: _isValidatingCoupon ? null : _applyCoupon,
                                              child: _isValidatingCoupon 
                                                ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2))
                                                : const Text('Apply'),
                                            ),
                                          ],
                                        ),
                                        if (_appliedCoupon != null)
                                          Padding(
                                            padding: const EdgeInsets.only(top: 4.0),
                                            child: Text(
                                              'Coupon applied! ${_appliedCoupon!.discountPercentage}% off',
                                              style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold, fontSize: 12),
                                            ),
                                          ),
                                      ],
                                      SizedBox(height: 1.h),
                                      TextButton(
                                        onPressed: () => Navigator.pop(context),
                                        child: Text(AppLocalizations.of(context)?.maybeLater ?? 'Maybe Later'),
                                      ),
                                    ],
                                  ),
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
}
