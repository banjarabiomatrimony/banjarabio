import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:banjarabio/services/ads/ad_service.dart';
import 'package:banjarabio/core/services/app_logger.dart';

class InterstitialAdManager {
  InterstitialAd? _interstitialAd;
  bool _isLoaded = false;

  void loadAd() {
    if (!AdMobService.isHealthy) return;

    InterstitialAd.load(
      adUnitId: AdMobService.interstitialAdUnitId ?? '',
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          _interstitialAd = ad;
          _isLoaded = true;
          
          _interstitialAd!.fullScreenContentCallback = FullScreenContentCallback(
            onAdDismissedFullScreenContent: (ad) {
              ad.dispose();
              _isLoaded = false;
              loadAd(); // Preload next
            },
            onAdFailedToShowFullScreenContent: (ad, error) {
              ad.dispose();
              _isLoaded = false;
              loadAd(); // Preload next
            },
          );
        },
        onAdFailedToLoad: (error) {
          AppLogger.error('InterstitialAdManager', 'InterstitialAd failed to load: $error');
          _isLoaded = false;
        },
      ),
    );
  }

  void showAd() {
    if (_isLoaded && _interstitialAd != null) {
      try {
        _interstitialAd!.show();
      } catch (e) {
        AppLogger.error('InterstitialAdManager', 'Error showing InterstitialAd: $e');
      } finally {
        _interstitialAd = null;
        _isLoaded = false;
      }
    } else {
      AppLogger.debug('InterstitialAdManager', 'InterstitialAd not ready yet.');
      loadAd(); // Try loading again for next time
    }
  }

  void dispose() {
    final ad = _interstitialAd;
    _interstitialAd = null;
    Future.microtask(() => ad?.dispose());
  }
}
