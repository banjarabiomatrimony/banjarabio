import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import 'package:lottie/lottie.dart';
import 'package:banjarabio/core/models/daily_reward_model.dart';
import 'package:banjarabio/core/repositories/daily_reward_repository.dart';
import 'package:banjarabio/core/constants/app_typography.dart';

class DailyRewardDialog extends StatefulWidget {
  final DailyRewardModel initialStatus;

  const DailyRewardDialog({super.key, required this.initialStatus});

  static Future<DailyRewardModel?> show(BuildContext context, DailyRewardModel status) {
    return showModalBottomSheet<DailyRewardModel>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DailyRewardDialog(initialStatus: status),
    );
  }

  @override
  State<DailyRewardDialog> createState() => _DailyRewardDialogState();
}

class _DailyRewardDialogState extends State<DailyRewardDialog> with SingleTickerProviderStateMixin {
  late DailyRewardModel _status;
  bool _isClaiming = false;
  bool _showLottie = false;
  
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _status = widget.initialStatus;

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.05).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  Future<void> _claimReward() async {
    if (_status.isClaimedToday || _isClaiming) return;

    setState(() => _isClaiming = true);

    final res = await DailyRewardRepository().claimDailyReward();
    
    if (mounted) {
      if (res.isSuccess) {
        setState(() {
          _status = res.data;
          _showLottie = true;
        });
        
        // Show success snackbar
        ScaffoldMessenger.of(context).showSnackBar(
           SnackBar(
             content: Text('🎉 Success! ${_status.lastReward?.name ?? ""}'),
             backgroundColor: Colors.green.shade600,
             behavior: SnackBarBehavior.floating,
             margin: EdgeInsets.only(bottom: 10.h, left: 4.w, right: 4.w),
           ),
        );
        
        // Auto close after 2.5 seconds to let animation play
        Future.delayed(const Duration(milliseconds: 2500), () {
          if (mounted) Navigator.of(context).pop(_status);
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(res.errorMessage), backgroundColor: Colors.red),
        );
        setState(() => _isClaiming = false);
      }
    }
  }

  // Predefined UI definitions for the 7 days
  final List<Map<String, dynamic>> _rewardTiers = [
    {'day': 1, 'label': '+1 Profile View', 'icon': Icons.visibility_rounded},
    {'day': 2, 'label': '+1 Bookmark', 'icon': Icons.bookmark_rounded},
    {'day': 3, 'label': '+2 Profile Views', 'icon': Icons.visibility_rounded},
    {'day': 4, 'label': '+1 Bookmark', 'icon': Icons.bookmark_rounded},
    {'day': 5, 'label': '+3 Profile Views', 'icon': Icons.visibility_rounded},
    {'day': 6, 'label': '+5 Profile Views', 'icon': Icons.visibility_rounded},
    {'day': 7, 'label': '+1 Free Message', 'icon': Icons.chat_bubble_rounded, 'isJackpot': true},
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Stack(
      children: [
        Container(
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          ),
          padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 3.h),
          child: SafeArea(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
            // Handle bar
            Center(
              child: Container(
                width: 12.w,
                height: 5,
                decoration: BoxDecoration(
                  color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            SizedBox(height: 3.h),
            
            Text(
              'Daily Rewards 🎁',
              style: TextStyle(
                fontSize: AppTypography.headingMedium,
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.primary,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 1.h),
            Text(
              'Keep your 7-day streak alive to unlock the jackpot! Missing a day resets the streak.',
              style: TextStyle(fontSize: AppTypography.bodySmall, color: theme.colorScheme.onSurfaceVariant),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 4.h),
            
            // The 7-Day Journey
            ..._rewardTiers.map((tier) {
              final int day = tier['day'];
              final bool isJackpot = tier['isJackpot'] ?? false;
              
              bool isCompleted = false;
              bool isToday = false;

              if (_status.isClaimedToday) {
                 if (day <= _status.streakCount) isCompleted = true; // Including today's claim
              } else {
                 if (day < _status.streakCount) isCompleted = true; // Past days
                 if (day == _status.streakCount) {
                    isToday = true;
                 }
              }
              
              Widget leadingIcon;
              if (isCompleted) {
                 leadingIcon = Icon(Icons.check_circle_rounded, color: Colors.green.shade500, size: 28);
              } else if (isToday) {
                 leadingIcon = ScaleTransition(
                    scale: _pulseAnimation, 
                    child: Icon(Icons.redeem_rounded, color: theme.colorScheme.primary, size: 30)
                 );
              } else {
                 leadingIcon = Icon(Icons.lock_rounded, color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.3), size: 28);
              }

              return Container(
                margin: EdgeInsets.only(bottom: 1.5.h),
                padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.5.h),
                decoration: BoxDecoration(
                  color: isToday 
                      ? theme.colorScheme.primary.withValues(alpha: 0.1) 
                      : (isJackpot ? Colors.amber.withValues(alpha: 0.1) : theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.3)),
                  borderRadius: BorderRadius.circular(16),
                  border: isToday ? Border.all(color: theme.colorScheme.primary.withValues(alpha: 0.5), width: 2) 
                      : (isJackpot ? Border.all(color: Colors.amber, width: 1.5) : null),
                ),
                child: Row(
                  children: [
                    leadingIcon,
                    SizedBox(width: 4.w),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Day $day ${isJackpot ? "👑 JACKPOT" : ""}',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: AppTypography.bodySmall,
                              color: isCompleted ? Colors.green.shade700 : (isToday ? theme.colorScheme.primary : theme.colorScheme.onSurface),
                            ),
                          ),
                          Text(
                            tier['label'],
                            style: TextStyle(
                              fontSize: AppTypography.bodySmall,
                              color: isCompleted ? theme.colorScheme.onSurfaceVariant : (isToday ? theme.colorScheme.onSurface : theme.colorScheme.onSurfaceVariant),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            }),

            SizedBox(height: 3.h),

            // Action Button
            ElevatedButton(
              onPressed: _status.isClaimedToday ? null : _claimReward,
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(vertical: 2.h),
                backgroundColor: theme.colorScheme.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                disabledBackgroundColor: theme.colorScheme.surfaceContainerHighest,
              ),
              child: _isClaiming
                  ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                  : Text(
                      _status.isClaimedToday ? 'Come back tomorrow!' : 'Claim ${ _rewardTiers[_status.streakCount > 7 ? 6 : _status.streakCount - 1]['label'] }',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: AppTypography.bodyMedium, color: _status.isClaimedToday ? theme.colorScheme.onSurfaceVariant : Colors.white),
                    ),
            ),
          ],
        ),
      ),
    ),
    if (_showLottie)
      Positioned.fill(
        child: IgnorePointer(
          child: Lottie.network(
            'https://assets2.lottiefiles.com/packages/lf20_u4yrau.json',
            repeat: false,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) => const SizedBox.shrink(),
          ),
        ),
      ),
    ],
  );
 }
}
