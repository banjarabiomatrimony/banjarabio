import 'package:flutter/material.dart';
import 'package:banjarabio/l10n/app_localizations.dart';
import 'package:banjarabio/core/app_export.dart';
import 'package:banjarabio/core/config/admin_config.dart';
import 'package:banjarabio/core/repositories/profile_repository.dart';
import 'package:banjarabio/core/services/local_cache_service.dart';
import 'package:banjarabio/core/supabase_client.dart';
import 'package:banjarabio/core/services/startup_orchestrator.dart';
import 'package:banjarabio/core/services/app_logger.dart';

import 'package:banjarabio/core/utils/app_feedback_service.dart';

class StartupWorkflow {
  static final ProfileRepository _profileRepository = ProfileRepository();

  /// Centralized logic to determine where a user should go based on their
  /// authentication and profile status.
  static Future<void> navigateBasedOnStatus(
    BuildContext context, {
    String? targetRouteOnNoProfile,
  }) async {
    // ─── PHASE ADVANCEMENT ──────────────────────────────────────────────
    // Trigger lifecycle phase transitions for ALL users (authenticated AND
    // guests). This guarantees Firebase, Crashlytics, Sentry, AdMob, and
    // background cleanup tasks initialise even if the user never logs in.
    // advanceToPhase is idempotent — duplicate calls are safe no-ops.
    _schedulePhaseAdvancement();

    // ─── NAVIGATION ROUTING ─────────────────────────────────────────────
    final isAuth = AppSupabaseClient.isAuthenticated;

    if (!isAuth) {
      // Not logged in -> User Type Selection Gateway Screen (Existing User vs New User)
      if (context.mounted) {
        Navigator.of(context, rootNavigator: true)
            .pushNamedAndRemoveUntil(AppRoutes.userTypeSelection, (route) => false);
      }
      return;
    }

    // Logged in -> Ensure guest mode is OFF
    await LocalCacheService().setGuestMode(false);

    final currentUser = AppSupabaseClient.currentUser;
    final userEmail = currentUser?.email?.toLowerCase() ?? '';

    // Admin check
    if (AdminConfig.isAdminEmail(userEmail)) {
      if (context.mounted) {
        Navigator.of(context, rootNavigator: true)
            .pushNamedAndRemoveUntil(AppRoutes.adminDashboard, (route) => false);
      }
      return;
    }

    // ── PATHWAY A: Relative Browse Mode ──
    // If the user is in relative browse mode (browsing for a relative),
    // route them directly to HomeScreen with pre-applied filters.
    // They skip biodata creation — they're browsing for someone else.
    if (LocalCacheService().isRelativeBrowseMode()) {
      final relativeIntent = LocalCacheService().getRelativeIntent();
      AppLogger.debug('StartupWorkflow', '🔍 Relative browse mode active: $relativeIntent');
      await LocalCacheService().setRelativeBrowseMode(true);

      // Async sync to Supabase for CRM and search analytics (fire-and-forget)
      if (relativeIntent != null) {
        final relation = (relativeIntent['relation'] ?? 'relative').toString();
        final targetGender = relativeIntent['target_gender']?.toString() ?? relativeIntent['targetGender']?.toString();
        final state = relativeIntent['state']?.toString();
        final district = relativeIntent['district']?.toString();
        _profileRepository.logBrowseIntent(
          relation: relation,
          targetGender: targetGender,
          state: state,
          district: district,
        );
      }

      if (context.mounted) {
        Navigator.of(context, rootNavigator: true)
            .pushNamedAndRemoveUntil(AppRoutes.home, (route) => false, arguments: relativeIntent);
      }
      return;
    }

    // Profile check
    try {
      final profileRes = await _profileRepository.getOwnProfile().timeout(
        const Duration(seconds: 10),
        onTimeout: () {
          AppLogger.error('StartupWorkflow', 'getOwnProfile timed out after 10s');
          return BackendResponse.failure('Profile fetch timed out');
        },
      );

      await profileRes.fold(
        onSuccess: (profile) async {
          if (!context.mounted) return;

          final hasProfile = profile != null;
          if (hasProfile) {
            // Identity Intelligence Toast feedback for existing profile detection
            final l10n = AppLocalizations.of(context);
            AppFeedback.showSuccess(
              context,
              l10n?.welcomeBackAccountFound ?? 'Welcome back! Your account has been found.',
            );

            // Role-based routing
            if (profile.role == 'volunteer' ||
                profile.role == 'staff' ||
                profile.role == 'telecaller') {
              Navigator.of(context, rootNavigator: true)
                  .pushNamedAndRemoveUntil(AppRoutes.staffDashboard, (route) => false);
            } else {
              // Regular user → Home
              Navigator.of(context, rootNavigator: true)
                  .pushNamedAndRemoveUntil(AppRoutes.home, (route) => false);
            }
          } else {
            // No profile:
            // - For cold launch / app reopen: default is AppRoutes.userTypeSelection (UserTypeSelectionScreen shows draft resume banner)
            // - For in-app signup/creation flow: targetRouteOnNoProfile is AppRoutes.biodataCreation
            final nextRoute = targetRouteOnNoProfile ?? AppRoutes.userTypeSelection;
            AppLogger.debug('StartupWorkflow', 'User authenticated but has no profile. Routing to $nextRoute.');
            Navigator.of(context, rootNavigator: true)
                .pushNamedAndRemoveUntil(nextRoute, (route) => false);
          }
        },
        onFailure: (error) async {
          AppLogger.error('StartupWorkflow', 'getOwnProfile error during startup: $error');
          if (!context.mounted) return;

          // 🌐 Graceful toast for connectivity issues
          AppFeedback.showWarning(
            context,
            '⚠️ Limited connection — showing cached data',
          );

          // 🛡️ CRITICAL AUTH LOOP FIX: User IS authenticated in Supabase.
          // Do NOT push AppRoutes.authentication, as that re-triggers authStateChanges -> infinite loop!
          final cachedJson = LocalCacheService().getOwnProfile();
          if (cachedJson != null && cachedJson.isNotEmpty) {
            final role = cachedJson['role']?.toString();
            if (role == 'volunteer' || role == 'staff' || role == 'telecaller') {
              Navigator.of(context, rootNavigator: true)
                  .pushNamedAndRemoveUntil(AppRoutes.staffDashboard, (route) => false);
            } else {
              Navigator.of(context, rootNavigator: true)
                  .pushNamedAndRemoveUntil(AppRoutes.home, (route) => false);
            }
          } else {
            // Default fallback for authenticated users without profile cache
            Navigator.of(context, rootNavigator: true)
                .pushNamedAndRemoveUntil(AppRoutes.home, (route) => false);
          }
        },
      );
    } catch (e) {
      AppLogger.error('StartupWorkflow', 'Unexpected error in navigateBasedOnStatus: $e');
      if (context.mounted) {
        Navigator.of(context, rootNavigator: true)
            .pushNamedAndRemoveUntil(AppRoutes.home, (route) => false);
      }
    }
  }

  // ─── PHASE SCHEDULING ───────────────────────────────────────────────
  // Separated into its own method so it is called exactly once per
  // startup flow, regardless of auth state or navigation outcome.
  // advanceToPhase is idempotent, so even if this is called multiple
  // times (e.g. after re-auth), the phases only execute once.
  static void _schedulePhaseAdvancement() {
    AppLogger.debug('StartupWorkflow', '🚀 Scheduling phase advancement…');

    // INTERACTIVE: first meaningful frame is on-screen
    StartupOrchestrator().markInteractive();

    // BACKGROUND: analytics, notifications, background syncs (2.5s later)
    Future.delayed(const Duration(milliseconds: 2500), () {
      StartupOrchestrator().markBackground();
    });

    // IDLE: heavy deferred init — Firebase, AdMob, isolates (5s later)
    Future.delayed(const Duration(milliseconds: 5000), () {
      StartupOrchestrator().markIdle();
    });
  }
}
