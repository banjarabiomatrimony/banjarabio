import 'dart:async';

import 'package:app_links/app_links.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:banjarabio/routes/app_routes.dart';
import 'package:banjarabio/core/services/local_cache_service.dart';
import 'package:banjarabio/core/services/app_logger.dart';

/// Service to handle deep linking (Universal Links & App Links)
class DeepLinkService {
  static final DeepLinkService _instance = DeepLinkService._internal();

  factory DeepLinkService() {
    return _instance;
  }

  DeepLinkService._internal();

  @visibleForTesting
  AppLinks? testAppLinks;
  @visibleForTesting
  SupabaseClient? testClient;
  @visibleForTesting
  NavigatorState? testNavigatorState;
  @visibleForTesting
  LocalCacheService? testCache;

  AppLinks get _appLinksInstance => testAppLinks ?? AppLinks();
  
  SupabaseClient? get _supabase {
    if (testClient != null) return testClient;
    try {
      return Supabase.instance.client;
    } catch (_) {
      return null;
    }
  }

  NavigatorState? get _navigatorState => testNavigatorState ?? _navigatorKey?.currentState;
  LocalCacheService get _cache => testCache ?? LocalCacheService();

  StreamSubscription<Uri>? _linkSubscription;
  GlobalKey<NavigatorState>? _navigatorKey;

  /// Callback to trigger rewards dialog on Home screen
  void Function()? onRewardsTriggered;

  /// Initialize deep linking with navigator key
  void init(GlobalKey<NavigatorState> navigatorKey) {
    _navigatorKey = navigatorKey;

    // Listen for new links
    _linkSubscription = _appLinksInstance.uriLinkStream.listen((uri) async {
      if (_navigatorKey != null) {
        await handleDeepLink(uri);
      }
    });
  }

  /// Check for initial link that might have started the app
  Future<void> checkInitialLink() async {
    await _initDeepLink();
  }

  /// Dispose subscription
  void dispose() {
    _linkSubscription?.cancel();
    _linkSubscription = null;
    _navigatorKey = null;
  }

  /// Handle initial link startup
  Future<void> _initDeepLink() async {
    try {
      final initialLink = await _appLinksInstance.getInitialLink();
      if (initialLink != null) {
        await handleDeepLink(initialLink);
      }
    } catch (e) {
      AppLogger.error('DeepLinkService', 'DeepLinkService: Initial link error: $e');
    }
  }

  Future<void> handleDeepLink(Uri? uri) async {
    if (uri == null) return;
    AppLogger.debug('DeepLinkService', 'DeepLinkService: Handling deep link: $uri');

    final path = uri.path;
    final queryParams = uri.queryParameters;

    // 💡 PRO TIP: Handle promo/referrer from query params globally (common for web redirects & Play Store referral links)
    final qPromo = queryParams['promo'] ?? queryParams['referrer'];
    if (qPromo != null) {
      if (qPromo.startsWith('profile/')) {
        final pid = qPromo.split('profile/').last;
        if (pid.isNotEmpty && pid != 'profile') {
          await _navigateToProfile(pid);
          return;
        }
      } else if (qPromo.startsWith('invite/')) {
        await _handleInvite(qPromo.split('invite/').last);
        return;
      } else if (qPromo.startsWith('promo/')) {
        await _handlePromo(qPromo.split('promo/').last);
        return;
      } else {
        await _handlePromo(qPromo);
      }
    }

    final isCustomScheme = uri.scheme == 'banjarabio';
    final isWebDomain = uri.host == 'banjarabio.vercel.app' ||
        uri.host == 'banjarabio.com' ||
        uri.host == 'www.banjarabio.com' ||
        uri.host == 'banjarabio.in' ||
        uri.host == 'www.banjarabio.in';

    // 1. Profile Routing
    // e.g. banjarabio://profile/123, banjarabio://profile?id=123, https://banjarabio.com/profile/123, https://banjarabio.com/profile?id=123
    if ((isCustomScheme && uri.host == 'profile') || (isWebDomain && path.startsWith('/profile')) || path.startsWith('/profile')) {
      String? profileId = queryParams['id'];
      if (profileId == null || profileId.isEmpty) {
        final segments = uri.pathSegments;
        if (segments.isNotEmpty) {
          profileId = segments.last;
        }
      }
      if (profileId != null && profileId.isNotEmpty && profileId != 'profile') {
        await _navigateToProfile(profileId);
        return;
      }
    }

    // 2. Invite/Referral Routing
    // e.g. banjarabio://invite/456, banjarabio://invite?id=456, https://banjarabio.com/invite/456, https://banjarabio.com/invite?id=456
    if ((isCustomScheme && uri.host == 'invite') || (isWebDomain && path.startsWith('/invite')) || path.startsWith('/invite')) {
      String? referralId = queryParams['id'] ?? queryParams['code'];
      if (referralId == null || referralId.isEmpty) {
        final segments = uri.pathSegments;
        if (segments.isNotEmpty) {
          referralId = segments.last;
        }
      }
      if (referralId != null && referralId.isNotEmpty && referralId != 'invite') {
        await _handleInvite(referralId);
        return;
      }
    }

    // 3. Promo Routing
    // e.g. banjarabio://promo/SAVE20, banjarabio://promo?code=SAVE20, https://banjarabio.com/promo/SAVE20, https://banjarabio.com/promo?code=SAVE20
    if ((isCustomScheme && uri.host == 'promo') || (isWebDomain && path.startsWith('/promo')) || path.startsWith('/promo')) {
      String? promoCode = queryParams['code'] ?? queryParams['id'];
      if (promoCode == null || promoCode.isEmpty) {
        final segments = uri.pathSegments;
        if (segments.isNotEmpty) {
          promoCode = segments.last;
        }
      }
      if (promoCode != null && promoCode.isNotEmpty && promoCode != 'promo') {
        await _handlePromo(promoCode);
        return;
      }
    }

    // 4. Rewards Routing
    // e.g. banjarabio://rewards, https://banjarabio.com/rewards
    if ((isCustomScheme && uri.host == 'rewards') || (isWebDomain && path.startsWith('/rewards')) || path.startsWith('/rewards')) {
      await _handleRewards();
      return;
    }

    // 5. Staff Dashboard Routing
    // e.g. banjarabio://staff-dashboard, https://banjarabio.com/staff-dashboard
    if ((isCustomScheme && uri.host == 'staff-dashboard') || (isWebDomain && path.startsWith('/staff-dashboard'))) {
      await _navigateDirectlyTo(AppRoutes.staffDashboard);
      return;
    }

    // 6. Admin Dashboard Routing
    // e.g. banjarabio://admin-dashboard, https://banjarabio.com/admin-dashboard
    if ((isCustomScheme && uri.host == 'admin-dashboard') || (isWebDomain && path.startsWith('/admin-dashboard'))) {
      await _navigateDirectlyTo(AppRoutes.adminDashboard);
      return;
    }

    // 7. Subscription Screen Routing
    // e.g. banjarabio://subscription, https://banjarabio.com/subscription, or path /subscription
    if ((isCustomScheme && uri.host == 'subscription') || (isWebDomain && path.startsWith('/subscription')) || path == '/subscription') {
      await _navigateDirectlyTo(AppRoutes.subscription);
      return;
    }
  }

