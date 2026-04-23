
import 'package:flutter/foundation.dart';
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
import 'package:banjarabio/core/models/subscription_config.dart';
import 'package:fluttertoast/fluttertoast.dart';

/// Biodata PDF screen – uses shared [RazorpayRepository] for unlock payment.
class BiodataPdfScreenRiverpod extends ConsumerStatefulWidget {
  const BiodataPdfScreenRiverpod({super.key});

  @override
  ConsumerState<BiodataPdfScreenRiverpod> createState() =>
      _BiodataPdfScreenRiverpodState();
}

class _BiodataPdfScreenRiverpodState
    extends ConsumerState<BiodataPdfScreenRiverpod> {
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
            _isPaid = profile.isPdfUnlocked;
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
      debugPrint('Error loading template image: $e');
    }

    _pdfData = await PdfService.generateBiodataPdfIsolate(
      _profile!,
      isLocked: !_isPaid,
      logoBytes: assets.logoBytes,
      profilePhotoBytes: assets.profilePhotoBytes,
      templateImageBytes: templateImageBytes,
      accentColor: template.accentColor,
      language: BiodataTranslations.fromLocale(languageCode),
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
    debugPrint('[RAZORPAY] BiodataPdfScreenRiverpod > User tapped Pay to unlock');
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
        debugPrint('[RAZORPAY] BiodataPdfScreenRiverpod > Payment SUCCESS | using cached profile (razorpay_repository already applied optimistic unlock)');
        await _loadData();
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(tempLocalizations?.paymentSuccessfulPdfUnlocked ?? 'Payment Successful! PDF Unlocked.'),
            backgroundColor: Colors.green,
          ),
        );
      } else if (!response.errorMessage.toLowerCase().contains('cancelled')) {
        debugPrint('[RAZORPAY] BiodataPdfScreenRiverpod > Payment FAILED | ${response.errorMessage}');
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
                      height: 11.h,
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
                            padding: EdgeInsets.fromLTRB(4.w, 1.h, 4.w, 0.5.h),
                            child: Text(AppLocalizations.of(context)?.chooseTemplate ?? 'Choose Template',
                              style: theme.textTheme.labelMedium?.copyWith(
                                fontWeight: FontWeight.w700,
                                color: theme.colorScheme.onSurfaceVariant,
                                letterSpacing: 0.5,
                              ),
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
                                return GestureDetector(
                                  onTap: () => _onTemplateSelected(index),
                                  child: Container(
                                    width: 14.w,
                                    margin: EdgeInsets.symmetric(horizontal: 1.5.w),
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(10),
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
                                                    .withValues(alpha: 0.3),
                                                blurRadius: 8,
                                                offset: const Offset(0, 2),
                                              ),
                                            ]
                                          : null,
                                    ),
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(8),
                                      child: Stack(
                                        fit: StackFit.expand,
                                        children: [
                                          Image.asset(
                                            template.assetPath,
                                            fit: BoxFit.cover,
                                          ),
                                          if (isSelected)
                                            Positioned(
                                              top: 2,
                                              right: 2,
                                              child: Container(
                                                padding: const EdgeInsets.all(2),
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
                            )
                          else
                            Center(child: Text(AppLocalizations.of(context)?.failedToGeneratePdfPreview ?? 'Failed to generate PDF preview')),
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
                                      Text(AppLocalizations.of(context)?.getAProfessionalWellformattedPdfWithoutW ?? 'Get a professional, well-formatted PDF without watermarks and with all details visible.',
                                        textAlign: TextAlign.center,
                                        style: Theme.of(context).textTheme.bodyMedium,
                                      ),
                                      SizedBox(height: 3.h),
                                      ElevatedButton(
                                        onPressed:
                                            _isPaymentInProgress ? null : _startPayment,
                                        style: ElevatedButton.styleFrom(
                                          padding: EdgeInsets.symmetric(
                                            horizontal: 10.w,
                                            vertical: 1.5.h,
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
                                                ? 'Pay ₹${(SubscriptionConfig.biodataUnlock.price * (1 - _appliedCoupon!.discountPercentage / 100)).toStringAsFixed(0)} to Unlock Full PDF'
                                                : AppLocalizations.of(context)?.pay199ToUnlockFullPdf ?? 'Pay ₹199 to Unlock Full PDF'),
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
