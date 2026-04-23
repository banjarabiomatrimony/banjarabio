import 'package:flutter/material.dart';
import 'package:banjarabio/l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tutorial_coach_mark/tutorial_coach_mark.dart';
import 'package:sizer/sizer.dart';
import 'package:banjarabio/core/services/local_cache_service.dart';

import 'package:banjarabio/core/app_export.dart';
import 'package:banjarabio/core/models/profile_model.dart';
import 'package:banjarabio/core/models/subscription_model.dart';
import 'package:banjarabio/core/repositories/profile_repository.dart';
import 'package:banjarabio/core/repositories/subscription_repository.dart';
import 'package:banjarabio/core/services/guest_guided_tour_service.dart';
import 'package:banjarabio/core/utils/tour_keys.dart';
import 'package:banjarabio/widgets/custom_app_bar.dart';
import 'package:banjarabio/presentation/profile_detail_screen/widgets/contact_preferences_card_widget.dart';
import 'package:banjarabio/presentation/profile_detail_screen/widgets/education_profession_card_widget.dart';
import 'package:banjarabio/presentation/profile_detail_screen/widgets/family_background_card_widget.dart';
import 'package:banjarabio/presentation/profile_detail_screen/widgets/location_details_card_widget.dart';
import 'package:banjarabio/presentation/profile_detail_screen/widgets/personal_details_card_widget.dart';
import 'package:banjarabio/presentation/profile_detail_screen/widgets/profile_header_widget.dart';
import 'package:banjarabio/widgets/shimmer_widget.dart';
import 'package:banjarabio/widgets/app_logo_image.dart';
import 'package:banjarabio/widgets/glassmorphism_container.dart';
import 'package:banjarabio/presentation/my_profile_screen/widgets/vouch_dashboard_card.dart';
import 'package:banjarabio/core/services/share_service.dart';

/// My Profile Screen - View and edit own profile
class MyProfileScreen extends ConsumerStatefulWidget {
  const MyProfileScreen({super.key});

  @override
  ConsumerState<MyProfileScreen> createState() => _MyProfileScreenState();
}

class _MyProfileScreenState extends ConsumerState<MyProfileScreen> {
  final ProfileRepository _profileRepository = ProfileRepository();
  final ScrollController _scrollController = ScrollController();
  final SubscriptionRepository _subscriptionRepository =
      SubscriptionRepository();

  ProfileModel? _profile;
  SubscriptionModel? _subscription;
  int _trustScore = 0;
  bool _isLoading = true;
  bool _showAppBarTitle = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    _loadProfile();
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

  Future<void> _loadProfile() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      debugPrint('MyProfileScreen: Loading profile and subscription...');

      // Run fetches with individual timeouts to prevent hanging
      final profileRes = await _profileRepository.getOwnProfile().timeout(
        const Duration(seconds: 10),
      );

