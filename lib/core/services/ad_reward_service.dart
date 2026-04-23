import 'package:flutter/foundation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:banjarabio/services/ads/ad_service.dart';
import 'package:banjarabio/core/session_manager.dart';

/// Reward types for different ad-supported actions
enum AdRewardType {
  profileViews, // Watch 1 ad -> 5 views
  directMessage, // Watch 3 ads -> 1 DM unlock
  whoViewedMe,   // Watch 1 ad -> see who viewed me for 24h
}

/// [AdRewardService]
/// 
/// Manages Google Mobile Ads initialization and Rewarded Ad lifecycle.
/// Follows the "Reward-upon-Completion" pattern for free users.
class AdRewardService {
  static final AdRewardService _instance = AdRewardService._();
  factory AdRewardService() => _instance;
  AdRewardService._();


  RewardedAd? _rewardedAd;
  bool _isAdLoading = false;

  /// Initialize Mobile Ads SDK (Called from StartupOrchestrator via AdMobService)
  void setInitialized() {
    loadRewardedAd();
  }

  /// Load a Rewarded Ad
  void loadRewardedAd() {
    if (_isAdLoading || SessionManager.instance.isPremium) return;
    _isAdLoading = true;

    final adUnitId = AdMobService.rewardedAdUnitId;
    if (adUnitId == null) {
      _isAdLoading = false;
      return;
    }

    RewardedAd.load(
      adUnitId: adUnitId,
      request: const AdRequest(),
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: (ad) {
          debugPrint('BANJARABIO_AD: Rewarded Ad Loaded: ${ad.adUnitId}');
          _rewardedAd = ad;
          _isAdLoading = false;
          _setupAdCallbacks(ad);
        },
        onAdFailedToLoad: (error) {
          debugPrint('BANJARABIO_AD: Rewarded Ad Failed to Load: $error');
          _rewardedAd = null;
          _isAdLoading = false;
        },
      ),
    );
  }

  void _setupAdCallbacks(RewardedAd ad) {
    ad.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (ad) {
        debugPrint('BANJARABIO_AD: Rewarded Ad Dismissed');
        ad.dispose();
        _rewardedAd = null;
        // Pre-load the next one
        loadRewardedAd();
      },
      onAdFailedToShowFullScreenContent: (ad, error) {
        debugPrint('BANJARABIO_AD: Rewarded Ad Failed to Show: $error');
        ad.dispose();
        _rewardedAd = null;
        loadRewardedAd();
      },
    );
  }

  /// Show the loaded ad and trigger a callback upon reward
  Future<void> showRewardedAd({
    required Function(RewardItem reward) onRewardEarned,
    VoidCallback? onAdDismissed,
  }) async {
    if (_rewardedAd == null) {
      debugPrint('BANJARABIO_AD: No ad ready. Attempting to load...');
      loadRewardedAd();
      return;
    }

    await _rewardedAd!.show(
      onUserEarnedReward: (ad, reward) {
        debugPrint('BANJARABIO_AD: Reward Earned: ${reward.amount} ${reward.type}');
        onRewardEarned(reward);
      },
    );
  }

  /// Check if an ad is ready to show
  bool get isAdReady => _rewardedAd != null;
}
