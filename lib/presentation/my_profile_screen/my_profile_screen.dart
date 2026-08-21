import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:banjarabio/l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tutorial_coach_mark/tutorial_coach_mark.dart';
import 'package:sizer/sizer.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:banjarabio/core/services/local_cache_service.dart';

import 'package:banjarabio/core/app_export.dart';
import 'package:banjarabio/core/providers/profile_providers.dart';
import 'package:banjarabio/core/models/profile_model.dart';
import 'package:banjarabio/core/models/subscription_model.dart';
import 'package:banjarabio/core/repositories/profile_repository.dart';
import 'package:banjarabio/core/repositories/subscription_repository.dart';
import 'package:banjarabio/core/services/guest_guided_tour_service.dart';
import 'package:banjarabio/core/utils/tour_keys.dart';
import 'package:banjarabio/widgets/custom_app_bar.dart';
import 'package:banjarabio/presentation/profile_detail_screen/widgets/education_profession_card_widget.dart';
import 'package:banjarabio/presentation/profile_detail_screen/widgets/family_background_card_widget.dart';
import 'package:banjarabio/presentation/profile_detail_screen/widgets/location_details_card_widget.dart';
import 'package:banjarabio/presentation/profile_detail_screen/widgets/personal_details_card_widget.dart';
import 'package:banjarabio/presentation/profile_detail_screen/widgets/profile_tab_selector_widget.dart';
import 'package:banjarabio/presentation/profile_detail_screen/widgets/staggered_fade_slide_widget.dart';
import 'package:banjarabio/presentation/profile_detail_screen/widgets/profile_trust_score_card_widget.dart';
import 'package:banjarabio/widgets/tactile/tactile_pressable.dart';
import 'package:banjarabio/widgets/shimmer_widget.dart';
import 'package:banjarabio/widgets/app_logo_image.dart';
import 'package:banjarabio/widgets/glassmorphism_container.dart';
import 'package:banjarabio/core/services/app_logger.dart';
import 'package:banjarabio/presentation/my_profile_screen/widgets/completion_badge_widget.dart';

/// My Profile Screen - View and edit own profile (Ultra-Premium Edition)
class MyProfileScreen extends ConsumerStatefulWidget {
  const MyProfileScreen({super.key});

  @override
  ConsumerState<MyProfileScreen> createState() => _MyProfileScreenState();
}

/// Backwards compatibility alias
typedef SelfProfileScreen = MyProfileScreen;

