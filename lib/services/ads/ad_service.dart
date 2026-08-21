import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:banjarabio/core/services/app_logger.dart';

final adServiceProvider = Provider((ref) => AdMobService());

class AdMobService {
  static String? get appId {
    if (kDebugMode) {
      if (Platform.isAndroid) {
        return 'ca-app-pub-3940256099942544~3347511713'; // Google AdMob Android Test App ID
      } else if (Platform.isIOS) {
        return 'ca-app-pub-3940256099942544~1458002511'; // Google AdMob iOS Test App ID
      }
    }
    if (Platform.isAndroid) {
      return 'ca-app-pub-4950621499761292~6413891372'; // BanjaraBio Android App ID
    } else if (Platform.isIOS) {
      return 'ca-app-pub-4950621499761292~1458002511'; // BanjaraBio iOS App ID (Placeholder/To be updated)
    }
    return null;
  }

  static String? get bannerAdUnitId {
    if (kDebugMode) {
      return Platform.isAndroid
          ? 'ca-app-pub-3940256099942544/6300978111' // Android Test ID
          : 'ca-app-pub-3940256099942544/2934735716'; // iOS Test ID
    }
    if (Platform.isAndroid) {
      return 'ca-app-pub-4950621499761292/3012547462'; // BanjaraBio Android Production ID
    } else if (Platform.isIOS) {
      return null; // BanjaraBio iOS Production ID (Add later)
    }
    return null;
  }

  static String? get rewardedAdUnitId {
    if (kDebugMode) {
      return Platform.isAndroid
          ? 'ca-app-pub-3940256099942544/5224354917' // Android Test ID
          : 'ca-app-pub-3940256099942544/1712485313'; // iOS Test ID
    }
    if (Platform.isAndroid) {
      return 'ca-app-pub-4950621499761292/6951792473'; // BanjaraBio Android Production ID
    } else if (Platform.isIOS) {
      return null; // BanjaraBio iOS Production ID (Add later)
    }
    return null;
  }

  static String? get interstitialAdUnitId {
    if (kDebugMode) {
      return Platform.isAndroid
          ? 'ca-app-pub-3940256099942544/1033173712' // Android Test ID
          : 'ca-app-pub-3940256099942544/4411468910'; // iOS Test ID
    }
    if (Platform.isAndroid) {
      return 'ca-app-pub-4950621499761292/1628794557'; // BanjaraBio Android Production ID
    } else if (Platform.isIOS) {
      return null; // BanjaraBio iOS Production ID (Add later)
    }
    return null;
  }

  static String? get appOpenAdUnitId {
    if (kDebugMode) {
      return Platform.isAndroid
          ? 'ca-app-pub-3940256099942544/9257395921' // Google Official Android App Open Test ID
          : 'ca-app-pub-3940256099942544/5662855259'; // iOS Test ID
    }
    if (Platform.isAndroid) {
      return 'ca-app-pub-4950621499761292/7853810607'; // BanjaraBio Android Production ID
    } else if (Platform.isIOS) {
      return null; // BanjaraBio iOS Production ID (Add later)
    }
    return null;
  }

  static String? get nativeAdUnitId {
    if (kDebugMode) {
      return Platform.isAndroid
          ? 'ca-app-pub-3940256099942544/2247696110' // Android Test ID
          : 'ca-app-pub-3940256099942544/3986693107'; // iOS Test ID
    }
    if (Platform.isAndroid) {
      return 'ca-app-pub-4950621499761292/5008764223'; // BanjaraBio Android Production ID
    } else if (Platform.isIOS) {
      return null; // BanjaraBio iOS Production ID (Add later)
    }
    return null;
  }

  static bool isHealthy = true;

  /// Decodes AdMob error codes into actionable diagnostics
  static String describeAdError(int code, String message) {
    switch (code) {
      case 0:
        return 'Code 0 (INTERNAL_ERROR): Ad server failure, WebView/JavascriptEngine timeout, or Private DNS/AdBlocker active on device. Message: $message';
      case 1:
        return 'Code 1 (INVALID_REQUEST): Invalid Ad Unit ID, incorrect ad size, or mismatched configuration. Message: $message';
      case 2:
        return 'Code 2 (NETWORK_ERROR): Network request failed due to lack of internet or connection drop. Message: $message';
      case 3:
        return 'Code 3 (NO_FILL): Google AdMob servers currently have no ads in inventory for this unit/region. Message: $message';
      default:
        return 'Code $code: $message';
    }
  }

  // Readiness gate — screens await this before loading any ad.
  static final Completer<void> _initCompleter = Completer<void>();
  static bool _isInitialized = false;
  static bool _isInitializing = false;

