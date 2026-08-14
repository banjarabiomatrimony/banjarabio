import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:sizer/sizer.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:banjarabio/l10n/app_localizations.dart';
import 'package:banjarabio/routes/app_routes.dart';

class BvsGatewayScreen extends StatefulWidget {
  const BvsGatewayScreen({super.key});

  @override
  State<BvsGatewayScreen> createState() => _BvsGatewayScreenState();
}

class _BvsGatewayScreenState extends State<BvsGatewayScreen>
    with TickerProviderStateMixin {
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

  String _getRegistrationUrl(BuildContext context) {
    final langCode = Localizations.localeOf(context).languageCode;
    return 'https://banjaravirasat.org.in/join_by_ref.php?ref_by=7020797849&lang=$langCode';
  }

  String _getLocalizedWhatsAppMessage(BuildContext context) {
    final langCode = Localizations.localeOf(context).languageCode;
    switch (langCode) {
      case 'hi':
        return '''🚩 जय सेवालाल..! 🚩
महाराष्ट्र सरकार के मंत्री माननीय श्री संजयभाऊ राठौड़ की संकल्पना से शुरू हुए "बणजारा विरासत संघ" के इस ऐतिहासिक अभियान से जुड़कर बंजारा समाज की एकता और भविष्य को मजबूत करने के लिए नीचे दिए गए लिंक पर क्लिक करके सदस्य बनें:
🔗 आज ही जुड़ें: https://banjaravirasat.org.in/join_by_ref.php?ref_by=7020797849&lang=hi

धन्यवाद...!
🙏।। विनीत ।। 🙏
Banti Shankar Rathod (7020797849)''';
      case 'te':
        return '''🚩 జై సేవాలాల్..! 🚩
మహారాష్ట్ర ప్రభుత్వ మంత్రి శ్రీ సంజయ్‌భావూ రాథోడ్ గారి సంకల్పంతో ప్రారంభమైన "బంజారా విరాసత్ సంఘ్" ఉద్యమంలో చేరి బంజారా సమాజం యొక్క ఐక్యత మరియు భవిష్యత్తును బలోపేతం చేయడానికి క్రింది లింక్‌పై క్లిక్ చేసి సభ్యులుగా చేరండి:
🔗 ఇప్పుడే చేరండి: https://banjaravirasat.org.in/join_by_ref.php?ref_by=7020797849&lang=te

ధన్యవాదాలు...!
🙏।। వినీతులు ।। 🙏
Banti Shankar Rathod (7020797849)''';
      case 'kn':
        return '''🚩 ಜೈ ಸೇವಾಲಾಲ್..! 🚩
ಮಹಾರಾಷ್ಟ್ರ ಸರ್ಕಾರದ ಸಚಿವರಾದ ಶ್ರೀ ಸಂಜಯಭಾವು ರಾಠೋಡ್ ಅವರ ಪರಿಕಲ್ಪನೆಯಲ್ಲಿ ಪ್ರಾರಂಭವಾದ "ಬಂಜಾರಾ ವಿರಾಸತ್ ಸಂಘ" ಚಳವಳಿಗೆ ಸೇರಿ ಬಂಜಾರಾ ಸಮಾಜದ ಐಕ್ಯತೆ ಮತ್ತು ಭವಿಷ್ಯವನ್ನು ಬಲಪಡಿಸಲು ಕೆಳಗಿನ ಲಿಂಕ್ ಕ್ಲಿಕ್ ಮಾಡಿ ಸದಸ್ಯರಾಗಿ:
🔗 ಈಗಲೇ ಸೇರಿ: https://banjaravirasat.org.in/join_by_ref.php?ref_by=7020797849&lang=kn

ಧನ್ಯವಾದಗಳು...!
🙏।। ವಿನೀತ ।। 🙏
Banti Shankar Rathod (7020797849)''';
      case 'en':
        return '''🚩 Jai Sevalal..! 🚩
Join "Banjara Virasat Sangh" (BVS), a historic movement envisioned by Maharashtra Cabinet Minister Hon. Shri Sanjaybhau Rathod, to strengthen the unity and heritage of the Banjara community. Click below to become a member:
🔗 Join Today: https://banjaravirasat.org.in/join_by_ref.php?ref_by=7020797849&lang=en

Thank you...!
🙏 With Regards 🙏
Banti Shankar Rathod (7020797849)''';
      case 'mr':
      default:
        return '''🚩 जय सेवालाल..! 🚩
महाराष्ट्र राज्याचे मंत्री श्री.संजयभाऊ राठोड यांच्या संकल्पनेतून सुरू झालेल्या "बणजारा विरासत संघ" या नाविन्यपूर्ण उपक्रमात सहभागी होऊन बंजारा समाजाची एकता आणि भवितव्य अधिक मजबूत करण्यासाठी खालील लिंकवर क्लिक करून सदस्य व्हा:
🔗 आजच सामील व्हा: https://banjaravirasat.org.in/join_by_ref.php?ref_by=7020797849&lang=mr

धन्यवाद...!
🙏।। विनित।। 🙏
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
        backgroundColor: const Color(0xFF8B1A2E),
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
    final joinNowButtonText = l10n?.bvsJoinNowButton ?? 'आजच BVS चे सदस्य व्हा (Join Now)';
    final uploadCardButtonText = l10n?.bvsUploadCardButton ?? 'BVS कार्ड अपलोड करा (सवलत मिळवा)';

    return Scaffold(
      backgroundColor: const Color(0xFFF9F6F0),
      appBar: AppBar(
        titleSpacing: 0,
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(2),
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.amberAccent, width: 1.5),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.2),
                    blurRadius: 6,
                  ),
                ],
              ),
              child: ClipOval(
                child: Image.asset(
                  'assets/images/bvs_logo_gold.png',
                  width: 32,
                  height: 32,
                  fit: BoxFit.cover,
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                titleText,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 17,
                  color: Colors.white,
                  letterSpacing: 0.3,
                ),
              ),
            ),
          ],
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 20),
          onPressed: () {
            HapticFeedback.lightImpact();
            Navigator.pop(context);
          },
        ),
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF5A000F), Color(0xFF8B1A2E), Color(0xFFB71C1C)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        elevation: 3,
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
                        Color(0xFF4A000C),
                        Color(0xFF7A1324),
                        Color(0xFFB71C1C),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(
                      color: const Color(0xFFFFD700).withValues(alpha: 0.7),
                      width: 1.6,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF7A1324).withValues(alpha: 0.35),
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
                            color: Colors.amberAccent.withValues(alpha: 0.08),
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
                                        color: const Color(0xFFFFD700),
                                        width: 2.2,
                                      ),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withValues(alpha: 0.3),
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
                                              style: const TextStyle(
                                                color: Colors.white,
                                                fontSize: 17.5,
                                                fontWeight: FontWeight.bold,
                                                letterSpacing: 0.4,
                                              ),
                                            ),
                                          ),
                                          Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2.5),
                                            decoration: BoxDecoration(
                                              color: const Color(0xFFFFD700),
                                              borderRadius: BorderRadius.circular(6),
                                              boxShadow: [
                                                BoxShadow(
                                                  color: Colors.amber.withValues(alpha: 0.4),
                                                  blurRadius: 6,
                                                ),
                                              ],
                                            ),
                                            child: const Text(
                                              'BVS VIP',
                                              style: TextStyle(
                                                color: Color(0xFF4A000C),
                                                fontSize: 10,
                                                fontWeight: FontWeight.w900,
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
                                          color: Colors.white.withValues(alpha: 0.12),
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                        child: Text(
                                          conceptText,
                                          style: TextStyle(
                                            color: Colors.white.withValues(alpha: 0.95),
                                            fontSize: 11,
                                            height: 1.35,
                                            fontWeight: FontWeight.w500,
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
                                  const Text('🚩', style: TextStyle(fontSize: 16)),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      movementDesc,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 11.5,
                                        height: 1.35,
                                        fontWeight: FontWeight.w500,
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
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(22),
                    border: Border.all(
                      color: const Color(0xFF8B1A2E).withValues(alpha: 0.16),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.04),
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
                              color: const Color(0xFF8B1A2E).withValues(alpha: 0.1),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.verified_rounded,
                              color: Color(0xFF8B1A2E),
                              size: 18,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            officialEmblemsTitle,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                              color: Color(0xFF6B0E1E),
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
                                gradient: const LinearGradient(
                                  colors: [Color(0xFFFAF5F6), Color(0xFFF3E7EA)],
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                ),
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: const Color(0xFF8B1A2E).withValues(alpha: 0.18),
                                ),
                              ),
                              child: Column(
                                children: [
                                  Container(
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(12),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withValues(alpha: 0.1),
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
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12.5,
                                      color: Color(0xFF6B0E1E),
                                    ),
                                  ),
                                  const SizedBox(height: 3),
                                  Text(
                                    unityDesc,
                                    textAlign: TextAlign.center,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      fontSize: 10.5,
                                      color: Colors.grey[700],
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
                                gradient: const LinearGradient(
                                  colors: [Color(0xFFFFFDF5), Color(0xFFFFF7DB)],
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                ),
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: const Color(0xFFFFD700).withValues(alpha: 0.5),
                                ),
                              ),
                              child: Column(
                                children: [
                                  Container(
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.amber.withValues(alpha: 0.25),
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
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12.5,
                                      color: Color(0xFF8B1A2E),
                                    ),
                                  ),
                                  const SizedBox(height: 3),
                                  Text(
                                    heritageDesc,
                                    textAlign: TextAlign.center,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      fontSize: 10.5,
                                      color: Colors.grey[700],
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
                          gradient: const LinearGradient(
                            colors: [
                              Color(0xFFFFFDE7),
                              Color(0xFFFFF8E1),
                              Color(0xFFFFECB3),
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(22),
                          border: Border.all(
                            color: Color.lerp(
                              const Color(0xFFFFB300),
                              const Color(0xFFFFD700),
                              _glowAnimation.value,
                            )!,
                            width: 2.0,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.amber.withValues(alpha: _glowAnimation.value * 0.4),
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
                                  colors: [Color(0xFFFFC107), Color(0xFFFF9800)],
                                ),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.auto_awesome,
                                color: Color(0xFF4A000C),
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
                                    style: const TextStyle(
                                      color: Color(0xFF6B0E1E),
                                      fontSize: 14.5,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    subsidySubtitle,
                                    style: const TextStyle(
                                      color: Color(0xFF5D4037),
                                      fontSize: 11.5,
                                      fontWeight: FontWeight.w500,
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
                            Expanded(
                              child: Container(
                                padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(14),
                                  border: Border.all(color: Colors.amber.shade400, width: 1.2),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withValues(alpha: 0.04),
                                      blurRadius: 8,
                                    ),
                                  ],
                                ),
                                child: Column(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFE8F5E9),
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      child: const Text(
                                        'सर्वोत्कृष्ट बचत • Best Value',
                                        style: TextStyle(
                                          fontSize: 9,
                                          fontWeight: FontWeight.bold,
                                          color: Color(0xFF2E7D32),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      annualPlanLabel,
                                      style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w600),
                                    ),
                                    const SizedBox(height: 3),
                                    Text(
                                      annualPrice,
                                      style: const TextStyle(
                                        fontSize: 17,
                                        fontWeight: FontWeight.bold,
                                        color: Color(0xFF8B1A2E),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            SizedBox(width: 2.5.w),
                            Expanded(
                              child: Container(
                                padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(14),
                                  border: Border.all(color: Colors.amber.shade300, width: 1.2),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withValues(alpha: 0.04),
                                      blurRadius: 8,
                                    ),
                                  ],
                                ),
                                child: Column(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFFFF3E0),
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      child: const Text(
                                        'महिना दर महिना • Flexible',
                                        style: TextStyle(
                                          fontSize: 9,
                                          fontWeight: FontWeight.bold,
                                          color: Color(0xFFE65100),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      monthlyPlanLabel,
                                      style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w600),
                                    ),
                                    const SizedBox(height: 3),
                                    Text(
                                      monthlyPrice,
                                      style: const TextStyle(
                                        fontSize: 17,
                                        fontWeight: FontWeight.bold,
                                        color: Color(0xFF8B1A2E),
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
              ),

              SizedBox(height: 2.2.h),

              // ── 4. Interactive Visual Stepper Pathway ──
              SlideTransition(
                position: _stepsSlide,
                child: Container(
                  padding: EdgeInsets.all(4.5.w),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(22),
                    border: Border.all(color: Colors.grey.withValues(alpha: 0.2)),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.04),
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
                          const Icon(Icons.lightbulb_outline_rounded, color: Color(0xFFE65100), size: 20),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              howToJoinTitle,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 13.5,
                                color: Colors.black87,
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
                      ),
                      _buildTimelineStep(
                        stepNum: '2',
                        icon: Icons.badge_outlined,
                        title: step2Title,
                        desc: step2Desc,
                        isLast: false,
                      ),
                      _buildTimelineStep(
                        stepNum: '3',
                        icon: Icons.verified_user_rounded,
                        title: step3Title,
                        desc: step3Desc,
                        isLast: true,
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
                    gradient: const LinearGradient(
                      colors: [Color(0xFFE8FCE8), Color(0xFFD7FAD7)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(22),
                    border: Border.all(color: const Color(0xFF25D366).withValues(alpha: 0.5), width: 1.2),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF25D366).withValues(alpha: 0.12),
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
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 13.5,
                                color: Color(0xFF075E54),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: const Color(0xFF25D366).withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: const Text(
                              'Auto Invite',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF075E54),
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 1.4.h),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(14),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.05),
                              blurRadius: 6,
                            ),
                          ],
                        ),
                        child: Text(
                          _getLocalizedWhatsAppMessage(context),
                          maxLines: 5,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 11.5,
                            color: Colors.black87,
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
                    _buildShiningRunningColorJoinCard(
                      buttonText: joinNowButtonText,
                    ),

                    SizedBox(height: 1.8.h),

                    // Action 2: WhatsApp Share Automation + Copy Message Row
                    Row(
                      children: [
                        Expanded(
                          flex: 4,
                          child: ElevatedButton(
                            onPressed: _shareOnWhatsApp,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF25D366),
                              foregroundColor: Colors.white,
                              padding: EdgeInsets.symmetric(vertical: 1.6.h),
                              elevation: 3,
                              shadowColor: const Color(0xFF25D366).withValues(alpha: 0.4),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
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
                                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13.5),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        SizedBox(width: 2.5.w),
                        Expanded(
                          child: OutlinedButton(
                            onPressed: _copyReferralMessage,
                            style: OutlinedButton.styleFrom(
                              padding: EdgeInsets.symmetric(vertical: 1.6.h),
                              side: BorderSide(
                                color: _isCopied ? Colors.green : Colors.grey.withValues(alpha: 0.4),
                                width: 1.5,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                              backgroundColor: _isCopied
                                  ? Colors.green.withValues(alpha: 0.1)
                                  : Colors.white,
                            ),
                            child: Icon(
                              _isCopied ? Icons.check_circle : Icons.copy_rounded,
                              color: _isCopied ? Colors.green : Colors.grey[700],
                              size: 20,
                            ),
                          ),
                        ),
                      ],
                    ),

                    SizedBox(height: 1.5.h),

                    // Action 3: Upload BVS Card for Discount
                    OutlinedButton.icon(
                      onPressed: () {
                        HapticFeedback.lightImpact();
                        Navigator.pushNamed(context, AppRoutes.communityIdVerification);
                      },
                      icon: const Icon(Icons.badge_outlined, size: 20, color: Color(0xFF8B1A2E)),
                      label: Text(
                        '🪪 $uploadCardButtonText',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 13.5,
                          color: Color(0xFF8B1A2E),
                        ),
                      ),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Color(0xFF8B1A2E), width: 1.6),
                        backgroundColor: Colors.white,
                        padding: EdgeInsets.symmetric(vertical: 1.6.h),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
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
                  Color(0xFF3F000B), // Deepest Royal Maroon
                  Color(0xFF6E0D1E), // Vibrant BVS Crimson
                  Color(0xFF99152B), // Imperial Wine Red
                  Color(0xFFB71C1C), // Saffron Flame
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(22),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFFFFD700).withValues(alpha: 0.35),
                  blurRadius: 18,
                  spreadRadius: 1,
                  offset: const Offset(0, 4),
                ),
                BoxShadow(
                  color: const Color(0xFF8B1A2E).withValues(alpha: 0.5),
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
                                        color: const Color(0xFFFFD700),
                                        width: 2.2,
                                      ),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.amber.withValues(alpha: 0.6),
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
                                        color: Color(0xFF00E676),
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
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w900,
                                    fontSize: 15,
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
                                    colors: [Color(0xFFFFD700), Color(0xFFFFAB00)],
                                  ),
                                  borderRadius: BorderRadius.circular(12),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withValues(alpha: 0.25),
                                      blurRadius: 6,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: const Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      'JOIN',
                                      style: TextStyle(
                                        color: Color(0xFF4A000C),
                                        fontWeight: FontWeight.w900,
                                        fontSize: 11,
                                        letterSpacing: 0.8,
                                      ),
                                    ),
                                    SizedBox(width: 3),
                                    Icon(
                                      Icons.arrow_forward_rounded,
                                      size: 14,
                                      color: Color(0xFF4A000C),
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
                                color: const Color(0xFFFFD700).withValues(alpha: 0.3),
                              ),
                            ),
                            child: Text(
                              AppLocalizations.of(context)?.bvsJoinCardSubtitle ??
                                  '⚡ BVS पोर्टलवर नोंदणी करा व ₹२००/वर्ष सवलत मिळवा',
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                color: Color(0xFFFFE082),
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
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
                    colors: [Color(0xFF8B1A2E), Color(0xFF5A000F)],
                  ),
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.amberAccent, width: 1.2),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF8B1A2E).withValues(alpha: 0.3),
                      blurRadius: 6,
                    ),
                  ],
                ),
                child: Text(
                  stepNum,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
              if (!isLast)
                Expanded(
                  child: Container(
                    width: 2,
                    margin: const EdgeInsets.symmetric(vertical: 4),
                    color: const Color(0xFF8B1A2E).withValues(alpha: 0.25),
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
                      Icon(icon, size: 16, color: const Color(0xFF8B1A2E)),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          title,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                            color: Colors.black87,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    desc,
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.grey[700],
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
        Color(0xFFFFD700), // Gold
        Color(0xFFFF3D00), // Saffron Flame
        Color(0xFFFF007F), // Neon Rose
        Color(0xFF00E5FF), // Electric Cyan
        Color(0xFF00E676), // Emerald Green
        Color(0xFFFFEA00), // Electric Gold
        Color(0xFFFFD700), // Gold loop
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
