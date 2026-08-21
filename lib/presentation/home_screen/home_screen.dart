import 'dart:async';

import 'package:banjarabio/l10n/app_localizations.dart';
import 'package:banjarabio/core/constants/app_typography.dart';
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
import 'package:banjarabio/core/services/biodata_preload_service.dart';
import 'package:banjarabio/routes/app_routes.dart';


import 'package:banjarabio/presentation/connect_screen/connect_screen.dart';
import 'package:banjarabio/presentation/biodata_pdf_screen/biodata_pdf_screen.dart';
import 'package:banjarabio/presentation/services_hub_screen/services_hub_screen.dart';
import 'package:banjarabio/presentation/settings_screen/settings_screen.dart';
import 'package:banjarabio/widgets/exit_confirmation_dialog.dart';

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
        case 1: return const ConnectScreen();
        case 2: return const BiodataPdfScreen();
        case 3: return const ServicesHubScreen();
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

    // ⚡ BIODATA BACKGROUND PREWARM: Preload candidate profile, template images,
    // and pre-compile default A4 Biodata PDF in background isolate right after first frame renders.
    StartupOrchestrator().registerTask(StartupPhase.interactive, () async {
      await Future.delayed(const Duration(milliseconds: 800));
      if (!mounted) return;
      await BiodataPreloadService.instance.preload();
    }, name: 'Biodata Background Preload');

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
                    style: TextStyle(fontWeight: AppTypography.bold, color: Colors.white, fontSize: AppTypography.headingLarge),
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
                    style: TextStyle(fontWeight: AppTypography.bold, color: Colors.white, fontSize: AppTypography.headingLarge),
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
          keyTarget: TourKeys.chatTabKey,
          contents: [
            TargetContent(
              builder: (context, controller) => Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                   Text(
                    AppLocalizations.of(context)?.tourChatTitle ?? 'Messages & Chat',
                    style: TextStyle(fontWeight: AppTypography.bold, color: Colors.white, fontSize: AppTypography.headingLarge),
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
                    style: TextStyle(fontWeight: AppTypography.bold, color: Colors.white, fontSize: AppTypography.headingLarge),
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
                    style: TextStyle(fontWeight: AppTypography.bold, color: Colors.white, fontSize: AppTypography.headingLarge),
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
                    style: TextStyle(fontWeight: AppTypography.bold, color: Colors.white, fontSize: AppTypography.headingLarge),
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
    'Home', 'Connect', 'Biodata', 'Services', 'Profile',
  ];

  Future<bool> _onWillPop() async {
    // 🔙 If user is on any non-Home tab (Connect, Biodata, Services, Menu), switch to Tab 0 (Home)
    if (ref.read(homeTabProvider) != 0) {
      ref.read(homeTabProvider.notifier).state = 0;
      setState(() {
        _isBottomBarVisible = true;
      });
      return false;
    }

    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);

    // 🚪 Relative Browse users: offer option to change search criteria or exit app without signing out
    if (LocalCacheService().isRelativeBrowseMode()) {
      final bool? shouldExit = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Text(l10n?.exitApp ?? 'Exit App'),
          content: Text(
            l10n?.changeCriteriaOrExitPrompt ??
                'Do you want to change your search options or exit the app?',
          ),
          actionsOverflowDirection: VerticalDirection.up,
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: Text(l10n?.cancel ?? 'No'),
            ),
            OutlinedButton(
              style: OutlinedButton.styleFrom(
                side: BorderSide(color: theme.colorScheme.primary),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              onPressed: () async {
                await LocalCacheService().clearRelativeBrowseSession();
                if (context.mounted) {
                  Navigator.of(context).pop(false);
                  Navigator.of(context, rootNavigator: true)
                      .pushNamedAndRemoveUntil(AppRoutes.userTypeSelection, (route) => false);
                }
              },
              child: Text(l10n?.changeOptionsCta ?? 'Change Options ✏️'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, true),
              style: ElevatedButton.styleFrom(
                backgroundColor: theme.colorScheme.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: Text(l10n?.exit ?? 'Yes, Exit'),
            ),
          ],
        ),
      );
      return shouldExit ?? false;
    }

    // 🚪 Unauthenticated Guest: return to user type selection
    if (LocalCacheService().isGuestMode()) {
      await LocalCacheService().setGuestMode(false);
      if (mounted) {
        Navigator.of(context, rootNavigator: true)
            .pushNamedAndRemoveUntil(AppRoutes.userTypeSelection, (route) => false);
      }
      return false;
    }

    // 🛑 Show animated exit confirmation popup for all users on Tab 0 (Home tab)
    return await ExitConfirmationDialog.show(context) ?? false;
  }

  @override
  Widget build(BuildContext context) {
    // 🚨 DEFERRED BUILD GATE: On the very first frame, render a trivial placeholder.
    if (!_isReady) {
      return const Scaffold(
        backgroundColor: Color(0xFF2A1B4D),
        body: SizedBox.shrink(),
      );
    }

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;
        final shouldPop = await _onWillPop();
        if (shouldPop && mounted) {
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
                  // Allow Melavas tab (3) for relative browse users
                  if (cache.isRelativeBrowseMode() && index == 3) {
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