      await profileRes.fold(
        onSuccess: (profile) async {
          debugPrint(
            'MyProfileScreen: Profile ${profile != null ? "found" : "NOT found"}',
          );

          if (profile != null) {
            // Safety delay to allow UI to settle before heavy ops
            await Future.delayed(const Duration(milliseconds: 100));
          }

          // Fetch Trust Score
          int trustScore = 0;
          try {
            final trustRes = await _subscriptionRepository.getTrustScore(
              profile: profile,
            );
            trustRes.fold(
              onSuccess: (score) => trustScore = score,
              onFailure: (e) =>
                  debugPrint('MyProfileScreen: Trust Score fetch error: $e'),
            );
          } catch (e) {
            debugPrint('MyProfileScreen: Trust Score fatal error caught: $e');
          }

          SubscriptionModel? subscription;
          try {
            final subRes = await _subscriptionRepository
                .getCurrentSubscription()
                .timeout(const Duration(seconds: 10));

            subRes.fold(
              onSuccess: (sub) => subscription = sub,
              onFailure: (e) {
                debugPrint(
                  'MyProfileScreen: Subscription fetch error (non-fatal): $e',
                );
                // Non-fatal error, continue with free plan assumption
              },
            );
          } catch (e) {
            debugPrint('MyProfileScreen: Subscription fatal error caught: $e');
          }

          if (mounted) {
            setState(() {
              _profile = profile;
              _subscription = subscription;
              _trustScore = trustScore;
              _isLoading = false;
            });
            // Start tour after profile loads and UI settles
            WidgetsBinding.instance.addPostFrameCallback((_) {
              _checkAndStartTour();
            });
          }
        },
        onFailure: (error) {
          debugPrint('MyProfileScreen: Error loading profile: $error');
          if (mounted) {
            setState(() {
              _errorMessage = AppLocalizations.of(context)?.failedToLoadProfileError(error.toString()) ?? 'Failed to load profile: $error';
              _isLoading = false;
            });
          }
        },
      );
    } catch (e) {
      debugPrint('MyProfileScreen: Critical error loading profile: $e');
      if (mounted) {
        setState(() {
          _errorMessage = AppLocalizations.of(context)?.criticalFailure(e.toString()) ?? 'Critical failure: $e';
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

  void _checkAndStartTour() {
    if (_profile == null) return; // Only show tour when profile is loaded
    final cache = LocalCacheService();
    if (cache.isTourStageCompleted(TourStage.myProfileScreen.name)) return;

    Future.delayed(const Duration(milliseconds: 800), () {
      if (!mounted) return;
      final tourService = ref.read(guestTourProvider);
      tourService.startTour(
        context,
        stage: TourStage.myProfileScreen,
        targets: [
          TargetFocus(
            identify: 'profile_photos',
            keyTarget: TourKeys.profileManagePhotosKey,
            contents: [
              TargetContent(
                builder: (context, controller) => Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      AppLocalizations.of(context)?.tourProfilePhotosTitle ?? 'Manage Photos',
                      style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 20),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      AppLocalizations.of(context)?.tourProfilePhotosDesc ?? 'Upload, reorder, or delete your profile photos.',
                      style: const TextStyle(color: Colors.white),
                    ),
                  ],
                ),
              ),
            ],
          ),
          TargetFocus(
            identify: 'profile_trust',
            keyTarget: TourKeys.profileTrustScoreKey,
            contents: [
              TargetContent(
                builder: (context, controller) => Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      AppLocalizations.of(context)?.tourProfileTrustTitle ?? 'Trust Score',
                      style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 20),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      AppLocalizations.of(context)?.tourProfileTrustDesc ?? 'Your credibility score. Verify ID and selfie to increase it.',
                      style: const TextStyle(color: Colors.white),
                    ),
                  ],
                ),
              ),
            ],
          ),
          TargetFocus(
            identify: 'profile_pdf',
            keyTarget: TourKeys.profileExportPdfKey,
            contents: [
              TargetContent(
                builder: (context, controller) => Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      AppLocalizations.of(context)?.tourProfilePdfTitle ?? 'Export Biodata PDF',
                      style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 20),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      AppLocalizations.of(context)?.tourProfilePdfDesc ?? 'Generate a professional PDF to share with family.',
                      style: const TextStyle(color: Colors.white),
                    ),
                  ],
                ),
              ),
            ],
          ),
          TargetFocus(
            identify: 'profile_saved',
            keyTarget: TourKeys.profileSavedProfilesKey,
            contents: [
              TargetContent(
                align: ContentAlign.top,
                builder: (context, controller) => Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      AppLocalizations.of(context)?.tourProfileSavedTitle ?? 'Saved Profiles',
                      style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 20),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      AppLocalizations.of(context)?.tourProfileSavedDesc ?? 'View all your bookmarked profiles.',
                      style: const TextStyle(color: Colors.white),
                    ),
                  ],
                ),
              ),
            ],
          ),
          TargetFocus(
            identify: 'profile_edit',
            keyTarget: TourKeys.profileEditKey,
            contents: [
              TargetContent(
                builder: (context, controller) => Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      AppLocalizations.of(context)?.tourProfileEditTitle ?? 'Edit Profile',
                      style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 20),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      AppLocalizations.of(context)?.tourProfileEditDesc ?? 'Update your details and preferences anytime.',
                      style: const TextStyle(color: Colors.white),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
        onFinish: () {
          LocalCacheService().setTourStageCompleted(TourStage.myProfileScreen.name, true);
        },
        onSkip: () {
          LocalCacheService().setTourStageCompleted(TourStage.myProfileScreen.name, true);
        },
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    debugPrint('MyProfileScreen: build() started');
    late ThemeData theme;
    try {
      theme = Theme.of(context);
    } catch (e) {
      debugPrint('MyProfileScreen: Error getting theme: $e');
      theme = ThemeData.light(); // Fallback
    }

    if (_profile != null) {
      debugPrint(
        'MyProfileScreen building with profile: ${_profile!.fullName}',
      );
      debugPrint('Profile Photos count: ${_profile!.photos.length}');
      debugPrint('Profile ID: ${_profile!.id}');
    } else {
      debugPrint(
        'MyProfileScreen building with NULL profile (isLoading=$_isLoading)',
      );
    }

    if (_isLoading) {
      return Scaffold(
        backgroundColor: theme.scaffoldBackgroundColor,
        appBar: CustomAppBar(
          title: AppLocalizations.of(context)?.myProfile ?? 'My Profile',
          automaticallyImplyLeading: false,
          leading: Padding(
            padding: EdgeInsets.all(1.h),
            child: AppLogoImage(height: 3.5.h),
          ),
        ),
        body: const ProfileDetailSkeleton(),
      );
    }

    debugPrint('MyProfileScreen: Building Scaffold');
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: _profile == null && _errorMessage == null
          ? CustomAppBar(
              title: AppLocalizations.of(context)?.myProfile ?? 'My Profile',
              automaticallyImplyLeading: false,
              leading: Padding(
                padding: EdgeInsets.all(1.h),
                child: AppLogoImage(height: 3.5.h),
              ),
            )
          : null,
      body: _errorMessage != null
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CustomIconWidget(
                    iconName: 'error',
                    color: theme.colorScheme.error,
                    size: 48,
                  ),
                  SizedBox(height: 2.h),
                  Text(_errorMessage!),
                  SizedBox(height: 2.h),
                  ElevatedButton(
                    onPressed: _loadProfile,
                    child: Text(AppLocalizations.of(context)?.retry ?? 'Retry'),
                  ),
                ],
              ),
            )
          : _profile == null
          ? Center(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 8.w),
                child: GlassmorphismContainer(
                  color: theme.colorScheme.primary,
                  opacity: 0.05,
                  blur: 10,
                  borderRadius: BorderRadius.circular(32),
                  padding: EdgeInsets.all(8.w),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      AppLogoImage(height: 8.h),
                      SizedBox(height: 3.h),
                      Text(
                        AppLocalizations.of(context)?.biodataRequired ?? 'Biodata Required',
                        style: theme.textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: 1.5.h),
                      Text(
                        AppLocalizations.of(context)?.guestRestrictionMessage ?? 
                        'To interact with profiles, express interest, or send messages, you need to create your own biodata first.',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: 4.h),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () {
                            LocalCacheService().setGuestMode(false);
                            Navigator.of(context, rootNavigator: true)
                                .pushReplacementNamed(AppRoutes.biodataCreation);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: theme.colorScheme.primary,
                            foregroundColor: Colors.white,
                            padding: EdgeInsets.symmetric(vertical: 1.8.h),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            elevation: 0,
                          ),
                          child: Text(
                            AppLocalizations.of(context)?.createProfile ?? 'Create My Biodata',
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13.sp),
                          ),
                        ),
                      ),
                      SizedBox(height: 2.h),
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton(
                          onPressed: () {
                            LocalCacheService().setGuestMode(false);
                            // Navigate back to onboarding selection
                            Navigator.of(context, rootNavigator: true)
                                .pushReplacementNamed(AppRoutes.onboardingSelection);
                          },
                          style: OutlinedButton.styleFrom(
                            padding: EdgeInsets.symmetric(vertical: 1.8.h),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          child: Text(
                            AppLocalizations.of(context)?.exitGuestMode ?? 'Exit Guest Mode',
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13.sp),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            )
          : RefreshIndicator(
              onRefresh: _loadProfile,
              child: CustomScrollView(
                controller: _scrollController,
                slivers: [
                  SliverAppBar(
                    expandedHeight: 60.h,
                    pinned: true,
                    automaticallyImplyLeading: false,
                    backgroundColor: theme.scaffoldBackgroundColor,
                    surfaceTintColor: Colors.transparent,
                    elevation: 0,
                    leading: Padding(
                      padding: EdgeInsets.all(1.h),
                      child: AppLogoImage(height: 3.5.h),
                    ),
                    title: AnimatedOpacity(
                      opacity: _showAppBarTitle ? 1.0 : 0.0,
                      duration: const Duration(milliseconds: 250),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Row(
                                  children: [
                                    Flexible(
                                      child: Text(
                                        _profile!.fullName.toUpperCase(),
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
                                    if (_profile!.isVerified) ...[
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
                                  '${AppLocalizations.of(context)?.yrs(_profile!.age) ?? "${_profile!.age} Yrs"} • ${_profile!.height} • ${_profile!.surname} • ${_profile!.gotra ?? ''}',
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
                        ],
                      ),
                    ),
                    actions: [
                      if (_profile != null)
                        TextButton.icon(
                          key: TourKeys.profileEditKey,
                          onPressed: () {
                            Navigator.pushNamed(
                              context,
                              AppRoutes.biodataCreation,
                              arguments: {..._convertToMap(_profile!), 'isEditMode': true},
                            ).then((_) => _loadProfile());
                          },
                          icon: CustomIconWidget(
                            iconName: 'edit',
                            color: theme.colorScheme.primary,
                            size: 20,
                          ),
                          label: Text(AppLocalizations.of(context)?.edit ?? 'Edit',
                            style: theme.textTheme.labelLarge?.copyWith(
                              color: theme.colorScheme.primary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                    ],
                    flexibleSpace: FlexibleSpaceBar(
                      background: ProfileHeaderWidget(
                        profileData: _profile!.toDisplayMap(),
                        isPremium: _subscription?.planType != PlanType.free,
                        onOptionsTap: () {},
                      ),
                    ),
                  ),
                  SliverToBoxAdapter(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(height: 2.h),
                        // Manage Photos (1/3) & Trust Score (2/3)
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 4.w),
                          child: _safeBuild(
                            'PhotosAndTrust',
                            () => _buildPhotosAndTrustRow(theme),
                          ),
                        ),

                        SizedBox(height: 2.h),

                        // Utilities (PDF & Saved Profiles)
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 4.w),
                          child: _safeBuild(
                            'UtilitiesGroup',
                            () => _buildUtilitiesGroup(theme),
                          ),
                        ),

                        SizedBox(height: 2.h), // Reduced gap

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
                                    _safeBuild(
                                      'PersonalDetails',
                                      () => PersonalDetailsCardWidget(
                                        profileData: _profile!.toDisplayMap(),
                                        margin: EdgeInsets.only(
                                            bottom: 2.h, left: 1.w, right: 1.w),
                                      ),
                                    ),
                                    _safeBuild(
                                      'EducationProfession',
                                      () => EducationProfessionCardWidget(
                                        profileData: _profile!.toDisplayMap(),
                                        margin: EdgeInsets.only(
                                            bottom: 2.h, left: 1.w, right: 1.w),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              // Right Column
                              Expanded(
                                child: Column(
                                  children: [
                                    _safeBuild(
                                      'LocationDetails',
                                      () => LocationDetailsCardWidget(
                                        profileData: _profile!.toDisplayMap(),
                                        margin: EdgeInsets.only(
                                            bottom: 2.h, left: 1.w, right: 1.w),
                                      ),
                                    ),
                                    _safeBuild(
                                      'FamilyBackground',
                                      () => FamilyBackgroundCardWidget(
                                        profileData: _profile!.toDisplayMap(),
                                        margin: EdgeInsets.only(
                                            bottom: 2.h, left: 1.w, right: 1.w),
                                      ),
                                    ),
                                    _safeBuild(
                                      'ContactPreferences',
                                      () => ContactPreferencesCardWidget(
                                        profileData: _profile!.toDisplayMap(),
                                        margin: EdgeInsets.only(
                                            bottom: 2.h, left: 1.w, right: 1.w),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),

                        // Admin Section (Needs Padding)
                        if (_profile!.isAdmin) ...[
                          SizedBox(height: 1.h),
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: 4.w),
                            child: _buildSectionTitle(theme, AppLocalizations.of(context)?.adminManagement ?? 'Admin Management'),
                          ),
                          SizedBox(height: 1.h),
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: 4.w),
                            child: _buildProfileItem(
                              theme,
                              icon: 'admin_panel_settings',
                              title: AppLocalizations.of(context)
                                      ?.adminPortal ??
                                  'Admin Portal',
                              onTap: () => Navigator.pushNamed(
                                context,
                                AppRoutes.adminDashboard,
                              ),
                            ),
                          ),
                          SizedBox(height: 2.h),
                        ],

                        SizedBox(height: 8.h),
                      ],
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _safeBuild(String label, Widget Function() builder) {
    debugPrint('MyProfileScreen: Building $label...');
    try {
      final widget = builder();
      debugPrint('MyProfileScreen: Built $label');
      return widget;
    } catch (e) {
      debugPrint('MyProfileScreen: Error building $label: $e');
      return SizedBox(height: 6.h, child: Center(child: Text('Error: $label')));
    }
  }

  Widget _buildSectionTitle(ThemeData theme, String title) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 2.w),
      child: Text(
        title,
        style: theme.textTheme.titleLarge?.copyWith(
          // Increased from titleMedium
          fontWeight: FontWeight.bold,
          color: theme.colorScheme.primary,
          fontSize: 16.sp, // Explicit large size
        ),
      ),
    );
  }



  Widget _buildPhotosAndTrustRow(ThemeData theme) {
    return Column(
      children: [
        IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Manage Photos (Flex 3)
              Expanded(
                flex: 3,
                child: InkWell(
                  key: TourKeys.profileManagePhotosKey,
                  onTap: () async {
                    await Navigator.pushNamed(context, AppRoutes.photoManagement);
                    _loadProfile();
                  },
                  borderRadius: BorderRadius.circular(16),
                  child: Container(
                    padding: EdgeInsets.all(3.w),
                    decoration: BoxDecoration(
                      color: theme.cardColor,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF6C63FF).withValues(alpha: 0.1),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                      border: Border.all(
                        color: const Color(0xFF6C63FF).withValues(alpha: 0.2),
                      ),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: EdgeInsets.all(3.w),
                          decoration: BoxDecoration(
                            color: const Color(0xFF6C63FF).withValues(alpha: 0.1),
                            shape: BoxShape.circle,
                          ),
                          child: const CustomIconWidget(
                            iconName: 'photo_camera',
                            color: Color(0xFF6C63FF),
                            size: 28,
                          ),
                        ),
                        SizedBox(height: 1.h),
                        Text(
                          AppLocalizations.of(context)?.managePhotos ??
                              'Manage\nPhotos',
                          textAlign: TextAlign.center,
                          style: theme.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                            fontSize: 11.sp,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              SizedBox(width: 3.w),

              // Trust Score Dashboard (Internal Verification)
              Expanded(
                flex: 6,
                child: _buildTrustDashboard(theme),
              ),
            ],
          ),
        ),
        SizedBox(height: 2.h),
        // Community Vouching Dashboard (Social Proof)
        _safeBuild(
          'VouchDashboard',
          () => VouchDashboardCard(
            profile: _profile!,
            onInviteTap: () {
              ShareService().shareProfileStatus(
                context,
                _profile!,
                customCaption:
                    'Please vouch for my profile on BanjaraBio to help me get a "Community Trusted" badge! 🙏💍\nScan to view my details and vouch: ',
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildTrustDashboard(ThemeData theme) {
    return InkWell(
      onTap: () {
        Navigator.pushNamed(
          context,
          AppRoutes.trustScore,
        ).then((_) => _loadProfile());
      },
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: EdgeInsets.all(3.w), // Reduced padding for tighter fit
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [
              Color(0xFFE8F5E9), // Light Green
              Color(0xFFC8E6C9),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.green.withValues(alpha: 0.1),
              blurRadius: 15,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(AppLocalizations.of(context)?.trustScore ?? 'Trust Score',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                      color: const Color(0xFF2E7D32),
                      fontSize: 13.sp, // Slightly adjust for 2/3 width
                    ),
                  ),
                  SizedBox(height: 0.5.h),
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 2.w,
                      vertical: 0.5.h,
                    ),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surface,
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: Text(AppLocalizations.of(context)?.viewDetails ?? 'View Details',
                      style: TextStyle(
                        color: const Color(0xFF2E7D32),
                        fontWeight: FontWeight.bold,
                        fontSize: 9.sp,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Container(
              width: 16.w, // Slightly smaller
              height: 16.w,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: theme.colorScheme.surface,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 10,
                  ),
                ],
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  SizedBox(
                    width: 12.w,
                    height: 12.w,
                    child: CircularProgressIndicator(
                      value: _trustScore / 100,
                      backgroundColor: Colors.grey[200],
                      valueColor: const AlwaysStoppedAnimation<Color>(
                        Color(0xFF43A047),
                      ),
                      strokeWidth: 5,
                    ),
                  ),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        '$_trustScore',
                        style: TextStyle(
                          fontWeight: FontWeight.w900,
                          fontSize: 14.sp,
                          color: const Color(0xFF2E7D32),
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
    );
  }

  Widget _buildUtilitiesGroup(ThemeData theme) {
    return Container(
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            key: TourKeys.profileExportPdfKey,
            child: _buildUtilityItem(
              theme,
              icon: 'picture_as_pdf',
              title: AppLocalizations.of(context)?.exportBiodataPdf ?? 'Export Biodata PDF',
              subtitle: AppLocalizations.of(context)?.shareYourProfileProfessionally ?? 'Share your profile professionally',
              onTap: () {
                // Two-frame delay to avoid native crash when opening in debug
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    if (context.mounted) {
                      Navigator.pushNamed(context, AppRoutes.biodataEditor);
                    }
                  });
                });
              },
            ),
          ),
          Divider(height: 1, indent: 4.w, endIndent: 4.w),
          Container(
            key: TourKeys.profileSavedProfilesKey,
            child: _buildUtilityItem(
              theme,
              icon: 'bookmark',
              title: AppLocalizations.of(context)?.savedProfiles ?? 'Saved Profiles',
              subtitle: AppLocalizations.of(context)?.viewYourBookmarkedProfiles ?? 'View your bookmarked profiles',
              onTap: () {
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    if (context.mounted) {
                      Navigator.pushNamed(context, AppRoutes.savedProfiles);
                    }
                  });
                });
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUtilityItem(
    ThemeData theme, {
    required String icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return ListTile(
      onTap: onTap,
      contentPadding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 0.5.h),
      leading: Container(
        padding: EdgeInsets.all(2.w),
        decoration: BoxDecoration(
          color: theme.colorScheme.primary.withValues(alpha: 0.1),
          shape: BoxShape.circle,
        ),
        child: CustomIconWidget(
          iconName: icon,
          color: theme.colorScheme.primary,
          size: 20,
        ),
      ),
      title: Text(
        title,
        style: theme.textTheme.titleMedium?.copyWith(
          fontWeight: FontWeight.bold,
          fontSize: 13.sp, // Increased from 11.sp
        ),
      ),
      subtitle: Text(
        subtitle,
        style: theme.textTheme.bodyMedium?.copyWith(
          // Increased from bodySmall
          color: theme.colorScheme.onSurfaceVariant,
          fontSize: 11.sp, // Explicit size
        ),
      ),
      trailing: Icon(
        Icons.chevron_right,
        color: theme.colorScheme.onSurfaceVariant,
        size: 20,
      ),
    );
  }

  // _buildReferralItem removed

  Map<String, dynamic> _convertToMap(ProfileModel profile) {
    return profile.toDisplayMap();
  }

  Widget _buildProfileItem(
    ThemeData theme, {
    required String icon,
    required String title,
    required VoidCallback onTap,
    Color? iconColor,
  }) {
    return Container(
      margin: EdgeInsets.only(bottom: 1.h),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: theme.dividerColor.withValues(alpha: 0.5)),
      ),
      child: ListTile(
        onTap: onTap,
        leading: CustomIconWidget(
          iconName: icon,
          color: iconColor ?? theme.colorScheme.primary,
        ),
        title: Text(
          title,
          style: theme.textTheme.titleMedium?.copyWith(
            // Increased from bodyLarge
            color: iconColor,
            fontWeight: FontWeight.w600,
            fontSize: 13.sp, // Explicit size
          ),
        ),
        trailing: CustomIconWidget(
          iconName: 'chevron_right',
          color: theme.colorScheme.onSurfaceVariant,
          size: 20,
        ),
      ),
    );
  }
}
