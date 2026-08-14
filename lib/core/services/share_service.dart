import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:screenshot/screenshot.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:banjarabio/core/models/profile_model.dart';
import 'package:banjarabio/presentation/home_screen/widgets/profile_share_card.dart';
import 'package:banjarabio/core/services/app_logger.dart';

/// Service to handle premium image generation and sharing.
class ShareService {
  static final ShareService _instance = ShareService._();
  factory ShareService() => _instance;
  ShareService._();

  final ScreenshotController _screenshotController = ScreenshotController();

  /// Launches WhatsApp directly with formatted Marathi candidate text and link.
  Future<bool> launchWhatsAppDirectly({
    required String text,
    String? phone,
  }) async {
    try {
      final encodedText = Uri.encodeComponent(text);
      final phoneString = (phone != null && phone.isNotEmpty) ? 'phone=$phone&' : '';
      
      // 1. Try whatsapp:// scheme (Native App)
      final nativeUri = Uri.parse('whatsapp://send?${phoneString}text=$encodedText');
      if (await canLaunchUrl(nativeUri)) {
        return await launchUrl(nativeUri, mode: LaunchMode.externalApplication);
      }
      
      // 2. Fallback to wa.me URL
      final webUri = Uri.parse('https://wa.me/?text=$encodedText');
      if (await canLaunchUrl(webUri)) {
        return await launchUrl(webUri, mode: LaunchMode.externalApplication);
      }

      // 3. System share sheet fallback
      await Share.share(text);
      return true;
    } catch (e) {
      AppLogger.error('ShareService', 'Direct WhatsApp launch failed: $e');
      await Share.share(text);
      return false;
    }
  }

  /// Captures a premium profile card as an image and shares it.
  Future<void> shareProfileStatus(
    BuildContext context,
    ProfileModel profile, {
    String? customCaption,
    String? referrerCode,
  }) async {
    try {
      // 1. Show a loading indicator (Premium feel)
      if (context.mounted) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => const Center(
            child: CircularProgressIndicator(
              color: Color(0xFFE91E63),
            ),
          ),
        );
      }

      // 2. Render the off-screen widget
      // We use a high pixel ratio for "super premium" quality
      final image = await _screenshotController.captureFromWidget(
        ProfileShareCard(profile: profile, referrerCode: referrerCode),
        delay: const Duration(milliseconds: 200),
        pixelRatio: 3.0, // High density for WhatsApp
        context: context,
      );

      // 3. Save to temporary directory
      final tempDir = await getTemporaryDirectory();
      final String fileName = 'BanjaraBio_${profile.fullName.replaceAll(' ', '_')}.png';
      final file = await File('${tempDir.path}/$fileName').create();
      await file.writeAsBytes(image);

      // 4. Close loading indicator
      if (context.mounted) {
        Navigator.of(context).pop();
      }

      // 5. Share with WhatsApp specific intent (if possible) or generic share
      // Providing a clear caption for better click-through
      final String refSuffix = (referrerCode != null && referrerCode.isNotEmpty) ? '_ref_$referrerCode' : '';
      final String deepLinkUrl = 'https://play.google.com/store/apps/details?id=com.avishio.banjarabio&referrer=profile_${profile.id}$refSuffix';

      final String caption = customCaption ??
          '💍 Check out this bio on BanjaraBio Matrimony!\n'
          '📲 View Profile & Install: $deepLinkUrl\n'
          'Scan the QR code in the image to view more details.';
      
      await Share.shareXFiles(
        [XFile(file.path)],
        text: caption,
        subject: 'Profile Invitation',
      );
      
    } catch (e) {
      AppLogger.error('ShareService', 'BANJARABIO_SHARE: Error sharing profile: $e');
      if (context.mounted && Navigator.of(context).canPop()) {
        Navigator.of(context).pop();
      }
    }
  }

  /// Specialized WhatsApp share for relatives forwarding candidate profiles to their children/relatives.
  Future<void> shareProfileToCandidateWhatsApp(
    BuildContext context,
    ProfileModel profile, {
    String? relationLabel,
    String? referrerCode,
    bool directLaunchOnly = true,
  }) async {
    final String relationText = (relationLabel != null && relationLabel.isNotEmpty)
        ? relationLabel
        : 'नातेवाईक';

    final String gotraStr = (profile.gotra != null && profile.gotra!.isNotEmpty)
        ? ' • गोत्र: ${profile.gotra}'
        : '';

    final String refSuffix = (referrerCode != null && referrerCode.isNotEmpty) ? '_ref_$referrerCode' : '';
    final String deepLinkUrl = 'https://play.google.com/store/apps/details?id=com.avishio.banjarabio&referrer=profile_${profile.id}$refSuffix';

    final String customCaption =
        'जय सेवालाल! 🚩 बंजाराबायो (BanjaraBio) वर $relationText साठी एक उत्तम बायो-डाटा स्थळ सापडले आहे:\n\n'
        '👤 नाव: ${profile.fullName}\n'
        '🎂 वय: ${profile.age} वर्षे $gotraStr\n'
        '🎓 शिक्षण: ${profile.education.isNotEmpty ? profile.education : "माहिती उपलब्ध"}\n'
        '💼 व्यवसाय: ${profile.profession.isNotEmpty ? profile.profession : "माहिती उपलब्ध"}\n'
        '📍 ठिकाण: ${profile.district ?? profile.state ?? ""}\n\n'
        '📲 *बायो-डाटा पाहण्यासाठी व ॲप डाऊनलोड करण्यासाठी लिंक:*\n'
        '$deepLinkUrl\n\n'
        '✨ (BanjaraBio Matrimony ॲपवर मोफत नोंदणी करा)';

    if (directLaunchOnly) {
      await launchWhatsAppDirectly(text: customCaption);
    } else {
      await shareProfileStatus(
        context,
        profile,
        customCaption: customCaption,
        referrerCode: referrerCode,
      );
    }
  }
}

