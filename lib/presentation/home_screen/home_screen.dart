import 'dart:async';

import 'package:banjarabio/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tutorial_coach_mark/tutorial_coach_mark.dart';
import 'package:sizer/sizer.dart';

import 'package:banjarabio/widgets/custom_bottom_bar.dart';
import 'package:banjarabio/presentation/home_screen/home_screen_initial_page.dart';
import 'package:banjarabio/core/services/analytics_service.dart';

import 'package:banjarabio/core/services/matchmaking_service.dart';
import 'package:banjarabio/core/services/startup_orchestrator.dart';
import 'package:banjarabio/core/services/local_cache_service.dart';
import 'package:banjarabio/core/services/guest_guided_tour_service.dart';
import 'package:banjarabio/core/utils/tour_keys.dart';
import 'package:banjarabio/notification/features/notification_bridge.dart';
import 'package:banjarabio/presentation/home_screen/widgets/guest_restricted_dialog.dart';
import 'package:banjarabio/notification/features/nudge_engine.dart';
import 'package:banjarabio/core/session_manager.dart';
import 'package:banjarabio/routes/app_routes.dart';
import 'package:banjarabio/core/repositories/auth_repository.dart';
import 'package:banjarabio/core/supabase_client.dart';


// 🚨 ANR FIX: Import tab screens directly for IndexedStack (no more Navigator)
import 'package:banjarabio/presentation/shared_profiles_screen/shared_profiles_screen.dart';
import 'package:banjarabio/presentation/melava_screen/melava_screen.dart';
import 'package:banjarabio/presentation/my_profile_screen/my_profile_screen.dart';
import 'package:banjarabio/presentation/settings_screen/settings_screen.dart';

import 'package:banjarabio/core/providers/home_tab_provider.dart';
import 'package:banjarabio/core/services/app_logger.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => HomeScreenState();
}

class HomeScreenState extends ConsumerState<HomeScreen> {
  bool _isBottomBarVisible = true;
  double get _bottomBarHeight => 6.5.h + MediaQuery.of(context).padding.bottom;
  Timer? _notificationTimer;
  Timer? _guestTourTimer;

  // 🚨 CRITICAL ANR FIX: DEFERRED BUILD GATE
  // The HomeScreen widget tree (SliverAppBar + filters + grid + bottom bar)
  // takes 2.27 seconds to build on the Vivo V2105, causing Signal 3 ANR.
  // By deferring the heavy build to AFTER the first frame renders (a lightweight
  // branded placeholder), we break the ANR window. Frame 1 renders in <16ms,
  // Frame 2+ builds the real UI after GPU/GC have settled.
  bool _isReady = false;

  // 🚨 LAZY TAB LOADING
  final Map<int, Widget> _builtTabs = {};

  Widget _getTabScreen(int index) {
    return _builtTabs.putIfAbsent(index, () {
      switch (index) {
        case 0: return const HomeScreenInitialPage();
        case 1: return const SharedProfilesScreen();
        case 2: return const MelavaScreen();
        case 3: return const MyProfileScreen();
        case 4: return const SettingsScreen();
        default: return const SizedBox.shrink();
      }
    });
  }

