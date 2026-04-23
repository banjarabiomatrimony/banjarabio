
import 'package:banjarabio/l10n/app_localizations.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:sizer/sizer.dart';

import 'package:banjarabio/core/app_export.dart';
import 'package:banjarabio/core/repositories/profile_repository.dart';
import 'package:banjarabio/core/models/profile_share_model.dart';
import 'package:banjarabio/core/repositories/share_repository.dart';
import 'package:banjarabio/core/repositories/usage_repository.dart';
import 'package:banjarabio/core/services/local_cache_service.dart';
import 'package:banjarabio/widgets/upgrade_dialog.dart';
import 'package:banjarabio/features/bookmarks/providers/bookmark_notifier.dart';
import 'package:banjarabio/presentation/profile_detail_screen/widgets/action_buttons_widget.dart';
import 'package:banjarabio/core/repositories/chat_repository.dart';
import 'package:banjarabio/presentation/profile_detail_screen/widgets/contact_preferences_card_widget.dart';
import 'package:banjarabio/presentation/profile_detail_screen/widgets/education_profession_card_widget.dart';
import 'package:banjarabio/presentation/profile_detail_screen/widgets/family_background_card_widget.dart';
import 'package:banjarabio/presentation/profile_detail_screen/widgets/location_details_card_widget.dart';
import 'package:banjarabio/presentation/profile_detail_screen/widgets/personal_details_card_widget.dart';
import 'package:banjarabio/presentation/profile_detail_screen/widgets/profile_header_widget.dart';
import 'package:banjarabio/widgets/shimmer_widget.dart';
import 'package:tutorial_coach_mark/tutorial_coach_mark.dart';
import 'package:banjarabio/core/services/guest_guided_tour_service.dart';
import 'package:banjarabio/core/utils/tour_keys.dart';
import 'package:banjarabio/presentation/home_screen/widgets/guest_restricted_dialog.dart';
// import '../../core/services/ad_reward_service.dart';
// import '../widgets/rewarded_ad_dialog.dart';

/// Profile Detail Screen displaying complete biodata information
/// Accessed via stack navigation from Home screen
/// Presents traditional matrimonial format optimized for mobile viewing
class ProfileDetailScreen extends ConsumerStatefulWidget {
  const ProfileDetailScreen({super.key});

  @override
  ConsumerState<ProfileDetailScreen> createState() =>
      _ProfileDetailScreenState();
}

