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

/// Riverpod-based Trust Score screen.
/// Parallel to [TrustScoreScreen]; use until migration 100% validated.
class TrustScoreScreenRiverpod extends ConsumerStatefulWidget {
  const TrustScoreScreenRiverpod({super.key});

  @override
  ConsumerState<TrustScoreScreenRiverpod> createState() =>
      _TrustScoreScreenRiverpodState();
}

class _TrustScoreScreenRiverpodState
    extends ConsumerState<TrustScoreScreenRiverpod> {
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
      debugPrint('[TRUST_SCORE] TrustScoreScreenRiverpod > _loadTrustScore > Loading');
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
              '[TRUST_SCORE] TrustScoreScreenRiverpod > _loadTrustScore > SUCCESS | score=$_currentScore',
            );
          }
        } else {
          if (kDebugMode) {
            debugPrint(
              '[TRUST_SCORE] TrustScoreScreenRiverpod > _loadTrustScore > FAILED | '
              'score=${scoreRes.isSuccess}, status=${statusRes.isSuccess}, profile=${profileRes.isSuccess}',
            );
          }
          setState(() => _isLoading = false);
        }
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('[TRUST_SCORE] TrustScoreScreenRiverpod > _loadTrustScore > Error: $e');
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
        debugPrint('[TRUST_SCORE] TrustScoreScreenRiverpod > _handleVerifyItem > $itemKey');
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
        '[TRUST_SCORE] TrustScoreScreenRiverpod > _showShareCard > Opening share sheet',
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
    if (_currentScore >= 80) {
      scoreColor = Colors.green;
    } else if (_currentScore >= 50) {
      scoreColor = Colors.orange;
    } else {
      scoreColor = Colors.red;
    }

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
          Text(AppLocalizations.of(context)?.yourTrustScore ?? 'Your Trust Score',
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 1.2.h),
          Stack(
            alignment: Alignment.center,
            children: [
              SizedBox(
                width: 22.w,
                height: 22.w,
                child: CircularProgressIndicator(
                  value: _currentScore / 100,
                  strokeWidth: 10,
                  backgroundColor: theme.colorScheme.surfaceContainerHighest,
                  valueColor: AlwaysStoppedAnimation<Color>(scoreColor),
                ),
              ),
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '$_currentScore',
                    style: theme.textTheme.displayMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: scoreColor,
                    ),
                  ),
                  Text(AppLocalizations.of(context)?.num100 ?? '/ 100', style: theme.textTheme.bodySmall),
                ],
              ),
            ],
          ),
          SizedBox(height: 1.h),
          _buildScoreLabel(theme, scoreColor),
        ],
      ),
    );
  }

  Widget _buildScoreLabel(ThemeData theme, Color color) {
    String label;
    IconData icon;
    if (_currentScore >= 80) {
      label = 'Verified Profile';
      icon = Icons.verified;
    } else if (_currentScore >= 50) {
      label = 'Trusted Profile';
      icon = Icons.thumb_up;
    } else {
      label = 'Standard Profile';
      icon = Icons.person_outline;
    }

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 0.6.h),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 20),
          SizedBox(width: 2.w),
          Text(
            label,
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
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
          title: AppLocalizations.of(context)?.communityVerification ?? 'Community Verification',
          points: 15,
          itemKey: 'communityId',
          iconName: 'diversity_3',
          color: Colors.teal,
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
                  fontSize: 10.sp,
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
                    style: TextStyle(color: Colors.white, fontSize: 10.sp),
                  ),
                ),
            ] else if (status == TrustScoreRepository.statusVerified) ...[
              Text(
                statusText,
                style: TextStyle(
                  color: statusColor,
                  fontWeight: FontWeight.bold,
                  fontSize: 10.sp,
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
                  style: TextStyle(color: statusColor, fontSize: 10.sp),
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
                    style: TextStyle(color: Colors.white, fontSize: 10.sp),
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
