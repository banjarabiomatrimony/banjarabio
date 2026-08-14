import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:banjarabio/core/models/backend_response.dart';
import 'package:banjarabio/core/session_manager.dart';
import 'package:banjarabio/core/supabase_client.dart' as app_supabase;
import 'package:banjarabio/notification/features/admin_notification_service.dart';
import 'package:banjarabio/core/repositories/photo_repository.dart';
import 'package:banjarabio/core/repositories/profile_repository.dart';
import 'package:banjarabio/core/services/app_logger.dart';
import 'package:banjarabio/core/services/local_cache_service.dart';

/// App-level auth status (Vendor Agnostic)
enum AppAuthStatus { initial, authenticated, unauthenticated }

/// Repository for authentication operations
class AuthRepository {
  final SupabaseClient? testClient;
  final SessionManager? testSessionManager;

  AuthRepository({this.testClient, this.testSessionManager});

  // Lazy getter - only accesses Supabase when actually needed
  SupabaseClient get _supabase => testClient ?? app_supabase.AppSupabaseClient.client;

  SessionManager get _sessionManager =>
      testSessionManager ?? SessionManager.instance;

  /// Sign in with Email and Password (for testing credentials)
  Future<BackendResponse<bool>> signInWithEmail(
    String email,
    String password,
  ) async {
    try {
      final response = await _supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );

      if (response.user != null) {
        await _saveSessionData(email, response.user!.id);
        return BackendResponse.success(true);
      }
      return BackendResponse.success(false);
    } catch (e, stack) {
      AppLogger.error('AuthRepository', 'AuthRepository.signInWithEmail error: $e');
      return BackendResponse.failure(
        e.toString(),
        stackTrace: stack,
        onRetry: () => signInWithEmail(email, password),
      );
    }
  }

  /// Sign up with Email and Password
  Future<BackendResponse<bool>> signUpWithEmail(
    String email,
    String password,
  ) async {
    try {
      final response = await _supabase.auth.signUp(
        email: email,
        password: password,
      );
      return BackendResponse.success(response.user != null);
    } catch (e) {
      return BackendResponse.failure(e.toString());
    }
  }

  /// Sign in with Google (Native ID Token Exchange — Zero Web Browser Popups)
  Future<BackendResponse<bool>> signInWithGoogle() async {
    try {
      if (kIsWeb) {
        await _supabase.auth.signInWithOAuth(OAuthProvider.google);
        return BackendResponse.success(true);
      }

      final webClientId = app_supabase.AppSupabaseClient.googleWebClientId;

      final isPlaceholder = webClientId.isEmpty ||
          webClientId == 'your_google_web_client_id' ||
          webClientId.contains('your_google');

      if (isPlaceholder) {
        AppLogger.error(
          'AuthRepository',
          'Google Sign-In failed: GOOGLE_WEB_CLIENT_ID is not configured in assets/env.json',
        );
        return BackendResponse.failure(
          'Google Web Client ID missing in assets/env.json. Please configure your Google OAuth Web Client ID.',
        );
      }

      try {
        final GoogleSignIn googleSignIn = GoogleSignIn(
          serverClientId: webClientId,
        );

        // Force-clear any previous stale cached Google Sign-In session
        try {
          await googleSignIn.signOut();
        } catch (_) {}

        final GoogleSignInAccount? googleUser = await googleSignIn.signIn();

        if (googleUser == null) {
          // User cancelled the Google Sign-In dialog
          return BackendResponse.success(false);
        }

        final GoogleSignInAuthentication googleAuth =
            await googleUser.authentication;
        final accessToken = googleAuth.accessToken;
        final idToken = googleAuth.idToken;

        if (idToken != null) {
          final AuthResponse response = await _supabase.auth.signInWithIdToken(
            provider: OAuthProvider.google,
            idToken: idToken,
            accessToken: accessToken,
          );

          if (response.user != null) {
            final email = response.user!.email ?? googleUser.email;
            await _saveSessionData(email, response.user!.id);
            return BackendResponse.success(true);
          }
        }
      } catch (nativeError) {
        AppLogger.warn(
          'AuthRepository',
          'Native Google Sign-In failed ($nativeError). Automatically falling back to Supabase Web OAuth flow.',
        );
        // 🚀 AUTOMATIC FALLBACK: Seamlessly fallback to Web OAuth so user is NEVER blocked by SHA-1 issues!
        final bool success = await _supabase.auth.signInWithOAuth(
          OAuthProvider.google,
          redirectTo: kIsWeb ? null : 'io.supabase.banjarabio://login-callback',
        );
        return BackendResponse.success(success);
      }

      return BackendResponse.success(false);
    } catch (e, stack) {
      AppLogger.error('AuthRepository', 'signInWithGoogle error: $e');

      String errorMessage = e.toString();
      if (errorMessage.contains('sign_in_failed') ||
          errorMessage.contains('10:')) {
        errorMessage =
            'Google Sign-In Failed (ApiException 10): Ensure SHA-1 fingerprint is registered in Google Cloud / Firebase and Web Client ID in assets/env.json is correct.';
      }

      return BackendResponse.failure(
        errorMessage,
        stackTrace: stack,
      );
    }
  }

  /// Sign in with Phone Number (OTP)
  Future<BackendResponse<void>> signInWithPhone(String phoneNumber) async {
    try {
      await _supabase.auth.signInWithOtp(phone: phoneNumber);
      return BackendResponse.success(null);
    } catch (e, stack) {
      return BackendResponse.failure(
        e.toString(),
        stackTrace: stack,
        onRetry: () => signInWithPhone(phoneNumber),
      );
    }
  }

  /// Verify Phone OTP
  Future<BackendResponse<bool>> verifyPhoneOtp(
    String phoneNumber,
    String token,
  ) async {
    try {
      final response = await _supabase.auth.verifyOTP(
        phone: phoneNumber,
        token: token,
        type: OtpType.sms,
      );

      if (response.user != null) {
        await _saveSessionData(phoneNumber, response.user!.id);

        // 🔔 Admin Alert: New user registration
        AdminNotificationService().notifyNewRegistration(
          userId: response.user!.id,
          phone: phoneNumber,
        );

        // 🔔 Admin Alert: First login
        AdminNotificationService().notifyFirstLogin(
          userId: response.user!.id,
          phone: phoneNumber,
        );

        return BackendResponse.success(true);
      }
      return BackendResponse.success(false);
    } catch (e, stack) {
      return BackendResponse.failure(
        e.toString(),
        stackTrace: stack,
        onRetry: () => verifyPhoneOtp(phoneNumber, token),
      );
    }
  }

  /// Verify Email OTP
  Future<BackendResponse<bool>> verifyEmailOtp(
    String email,
    String token,
  ) async {
    try {
      final response = await _supabase.auth.verifyOTP(
        email: email,
        token: token,
        type: OtpType.email,
      );

      if (response.user != null) {
        await _saveSessionData(email, response.user!.id);

        // 🔔 Admin Alert: First login via email
        AdminNotificationService().notifyFirstLogin(
          userId: response.user!.id,
          email: email,
        );

        return BackendResponse.success(true);
      }
      return BackendResponse.success(false);
    } catch (e) {
      return BackendResponse.failure(e.toString());
    }
  }

  /// Send Email OTP (for existing users to verify email)
  Future<BackendResponse<void>> sendEmailOtp(String email) async {
    try {
      await _supabase.auth.signInWithOtp(email: email);
      return BackendResponse.success(null);
    } catch (e) {
      return BackendResponse.failure(e.toString());
    }
  }

  /// Handle auth state changes (Vendor Agnostic Stream)
  Stream<AppAuthStatus> get authStateChanges {
    return _supabase.auth.onAuthStateChange.map((data) {
      final event = data.event;
      if (event == AuthChangeEvent.signedIn ||
          event == AuthChangeEvent.tokenRefreshed) {
        return AppAuthStatus.authenticated;
      } else if (event == AuthChangeEvent.signedOut) {
        return AppAuthStatus.unauthenticated;
      } else {
        return AppAuthStatus.initial;
      }
    });
  }

  /// Check if user is authenticated
  bool get isAuthenticated => app_supabase.AppSupabaseClient.isAuthenticated;

  /// Get current user ID
  String? get currentUserId => app_supabase.AppSupabaseClient.currentUserId;

  /// Check if user is signed in after OAuth redirect
  Future<BackendResponse<bool>> handleAuthCallback() async {
    try {
      final session = _supabase.auth.currentSession;
      final user = _supabase.auth.currentUser;

      if (session != null && user != null) {
        // Save session data
        final email = user.email ?? '';
        await _saveSessionData(email, user.id);

        // 🔔 Admin Alert: First login via OAuth
        AdminNotificationService().notifyFirstLogin(
          userId: user.id,
          email: email.isNotEmpty ? email : null,
        );

        return BackendResponse.success(true);
      }
      return BackendResponse.success(false);
    } catch (e) {
      return BackendResponse.failure(e.toString());
    }
  }

  /// Save session data after successful login
  Future<void> _saveSessionData(String email, String userId) async {
    await _sessionManager.setLoggedIn(true);
    await _sessionManager.setEmail(email);
    await _sessionManager.setUserId(userId);
    await _sessionManager.setLastLoginTime(DateTime.now());

    // Get user token from Supabase
    final session = _supabase.auth.currentSession;
    if (session != null) {
      await _sessionManager.setUserToken(session.accessToken);
    }
  }

  /// Delete own account and all data
  Future<BackendResponse<void>> deleteAccount() async {
    try {
      final userId = currentUserId;
      if (userId == null) {
        return BackendResponse.failure('User not authenticated');
      }

      // Migration-Ready Deletion Logic:
      // 1. Delete Photos (Storage + DB)
      final photoRepo = PhotoRepository();
      // Need profile ID for photos.
      final profileRepo = ProfileRepository();
      final profileRes = await profileRepo.getOwnProfile();

      await profileRes.fold(
        onSuccess: (profile) async {
          if (profile != null) {
            await photoRepo.deleteAllPhotos(profile.id);
            // 2. Delete Profile Data
            await profileRepo.deleteProfile();
          }
        },
        onFailure: (error) async {
          AppLogger.error('AuthRepository', 'Error fetching profile during deletion: $error');
        },
      );

      // 3. Notify admin before signing out
      AdminNotificationService().notifyAccountDeleted(
        userId: userId,
        name: profileRes.data?.fullName,
        phone: profileRes.data?.phoneNumber,
      );

      // 4. Delete from Auth
      await signOut();
      return BackendResponse.success(null);
    } catch (e) {
      AppLogger.error('AuthRepository', 'AuthRepository.deleteAccount: Error = $e');
      return BackendResponse.failure(e.toString());
    }
  }

  /// Sign out
  Future<BackendResponse<void>> signOut() async {
    try {
      await _supabase.auth.signOut();
      await _sessionManager.clearSession();
      try {
        SessionManager.instance.setCurrentProfile(null);
        await LocalCacheService().clearOwnProfile();
        await LocalCacheService().clearRelativeBrowseSession();
        await LocalCacheService().setGuestMode(false);
        await LocalCacheService().clearHomeFeed();
      } catch (cacheErr) {
        AppLogger.warn('AuthRepository', 'LocalCache clear during signOut bypassed: $cacheErr');
      }
      return BackendResponse.success(null);
    } catch (e) {
      AppLogger.error('AuthRepository', 'AuthRepository.signOut: Error = $e');
      return BackendResponse.failure(e.toString());
    }
  }

  /// Refresh session
  Future<BackendResponse<void>> refreshSession() async {
    try {
      await _supabase.auth.refreshSession();
      return BackendResponse.success(null);
    } catch (e) {
      // If refresh fails, clear session
      await _sessionManager.clearSession();
      return BackendResponse.failure(e.toString());
    }
  }
}