class _ProfileDetailScreenState extends ConsumerState<ProfileDetailScreen> {
  final ScrollController _scrollController = ScrollController();
  final ShareRepository _shareRepository = ShareRepository();
  bool _isLoading = false;
  Map<String, dynamic>? _profileData;
  bool _showAppBarTitle = false;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);

    // Check and start profile detail tour for guests
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkAndStartProfileTour();
      _trackProfileView();
    });
  }

  Future<void> _trackProfileView() async {
    final profileId = _profileData?['id']?.toString();
    if (profileId == null) return;

    final usageRepo = UsageRepository();
    final canView = await usageRepo.canViewProfile();
    return await canView.fold(
      onSuccess: (canProceed) async {
        if (canProceed) {
          ChatRepository().trackView(profileId);
          await usageRepo.incrementProfileView();
        } else {
          // Limit reached - Ads currently disabled
          /*
          if (mounted) {
            showDialog(
              context: context,
              builder: (context) => RewardedAdDialog(
                rewardType: AdRewardType.profileViews,
                onRewardGranted: () async {
                  await usageRepo.grantAdReward(AdRewardType.profileViews);
                  if (mounted) {
                    Fluttertoast.showToast(msg: AppLocalizations.of(context)?.extraViewsUnlocked(5) ?? "5 Extra Views Unlocked!");
                  }
                },
              ),
            );
          }
          */
          if (mounted) {
            Fluttertoast.showToast(msg: 'Daily view limit reached.');
          }
        }
      },
      onFailure: (error) async => debugPrint('Error checking view limit: $error'),
    );
  }

  void _checkAndStartProfileTour() {
    final cache = LocalCacheService();
    if (cache.isGuestMode() &&
        !cache.isTourStageCompleted(TourStage.profileDetail.name)) {
      _startProfileTour();
    }
  }

  void _startProfileTour() {
    final tourService = ref.read(guestTourProvider);
    tourService.startTour(
      context,
      stage: TourStage.profileDetail,
      targets: [
        TargetFocus(
          identify: 'bookmark',
          keyTarget: TourKeys.bookmarkButtonKey,
          contents: [
            TargetContent(
              align: ContentAlign.top,
              builder: (context, controller) => Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    AppLocalizations.of(context)?.tourBookmarkTitle ??
                        'Save for later',
                    style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        fontSize: 20),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    AppLocalizations.of(context)?.tourBookmarkDesc ??
                        'Bookmark this profile to view later.',
                    style: const TextStyle(color: Colors.white),
                  ),
                ],
              ),
            ),
          ],
        ),
        TargetFocus(
          identify: 'interest',
          keyTarget: TourKeys.interestButtonKey,
          contents: [
            TargetContent(
              align: ContentAlign.top,
              builder: (context, controller) => Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    AppLocalizations.of(context)?.tourInterestTitle ??
                        'Express Interest',
                    style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        fontSize: 20),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    AppLocalizations.of(context)?.tourInterestDesc ??
                        AppLocalizations.of(context)?.sendHeartInterested ?? "Send a heart to show you're interested.",
                    style: const TextStyle(color: Colors.white),
                  ),
                ],
              ),
            ),
          ],
        ),
        TargetFocus(
          identify: 'share',
          keyTarget: TourKeys.shareButtonKey,
          contents: [
            TargetContent(
              align: ContentAlign.top,
              builder: (context, controller) => Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    AppLocalizations.of(context)?.tourShareTitle ??
                        'Share with family',
                    style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        fontSize: 20),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    AppLocalizations.of(context)?.tourShareDesc ??
                        'Share profiles via WhatsApp.',
                    style: const TextStyle(color: Colors.white),
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
      onFinish: () {
        LocalCacheService()
            .setTourStageCompleted(TourStage.profileDetail.name, true);
      },
      onSkip: () {
        LocalCacheService()
            .setTourStageCompleted(TourStage.profileDetail.name, true);
      },
    );
  }

  void _onScroll() {
    // Show title when header is mostly collapsed (60.h is total height)
    final threshold = 45.h;
    if (_scrollController.offset > threshold && !_showAppBarTitle) {
      setState(() => _showAppBarTitle = true);
    } else if (_scrollController.offset <= threshold && _showAppBarTitle) {
      setState(() => _showAppBarTitle = false);
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Get profile data from route arguments
    final args = ModalRoute.of(context)?.settings.arguments;
    if (args != null) {
      if (args is Map<String, dynamic>) {
        // Passed full profile data
        _profileData = args;
      } else if (args is String) {
        // Passed profile ID (e.g. from deep link)
        if (_profileData == null && !_isLoading) {
          _loadProfile(args);
        }
      }
    }
  }

  Future<void> _loadProfile(String profileId) async {
    setState(() {
      _isLoading = true;
    });

    try {
      final response = await ProfileRepository().getProfileById(profileId);

      await response.fold(
        onSuccess: (profile) {
          if (profile != null) {
            if (mounted) {
              setState(() {
                _profileData = profile.toDisplayMap();
              });
            }
          }
        },
        onFailure: (error) {
          debugPrint('Error loading profile from ID: $error');
        },
      );
    } catch (e) {
      debugPrint('Error loading profile from ID: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    // 🧬 PERFORMANCE: Removed global imageCache.clear() which was causing feed stutter.
    // Proactive limits are now managed globally by PerformanceService.
    super.dispose();
  }


  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (_isLoading) {
      return Scaffold(
        backgroundColor: theme.scaffoldBackgroundColor,
        appBar: AppBar(
          leading: IconButton(
            icon: CustomIconWidget(
              iconName: 'arrow_back',
              color: theme.colorScheme.onSurface,
            ),
            onPressed: () => Navigator.of(context).pop(),
          ),
          backgroundColor: Colors.transparent,
          elevation: 0,
        ),
        body: const ProfileDetailSkeleton(),
      );
    }

    // Show error if no profile data
    if (_profileData == null) {
      return Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: CustomIconWidget(
              iconName: 'arrow_back',
              color: theme.colorScheme.onSurface,
            ),
            onPressed: () => Navigator.of(context).pop(),
          ),
          title: Text(AppLocalizations.of(context)?.profile ?? 'Profile'),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CustomIconWidget(
                iconName: 'error_outline',
                color: theme.colorScheme.error,
                size: 48,
              ),
              SizedBox(height: 2.h),
              Text(AppLocalizations.of(context)?.profileDataNotFound ?? 'Profile data not found',
                style: theme.textTheme.titleMedium,
              ),
              SizedBox(height: 2.h),
              ElevatedButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text(AppLocalizations.of(context)?.goBack ?? 'Go Back'),
              ),
            ],
          ),
        ),
      );
    }

    // Derive isBookmarked from Riverpod (single source of truth for bookmark state)
    final profileId = _profileData!['id']?.toString();
    final displayProfileData = profileId != null
        ? <String, dynamic>{
            ..._profileData!,
            'isBookmarked': ref.watch(isBookmarkedProvider(profileId)),
          }
        : _profileData!;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: Stack(
        children: [
          // Main scrollable content
          CustomScrollView(
            controller: _scrollController,
            slivers: [
              // Pinned Profile AppBar with persistent info
              SliverAppBar(
                expandedHeight: 60.h,
                pinned: true,
                automaticallyImplyLeading: false,
                backgroundColor: theme.scaffoldBackgroundColor,
                surfaceTintColor: Colors.transparent,
                elevation: 0,
                leadingWidth: 14.w,
                leading: IconButton(
                  icon: CustomIconWidget(
                    iconName: 'arrow_back',
                    color: theme.colorScheme.onSurface,
                  ),
                  onPressed: () => Navigator.of(context).pop(),
                  tooltip: AppLocalizations.of(context)?.goBack ?? 'Back',
                ),
                title: AnimatedOpacity(
                  opacity: _showAppBarTitle ? 1.0 : 0.0,
                  duration: const Duration(milliseconds: 250),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        children: [
                          Flexible(
                            child: Text(
                              _profileData!['name']?.toString() ?? (AppLocalizations.of(context)?.banjaraMember ?? 'Banjara Member'),
                              style: theme.textTheme.titleMedium?.copyWith(
                                color: theme.colorScheme.onSurface,
                                fontWeight: FontWeight.w900,
                                fontSize: 18.sp,
                                letterSpacing: 0.3,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (_profileData!['isVerified'] == true) ...[
                            SizedBox(width: 1.w),
                            const Icon(
                              Icons.verified,
                              color: Colors.green,
                              size: 16,
                            ),
                          ],
                        ],
                      ),
                      Text(
                        'ID: ${_profileData!['displayId'] ?? ''} • ${_profileData!['age'] != null ? AppLocalizations.of(context)?.yrs(_profileData!['age'].toString()) ?? "${_profileData!['age']} Yrs" : ""} • ${_profileData!['height'] ?? ''} • ${_profileData!['surname'] ?? ''}',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                          fontWeight: FontWeight.w700,
                          fontSize: 10.sp,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                actions: [
                  IconButton(
                    icon: CustomIconWidget(
                      iconName: 'more_vert',
                      color: theme.colorScheme.onSurface,
                    ),
                    onPressed: _showOptionsMenu,
                    tooltip: AppLocalizations.of(context)?.moreOptions ?? 'More options',
                  ),
                  SizedBox(width: 2.w),
                ],
                flexibleSpace: FlexibleSpaceBar(
                  background: ProfileHeaderWidget(
                    profileData: displayProfileData,
                    isPremium: _profileData!['isPremium'] as bool? ?? false,
                    onOptionsTap: _showOptionsMenu,
                  ),
                ),
              ),

              // Profile content sections
              SliverToBoxAdapter(
                child: Column(
                  children: [
                    SizedBox(height: 1.h),
                    // Staggered Detail Cards (2 Columns)
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 1.w),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Left Column
                          Expanded(
                            child: Column(
                              children: [
                                PersonalDetailsCardWidget(
                                  profileData: displayProfileData,
                                  margin: EdgeInsets.only(
                                      bottom: 2.h, left: 1.w, right: 1.w),
                                ),
                                EducationProfessionCardWidget(
                                  profileData: displayProfileData,
                                  margin: EdgeInsets.only(
                                      bottom: 2.h, left: 1.w, right: 1.w),
                                ),
                              ],
                            ),
                          ),
                          // Right Column
                          Expanded(
                            child: Column(
                              children: [
                                LocationDetailsCardWidget(
                                  profileData: displayProfileData,
                                  margin: EdgeInsets.only(
                                      bottom: 2.h, left: 1.w, right: 1.w),
                                ),
                                FamilyBackgroundCardWidget(
                                  profileData: displayProfileData,
                                  margin: EdgeInsets.only(
                                      bottom: 2.h, left: 1.w, right: 1.w),
                                ),
                                ContactPreferencesCardWidget(
                                  profileData: displayProfileData,
                                  margin: EdgeInsets.only(
                                      bottom: 2.h, left: 1.w, right: 1.w),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 8.h),
                  ],
                ),
              ),
            ],
          ),

          // Action buttons at bottom
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: ActionButtonsWidget(
              profileData: displayProfileData,
              onShare: _handleShare,
              onInterest: _handleInterest,
              onMessage: _handleMessage,
              onBookmark: _handleBookmark,
            ),
          ),
        ],
      ),
    );
  }

  void _handleShare(Map<String, dynamic> profile) async {
    if (LocalCacheService().isGuestMode()) {
      GuestRestrictedDialog.show(context);
      return;
    }
    final theme = Theme.of(context);
    final profileId = profile['id']?.toString() ?? '';
    final profileName = profile['name']?.toString() ?? 'User';

    if (!mounted) return;

    // Show sharing options bottom sheet
    showModalBottomSheet(
      context: context,
      useRootNavigator: true,
      backgroundColor: theme.colorScheme.surface,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => Container(
        padding: EdgeInsets.fromLTRB(4.w, 1.5.h, 4.w, 3.h),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 12.w,
                height: 5,
                decoration: BoxDecoration(
                  color: theme.colorScheme.onSurfaceVariant.withValues(
                    alpha: 0.2,
                  ),
                  borderRadius: BorderRadius.circular(2.5),
                ),
              ),
            ),
            SizedBox(height: 3.h),
            Text(
              AppLocalizations.of(context)?.shareProfile ?? 'Share Profile',
              style: theme.textTheme.headlineSmall?.copyWith(
                color: theme.colorScheme.onSurface,
                fontWeight: FontWeight.w900,
                letterSpacing: -0.5,
              ),
            ),
            SizedBox(height: 2.h),

            // RECOMMEND (External Reach)
            Text(
              AppLocalizations.of(context)?.recommendToOthers ?? 'RECOMMEND TO OTHERS',
              style: theme.textTheme.labelMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
                fontWeight: FontWeight.w800,
                letterSpacing: 1.2,
              ),
            ),
            SizedBox(height: 1.h),
            _buildShareOption(
              ctx,
              AppLocalizations.of(context)?.whatsApp ?? 'WhatsApp',
              AppLocalizations.of(context)?.whatsappShareSubtitle(profileName) ?? 'Share $profileName details with family or friends',
              'share',
              onTap: () async {
                Navigator.pop(ctx);
                final res = await _shareRepository.shareProfile(
                  sharedProfileId: profileId,
                  sharingMethod: 'whatsapp',
                  recipientName: AppLocalizations.of(context)?.whatsAppContact ?? 'WhatsApp Contact',
                  recipientRelation: 'External',
                  profileName: profileName,
                );
                _handleShareResult(res, 'WhatsApp', profileName);
              },
            ),
            SizedBox(height: 1.h),
            _buildShareOption(
              ctx,
              AppLocalizations.of(context)?.copyLink ?? 'Copy Profile Link',
              AppLocalizations.of(context)?.copyLinkSubtitle(profileName) ?? 'Copy a link to $profileName profile',
              'link',
              onTap: () async {
                Navigator.pop(ctx);
                final res = await _shareRepository.shareProfile(
                  sharedProfileId: profileId,
                  sharingMethod: 'link',
                  recipientName: AppLocalizations.of(context)?.linkShare ?? 'Link Share',
                  recipientRelation: 'External',
                  profileName: profileName,
                );
                _handleShareResult(res, 'link', profileName);
              },
            ),
            SizedBox(height: 2.h),
          ],
        ),
      ),
    );
  }

  Widget _buildShareOption(
    BuildContext ctx,
    String title,
    String subtitle,
    String iconName, {
    required VoidCallback onTap,
    bool isHighlight = false,
  }) {
    final theme = Theme.of(ctx);
    final primaryColor = theme.colorScheme.primary;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: EdgeInsets.all(4.w),
        margin: EdgeInsets.symmetric(vertical: 0.5.h),
        decoration: BoxDecoration(
          color: isHighlight
              ? primaryColor.withValues(alpha: 0.05)
              : Colors.transparent,
          border: Border.all(
            color: isHighlight
                ? primaryColor.withValues(alpha: 0.3)
                : theme.colorScheme.outline.withValues(alpha: 0.15)
,
            width: isHighlight ? 1.5 : 1,
          ),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(2.5.w),
              decoration: BoxDecoration(
                color: isHighlight
                    ? primaryColor.withValues(alpha: 0.1)
                    : theme.colorScheme.onSurface.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(12),
              ),
              child: CustomIconWidget(
                iconName: iconName,
                color: isHighlight ? primaryColor : theme.colorScheme.onSurface,
              ),
            ),
            SizedBox(width: 4.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                      color: isHighlight ? primaryColor : theme.colorScheme.onSurface,
                    ),
                  ),
                  SizedBox(height: 0.2.h),
                  Text(
                    subtitle,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right,
              color: isHighlight
                  ? primaryColor.withValues(alpha: 0.5)
                  : theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.2)
