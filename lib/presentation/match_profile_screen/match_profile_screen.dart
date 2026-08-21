
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
import 'package:banjarabio/presentation/match_profile_screen/widgets/action_buttons_widget.dart';
import 'package:banjarabio/core/repositories/chat_repository.dart';
import 'package:banjarabio/presentation/match_profile_screen/widgets/education_profession_card_widget.dart';
import 'package:banjarabio/presentation/match_profile_screen/widgets/family_background_card_widget.dart';
import 'package:banjarabio/presentation/match_profile_screen/widgets/location_details_card_widget.dart';
import 'package:banjarabio/presentation/match_profile_screen/widgets/personal_details_card_widget.dart';
import 'package:banjarabio/presentation/match_profile_screen/widgets/horoscope_astro_card_widget.dart';
import 'package:banjarabio/presentation/match_profile_screen/widgets/match_compatibility_meter_widget.dart';
import 'package:banjarabio/presentation/match_profile_screen/widgets/profile_trust_score_card_widget.dart';
import 'package:banjarabio/presentation/match_profile_screen/widgets/staggered_fade_slide_widget.dart';
import 'package:banjarabio/presentation/match_profile_screen/widgets/profile_header_widget.dart';
import 'package:banjarabio/presentation/match_profile_screen/widgets/profile_share_bottom_sheet.dart';
import 'package:banjarabio/presentation/match_profile_screen/widgets/direct_note_bottom_sheet.dart';
import 'package:banjarabio/presentation/match_profile_screen/widgets/profile_options_menu.dart';
import 'package:banjarabio/presentation/match_profile_screen/widgets/profile_guided_tour.dart';
import 'package:banjarabio/presentation/match_profile_screen/widgets/profile_loading_states.dart';
import 'package:banjarabio/presentation/home_screen/widgets/guest_restricted_dialog.dart';
import 'package:banjarabio/core/services/app_logger.dart';
import 'package:banjarabio/presentation/match_profile_screen/widgets/similar_profiles_carousel.dart';
// import '../../core/services/ad_reward_service.dart';
// import '../widgets/rewarded_ad_dialog.dart';

import 'package:banjarabio/presentation/match_profile_screen/widgets/profile_tab_selector_widget.dart';
import 'package:banjarabio/widgets/tactile/tactile_back_button.dart';
import 'package:banjarabio/widgets/tactile/tactile_action_button.dart';

/// Match Profile Screen displaying complete biodata information of another candidate
/// Accessed via stack navigation from Home / Search / Melava screen
/// Presents traditional matrimonial format optimized for mobile viewing
class MatchProfileScreen extends ConsumerStatefulWidget {
  const MatchProfileScreen({super.key});

  @override
  ConsumerState<MatchProfileScreen> createState() =>
      _MatchProfileScreenState();
}

/// Backwards compatibility alias
typedef ProfileDetailScreen = MatchProfileScreen;

class _MatchProfileScreenState extends ConsumerState<MatchProfileScreen> {
  final ScrollController _scrollController = ScrollController();
  final ShareRepository _shareRepository = ShareRepository();
  bool _isLoading = false;
  Map<String, dynamic>? _profileData;
  bool _showAppBarTitle = false;
  int _selectedTabIndex = 0;

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
            Fluttertoast.showToast(msg: AppLocalizations.of(context)?.dailyViewLimitReached ?? 'Daily view limit reached.');
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
                leadingWidth: 54,
                leading: const TactileBackButton(
                  margin: EdgeInsets.only(left: 12, top: 7, bottom: 7),
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
                                fontWeight: AppTypography.black,
                                fontSize: AppTypography.headingSmall,
                                letterSpacing: -0.2,
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
                          fontWeight: AppTypography.bold,
                          fontSize: AppTypography.bodySmall,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                actions: [
                  TactileActionButton(
                    iconData: Icons.more_vert_rounded,
                    margin: const EdgeInsets.only(right: 12, top: 7, bottom: 7),
                    onPressed: () => _showOptionsMenu(),
                    tooltip: AppLocalizations.of(context)?.moreOptions ?? 'More options',
                  ),
                ],
                flexibleSpace: FlexibleSpaceBar(
                  background: ProfileHeaderWidget(
                    profileData: displayProfileData,
                    isPremium: _profileData!['isPremium'] as bool? ?? false,
                    onOptionsTap: () => _showOptionsMenu(),
                  ),
                ),
              ),

