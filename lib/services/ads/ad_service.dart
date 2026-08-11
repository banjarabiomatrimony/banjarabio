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
          ? 'ca-app-pub-3940256099942544/3419835294' // Android Test ID
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

  // Readiness gate — screens await this before loading any ad.
  static final Completer<void> _initCompleter = Completer<void>();
  static bool _isInitialized = false;

  /// Returns a Future that completes once MobileAds SDK is initialized.
  /// Safe to call multiple times; returns immediately if already done.
  static Future<void> ensureInitialized() {
    if (_isInitialized) return Future.value();
    return _initCompleter.future;
  }

  static Future<AdSize> getAdaptiveAdSize(BuildContext context) async {
    final width = MediaQuery.of(context).size.width.truncate();
    AppLogger.debug('AdService', 'Ads: [SIZE] Calculating adaptive size for width: $width');
    final AdSize? size = await AdSize.getAnchoredAdaptiveBannerAdSize(
      Orientation.portrait,
      width,
    );
    AppLogger.debug('AdService', 'Ads: [SIZE] Calculated: ${size?.width}x${size?.height}');
    return size ?? AdSize.banner;
  }

  static final BannerAdListener bannerListener = BannerAdListener(
    onAdLoaded: (ad) {
      AppLogger.debug('AdService', 'Ads: [BANNER] Successfully loaded: ${ad.adUnitId}');
      AppLogger.debug('AdService', 'Ads: [BANNER] Latency: ${ad.responseInfo?.responseId ?? "N/A"}');
    },
    onAdFailedToLoad: (ad, error) {
      // Use microtask to ensure we don't dispose while the native side is still processing
      Future.microtask(() => ad.dispose());
      AppLogger.error('AdService', 'Ads: [BANNER] FAILED (${ad.adUnitId})');
      AppLogger.error('AdService', 'Ads: [BANNER] Error Code: ${error.code}');
      AppLogger.error('AdService', 'Ads: [BANNER] Error Message: ${error.message}');
      AppLogger.error('AdService', 'Ads: [BANNER] Domain: ${error.domain}');
      AppLogger.error('AdService', 'Ads: [BANNER] ResponseInfo: ${error.responseInfo}');
      
      if (error.message.contains('JavascriptEngine')) {
        isHealthy = false;
        AppLogger.debug('AdService', 'Ads: [CRITICAL] WebView JavascriptEngine unavailable on this device.');
      }
    },
    onAdOpened: (ad) => debugPrint('Ads: [BANNER] Opened: ${ad.adUnitId}'),
    onAdClosed: (ad) => debugPrint('Ads: [BANNER] Closed: ${ad.adUnitId}'),
  );

  static Future<void> initialize() async {
    AppLogger.debug('AdService', 'Ads: [INIT] Starting MobileAds initialization...');
    try {
      final initStatus = await MobileAds.instance.initialize();
      AppLogger.debug('AdService', 'Ads: [INIT] Adapter status: ${initStatus.adapterStatuses}');
      
      // Explicitly register the user's test devices internally
      final RequestConfiguration configuration = RequestConfiguration(
        testDeviceIds: [
          '48B6B1CDD6B77643C4E9A3FCF6A34A2D',     // Original MD5 hash
          'c7a4ee60-d501-4dab-acea-603f08026923', // Vivo Advertising UUID
          '3ccf5d6f6e5223a1',                      // V2105 potential test ID
        ],
      );
      await MobileAds.instance.updateRequestConfiguration(configuration);
      _isInitialized = true;
      if (!_initCompleter.isCompleted) _initCompleter.complete();
      AppLogger.debug('AdService', 'Ads: [INIT] Completed successfully with configuration update.');
    } catch (e) {
      isHealthy = false;
      _isInitialized = true; // Mark done even on failure so callers don't hang.
      if (!_initCompleter.isCompleted) _initCompleter.complete();
      AppLogger.error('AdService', 'Ads: [INIT] MobileAds.initialize() CRASHED: $e');
    }
  }
}
