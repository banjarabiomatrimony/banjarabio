import 'package:flutter/foundation.dart';
import 'package:banjarabio/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sizer/sizer.dart';
import 'package:share_plus/share_plus.dart';

import 'package:banjarabio/core/app_export.dart';
import 'package:banjarabio/core/models/profile_model.dart';
import 'package:banjarabio/core/models/trust_score_config.dart';
import 'package:banjarabio/core/providers/profile_providers.dart';
import 'package:banjarabio/core/repositories/profile_repository.dart';
import 'package:banjarabio/features/trust_score/providers/trust_score_providers.dart';
import 'package:banjarabio/features/trust_score/repository/trust_score_repository.dart';
import 'package:banjarabio/widgets/custom_app_bar.dart';
import 'package:banjarabio/widgets/tactile/tactile_back_button.dart';
import 'package:banjarabio/widgets/tactile/tactile_pressable.dart';
import 'package:banjarabio/widgets/branded_refresh_indicator.dart';
import 'package:banjarabio/widgets/skeleton_loaders.dart';
import 'package:banjarabio/presentation/trust_score_screen/widgets/trust_score_share_card.dart';
import 'package:banjarabio/core/services/app_logger.dart';

/// Riverpod-based Trust Score screen with rich animations and discount perks.
class TrustScoreScreen extends ConsumerStatefulWidget {
  const TrustScoreScreen({super.key});

  @override
  ConsumerState<TrustScoreScreen> createState() => _TrustScoreScreenState();
}