              // 🌟 Animated Sticky Profile Category Tab Selector
              SliverToBoxAdapter(
                child: ProfileTabSelectorWidget(
                  selectedIndex: _selectedTabIndex,
                  onTabSelected: (index) {
                    setState(() => _selectedTabIndex = index);
                  },
                  margin: EdgeInsets.only(top: 0.6.h, bottom: 0.5.h),
                ),
              ),

              // Profile content sections with AnimatedSwitcher
              SliverToBoxAdapter(
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  switchInCurve: Curves.easeOutCubic,
                  switchOutCurve: Curves.easeInCubic,
                  transitionBuilder: (child, animation) {
                    return FadeTransition(
                      opacity: animation,
                      child: SlideTransition(
                        position: Tween<Offset>(
                          begin: const Offset(0, 0.04),
                          end: Offset.zero,
                        ).animate(animation),
                        child: child,
                      ),
                    );
                  },
                  child: KeyedSubtree(
                    key: ValueKey<int>(_selectedTabIndex),
                    child: _buildTabContent(displayProfileData),
                  ),
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
              onDirectNote: _handleDirectNote,
              onAcceptInterest: _handleAcceptInterest,
              onDeclineInterest: _handleDeclineInterest,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabContent(Map<String, dynamic> displayProfileData) {
    switch (_selectedTabIndex) {
      case 1:
        return Column(
          children: [
            PersonalDetailsCardWidget(
              profileData: displayProfileData,
              margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
            ),
            _buildSimilarProfiles(displayProfileData),
          ],
        );
      case 2:
        return Column(
          children: [
            EducationProfessionCardWidget(
              profileData: displayProfileData,
              margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
            ),
            _buildSimilarProfiles(displayProfileData),
          ],
        );
      case 3:
        return Column(
          children: [
            FamilyBackgroundCardWidget(
              profileData: displayProfileData,
              margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
            ),
            _buildSimilarProfiles(displayProfileData),
          ],
        );
      case 4:
        return Column(
          children: [
            HoroscopeAstroCardWidget(
              profileData: displayProfileData,
              margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
              onViewKundali: () => _handleKundaliPreview(displayProfileData),
            ),
            _buildSimilarProfiles(displayProfileData),
          ],
        );
      case 5:
        return Column(
          children: [
            LocationDetailsCardWidget(
              profileData: displayProfileData,
              margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
            ),
            _buildSimilarProfiles(displayProfileData),
          ],
        );
      case 0:
      default:
        return Column(
          children: [
            StaggeredFadeSlideWidget(
              index: 0,
              child: MatchCompatibilityMeterWidget(
                profileData: displayProfileData,
                margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
              ),
            ),
            StaggeredFadeSlideWidget(
              index: 1,
              child: ProfileTrustScoreCardWidget(
                profileData: displayProfileData,
                margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
                onTap: () {
                  Navigator.pushNamed(context, AppRoutes.trustScore);
                },
              ),
            ),
            StaggeredFadeSlideWidget(
              index: 2,
              child: PersonalDetailsCardWidget(
                profileData: displayProfileData,
                margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
              ),
            ),
            StaggeredFadeSlideWidget(
              index: 3,
              child: EducationProfessionCardWidget(
                profileData: displayProfileData,
                margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
              ),
            ),
            StaggeredFadeSlideWidget(
              index: 4,
              child: FamilyBackgroundCardWidget(
                profileData: displayProfileData,
                margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
              ),
            ),
            StaggeredFadeSlideWidget(
              index: 5,
              child: HoroscopeAstroCardWidget(
                profileData: displayProfileData,
                margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
                onViewKundali: () => _handleKundaliPreview(displayProfileData),
              ),
            ),
            StaggeredFadeSlideWidget(
              index: 6,
              child: LocationDetailsCardWidget(
                profileData: displayProfileData,
                margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
              ),
            ),
            _buildSimilarProfiles(displayProfileData),
          ],
        );
    }
  }

  void _handleKundaliPreview(Map<String, dynamic> profile) {
    final hasKundali = profile['hasHoroscope'] == true ||
        profile['kundaliAttached'] == true ||
        profile['horoscopeUrl'] != null;

    if (hasKundali) {
      Fluttertoast.showToast(
        msg: AppLocalizations.of(context)?.horoscopeChartVerified ?? 'Horoscope chart verified & matched.',
      );
    } else {
      Fluttertoast.showToast(
        msg: AppLocalizations.of(context)?.fullKundaliAvailableOnMutual ?? 'Full Kundali chart available on mutual match interest.',
      );
    }
  }

  Widget _buildSimilarProfiles(Map<String, dynamic> displayProfileData) {
    return Column(
      children: [
        SizedBox(height: 2.h),
        SimilarProfilesCarousel(
          currentProfileData: displayProfileData,
        ),
        SizedBox(height: 10.h),
      ],
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
          if (method == 'in_app') {
            msg = AppLocalizations.of(context)?.profileSharedWith(profileName) ?? 'Profile shared with $profileName';
            setState(() {
              if (_profileData != null) {
                _profileData!['interestSent'] = true;
                _profileData!['status'] = 'pending_sent';
              }
            });
          }

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

  void _handleDirectNote(Map<String, dynamic> profile) {
    if (LocalCacheService().isGuestMode()) {
      GuestRestrictedDialog.show(context);
      return;
    }
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => DirectNoteBottomSheet(
        profile: profile,
        onSuccess: () {
          setState(() {
            if (_profileData != null) {
              _profileData!['interestSent'] = true;
              _profileData!['status'] = 'pending_sent';
            }
          });
          Fluttertoast.showToast(
            msg: AppLocalizations.of(context)?.directNoteSentToast ?? 'Direct Note sent with high priority! 💌',
            backgroundColor: AppColors.categoryLocation,
            textColor: Colors.white,
          );
        },
      ),
    );
  }

  void _handleAcceptInterest(Map<String, dynamic> profile) async {
    if (LocalCacheService().isGuestMode()) {
      GuestRestrictedDialog.show(context);
      return;
    }
    final otherUserId = profile['userId']?.toString() ?? profile['id']?.toString();
    if (otherUserId == null) return;

    setState(() {
      if (_profileData != null) {
        _profileData!['isMatched'] = true;
        _profileData!['status'] = 'matched';
      }
    });

    Fluttertoast.showToast(
      msg: AppLocalizations.of(context)?.connectionAcceptedToast ?? 'Connection Accepted! You can now chat directly 🎉',
      backgroundColor: AppColors.categoryLocation,
      textColor: Colors.white,
    );
  }

  void _handleDeclineInterest(Map<String, dynamic> profile) async {
    if (LocalCacheService().isGuestMode()) {
      GuestRestrictedDialog.show(context);
      return;
    }

    setState(() {
      if (_profileData != null) {
        _profileData!['status'] = 'declined';
        _profileData!['isDeclined'] = true;
      }
    });

    Fluttertoast.showToast(
      msg: AppLocalizations.of(context)?.interestDeclinedToast ?? 'Interest declined',
      backgroundColor: Colors.grey.shade700,
      textColor: Colors.white,
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
      // Route to 1 Free Intro Note / Message sheet
      _handleDirectNote(profile);
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
                  Fluttertoast.showToast(msg: AppLocalizations.of(context)?.oneMessageUnlocked ?? "1 Message Unlocked!");
                }
              },
            ),
          );
          */
          if (mounted) {
             Fluttertoast.showToast(msg: AppLocalizations.of(context)?.dailyMessageLimitReached ?? 'Daily message limit reached.');
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
              backgroundColor: AppColors.materialPink,
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