  @override
  void initState() {
    super.initState();

    // 🚨 DEFERRED BUILD: Wait for first frame to paint the lightweight placeholder,
    // then allow the heavy widget tree to be built on subsequent frames.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) setState(() => _isReady = true);
    });

    // Initialize Real-time Match Listener (staged by Orchestrator)
    // 🧬 SIGNAL 3 FIX: Moved from BACKGROUND to IDLE phase.
    // Realtime connections are non-critical for the first 20 seconds
    // and can cause thread starvation if initialized during peak UI load.
    StartupOrchestrator().registerTask(StartupPhase.idle, () async {
      if (!mounted) return;
      // 🧊 YIELD: Stagger matchmaking after other IDLE tasks (Firebase/Ads)
      await Future.delayed(const Duration(milliseconds: 500));
      if (!mounted) return;
      
      MatchmakingService().initializeRealtime();
      // Log Active Use (Home Screen View)
      AnalyticsService.logScreenView('home_screen');
      
      // Guest Tour Logic
      _checkAndStartGuestTour();
    }, name: 'Matchmaking & Analytics');

    // Evaluate and schedule daily Mass-Market subscription nudge in background phase
    StartupOrchestrator().registerTask(StartupPhase.background, () async {
      if (!mounted) return;
      if (SessionManager.instance.isLoggedIn && !LocalCacheService().isGuestMode()) {
        final isPremium = SessionManager.instance.isPremium ||
            (SessionManager.instance.currentProfile?.isPremium ?? false);
        await NudgeEngine().scheduleDailyMassMarketNudge(isPremium: isPremium);
      }
    }, name: 'Mass-Market Daily Nudge');


    // 🔔 NOTIFICATION PERMISSION: Ask logged-in users for notification permission
    // after a short delay to avoid overwhelming the user on first load.
    if (!LocalCacheService().isGuestMode()) {
      _notificationTimer = Timer(const Duration(seconds: 3), () {
        if (!mounted) return;
        NotificationBridge().askPermissionInterstitially(context);
      });
    }
  }

  void _checkAndStartGuestTour() {
    final cache = LocalCacheService();
    if (cache.isGuestMode() && !cache.isTourStageCompleted(TourStage.homeScreen.name)) {
      // Small delay to ensure UI is settled
      _guestTourTimer = Timer(const Duration(milliseconds: 1500), () {
        if (!mounted) return;
        _startFullTour();
      });
    }
  }

  void _startFullTour() {
    final tourService = ref.read(guestTourProvider);
    tourService.startTour(
      context,
      stage: TourStage.homeScreen,
      targets: [
        TargetFocus(
          identify: 'location',
          keyTarget: TourKeys.locationKey,
          contents: [
            TargetContent(
              builder: (context, controller) => Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                   Text(
                    AppLocalizations.of(context)?.tourLocationTitle ?? 'Select Location',
                    style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 20),
                  ),
                  const SizedBox(height: 10),
                   Text(
                    AppLocalizations.of(context)?.tourLocationDesc ?? 'Filter profiles by State, District, or Taluka.',
                    style: const TextStyle(color: Colors.white),
                  ),
                ],
              ),
            ),
          ],
        ),
        TargetFocus(
          identify: 'search',
          keyTarget: TourKeys.searchKey,
          contents: [
            TargetContent(
              builder: (context, controller) => Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                   Text(
                    AppLocalizations.of(context)?.tourSearchTitle ?? 'Search Profiles',
                    style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 20),
                  ),
                  const SizedBox(height: 10),
                   Text(
                    AppLocalizations.of(context)?.tourSearchDesc ?? 'Search by name or education.',
                    style: const TextStyle(color: Colors.white),
                  ),
                ],
              ),
            ),
          ],
        ),
        TargetFocus(
          identify: 'chat',
          keyTarget: TourKeys.chatKey,
          contents: [
            TargetContent(
              builder: (context, controller) => Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                   Text(
                    AppLocalizations.of(context)?.tourChatTitle ?? 'Messages & Chat',
                    style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 20),
                  ),
                  const SizedBox(height: 10),
                   Text(
                    AppLocalizations.of(context)?.tourChatDesc ?? 'View your conversations here.',
                    style: const TextStyle(color: Colors.white),
                  ),
                ],
              ),
            ),
          ],
        ),
        TargetFocus(
          identify: 'filter',
          keyTarget: TourKeys.filterKey,
          contents: [
            TargetContent(
              builder: (context, controller) => Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                   Text(
                    AppLocalizations.of(context)?.tourFilterTitle ?? 'Advanced Filters',
                    style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 20),
                  ),
                  const SizedBox(height: 10),
                   Text(
                    AppLocalizations.of(context)?.tourFilterDesc ?? 'Filter by Age, Education, or Profession.',
                    style: const TextStyle(color: Colors.white),
                  ),
                ],
              ),
            ),
          ],
        ),
        TargetFocus(
          identify: 'whatsapp',
          keyTarget: TourKeys.whatsappKey,
          contents: [
            TargetContent(
              builder: (context, controller) => Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                   Text(
                    AppLocalizations.of(context)?.tourWhatsappTitle ?? 'WhatsApp Support',
                    style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 20),
                  ),
                  const SizedBox(height: 10),
                   Text(
                    AppLocalizations.of(context)?.tourWhatsappDesc ?? 'Contact admin directly for help.',
                    style: const TextStyle(color: Colors.white),
                  ),
                ],
              ),
            ),
          ],
        ),
        TargetFocus(
          identify: 'instagram',
          keyTarget: TourKeys.instagramKey,
          contents: [
            TargetContent(
              builder: (context, controller) => Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                   Text(
                    AppLocalizations.of(context)?.tourInstagramTitle ?? 'Follow Us',
                    style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 20),
                  ),
                  const SizedBox(height: 10),
                   Text(
                    AppLocalizations.of(context)?.tourInstagramDesc ?? 'See daily success stories.',
                    style: const TextStyle(color: Colors.white),
                  ),
                ],
              ),
            ),
          ],
        ),
        TargetFocus(
          identify: 'home_tab',
          keyTarget: TourKeys.homeTabKey,
          contents: [
            TargetContent(
              align: ContentAlign.top,
              builder: (context, controller) => Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                   Text(
                    AppLocalizations.of(context)?.tourBottomHome ?? 'Home Feed',
                    style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 20),
                  ),
                  const SizedBox(height: 10),
                   Text(
                    AppLocalizations.of(context)?.tourBottomHomeDesc ?? 'Explore verified profiles.',
                    style: const TextStyle(color: Colors.white),
                  ),
                ],
              ),
            ),
          ],
        ),
        TargetFocus(
          identify: 'shared_tab',
          keyTarget: TourKeys.sharedTabKey,
          contents: [
            TargetContent(
              align: ContentAlign.top,
              builder: (context, controller) => Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                   Text(
                    AppLocalizations.of(context)?.tourBottomShared ?? 'Shared Profiles',
                    style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 20),
                  ),
                  const SizedBox(height: 10),
                   Text(
                    AppLocalizations.of(context)?.tourBottomSharedDesc ?? 'See your incoming/outgoing shares.',
                    style: const TextStyle(color: Colors.white),
                  ),
                ],
              ),
            ),
          ],
        ),
        TargetFocus(
          identify: 'profile_tab',
          keyTarget: TourKeys.profileTabKey,
          contents: [
            TargetContent(
              align: ContentAlign.top,
              builder: (context, controller) => Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                   Text(
                    AppLocalizations.of(context)?.tourBottomProfile ?? 'Your Profile',
                    style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 20),
                  ),
                  const SizedBox(height: 10),
                   Text(
                    AppLocalizations.of(context)?.tourBottomProfileDesc ?? 'Manage your biodata here.',
                    style: const TextStyle(color: Colors.white),
                  ),
                ],
              ),
            ),
          ],
        ),
        TargetFocus(
          identify: 'settings_tab',
          keyTarget: TourKeys.settingsTabKey,
          contents: [
            TargetContent(
              align: ContentAlign.top,
              builder: (context, controller) => Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                   Text(
                    AppLocalizations.of(context)?.tourBottomSettings ?? 'App Settings',
                    style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 20),
                  ),
                  const SizedBox(height: 10),
                   Text(
                    AppLocalizations.of(context)?.tourBottomSettingsDesc ?? 'Language and notifications.',
                    style: const TextStyle(color: Colors.white),
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
      onFinish: () {
        LocalCacheService().setTourStageCompleted(TourStage.homeScreen.name, true);
      },
      onSkip: () {
        LocalCacheService().setTourStageCompleted(TourStage.homeScreen.name, true);
      },
    );
  }

  @override
  void dispose() {
    // 🚨 CRITICAL FIX: Do NOT dispose the MatchmakingService singleton from a
    // widget lifecycle. removeAllChannels() blocks the main thread and causes
    // Signal 3 ANR, especially during Guest Mode back navigation.
    // MatchmakingService is app-scoped and should only be disposed at app exit.
    _notificationTimer?.cancel();
    _guestTourTimer?.cancel();
    super.dispose();
  }

  // Tab labels for debug logging
  static const List<String> _tabNames = [
    'Home', 'Shared', 'Melavas', 'Profile', 'Settings',
  ];

  Future<bool> _onWillPop() async {
    // 🚪 Single-click Back Auto-Logout for Relative Search & Guest users
    if (LocalCacheService().isGuestMode() || LocalCacheService().isRelativeBrowseMode()) {
      if (AppSupabaseClient.isAuthenticated) {
        await AuthRepository().signOut();
      }
      await LocalCacheService().clearRelativeBrowseSession();
      await LocalCacheService().setGuestMode(false);
      if (mounted) {
        Navigator.of(context, rootNavigator: true)
            .pushNamedAndRemoveUntil(AppRoutes.userTypeSelection, (route) => false);
      }
      return false;
    }

    if (ref.read(homeTabProvider) != 0) {
      ref.read(homeTabProvider.notifier).state = 0;
      setState(() {
        _isBottomBarVisible = true;
      });
      return false;
    }

    // Show exit confirmation
    final bool? shouldExit = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(AppLocalizations.of(context)?.exitApp ?? 'Exit App'),
        content: Text(AppLocalizations.of(context)?.areYouSureExit ?? 'Are you sure you want to exit the app?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(AppLocalizations.of(context)?.cancel ?? 'Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.primary,
              foregroundColor: Colors.white,
            ),
            child: Text(AppLocalizations.of(context)?.exit ?? 'Exit'),
          ),
        ],
      ),
    );
    return shouldExit ?? false;
  }

  @override
  Widget build(BuildContext context) {
    // 🚨 DEFERRED BUILD GATE: On the very first frame, render a trivial placeholder.
    // The full widget tree (SliverAppBar + filters + grid + bottom bar) takes 2.27s
    // on Vivo V2105, which triggers Signal 3 ANR. By rendering immediately with a
    // lightweight screen, we break the ANR window. The real UI builds on frame 2.
    if (!_isReady) {
      // 🚨 ZERO-GPU PLACEHOLDER: No CircularProgressIndicator!
      // CPI has an internal AnimationController that generates ~60
      // gralloc4 GPU allocations/sec on MediaTek, compounding the ANR.
      return const Scaffold(
        backgroundColor: Color(0xFF2A1B4D),
        body: SizedBox.shrink(),
      );
    }

    return PopScope(
      canPop: LocalCacheService().isGuestMode(),
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;
        final shouldPop = await _onWillPop();
        if (shouldPop && mounted) {
          // Since we can't pop the root from here if canPop is false,
          // we use SystemNavigator.pop() to exit the app
          SystemNavigator.pop();
        }
      },
      child: Scaffold(
        extendBody: true, // Allows body to flow behind the floating nav bar
        resizeToAvoidBottomInset: false,
        floatingActionButton: (LocalCacheService().isGuestMode() || ref.watch(homeTabProvider) != 3)
            ? null
            : AnimatedSlide(
                offset: _isBottomBarVisible ? Offset.zero : const Offset(0, 2),
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
                child: AnimatedOpacity(
                  opacity: _isBottomBarVisible ? 1.0 : 0.0,
                  duration: const Duration(milliseconds: 250),
                  child: Padding(
                    padding: EdgeInsets.only(bottom: 0.2.h),
                    child: const _BeautifulPdfFloatingActionButton(),
                  ),
                ),
              ),
        floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
        // 🚨 ANR FIX: IndexedStack keeps all tabs alive. No destruction/creation.
        body: NotificationListener<UserScrollNotification>(
          onNotification: (notification) {
            // Only react to scroll events from the active Home tab
            if (ref.read(homeTabProvider) == 0) {
              if (notification.direction == ScrollDirection.reverse &&
                  _isBottomBarVisible) {
                setState(() => _isBottomBarVisible = false);
              } else if (notification.direction == ScrollDirection.forward &&
                  !_isBottomBarVisible) {
                setState(() => _isBottomBarVisible = true);
              }
            }
            return true;
          },
          child: Stack(
            children: List.generate(5, (i) {
              final currentTab = ref.watch(homeTabProvider);
              // Only build tabs that have been visited (lazy)
              // Home tab (0) is always built on startup
              if (i == 0 || currentTab == i || _builtTabs.containsKey(i)) {
                return Offstage(
                  offstage: currentTab != i,
                  child: TickerMode(
                    enabled: currentTab == i,
                    child: _getTabScreen(i),
                  ),
                );
              }
              // Unvisited tabs: invisible placeholder
              return const SizedBox.shrink();
            }),
          ),
        ),
        // 🚨 ANR FIX: Plain SizedBox instead of AnimatedContainer.
        // AnimatedContainer has an internal AnimationController that
        // generates gralloc4 GPU allocations during transitions.
        bottomNavigationBar: SizedBox(
          height: _isBottomBarVisible ? _bottomBarHeight : 0,
          child: SingleChildScrollView(
            physics: const NeverScrollableScrollPhysics(),
            child: CustomBottomBar(
              currentIndex: ref.watch(homeTabProvider),
              onTap: (index) {
                final cache = LocalCacheService();
                if (index != 0 && (cache.isGuestMode() || cache.isRelativeBrowseMode())) {
                  // Relative browse & guest: only Home tab (0) allowed
                  // Allow Melavas tab (2) for relative browse users
                  if (cache.isRelativeBrowseMode() && index == 2) {
                    // Melavas allowed for relative browse
                  } else {
                    GuestRestrictedDialog.show(context);
                    return;
                  }
                }
                if (ref.read(homeTabProvider) != index) {
                  AppLogger.debug('HomeScreen', 'HomeScreen: Switching to ${_tabNames[index]} tab');
                  
                  // 🧬 PERFORMANCE: Removed unconditional imageCache.clear() here.
                  // Previously, EVERY tab switch nuked the entire image cache,
                  // forcing re-decode of all profile photos when returning to
                  // the Home tab (visible jank + redundant network requests).
                  //
                  // Memory pressure is now handled properly by:
                  // 1. PerformanceService.didHaveMemoryPressure() — OS-level pressure
                  // 2. GlobalWatchdog — emergency clear on severe frame blocks
                  // 3. Image cache caps (50 images / 20MB) set in PerformanceService
                  
                  ref.read(homeTabProvider.notifier).state = index;
                  setState(() {
                    // Always show bottom bar when switching tabs
                    _isBottomBarVisible = true;
                  });
                }
              },
            ),
          ),
        ),
      ),
    );
  }
}

