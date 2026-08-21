import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:banjarabio/services/ads/ad_service.dart';
import 'package:banjarabio/core/services/app_logger.dart';

class AppOpenAdManager {
  AppOpenAd? _appOpenAd;
  bool _isShowingAd = false;
  DateTime? _appOpenLoadTime;

  /// Load an [AppOpenAd].
  void loadAd() async {
    AppLogger.debug('AppOpenAd', '📢 [AppOpenAd:STEP 1/4:WAIT_SDK] Awaiting AdMob initialization...');
    await AdMobService.ensureInitialized();

    final unitId = AdMobService.appOpenAdUnitId;
    AppLogger.debug('AppOpenAd', '📢 [AppOpenAd:STEP 2/4:REQUEST] Requesting AppOpen ad for Unit: $unitId');

    if (unitId == null || unitId.isEmpty) {
      AppLogger.error('AppOpenAd', '❌ [AppOpenAd:ERROR] No valid AppOpen unit ID configured.');
      return;
    }

    AppOpenAd.load(
      adUnitId: unitId,
      request: const AdRequest(),
      adLoadCallback: AppOpenAdLoadCallback(
        onAdLoaded: (ad) {
          AppLogger.debug('AppOpenAd', '✅ [AppOpenAd:STEP 3/4:LOADED] AppOpen ad successfully loaded and cached! Unit: ${ad.adUnitId}');
          _appOpenLoadTime = DateTime.now();
          _appOpenAd = ad;
        },
        onAdFailedToLoad: (error) {
          final diagnostic = AdMobService.describeAdError(error.code, error.message);
          AppLogger.error('AppOpenAd', '❌ [AppOpenAd:FAILED] AppOpen ad failed to load.');
          AppLogger.error('AppOpenAd', '❌ [AppOpenAd:DIAGNOSTIC] $diagnostic');
          AppLogger.error('AppOpenAd', '❌ [AppOpenAd:DETAILS] Code: ${error.code} | Message: ${error.message} | Domain: ${error.domain}');
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
      AppLogger.debug('AppOpenAd', '📢 [AppOpenAd:STATUS] No cached ad available. Triggering pre-load.');
      loadAd();
      return;
    }
    if (_isShowingAd) {
      AppLogger.debug('AppOpenAd', '📢 [AppOpenAd:STATUS] Ad already showing on screen.');
      return;
    }

    AppLogger.debug('AppOpenAd', '📢 [AppOpenAd:STEP 4/4:DISPLAY] Showing AppOpen fullscreen ad to user.');
    _appOpenAd!.fullScreenContentCallback = FullScreenContentCallback(
      onAdShowedFullScreenContent: (ad) {
        _isShowingAd = true;
        AppLogger.debug('AppOpenAd', '📢 [AppOpenAd:DISPLAY] AppOpen ad displayed on screen.');
      },
      onAdFailedToShowFullScreenContent: (ad, error) {
        _isShowingAd = false;
        AppLogger.error('AppOpenAd', '❌ [AppOpenAd:DISPLAY_FAILED] Error displaying AppOpen ad: $error');
        Future.microtask(() => ad.dispose());
        _appOpenAd = null;
        loadAd();
      },
      onAdDismissedFullScreenContent: (ad) {
        _isShowingAd = false;
        AppLogger.debug('AppOpenAd', '📢 [AppOpenAd:DISMISSED] AppOpen ad dismissed by user. Preloading next.');
        Future.microtask(() => ad.dispose());
        _appOpenAd = null;
        loadAd();
      },
    );
    try {
      _appOpenAd!.show();
    } catch (e) {
      AppLogger.error('AppOpenAd', '❌ [AppOpenAd:SHOW_EXCEPTION] AppOpenAd.show() exception: $e');
      _isShowingAd = false;
      _appOpenAd?.dispose();
      _appOpenAd = null;
    }
  }
}
