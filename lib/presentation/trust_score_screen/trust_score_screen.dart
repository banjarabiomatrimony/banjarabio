import 'package:flutter/foundation.dart';
import 'package:banjarabio/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sizer/sizer.dart';
import 'package:share_plus/share_plus.dart';

import 'package:banjarabio/core/app_export.dart';
import 'package:banjarabio/core/models/profile_model.dart';
import 'package:banjarabio/core/providers/profile_providers.dart';
import 'package:banjarabio/core/repositories/profile_repository.dart';
import 'package:banjarabio/features/trust_score/providers/trust_score_providers.dart';
import 'package:banjarabio/features/trust_score/repository/trust_score_repository.dart';
import 'package:banjarabio/routes/app_routes.dart';
import 'package:banjarabio/widgets/custom_app_bar.dart';
import 'package:banjarabio/widgets/skeleton_loaders.dart';
import 'package:banjarabio/presentation/trust_score_screen/widgets/trust_score_share_card.dart';
import 'package:banjarabio/core/services/app_logger.dart';
import 'package:banjarabio/core/constants/app_typography.dart';

/// Riverpod-based Trust Score screen.
class TrustScoreScreen extends ConsumerStatefulWidget {
  const TrustScoreScreen({super.key});

  @override
  ConsumerState<TrustScoreScreen> createState() =>
      _TrustScoreScreenState();
}