/// 🚀 PREMIUM ANIMATED FAB: A gorgeous, custom-designed floating action button.
/// Includes a breathing outer ring pulse animation and a periodic diagonal
/// shimmer sweep to catch the user's eye without being obtrusive.
class _BeautifulPdfFloatingActionButton extends StatefulWidget {
  const _BeautifulPdfFloatingActionButton();

  @override
  State<_BeautifulPdfFloatingActionButton> createState() =>
      __BeautifulPdfFloatingActionButtonState();
}

class __BeautifulPdfFloatingActionButtonState
    extends State<_BeautifulPdfFloatingActionButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _pulseAnimation;
  late Animation<double> _shimmerAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3000),
    )..repeat();

    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.25).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
      ),
    );

    _shimmerAnimation = Tween<double>(begin: -1.0, end: 2.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.4, 1.0, curve: Curves.easeInOut),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final double pulseOpacity = _controller.value <= 0.6
            ? (1.0 - (_controller.value / 0.6)).clamp(0.0, 1.0)
            : 0.0;

        return Stack(
          alignment: Alignment.center,
          clipBehavior: Clip.none,
          children: [
            // Pulsing Background Ring (Breathing effect)
            Positioned(
              child: Transform.scale(
                scale: _pulseAnimation.value,
                child: Opacity(
                  opacity: pulseOpacity * 0.4,
                  child: Container(
                    width: 46.w,
                    height: 5.6.h,
                    decoration: BoxDecoration(
                      color: const Color(0xFFC62828),
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                ),
              ),
            ),
            // Main Button Container
            Container(
              width: 46.w,
              height: 5.6.h,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [
                    Color(0xFFC62828), // Deep red
                    Color(0xFFAD1457), // Rich magenta
                  ],
                ),
                borderRadius: BorderRadius.circular(30),
                border: Border.all(
                  color: const Color(0xFFFFD700).withValues(alpha: 0.5), // Premium gold border outline
                  width: 1.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFFC62828).withValues(alpha: 0.4),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(30),
                child: Stack(
                  children: [
                    // Shimmer Sweep
                    Positioned.fill(
                      child: Transform(
                        transform: Matrix4.translationValues(
                          _shimmerAnimation.value * 46.w,
                          0,
                          0,
                        ),
                        child: Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                Colors.white.withValues(alpha: 0.0),
                                Colors.white.withValues(alpha: 0.25),
                                Colors.white.withValues(alpha: 0.0),
                              ],
                              stops: const [0.3, 0.5, 0.7],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                          ),
                        ),
                      ),
                    ),
                    // Content
                    Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: () {
                          Navigator.pushNamed(context, '/biodata-editor');
                        },
                        borderRadius: BorderRadius.circular(30),
                        child: Center(
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(
                                Icons.picture_as_pdf_rounded,
                                color: Colors.white,
                                size: 20,
                              ),
                              SizedBox(width: 2.w),
                              Text(
                                'Download Biodata',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w900,
                                  fontSize: 11.5.sp,
                                  letterSpacing: 0.5,
                                  shadows: const [
                                    Shadow(
                                      color: Colors.black38,
                                      offset: Offset(0, 1),
                                      blurRadius: 2,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