class _TrustScoreScreenState extends ConsumerState<TrustScoreScreen>
    with SingleTickerProviderStateMixin {
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
      AppLogger.debug(
        'TrustScoreScreen',
        '[TRUST_SCORE] TrustScoreScreen > _loadTrustScore > Loading',
      );
    }
    setState(() => _isLoading = true);

    try {
      final scoreRes = await _trustScoreRepository.calculateTrustScore();
      final statusRes = await _trustScoreRepository.getVerificationStatus();
      final profileRes = await _profileRepository.getOwnProfile(forceRefresh: true);

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
        AppLogger.error(
          'TrustScoreScreen',
          '[TRUST_SCORE] TrustScoreScreen > _loadTrustScore > Error: $e',
        );
      }
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              AppLocalizations.of(context)?.failedToLoadTrustScoreStats ??
                  'Failed to load trust score stats',
            ),
          ),
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
        AppLogger.debug(
          'TrustScoreScreen',
          '[TRUST_SCORE] TrustScoreScreen > _handleVerifyItem > $itemKey',
        );
      }
      HapticFeedback.lightImpact();
      await Navigator.pushNamed(context, route);
      _loadTrustScore();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: CustomAppBar(
        leading: const TactileBackButton(),
        title: l10n?.trustScoreDiscounts ?? 'Trust Score & Discounts',
        actions: [
          TactilePressable(
            onTap: _showShareCard,
            pressedScale: 0.92,
            child: Container(
              margin: EdgeInsets.only(right: 3.w),
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: theme.colorScheme.primary.withValues(alpha: AppColors.opacity10),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.share_rounded,
                size: 20,
                color: theme.colorScheme.primary,
              ),
            ),
          ),
        ],
      ),
      body: _isLoading
          ? const TrustScoreSkeleton()
          : BrandedRefreshIndicator(
              onRefresh: _loadTrustScore,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(
                  parent: BouncingScrollPhysics(),
                ),
                padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _buildScoreCard(theme),
                    SizedBox(height: 2.h),
                    _buildDiscountCard(theme),
                    SizedBox(height: 2.5.h),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Verifications Checklist',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: AppTypography.extraBold,
                            fontSize: AppTypography.headingSmall,
                          ),
                        ),
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 2.5.w,
                            vertical: 0.4.h,
                          ),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.primary.withValues(alpha: AppColors.opacity10),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            'Max 100 Pts',
                            style: TextStyle(
                              fontSize: AppTypography.labelSmall,
                              fontWeight: AppTypography.bold,
                              color: theme.colorScheme.primary,
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 1.2.h),
                    _buildVerificationList(theme),
                    SizedBox(height: 3.h),
                  ],
                ),
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
              child: TactilePressable(
                onTap: () {
                  Navigator.pop(context);
                  Share.share(
                    "I just verified my profile on BanjaraBio with a Trust Score of $_currentScore! Check out my profile and join our community: https://play.google.com/store/apps/details?id=com.avishio.banjarabio&referrer=profile/${_profile?.id ?? ""}",
                  );
                },
                pressedScale: 0.96,
                child: Container(
                  padding: EdgeInsets.symmetric(vertical: 1.5.h),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [AppColors.crimsonDeep, AppColors.maroonAccent],
                    ),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.crimsonDeep.withValues(alpha: AppColors.opacity35),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.share_rounded, color: Colors.white, size: 20),
                      SizedBox(width: 2.w),
                      Text(
                        AppLocalizations.of(context)?.shareToSocialMedia ??
                            'Share to Social Media',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: AppTypography.bold,
                          fontSize: AppTypography.bodyLarge,
                        ),
                      ),
                    ],
                  ),
                ),
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
      scoreColor = AppColors.materialPurpleDark; // Deep purple Platinum
      tierName = 'Platinum Verified';
      tierEmoji = '🛡️';
      nextMilestoneScore = 100;
      nextTierName = 'Max Trust';
    } else if (_currentScore >= 70) {
      scoreColor = AppColors.categoryLocation; // Emerald Gold
      tierName = 'Gold Trusted';
      tierEmoji = '🥇';
      nextMilestoneScore = 90;
      nextTierName = 'Platinum';
    } else if (_currentScore >= 40) {
      scoreColor = AppColors.categoryAstro; // Amber Silver
      tierName = 'Silver Profile';
      tierEmoji = '🥈';
      nextMilestoneScore = 70;
      nextTierName = 'Gold';
    } else {
      scoreColor = AppColors.trustLow; // Crimson Bronze
      tierName = 'Bronze Profile';
      tierEmoji = '🥉';
      nextMilestoneScore = 40;
      nextTierName = 'Silver';
    }

    final pointsNeeded = nextMilestoneScore - _currentScore;

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 5.w, vertical: 2.5.h),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: scoreColor.withValues(alpha: AppColors.opacity25),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: scoreColor.withValues(alpha: AppColors.opacity8),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                AppLocalizations.of(context)?.yourTrustScore ?? 'Your Trust Score',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: AppTypography.black,
                  fontSize: AppTypography.headingSmall,
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 0.6.h),
                decoration: BoxDecoration(
                  color: scoreColor.withValues(alpha: AppColors.opacity12),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: scoreColor.withValues(alpha: AppColors.opacity30)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(tierEmoji, style: TextStyle(fontSize: AppTypography.bodyLarge)),
                    SizedBox(width: 1.5.w),
                    Text(
                      tierName,
                      style: TextStyle(
                        fontWeight: AppTypography.extraBold,
                        color: scoreColor,
                        fontSize: AppTypography.bodySmall,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 2.5.h),
          TweenAnimationBuilder<double>(
            tween: Tween<double>(begin: 0, end: _currentScore / 100),
            duration: const Duration(milliseconds: 1400),
            curve: Curves.easeOutCubic,
            builder: (context, value, child) {
              final animatedScore = (value * 100).round();
              return Stack(
                alignment: Alignment.center,
                children: [
                  Container(
                    width: 32.w,
                    height: 32.w,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: scoreColor.withValues(alpha: 0.15 * value),
                          blurRadius: 25,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                  ),
                  SizedBox(
                    width: 30.w,
                    height: 30.w,
                    child: CircularProgressIndicator(
                      value: value,
                      strokeWidth: 12,
                      strokeCap: StrokeCap.round,
                      backgroundColor: theme.colorScheme.surfaceContainerHighest,
                      valueColor: AlwaysStoppedAnimation<Color>(scoreColor),
                    ),
                  ),
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        '$animatedScore',
                        style: TextStyle(
                          fontSize: AppTypography.displayLarge,
                          fontWeight: AppTypography.black,
                          color: scoreColor,
                          height: 1.0,
                        ),
                      ),
                      SizedBox(height: 0.4.h),
                      Text(
                        AppLocalizations.of(context)?.num100 ?? '/ 100',
                        style: TextStyle(
                          fontSize: AppTypography.labelMedium,
                          fontWeight: AppTypography.semiBold,
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ],
              );
            },
          ),
          SizedBox(height: 2.h),
          // Nudge bar to next milestone
          if (pointsNeeded > 0 && _currentScore < 100) ...[
            Container(
              padding: EdgeInsets.symmetric(horizontal: 3.5.w, vertical: 1.2.h),
              decoration: BoxDecoration(
                color: scoreColor.withValues(alpha: AppColors.opacity8),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: scoreColor.withValues(alpha: AppColors.opacity20)),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: scoreColor.withValues(alpha: AppColors.opacity15),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(Icons.trending_up_rounded, color: scoreColor, size: 18),
                  ),
                  SizedBox(width: 2.5.w),
                  Expanded(
                    child: Text(
                      'Earn $pointsNeeded more points to reach $nextTierName Tier & unlock bigger discounts!',
                      style: TextStyle(
                        color: scoreColor,
                        fontWeight: AppTypography.bold,
                        fontSize: AppTypography.bodySmall,
                        height: 1.3,
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

  Widget _buildDiscountCard(ThemeData theme) {
    final discount = TrustScoreConfig.getDiscountPercentage(_currentScore);

    return Container(
      padding: EdgeInsets.all(4.5.w),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.blue800.withValues(alpha: 0.95),
            AppColors.categoryCareer.withValues(alpha: AppColors.opacity90),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.blue800.withValues(alpha: AppColors.opacity25),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: AppColors.opacity20),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.local_offer_rounded,
                  color: Colors.white,
                  size: 18,
                ),
              ),
              SizedBox(width: 2.w),
              Expanded(
                child: Text(
                  'Discounts & Perks',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: AppTypography.extraBold,
                    fontSize: AppTypography.headingSmall,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              SizedBox(width: 2.w),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 2.5.w, vertical: 0.5.h),
                decoration: BoxDecoration(
                  color: Colors.amber,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  discount > 0 ? '$discount% OFF' : 'UP TO 30% OFF',
                  style: TextStyle(
                    color: Colors.black,
                    fontWeight: AppTypography.black,
                    fontSize: AppTypography.labelMedium,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 1.5.h),
          Text(
            discount > 0
                ? '🎉 Congratulations! You have unlocked a $discount% discount applied automatically at checkout on all premium matrimonial plans.'
                : 'Complete more profile verification steps to unlock up to 30% instant discount on all matrimonial plans!',
            style: TextStyle(
              color: Colors.white.withValues(alpha: AppColors.opacity90),
              fontSize: AppTypography.bodySmall,
              height: 1.4,
            ),
          ),
          SizedBox(height: 1.5.h),
          Wrap(
            spacing: 2.w,
            runSpacing: 0.8.h,
            children: [
              _buildPerkChip('🛡️ Verified Badge'),
              _buildPerkChip('🚀 3x Views'),
              _buildPerkChip('⚡ Priority Rank'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPerkChip(String label) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 2.5.w, vertical: 0.4.h),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: AppColors.opacity15),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: Colors.white,
          fontWeight: AppTypography.semiBold,
          fontSize: AppTypography.labelSmall,
        ),
      ),
    );
  }

  Widget _buildVerificationList(ThemeData theme) {
    final items = [
      {
        'title': AppLocalizations.of(context)?.mobileNumber ?? 'Mobile Number',
        'points': 10,
        'itemKey': 'mobile',
        'icon': Icons.phone_android_rounded,
        'color': AppColors.categoryCareer,
      },
      {
        'title': AppLocalizations.of(context)?.emailAddress ?? 'Email Address',
        'points': 10,
        'itemKey': 'email',
        'icon': Icons.email_rounded,
        'color': AppColors.warning,
      },
      {
        'title': AppLocalizations.of(context)?.liveSelfie ?? 'Live Selfie',
        'points': 10,
        'itemKey': 'photo',
        'icon': Icons.face_retouching_natural_rounded,
        'color': AppColors.categoryPersonal,
      },
      {
        'title': AppLocalizations.of(context)?.governmentId ?? 'Government ID',
        'points': 15,
        'itemKey': 'govtId',
        'icon': Icons.badge_rounded,
        'color': AppColors.categoryFamily,
      },
      {
        'title': AppLocalizations.of(context)?.bvsMembershipCard ?? 'BVS Membership Card',
        'points': 15,
        'itemKey': 'communityId',
        'icon': Icons.verified_user_rounded,
        'color': AppColors.crimsonDeep,
      },
      {
        'title': AppLocalizations.of(context)?.references ?? 'Family References',
        'points': 10,
        'itemKey': 'reference',
        'icon': Icons.group_add_rounded,
        'color': AppColors.categorySecurity,
      },
      {
        'title': 'Video Bio / Intro',
        'points': 10,
        'itemKey': 'videoBio',
        'icon': Icons.videocam_rounded,
        'color': AppColors.trustLow,
      },
      {
        'title': AppLocalizations.of(context)?.profileCompleted ?? 'Profile Completed',
        'points': 20,
        'itemKey': 'profileCompletion',
        'icon': Icons.assignment_turned_in_rounded,
        'color': AppColors.categoryLocation,
      },
    ];

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        return TweenAnimationBuilder<double>(
          tween: Tween<double>(begin: 0.0, end: 1.0),
          duration: Duration(milliseconds: 350 + (index * 50)),
          curve: Curves.easeOutCubic,
          builder: (context, value, child) {
            return Transform.translate(
              offset: Offset(0, 16 * (1 - value)),
              child: Opacity(
                opacity: value.clamp(0.0, 1.0),
                child: child,
              ),
            );
          },
          child: _buildVerificationItem(
            theme,
            title: item['title'] as String,
            points: item['points'] as int,
            itemKey: item['itemKey'] as String,
            icon: item['icon'] as IconData,
            color: item['color'] as Color,
          ),
        );
      },
    );
  }

  Widget _buildVerificationItem(
    ThemeData theme, {
    required String title,
    required int points,
    required String itemKey,
    required IconData icon,
    required Color color,
  }) {
    final status =
        _verificationStatus[itemKey] ?? TrustScoreRepository.statusNotStarted;

    String statusText;
    VoidCallback? onTap;

    switch (status) {
      case TrustScoreRepository.statusVerified:
        statusText = 'Verified';
        onTap = () => _handleVerifyItem(itemKey);
        break;
      case TrustScoreRepository.statusPendingReview:
        statusText = 'Under Review';
        onTap = () => _handleVerifyItem(itemKey);
        break;
      case TrustScoreRepository.statusRejected:
        statusText = 'Rejected';
        onTap = () => _handleVerifyItem(itemKey);
        break;
      default:
        statusText = itemKey == 'profileCompletion' ? 'Update' : 'Verify';
        onTap = itemKey == 'profileCompletion'
            ? () => Navigator.pushNamed(
                  context,
                  AppRoutes.biodataCreation,
                  arguments: {'profile': _profile, 'isEditMode': true},
                ).then((_) => _loadTrustScore())
            : () => _handleVerifyItem(itemKey);
        break;
    }

    if (itemKey == 'profileCompletion' &&
        status == TrustScoreRepository.statusVerified) {
      onTap = () => Navigator.pushNamed(
            context,
            AppRoutes.biodataCreation,
            arguments: {'profile': _profile, 'isEditMode': true},
          ).then((_) => _loadTrustScore());
    }

    return TactilePressable(
      onTap: onTap,
      pressedScale: 0.97,
      child: Container(
        margin: EdgeInsets.only(bottom: 1.2.h),
        decoration: BoxDecoration(
          color: theme.cardColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: status == TrustScoreRepository.statusVerified
                ? AppColors.categoryLocation.withValues(alpha: AppColors.opacity25)
                : theme.colorScheme.outline.withValues(alpha: AppColors.opacity8),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.4.h),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: AppColors.opacity12),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: color, size: 22),
              ),
              SizedBox(width: 3.5.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontWeight: AppTypography.bold,
                        fontSize: AppTypography.bodyMedium,
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                    SizedBox(height: 0.3.h),
                    Row(
                      children: [
                        Text(
                          '+$points Points',
                          style: TextStyle(
                            color: AppColors.categoryLocation,
                            fontWeight: AppTypography.bold,
                            fontSize: AppTypography.bodySmall,
                          ),
                        ),
                        if (itemKey == 'profileCompletion' && _profile != null) ...[
                          SizedBox(width: 2.w),
                          Flexible(
                            child: Text(
                              '• ${_profile!.calculateCompletionPercentage()}% Complete',
                              style: TextStyle(
                                color: theme.colorScheme.onSurfaceVariant,
                                fontWeight: AppTypography.semiBold,
                                fontSize: AppTypography.bodySmall,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
              SizedBox(width: 2.w),
              if (status == TrustScoreRepository.statusVerified)
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 0.6.h),
                  decoration: BoxDecoration(
                    color: AppColors.categoryLocation.withValues(alpha: AppColors.opacity12),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: AppColors.categoryLocation.withValues(alpha: AppColors.opacity30),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.check_circle_rounded,
                        color: AppColors.categoryLocation,
                        size: 16,
                      ),
                      SizedBox(width: 1.5.w),
                      Text(
                        'Verified',
                        style: TextStyle(
                          color: AppColors.categoryLocation,
                          fontWeight: AppTypography.extraBold,
                          fontSize: AppTypography.bodySmall,
                        ),
                      ),
                    ],
                  ),
                )
              else if (status == TrustScoreRepository.statusPendingReview)
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 0.6.h),
                  decoration: BoxDecoration(
                    color: AppColors.categoryAstro.withValues(alpha: AppColors.opacity12),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: AppColors.categoryAstro.withValues(alpha: AppColors.opacity30),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.hourglass_top_rounded,
                        color: AppColors.categoryAstro,
                        size: 15,
                      ),
                      SizedBox(width: 1.5.w),
                      Text(
                        'In Review',
                        style: TextStyle(
                          color: AppColors.categoryAstro,
                          fontWeight: AppTypography.extraBold,
                          fontSize: AppTypography.bodySmall,
                        ),
                      ),
                    ],
                  ),
                )
              else if (status == TrustScoreRepository.statusRejected)
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 0.6.h),
                  decoration: BoxDecoration(
                    color: AppColors.trustLow.withValues(alpha: AppColors.opacity12),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: AppColors.trustLow.withValues(alpha: AppColors.opacity30),
                    ),
                  ),
                  child: Text(
                    'Retry',
                    style: TextStyle(
                      color: AppColors.trustLow,
                      fontWeight: AppTypography.extraBold,
                      fontSize: AppTypography.bodySmall,
                    ),
                  ),
                )
              else
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 3.5.w, vertical: 0.7.h),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    statusText,
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: AppTypography.extraBold,
                      fontSize: AppTypography.bodySmall,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
