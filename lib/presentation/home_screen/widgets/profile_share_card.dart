import 'package:banjarabio/core/services/persistent_cache_manager.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:banjarabio/core/models/profile_model.dart';
import 'package:banjarabio/core/theme/app_gradients.dart';

/// A premium, high-resolution widget designed to be captured as an image 
/// for WhatsApp Status sharing.
class ProfileShareCard extends StatelessWidget {
  final ProfileModel profile;
  
  const ProfileShareCard({
    super.key,
    required this.profile,
  });

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
                errorWidget: (context, url, error) => Container(color: const Color(0xFF432C7A)),
              ),
              
            // 2. Dark Gradient Overlay (Premium feel)
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withValues(alpha: 0.3),
                    Colors.transparent,
                    Colors.black.withValues(alpha: 0.6),
                    Colors.black.withValues(alpha: 0.95),
                  ],
                  stops: const [0.0, 0.4, 0.7, 1.0],
                ),
              ),
            ),
  
            // 3. Branding Header
            Positioned(
              top: 80,
              left: 0,
              right: 0,
              child: Column(
                children: [
                  Image.asset(
                    'assets/logo/BanjaraBio.png',
                    height: 100,
                    errorBuilder: (context, error, stackTrace) => const SizedBox.shrink(),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    'BANJARABIO',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 40,
                      fontWeight: FontWeight.w900,
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
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.verified, color: Colors.greenAccent, size: 40),
                      SizedBox(width: 10),
                      Text(
                        'VERIFIED',
                        style: TextStyle(
                          color: Colors.greenAccent,
                          fontSize: 32,
                          fontWeight: FontWeight.w900,
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
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 80,
                      fontWeight: FontWeight.w900,
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
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 36,
                          fontWeight: FontWeight.w600,
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
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 36,
                          fontWeight: FontWeight.w600,
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
                      data: 'banjarabio://profile?id=${profile.id}',
                      size: 220,
                      gapless: false,
                      embeddedImage: const AssetImage('assets/logo/BanjaraBio.png'),
                      embeddedImageStyle: const QrEmbeddedImageStyle(
                        size: Size(50, 50),
                      ),
                    ),
                  ),
                  const SizedBox(width: 40),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Interested?',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 48,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        SizedBox(height: 10),
                        Text(
                          'Scan QR to view full Bio on BanjaraBio Matrimony app',
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 28,
                            fontWeight: FontWeight.w500,
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
