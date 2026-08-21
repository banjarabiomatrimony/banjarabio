import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:sizer/sizer.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:banjarabio/l10n/app_localizations.dart';
import 'package:banjarabio/core/constants/app_typography.dart';
import 'package:banjarabio/core/models/subscription_config.dart';
import 'package:banjarabio/core/models/subscription_model.dart';
import 'package:banjarabio/core/repositories/razorpay_repository.dart';
import 'package:banjarabio/core/repositories/trust_score_repository.dart';
import 'package:banjarabio/routes/app_routes.dart';
import 'package:banjarabio/widgets/custom_app_bar.dart';
import 'package:banjarabio/widgets/tactile/tactile_back_button.dart';
import 'package:banjarabio/widgets/tactile/tactile_pressable.dart';
import 'package:banjarabio/theme/app_colors.dart';
import 'package:banjarabio/theme/app_color_scheme.dart';

class BvsGatewayScreen extends StatefulWidget {
  const BvsGatewayScreen({super.key});

  @override
  State<BvsGatewayScreen> createState() => _BvsGatewayScreenState();
}

class _BvsGatewayScreenState extends State<BvsGatewayScreen>
    with TickerProviderStateMixin {
  final RazorpayRepository _razorpayRepository = RazorpayRepository();
  final TrustScoreRepository _trustScoreRepository = TrustScoreRepository();

  bool _isBvsVerified = false;
  bool _isProcessingPayment = false;

  late AnimationController _entranceController;
  late AnimationController _pulseController;
  late AnimationController _glowController;
  late AnimationController _borderRotateController;
  late AnimationController _sheenController;

  late Animation<double> _fadeAnimation;
  late Animation<Offset> _headerSlide;
  late Animation<Offset> _emblemsSlide;
  late Animation<Offset> _subsidySlide;
  late Animation<Offset> _stepsSlide;
  late Animation<Offset> _whatsappSlide;
  late Animation<Offset> _actionsSlide;
  late Animation<double> _pulseAnimation;
  late Animation<double> _glowAnimation;

  bool _isCopied = false;

  @override
  void initState() {
    super.initState();
    _checkBvsVerificationStatus();

    _entranceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..repeat(reverse: true);

    _glowController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2400),
    )..repeat(reverse: true);

    _borderRotateController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3000),
    )..repeat();

    _sheenController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2500),
    )..repeat();

    _fadeAnimation = CurvedAnimation(
      parent: _entranceController,
      curve: Curves.easeOut,
    );

    _headerSlide = Tween<Offset>(
      begin: const Offset(0, 0.20),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _entranceController,
      curve: const Interval(0.0, 0.35, curve: Curves.easeOutCubic),
    ));

    _emblemsSlide = Tween<Offset>(
      begin: const Offset(0, 0.20),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _entranceController,
      curve: const Interval(0.15, 0.50, curve: Curves.easeOutCubic),
    ));

    _subsidySlide = Tween<Offset>(
      begin: const Offset(0, 0.20),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _entranceController,
      curve: const Interval(0.30, 0.65, curve: Curves.easeOutCubic),
    ));

    _stepsSlide = Tween<Offset>(
      begin: const Offset(0, 0.20),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _entranceController,
      curve: const Interval(0.45, 0.80, curve: Curves.easeOutCubic),
    ));

    _whatsappSlide = Tween<Offset>(
      begin: const Offset(0, 0.20),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _entranceController,
      curve: const Interval(0.60, 0.90, curve: Curves.easeOutCubic),
    ));

    _actionsSlide = Tween<Offset>(
      begin: const Offset(0, 0.20),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _entranceController,
      curve: const Interval(0.70, 1.0, curve: Curves.easeOutCubic),
    ));

    _pulseAnimation = Tween<double>(
      begin: 1.0,
      end: 1.035,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));

    _glowAnimation = Tween<double>(
      begin: 0.3,
      end: 0.8,
    ).animate(CurvedAnimation(
      parent: _glowController,
      curve: Curves.easeInOut,
    ));

    _entranceController.forward();
  }

  @override
  void dispose() {
    _entranceController.dispose();
    _pulseController.dispose();
    _glowController.dispose();
    _borderRotateController.dispose();
    _sheenController.dispose();
    super.dispose();
  }

  Future<void> _checkBvsVerificationStatus() async {
    try {
      final statusRes = await _trustScoreRepository.getVerificationStatus();
      if (mounted && statusRes.isSuccess) {
        setState(() {
          _isBvsVerified = statusRes.data['communityId'] ==
              TrustScoreRepository.statusVerified;
        });
      }
    } catch (_) {}
  }

  Future<void> _handleBvsPlanPurchase(PlanType planType) async {
    if (_isProcessingPayment) return;

    if (!_isBvsVerified) {
      _showBvsVerificationRequiredSheet();
      return;
    }

    setState(() => _isProcessingPayment = true);
    try {
      final response = await _razorpayRepository.startPayment(
        planType: planType,
        entryPoint: 'bvs_gateway',
      );

      if (mounted) {
        if (response.isSuccess) {
          Fluttertoast.showToast(
            msg: AppLocalizations.of(context)?.paymentSuccessfulWelcome(
                    SubscriptionConfig.getDisplayName(
                        planType, AppLocalizations.of(context))) ??
                'Payment successful! BVS Subsidized Plan Activated',
            backgroundColor: Colors.green,
            textColor: Colors.white,
          );
        } else {
          Fluttertoast.showToast(
            msg: response.errorMessage,
            backgroundColor: Theme.of(context).colorScheme.error,
            textColor: Colors.white,
          );
        }
      }
    } catch (e) {
      if (mounted) {
        Fluttertoast.showToast(
          msg: 'Payment error: $e',
          backgroundColor: Theme.of(context).colorScheme.error,
          textColor: Colors.white,
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isProcessingPayment = false);
      }
    }
  }

  void _showBvsVerificationRequiredSheet() {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: EdgeInsets.all(5.w),
        decoration: BoxDecoration(
          color: theme.cardColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: isDark ? 0.4 : 0.1),
              blurRadius: 20,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: theme.colorScheme.onSurface.withValues(alpha: AppColors.opacity20),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            SizedBox(height: 2.5.h),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.crimsonDeep.withValues(alpha: AppColors.opacity12),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.badge_outlined,
                size: 36,
                color: AppColors.crimsonDeep,
              ),
            ),
            SizedBox(height: 1.5.h),
            Text(
              'BVS Member Card Required',
              style: TextStyle(
                fontSize: AppTypography.headingSmall,
                fontWeight: AppTypography.bold,
                color: theme.colorScheme.onSurface,
              ),
            ),
            SizedBox(height: 1.h),
            Text(
              'Subsidized membership plans (₹200/yr & ₹20/mo) are exclusive to registered Banjara Virasat Sangh (BVS) members. Upload your BVS card to verify and unlock this pricing.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: AppTypography.bodySmall,
                color: theme.colorScheme.onSurfaceVariant,
                height: 1.35,
              ),
            ),
            SizedBox(height: 2.5.h),
            SizedBox(
              width: double.infinity,
              child: TactilePressable(
                onTap: () {
                  Navigator.pop(context);
                  Navigator.pushNamed(context, AppRoutes.communityIdVerification).then((_) {
                    _checkBvsVerificationStatus();
                  });
                },
                pressedScale: 0.96,
                child: Container(
                  padding: EdgeInsets.symmetric(vertical: 1.4.h),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [AppColors.crimsonDeep, AppColors.error],
                    ),
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.crimsonDeep.withValues(alpha: AppColors.opacity30),
                        blurRadius: 8,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.badge_outlined, color: Colors.white, size: 20),
                      SizedBox(width: 2.w),
                      Text(
                        l10n?.bvsUploadCardButton ?? '🪪 Upload BVS Card Now',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: AppTypography.bold,
                          fontSize: AppTypography.bodyMedium,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            SizedBox(height: 1.h),
          ],
        ),
      ),
    );
  }

  String _getRegistrationUrl(BuildContext context) {
    final langCode = Localizations.localeOf(context).languageCode;
    return 'https://banjaravirasat.org.in/join_by_ref.php?ref_by=7020797849&lang=$langCode';
  }

  String _getLocalizedWhatsAppMessage(BuildContext context) {
    final langCode = Localizations.localeOf(context).languageCode;
    const playStoreUrl =
        'https://play.google.com/store/apps/details?id=com.avishio.banjarabio&referrer=bvs_ref_7020797849';

    switch (langCode) {
      case 'hi':
        return '''🚩 जय सेवालाल..! 🚩

महाराष्ट्र सरकार के मंत्री माननीय श्री संजयभाऊ राठौड़ की संकल्पना से शुरू हुए "बणजारा विरासत संघ" (BVS) के इस ऐतिहासिक अभियान से जुड़कर बंजारा समाज की एकता और भविष्य को मजबूत करें!

🏛️ 'बंजारा बायो' (BanjaraBio) - बंजारा समाज का आधिकारिक ऑल-इन-वन डिजिटल मंच:
इस एक ही ऐप में समाज के प्रत्येक बंधु के लिए निम्नलिखित सभी सुविधाएं उपलब्ध हैं:

🔹 BVS आधिकारिक डिजिटल सदस्यता पंजीकरण (BVS Membership)
🔹 1-क्लिक में निःशुल्क आकर्षक PDF बायोडाटा निर्माण और WhatsApp शेयरिंग
🔹 देश-विदेश के हजारों उच्चशिक्षित बंजारा युवक-युवतियों के वैवाहिक प्रोफाइल्स
🔹 बेटियों के लिए 100% सुरक्षित और प्राइवेट: बिना मोबाइल नंबर या ईमेल साझा किए सुरक्षित चैट और संपर्क
🔹 बंजारा समाज के विवाह मेलों और आयोजनों की संपूर्ण जानकारी
🔹 5 भाषाओं में उपलब्ध (हिंदी, मराठी, తెలుగు, ಕನ್ನಡ, English)

📲 BVS डिजिटल पंजीकरण और ऐप डाउनलोड लिंक:
$playStoreUrl

अपने तांडे और परिवार के प्रत्येक सदस्य तक यह संदेश अवश्य पहुंचाएं!

धन्यवाद...!
🙏।। विनीत ।। 🙏
Banti Shankar Rathod (7020797849)''';
      case 'te':
        return '''🚩 జై సేవాలాల్..! 🚩

మహారాష్ట్ర ప్రభుత్వ మంత్రి శ్రీ సంజయ్‌భావూ రాథోడ్ గారి సంకల్పంతో ప్రారంభమైన "బంజారా విరాసత్ సంఘ్" (BVS) ఉద్యమంలో చేరి బంజారా సమాజం యొక్క ఐక్యత మరియు భవిష్యత్తును బలోపేతం చేయండి!

🏛️ 'బంజారా బయో' (BanjaraBio) - బంజారా సమాజ అధికారిక ఆల్-ఇన్-వన్ డిజిటల్ వేదిక:
ఈ ఒక్క యాప్‌లోనే సమాజంలోని ప్రతి ఒక్కరికీ క్రింది అద్భుతమైన సేవలు ఉచితంగా లభిస్తాయి:

🔹 BVS అధికారిక డిజిటల్ సభ్యత్వ నమోదు (BVS Membership)
🔹 1-క్లిక్‌తో ఉచిత ఆకర్షణీయమైన PDF బయోడేటా తయారీ & WhatsApp షేరింగ్
🔹 దేశ-విదేశాలలోని వేలాది మంది ఉన్నత విద్యావంతులైన బంజారా వధూవరుల ప్రొఫైల్స్
🔹 యువతులకు 100% సురక్షితం: మొబైల్ నంబర్ లేదా ఈమెయిల్ ఇవ్వకుండానే యాప్‌లో నేరుగా సురక్షిత చాట్
🔹 బంజారా సమాజ వివాహ మేళావా సమాచారం
🔹 5 భాషలలో అందుబాటులో ఉంది (తెలుగు, मराठी, ಕನ್ನಡ, हिंदी, English)

📲 BVS డిజిటల్ రిజిస్ట్రేషన్ & యాప్ డౌన్‌లోడ్ లిಂಕ್:
$playStoreUrl

మీ తాండా మరియు కుటుంబ సభ్యులందరికీ ఈ సందేశాన్ని తప్పక చేరవేయండి!

ధన్యవాదాలు...!
🙏।। వినీతులు ।। 🙏
Banti Shankar Rathod (7020797849)''';
      case 'kn':
        return '''🚩 ಜೈ ಸೇವಾಲಾಲ್..! 🚩

ಮಹಾರಾಷ್ಟ್ರ ಸರ್ಕಾರದ ಸಚಿವರಾದ ಶ್ರೀ ಸಂಜಯಭಾವು ರಾಠೋಡ್ ಅವರ ಪರಿಕಲ್ಪನೆಯಲ್ಲಿ ಪ್ರಾರಂಭವಾದ "ಬಂಜಾರಾ ವಿರಾಸತ್ ಸಂಘ" (BVS) ಚಳವಳಿಗೆ ಸೇರಿ ಬಂಜಾರಾ ಸಮಾಜದ ಐಕ್ಯತೆ ಮತ್ತು ಭವಿಷ್ಯವನ್ನು ಬಲಪಡಿಸಿ!

🏛️ 'ಬಂಜಾರಾ ಬಯೋ' (BanjaraBio) - ಬಂಜಾರಾ ಸಮಾಜದ ಅಧಿಕೃತ ಆಲ್-ಇನ್-ಒನ್ ಡಿಜಿಟಲ್ ವೇದಿಕೆ:
ಈ ಒಂದೇ ಆಪ್‌ನಲ್ಲಿ ಸಮಾಜದ ಪ್ರತಿಯೊಬ್ಬರಿಗೂ ಈ ಕೆಳಗಿನ ಎಲ್ಲಾ ಸೇವೆಗಳು ಉಚಿತವಾಗಿ ಲಭ್ಯವಿದೆ:

🔹 BVS ಅಧಿಕೃತ ಡಿಜಿಟಲ್ ಸದಸ್ಯತ್ವ ನೋಂದಣಿ (BVS Membership)
🔹 1-ಕ್ಲಿಕ್‌ನಲ್ಲಿ ಉಚಿತ ಆಕರ್ಷಕ PDF ಬಯೋಡೇಟಾ ರಚನೆ ಮತ್ತು WhatsApp ಹಂಚಿಕೆ
🔹 ದೇಶ-ವಿದೇಶಗಳಲ್ಲಿರುವ ಸಾವಿರಾರು ಉನ್ನತ ಶಿಕ್ಷಣ ಪಡೆದ ಬಂಜಾರಾ ವಧು-ವರರ ಪ್ರೊಫೈಲ್‌ಗಳು
🔹 ಹೆಣ್ಣುಮಕ್ಕಳಿಗೆ 100% ಸುರಕ್ಷಿತ ಮತ್ತು ಖಾಸಗಿ: ಮೊಬೈಲ್ ನಂಬರ್ ಅಥವಾ ಇಮೇಲ್ ನೀಡದೆ ಆಪ್‌ನಲ್ಲಿ ಸುರಕ್ಷಿತ ಚಾಟ್
🔹 ಬಂಜಾರಾ ಸಮಾಜದ ವಿವಾಹ ಮೇಳಾವಗಳ ಸಂಪೂರ್ಣ ಮಾಹಿತಿ
🔹 5 ಪ್ರಾದೇಶಿಕ ಭಾಷೆಗಳಲ್ಲಿ ಲಭ್ಯ (ಕನ್ನಡ, मराठी, తెలుగు, हिंदी, English)

📲 BVS ಡಿಜಿಟಲ್ ನೋಂದಣಿ ಮತ್ತು ಆಪ್ ಡೌನ್‌ಲೋಡ್ ಲಿಂಕ್:
$playStoreUrl

ನಿಮ್ಮ ತಾಂಡಾ ಮತ್ತು ಕುಟುಂಬದ ಎಲ್ಲ ಸದಸ್ಯರಿಗೂ ಈ ಸಂದೇಶವನ್ನು ತಪ್ಪದೇ ತಲುಪಿಸಿ!

ಧನ್ಯವಾದಗಳು...!
🙏।। ವಿನೀತ ।। 🙏
Banti Shankar Rathod (7020797849)''';
      case 'en':
        return '''🚩 Jai Sevalal..! 🚩

Join "Banjara Virasat Sangh" (BVS), a historic movement envisioned by Maharashtra Cabinet Minister Hon. Shri Sanjaybhau Rathod, to strengthen the unity and heritage of the Banjara community.

🏛️ 'BanjaraBio' - The Official All-in-One Digital Community Platform for Gor Banjara:
Access all community services in one powerful app:

🔹 Official BVS Digital Membership Registration
🔹 1-Click Free Professional PDF Bio-Data Generator & WhatsApp Sharing
🔹 Thousands of Verified Matrimonial Profiles of Banjara Brides & Grooms from across India and worldwide
🔹 100% Privacy Shield for Girls: Connect and chat securely in-app without sharing personal phone numbers or email addresses
🔹 Banjara Vadhu-Var Melava Directory & Community Events
🔹 Available in 5 Regional Languages (Marathi, Telugu, Kannada, Hindi, English)

📲 1-Click BVS Digital Registration & App Download Link:
$playStoreUrl

Please share this message across all your Tanda and family circles!

Thank you...!
🙏 With Regards 🙏
Banti Shankar Rathod (7020797849)''';
      case 'mr':
      default:
        return '''🚩 जय सेवालाल..! 🚩

महाराष्ट्र राज्याचे मंत्री ना. श्री. संजयभाऊ राठोड यांच्या संकल्पनेतून सुरू झालेल्या "बणजारा विरासत संघ" (BVS) या ऐतिहासिक चळवळीत सहभागी होऊन बंजारा समाजाची एकता आणि भवितव्य अधिक मजबूत करा!

🏛️ 'बंजारा बायो' (BanjaraBio) - बंजारा समाजाचे अधिकृत ऑल-इन-वन डिजिटल व्यासपीठ:
या एकाच ॲपमध्ये समाजातील प्रत्येक बांधवासाठी खालील सर्व सुविधा मोफत उपलब्ध आहेत:

🔹 BVS अधिकृत डिजिटल सदस्य नोंदणी (BVS Membership)
🔹 १-क्लिक मोफत सुंदर व आकर्षक PDF बायोडाटा निर्मिती व WhatsApp शेअरिंग
🔹 देश-विदेशातील बंजारा समाजातील हजारो उच्चशिक्षित व अनुरूप वधू-वर प्रोफाइल्स
🔹 मुलींसाठी १००% सुरक्षित व प्रायव्हेट: स्वतःचा मोबाईल नंबर किंवा ईमेल न देता थेट ॲपमध्ये सुरक्षित चॅट व संपर्क
🔹 बंजारा समाज अधिकृत विवाह मेळावे व इव्हेंट्सची संपूर्ण माहिती
🔹 ५ प्रादेशिक भाषांमध्ये उपलब्ध (मराठी, తెలుగు, ಕನ್ನಡ, हिंदी, English)

📲 BVS डिजिटल नोंदणी व ॲप डाउनलोड लिंक:
$playStoreUrl

आपल्या तांड्यातील आणि परिवारातील प्रत्येक बांधवापर्यंत हा संदेश अवश्य पोहोचवा!

धन्यवाद...!
🙏।। विनित ।। 🙏
Banti Shankar Rathod (7020797849)''';
    }
  }

  void _launchRegistration() {
    HapticFeedback.mediumImpact();
    final url = _getRegistrationUrl(context);
    Navigator.pushNamed(context, AppRoutes.bvsWebView, arguments: url);
  }

  Future<void> _shareOnWhatsApp() async {
    HapticFeedback.lightImpact();
    final message = _getLocalizedWhatsAppMessage(context);
    final encoded = Uri.encodeComponent(message.trim());
    final nativeUri = Uri.parse('whatsapp://send?text=$encoded');
    final webUri = Uri.parse('https://wa.me/?text=$encoded');

    try {
      if (await canLaunchUrl(nativeUri)) {
        await launchUrl(nativeUri, mode: LaunchMode.externalApplication);
      } else if (await canLaunchUrl(webUri)) {
        await launchUrl(webUri, mode: LaunchMode.externalApplication);
      }
    } catch (_) {
      if (await canLaunchUrl(webUri)) {
        await launchUrl(webUri, mode: LaunchMode.externalApplication);
      }
    }
  }

  Future<void> _copyReferralMessage() async {
    HapticFeedback.lightImpact();
    final l10n = AppLocalizations.of(context);
    final message = _getLocalizedWhatsAppMessage(context);
    await Clipboard.setData(ClipboardData(text: message));
    if (mounted) {
      setState(() => _isCopied = true);
      Fluttertoast.showToast(
        msg: l10n?.bvsCopyMessageToast ?? '🚩 BVS invite message copied!',
        backgroundColor: AppColors.crimsonDeep,
        textColor: Colors.white,
      );
      Future.delayed(const Duration(seconds: 3), () {
        if (mounted) setState(() => _isCopied = false);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    final titleText = l10n?.bvsTitle ?? 'बणजारा विरासत संघ';
    final conceptText = l10n?.bvsConceptSubtitle ??
        'संकल्पना: ना. श्री. संजयभाऊ राठोड\nमंत्री, मृद व जलसंधारण, महाराष्ट्र राज्य';
    final movementDesc = l10n?.bvsMovementDesc ??
        'बंजारा समाजाची एकता आणि भवितव्य अधिक मजबूत करण्यासाठी एक ऐतिहासिक चळवळ.';
    final officialEmblemsTitle = l10n?.bvsOfficialEmblems ?? 'अधिकृत BVS बोधचिन्हे';
    final unityTitle = l10n?.bvsUnityEmblemTitle ?? 'एकता मुद्रा';
    final unityDesc = l10n?.bvsUnityEmblemDesc ?? 'हातांची साखळी व बंजारा भरतकाम';
    final heritageTitle = l10n?.bvsHeritageEmblemTitle ?? 'वारसा मुद्रा';
    final heritageDesc = l10n?.bvsHeritageEmblemDesc ?? 'पोहरादेवी व १२+ कोटी समाज अस्मिता';
    final subsidyTitle = l10n?.bvsSubsidyCardTitle ?? 'BVS सदस्यांसाठी विशेष सवलत!';
    final subsidySubtitle = l10n?.bvsSubsidyCardSubtitle ?? 'BanjaraBio वर मॅट्रिमोनी सबस्क्रिप्शनमध्ये मोठी बचत!';
    final annualPlanLabel = l10n?.bvsAnnualPlanLabel ?? 'वार्षिक प्लॅन';
    final monthlyPlanLabel = l10n?.bvsMonthlyPlanLabel ?? 'मासिक प्लॅन';
    final annualPrice = l10n?.bvsAnnualPrice ?? '₹२०० / वर्ष';
    final monthlyPrice = l10n?.bvsMonthlyPrice ?? '₹२० / महिना';
    final howToJoinTitle = l10n?.bvsHowToJoinTitle ?? 'BVS सदस्य कसे व्हावे व सवलत कशी मिळवावी?';
    final step1Title = l10n?.bvsStep1Title ?? 'ऑनलाइन नोंदणी करा';
    final step1Desc = l10n?.bvsStep1Desc ?? 'BVS पोर्टलवर आपले नाव व पत्ता नोंदवा.';
    final step2Title = l10n?.bvsStep2Title ?? 'मेंबरशिप कार्ड मिळवा';
    final step2Desc = l10n?.bvsStep2Desc ?? 'आपला अधिकृत BVS मेंबर आयडी व डिजिटल ओळखपत्र प्राप्त करा.';
    final step3Title = l10n?.bvsStep3Title ?? 'BanjaraBio वर कार्ड अपलोड करा';
    final step3Desc = l10n?.bvsStep3Desc ?? 'BVS कार्ड जोडून ₹२००/वर्ष सवलत प्लॅन सक्रिय करा.';
    final whatsAppInviteTitle = l10n?.bvsWhatsAppInviteTitle ?? 'WhatsApp ऑटोमेशन आमंत्रण';
    final shareOnWhatsAppText = l10n?.bvsShareOnWhatsApp ?? 'WhatsApp वर शेअर करा';
    final joinNowButtonText = 'आताच BVS सदस्य व्हा';
    final uploadCardButtonText = 'BVS कार्ड अपलोड करा';

    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: CustomAppBar(
        leading: const TactileBackButton(),
        title: titleText,
        actions: [
          Container(
            margin: EdgeInsets.only(right: 3.w),
            padding: const EdgeInsets.all(2),
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.categoryVip, width: 1.5),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: AppColors.opacity15),
                  blurRadius: 6,
                ),
              ],
            ),
            child: ClipOval(
              child: Image.asset(
                'assets/images/bvs_logo_gold.png',
                width: 28,
                height: 28,
                fit: BoxFit.cover,
              ),
            ),
          ),
        ],
      ),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: EdgeInsets.fromLTRB(4.w, 1.8.h, 4.w, 5.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // ── 1. Animated Imperial Hero Banner ──
              SlideTransition(
                position: _headerSlide,
                child: Container(
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [
                        AppColors.maroonDarkest,
                        AppColors.crimson700,
                        AppColors.error,
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(
                      color: AppColors.categoryVip.withValues(alpha: AppColors.opacity70),
                      width: 1.6,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.crimson700.withValues(alpha: AppColors.opacity35),
                        blurRadius: 22,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Stack(
                    children: [
                      Positioned(
                        right: -20,
                        top: -20,
                        child: Container(
                          width: 120,
                          height: 120,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.amberAccent.withValues(alpha: AppColors.opacity8),
                          ),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.all(5.w),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                ScaleTransition(
                                  scale: _pulseAnimation,
                                  child: Container(
                                    padding: const EdgeInsets.all(3),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                        color: AppColors.categoryVip,
                                        width: 2.2,
                                      ),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withValues(alpha: AppColors.opacity30),
                                          blurRadius: 12,
                                          offset: const Offset(0, 4),
                                        ),
                                      ],
                                    ),
                                    child: ClipOval(
                                      child: Image.asset(
                                        'assets/images/bvs_logo_gold.png',
                                        width: 58,
                                        height: 58,
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                  ),
                                ),
                                SizedBox(width: 3.5.w),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Expanded(
                                            child: Text(
                                              titleText,
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontSize: AppTypography.headingMedium,
                                                fontWeight: AppTypography.bold,
                                                letterSpacing: 0.4,
                                              ),
                                            ),
                                          ),
                                          Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2.5),
                                            decoration: BoxDecoration(
                                              color: AppColors.categoryVip,
                                              borderRadius: BorderRadius.circular(6),
                                              boxShadow: [
                                                BoxShadow(
                                                  color: Colors.amber.withValues(alpha: AppColors.opacity40),
                                                  blurRadius: 6,
                                                ),
                                              ],
                                            ),
                                            child: Text(
                                              'BVS VIP',
                                              style: TextStyle(
                                                color: AppColors.maroonDarkest,
                                                fontSize: AppTypography.bodySmall,
                                                fontWeight: AppTypography.black,
                                                letterSpacing: 0.5,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 5),
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                        decoration: BoxDecoration(
                                          color: Colors.white.withValues(alpha: AppColors.opacity12),
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                        child: Text(
                                          conceptText,
                                          style: TextStyle(
                                            color: Colors.white.withValues(alpha: 0.95),
                                            fontSize: AppTypography.bodySmall,
                                            height: 1.35,
                                            fontWeight: AppTypography.medium,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 1.8.h),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.14),
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(
                                  color: Colors.white.withValues(alpha: 0.22),
                                ),
                              ),
                              child: Row(
                                children: [
                                  Text('🚩', style: TextStyle(fontSize: AppTypography.headingSmall)),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      movementDesc,
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: AppTypography.bodyMedium,
                                        height: 1.35,
                                        fontWeight: AppTypography.medium,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              SizedBox(height: 2.2.h),

              // ── 2. Official Emblems Spotlight ──
              SlideTransition(
                position: _emblemsSlide,
                child: Container(
                  padding: EdgeInsets.all(4.w),
                  decoration: BoxDecoration(
                    color: theme.cardColor,
                    borderRadius: BorderRadius.circular(22),
                    border: Border.all(
                      color: isDark
                          ? AppColors.crimsonDeep.withValues(alpha: AppColors.opacity35)
                          : AppColors.crimsonDeep.withValues(alpha: 0.16),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.04),
                        blurRadius: 14,
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
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: AppColors.crimsonDeep.withValues(alpha: AppColors.opacity12),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.verified_rounded,
                              color: AppColors.crimsonDeep,
                              size: 18,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            officialEmblemsTitle,
                            style: TextStyle(
                              fontWeight: AppTypography.bold,
                              fontSize: AppTypography.bodyLarge,
                              color: isDark ? AppColors.primaryDarkContrast : AppColors.wineDark,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 1.6.h),
                      Row(
                        children: [
                          // 1. Diamond Unity Logo
                          Expanded(
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: isDark
                                      ? [AppColors.surfaceDark, AppColors.canvasDark]
                                      : [AppColors.canvasLight, AppColors.neutral200],
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                ),
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: AppColors.crimsonDeep.withValues(alpha: AppColors.opacity25),
                                ),
                              ),
                              child: Column(
                                children: [
                                  Container(
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(12),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withValues(alpha: AppColors.opacity15),
                                          blurRadius: 8,
                                          offset: const Offset(0, 3),
                                        ),
                                      ],
                                    ),
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(12),
                                      child: Image.asset(
                                        'assets/images/bvs_logo_unity.jpg',
                                        width: 68,
                                        height: 68,
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 9),
                                  Text(
                                    unityTitle,
                                    style: TextStyle(
                                      fontWeight: AppTypography.bold,
                                      fontSize: AppTypography.bodyMedium,
                                      color: isDark ? Colors.white : AppColors.wineDark,
                                    ),
                                  ),
                                  const SizedBox(height: 3),
                                  Text(
                                    unityDesc,
                                    textAlign: TextAlign.center,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      fontSize: AppTypography.bodySmall,
                                      color: theme.colorScheme.onSurfaceVariant,
                                      height: 1.25,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          SizedBox(width: 3.w),
                          // 2. Gold Heritage Insignia
                          Expanded(
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: isDark
                                      ? [AppColors.surfaceDark, AppColors.canvasDark]
                                      : [AppColors.goldLight, AppColors.goldLight],
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                ),
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: AppColors.categoryVip.withValues(alpha: AppColors.opacity50),
                                ),
                              ),
                              child: Column(
                                children: [
                                  Container(
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.amber.withValues(alpha: AppColors.opacity25),
                                          blurRadius: 8,
                                          offset: const Offset(0, 3),
                                        ),
                                      ],
                                    ),
                                    child: ClipOval(
                                      child: Image.asset(
                                        'assets/images/bvs_logo_gold.png',
                                        width: 68,
                                        height: 68,
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 9),
                                  Text(
                                    heritageTitle,
                                    style: TextStyle(
                                      fontWeight: AppTypography.bold,
                                      fontSize: AppTypography.bodyMedium,
                                      color: isDark ? AppColors.categoryVip : AppColors.crimsonDeep,
                                    ),
                                  ),
                                  const SizedBox(height: 3),
                                  Text(
                                    heritageDesc,
                                    textAlign: TextAlign.center,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      fontSize: AppTypography.bodySmall,
                                      color: theme.colorScheme.onSurfaceVariant,
                                      height: 1.25,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              SizedBox(height: 2.2.h),

              // ── 3. Animated Glowing VIP Subsidy Card ──
              SlideTransition(
                position: _subsidySlide,
                child: ScaleTransition(
                  scale: _pulseAnimation,
                  child: AnimatedBuilder(
                    animation: _glowAnimation,
                    builder: (context, child) {
                      return Container(
                        padding: EdgeInsets.symmetric(horizontal: 4.5.w, vertical: 2.2.h),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: isDark
                                ? const [
                                    AppColors.warmDarkText,
                                    AppColors.canvasDark,
                                    AppColors.amberBrownBg,
                                  ]
                                : const [
                                    AppColors.goldLight,
                                    AppColors.goldLight,
                                    AppColors.goldTint200,
                                  ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(22),
                          border: Border.all(
                            color: Color.lerp(
                              AppColors.amber600,
                              AppColors.categoryVip,
                              _glowAnimation.value,
                            )!,
                            width: 2.0,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.amber.withValues(alpha: _glowAnimation.value * (isDark ? 0.25 : 0.4)),
                              blurRadius: 18,
                              offset: const Offset(0, 6),
                            ),
                          ],
                        ),
                        child: child,
                      );
                    },
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: const BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [AppColors.categoryAstro, AppColors.materialOrange],
                                ),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.auto_awesome,
                                color: AppColors.maroonDarkest,
                                size: 22,
                              ),
                            ),
                            SizedBox(width: 3.5.w),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    '👑 $subsidyTitle',
                                    style: TextStyle(
                                      color: isDark ? AppColors.categoryVip : AppColors.wineDark,
                                      fontSize: AppTypography.headingSmall,
                                      fontWeight: AppTypography.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    subsidySubtitle,
                                    style: TextStyle(
                                      color: isDark ? Colors.white70 : AppColors.neutral800,
                                      fontSize: AppTypography.bodyMedium,
                                      fontWeight: AppTypography.medium,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 1.8.h),
                        Row(
                          children: [
                            // ─── Annual Plan (₹200/year) ───
                            Expanded(
                              child: TactilePressable(
                                onTap: () => _handleBvsPlanPurchase(PlanType.mass_market_annual),
                                pressedScale: 0.96,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
                                  decoration: BoxDecoration(
                                    color: isDark ? AppColors.canvasDark : Colors.white,
                                    borderRadius: BorderRadius.circular(14),
                                    border: Border.all(color: Colors.amber.shade400, width: 1.5),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.04),
                                        blurRadius: 8,
                                      ),
                                    ],
                                  ),
                                  child: Column(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                        decoration: BoxDecoration(
                                          color: isDark
                                              ? AppColors.darkForest2
                                              : AppColors.greenLightBg,
                                          borderRadius: BorderRadius.circular(4),
                                        ),
                                        child: Text(
                                          'सर्वोत्कृष्ट बचत • Best Value',
                                          style: TextStyle(
                                            fontSize: AppTypography.labelSmall,
                                            fontWeight: AppTypography.bold,
                                            color: context.colors.success,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        annualPlanLabel,
                                        style: TextStyle(
                                          fontSize: AppTypography.bodyMedium,
                                          fontWeight: AppTypography.semiBold,
                                          color: theme.colorScheme.onSurface,
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        annualPrice,
                                        style: TextStyle(
                                          fontSize: AppTypography.headingMedium,
                                          fontWeight: AppTypography.bold,
                                          color: isDark ? AppColors.primaryDarkContrast : AppColors.crimsonDeep,
                                        ),
                                      ),
                                      const SizedBox(height: 6),
                                      Container(
                                        width: double.infinity,
                                        padding: const EdgeInsets.symmetric(vertical: 6),
                                        decoration: BoxDecoration(
                                          gradient: const LinearGradient(
                                            colors: [AppColors.categoryAstro, AppColors.materialOrange],
                                          ),
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                        child: Center(
                                          child: Text(
                                            _isBvsVerified ? 'Buy Plan • ₹200' : 'Unlock with BVS',
                                            style: TextStyle(
                                              color: AppColors.maroonDarkest,
                                              fontWeight: AppTypography.bold,
                                              fontSize: AppTypography.labelSmall,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(width: 2.5.w),
                            // ─── Monthly Plan (₹20/month) ───
                            Expanded(
                              child: TactilePressable(
                                onTap: () => _handleBvsPlanPurchase(PlanType.mass_market),
                                pressedScale: 0.96,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
                                  decoration: BoxDecoration(
                                    color: isDark ? AppColors.canvasDark : Colors.white,
                                    borderRadius: BorderRadius.circular(14),
                                    border: Border.all(color: Colors.amber.shade300, width: 1.2),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.04),
                                        blurRadius: 8,
                                      ),
                                    ],
                                  ),
                                  child: Column(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                        decoration: BoxDecoration(
                                          color: isDark
                                              ? AppColors.amberBgDark
                                              : AppColors.goldLight,
                                          borderRadius: BorderRadius.circular(4),
                                        ),
                                        child: Text(
                                          'दर महिना • Flexible',
                                          style: TextStyle(
                                            fontSize: AppTypography.labelSmall,
                                            fontWeight: AppTypography.bold,
                                            color: isDark ? AppColors.warningDark : AppColors.deepOrange,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        monthlyPlanLabel,
                                        style: TextStyle(
                                          fontSize: AppTypography.bodyMedium,
                                          fontWeight: AppTypography.semiBold,
                                          color: theme.colorScheme.onSurface,
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        monthlyPrice,
                                        style: TextStyle(
                                          fontSize: AppTypography.headingMedium,
                                          fontWeight: AppTypography.bold,
                                          color: isDark ? AppColors.primaryDarkContrast : AppColors.crimsonDeep,
                                        ),
                                      ),
                                      const SizedBox(height: 6),
                                      Container(
                                        width: double.infinity,
                                        padding: const EdgeInsets.symmetric(vertical: 6),
                                        decoration: BoxDecoration(
                                          color: isDark
                                              ? Colors.white.withValues(alpha: AppColors.opacity10)
                                              : AppColors.crimsonDeep.withValues(alpha: AppColors.opacity10),
                                          borderRadius: BorderRadius.circular(8),
                                          border: Border.all(
                                            color: isDark ? Colors.amber.shade400 : AppColors.crimsonDeep,
                                          ),
                                        ),
                                        child: Center(
                                          child: Text(
                                            _isBvsVerified ? 'Buy Plan • ₹20' : 'Unlock with BVS',
                                            style: TextStyle(
                                              color: isDark ? Colors.amber.shade200 : AppColors.crimsonDeep,
                                              fontWeight: AppTypography.bold,
                                              fontSize: AppTypography.labelSmall,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              SizedBox(height: 2.2.h),

              // ── 4. Interactive Visual Stepper Pathway ──
              SlideTransition(
                position: _stepsSlide,
                child: Container(
                  padding: EdgeInsets.all(4.5.w),
                  decoration: BoxDecoration(
                    color: theme.cardColor,
                    borderRadius: BorderRadius.circular(22),
                    border: Border.all(
                      color: isDark
                          ? theme.colorScheme.outlineVariant.withValues(alpha: AppColors.opacity30)
                          : Colors.grey.withValues(alpha: AppColors.opacity20),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.04),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.lightbulb_outline_rounded, color: AppColors.deepOrange, size: 20),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              howToJoinTitle,
                              style: TextStyle(
                                fontWeight: AppTypography.bold,
                                fontSize: AppTypography.bodyLarge,
                                color: theme.colorScheme.onSurface,
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 1.8.h),
                      _buildTimelineStep(
                        stepNum: '1',
                        icon: Icons.app_registration_rounded,
                        title: step1Title,
                        desc: step1Desc,
                        isLast: false,
                        isDark: isDark,
                        theme: theme,
                      ),
                      _buildTimelineStep(
                        stepNum: '2',
                        icon: Icons.badge_outlined,
                        title: step2Title,
                        desc: step2Desc,
                        isLast: false,
                        isDark: isDark,
                        theme: theme,
                      ),
                      _buildTimelineStep(
                        stepNum: '3',
                        icon: Icons.verified_user_rounded,
                        title: step3Title,
                        desc: step3Desc,
                        isLast: true,
                        isDark: isDark,
                        theme: theme,
                      ),
                    ],
                  ),
                ),
              ),

              SizedBox(height: 2.2.h),

              // ── 5. WhatsApp Referral Live Preview Card ──
              SlideTransition(
                position: _whatsappSlide,
                child: Container(
                  padding: EdgeInsets.all(4.w),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: isDark
                          ? const [AppColors.darkForest1, AppColors.canvasDark]
                          : const [AppColors.greenLightBg, AppColors.sageGreenBorder],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(22),
                    border: Border.all(
                      color: AppColors.whatsapp.withValues(alpha: isDark ? 0.35 : 0.5),
                      width: 1.2,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.whatsapp.withValues(alpha: isDark ? 0.18 : 0.12),
                        blurRadius: 14,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Image.asset(
                            'assets/icons/whatsapp_icon.png',
                            width: 22,
                            height: 22,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              whatsAppInviteTitle,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontWeight: AppTypography.bold,
                                fontSize: AppTypography.bodyLarge,
                                color: isDark ? AppColors.green300 : AppColors.whatsappDark,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: AppColors.whatsapp.withValues(alpha: AppColors.opacity20),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              'Auto Invite',
                              style: TextStyle(
                                fontSize: AppTypography.bodySmall,
                                fontWeight: AppTypography.bold,
                                color: isDark ? AppColors.green300 : AppColors.whatsappDark,
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 1.4.h),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: isDark ? AppColors.canvasNearBlack : Colors.white,
                          borderRadius: BorderRadius.circular(14),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.05),
                              blurRadius: 6,
                            ),
                          ],
                        ),
                        child: Text(
                          _getLocalizedWhatsAppMessage(context),
                          maxLines: 5,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: AppTypography.bodyMedium,
                            color: isDark ? Colors.white : Colors.black87,
                            height: 1.35,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              SizedBox(height: 2.8.h),

              // ── 6. Shining Running-Colors "Join BVS Today" Action Dock ──
              SlideTransition(
                position: _actionsSlide,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Action 1: Shining Running-Colors Circular Glow Card
                    TactilePressable(
                      onTap: _launchRegistration,
                      pressedScale: 0.97,
                      child: _buildShiningRunningColorJoinCard(
                        buttonText: joinNowButtonText,
                      ),
                    ),

                    SizedBox(height: 1.8.h),

                    // Action 2: WhatsApp Share Automation + Copy Message Row
                    Row(
                      children: [
                        Expanded(
                          flex: 4,
                          child: TactilePressable(
                            onTap: _shareOnWhatsApp,
                            pressedScale: 0.96,
                            child: Container(
                              padding: EdgeInsets.symmetric(vertical: 1.6.h),
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  colors: [AppColors.whatsapp, AppColors.whatsappDark],
                                ),
                                borderRadius: BorderRadius.circular(16),
                                boxShadow: [
                                  BoxShadow(
                                    color: AppColors.whatsapp.withValues(alpha: AppColors.opacity40),
                                    blurRadius: 10,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Image.asset(
                                    'assets/icons/whatsapp_icon.png',
                                    width: 20,
                                    height: 20,
                                  ),
                                  SizedBox(width: 2.w),
                                  Flexible(
                                    child: Text(
                                      shareOnWhatsAppText,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        fontWeight: AppTypography.bold,
                                        fontSize: AppTypography.bodyLarge,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        SizedBox(width: 2.5.w),
                        Expanded(
                          child: TactilePressable(
                            onTap: _copyReferralMessage,
                            pressedScale: 0.92,
                            child: Container(
                              padding: EdgeInsets.symmetric(vertical: 1.6.h),
                              decoration: BoxDecoration(
                                color: _isCopied
                                    ? Colors.green.withValues(alpha: AppColors.opacity15)
                                    : (isDark ? AppColors.surfaceDark30 : Colors.white),
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: _isCopied
                                      ? Colors.green
                                      : (isDark ? Colors.white24 : Colors.grey.withValues(alpha: AppColors.opacity40)),
                                  width: 1.5,
                                ),
                              ),
                              child: Center(
                                child: Icon(
                                  _isCopied ? Icons.check_circle : Icons.copy_rounded,
                                  color: _isCopied
                                      ? Colors.green
                                      : (isDark ? Colors.white70 : Colors.grey[700]),
                                  size: 20,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),

                    SizedBox(height: 1.5.h),

                    // Action 3: Upload BVS Card for Discount
                    TactilePressable(
                      onTap: () {
                        HapticFeedback.lightImpact();
                        Navigator.pushNamed(context, AppRoutes.communityIdVerification);
                      },
                      pressedScale: 0.96,
                      child: Container(
                        padding: EdgeInsets.symmetric(vertical: 1.6.h),
                        decoration: BoxDecoration(
                          color: isDark ? AppColors.surfaceDark30 : Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: AppColors.crimsonDeep,
                            width: 1.6,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.crimsonDeep.withValues(alpha: isDark ? 0.2 : 0.08),
                              blurRadius: 10,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: Center(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.badge_outlined, size: 20, color: AppColors.crimsonDeep),
                              SizedBox(width: 2.w),
                              Text(
                                '🪪 $uploadCardButtonText',
                                style: TextStyle(
                                  fontWeight: AppTypography.bold,
                                  fontSize: AppTypography.bodyLarge,
                                  color: isDark ? AppColors.primaryDarkContrast : AppColors.crimsonDeep,
                                ),
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
        ),
      ),
    );
  }

  /// 🌟 Ultra-Visible Shining Running Colors Hero Card
  Widget _buildShiningRunningColorJoinCard({
    required String buttonText,
  }) {
    return AnimatedBuilder(
      animation: Listenable.merge([_borderRotateController, _sheenController]),
      builder: (context, child) {
        return CustomPaint(
          painter: _RunningGradientBorderPainter(
            animationPercent: _borderRotateController.value,
          ),
          child: Container(
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [
                  AppColors.maroonDarkest, // Deepest Royal Maroon
                  AppColors.wineDark, // Vibrant BVS Crimson
                  AppColors.primary, // Imperial Wine Red
                  AppColors.error, // Saffron Flame
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(22),
              boxShadow: [
                BoxShadow(
                  color: AppColors.categoryVip.withValues(alpha: AppColors.opacity35),
                  blurRadius: 18,
                  spreadRadius: 1,
                  offset: const Offset(0, 4),
                ),
                BoxShadow(
                  color: AppColors.crimsonDeep.withValues(alpha: AppColors.opacity50),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: _launchRegistration,
                borderRadius: BorderRadius.circular(22),
                child: Stack(
                  children: [
                    // Moving Light Sheen Streak
                    Positioned.fill(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(22),
                        child: CustomPaint(
                          painter: _LightSheenPainter(
                            progress: _sheenController.value,
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 4.5.w, vertical: 2.h),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Row(
                            children: [
                              // Pulsing Logo with Online Badge
                              Stack(
                                clipBehavior: Clip.none,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(3),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                        color: AppColors.categoryVip,
                                        width: 2.2,
                                      ),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.amber.withValues(alpha: AppColors.opacity60),
                                          blurRadius: 10,
                                        ),
                                      ],
                                    ),
                                    child: ClipOval(
                                      child: Image.asset(
                                        'assets/images/bvs_logo_gold.png',
                                        width: 44,
                                        height: 44,
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                  ),
                                  Positioned(
                                    right: -2,
                                    bottom: -2,
                                    child: Container(
                                      padding: const EdgeInsets.all(3),
                                      decoration: const BoxDecoration(
                                        color: AppColors.greenBright,
                                        shape: BoxShape.circle,
                                      ),
                                      child: const Icon(
                                        Icons.flash_on_rounded,
                                        size: 11,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(width: 3.w),
                              // Title Block
                              Expanded(
                                child: Text(
                                  buttonText,
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: AppTypography.black,
                                    fontSize: AppTypography.headingSmall,
                                    letterSpacing: 0.3,
                                  ),
                                ),
                              ),
                              SizedBox(width: 2.w),
                              // Arrow Action Capsule
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
                                decoration: BoxDecoration(
                                  gradient: const LinearGradient(
                                    colors: [AppColors.categoryVip, AppColors.categoryVipDark],
                                  ),
                                  borderRadius: BorderRadius.circular(12),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withValues(alpha: AppColors.opacity25),
                                      blurRadius: 6,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      'JOIN',
                                      style: TextStyle(
                                        color: AppColors.maroonDarkest,
                                        fontWeight: AppTypography.black,
                                        fontSize: AppTypography.bodySmall,
                                        letterSpacing: 0.8,
                                      ),
                                    ),
                                    const SizedBox(width: 3),
                                    const Icon(
                                      Icons.arrow_forward_rounded,
                                      size: 14,
                                      color: AppColors.maroonDarkest,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 1.4.h),
                          // Highlight Subtitle (Full Width, Fully Visible)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                            decoration: BoxDecoration(
                              color: Colors.black.withValues(alpha: 0.24),
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                color: AppColors.categoryVip.withValues(alpha: AppColors.opacity30),
                              ),
                            ),
                            child: Text(
                              AppLocalizations.of(context)?.bvsJoinCardSubtitle ??
                                  '⚡ BVS पोर्टलवर नोंदणी करा व ₹२००/वर्ष सवलत मिळवा',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: AppColors.goldGlow,
                                fontSize: AppTypography.bodyMedium,
                                fontWeight: AppTypography.semiBold,
                                height: 1.35,
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
          ),
        );
      },
    );
  }

  Widget _buildTimelineStep({
    required String stepNum,
    required IconData icon,
    required String title,
    required String desc,
    required bool isLast,
    required bool isDark,
    required ThemeData theme,
  }) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            children: [
              Container(
                width: 28,
                height: 28,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [AppColors.crimsonDeep, AppColors.maroonAccent],
                  ),
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.amberAccent, width: 1.2),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.crimsonDeep.withValues(alpha: AppColors.opacity30),
                      blurRadius: 6,
                    ),
                  ],
                ),
                child: Text(
                  stepNum,
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: AppTypography.bold,
                    fontSize: AppTypography.bodyMedium,
                  ),
                ),
              ),
              if (!isLast)
                Expanded(
                  child: Container(
                    width: 2,
                    margin: const EdgeInsets.symmetric(vertical: 4),
                    color: AppColors.crimsonDeep.withValues(alpha: isDark ? 0.4 : 0.25),
                  ),
                ),
            ],
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(bottom: isLast ? 0 : 1.8.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(icon, size: 16, color: isDark ? AppColors.primaryDarkContrast : AppColors.crimsonDeep),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          title,
                          style: TextStyle(
                            fontWeight: AppTypography.bold,
                            fontSize: AppTypography.bodyLarge,
                            color: theme.colorScheme.onSurface,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    desc,
                    style: TextStyle(
                      fontSize: AppTypography.bodySmall,
                      color: theme.colorScheme.onSurfaceVariant,
                      height: 1.35,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// 🌈 Circular / Orbital Running Gradient Border Painter
class _RunningGradientBorderPainter extends CustomPainter {
  final double animationPercent;
  static const double borderRadius = 22.0;
  static const double strokeWidth = 3.5;

  _RunningGradientBorderPainter({
    required this.animationPercent,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (size.width <= 0 || size.height <= 0) return;

    final rect = Offset.zero & size;
    final rrect = RRect.fromRectAndRadius(
      rect.deflate(strokeWidth / 2),
      const Radius.circular(borderRadius),
    );

    // Rotating Multi-Color Sweep Gradient
    final sweepGradient = SweepGradient(
      transform: GradientRotation(animationPercent * 2 * math.pi),
      colors: const [
        AppColors.categoryVip, // Gold
        AppColors.deepOrange600, // Saffron Flame
        AppColors.materialPink, // Neon Rose
        AppColors.categoryVerification, // Electric Cyan
        AppColors.greenBright, // Emerald Green
        AppColors.categoryVip, // Electric Gold
        AppColors.categoryVip, // Gold loop
      ],
      stops: const [0.0, 0.18, 0.36, 0.54, 0.72, 0.90, 1.0],
    );

    // 1. Glowing outer blur aura
    final glowPaint = Paint()
      ..shader = sweepGradient.createShader(rect)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth * 2.2
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);

    // 2. Crisp sharp border stroke
    final strokePaint = Paint()
      ..shader = sweepGradient.createShader(rect)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;

    canvas.drawRRect(rrect, glowPaint);
    canvas.drawRRect(rrect, strokePaint);
  }

  @override
  bool shouldRepaint(covariant _RunningGradientBorderPainter oldDelegate) =>
      oldDelegate.animationPercent != animationPercent;
}

/// ✨ Shimmering Light Sheen Streak Painter
class _LightSheenPainter extends CustomPainter {
  final double progress;

  _LightSheenPainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    if (size.width <= 0 || size.height <= 0) return;

    final width = size.width;
    final height = size.height;

    // Slide sheen from left (-width) to right (2*width)
    final dx = -width + (3 * width * progress);

    final paint = Paint()
      ..shader = LinearGradient(
        colors: [
          Colors.white.withValues(alpha: 0.0),
          Colors.white.withValues(alpha: 0.22),
          Colors.white.withValues(alpha: 0.0),
        ],
        stops: const [0.0, 0.5, 1.0],
        transform: const GradientRotation(math.pi / 4), // 45 degree angle
      ).createShader(Rect.fromLTWH(dx, 0, width * 0.45, height));

    canvas.drawRect(Rect.fromLTWH(0, 0, width, height), paint);
  }

  @override
  bool shouldRepaint(covariant _LightSheenPainter oldDelegate) =>
      oldDelegate.progress != progress;
}
