import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:banjarabio/services/ads/ad_service.dart';
import 'package:banjarabio/core/services/app_logger.dart';

class AppOpenAdManager {
  AppOpenAd? _appOpenAd;
  bool _isShowingAd = false;
  DateTime? _appOpenLoadTime;
  bool _isWebViewBroken = false;

  /// Load an [AppOpenAd].
  void loadAd() async {
    // Don't retry if WebView engine is known to be broken on this device
    if (_isWebViewBroken) return;

    // 🚨 ANR FIX: Wait for SDK to be ready before requesting ads.
    await AdMobService.ensureInitialized();

    AppLogger.debug('AppOpenAdManager', 'Ads: [APPOPEN] Requesting load for: ${AdMobService.appOpenAdUnitId}');
    AppOpenAd.load(
      adUnitId: AdMobService.appOpenAdUnitId ?? '',
      request: const AdRequest(),
      adLoadCallback: AppOpenAdLoadCallback(
        onAdLoaded: (ad) {
          AppLogger.debug('AppOpenAdManager', 'Ads: [APPOPEN] Successfully loaded: ${ad.adUnitId}');
          _appOpenLoadTime = DateTime.now();
          _appOpenAd = ad;
        },
        onAdFailedToLoad: (error) {
          AppLogger.error('AppOpenAdManager', 'Ads: [APPOPEN] FAILED: ${error.code} - ${error.message}');
          AppLogger.error('AppOpenAdManager', 'Ads: [APPOPEN] Domain: ${error.domain}');
          if (error.message.contains('JavascriptEngine')) {
            _isWebViewBroken = true;
            AppLogger.debug('AppOpenAdManager', 'Ads: [APPOPEN] CRITICAL: WebView JavascriptEngine unavailable.');
          }
        },
      ),
    );
  }


  /// Whether an ad is available to be shown.
  bool get isAdAvailable {
    return _appOpenAd != null && _appOpenLoadTime != null && 
           DateTime.now().difference(_appOpenLoadTime!).inHours < 4;
  }

  /// Shows the ad if one is available and not already showing.
  void showAdIfAvailable() {
    if (!isAdAvailable) {
      loadAd();
      return;
    }
    if (_isShowingAd) {
      return;
    }

    _appOpenAd!.fullScreenContentCallback = FullScreenContentCallback(
      onAdShowedFullScreenContent: (ad) {
        _isShowingAd = true;
      },
      onAdFailedToShowFullScreenContent: (ad, error) {
        _isShowingAd = false;
        Future.microtask(() => ad.dispose());
        _appOpenAd = null;
        loadAd();
      },
      onAdDismissedFullScreenContent: (ad) {
        _isShowingAd = false;
        Future.microtask(() => ad.dispose());
        _appOpenAd = null;
        loadAd();
      },
    );
    try {
      _appOpenAd!.show();
    } catch (e) {
      AppLogger.error('AppOpenAdManager', '[BANJARABIO_AUDIT:ADS] AppOpenAd.show() failed: $e');
      _isShowingAd = false;
      _appOpenAd?.dispose();
      _appOpenAd = null;
    }
  }
}
