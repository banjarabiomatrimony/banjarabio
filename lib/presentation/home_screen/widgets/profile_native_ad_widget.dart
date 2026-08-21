import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:sizer/sizer.dart';
import 'package:banjarabio/services/ads/ad_service.dart';
import 'package:banjarabio/core/session_manager.dart';
import 'package:banjarabio/core/services/app_logger.dart';
import 'package:banjarabio/core/constants/app_typography.dart';
import 'package:banjarabio/theme/app_colors.dart';

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
    if (SessionManager.instance.isPremium) {
      AppLogger.debug('NativeAd', '📢 [NativeAd:ABORT] User is Premium. Suppressing native ad.');
      return;
    }

    AppLogger.debug('NativeAd', '📢 [NativeAd:STEP 1/4:WAIT_SDK] Awaiting AdMob initialization...');
    await AdMobService.ensureInitialized();
    if (!mounted) return;

    final unitId = AdMobService.nativeAdUnitId;
    AppLogger.debug('NativeAd', '📢 [NativeAd:STEP 2/4:REQUEST] Requesting NativeAd for Unit: $unitId');

    if (unitId == null || unitId.isEmpty) {
      AppLogger.error('NativeAd', '❌ [NativeAd:ERROR] No valid Native Ad Unit ID configured.');
      setState(() => _isAdFailed = true);
      return;
    }

    _nativeAd = NativeAd(
      adUnitId: unitId,
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
          AppLogger.debug('NativeAd', '✅ [NativeAd:STEP 3/4:LOADED] Native ad loaded and ready for rendering! Unit: ${ad.adUnitId}');
          if (mounted) {
            setState(() {
              _isAdLoaded = true;
            });
          }
        },
        onAdFailedToLoad: (ad, error) {
          final diagnostic = AdMobService.describeAdError(error.code, error.message);
          AppLogger.error('NativeAd', '❌ [NativeAd:FAILED] Native ad failed to load.');
          AppLogger.error('NativeAd', '❌ [NativeAd:DIAGNOSTIC] $diagnostic');
          AppLogger.error('NativeAd', '❌ [NativeAd:DETAILS] Code: ${error.code} | Message: ${error.message} | Domain: ${error.domain}');
          ad.dispose();
          if (mounted) {
            setState(() {
              _isAdFailed = true;
            });
          }
        },
        onAdOpened: (ad) => AppLogger.debug('NativeAd', '📢 [NativeAd:STEP 4/4:CLICKED] User clicked native ad.'),
        onAdClosed: (ad) => AppLogger.debug('NativeAd', '📢 [NativeAd:STEP 4/4:CLOSED] User closed native ad.'),
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

    // 🛡️ PREMIUM SUPPRESSION: Completely hide native ads for Premium subscribers
    if (SessionManager.instance.isPremium || _isAdFailed || !_isAdLoaded || _nativeAd == null) {
      return const SizedBox.shrink();
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
                ? Colors.black.withValues(alpha: AppColors.opacity20) 
                : theme.colorScheme.primary.withValues(alpha: AppColors.opacity10),
            blurRadius: 16,
            offset: const Offset(0, 8),
            spreadRadius: 1,
          ),
        ],
        border: Border.all(
          color: theme.colorScheme.outlineVariant.withValues(alpha: AppColors.opacity20),
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
                  color: Colors.black.withValues(alpha: AppColors.opacity50),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.white.withValues(alpha: AppColors.opacity20)),
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
                        fontWeight: AppTypography.black,
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