  /// Navigate directly to a specific named route
  Future<void> _navigateDirectlyTo(String routeName) async {
    AppLogger.debug('DeepLinkService', 'DeepLinkService: Navigating directly to $routeName');

    final client = _supabase;
    if (client == null || client.auth.currentSession == null) {
      AppLogger.debug('DeepLinkService', 'DeepLinkService: Unauthenticated. Cannot navigate to $routeName.');
      return;
    }

    void navigate() {
      if (_navigatorState != null) {
        _navigatorState!.pushNamed(routeName);
      }
    }

    if (testNavigatorState != null) {
      navigate();
    } else {
      WidgetsBinding.instance.addPostFrameCallback((_) => navigate());
    }
  }

  /// Handle promo deep link
  Future<void> _handlePromo(String promoCode) async {
    AppLogger.debug('DeepLinkService', 'DeepLinkService: Handling promo code: $promoCode');
    await _cache.savePendingPromoCode(promoCode);
  }

  /// Handle rewards deep link
  Future<void> _handleRewards() async {
    AppLogger.debug('DeepLinkService', 'DeepLinkService: Handling rewards deep link');
    await _cache.savePendingRewardsFlag(true);
    
    if (onRewardsTriggered != null) {
      onRewardsTriggered!();
    }
  }

  /// Handle invite deep link
  Future<void> _handleInvite(String inviteId) async {
    AppLogger.debug('DeepLinkService', 'DeepLinkService: Handling invite ID: $inviteId');
    await _cache.savePendingReferralId(inviteId);
  }

  /// Navigate to profile detail screen
  Future<void> _navigateToProfile(String profileId) async {
    AppLogger.debug('DeepLinkService', 'DeepLinkService: Navigating to profile $profileId');

    final client = _supabase;
    if (client == null) {
      AppLogger.debug('DeepLinkService', 'DeepLinkService: Supabase not available. Deferring profile navigation.');
      await _cache.savePendingProfileId(profileId);
      return;
    }

    // 🧬 PRO SCALE: Check if user is authenticated.
    final hasSession = client.auth.currentSession != null;

    if (!hasSession) {
      debugPrint(
          'DeepLinkService: User not authenticated. Saving pending profile ID.');
      await _cache.savePendingProfileId(profileId);

      void navigateToAuth() {
        if (_navigatorState != null) {
          _navigatorState!.pushNamed(AppRoutes.authentication);
        }
      }

      if (testNavigatorState != null) {
        navigateToAuth();
      } else {
        try {
          WidgetsBinding.instance.addPostFrameCallback((_) => navigateToAuth());
        } catch (_) {
          navigateToAuth();
        }
      }
      return;
    }

    void navigate() {
      if (_navigatorState != null) {
        _navigatorState!.pushNamed(
          AppRoutes.profileDetail,
          arguments: profileId,
        );
      } else {
        AppLogger.debug('DeepLinkService', 'DeepLinkService: Navigator state is null');
      }
    }

    // In tests, we want to execute immediately to avoid WidgetsBinding race conditions
    if (testNavigatorState != null) {
      navigate();
    } else {
      try {
        WidgetsBinding.instance.addPostFrameCallback((_) => navigate());
      } catch (_) {
        navigate();
      }
    }
  }

  @visibleForTesting
  void reset() {
    _linkSubscription?.cancel();
    _linkSubscription = null;
    testAppLinks = null;
    testClient = null;
    testNavigatorState = null;
    testCache = null;
    _navigatorKey = null;
  }
}
