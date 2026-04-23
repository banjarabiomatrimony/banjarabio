import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:screenshot/screenshot.dart';
import 'package:share_plus/share_plus.dart';
import 'package:banjarabio/core/models/profile_model.dart';
import 'package:banjarabio/presentation/home_screen/widgets/profile_share_card.dart';

/// Service to handle premium image generation and sharing.
class ShareService {
  static final ShareService _instance = ShareService._();
  factory ShareService() => _instance;
  ShareService._();

  final ScreenshotController _screenshotController = ScreenshotController();

  /// Captures a premium profile card as an image and shares it.
  Future<void> shareProfileStatus(
    BuildContext context,
    ProfileModel profile, {
    String? customCaption,
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
        ProfileShareCard(profile: profile),
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
      final String caption = customCaption ??
          'Check out this bio on BanjaraBio Matrimony! 💍\nScan the QR code to view more details.';
      
      await Share.shareXFiles(
        [XFile(file.path)],
        text: caption,
        subject: 'Profile Invitation',
      );
      
    } catch (e) {
      debugPrint('BANJARABIO_SHARE: Error sharing profile: $e');
      if (context.mounted && Navigator.of(context).canPop()) {
        Navigator.of(context).pop();
      }
      // Show error toast or dialog if needed
    }
  }
}