,
            ),
          ],
        ),
      ),
    );
  }


  void _handleShareResult(
    BackendResponse<ProfileShare> res,
    String method,
    String profileName,
  ) {
    res.fold(
      onSuccess: (_) {
        if (mounted) {
          String msg = AppLocalizations.of(context)?.sharedVia(profileName, method) ?? 'Shared $profileName via $method';
          if (method == 'link') msg = AppLocalizations.of(context)?.profileLinkCopied ?? 'Profile link copied to clipboard!';
          if (method == 'in_app') msg = AppLocalizations.of(context)?.profileSharedWith(profileName) ?? 'Profile shared with $profileName';

          Fluttertoast.showToast(
            msg: msg,
            backgroundColor: Colors.green,
            textColor: Colors.white,
          );
        }
      },
      onFailure: (error) {
        if (mounted) {
          Fluttertoast.showToast(
            msg: error,
            backgroundColor: Theme.of(context).colorScheme.error,
            textColor: Colors.white,
          );
        }
      },
    );
  }

  void _handleMessage(Map<String, dynamic> profile) async {
    if (LocalCacheService().isGuestMode()) {
      GuestRestrictedDialog.show(context);
      return;
    }
    // 🚨 CRITICAL: Use 'userId' (camelCase) to match ProfileModel.toDisplayMap() structure
    final otherUserId = profile['userId']?.toString();
    if (otherUserId == null) {
      Fluttertoast.showToast(msg: AppLocalizations.of(context)?.userIdNotFound ?? 'User ID not found');
      return;
    }

    // Check if matched
    final isMatched = profile['isMatched'] as bool? ?? false;
    if (!isMatched) {
      if (mounted) {
        Fluttertoast.showToast(
          msg: AppLocalizations.of(context)?.notMatchedCannotMessage ?? "You are not matched with this profile, so you can't direct message them.",
          toastLength: Toast.LENGTH_LONG,
        );
      }
      return;
    }

    if (mounted) {
      Fluttertoast.showToast(msg: AppLocalizations.of(context)?.openingConversation ?? 'Opening conversation...');
    }

    final chatRepo = ChatRepository();
    final res = await chatRepo.getOrCreateConversation(otherUserId);

    res.fold(
      onSuccess: (conversation) {
        if (mounted) {
          Navigator.pushNamed(
            context,
            AppRoutes.chatScreen,
            arguments: conversation,
          );
        }
      },
      onFailure: (error) {
        if (error.toString().contains('FREE_LIMIT_REACHED')) {
          // Show Ad Reward option instead of just Upgrade (Disabled for now)
          /*
          showDialog(
            context: context,
            builder: (context) => RewardedAdDialog(
              rewardType: AdRewardType.directMessage,
              onRewardGranted: () async {
                await UsageRepository().grantAdReward(AdRewardType.directMessage);
                if (mounted) {
                  Fluttertoast.showToast(msg: "1 Message Unlocked!");
                }
              },
            ),
          );
          */
          if (mounted) {
             Fluttertoast.showToast(msg: 'Daily message limit reached.');
          }
        } else if (mounted) {
          Fluttertoast.showToast(
            msg: AppLocalizations.of(context)?.failedToStartChat(error.toString()) ?? 'Failed to start chat: $error',
            backgroundColor: Theme.of(context).colorScheme.error,
            textColor: Colors.white,
          );
        }
      },
    );
  }

  void _handleInterest(Map<String, dynamic> profile) {
    if (LocalCacheService().isGuestMode()) {
      GuestRestrictedDialog.show(context);
      return;
    }
    final profileName = profile['name']?.toString() ?? 'User';
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(AppLocalizations.of(context)?.expressInterest ?? 'Express Interest?'),
        content: Text(
          AppLocalizations.of(context)?.interestConfirmationDesc(profileName) ?? 
          'Do you want to share your profile with $profileName to show your interest?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(AppLocalizations.of(context)?.no ?? 'No'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _executeInterest(profile);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFE91E63),
              foregroundColor: Colors.white,
            ),
            child: Text(AppLocalizations.of(context)?.yesInterest ?? 'Yes, Interest'),
          ),
        ],
      ),
    );
  }

  Future<void> _executeInterest(Map<String, dynamic> profile) async {
    final l10n = AppLocalizations.of(context);
    final profileId = profile['id']?.toString() ?? '';
    final profileName = profile['name']?.toString() ?? 'User';

    // 1. Check sharing limits
    final usageRepo = UsageRepository();
    final canShareResult = await usageRepo.canShareProfile();
    final canShare = canShareResult.fold(onSuccess: (val) => val, onFailure: (_) => false);

    if (!canShare) {
      if (mounted) {
        showDialog(
          context: context,
          builder: (context) => UpgradeDialog(
            title: l10n?.limitReached ?? 'Limit Reached',
            message: l10n?.upgradeToShareMore ?? 'You have reached your free sharing limit. Upgrade to continue sharing profiles.',
            featureName: l10n?.sharingProfiles ?? 'Sharing Profiles',
          ),
        );
      }
      return;
    }

    // 2. Get My Profile ID
    final myProfileId = await _shareRepository.getMyProfileId();
    if (myProfileId == null) {
      if (mounted) {
        Fluttertoast.showToast(msg: l10n?.youNeedAProfileToShareIt ?? 'You need a profile to share it.');
      }
      return;
    }

    // 3. Execute share
    if (mounted) {
      Fluttertoast.showToast(msg: l10n?.sharingProfile ?? 'Sharing profile...');
    }

    final res = await _shareRepository.shareProfile(
      sharedProfileId: myProfileId,
      sharingMethod: 'in_app',
      recipientId: profileId,
      recipientName: profileName,
      recipientRelation: 'Prospect',
      profileName: l10n?.your ?? 'Your',
    );

    _handleShareResult(res, 'in_app', profileName);
  }

  Future<void> _handleBookmark(Map<String, dynamic> profile) async {
    if (LocalCacheService().isGuestMode()) {
      GuestRestrictedDialog.show(context);
      return;
    }
    final profileId = profile['id']?.toString();
    if (profileId == null) return;

    final wasBookmarked = profile['isBookmarked'] == true;
    if (kDebugMode) {
      debugPrint('[BOOKMARK] ProfileDetailScreen > User tapped ${wasBookmarked ? "SAVED" : "SAVE"} on profile $profileId > Calling Riverpod toggle');
    }

    try {
      await ref.read(bookmarkNotifierProvider.notifier).toggle(profileId);
      if (mounted) {
        final isNowBookmarked =
            ref.read(bookmarkNotifierProvider)[profileId] ?? false;
        if (kDebugMode) {
          debugPrint('[BOOKMARK] ProfileDetailScreen > toggle($profileId) > SUCCESS > now: $isNowBookmarked');
        }
        Fluttertoast.showToast(
          msg: isNowBookmarked 
              ? (AppLocalizations.of(context)?.profileSaved ?? 'Profile saved!') 
              : (AppLocalizations.of(context)?.profileRemovedFromSaved ?? 'Profile removed from saved'),
          backgroundColor: Colors.green,
          textColor: Colors.white,
        );
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('[BOOKMARK] ProfileDetailScreen > toggle($profileId) > FAILED | $e');
      }
      if (mounted) {
        Fluttertoast.showToast(
          msg: AppLocalizations.of(context)?.failedToUpdateBookmark(e.toString()) ?? 'Failed to update bookmark: $e',
          backgroundColor: Theme.of(context).colorScheme.error,
          textColor: Colors.white,
        );
      }
    }
  }

  void _showOptionsMenu() {
    if (LocalCacheService().isGuestMode()) {
      GuestRestrictedDialog.show(context);
      return;
    }
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        final theme = Theme.of(context);
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: Icon(Icons.block, color: theme.colorScheme.error),
                title: Text(AppLocalizations.of(context)?.blockUser ?? 'Block User'),
                subtitle: Text(AppLocalizations.of(context)?.youWillNoLongerSeeThisProfile ?? 'You will no longer see this profile'),
                onTap: () {
                  Navigator.pop(context);
                  _confirmBlock();
                },
              ),
              ListTile(
                leading: const Icon(Icons.report, color: Colors.orange),
                title: Text(AppLocalizations.of(context)?.reportUser ?? 'Report User'),
                subtitle: Text(AppLocalizations.of(context)?.inappropriateContentOrFakeProfile ?? 'Inappropriate content or fake profile'),
                onTap: () {
                  Navigator.pop(context);
                  _showReportDialog();
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _confirmBlock() {
    showDialog(
      context: context,
      builder: (context) {
        final theme = Theme.of(context);
        return AlertDialog(
          title: Text(AppLocalizations.of(context)?.blockUser ?? 'Block User?'),
          content: Text(AppLocalizations.of(context)?.areYouSureYouWantToBlockThisUserYouWillN ?? 'Are you sure you want to block this user? You will not be able to see their profile again.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(AppLocalizations.of(context)?.cancel ?? 'Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                _executeBlock();
              },
              style: ElevatedButton.styleFrom(backgroundColor: theme.colorScheme.error),
              child: Text(AppLocalizations.of(context)?.block ?? 'Block'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _executeBlock() async {
    try {
      // userId from toDisplayMap (camelCase) or raw profile (snake_case)
      final userId = _profileData?['userId'] ?? _profileData?['user_id'];
      if (userId == null) return;

      final res = await ProfileRepository().blockUser(userId.toString());
      await res.fold(
        onSuccess: (_) async {
          if (mounted) {
            Navigator.pop(context); // Close profile detail
            Fluttertoast.showToast(
              msg: AppLocalizations.of(context)?.userBlockedSuccessfully ?? 'User blocked successfully',
              backgroundColor: Colors.green,
              textColor: Colors.white,
            );
          }
        },
        onFailure: (error) async {
          if (mounted) {
            Fluttertoast.showToast(
              msg: AppLocalizations.of(context)?.failedToBlockUser(error.toString()) ?? 'Failed to block user: $error',
              backgroundColor: Theme.of(context).colorScheme.error,
              textColor: Colors.white,
            );
          }
        },
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(AppLocalizations.of(context)?.errorOccurred(e.toString()) ?? 'Error: $e')));
      }
    }
  }

  void _showReportDialog() {
    final reasons = [
      AppLocalizations.of(context)?.fakeProfile ?? 'Fake Profile',
      AppLocalizations.of(context)?.inappropriatePhotos ?? 'Inappropriate Photos',
      AppLocalizations.of(context)?.abusiveBehavior ?? 'Abusive Behavior',
      AppLocalizations.of(context)?.solicitingMoney ?? 'Soliciting Money',
      AppLocalizations.of(context)?.other ?? 'Other',
    ];

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(AppLocalizations.of(context)?.reportUser ?? 'Report User'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: reasons
              .map(
                (reason) => ListTile(
                  title: Text(reason),
                  onTap: () {
                    Navigator.pop(context);
                    _executeReport(reason);
                  },
                ),
              )
              .toList(),
        ),
      ),
    );
  }

  Future<void> _executeReport(String reason) async {
    try {
      // userId from toDisplayMap (camelCase) or raw profile (snake_case)
      final userId = _profileData?['userId'] ?? _profileData?['user_id'];
      if (userId == null) return;

      final res = await ProfileRepository().reportUser(
        reportedUserId: userId.toString(),
        reason: reason,
      );

      await res.fold(
        onSuccess: (_) async {
          if (mounted) {
            Fluttertoast.showToast(
              msg: AppLocalizations.of(context)?.reportSubmittedReview ?? 'Report submitted. Our team will review it within 24 hours.',
              backgroundColor: Colors.green,
              textColor: Colors.white,
            );
          }
        },
        onFailure: (error) async {
          if (mounted) {
            Fluttertoast.showToast(
              msg: AppLocalizations.of(context)?.failedToSubmitReport(error.toString()) ?? 'Failed to submit report: $error',
              backgroundColor: Theme.of(context).colorScheme.error,
              textColor: Colors.white,
            );
          }
        },
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(AppLocalizations.of(context)?.errorOccurred(e.toString()) ?? 'Error: $e')));
      }
    }
  }
}
