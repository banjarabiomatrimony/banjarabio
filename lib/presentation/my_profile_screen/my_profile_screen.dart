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
import 'package:banjarabio/widgets/shimmer_widget.dart';
import 'package:banjarabio/widgets/app_logo_image.dart';
import 'package:banjarabio/widgets/glassmorphism_container.dart';
import 'package:banjarabio/presentation/my_profile_screen/widgets/vouch_dashboard_card.dart';
import 'package:banjarabio/core/services/share_service.dart';
import 'package:banjarabio/core/services/app_logger.dart';
import 'package:banjarabio/core/constants/app_typography.dart';

/// My Profile Screen - View and edit own profile
class MyProfileScreen extends ConsumerStatefulWidget {
  const MyProfileScreen({super.key});

  @override
  ConsumerState<MyProfileScreen> createState() => _MyProfileScreenState();
}

class _MyProfileScreenState extends ConsumerState<MyProfileScreen>
    with SingleTickerProviderStateMixin {
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
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 850));
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
      AppLogger.debug('MyProfileScreen', 'MyProfileScreen: Loading profile and subscription...');

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
            AppLogger.error('MyProfileScreen', 'MyProfileScreen: Trust Score fatal error caught: $e');
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
            AppLogger.error('MyProfileScreen', 'MyProfileScreen: Subscription fatal error caught: $e');
          }

          if (mounted) {
            setState(() {
              _profile = profile;
              _subscription = subscription;
              _trustScore = trustScore;
              _isLoading = false;
            });
            _controller.forward(from: 0.0);
            // Start tour after profile loads and UI settles
            WidgetsBinding.instance.addPostFrameCallback((_) {
              _checkAndStartTour();
            });
          }
        },
        onFailure: (error) {
          AppLogger.error('MyProfileScreen', 'MyProfileScreen: Error loading profile: $error');
          if (mounted) {
            setState(() {
              _errorMessage = AppLocalizations.of(context)?.failedToLoadProfileError(error.toString()) ?? 'Failed to load profile: $error';
              _isLoading = false;
            });
          }
        },
      );
    } catch (e) {
      AppLogger.error('MyProfileScreen', 'MyProfileScreen: Critical error loading profile: $e');
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
    _controller.dispose();
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
    AppLogger.debug('MyProfileScreen', 'MyProfileScreen: build() started');
    late ThemeData theme;
    try {
      theme = Theme.of(context);
    } catch (e) {
      AppLogger.error('MyProfileScreen', 'MyProfileScreen: Error getting theme: $e');
      theme = ThemeData.light(); // Fallback
    }

    if (_profile != null) {
      debugPrint(
        'MyProfileScreen building with profile: ${_profile!.fullName}',
      );
      AppLogger.debug('MyProfileScreen', 'Profile Photos count: ${_profile!.photos.length}');
      AppLogger.debug('MyProfileScreen', 'Profile ID: ${_profile!.id}');
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

    AppLogger.debug('MyProfileScreen', 'MyProfileScreen: Building Scaffold');
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
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: AppTypography.bodyLarge),
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
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: AppTypography.bodyLarge),
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
                        fontWeight: FontWeight.w900,
                        color: theme.colorScheme.onSurface,
                        fontSize: AppTypography.headingSmall,
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
                            size: 18,
                          ),
                          label: Text(
                            AppLocalizations.of(context)?.edit ?? 'Edit',
                            style: theme.textTheme.labelLarge?.copyWith(
                              color: theme.colorScheme.primary,
                              fontWeight: FontWeight.bold,
                              fontSize: AppTypography.bodyMedium,
                            ),
                          ),
                        ),
                    ],
                  ),
                  SliverToBoxAdapter(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildAnimatedItem(
                          index: 0,
                          child: _buildProfileDashboardCard(theme),
                        ),

                        // 🚀 HERO CTA: Primary entry point for Biodata PDF download.
                        // Placed above Quick Actions so it's the FIRST action users see.
                        // Addresses UX friction: feature was buried 4+ taps deep.
                        _buildAnimatedItem(
                          index: 1,
                          child: _safeBuild(
                            'BiodataHeroCTA',
                            () => _buildBiodataHeroCTA(theme),
                          ),
                        ),

                        _buildAnimatedItem(
                          index: 2,
                          child: _safeBuild(
                            'QuickActionsGrid',
                            () => _buildQuickActionsGrid(theme),
                          ),
                        ),

                        // Community Vouching Dashboard (Social Proof)
                        _buildAnimatedItem(
                          index: 3,
                          child: Padding(
                            padding: EdgeInsets.only(
                                bottom: 2.h, left: 4.w, right: 4.w),
                            child: _safeBuild(
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
                          ),
                        ),

                        // Staggered Detail Cards (Single Column)
                        _safeBuild(
                          'DetailsCards',
                          () => Column(
                            children: [
                              _buildAnimatedItem(
                                index: 4,
                                child: PersonalDetailsCardWidget(
                                  profileData: _profile!.toDisplayMap(),
                                  margin: EdgeInsets.only(
                                      bottom: 2.h, left: 4.w, right: 4.w),
                                ),
                              ),
                              _buildAnimatedItem(
                                index: 5,
                                child: EducationProfessionCardWidget(
                                  profileData: _profile!.toDisplayMap(),
                                  margin: EdgeInsets.only(
                                      bottom: 2.h, left: 4.w, right: 4.w),
                                ),
                              ),
                              _buildAnimatedItem(
                                index: 6,
                                child: LocationDetailsCardWidget(
                                  profileData: _profile!.toDisplayMap(),
                                  margin: EdgeInsets.only(
                                      bottom: 2.h, left: 4.w, right: 4.w),
                                ),
                              ),
                              _buildAnimatedItem(
                                index: 7,
                                child: FamilyBackgroundCardWidget(
                                  profileData: _profile!.toDisplayMap(),
                                  margin: EdgeInsets.only(
                                      bottom: 2.h, left: 4.w, right: 4.w),
                                ),
                              ),
                              _buildAnimatedItem(
                                index: 8,
                                child: ContactPreferencesCardWidget(
                                  profileData: _profile!.toDisplayMap(),
                                  margin: EdgeInsets.only(
                                      bottom: 2.h, left: 4.w, right: 4.w),
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
    AppLogger.debug('MyProfileScreen', 'MyProfileScreen: Building $label...');
    try {
      final widget = builder();
      AppLogger.debug('MyProfileScreen', 'MyProfileScreen: Built $label');
      return widget;
    } catch (e) {
      AppLogger.error('MyProfileScreen', 'MyProfileScreen: Error building $label: $e');
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
          fontSize: AppTypography.headingSmall, // Explicit large size
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
            fontSize: AppTypography.bodyLarge, // Explicit size
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

  Widget _buildProfileDashboardCard(ThemeData theme) {
    final primaryPhoto = _profile!.photos.firstWhere(
      (photo) => photo.isPrimary,
      orElse: () => _profile!.photos.isNotEmpty ? _profile!.photos.first : PhotoModel(id: '', profileId: '', storagePath: '', publicUrl: '', uploadedAt: DateTime.now()),
    );
    final photoUrl = primaryPhoto.publicUrl;
    final isVerified = _profile!.isVerified;
    final isPremium = _subscription?.planType != PlanType.free;

    return Container(
      margin: EdgeInsets.only(top: 1.5.h, bottom: 2.h, left: 4.w, right: 4.w),
      padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
      decoration: BoxDecoration(
        gradient: isPremium
            ? const LinearGradient(
                colors: [
                  Color(0xFFFFFDF0), // Premium cream-gold glow
                  Color(0xFFFFF8D0), 
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              )
            : null,
        color: isPremium ? null : theme.cardColor,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: isPremium
              ? const Color(0xFFD4AF37)
              : theme.colorScheme.primary.withValues(alpha: 0.12),
          width: 1.8,
        ),
        boxShadow: [
          BoxShadow(
            color: isPremium
                ? const Color(0xFFD4AF37).withValues(alpha: 0.08)
                : theme.colorScheme.primary.withValues(alpha: 0.04),
            blurRadius: 24,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. Prominent Trust & Verification Status Badge
          InkWell(
            onTap: () {
              Navigator.pushNamed(context, AppRoutes.trustScore)
                  .then((_) => _loadProfile());
            },
            borderRadius: BorderRadius.circular(14),
            child: Container(
              width: double.infinity,
              margin: EdgeInsets.only(bottom: 2.h),
              padding: EdgeInsets.symmetric(horizontal: 3.5.w, vertical: 1.2.h),
              decoration: BoxDecoration(
                color: isVerified
                    ? const Color(0xFFE8F5E9)
                    : const Color(0xFFFFF3E0),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: isVerified
                      ? const Color(0xFF81C784).withValues(alpha: 0.5)
                      : const Color(0xFFFFB74D).withValues(alpha: 0.5),
                  width: 1.2,
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    isVerified ? Icons.verified_user : Icons.gpp_maybe,
                    color: isVerified ? const Color(0xFF2E7D32) : const Color(0xFFE65100),
                    size: 20,
                  ),
                  SizedBox(width: 2.5.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          isVerified
                              ? '🛡️ PROFILE VERIFIED (सत्यापित प्रोफाइल)'
                              : '⚠️ PROFILE NOT VERIFIED (सत्यापित नहीं है)',
                          style: TextStyle(
                            color: isVerified ? const Color(0xFF1B5E20) : const Color(0xFFE65100),
                            fontWeight: FontWeight.w900,
                            fontSize: AppTypography.bodySmall,
                            letterSpacing: 0.3,
                          ),
                        ),
                        SizedBox(height: 0.2.h),
                        Text(
                          isVerified
                              ? 'This profile is verified for marriage matches.'
                              : 'Tap here to verify identity & build trust.',
                          style: TextStyle(
                            color: isVerified ? const Color(0xFF2E7D32) : const Color(0xFFD84315),
                            fontSize: AppTypography.labelMedium,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    Icons.chevron_right,
                    color: isVerified ? const Color(0xFF2E7D32) : const Color(0xFFE65100),
                    size: 18,
                  ),
                ],
              ),
            ),
          ),

          // 2. Avatar and Name info row
          Row(
            children: [
              // Beautiful Avatar Container
              Container(
                width: 18.w,
                height: 18.w,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isPremium
                        ? const Color(0xFFD4AF37) // Gold border for premium
                        : theme.colorScheme.primary.withValues(alpha: 0.8),
                    width: 2.5,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.06),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: ClipOval(
                  child: CustomImageWidget(
                    imageUrl: photoUrl,
                    width: double.infinity,
                    height: double.infinity,
                    fit: BoxFit.cover,
                    semanticLabel: 'My Profile Photo',
                  ),
                ),
              ),
              SizedBox(width: 4.w),
              // Name and display id column
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            _profile!.fullName,
                            style: theme.textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.w900,
                              fontSize: AppTypography.headingSmall,
                              color: theme.colorScheme.onSurface,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (isVerified) ...[
                          SizedBox(width: 1.5.w),
                          const Icon(
                            Icons.verified,
                            color: Color(0xFF2E7D32),
                            size: 18,
                          ),
                        ],
                      ],
                    ),
                    SizedBox(height: 0.4.h),
                    Text(
                      '${_profile!.surname} • ${_profile!.gotra ?? ""}',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                        fontWeight: FontWeight.w700,
                        fontSize: AppTypography.bodySmall,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: 0.6.h),
                    Row(
                      children: [
                        // User ID Badge
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 2.5.w, vertical: 0.5.h),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.primary.withValues(alpha: 0.08),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            _profile!.displayId,
                            style: TextStyle(
                              color: theme.colorScheme.primary,
                              fontWeight: FontWeight.w800,
                              fontSize: AppTypography.labelMedium,
                            ),
                          ),
                        ),
                        SizedBox(width: 2.w),
                        // Plan Badge
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 2.5.w, vertical: 0.5.h),
                          decoration: BoxDecoration(
                            color: isPremium
                                ? const Color(0xFFFCF8E3)
                                : Colors.grey[200],
                            borderRadius: BorderRadius.circular(6),
                            border: isPremium
                                ? Border.all(color: const Color(0xFFD4AF37).withValues(alpha: 0.4))
                                : null,
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              if (isPremium) ...[
                                const Icon(Icons.star, color: Color(0xFFD4AF37), size: 12),
                                SizedBox(width: 1.w),
                              ],
                              Text(
                                isPremium ? 'ROYAL PREMIUM' : 'FREE USER',
                                style: TextStyle(
                                  color: isPremium
                                      ? const Color(0xFFB8860B)
                                      : Colors.grey[700],
                                  fontWeight: FontWeight.w800,
                                  fontSize: AppTypography.labelMedium,
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
          
          Divider(height: 3.h, color: theme.dividerColor.withValues(alpha: 0.5)),

          // 3. Profile completeness progress tracker
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Profile Completion (तैयारी %)',
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                  color: theme.colorScheme.onSurface,
                  fontSize: AppTypography.bodySmall,
                ),
              ),
              Text(
                '${_profile!.completionPercentage}% Complete',
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w900,
                  color: theme.colorScheme.primary,
                  fontSize: AppTypography.bodyMedium,
                ),
              ),
            ],
          ),
          SizedBox(height: 1.h),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: _profile!.completionPercentage / 100,
              minHeight: 10,
              backgroundColor: theme.colorScheme.primary.withValues(alpha: 0.08),
              valueColor: AlwaysStoppedAnimation<Color>(theme.colorScheme.primary),
            ),
          ),
          if (_profile!.completionPercentage < 100) ...[
            SizedBox(height: 1.2.h),
            Text(
              '💡 Tip: Add your partner expectations to reach 100% and attract 3x more interest!',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
                fontStyle: FontStyle.italic,
                fontSize: AppTypography.labelMedium,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],

          SizedBox(height: 2.5.h),

          // 4. Analytics panel (Success milestones)
          Row(
            children: [
              Expanded(
                child: _buildStatItem(
                  theme,
                  icon: Icons.visibility_outlined,
                  value: '${_profile!.vouchCount * 12 + 45}',
                  label: 'Views (देखा)',
                  color: Colors.blue[700]!,
                ),
              ),
              SizedBox(width: 3.w),
              Expanded(
                child: _buildStatItem(
                  theme,
                  icon: Icons.verified_user_outlined,
                  value: '$_trustScore%',
                  label: 'Trust Score',
                  color: const Color(0xFF2E7D32),
                  onTap: () {
                    Navigator.pushNamed(context, AppRoutes.trustScore)
                        .then((_) => _loadProfile());
                  },
                ),
              ),
              SizedBox(width: 3.w),
              Expanded(
                child: _buildStatItem(
                  theme,
                  icon: Icons.people_outline_rounded,
                  value: '${_profile!.vouchCount}',
                  label: 'Vouches (गवाही)',
                  color: const Color(0xFFE65100),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// 🚀 HERO CTA: High-visibility biodata download button.
  /// Designed as the primary action on the profile screen — unmissable,
  /// bilingual, with a gradient background and subtle pulse animation.
  Widget _buildBiodataHeroCTA(ThemeData theme) {
    return Container(
      margin: EdgeInsets.only(bottom: 2.h, left: 4.w, right: 4.w),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            Navigator.pushNamed(context, AppRoutes.biodataEditor);
          },
          borderRadius: BorderRadius.circular(20),
          child: Ink(
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [
                  Color(0xFFC62828), // Deep red
                  Color(0xFFAD1457), // Rich magenta
                ],
              ),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFFC62828).withValues(alpha: 0.35),
                  blurRadius: 16,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 5.w, vertical: 2.h),
              child: Row(
                children: [
                  // Icon container with glass effect
                  Container(
                    width: 13.w,
                    height: 13.w,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const Icon(
                      Icons.picture_as_pdf_rounded,
                      color: Colors.white,
                      size: 28,
                    ),
                  ),
                  SizedBox(width: 4.w),
                  // Text content
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '📄 Download Biodata PDF',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w900,
                            fontSize: AppTypography.bodyLarge,
                            letterSpacing: 0.3,
                          ),
                        ),
                        SizedBox(height: 0.4.h),
                        Text(
                          'बायोडाटा डाउनलोड करा • Share on WhatsApp',
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.85),
                            fontWeight: FontWeight.w600,
                            fontSize: AppTypography.labelMedium,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Arrow indicator
                  Container(
                    padding: EdgeInsets.all(2.w),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.arrow_forward_rounded,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildQuickActionsGrid(ThemeData theme) {
    return Container(
      margin: EdgeInsets.only(bottom: 2.h, left: 4.w, right: 4.w),
      padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.5.h),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: theme.colorScheme.primary.withValues(alpha: 0.12),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.primary.withValues(alpha: 0.04),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Quick Actions (मुख्य कार्य)',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w900,
              fontSize: AppTypography.bodyLarge,
              color: theme.colorScheme.onSurface,
            ),
          ),
          SizedBox(height: 1.h),
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            padding: EdgeInsets.zero,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisSpacing: 3.w,
            mainAxisSpacing: 3.w,
            childAspectRatio: 1.2,
            children: [
              _buildActionTile(
                theme,
                icon: Icons.photo_camera_outlined,
                label: '📸 Upload Photos',
                subtitle: 'Add photos of candidate & family (फोटो डालें)',
                color: theme.colorScheme.primary,
                onTap: () async {
                  await Navigator.pushNamed(context, AppRoutes.photoManagement);
                  _loadProfile();
                },
              ),
              _buildActionTile(
                theme,
                icon: Icons.verified_user_outlined,
                label: '🛡️ Trust & Verify',
                subtitle: 'Upload ID card to get verification checkmark',
                color: const Color(0xFF2E7D32),
                onTap: () {
                  Navigator.pushNamed(context, AppRoutes.trustScore)
                      .then((_) => _loadProfile());
                },
              ),
              _buildActionTile(
                theme,
                icon: Icons.picture_as_pdf_outlined,
                label: '📄 Download Biodata',
                subtitle: 'Export & share biodata PDF on WhatsApp (बायोडाटा)',
                color: const Color(0xFFC62828),
                onTap: () {
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    if (context.mounted) {
                      Navigator.pushNamed(context, AppRoutes.biodataEditor);
                    }
                  });
                },
              ),
              _buildActionTile(
                theme,
                icon: Icons.bookmark_border_rounded,
                label: '❤️ Saved Matches',
                subtitle: 'View matches you have liked/saved (पसंदीदा)',
                color: const Color(0xFFE65100),
                onTap: () {
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    if (context.mounted) {
                      Navigator.pushNamed(context, AppRoutes.savedProfiles);
                    }
                  });
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionTile(
    ThemeData theme, {
    required IconData icon,
    required String label,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.2.h),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: color.withValues(alpha: 0.18),
            width: 1.2,
          ),
          boxShadow: [
            BoxShadow(
              color: color.withValues(alpha: 0.02),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: EdgeInsets.all(1.5.w),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.12),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, color: color, size: 20),
                ),
                const Spacer(),
                Icon(Icons.arrow_forward_rounded, color: color.withValues(alpha: 0.5), size: 14),
              ],
            ),
            SizedBox(height: 0.8.h),
            Text(
              label,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w900,
                color: theme.colorScheme.onSurface,
                fontSize: AppTypography.bodySmall,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            SizedBox(height: 0.2.h),
            Text(
              subtitle,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.8),
                fontSize: AppTypography.labelSmall,
                fontWeight: FontWeight.w600,
                height: 1.1,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(
    ThemeData theme, {
    required IconData icon,
    required String value,
    required String label,
    required Color color,
    VoidCallback? onTap,
  }) {
    final cardContent = Container(
      padding: EdgeInsets.symmetric(vertical: 1.5.h, horizontal: 2.w),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: color.withValues(alpha: 0.15),
        ),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 20),
          SizedBox(height: 0.8.h),
          Text(
            value,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w900,
              color: color,
              fontSize: AppTypography.bodyLarge,
            ),
          ),
          SizedBox(height: 0.2.h),
          Text(
            label,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
              fontWeight: FontWeight.w700,
              fontSize: AppTypography.labelMedium,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );

    if (onTap != null) {
      return InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: cardContent,
      );
    }
    return cardContent;
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
