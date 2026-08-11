import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sizer/sizer.dart';
import 'package:banjarabio/services/ads/ad_service.dart';
import 'package:banjarabio/core/session_manager.dart';
import 'package:banjarabio/core/providers/home_tab_provider.dart';
import 'package:banjarabio/core/services/app_logger.dart';

class BannerAdWidget extends ConsumerStatefulWidget {
  const BannerAdWidget({super.key});

  @override
  ConsumerState<BannerAdWidget> createState() => _BannerAdWidgetState();
}

class _BannerAdWidgetState extends ConsumerState<BannerAdWidget> with AutomaticKeepAliveClientMixin {
  BannerAd? _bannerAd;
  Timer? _delayTimer;
  bool _isAdLoaded = false;
  bool _isAdFailed = false;
  bool _isAdLoading = false;
  bool _startupDelayPassed = false;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    // 🚨 ANR FIX: Defer ad loading by 5 seconds to let profile rendering
    // finish first. AdMob WebView init blocks the main thread and directly
    // causes Signal 3 ANR on Vivo devices when competing with image decoding.
    // 🧬 SIGNAL 3 FIX: Increased delay to 15 seconds.
    // Allow the Home Feed images and grid generation to
    // finish first. AdMob WebView init blocks the main thread and directly
    // causes Signal 3 ANR on Vivo devices when competing with image decoding.
    // Note: Since AdMobService init is now in IDLE phase (20s), this widget
    // will actually wait until 20s to load.
    _delayTimer = Timer(const Duration(seconds: 15), () {
      if (!mounted) return;
      AppLogger.debug('BannerAdWidget', 'Ads: [WIDGET] 15s delay passed. Ready to load.');
      setState(() => _startupDelayPassed = true);
      if (!_isAdLoaded && !_isAdFailed && !_isAdLoading && !SessionManager.instance.isPremium) {
        _loadBannerAd();
      }
    });
  }

  Future<void> _loadBannerAd() async {
    _isAdLoading = true;
    // Wait for MobileAds to be ready
    await AdMobService.ensureInitialized();
    if (!mounted) {
      _isAdLoading = false;
      return;
    }

    final adSize = await AdMobService.getAdaptiveAdSize(context);
    if (!mounted) {
      _isAdLoading = false;
      return;
    }

    AppLogger.debug('BannerAdWidget', 'Ads: [WIDGET] Using Unit ID: ${AdMobService.bannerAdUnitId}');
    AppLogger.debug('BannerAdWidget', 'Ads: [WIDGET] Requesting Banner with size: $adSize');

    _bannerAd = BannerAd(
      adUnitId: AdMobService.bannerAdUnitId ?? '',
      size: adSize,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (ad) {
          AppLogger.debug('BannerAdWidget', 'Ads: [WIDGET] SUCCESS: ${ad.adUnitId}');
          if (mounted) {
            setState(() {
              _isAdLoaded = true;
              _isAdLoading = false;
            });
          }
        },
        onAdFailedToLoad: (ad, error) {
          AppLogger.error('BannerAdWidget', 'Ads: [WIDGET] FAILED: ${error.code} - ${error.message}');
          ad.dispose();
          if (mounted) {
            setState(() {
              _isAdFailed = true;
              _isAdLoading = false;
            });
          }
        },
      ),
    );

    _bannerAd!.load();
  }

  @override
  void dispose() {
    _delayTimer?.cancel();
    _bannerAd?.dispose();
    super.dispose();
  }

  Widget _buildSkeleton(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(8.0),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.withValues(alpha: 0.2)),
      ),
      child: Column(
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 10.0),
            child: Row(
              children: [
                Icon(Icons.public, color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.5), size: 16),
                const SizedBox(width: 6),
                Text(
                  'Sponsored',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.5),
                    letterSpacing: 0.5,
                  ),
                ),
                // 🧬 PERFORMANCE: Replaced Spacer with Flexible to prevent unbounded flex crashes
                const SizedBox(width: 8),
                const Flexible(child: SizedBox(width: double.infinity)),
                Icon(Icons.more_horiz, color: Colors.grey[200], size: 18),
              ],
            ),
          ),
          const Divider(height: 1, thickness: 1),
          // Shimmer Loading Area - 🧬 FIXED: Removed Expanded for safety in SliverToBoxAdapter
          SizedBox(
            height: 15.h,
            child: Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32.0),
                child: Text(
                  '. . .',
                  style: TextStyle(
                    fontSize: 24,
                    color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.3),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
          // Footer
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(16),
                bottomRight: Radius.circular(16),
              ),
            ),
            child: Text(
              'Loading Partner Network...',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: Colors.grey[500],
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final currentTab = ref.watch(homeTabProvider);

    // 🚨 FATAL RESOURCE ID CRASH FIX 🚨
    // When the user switches away from the Home tab, the BannerAd is still in the IndexedStack.
    // Native Android WebViews (TrichromeLibrary/0x6a) kept alive in the background crash 
    // memory-constrained Vivo devices when manipulating context resources. 
    // We strictly dispose them here when hidden.
    if (currentTab != 0) {
      if (_bannerAd != null) {
        _bannerAd!.dispose();
        _bannerAd = null;
        _isAdLoaded = false;
        _isAdLoading = false;
      }
      return _buildSkeleton(context);
    } else {
      if (_startupDelayPassed && _bannerAd == null && !_isAdLoading && !_isAdFailed && !SessionManager.instance.isPremium) {
        // Safe asynchronous trigger — only AFTER startup delay has passed
        Future.microtask(() => _loadBannerAd());
      }
    }

    if (_isAdFailed) {
      return Container(
        margin: const EdgeInsets.all(8.0),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.primaryContainer,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.3)),
        ),
        child: Container(
          height: 35.h,
          padding: const EdgeInsets.symmetric(vertical: 24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.stars_rounded, 
                color: Theme.of(context).colorScheme.primary, 
                size: 48
              ),
            const SizedBox(height: 16),
            Text(
              'Premium Matches', 
              style: TextStyle(
                fontWeight: FontWeight.bold, 
                fontSize: 18,
                color: Theme.of(context).colorScheme.onPrimaryContainer,
              ),
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Text(
                'Upgrade your profile to see who liked you and get 3x more visibility.', 
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: Theme.of(context).colorScheme.onPrimaryContainer.withValues(alpha: 0.8),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
    
    if (!_isAdLoaded || _bannerAd == null || SessionManager.instance.isPremium) {
      return _buildSkeleton(context);
    }

    return Container(
      margin: const EdgeInsets.all(8.0),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.withValues(alpha: 0.2)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            spreadRadius: 1,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 10.0),
            child: Row(
              children: [
                Icon(Icons.public, color: Theme.of(context).colorScheme.primary, size: 16),
                const SizedBox(width: 6),
                Text(
                  'Sponsored',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.primary,
                    letterSpacing: 0.5,
                  ),
                ),
                const Spacer(),
                Icon(Icons.more_horiz, color: Colors.grey[400], size: 18),
              ],
            ),
          ),
          const Divider(height: 1, thickness: 1),
          // Actual Banner Ad - 🧬 FIXED: Removed Expanded for safety in SliverToBoxAdapter
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: Center(
              child: SizedBox(
                width: _bannerAd!.size.width.toDouble(),
                height: _bannerAd!.size.height.toDouble(),
                child: AdWidget(ad: _bannerAd!),
              ),
            ),
          ),
          // Footer
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.05),
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(16),
                bottomRight: Radius.circular(16),
              ),
            ),
            child: Text(
              'Supporting the Banjara Community',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
