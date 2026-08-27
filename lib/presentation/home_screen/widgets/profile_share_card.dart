import 'package:banjarabio/core/services/persistent_cache_manager.dart';
import 'package:banjarabio/core/constants/app_typography.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:banjarabio/core/models/profile_model.dart';
import 'package:banjarabio/core/theme/app_gradients.dart';
import 'package:banjarabio/theme/app_colors.dart';

/// A premium, high-resolution widget designed to be captured as an image 
/// for WhatsApp Status sharing.
class ProfileShareCard extends StatelessWidget {
  final ProfileModel profile;
  final String? referrerCode;
  
  const ProfileShareCard({
    super.key,
    required this.profile,
    this.referrerCode,
  });

  String get _qrData {
    final refParam = (referrerCode != null && referrerCode!.isNotEmpty) ? '_ref_$referrerCode' : '';
    return 'https://play.google.com/store/apps/details?id=com.avishio.banjarabio&referrer=profile_${profile.id}$refParam';
  }

  @override
  Widget build(BuildContext context) {
    // We use a fixed aspect ratio for WhatsApp Status (9:16)
    // 1080x1920 is ideal for high-res status
    return Material(
      color: Colors.black,
      child: Container(
        width: 1080,
        height: 1920,
        decoration: const BoxDecoration(
          color: Colors.black,
        ),
        child: Stack(
          fit: StackFit.expand,
          children: [
            // 1. Background Photo
            if (profile.photos.isNotEmpty)
              CachedNetworkImage(
                imageUrl: profile.photos.first.publicUrl,
                fit: BoxFit.cover,
                width: 1080,
                height: 1920,
                cacheManager: PersistentCacheManager.instance,
                errorWidget: (context, url, error) => Container(color: AppColors.primary),
              ),
              
            // 2. Dark Gradient Overlay (Premium feel)
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withValues(alpha: AppColors.opacity30),
                    Colors.transparent,
                    Colors.black.withValues(alpha: AppColors.opacity60),
                    Colors.black.withValues(alpha: 0.95),
                  ],
                  stops: const [0.0, 0.4, 0.7, 1.0],
                ),
              ),
            ),
  
            // 3. Branding Header with Cultural Mantra
            Positioned(
              top: 70,
              left: 0,
              right: 0,
              child: Column(
                children: [
                  Text('॥ जय सेवालाल ॥', style: TextStyle(
                      color: AppColors.categoryVip, // Gold
                      fontSize: AppTypography.displayLarge,
                      fontWeight: AppTypography.extraBold,
                      letterSpacing: 2,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Image.asset(
                    'assets/logo/BanjaraBio.png',
                    height: 90,
                    errorBuilder: (context, error, stackTrace) => const SizedBox.shrink(),
                  ),
                  const SizedBox(height: 8),
                  Text('BANJARABIO', style: TextStyle(
                      color: Colors.white,
                      fontSize: AppTypography.displayLarge,
                      fontWeight: AppTypography.black,
                      letterSpacing: 8,
                    ),
                  ),
                ],
              ),
            ),
  
            // 4. Verification Stamp
            if (profile.isVerified)
              Positioned(
                top: 250,
                right: 60,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.greenAccent, width: 4),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.verified, color: Colors.greenAccent, size: 40),
                      const SizedBox(width: 10),
                      Text(
                        'VERIFIED',
                        style: TextStyle(
                          color: Colors.greenAccent,
                          fontSize: AppTypography.displayLarge,
                          fontWeight: AppTypography.black,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
  
            // 5. Main Info Column
            Positioned(
              bottom: 380,
              left: 60,
              right: 60,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${profile.fullName}, ${profile.age}',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: AppTypography.displayLarge,
                      fontWeight: AppTypography.black,
                      height: 1.1,
                    ),
                  ),
                  const SizedBox(height: 15),
                  Row(
                    children: [
                      const Icon(Icons.location_on, color: Colors.white70, size: 36),
                      const SizedBox(width: 8),
                      Text(
                        profile.locationExcludingVillage,
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: AppTypography.displayLarge,
                          fontWeight: AppTypography.semiBold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      const Icon(Icons.work, color: Colors.white70, size: 36),
                      const SizedBox(width: 8),
                      Text(
                        profile.profession,
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: AppTypography.displayLarge,
                          fontWeight: AppTypography.semiBold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 40),
                  Container(
                    width: double.infinity,
                    height: 4,
                    decoration: const BoxDecoration(
                      gradient: AppGradients.romance,
                    ),
                  ),
                ],
              ),
            ),
  
            // 6. QR Code Section (The "Network Effect" Engine)
            Positioned(
              bottom: 80,
              left: 60,
              right: 60,
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: QrImageView(
                      data: _qrData,
                      size: 220,
                      gapless: false,
                      embeddedImage: const AssetImage('assets/logo/BanjaraBio.webp'),
                      embeddedImageStyle: const QrEmbeddedImageStyle(
                        size: Size(50, 50),
                      ),
                    ),
                  ),
                  const SizedBox(width: 40),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Interested?',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: AppTypography.displayLarge,
                            fontWeight: AppTypography.black,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          'Scan QR to view full Bio on BanjaraBio Matrimony app',
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: AppTypography.headingLarge,
                            fontWeight: AppTypography.medium,
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
    );
  }
}
