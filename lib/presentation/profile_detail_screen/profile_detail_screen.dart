
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
import 'package:banjarabio/presentation/profile_detail_screen/widgets/profile_share_bottom_sheet.dart';
import 'package:banjarabio/presentation/profile_detail_screen/widgets/profile_options_menu.dart';
import 'package:banjarabio/presentation/profile_detail_screen/widgets/profile_guided_tour.dart';
import 'package:banjarabio/presentation/profile_detail_screen/widgets/profile_loading_states.dart';
import 'package:banjarabio/presentation/home_screen/widgets/guest_restricted_dialog.dart';
import 'package:banjarabio/core/services/app_logger.dart';
import 'package:banjarabio/core/constants/app_typography.dart';
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
      ProfileGuidedTour.checkAndStart(context, ref);
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
          AppLogger.error('ProfileDetailScreen', 'Error loading profile from ID: $error');
        },
      );
    } catch (e) {
      AppLogger.error('ProfileDetailScreen', 'Error loading profile from ID: $e');
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

    if (_isLoading) return const ProfileLoadingScaffold();
    if (_profileData == null) return const ProfileErrorScaffold();

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
                                fontSize: AppTypography.headingMedium,
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
                        'ID: ${_profileData!['displayId'] ?? ''} • ${_profileData!['age'] != null ? AppLocalizations.of(context)?.yrs(int.tryParse(_profileData!['age'].toString()) ?? 0) ?? "${_profileData!['age']} Yrs" : ""} • ${_profileData!['height'] ?? ''} • ${_profileData!['surname'] ?? ''}',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                          fontWeight: FontWeight.w700,
                          fontSize: AppTypography.bodySmall,
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
                    onPressed: () => _showOptionsMenu(),
                    tooltip: AppLocalizations.of(context)?.moreOptions ?? 'More options',
                  ),
                  SizedBox(width: 2.w),
                ],
                flexibleSpace: FlexibleSpaceBar(
                  background: ProfileHeaderWidget(
                    profileData: displayProfileData,
                    isPremium: _profileData!['isPremium'] as bool? ?? false,
                    onOptionsTap: () => _showOptionsMenu(),
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
    if (!mounted) return;

    ProfileShareBottomSheet.show(
      context: context,
      profile: profile,
      shareRepository: _shareRepository,
      onShareResult: _handleShareResult,
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
      AppLogger.debug('ProfileDetailScreen', '[BOOKMARK] ProfileDetailScreen > User tapped ${wasBookmarked ? "SAVED" : "SAVE"} on profile $profileId > Calling Riverpod toggle');
    }

    try {
      await ref.read(bookmarkNotifierProvider.notifier).toggle(profileId);
      if (mounted) {
        final isNowBookmarked =
            ref.read(bookmarkNotifierProvider)[profileId] ?? false;
        if (kDebugMode) {
          AppLogger.debug('ProfileDetailScreen', '[BOOKMARK] ProfileDetailScreen > toggle($profileId) > SUCCESS > now: $isNowBookmarked');
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
        AppLogger.error('ProfileDetailScreen', '[BOOKMARK] ProfileDetailScreen > toggle($profileId) > FAILED | $e');
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
    ProfileOptionsMenu.show(
      context: context,
      profileData: _profileData,
    );
  }
}