  /// Returns a Future that completes once MobileAds SDK is initialized.
  /// Safe to call multiple times; immediately kicks off init if not started yet.
  static Future<void> ensureInitialized() {
    if (_isInitialized) {
      AppLogger.debug('AdMob', '📢 [AdMob:STEP 1/5:INIT] ensureInitialized: Already initialized.');
      return Future.value();
    }
    if (!_isInitializing) {
      AppLogger.debug('AdMob', '📢 [AdMob:STEP 1/5:INIT] ensureInitialized: Triggering on-demand initialization.');
      initialize();
    }
    return _initCompleter.future;
  }

  static Future<AdSize> getAdaptiveAdSize(BuildContext context) async {
    final width = MediaQuery.of(context).size.width.truncate();
    AppLogger.debug('AdMob', '📢 [AdMob:STEP 2/5:SIZE] Calculating adaptive banner size for screen width: ${width}px');
    final AdSize? size = await AdSize.getAnchoredAdaptiveBannerAdSize(
      Orientation.portrait,
      width,
    );
    final finalSize = size ?? AdSize.banner;
    AppLogger.debug('AdMob', '📢 [AdMob:STEP 2/5:SIZE] Resolved size: ${finalSize.width}x${finalSize.height}');
    return finalSize;
  }

  static final BannerAdListener bannerListener = BannerAdListener(
    onAdLoaded: (ad) {
      AppLogger.debug('AdMob', '📢 [AdMob:STEP 4/5:LOADED] Banner Ad Loaded Successfully! Unit: ${ad.adUnitId}');
      AppLogger.debug('AdMob', '📢 [AdMob:STEP 4/5:LOADED] Response ID: ${ad.responseInfo?.responseId ?? "N/A"}');
    },
    onAdFailedToLoad: (ad, error) {
      Future.microtask(() => ad.dispose());
      final diagnostic = describeAdError(error.code, error.message);
      AppLogger.error('AdMob', '❌ [AdMob:STEP 4/5:FAILED] Banner Ad Failed! Unit: ${ad.adUnitId}');
      AppLogger.error('AdMob', '❌ [AdMob:DIAGNOSTIC] $diagnostic');
      AppLogger.error('AdMob', '❌ [AdMob:DETAILS] Domain: ${error.domain}, Code: ${error.code}');
    },
    onAdOpened: (ad) => AppLogger.debug('AdMob', '📢 [AdMob:STEP 5/5:ACTION] User opened/clicked Ad: ${ad.adUnitId}'),
    onAdClosed: (ad) => AppLogger.debug('AdMob', '📢 [AdMob:STEP 5/5:ACTION] User dismissed/closed Ad: ${ad.adUnitId}'),
  );

  static Future<void> initialize() async {
    if (_isInitialized) return;
    if (_isInitializing) return _initCompleter.future;
    _isInitializing = true;
    AppLogger.debug('AdMob', '📢 [AdMob:STEP 1/5:INIT] Starting Google Mobile Ads SDK initialization...');
    AppLogger.debug('AdMob', '📢 [AdMob:STEP 1/5:INIT] Platform: ${Platform.isAndroid ? "Android" : "iOS"} | Debug Mode: $kDebugMode');
    AppLogger.debug('AdMob', '📢 [AdMob:STEP 1/5:INIT] App ID: $appId');
    try {
      final initStatus = await MobileAds.instance.initialize();
      AppLogger.debug('AdMob', '📢 [AdMob:STEP 1/5:INIT] SDK Adapter status: ${initStatus.adapterStatuses}');
      
      final RequestConfiguration configuration = RequestConfiguration(
        testDeviceIds: [
          'B2F87125B4021395A8302FAA6A77BD23',     // Vivo V2105 Device ID (Active)
          '48B6B1CDD6B77643C4E9A3FCF6A34A2D',     // Original MD5 hash
          'c7a4ee60-d501-4dab-acea-603f08026923', // Vivo Advertising UUID
          '3ccf5d6f6e5223a1',                      // V2105 potential test ID
        ],
      );
      await MobileAds.instance.updateRequestConfiguration(configuration);
      _isInitialized = true;
      _isInitializing = false;
      if (!_initCompleter.isCompleted) _initCompleter.complete();
      AppLogger.debug('AdMob', '📢 [AdMob:STEP 1/5:INIT] ✅ SDK Initialization complete & test devices configured.');
    } catch (e) {
      _isInitialized = true; // Mark done so callers do not hang.
      _isInitializing = false;
      if (!_initCompleter.isCompleted) _initCompleter.complete();
      AppLogger.error('AdMob', '❌ [AdMob:STEP 1/5:INIT] CRASH during MobileAds.initialize(): $e');
    }
  }
}
