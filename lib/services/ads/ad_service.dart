import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

final adServiceProvider = Provider((ref) => AdMobService());

class AdMobService {
  static String? get appId {
    if (Platform.isAndroid) {
      return 'ca-app-pub-4950621499761292~6413891372'; // BanjaraBio Android App ID
    } else if (Platform.isIOS) {
      return 'ca-app-pub-4950621499761292~...'; // BanjaraBio iOS App ID (Add later)
    }
    return null;
  }

  static String? get bannerAdUnitId {
    if (Platform.isAndroid) {
      return 'ca-app-pub-4950621499761292/3012547462'; // BanjaraBio Production ID
    }
    return 'ca-app-pub-3940256099942544/6300978111'; // Android Test ID
  }

  static String? get rewardedAdUnitId {
    if (Platform.isAndroid) {
      return 'ca-app-pub-4950621499761292/6951792473'; // BanjaraBio Production ID
    }
    return 'ca-app-pub-3940256099942544/5224354917'; // Android Test ID
  }

  static String? get interstitialAdUnitId {
    if (Platform.isAndroid) {
      return 'ca-app-pub-4950621499761292/1628794557'; // BanjaraBio Production ID
    }
    return 'ca-app-pub-3940256099942544/1033173712'; // Android Test ID
  }

  static String? get appOpenAdUnitId {
    if (Platform.isAndroid) {
      return 'ca-app-pub-4950621499761292/7853810607'; // BanjaraBio Production ID
    }
    return 'ca-app-pub-3940256099942544/3419835294'; // Android Test ID
  }

  static String? get nativeAdUnitId {
    if (Platform.isAndroid) {
      return 'ca-app-pub-4950621499761292/5008764223'; // BanjaraBio Production ID
    }
    return 'ca-app-pub-3940256099942544/2247696110'; // Android Test ID
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
    debugPrint('Ads: [SIZE] Calculating adaptive size for width: $width');
    final AdSize? size = await AdSize.getAnchoredAdaptiveBannerAdSize(
      Orientation.portrait,
      width,
    );
    debugPrint('Ads: [SIZE] Calculated: ${size?.width}x${size?.height}');
    return size ?? AdSize.banner;
  }

  static final BannerAdListener bannerListener = BannerAdListener(
    onAdLoaded: (ad) {
      debugPrint('Ads: [BANNER] Successfully loaded: ${ad.adUnitId}');
      debugPrint('Ads: [BANNER] Latency: ${ad.responseInfo?.responseId ?? "N/A"}');
    },
    onAdFailedToLoad: (ad, error) {
      // Use microtask to ensure we don't dispose while the native side is still processing
      Future.microtask(() => ad.dispose());
      debugPrint('Ads: [BANNER] FAILED (${ad.adUnitId})');
      debugPrint('Ads: [BANNER] Error Code: ${error.code}');
      debugPrint('Ads: [BANNER] Error Message: ${error.message}');
      debugPrint('Ads: [BANNER] Domain: ${error.domain}');
      debugPrint('Ads: [BANNER] ResponseInfo: ${error.responseInfo}');
      
      if (error.message.contains('JavascriptEngine')) {
        isHealthy = false;
        debugPrint('Ads: [CRITICAL] WebView JavascriptEngine unavailable on this device.');
      }
    },
    onAdOpened: (ad) => debugPrint('Ads: [BANNER] Opened: ${ad.adUnitId}'),
    onAdClosed: (ad) => debugPrint('Ads: [BANNER] Closed: ${ad.adUnitId}'),
  );

  static Future<void> initialize() async {
    debugPrint('Ads: [INIT] Starting MobileAds initialization...');
    try {
      final initStatus = await MobileAds.instance.initialize();
      debugPrint('Ads: [INIT] Adapter status: ${initStatus.adapterStatuses}');
      
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
      debugPrint('Ads: [INIT] Completed successfully with configuration update.');
    } catch (e) {
      isHealthy = false;
      _isInitialized = true; // Mark done even on failure so callers don't hang.
      if (!_initCompleter.isCompleted) _initCompleter.complete();
      debugPrint('Ads: [INIT] MobileAds.initialize() CRASHED: $e');
    }
  }
}
