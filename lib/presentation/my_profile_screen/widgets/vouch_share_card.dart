import 'package:banjarabio/core/constants/app_typography.dart';
import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:banjarabio/core/models/profile_model.dart';
import 'package:banjarabio/core/services/persistent_cache_manager.dart';
import 'package:banjarabio/theme/app_colors.dart';

/// A pixel-perfect, 9:16 aspect ratio (400x711 logical, renders to 1080x1920 HD)
/// graphic card designed for WhatsApp Status and social sharing to invite relatives to vouch.
class VouchShareCard extends StatelessWidget {
  final ProfileModel profile;
  final String? referrerCode;

  const VouchShareCard({
    super.key,
    required this.profile,
    this.referrerCode,
  });

  String get _qrData {
    final refParam = (referrerCode != null && referrerCode!.isNotEmpty)
        ? '_ref_$referrerCode'
        : '_vouch_${profile.id}';
    return 'https://play.google.com/store/apps/details?id=com.avishio.banjarabio&referrer=vouch_${profile.id}$refParam';
  }

  @override
  Widget build(BuildContext context) {
    // Explicit 400x711 bounds (exact 9:16 aspect ratio)
    return MediaQuery(
      data: const MediaQueryData(
        size: Size(400, 711),
        textScaler: TextScaler.noScaling,
      ),
      child: Material(
        color: Colors.black,
        child: SizedBox(
          width: 400,
          height: 711,
          child: Stack(
            fit: StackFit.expand,
            children: [
              // ── 1. Background Photo or Gradient ──────────────────────
              if (profile.photos.isNotEmpty)
                CachedNetworkImage(
                  imageUrl: profile.photos.first.publicUrl,
                  fit: BoxFit.cover,
                  width: 400,
                  height: 711,
                  cacheManager: PersistentCacheManager.instance,
                  errorWidget: (context, error, stackTrace) =>
                      _buildFallbackBackground(),
                )
              else
                _buildFallbackBackground(),

              // ── 2. Cinematic Multi-Layer Dark Gradient Overlay ───────
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.black.withValues(alpha: AppColors.opacity80),
                      Colors.black.withValues(alpha: AppColors.opacity25),
                      Colors.black.withValues(alpha: 0.45),
                      Colors.black.withValues(alpha: 0.88),
                      Colors.black.withValues(alpha: 0.98),
                    ],
                    stops: const [0.0, 0.20, 0.45, 0.70, 1.0],
                  ),
                ),
              ),

              // ── 3. Top Cultural & Brand Header (top: 20) ─────────────
              Positioned(
                top: 20,
                left: 18,
                right: 18,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '॥ जय सेवालाल ॥',
                      style: TextStyle(
                        color: AppColors.categoryVip, // Pure Gold
                        fontSize: AppTypography.bodyMedium,
                        fontWeight: AppTypography.black,
                        letterSpacing: 2.5,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Image.asset(
                          'assets/logo/BanjaraBio.png',
                          height: 32,
                          errorBuilder: (context, error, stackTrace) =>
                              const SizedBox.shrink(),
                        ),
                        const SizedBox(width: 8),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'BANJARABIO',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: AppTypography.headingSmall,
                                fontWeight: AppTypography.black,
                                letterSpacing: 3,
                              ),
                            ),
                            Text(
                              'अखिल भारतीय बंजारा मॅट्रिमोनी',
                              style: TextStyle(
                                color: AppColors.categoryVip,
                                fontSize: AppTypography.labelTiny,
                                fontWeight: AppTypography.bold,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    // Vouch Banner Pill
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 4),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [
                            AppColors.gold,
                            AppColors.vouchGoldSoft,
                            AppColors.gold,
                          ],
                        ),
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color:
                                AppColors.gold.withValues(alpha: AppColors.opacity35),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.how_to_reg,
                              color: AppColors.crimsonBlack, size: 14),
                          const SizedBox(width: 6),
                          Text(
                            'समाज खात्री (VOUCH) आमंत्रण',
                            style: TextStyle(
                              color: AppColors.crimsonBlack,
                              fontSize: AppTypography.labelSmall,
                              fontWeight: AppTypography.black,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // ── 4. Floating Vouch Count Status Badge (top: 115) ───────
              Positioned(
                top: 115,
                right: 18,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: AppColors.opacity70),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: AppColors.categoryVip,
                      width: 1.5,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: AppColors.opacity40),
                        blurRadius: 6,
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.shield_outlined,
                          color: AppColors.categoryVip, size: 14),
                      const SizedBox(width: 5),
                      Text(
                        '${profile.vouchCount}/5 Vouches',
                        style: TextStyle(
                          color: AppColors.categoryVip,
                          fontSize: AppTypography.labelSmall,
                          fontWeight: AppTypography.black,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // ── 5. Candidate Profile Information (bottom: 155) ───────
              Positioned(
                bottom: 155,
                left: 18,
                right: 18,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Candidate Name & Age
                    Text(
                      '${profile.fullName}, ${profile.age}',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: AppTypography.headingLarge,
                        fontWeight: AppTypography.black,
                        height: 1.1,
                        shadows: [
                          const Shadow(
                            color: Colors.black87,
                            blurRadius: 6,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 6),

                    // Gotra & Location Row
                    Wrap(
                      spacing: 8,
                      runSpacing: 6,
                      children: [
                        if (profile.gotra != null && profile.gotra!.isNotEmpty)
                          _buildInfoBadge(
                            icon: Icons.brightness_auto,
                            text: 'गोत्र: ${profile.gotra}',
                            bgColor: AppColors.burgundy,
                          ),
                        _buildInfoBadge(
                          icon: Icons.location_on,
                          text: profile.locationExcludingVillage.isNotEmpty
                              ? profile.locationExcludingVillage
                              : 'महाराष्ट्र',
                          bgColor: AppColors.blue800,
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),

                    // Education
                    if (profile.education.isNotEmpty) ...[
                      Row(
                        children: [
                          const Icon(Icons.school,
                              color: AppColors.categoryVip, size: 14),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              profile.education,
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: AppTypography.bodySmall,
                                fontWeight: AppTypography.bold,
                                shadows: [
                                  const Shadow(color: Colors.black87, blurRadius: 4),
                                ],
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 3),
                    ],

                    // Profession
                    if (profile.profession.isNotEmpty) ...[
                      Row(
                        children: [
                          const Icon(Icons.work,
                              color: AppColors.categoryVip, size: 14),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              profile.profession,
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: AppTypography.bodySmall,
                                fontWeight: AppTypography.semiBold,
                                shadows: [
                                  const Shadow(color: Colors.black87, blurRadius: 4),
                                ],
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                    ],

                    // Vouch Progress Bar Container
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: AppColors.opacity60),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.white24),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'खात्री प्रगती (Vouch Status)',
                                style: TextStyle(
                                  color: Colors.white70,
                                  fontSize: AppTypography.labelSmall,
                                  fontWeight: AppTypography.semiBold,
                                ),
                              ),
                              Text(
                                '${profile.vouchCount} / 5 Vouches',
                                style: TextStyle(
                                  color: AppColors.categoryVip,
                                  fontSize: AppTypography.labelSmall,
                                  fontWeight: AppTypography.black,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 5),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(4),
                            child: LinearProgressIndicator(
                              value: (profile.vouchCount / 5).clamp(0.0, 1.0),
                              minHeight: 5,
                              backgroundColor: Colors.white24,
                              valueColor: const AlwaysStoppedAnimation<Color>(
                                AppColors.green500,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // ── 6. QR Code & Vouch Instructions (bottom: 18) ─────────
              Positioned(
                bottom: 18,
                left: 18,
                right: 18,
                child: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColors.crimsonBlack,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(
                      color: AppColors.gold.withValues(alpha: AppColors.opacity50),
                      width: 1.5,
                    ),
                  ),
                  child: Row(
                    children: [
                      // High-contrast QR Container
                      Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: QrImageView(
                          data: _qrData,
                          size: 88,
                          gapless: false,
                          embeddedImage:
                              const AssetImage('assets/logo/BanjaraBio.png'),
                          embeddedImageStyle: const QrEmbeddedImageStyle(
                            size: Size(20, 20),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'खात्री (Vouch) कशी द्यावी?',
                              style: TextStyle(
                                color: AppColors.categoryVip,
                                fontSize: AppTypography.bodySmall,
                                fontWeight: AppTypography.black,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '१. कॅमेऱ्याने QR स्कॅन करा\n२. BanjaraBio ॲप उघडा\n३. "Vouch द्या" वर क्लिक करा',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: AppTypography.labelTiny,
                                fontWeight: AppTypography.medium,
                                height: 1.35,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoBadge({
    required IconData icon,
    required String text,
    required Color bgColor,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: bgColor.withValues(alpha: AppColors.opacity85),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.white30),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.white, size: 11),
          const SizedBox(width: 4),
          Text(
            text,
            style: TextStyle(
              color: Colors.white,
              fontSize: AppTypography.labelSmall,
              fontWeight: AppTypography.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFallbackBackground() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            AppColors.maroonDarkest,
            AppColors.crimsonBlack,
            AppColors.canvasDark,
          ],
        ),
      ),
      child: Center(
        child: Text(
          profile.fullName.isNotEmpty ? profile.fullName[0].toUpperCase() : 'B',
          style: TextStyle(
            color: AppColors.categoryVip.withValues(alpha: AppColors.opacity15),
            fontSize: 160,
            fontWeight: AppTypography.black,
          ),
        ),
      ),
    );
  }
}
