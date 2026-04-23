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

// 🚨 ANR FIX: Import tab screens directly for IndexedStack (no more Navigator)
import 'package:banjarabio/presentation/shared_profiles_screen/shared_profiles_screen.dart';
import 'package:banjarabio/presentation/my_profile_screen/my_profile_screen.dart';
import 'package:banjarabio/presentation/settings_screen/settings_screen.dart';

import 'package:banjarabio/core/providers/home_tab_provider.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => HomeScreenState();
}

class HomeScreenState extends ConsumerState<HomeScreen> {
  bool _isBottomBarVisible = true;
  double get _bottomBarHeight => 13.h;
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
        case 2: return const MyProfileScreen();
        case 3: return const SettingsScreen();
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
    'Home', 'Shared', 'Profile', 'Settings',
  ];

  Future<bool> _onWillPop() async {
    // If in Guest Mode, allow popping immediately to return to OnboardingSelectionScreen
    if (LocalCacheService().isGuestMode()) {
      return true;
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
            children: List.generate(4, (i) {
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
                if (index != 0 && LocalCacheService().isGuestMode()) {
                  GuestRestrictedDialog.show(context);
                  return;
                }
                if (ref.read(homeTabProvider) != index) {
                  debugPrint('HomeScreen: Switching to ${_tabNames[index]} tab');
                  
                  // 🔥 AGGRESSIVELY CLEAR IMAGE CACHE ON TAB SWITCH TO PREVENT VIVO OOM AND RESOURCE ID CRASHES
                  PaintingBinding.instance.imageCache.clear();
                  PaintingBinding.instance.imageCache.clearLiveImages();
                  
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
