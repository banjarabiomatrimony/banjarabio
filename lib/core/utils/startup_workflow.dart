import 'package:flutter/material.dart';
import 'package:banjarabio/core/app_export.dart';
import 'package:banjarabio/core/config/admin_config.dart';
import 'package:banjarabio/core/repositories/profile_repository.dart';
import 'package:banjarabio/core/services/local_cache_service.dart';
import 'package:banjarabio/core/supabase_client.dart';
import 'package:banjarabio/core/services/startup_orchestrator.dart';

class StartupWorkflow {
  static final ProfileRepository _profileRepository = ProfileRepository();

  /// Centralized logic to determine where a user should go based on their
  /// authentication and profile status.
  static Future<void> navigateBasedOnStatus(BuildContext context) async {
    final isAuth = AppSupabaseClient.isAuthenticated;

    if (!isAuth) {
      // Not logged in -> Authentication
      if (context.mounted) {
        Navigator.of(context, rootNavigator: true)
            .pushReplacementNamed(AppRoutes.authentication);
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
            .pushReplacementNamed(AppRoutes.adminDashboard);
      }
      return;
    }

    // Profile check
    final profileRes = await _profileRepository.getOwnProfile();
    await profileRes.fold(
      onSuccess: (profile) async {
        if (!context.mounted) return;
        
        final hasProfile = profile != null;
        if (hasProfile) {
        // Role-based routing
        if (profile.role == 'staff' || profile.role == 'telecaller') {
          Navigator.of(context, rootNavigator: true)
              .pushReplacementNamed(AppRoutes.staffDashboard);
        } else {
          // Regular user → Home
          Navigator.of(context, rootNavigator: true)
              .pushReplacementNamed(AppRoutes.home);
        }
      } else {
        // No profile → Onboarding Selection
        Navigator.of(context, rootNavigator: true)
            .pushReplacementNamed(AppRoutes.onboardingSelection);
      }
    },
    onFailure: (error) {
      if (context.mounted) {
        Navigator.of(context, rootNavigator: true)
            .pushReplacementNamed(AppRoutes.authentication);
      }
    },
  );

  // 🚀 ADVANCE PHASES
  StartupOrchestrator().markInteractive();
  
  Future.delayed(const Duration(seconds: 8), () {
    StartupOrchestrator().markBackground();
  });

  Future.delayed(const Duration(seconds: 20), () {
    StartupOrchestrator().markIdle();
  });
}
}