class _MyProfileScreenState extends ConsumerState<MyProfileScreen>
    with TickerProviderStateMixin {
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
  int _selectedTabIndex = 0;

  bool get _isSelfProfileTourActive {
    final cache = LocalCacheService();
    return cache.isGuestMode() && !cache.isTourStageCompleted(TourStage.myProfileScreen.name);
  }
  late AnimationController _controller;
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 850),
    );
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 0.94, end: 1.06).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

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

  Future<void> _loadProfile({bool forceRefresh = false}) async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      AppLogger.debug('MyProfileScreen',
          'MyProfileScreen: Loading profile and subscription (forceRefresh: $forceRefresh)...');

      final profileRes = await _profileRepository
          .getOwnProfile(forceRefresh: forceRefresh)
          .timeout(const Duration(seconds: 10));

      await profileRes.fold(
        onSuccess: (profile) async {
          debugPrint(
            'MyProfileScreen: Profile ${profile != null ? "found" : "NOT found"}',
          );

          if (profile != null) {
            await Future.delayed(const Duration(milliseconds: 100));
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
              },
            );
          } catch (e) {
            AppLogger.error('MyProfileScreen',
                'MyProfileScreen: Subscription fatal error caught: $e');
          }

          int trustScore = 0;
          try {
            final trustRes = await _subscriptionRepository
                .getTrustScore(profile: profile)
                .timeout(const Duration(seconds: 10));
            trustRes.fold(
              onSuccess: (score) => trustScore = score,
              onFailure: (_) {},
            );
          } catch (_) {}

          if (mounted) {
            setState(() {
              _profile = profile;
              _subscription = subscription;
              _trustScore = trustScore;
              _isLoading = false;
            });
            _controller.forward(from: 0.0);
            WidgetsBinding.instance.addPostFrameCallback((_) {
              _checkAndStartTour();
            });
          }
        },
        onFailure: (error) {
          AppLogger.error(
              'MyProfileScreen', 'MyProfileScreen: Error loading profile: $error');
          if (mounted) {
            setState(() {
              _errorMessage = AppLocalizations.of(context)
                      ?.failedToLoadProfileError(error.toString()) ??
                  'Failed to load profile: $error';
              _isLoading = false;
            });
          }
        },
      );
    } catch (e) {
      AppLogger.error(
          'MyProfileScreen', 'MyProfileScreen: Critical error loading profile: $e');
      if (mounted) {
        setState(() {
          _errorMessage = AppLocalizations.of(context)
                  ?.criticalFailure(e.toString()) ??
              'Critical failure: $e';
          _isLoading = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _controller.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  void _checkAndStartTour() {
    if (_profile == null) return;
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
                      AppLocalizations.of(context)?.tourProfilePhotosTitle ??
                          'Manage Photos',
                      style: TextStyle(
                          fontWeight: AppTypography.bold,
                          color: Colors.white,
                          fontSize: AppTypography.headingLarge),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      AppLocalizations.of(context)?.tourProfilePhotosDesc ??
                          'Upload, reorder, or delete your profile photos.',
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
                      AppLocalizations.of(context)?.tourProfileTrustTitle ??
                          'Trust Score',
                      style: TextStyle(
                          fontWeight: AppTypography.bold,
                          color: Colors.white,
                          fontSize: AppTypography.headingLarge),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      AppLocalizations.of(context)?.tourProfileTrustDesc ??
                          'Your credibility score. Verify ID and selfie to increase it.',
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
                      AppLocalizations.of(context)?.tourProfileEditTitle ??
                          'Edit Profile',
                      style: TextStyle(
                          fontWeight: AppTypography.bold,
                          color: Colors.white,
                          fontSize: AppTypography.headingLarge),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      AppLocalizations.of(context)?.tourProfileEditDesc ??
                          'Update your details and preferences anytime.',
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
              .setTourStageCompleted(TourStage.myProfileScreen.name, true);
        },
        onSkip: () {
          LocalCacheService()
              .setTourStageCompleted(TourStage.myProfileScreen.name, true);
        },
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    AppLogger.debug('MyProfileScreen', 'MyProfileScreen: build() started');
    late ThemeData theme;
    try {
      theme = Theme.of(context);
    } catch (e) {
      AppLogger.error(
          'MyProfileScreen', 'MyProfileScreen: Error getting theme: $e');
      theme = ThemeData.light();
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
                            AppLocalizations.of(context)?.biodataRequired ??
                                'Biodata Required',
                            style: theme.textTheme.headlineSmall?.copyWith(
                              fontWeight: AppTypography.bold,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          SizedBox(height: 1.5.h),
                          Text(
                            AppLocalizations.of(context)
                                    ?.guestRestrictionMessage ??
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
                                    .pushReplacementNamed(
                                        AppRoutes.biodataCreation);
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: theme.colorScheme.primary,
                                foregroundColor: Colors.white,
                                padding:
                                    EdgeInsets.symmetric(vertical: 1.8.h),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                elevation: 0,
                              ),
                              child: Text(
                                AppLocalizations.of(context)?.createProfile ??
                                    'Create My Biodata',
                                style: TextStyle(
                                    fontWeight: AppTypography.bold,
                                    fontSize: AppTypography.bodyLarge),
                              ),
                            ),
                          ),
                          SizedBox(height: 2.h),
                          SizedBox(
                            width: double.infinity,
                            child: OutlinedButton(
                              onPressed: () {
                                LocalCacheService().setGuestMode(false);
                                Navigator.of(context, rootNavigator: true)
                                    .pushReplacementNamed(
                                        AppRoutes.onboardingSelection);
                              },
                              style: OutlinedButton.styleFrom(
                                padding:
                                    EdgeInsets.symmetric(vertical: 1.8.h),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                              ),
                              child: Text(
                                AppLocalizations.of(context)
                                        ?.exitGuestMode ??
                                    'Exit Guest Mode',
                                style: TextStyle(
                                    fontWeight: AppTypography.bold,
                                    fontSize: AppTypography.bodyLarge),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                )
              : RefreshIndicator(
                  onRefresh: () => _loadProfile(forceRefresh: true),
                  child: CustomScrollView(
                    controller: _scrollController,
                    slivers: [
                      SliverAppBar(
                        pinned: true,
                        automaticallyImplyLeading: false,
                        backgroundColor: theme.scaffoldBackgroundColor,
                        surfaceTintColor: Colors.transparent,
                        elevation: 0,
                        leading: Padding(
                          padding: EdgeInsets.all(1.h),
                          child: AppLogoImage(height: 3.5.h),
                        ),
                        title: Text(
                          'My Matrimonial Hub',
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontWeight: AppTypography.black,
                            color: theme.colorScheme.onSurface,
                            fontSize: AppTypography.headingSmall,
                          ),
                        ),
                        actions: [
                          if (_profile != null)
                            _AnimatedEditProfileButton(
                              key: _isSelfProfileTourActive ? TourKeys.profileEditKey : null,
                              onTap: () {
                                Navigator.pushNamed(
                                  context,
                                  AppRoutes.biodataCreation,
                                  arguments: {
                                    ..._convertToMap(_profile!),
                                    'profile': _profile,
                                    'isEditMode': true
                                  },
                                ).then((_) => _loadProfile(forceRefresh: true));
                              },
                            ),
                        ],
                      ),
                      SliverToBoxAdapter(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // 👑 Grand Profile Hero Card
                            _buildAnimatedItem(
                              index: 0,
                              child: _buildProfileDashboardCard(theme),
                            ),

                            // 🌟 Animated Profile Section Tab Selector
                            _buildAnimatedItem(
                              index: 1,
                              child: ProfileTabSelectorWidget(
                                selectedIndex: _selectedTabIndex,
                                onTabSelected: (index) {
                                  setState(() => _selectedTabIndex = index);
                                },
                                margin: EdgeInsets.only(
                                  top: 0.5.h,
                                  bottom: 1.2.h,
                                ),
                              ),
                            ),

                            // Staggered Detail Cards (Filtered / Animated Stream)
                            _safeBuild(
                              'DetailsCards',
                              () => AnimatedSwitcher(
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
                                  child: _buildTabCards(),
                                ),
                              ),
                            ),

                            // Admin Section (Needs Padding)
                            if (_profile!.isAdmin) ...[
                              SizedBox(height: 1.5.h),
                              Padding(
                                padding: EdgeInsets.symmetric(horizontal: 4.w),
                                child: _buildSectionTitle(
                                    theme,
                                    AppLocalizations.of(context)
                                            ?.adminManagement ??
                                        'Admin Management'),
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

  void _navigateToEdit({int? initialStep}) {
    Navigator.pushNamed(
      context,
      AppRoutes.biodataCreation,
      arguments: {
        ..._convertToMap(_profile!),
        'profile': _profile,
        'isEditMode': true,
        if (initialStep != null) 'initialStep': initialStep,
      },
    ).then((_) => _loadProfile(forceRefresh: true));
  }

  Widget _buildTabCards() {
    final displayData = _profile!.toDisplayMap();
    switch (_selectedTabIndex) {
      case 1:
        return PersonalDetailsCardWidget(
          profileData: displayData,
          margin: EdgeInsets.only(bottom: 2.h, left: 4.w, right: 4.w),
          onEdit: () => _navigateToEdit(initialStep: 0),
        );
      case 2:
        return EducationProfessionCardWidget(
          profileData: displayData,
          margin: EdgeInsets.only(bottom: 2.h, left: 4.w, right: 4.w),
          onEdit: () => _navigateToEdit(initialStep: 1),
        );
      case 3:
        return LocationDetailsCardWidget(
          profileData: displayData,
          margin: EdgeInsets.only(bottom: 2.h, left: 4.w, right: 4.w),
          onEdit: () => _navigateToEdit(initialStep: 2),
        );
      case 4:
        return FamilyBackgroundCardWidget(
          profileData: displayData,
          margin: EdgeInsets.only(bottom: 2.h, left: 4.w, right: 4.w),
          onEdit: () => _navigateToEdit(initialStep: 3),
        );
      case 0:
      default:
        return Column(
          children: [
            StaggeredFadeSlideWidget(
              index: 0,
              child: PersonalDetailsCardWidget(
                profileData: displayData,
                margin: EdgeInsets.only(bottom: 2.h, left: 4.w, right: 4.w),
                onEdit: () => _navigateToEdit(initialStep: 0),
              ),
            ),
            StaggeredFadeSlideWidget(
              index: 1,
              child: EducationProfessionCardWidget(
                profileData: displayData,
                margin: EdgeInsets.only(bottom: 2.h, left: 4.w, right: 4.w),
                onEdit: () => _navigateToEdit(initialStep: 1),
              ),
            ),
            StaggeredFadeSlideWidget(
              index: 2,
              child: LocationDetailsCardWidget(
                profileData: displayData,
                margin: EdgeInsets.only(bottom: 2.h, left: 4.w, right: 4.w),
                onEdit: () => _navigateToEdit(initialStep: 2),
              ),
            ),
            StaggeredFadeSlideWidget(
              index: 3,
              child: FamilyBackgroundCardWidget(
                profileData: displayData,
                margin: EdgeInsets.only(bottom: 2.h, left: 4.w, right: 4.w),
                onEdit: () => _navigateToEdit(initialStep: 3),
              ),
            ),
          ],
        );
    }
  }

  Widget _safeBuild(String label, Widget Function() builder) {
    try {
      return builder();
    } catch (e) {
      AppLogger.error(
          'MyProfileScreen', 'MyProfileScreen: Error building $label: $e');
      return SizedBox(
          height: 6.h, child: Center(child: Text('Error: $label')));
    }
  }

  Widget _buildSectionTitle(ThemeData theme, String title) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 2.w),
      child: Text(
        title,
        style: theme.textTheme.titleLarge?.copyWith(
          fontWeight: AppTypography.bold,
          color: theme.colorScheme.primary,
          fontSize: AppTypography.headingSmall,
        ),
      ),
    );
  }

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
    return _TactileMenuCard(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.5.h),
        decoration: BoxDecoration(
          color: theme.cardColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: theme.dividerColor.withValues(alpha: AppColors.opacity50),
            width: 1.1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: (iconColor ?? theme.colorScheme.primary)
                    .withValues(alpha: AppColors.opacity10),
                shape: BoxShape.circle,
              ),
              child: CustomIconWidget(
                iconName: icon,
                color: iconColor ?? theme.colorScheme.primary,
                size: 20,
              ),
            ),
            SizedBox(width: 3.5.w),
            Expanded(
              child: Text(
                title,
                style: theme.textTheme.titleMedium?.copyWith(
                  color: iconColor,
                  fontWeight: AppTypography.bold,
                  fontSize: AppTypography.bodyLarge,
                ),
              ),
            ),
            CustomIconWidget(
              iconName: 'chevron_right',
              color: theme.colorScheme.onSurfaceVariant,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }

  // 👑 Grand Profile Hero Card (Tactile, Animated & Luxurious)
  Widget _buildProfileDashboardCard(ThemeData theme) {
    final primaryPhoto = _profile!.photos.firstWhere(
      (photo) => photo.isPrimary,
      orElse: () => _profile!.photos.isNotEmpty
          ? _profile!.photos.first
          : PhotoModel(
              id: '',
              profileId: '',
              storagePath: '',
              publicUrl: '',
              uploadedAt: DateTime.now()),
    );
    final photoUrl = primaryPhoto.publicUrl;
    final isVerified = _profile!.isVerified;
    final isPremium =
        _subscription != null && _subscription!.planType.isPaidPlan;
    final planDisplayName = isPremium
        ? _subscription!.planType.displayName.toUpperCase()
        : 'FREE';
    final isComplete = _profile!.completionPercentage >= 100;
    final isDark = theme.brightness == Brightness.dark;

    final liveTrustScore = ref.watch(trustScoreProvider).maybeWhen(
      data: (score) => score,
      orElse: () => _trustScore,
    );

    return Container(
      margin: EdgeInsets.only(top: 1.h, bottom: 1.8.h, left: 4.w, right: 4.w),
      padding: EdgeInsets.symmetric(horizontal: 4.2.w, vertical: 2.2.h),
      decoration: BoxDecoration(
        color: isDark ? theme.colorScheme.surface : theme.cardColor,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: isPremium
              ? AppColors.gold
              : theme.colorScheme.outlineVariant.withValues(alpha: AppColors.opacity35),
          width: isPremium ? 1.6 : 1.1,
        ),
        boxShadow: [
          BoxShadow(
            color: isPremium
                ? AppColors.gold.withValues(alpha: AppColors.opacity12)
                : theme.colorScheme.primary.withValues(alpha: AppColors.opacity5),
            blurRadius: 18,
            offset: const Offset(0, 6),
          ),
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 4,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. Prominent Interactive Trust & Verification Banner
          ProfileTrustScoreCardWidget(
            key: _isSelfProfileTourActive ? TourKeys.profileTrustScoreKey : null,
            profileData: {
              'trustScore': liveTrustScore,
              'isVerified': isVerified,
            },
            margin: EdgeInsets.only(bottom: 2.h),
            onTap: () {
              Navigator.pushNamed(context, AppRoutes.trustScore)
                  .then((_) => _loadProfile(forceRefresh: true));
            },
          ),

          // 2. Avatar and Identity Row (with Live Multi-Layer Pulse Ring)
          Row(
            children: [
              // Live Breathing Avatar
              GestureDetector(
                key: _isSelfProfileTourActive ? TourKeys.profileManagePhotosKey : null,
                onTap: () {
                  Navigator.pushNamed(context, AppRoutes.photoManagement)
                      .then((_) => _loadProfile(forceRefresh: true));
                },
                child: AnimatedBuilder(
                  animation: _pulseAnimation,
                  builder: (context, child) {
                    return Stack(
                      alignment: Alignment.center,
                      clipBehavior: Clip.none,
                      children: [
                        // Rotating multi-gradient ring
                        Container(
                          width: 19.w,
                          height: 19.w,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: SweepGradient(
                              colors: [
                                AppColors.categoryVip,
                                theme.colorScheme.primary,
                                isComplete
                                    ? AppColors.categoryLocation
                                    : AppColors.orangeAmber700,
                                AppColors.categoryVip,
                              ],
                              transform: GradientRotation(
                                  _pulseController.value * 6.28),
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: (isComplete
                                        ? AppColors.categoryLocation
                                        : theme.colorScheme.primary)
                                    .withValues(
                                        alpha: 0.28 * _pulseAnimation.value),
                                blurRadius: 10,
                                spreadRadius: 1.5,
                              ),
                            ],
                          ),
                        ),
                        // Profile Photo
                        Container(
                          width: 17.w,
                          height: 17.w,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: theme.scaffoldBackgroundColor,
                            border: Border.all(
                              color: theme.cardColor,
                              width: 2.2,
                            ),
                          ),
                          child: ClipOval(
                            child: CustomImageWidget(
                              imageUrl: photoUrl,
                              fit: BoxFit.cover,
                              semanticLabel: 'My Profile Photo',
                            ),
                          ),
                        ),
                        // Verified check badge
                        if (isVerified)
                          Positioned(
                            bottom: 0,
                            right: 0,
                            child: Container(
                              padding: const EdgeInsets.all(3.0),
                              decoration: BoxDecoration(
                                color: AppColors.categoryLocation,
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: theme.cardColor,
                                  width: 1.8,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: AppColors.categoryLocation
                                        .withValues(alpha: AppColors.opacity40),
                                    blurRadius: 4,
                                  ),
                                ],
                              ),
                              child: const Icon(
                                Icons.check_rounded,
                                color: Colors.white,
                                size: 11,
                              ),
                            ),
                          ),
                      ],
                    );
                  },
                ),
              ),
              SizedBox(width: 4.w),

              // Name, Gotra, Display ID, and Plan Row
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            [
                              _profile!.fullName,
                              if (_profile!.gotra != null &&
                                  _profile!.gotra!.isNotEmpty)
                                '- ${_profile!.gotra}',
                            ].join(' '),
                            style: theme.textTheme.titleLarge?.copyWith(
                              fontWeight: AppTypography.black,
                              fontSize: AppTypography.headingSmall,
                              color: theme.colorScheme.onSurface,
                              letterSpacing: -0.3,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (isVerified) ...[
                          SizedBox(width: 1.5.w),
                          const Icon(
                            Icons.verified_rounded,
                            color: AppColors.categoryLocation,
                            size: 18,
                          ),
                        ],
                      ],
                    ),
                    SizedBox(height: 0.8.h),
                    Wrap(
                      spacing: 2.w,
                      runSpacing: 0.5.h,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        // Copyable User ID Badge
                        InkWell(
                          onTap: () {
                            Clipboard.setData(
                                ClipboardData(text: _profile!.displayId));
                            HapticFeedback.lightImpact();
                            Fluttertoast.showToast(
                              msg:
                                  'Profile ID copied: ${_profile!.displayId}',
                              toastLength: Toast.LENGTH_SHORT,
                              gravity: ToastGravity.BOTTOM,
                            );
                          },
                          borderRadius: BorderRadius.circular(6),
                          child: Container(
                            padding: EdgeInsets.symmetric(
                                horizontal: 2.2.w, vertical: 0.4.h),
                            decoration: BoxDecoration(
                              color: theme.colorScheme.primary
                                  .withValues(alpha: AppColors.opacity8),
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(
                                color: theme.colorScheme.primary
                                    .withValues(alpha: 0.22),
                                width: 0.8,
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  _profile!.displayId,
                                  style: TextStyle(
                                    color: theme.colorScheme.primary,
                                    fontWeight: AppTypography.extraBold,
                                    fontSize: AppTypography.labelSmall,
                                  ),
                                ),
                                SizedBox(width: 1.w),
                                Icon(
                                  Icons.copy_rounded,
                                  size: 10.5,
                                  color: theme.colorScheme.primary,
                                ),
                              ],
                            ),
                          ),
                        ),
                        // Plan Badge
                        Container(
                          padding: EdgeInsets.symmetric(
                              horizontal: 2.2.w, vertical: 0.4.h),
                          decoration: BoxDecoration(
                            gradient: isPremium
                                ? const LinearGradient(
                                    colors: [
                                      AppColors.amber600,
                                      AppColors.orangeAmber700
                                    ],
                                  )
                                : null,
                            color: isPremium ? null : AppColors.neutral100,
                            borderRadius: BorderRadius.circular(6),
                            border: isPremium
                                ? null
                                : Border.all(
                                    color: Colors.grey.withValues(alpha: AppColors.opacity30),
                                    width: 0.8,
                                  ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              if (isPremium) ...[
                                const Icon(Icons.star_rounded,
                                    color: Colors.white, size: 12),
                                SizedBox(width: 1.w),
                              ],
                              Text(
                                isPremium ? planDisplayName : 'FREE USER',
                                style: TextStyle(
                                  color: isPremium
                                      ? Colors.white
                                      : AppColors.neutral700,
                                  fontWeight: AppTypography.extraBold,
                                  fontSize: AppTypography.labelTiny,
                                  letterSpacing: 0.2,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),

          Divider(
              height: 2.5.h,
              color: theme.dividerColor.withValues(alpha: 0.45)),

          // 4. Profile Completeness Progress Tracker
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                isComplete
                    ? '🎉 Profile 100% Completed'
                    : 'Profile Completion (तैयारी %)',
                style: TextStyle(
                  fontSize: AppTypography.labelSmall,
                  fontWeight: AppTypography.extraBold,
                  color: isComplete
                      ? AppColors.categoryLocation
                      : theme.colorScheme.onSurface,
                ),
              ),
              Text(
                '${_profile!.completionPercentage}% Complete',
                style: TextStyle(
                  fontSize: AppTypography.labelSmall,
                  fontWeight: AppTypography.black,
                  color: isComplete
                      ? AppColors.categoryLocation
                      : theme.colorScheme.primary,
                ),
              ),
            ],
          ),
          SizedBox(height: 1.h),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: _profile!.completionPercentage / 100,
              minHeight: 8,
              backgroundColor:
                  theme.colorScheme.primary.withValues(alpha: AppColors.opacity8),
              valueColor: AlwaysStoppedAnimation<Color>(
                isComplete
                    ? AppColors.categoryLocation
                    : theme.colorScheme.primary,
              ),
            ),
          ),
          SizedBox(height: 1.5.h),
          CompletionBadgeWidget(
            completionPercentage: _profile!.completionPercentage,
            onEditTap: () {
              Navigator.pushNamed(
                context,
                AppRoutes.biodataCreation,
                arguments: {
                  ..._convertToMap(_profile!),
                  'profile': _profile,
                  'isEditMode': true,
                  'onlyPendingFields': true,
                },
              ).then((_) => _loadProfile(forceRefresh: true));
            },
          ),
          if (_profile!.completionPercentage < 100) ...[
            SizedBox(height: 1.2.h),
            Text(
              '💡 Tip: Add your partner expectations to reach 100% and attract 3x more interest!',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
                fontStyle: FontStyle.italic,
                fontSize: AppTypography.labelMedium,
                fontWeight: AppTypography.semiBold,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildAnimatedItem({required int index, required Widget child}) {
    final start = (index * 0.08).clamp(0.0, 1.0);
    final end = (0.5 + (index * 0.08)).clamp(0.0, 1.0);

    return SlideTransition(
      position: Tween<Offset>(begin: const Offset(0, 0.12), end: Offset.zero)
          .animate(CurvedAnimation(
              parent: _controller,
              curve: Interval(start, end, curve: Curves.easeOutCubic))),
      child: FadeTransition(
        opacity: Tween<double>(begin: 0.0, end: 1.0).animate(CurvedAnimation(
            parent: _controller,
            curve: Interval(start, end, curve: Curves.easeOut))),
        child: child,
      ),
    );
  }
}

/// 🎯 Tactile Micro-Interactive Card with Spring Physics on Tap
class _TactileMenuCard extends StatelessWidget {
  final Widget child;
  final VoidCallback onTap;

  const _TactileMenuCard({required this.child, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return TactilePressable(
      onTap: onTap,
      pressedScale: 0.965,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(18),
          onTap: onTap,
          child: child,
        ),
      ),
    );
  }
}

/// Animated, high-visibility Edit Profile button with subtle pulsing glow,
/// scale-spring press feedback, and gradient pill styling.
class _AnimatedEditProfileButton extends StatefulWidget {
  final VoidCallback onTap;

  const _AnimatedEditProfileButton({
    super.key,
    required this.onTap,
  });

  @override
  State<_AnimatedEditProfileButton> createState() =>
      _AnimatedEditProfileButtonState();
}

class _AnimatedEditProfileButtonState extends State<_AnimatedEditProfileButton>
    with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;
  late AnimationController _pressController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 0.95, end: 1.05).animate(
      CurvedAnimation(
        parent: _pulseController,
        curve: Curves.easeInOutSine,
      ),
    );

    _pressController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 120),
    );

    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.92).animate(
      CurvedAnimation(
        parent: _pressController,
        curve: Curves.easeInOut,
      ),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _pressController.dispose();
    super.dispose();
  }

  void _handleTapDown(TapDownDetails details) {
    _pressController.forward();
  }

  void _handleTapUp(TapUpDetails details) {
    _pressController.reverse();
    HapticFeedback.mediumImpact();
    widget.onTap();
  }

  void _handleTapCancel() {
    _pressController.reverse();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);

    return AnimatedBuilder(
      animation: Listenable.merge([_pulseAnimation, _scaleAnimation]),
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: Padding(
            padding: EdgeInsets.only(right: 3.w, top: 0.5.h, bottom: 0.5.h),
            child: GestureDetector(
              onTapDown: _handleTapDown,
              onTapUp: _handleTapUp,
              onTapCancel: _handleTapCancel,
              child: Container(
                padding:
                    EdgeInsets.symmetric(horizontal: 3.5.w, vertical: 0.8.h),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      theme.colorScheme.primary,
                      theme.colorScheme.primary.withValues(alpha: AppColors.opacity85),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: AppColors.opacity30),
                    width: 1.2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: theme.colorScheme.primary.withValues(
                        alpha: 0.35 * _pulseAnimation.value,
                      ),
                      blurRadius: 10 * _pulseAnimation.value,
                      spreadRadius: 1 * _pulseAnimation.value,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.22),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.edit_rounded,
                        color: Colors.white,
                        size: 14,
                      ),
                    ),
                    SizedBox(width: 1.8.w),
                    Text(
                      l10n?.edit ?? 'Edit',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: AppTypography.black,
                        fontSize: AppTypography.bodySmall,
                        letterSpacing: 0.3,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