class _TrustScoreScreenState
    extends ConsumerState<TrustScoreScreen> {
  late final TrustScoreRepository _trustScoreRepository;
  late final ProfileRepository _profileRepository;
  bool _isLoading = true;
  int _currentScore = 0;
  Map<String, String> _verificationStatus = {};
  ProfileModel? _profile;

  @override
  void initState() {
    super.initState();
    _trustScoreRepository = ref.read(trustScoreRepositoryProvider);
    _profileRepository = ref.read(profileRepositoryProvider);
    _loadTrustScore();
  }

  Future<void> _loadTrustScore() async {
    if (kDebugMode) {
      AppLogger.debug('TrustScoreScreen', '[TRUST_SCORE] TrustScoreScreen > _loadTrustScore > Loading');
    }
    setState(() => _isLoading = true);

    try {
      final scoreRes = await _trustScoreRepository.calculateTrustScore();
      final statusRes = await _trustScoreRepository.getVerificationStatus();
      final profileRes = await _profileRepository.getOwnProfile();

      if (mounted) {
        if (scoreRes.isSuccess && statusRes.isSuccess && profileRes.isSuccess) {
          setState(() {
            _currentScore = scoreRes.data;
            _verificationStatus = statusRes.data;
            _profile = profileRes.data;
            _isLoading = false;
          });
          if (kDebugMode) {
            debugPrint(
              '[TRUST_SCORE] TrustScoreScreen > _loadTrustScore > SUCCESS | score=$_currentScore',
            );
          }
        } else {
          if (kDebugMode) {
            debugPrint(
              '[TRUST_SCORE] TrustScoreScreen > _loadTrustScore > FAILED | '
              'score=${scoreRes.isSuccess}, status=${statusRes.isSuccess}, profile=${profileRes.isSuccess}',
            );
          }
          setState(() => _isLoading = false);
        }
      }
    } catch (e) {
      if (kDebugMode) {
        AppLogger.error('TrustScoreScreen', '[TRUST_SCORE] TrustScoreScreen > _loadTrustScore > Error: $e');
      }
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppLocalizations.of(context)?.failedToLoadTrustScoreStats ?? 'Failed to load trust score stats')),
        );
      }
    }
  }

  Future<void> _handleVerifyItem(String itemKey) async {
    String route = '';

    switch (itemKey) {
      case 'mobile':
        route = AppRoutes.mobileVerification;
        break;
      case 'email':
        route = AppRoutes.emailVerification;
        break;
      case 'photo':
        route = AppRoutes.liveSelfie;
        break;
      case 'communityId':
        route = AppRoutes.communityIdVerification;
        break;
      case 'govtId':
        route = AppRoutes.govtIdVerification;
        break;
      case 'reference':
        route = AppRoutes.referenceVerification;
        break;
      case 'videoBio':
        route = AppRoutes.videoIntro;
        break;
    }

    if (route.isNotEmpty) {
      if (kDebugMode) {
        AppLogger.debug('TrustScoreScreen', '[TRUST_SCORE] TrustScoreScreen > _handleVerifyItem > $itemKey');
      }
      await Navigator.pushNamed(context, route);
      _loadTrustScore();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: CustomAppBar(
        title: AppLocalizations.of(context)?.trustScoreDiscounts ?? 'Trust Score & Discounts',
        actions: [
          IconButton(
            onPressed: _showShareCard,
            icon: const Icon(Icons.share_rounded),
          ),
        ],
      ),
      body: _isLoading
          ? const TrustScoreSkeleton()
          : SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 3.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildScoreCard(theme),
                  SizedBox(height: 2.h),
                  Text(AppLocalizations.of(context)?.increaseYourTrustScoreToConfirmYourIdent ?? 'Increase your Trust Score to confirm your identity and unlock exclusive discounts.',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  SizedBox(height: 2.h),
                  _buildVerificationList(theme),
                ],
              ),
            ),
    );
  }

  void _showShareCard() {
    if (kDebugMode) {
      debugPrint(
        '[TRUST_SCORE] TrustScoreScreen > _showShareCard > Opening share sheet',
      );
    }
    HapticFeedback.lightImpact();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: EdgeInsets.all(20.sp),
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24.sp)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40.sp,
              height: 4.sp,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2.sp),
              ),
            ),
            SizedBox(height: 20.sp),
            TrustScoreShareCard(
              score: _currentScore,
              userName: _profile?.fullName ?? 'User',
            ),
            SizedBox(height: 30.sp),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.pop(context);
                  Share.share(
                    "I just verified my profile on BanjaraBio with a Trust Score of $_currentScore! Check out my profile and join our community: https://play.google.com/store/apps/details?id=com.avishio.banjarabio&referrer=profile/${_profile?.id ?? ""}",
                  );
                },
                icon: const Icon(Icons.share_rounded, color: Colors.white),
                label: Text(AppLocalizations.of(context)?.shareToSocialMedia ?? 'Share to Social Media'),
              ),
            ),
            SizedBox(height: 20.sp),
          ],
        ),
      ),
    );
  }

  Widget _buildScoreCard(ThemeData theme) {
    Color scoreColor;
    String tierName;
    String tierEmoji;
    int nextMilestoneScore;
    String nextTierName;

    if (_currentScore >= 90) {
      scoreColor = const Color(0xFF6A1B9A); // Deep purple
      tierName = 'Platinum Verified';
      tierEmoji = '🛡️';
      nextMilestoneScore = 100;
      nextTierName = 'Max Trust';
    } else if (_currentScore >= 70) {
      scoreColor = const Color(0xFF2E7D32); // Green
      tierName = 'Gold Trusted';
      tierEmoji = '🥇';
      nextMilestoneScore = 90;
      nextTierName = 'Platinum';
    } else if (_currentScore >= 40) {
      scoreColor = const Color(0xFFE65100); // Orange
      tierName = 'Silver Profile';
      tierEmoji = '🥈';
      nextMilestoneScore = 70;
      nextTierName = 'Gold';
    } else {
      scoreColor = const Color(0xFFC62828); // Red
      tierName = 'Bronze Profile';
      tierEmoji = '🥉';
      nextMilestoneScore = 40;
      nextTierName = 'Silver';
    }

    final pointsNeeded = nextMilestoneScore - _currentScore;

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 3.w),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: theme.shadowColor.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            AppLocalizations.of(context)?.yourTrustScore ?? 'Your Trust Score',
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 1.5.h),
          TweenAnimationBuilder<double>(
            tween: Tween<double>(begin: 0, end: _currentScore / 100),
            duration: const Duration(milliseconds: 1200),
            curve: Curves.easeOutCubic,
            builder: (context, value, child) {
              final animatedScore = (value * 100).round();
              return Stack(
                alignment: Alignment.center,
                children: [
                  SizedBox(
                    width: 26.w,
                    height: 26.w,
                    child: CircularProgressIndicator(
                      value: value,
                      strokeWidth: 10,
                      backgroundColor: theme.colorScheme.surfaceContainerHighest,
                      valueColor: AlwaysStoppedAnimation<Color>(scoreColor),
                    ),
                  ),
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        '$animatedScore',
                        style: theme.textTheme.displayMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: scoreColor,
                        ),
                      ),
                      Text(
                        AppLocalizations.of(context)?.num100 ?? '/ 100',
                        style: theme.textTheme.bodySmall,
                      ),
                    ],
                  ),
                ],
              );
            },
          ),
          SizedBox(height: 1.5.h),
          // Tier badge
          Container(
            padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 0.8.h),
            decoration: BoxDecoration(
              color: scoreColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: scoreColor.withValues(alpha: 0.3)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(tierEmoji, style: const TextStyle(fontSize: 16)),
                SizedBox(width: 2.w),
                Text(
                  tierName,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: scoreColor,
                  ),
                ),
              ],
            ),
          ),
          // Nudge bar to next milestone
          if (pointsNeeded > 0 && _currentScore < 100) ...[
            SizedBox(height: 1.5.h),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.h),
              decoration: BoxDecoration(
                color: theme.colorScheme.primary.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                children: [
                  const Text('💡', style: TextStyle(fontSize: 14)),
                  SizedBox(width: 2.w),
                  Expanded(
                    child: Text(
                      'Complete $pointsNeeded more points of verification to reach $nextTierName Tier!',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.primary,
                        fontWeight: FontWeight.w700,
                        fontSize: AppTypography.labelMedium,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildVerificationList(ThemeData theme) {
    return Column(
      children: [
        _buildVerificationItem(
          theme,
          title: AppLocalizations.of(context)?.mobileNumber ?? 'Mobile Number',
          points: 10,
          itemKey: 'mobile',
          iconName: 'phone_android',
          color: Colors.blue,
        ),
        _buildVerificationItem(
          theme,
          title: AppLocalizations.of(context)?.emailAddress ?? 'Email Address',
          points: 10,
          itemKey: 'email',
          iconName: 'email',
          color: Colors.orange,
        ),
        _buildVerificationItem(
          theme,
          title: AppLocalizations.of(context)?.liveSelfie ?? 'Live Selfie',
          points: 10,
          itemKey: 'photo',
          iconName: 'face',
          color: Colors.pink,
        ),
        _buildVerificationItem(
          theme,
          title: AppLocalizations.of(context)?.governmentId ?? 'Government ID',
          points: 15,
          itemKey: 'govtId',
          iconName: 'badge',
          color: Colors.purple,
        ),
        _buildVerificationItem(
          theme,
          title: AppLocalizations.of(context)?.bvsMembershipCard ?? 'BVS Membership Card',
          points: 15,
          itemKey: 'communityId',
          iconName: 'badge',
          color: const Color(0xFF8B1A2E),
        ),
        _buildVerificationItem(
          theme,
          title: AppLocalizations.of(context)?.references ?? 'References',
          points: 10,
          itemKey: 'reference',
          iconName: 'group_add',
          color: Colors.indigo,
        ),
        _buildVerificationItem(
          theme,
          title: 'Video Bio / Intro',
          points: 10,
          itemKey: 'videoBio',
          iconName: 'videocam',
          color: Colors.red,
        ),
        _buildVerificationItem(
          theme,
          title: AppLocalizations.of(context)?.profileCompleted ?? 'Profile Completed',
          points: 20,
          itemKey: 'profileCompletion',
          iconName: 'assignment_turned_in',
          color: Colors.green,
        ),
      ],
    );
  }

  Widget _buildVerificationItem(
    ThemeData theme, {
    required String title,
    required int points,
    required String itemKey,
    required String iconName,
    required Color color,
  }) {
    final status =
        _verificationStatus[itemKey] ?? TrustScoreRepository.statusNotStarted;

    IconData statusIcon;
    Color statusColor;
    String statusText;
    VoidCallback? onTap;

    switch (status) {
      case TrustScoreRepository.statusVerified:
        statusIcon = Icons.check_circle;
        statusColor = Colors.green;
        statusText = 'Verified';
        onTap = () => _handleVerifyItem(itemKey);
        break;
      case TrustScoreRepository.statusPendingReview:
        statusIcon = Icons.schedule;
        statusColor = Colors.orange;
        statusText = 'Pending';
        onTap = () => _handleVerifyItem(itemKey);
        break;
      case TrustScoreRepository.statusRejected:
        statusIcon = Icons.cancel;
        statusColor = Colors.red;
        statusText = 'Rejected';
        onTap = () => _handleVerifyItem(itemKey);
        break;
      default:
        statusIcon = Icons.arrow_forward_ios;
        statusColor = Colors.grey;
        statusText = itemKey == 'profileCompletion' ? 'Update' : 'Start';
        onTap = itemKey == 'profileCompletion'
            ? () => Navigator.pushNamed(
                  context,
                  AppRoutes.biodataCreation,
                  arguments: {'profile': _profile, 'isEditMode': true},
                )
            : () => _handleVerifyItem(itemKey);
        break;
    }

    if (itemKey == 'profileCompletion' &&
        status == TrustScoreRepository.statusVerified) {
      onTap = () => Navigator.pushNamed(
            context,
            AppRoutes.biodataCreation,
            arguments: {'profile': _profile, 'isEditMode': true},
          );
    }

    return Card(
      margin: EdgeInsets.only(bottom: 0.8.h),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 2,
      child: ListTile(
        contentPadding: EdgeInsets.symmetric(horizontal: 3.w),
        leading: Container(
          padding: EdgeInsets.all(1.5.w),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(_getIconData(iconName), color: color, size: 20),
        ),
        title: Text(
          title,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Text(
          '+$points Points',
          style: theme.textTheme.bodySmall?.copyWith(
            color: Colors.green,
            fontWeight: FontWeight.w600,
          ),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (itemKey == 'profileCompletion' && _profile != null) ...[
              Text(
                '${_profile!.calculateCompletionPercentage()}%',
                style: TextStyle(
                  color: _profile!.calculateCompletionPercentage() >= 100
                      ? Colors.green
                      : Colors.orange,
                  fontWeight: FontWeight.bold,
                  fontSize: AppTypography.bodySmall,
                ),
              ),
              SizedBox(width: 2.w),
              if (_profile!.calculateCompletionPercentage() >= 100)
                const Icon(Icons.check_circle, color: Colors.green, size: 20)
              else
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: theme.primaryColor,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(AppLocalizations.of(context)?.update ?? 'Update',
                    style: TextStyle(color: Colors.white, fontSize: AppTypography.bodySmall),
                  ),
                ),
            ] else if (status == TrustScoreRepository.statusVerified) ...[
              Text(
                statusText,
                style: TextStyle(
                  color: statusColor,
                  fontWeight: FontWeight.bold,
                  fontSize: AppTypography.bodySmall,
                ),
              ),
              SizedBox(width: 1.w),
              Icon(statusIcon, color: statusColor, size: 20),
              SizedBox(width: 2.w),
              const Icon(Icons.edit, color: Colors.grey, size: 16),
            ] else ...[
              if (status == TrustScoreRepository.statusPendingReview)
                Text(
                  statusText,
                  style: TextStyle(color: statusColor, fontSize: AppTypography.bodySmall),
                ),
              if (statusText == 'Start' || statusText == 'Rejected')
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: theme.primaryColor,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    statusText == 'Rejected'
                        ? 'Retry'
                        : (itemKey == 'profileCompletion' ? 'Go' : 'Verify'),
                    style: TextStyle(color: Colors.white, fontSize: AppTypography.bodySmall),
                  ),
                ),
            ],
          ],
        ),
        onTap: onTap,
      ),
    );
  }

  IconData _getIconData(String name) {
    switch (name) {
      case 'phone_android':
        return Icons.phone_android;
      case 'email':
        return Icons.email;
      case 'face':
        return Icons.face;
      case 'badge':
        return Icons.badge;
      case 'diversity_3':
        return Icons.diversity_3;
      case 'group_add':
        return Icons.group_add;
      case 'videocam':
        return Icons.videocam;
      case 'assignment_turned_in':
        return Icons.assignment_turned_in;
      default:
        return Icons.verified;
    }
  }
}
