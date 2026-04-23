import 'dart:async';

import 'package:app_links/app_links.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:banjarabio/routes/app_routes.dart';
import 'package:banjarabio/core/services/local_cache_service.dart';

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
      debugPrint('DeepLinkService: Initial link error: $e');
    }
  }

  Future<void> handleDeepLink(Uri? uri) async {
    if (uri == null) return;
    debugPrint('DeepLinkService: Handling deep link: $uri');

    final path = uri.path;
    final queryParams = uri.queryParameters;

    // 💡 PRO TIP: Handle promo/referrer from query params globally (common for web redirects)
    final qPromo = queryParams['promo'] ?? queryParams['referrer'];
    if (qPromo != null) {
      if (qPromo.startsWith('invite/')) {
        await _handleInvite(qPromo.split('invite/').last);
      } else if (qPromo.startsWith('promo/')) {
        await _handlePromo(qPromo.split('promo/').last);
      } else {
        await _handlePromo(qPromo);
      }
    }

    // Standard URL: https://banjarabio.com/profile/123
    if (path.contains('/profile/')) {
      final profileId = path.split('/profile/').last;
      await _navigateToProfile(profileId);
      return;
    }

    // Standard URL: https://banjarabio.com/invite/456
    if (path.contains('/invite/')) {
      final referralId = path.split('/invite/').last;
      await _handleInvite(referralId);
      return;
    }

    // Standard URL: https://banjarabio.com/promo/SAVE20
    if (path.contains('/promo/')) {
      final promoCode = path.split('/promo/').last;
      await _handlePromo(promoCode);
      return;
    }

    // Custom Scheme: banjarabio://profile?id=789
    if (uri.scheme == 'banjarabio' && uri.host == 'profile') {
      final profileId = queryParams['id'];
      if (profileId != null) {
        await _navigateToProfile(profileId);
      }
      return;
    }

    // Custom Scheme: banjarabio://rewards
    if (uri.scheme == 'banjarabio' && uri.host == 'rewards') {
      await _handleRewards();
      return;
    }

    // Custom Scheme: banjarabio://promo?code=SAVE20
    if (uri.scheme == 'banjarabio' && uri.host == 'promo') {
      final promoCode = queryParams['code'];
      if (promoCode != null) {
        await _handlePromo(promoCode);
      }
      return;
    }

    // Direct Route matching
    if (path == '/staff-dashboard') {
      await _navigateDirectlyTo(AppRoutes.staffDashboard);
      return;
    }

    if (path == '/admin-dashboard') {
      await _navigateDirectlyTo(AppRoutes.adminDashboard);
      return;
    }
  }

  /// Navigate directly to a specific named route
  Future<void> _navigateDirectlyTo(String routeName) async {
    debugPrint('DeepLinkService: Navigating directly to $routeName');

    final client = _supabase;
    if (client == null || client.auth.currentSession == null) {
      debugPrint('DeepLinkService: Unauthenticated. Cannot navigate to $routeName.');
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
    debugPrint('DeepLinkService: Handling promo code: $promoCode');
    await _cache.savePendingPromoCode(promoCode);
  }

  /// Handle rewards deep link
  Future<void> _handleRewards() async {
    debugPrint('DeepLinkService: Handling rewards deep link');
    await _cache.savePendingRewardsFlag(true);
    
    if (onRewardsTriggered != null) {
      onRewardsTriggered!();
    }
  }

  /// Handle invite deep link
  Future<void> _handleInvite(String inviteId) async {
    debugPrint('DeepLinkService: Handling invite ID: $inviteId');
    await _cache.savePendingReferralId(inviteId);
  }

  /// Navigate to profile detail screen
  Future<void> _navigateToProfile(String profileId) async {
    debugPrint('DeepLinkService: Navigating to profile $profileId');

    final client = _supabase;
    if (client == null) {
      debugPrint('DeepLinkService: Supabase not available. Deferring profile navigation.');
      await _cache.savePendingProfileId(profileId);
      return;
    }

    // 🧬 PRO SCALE: Check if user is authenticated.
    final hasSession = client.auth.currentSession != null;

    if (!hasSession) {
      debugPrint(
          'DeepLinkService: User not authenticated. Saving pending profile ID.');
      await _cache.savePendingProfileId(profileId);
      return;
    }

    void navigate() {
      if (_navigatorState != null) {
        _navigatorState!.pushNamed(
          AppRoutes.profileDetail,
          arguments: profileId,
        );
      } else {
        debugPrint('DeepLinkService: Navigator state is null');
      }
    }

    // In tests, we want to execute immediately to avoid WidgetsBinding race conditions
    if (testNavigatorState != null) {
      navigate();
    } else {
      WidgetsBinding.instance.addPostFrameCallback((_) => navigate());
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
