import 'package:banjarabio/core/constants/app_typography.dart';
import 'package:flutter/material.dart';
import 'package:banjarabio/core/services/ad_reward_service.dart';
import 'package:banjarabio/core/services/app_logger.dart';
import 'package:banjarabio/l10n/app_localizations.dart';
import 'package:banjarabio/theme/app_colors.dart';
import 'package:banjarabio/core/utils/app_feedback_service.dart';

/// [RewardedAdDialog]
/// 
/// A premium-styled dialog that offers users a way to unlock features
/// by watching a rewarded advertisement.
class RewardedAdDialog extends StatefulWidget {
  final AdRewardType rewardType;
  final VoidCallback onRewardGranted;

  const RewardedAdDialog({
    super.key,
    required this.rewardType,
    required this.onRewardGranted,
  });

  @override
  State<RewardedAdDialog> createState() => _RewardedAdDialogState();
}

class _RewardedAdDialogState extends State<RewardedAdDialog> {
  bool _isLoadingAd = false;
  final _adService = AdRewardService();

  void _handleWatchAd() async {
    setState(() => _isLoadingAd = true);
    AppLogger.debug('RewardedAdDialog', '📢 [RewardedDialog:STEP 1/3:TAP] User tapped Watch Ad button for ${widget.rewardType.name}.');
    
    if (!_adService.isAdReady) {
      AppLogger.debug('RewardedAdDialog', '📢 [RewardedDialog:STEP 2/3:PRELOAD] Rewarded ad not ready. Triggering load and waiting 2s...');
      _adService.loadRewardedAd();
      await Future.delayed(const Duration(seconds: 2));
    }
    
    if (!mounted) return;
    
    if (_adService.isAdReady) {
      AppLogger.debug('RewardedAdDialog', '📢 [RewardedDialog:STEP 3/3:SHOW] Presenting rewarded ad to user...');
      await _adService.showRewardedAd(
        onRewardEarned: (reward) {
          AppLogger.debug('RewardedAdDialog', '🎉 [RewardedDialog:SUCCESS] Reward granted to user: ${widget.rewardType.name}');
          widget.onRewardGranted();
          if (mounted) Navigator.of(context).pop();
        },
      );
    } else {
      AppLogger.debug('RewardedAdDialog', '❌ [RewardedDialog:NOT_READY] Ad could not be fetched in time. Showing snackbar.');
      if (mounted) {
        AppFeedback.showInfo(
          context,
          AppLocalizations.of(context)?.adNotReady ?? 'Ad not ready yet. Please try again in a moment.',
        );
      }
    }
    
    if (mounted) setState(() => _isLoadingAd = false);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);
    String title = '';
    String description = '';
    String rewardText = '';
    IconData icon = Icons.ads_click;
    Color accentColor = theme.primaryColor;

    if (widget.rewardType == AdRewardType.profileViews) {
      title = l10n?.dailyLimitReached ?? 'Daily Limit Reached';
      description = l10n?.dailyLimitViewsReached ??
          'You have used all your daily profile views.';
      rewardText = l10n?.unlockMoreViewsAd ??
          'Watch a quick ad to unlock 5 MORE views for today!';
      icon = Icons.visibility;
    } else {
      title = l10n?.directMessage ?? 'Direct Message';
      description = l10n?.directMessagingPremium ??
          'Direct messaging is a Premium feature.';
      rewardText = l10n?.unlockDirectMessageAd ??
          'Watch 3 ads to unlock 1 direct message for FREE!';
      icon = Icons.message;
      accentColor = Colors.orange;
    }

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: accentColor.withValues(alpha: AppColors.opacity10),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: accentColor, size: 40),
            ),
            const SizedBox(height: 20),
            Text(
              title,
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: AppTypography.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              description,
              style: theme.textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: accentColor.withValues(alpha: AppColors.opacity30)),
              ),
              child: Text(
                rewardText,
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: AppTypography.bold,
                  color: accentColor,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _isLoadingAd ? null : _handleWatchAd,
                style: ElevatedButton.styleFrom(
                  backgroundColor: accentColor,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: _isLoadingAd
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation(Colors.white),
                        ),
                      )
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.play_circle_fill),
                          const SizedBox(width: 8),
                          Text(l10n?.watchAdToUnlock ?? 'WATCH AD TO UNLOCK'),
                        ],
                      ),
              ),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                l10n?.maybeLater ?? 'Maybe Later',
                style: TextStyle(color: Colors.grey[600]),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
