import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:sizer/sizer.dart';
import 'package:banjarabio/services/ads/ad_service.dart';
import 'package:banjarabio/core/session_manager.dart';
import 'package:banjarabio/core/services/app_logger.dart';
import 'package:banjarabio/core/constants/app_typography.dart';

/// A native ad widget that blends into the profile feed.
class ProfileNativeAdWidget extends StatefulWidget {
  const ProfileNativeAdWidget({super.key});

  @override
  State<ProfileNativeAdWidget> createState() => _ProfileNativeAdWidgetState();
}

class _ProfileNativeAdWidgetState extends State<ProfileNativeAdWidget> with AutomaticKeepAliveClientMixin {
  NativeAd? _nativeAd;
  bool _isAdLoaded = false;
  bool _isAdFailed = false;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _loadAd();
  }

  Future<void> _loadAd() async {
    // Hide totally for premium users
    if (SessionManager.instance.isPremium) return;

    await AdMobService.ensureInitialized();
    if (!mounted) return;

    _nativeAd = NativeAd(
      adUnitId: AdMobService.nativeAdUnitId ?? '',
      nativeTemplateStyle: NativeTemplateStyle(
        templateType: TemplateType.medium,
        mainBackgroundColor: Theme.of(context).colorScheme.surface,
        cornerRadius: 24,
        callToActionTextStyle: NativeTemplateTextStyle(
          textColor: Colors.white,
          backgroundColor: Theme.of(context).colorScheme.primary,
          style: NativeTemplateFontStyle.bold,
          size: 16.0,
        ),
        primaryTextStyle: NativeTemplateTextStyle(
          textColor: Theme.of(context).colorScheme.onSurface,
          backgroundColor: Colors.transparent,
          style: NativeTemplateFontStyle.bold,
          size: 16.0,
        ),
        secondaryTextStyle: NativeTemplateTextStyle(
          textColor: Theme.of(context).colorScheme.onSurfaceVariant,
          backgroundColor: Colors.transparent,
          style: NativeTemplateFontStyle.normal,
          size: 14.0,
        ),
        tertiaryTextStyle: NativeTemplateTextStyle(
          textColor: Theme.of(context).colorScheme.onSurfaceVariant,
          backgroundColor: Colors.transparent,
          style: NativeTemplateFontStyle.normal,
          size: 14.0,
        ),
      ),
      request: const AdRequest(),
      listener: NativeAdListener(
        onAdLoaded: (ad) {
          if (mounted) {
            setState(() {
              _isAdLoaded = true;
            });
          }
        },
        onAdFailedToLoad: (ad, error) {
          ad.dispose();
          AppLogger.error('ProfileNativeAdWidget', 'NativeAd failed to load: $error');
          if (mounted) {
            setState(() {
              _isAdFailed = true;
            });
          }
        },
      ),
    );

    _nativeAd!.load();
  }

  @override
  void dispose() {
    _nativeAd?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context); // Required for AutomaticKeepAliveClientMixin
    if (_isAdFailed) {
      return const SizedBox.shrink();
    }

    if (!_isAdLoaded || SessionManager.instance.isPremium) {
      return Container(
        height: 62.h,
        margin: EdgeInsets.symmetric(horizontal: 2.w, vertical: 1.h),
        // 🚨 ZERO-GPU FIX: Removed CircularProgressIndicator
        child: Center(
          child: Text(
            '. . .',
            style: TextStyle(
              fontSize: 24,
              color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.3),
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      );
    }

    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      // Matches the 68.h or similar height constraints of the profile grid
      height: 62.h, 
      margin: EdgeInsets.symmetric(horizontal: 2.w, vertical: 1.h),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: isDark 
                ? Colors.black.withValues(alpha: 0.2) 
                : theme.colorScheme.primary.withValues(alpha: 0.1),
            blurRadius: 16,
            offset: const Offset(0, 8),
            spreadRadius: 1,
          ),
        ],
        border: Border.all(
          color: theme.colorScheme.outlineVariant.withValues(alpha: 0.2),
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(23),
        child: Stack(
          children: [
            // The Ad itself
            AdWidget(ad: _nativeAd!),
            
            // Premium "Sponsored" label to match Tinder/Big apps style
            Positioned(
              top: 12,
              right: 12,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.info_outline, color: Colors.white, size: 12),
                    const SizedBox(width: 4),
                    Text(
                      'SPONSORED',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: AppTypography.labelSmall,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 1.0,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
