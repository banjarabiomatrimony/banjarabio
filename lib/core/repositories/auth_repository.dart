import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:banjarabio/core/models/backend_response.dart';
import 'package:banjarabio/core/session_manager.dart';
import 'package:banjarabio/core/supabase_client.dart' as app_supabase;
import 'package:banjarabio/notification/features/admin_notification_service.dart';
import 'package:banjarabio/core/repositories/photo_repository.dart';
import 'package:banjarabio/core/repositories/profile_repository.dart';

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
      debugPrint('AuthRepository.signInWithEmail error: $e');
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

  /// Sign in with Google
  Future<BackendResponse<bool>> signInWithGoogle() async {
    try {
      // For web, use OAuth flow
      if (kIsWeb) {
        await _supabase.auth.signInWithOAuth(
          OAuthProvider.google,
          redirectTo: kIsWeb ? null : 'io.supabase.banjarabio://login-callback',
        );
        // OAuth redirects, so we return true and let the redirect handle it
        return BackendResponse.success(true);
      } else {
        // For mobile, use OAuth flow with redirect
        await _supabase.auth.signInWithOAuth(
          OAuthProvider.google,
          redirectTo: 'io.supabase.banjarabio://login-callback',
        );
        return BackendResponse.success(true);
      }
    } catch (e) {
      return BackendResponse.failure(e.toString());
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
          debugPrint('Error fetching profile during deletion: $error');
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
      debugPrint('AuthRepository.deleteAccount: Error = $e');
      return BackendResponse.failure(e.toString());
    }
  }

  /// Sign out
  Future<BackendResponse<void>> signOut() async {
    try {
      await _supabase.auth.signOut();
      await _sessionManager.clearSession();
      return BackendResponse.success(null);
    } catch (e) {
      debugPrint('AuthRepository.signOut: Error = $e');
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
