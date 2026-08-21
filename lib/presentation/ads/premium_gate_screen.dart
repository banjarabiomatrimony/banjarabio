import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:banjarabio/services/ads/ad_service.dart';
import 'package:flutter/services.dart';
import 'package:banjarabio/theme/app_theme.dart';
import 'package:banjarabio/core/session_manager.dart';
import 'package:banjarabio/core/constants/app_typography.dart';
import 'package:banjarabio/core/services/app_logger.dart';
import 'package:banjarabio/l10n/app_localizations.dart';

class PremiumGateScreen extends StatefulWidget {
  final VoidCallback onComplete;
  final VoidCallback onPremiumPurchased;

  const PremiumGateScreen({
    super.key,
    required this.onComplete,
    required this.onPremiumPurchased,
  });

  @override
  State<PremiumGateScreen> createState() => _PremiumGateScreenState();
}

class _PremiumGateScreenState extends State<PremiumGateScreen> {
  RewardedAd? _rewardedAd;
  bool _isAdLoaded = false;
  bool _adCompleted = false;
  bool _isCheckingFirstRun = true;
  bool _adLoadFailed = false;
  Timer? _timeoutTimer;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkStatus();
    });
  }

  Future<void> _checkStatus() async {
    // If user is already premium, skip this screen entirely
    if (SessionManager.instance.isPremium) {
      widget.onComplete();
      return;
    }

    final prefs = await SharedPreferences.getInstance();
    final bool hasOpenedBefore = prefs.getBool('has_opened_before') ?? false;

    if (!hasOpenedBefore) {
      await prefs.setBool('has_opened_before', true);
      // It's the first run, skip the gate
      if (mounted) widget.onComplete();
    } else {
      if (mounted) {
        setState(() => _isCheckingFirstRun = false);
      }
      _waitForSdkAndLoadAd();
    }
  }

  Future<void> _waitForSdkAndLoadAd() async {
    _timeoutTimer = Timer(const Duration(seconds: 15), () {
      if (mounted && !_isAdLoaded && !_adCompleted) {
        setState(() => _adLoadFailed = true);
      }
    });

    await AdMobService.ensureInitialized();
    if (!mounted) return;

    _loadRewardedAd();
  }

  Future<void> _loadRewardedAd() async {
    AppLogger.debug('PremiumGate', '📢 [PremiumGate:STEP 1/4:WAIT_SDK] Awaiting AdMob initialization...');
    await AdMobService.ensureInitialized();
    if (!mounted) return;

    final unitId = AdMobService.rewardedAdUnitId;
    AppLogger.debug('PremiumGate', '📢 [PremiumGate:STEP 2/4:REQUEST] Requesting RewardedAd for Unit: $unitId');

    if (unitId == null || unitId.isEmpty) {
      AppLogger.error('PremiumGate', '❌ [PremiumGate:ERROR] No valid Rewarded Ad Unit ID configured.');
      _timeoutTimer?.cancel();
      if (mounted) setState(() => _adLoadFailed = true);
      return;
    }

    RewardedAd.load(
      adUnitId: unitId,
      request: const AdRequest(),
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: (ad) {
          AppLogger.debug('PremiumGate', '✅ [PremiumGate:STEP 3/4:LOADED] RewardedAd loaded and ready! Unit: ${ad.adUnitId}');
          _timeoutTimer?.cancel();
          if (mounted) {
            setState(() {
              _rewardedAd = ad;
              _isAdLoaded = true;
            });
          }
        },
        onAdFailedToLoad: (error) {
          final diagnostic = AdMobService.describeAdError(error.code, error.message);
          AppLogger.error('PremiumGate', '❌ [PremiumGate:FAILED] RewardedAd failed to load.');
          AppLogger.error('PremiumGate', '❌ [PremiumGate:DIAGNOSTIC] $diagnostic');
          AppLogger.error('PremiumGate', '❌ [PremiumGate:DETAILS] Code: ${error.code} | Message: ${error.message} | Domain: ${error.domain}');
          _timeoutTimer?.cancel();
          if (mounted) {
            setState(() => _adLoadFailed = true);
          }
        },
      ),
    );
  }

  void _showRewardedAd() {
    if (_rewardedAd != null) {
      AppLogger.debug('PremiumGate', '📢 [PremiumGate:STEP 4/4:DISPLAY] Showing RewardedAd to unlock premium feature.');
      _rewardedAd!.fullScreenContentCallback = FullScreenContentCallback(
        onAdDismissedFullScreenContent: (ad) {
          AppLogger.debug('PremiumGate', '📢 [PremiumGate:DISMISSED] RewardedAd dismissed.');
          Future.microtask(() => ad.dispose());
          _loadRewardedAd();
        },
        onAdFailedToShowFullScreenContent: (ad, error) {
          AppLogger.error('PremiumGate', '❌ [PremiumGate:DISPLAY_FAILED] RewardedAd failed to show: $error');
          Future.microtask(() => ad.dispose());
          _loadRewardedAd();
        },
      );

      _rewardedAd!.show(
        onUserEarnedReward: (ad, reward) {
          AppLogger.debug('PremiumGate', '🎉 [PremiumGate:REWARD_EARNED] User earned reward: ${reward.amount} ${reward.type}');
          HapticFeedback.mediumImpact();
          if (mounted) {
            setState(() => _adCompleted = true);
          }
        },
      );
      _rewardedAd = null;
    }
  }

  @override
  void dispose() {
    _timeoutTimer?.cancel();
    Future.microtask(() => _rewardedAd?.dispose());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    if (_isCheckingFirstRun) {
      return const Scaffold(backgroundColor: Colors.black);
    }

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.black,
                  AppTheme.primaryLight.withValues(alpha: 0.1),
                  Colors.black,
                ],
              ),
            ),
          ),
          
          BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Container(color: Colors.transparent),
          ),
          
          SafeArea(
            child: Column(
              children: [
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 140,
                          height: 140,
                          decoration: BoxDecoration(
                            color: AppTheme.primaryLight.withValues(alpha: 0.1),
                            shape: BoxShape.circle,
                            border: Border.all(color: AppTheme.primaryLight.withValues(alpha: 0.2), width: 2),
                            boxShadow: [
                              BoxShadow(
                                color: AppTheme.primaryLight.withValues(alpha: 0.15),
                                blurRadius: 40,
                                spreadRadius: 5,
                              ),
                            ],
                          ),
                          child: Center(
                            child: ClipOval(
                              child: Image.asset(
                                'assets/images/logo.png', // Updated to BanjaraBio logo path
                                width: 110,
                                height: 110,
                                fit: BoxFit.cover,
                                errorBuilder: (c, e, s) => const Icon(Icons.favorite_rounded, color: AppTheme.primaryLight, size: 80),
                              ),
                            ),
                          ),
                        ),
                        
                        const SizedBox(height: 24),
                        
                        Text(
                          l10n?.premiumAccess ?? 'PREMIUM ACCESS',
                          style: GoogleFonts.inter(
                            fontSize: AppTypography.bodySmall,
                            fontWeight: AppTypography.black,
                            letterSpacing: 4,
                            color: AppTheme.primaryLight,
                          ),
                        ),
                        
                        const SizedBox(height: 8),
                        
                        Text(
                          'BanjaraBio',
                          style: GoogleFonts.outfit(
                            fontSize: AppTypography.displayLarge,
                            fontWeight: AppTypography.black,
                            color: Colors.white,
                            letterSpacing: 1,
                          ),
                        ),
                        
                        const SizedBox(height: 12),
                        
                        Text(
                          l10n?.premiumGateSupport ?? 'Support our community by watching a quick ad,\nor upgrade to Pro for an ad-free experience.',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.inter(
                            fontSize: AppTypography.bodyLarge,
                            color: Colors.white.withValues(alpha: 0.5),
                            height: 1.5,
                          ),
                        ),
                        
                        const SizedBox(height: 48),

                        if (!_adCompleted) 
                          _isAdLoaded 
                            ? _buildMandatoryAdUI(l10n)
                            : _buildLoadingState(l10n)
                        else
                          _buildSuccessState(l10n),
                      ],
                    ),
                  ),
                ),
                
                Container(
                  padding: const EdgeInsets.fromLTRB(20, 24, 20, 40),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.02),
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
                    border: Border(top: BorderSide(color: Colors.white.withValues(alpha: 0.05))),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        l10n?.unblockAllProFeatures ?? 'UNBLOCK ALL PRO FEATURES',
                        style: GoogleFonts.inter(
                          fontSize: AppTypography.bodySmall, 
                          fontWeight: AppTypography.black, 
                          color: AppTheme.primaryLight,
                          letterSpacing: 2,
                        ),
                      ),
                      const SizedBox(height: 20),
                      Row(
                        children: [
                          Expanded(
                            child: _buildCompactProOption(
                              l10n?.monthly ?? 'Monthly', 
                              '₹49', 
                              onTap: () => _handleSubscription(context),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: _buildCompactProOption(
                              l10n?.annual ?? 'Annual', 
                              '₹499', 
                              isAccent: true,
                              onTap: () => _handleSubscription(context),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: _buildCompactProOption(
                              l10n?.lifetime ?? 'Lifetime', 
                              '₹2499',
                              onTap: () => _handleSubscription(context),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMandatoryAdUI(AppLocalizations? l10n) {
    return Column(
      children: [
        ElevatedButton(
          onPressed: () {
            HapticFeedback.heavyImpact();
            _showRewardedAd();
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: AppTheme.primaryLight,
            foregroundColor: Colors.white,
            minimumSize: const Size(double.infinity, 64),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
            elevation: 10,
            shadowColor: AppTheme.primaryLight.withValues(alpha: 0.4),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.play_circle_fill_rounded, size: 28),
              const SizedBox(width: 12),
              Text(
                l10n?.watchQuickAd ?? 'WATCH QUICK AD',
                style: GoogleFonts.outfit(fontWeight: AppTypography.black, fontSize: AppTypography.headingSmall),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Text(
          l10n?.continueBlockedUntilAdEnds ?? 'CONTINUE TO APP BLOCKED UNTIL AD ENDS',
          style: GoogleFonts.inter(
            fontSize: AppTypography.labelMedium, 
            fontWeight: AppTypography.bold, 
            color: Colors.white24,
            letterSpacing: 1,
          ),
        ),
      ],
    );
  }

  Widget _buildSuccessState(AppLocalizations? l10n) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          decoration: BoxDecoration(
            color: AppTheme.successLight.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppTheme.successLight.withValues(alpha: 0.3)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.check_circle_rounded, color: AppTheme.successLight, size: 20),
              const SizedBox(width: 10),
              Text(
                l10n?.adCompletedSuccessfully ?? 'AD COMPLETED SUCCESSFULLY',
                style: GoogleFonts.inter(color: AppTheme.successLight, fontWeight: AppTypography.bold, fontSize: AppTypography.bodyMedium),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        SizedBox(
          width: double.infinity,
          height: 64,
          child: ElevatedButton(
            onPressed: widget.onComplete,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: Colors.black,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
              elevation: 0,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  l10n?.continueToApp ?? 'CONTINUE TO APP',
                  style: GoogleFonts.outfit(fontWeight: AppTypography.black, fontSize: AppTypography.headingMedium, letterSpacing: 1),
                ),
                const SizedBox(width: 12),
                const Icon(Icons.arrow_forward_rounded, size: 22),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLoadingState(AppLocalizations? l10n) {
    return Column(
      children: [
        if (!_adLoadFailed) ...[
          const SizedBox(
            width: 32,
            height: 32,
            child: CircularProgressIndicator(
              strokeWidth: 3,
              valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primaryLight),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            l10n?.preparingAdExperience ?? 'PREPARING AD EXPERIENCE...',
            style: GoogleFonts.inter(fontSize: AppTypography.bodySmall, fontWeight: AppTypography.bold, color: Colors.white24, letterSpacing: 2),
          ),
        ],
        if (_adLoadFailed) ...[
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.orange.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.orange.withValues(alpha: 0.3)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.wifi_off_rounded, color: Colors.orange, size: 18),
                const SizedBox(width: 10),
                Flexible(
                  child: Text(
                    l10n?.adTemporarilyUnavailable ?? 'AD TEMPORARILY UNAVAILABLE',
                    style: GoogleFonts.inter(color: Colors.orange, fontWeight: AppTypography.bold, fontSize: AppTypography.bodySmall),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton(
              onPressed: widget.onComplete,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white.withValues(alpha: 0.1),
                foregroundColor: Colors.white70,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                elevation: 0,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    l10n?.continueToApp ?? 'CONTINUE TO APP',
                    style: GoogleFonts.outfit(fontWeight: AppTypography.extraBold, fontSize: AppTypography.headingSmall, letterSpacing: 1),
                  ),
                  const SizedBox(width: 10),
                  const Icon(Icons.arrow_forward_rounded, size: 20),
                ],
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildCompactProOption(String title, String price, {bool isAccent = false, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
        decoration: BoxDecoration(
          color: isAccent ? AppTheme.primaryLight.withValues(alpha: 0.2) : Colors.white.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: isAccent ? AppTheme.primaryLight : Colors.white.withValues(alpha: 0.1), width: 1.5),
        ),
        child: Column(
          children: [
            Text(
              title, 
              style: GoogleFonts.inter(color: isAccent ? Colors.white : Colors.white70, fontSize: AppTypography.bodySmall, fontWeight: AppTypography.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 6),
            Text(
              price, 
              style: GoogleFonts.outfit(color: Colors.white, fontSize: AppTypography.headingMedium, fontWeight: AppTypography.black),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  void _handleSubscription(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A1A),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20), side: const BorderSide(color: Colors.white12)),
        title: Text(l10n?.banjaraBioPro ?? 'BanjaraBio Pro', style: GoogleFonts.outfit(color: Colors.white, fontWeight: AppTypography.bold)),
        content: Text(
          l10n?.upgradeToUnlockPremiumFeatures ?? 'Upgrade to remove all ads and unlock premium biodata features.',
          style: GoogleFonts.inter(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n?.maybeLater ?? 'Maybe Later', style: const TextStyle(color: Colors.white38)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              widget.onPremiumPurchased();
            }, 
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primaryLight, foregroundColor: Colors.white),
            child: Text(l10n?.upgradeNow ?? 'Upgrade Now'),
          ),
        ],
      ),
    );
  }
}
