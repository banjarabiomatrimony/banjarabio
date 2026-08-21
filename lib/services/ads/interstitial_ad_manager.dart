import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:banjarabio/services/ads/ad_service.dart';
import 'package:banjarabio/core/services/app_logger.dart';

class InterstitialAdManager {
  InterstitialAd? _interstitialAd;
  bool _isLoaded = false;

  Future<void> loadAd() async {
    AppLogger.debug('InterstitialAd', '📢 [Interstitial:STEP 1/4:WAIT_SDK] Awaiting AdMob initialization...');
    await AdMobService.ensureInitialized();

    final unitId = AdMobService.interstitialAdUnitId;
    AppLogger.debug('InterstitialAd', '📢 [Interstitial:STEP 2/4:REQUEST] Requesting Interstitial ad for Unit: $unitId');

    if (unitId == null || unitId.isEmpty) {
      AppLogger.error('InterstitialAd', '❌ [Interstitial:ERROR] No valid Interstitial Ad Unit ID configured.');
      return;
    }

    InterstitialAd.load(
      adUnitId: unitId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          AppLogger.debug('InterstitialAd', '✅ [Interstitial:STEP 3/4:LOADED] Interstitial ad loaded and cached! Unit: ${ad.adUnitId}');
          _interstitialAd = ad;
          _isLoaded = true;
          
          _interstitialAd!.fullScreenContentCallback = FullScreenContentCallback(
            onAdShowedFullScreenContent: (ad) {
              AppLogger.debug('InterstitialAd', '📢 [Interstitial:DISPLAY] Interstitial ad displayed on screen.');
            },
            onAdDismissedFullScreenContent: (ad) {
              AppLogger.debug('InterstitialAd', '📢 [Interstitial:DISMISSED] Interstitial ad dismissed by user. Preloading next.');
              ad.dispose();
              _isLoaded = false;
              loadAd(); // Preload next
            },
            onAdFailedToShowFullScreenContent: (ad, error) {
              AppLogger.error('InterstitialAd', '❌ [Interstitial:DISPLAY_FAILED] Interstitial ad failed to show: $error');
              ad.dispose();
              _isLoaded = false;
              loadAd(); // Preload next
            },
          );
        },
        onAdFailedToLoad: (error) {
          final diagnostic = AdMobService.describeAdError(error.code, error.message);
          AppLogger.error('InterstitialAd', '❌ [Interstitial:FAILED] Interstitial ad failed to load.');
          AppLogger.error('InterstitialAd', '❌ [Interstitial:DIAGNOSTIC] $diagnostic');
          AppLogger.error('InterstitialAd', '❌ [Interstitial:DETAILS] Code: ${error.code} | Message: ${error.message} | Domain: ${error.domain}');
          _isLoaded = false;
        },
      ),
    );
  }

  void showAd() {
    if (_isLoaded && _interstitialAd != null) {
      try {
        AppLogger.debug('InterstitialAd', '📢 [Interstitial:STEP 4/4:DISPLAY] Showing Interstitial fullscreen ad to user.');
        _interstitialAd!.show();
      } catch (e) {
        AppLogger.error('InterstitialAd', '❌ [Interstitial:SHOW_EXCEPTION] InterstitialAd.show() error: $e');
      } finally {
        _interstitialAd = null;
        _isLoaded = false;
      }
    } else {
      AppLogger.debug('InterstitialAd', '📢 [Interstitial:STATUS] Interstitial ad not cached yet. Triggering load.');
      loadAd(); // Try loading again for next time
    }
  }

  void dispose() {
    final ad = _interstitialAd;
    _interstitialAd = null;
    Future.microtask(() => ad?.dispose());
  }
}
