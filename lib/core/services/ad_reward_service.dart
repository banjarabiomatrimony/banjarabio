import 'package:flutter/foundation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:banjarabio/services/ads/ad_service.dart';
import 'package:banjarabio/core/session_manager.dart';
import 'package:banjarabio/core/services/app_logger.dart';

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
  Future<void> loadRewardedAd() async {
    if (SessionManager.instance.isPremium) {
      AppLogger.debug('AdReward', '📢 [RewardedAd:ABORT] User is Premium. Skipping rewarded ad preload.');
      return;
    }
    if (_isAdLoading) {
      AppLogger.debug('AdReward', '📢 [RewardedAd:STATUS] Rewarded ad load already in flight.');
      return;
    }
    _isAdLoading = true;

    AppLogger.debug('AdReward', '📢 [RewardedAd:STEP 1/5:WAIT_SDK] Awaiting AdMob initialization...');
    await AdMobService.ensureInitialized();

    final adUnitId = AdMobService.rewardedAdUnitId;
    AppLogger.debug('AdReward', '📢 [RewardedAd:STEP 2/5:REQUEST] Requesting Rewarded ad for Unit: $adUnitId');

    if (adUnitId == null || adUnitId.isEmpty) {
      AppLogger.error('AdReward', '❌ [RewardedAd:ERROR] No valid Rewarded Ad Unit ID configured.');
      _isAdLoading = false;
      return;
    }

    RewardedAd.load(
      adUnitId: adUnitId,
      request: const AdRequest(),
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: (ad) {
          AppLogger.debug('AdReward', '✅ [RewardedAd:STEP 3/5:LOADED] Rewarded ad loaded and cached! Unit: ${ad.adUnitId}');
          _rewardedAd = ad;
          _isAdLoading = false;
          _setupAdCallbacks(ad);
        },
        onAdFailedToLoad: (error) {
          final diagnostic = AdMobService.describeAdError(error.code, error.message);
          AppLogger.error('AdReward', '❌ [RewardedAd:FAILED] Rewarded ad failed to load.');
          AppLogger.error('AdReward', '❌ [RewardedAd:DIAGNOSTIC] $diagnostic');
          AppLogger.error('AdReward', '❌ [RewardedAd:DETAILS] Code: ${error.code} | Message: ${error.message} | Domain: ${error.domain}');
          _rewardedAd = null;
          _isAdLoading = false;
        },
      ),
    );
  }

  void _setupAdCallbacks(RewardedAd ad) {
    ad.fullScreenContentCallback = FullScreenContentCallback(
      onAdShowedFullScreenContent: (ad) {
        AppLogger.debug('AdReward', '📢 [RewardedAd:DISPLAY] Rewarded ad displaying on screen.');
      },
      onAdDismissedFullScreenContent: (ad) {
        AppLogger.debug('AdReward', '📢 [RewardedAd:DISMISSED] Rewarded ad dismissed. Preloading next.');
        ad.dispose();
        _rewardedAd = null;
        loadRewardedAd();
      },
      onAdFailedToShowFullScreenContent: (ad, error) {
        AppLogger.error('AdReward', '❌ [RewardedAd:DISPLAY_FAILED] Rewarded ad failed to show: $error');
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
      AppLogger.debug('AdReward', '📢 [RewardedAd:STEP 4/5:TRIGGER] No ad cached. Triggering load...');
      loadRewardedAd();
      return;
    }

    AppLogger.debug('AdReward', '📢 [RewardedAd:STEP 4/5:DISPLAY] Showing Rewarded ad to user...');
    await _rewardedAd!.show(
      onUserEarnedReward: (ad, reward) {
        AppLogger.debug('AdReward', '🎉 [RewardedAd:STEP 5/5:REWARD_EARNED] User completed ad! Reward: ${reward.amount} ${reward.type}');
        onRewardEarned(reward);
      },
    );
  }

  /// Check if an ad is ready to show
  bool get isAdReady => _rewardedAd != null;
}
