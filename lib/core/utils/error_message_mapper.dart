import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:banjarabio/l10n/app_localizations.dart';

/// Centralized Error Message Mapper
/// Translates raw backend exceptions (Postgrest, Auth, Network) into clean,
/// user-friendly, localized copy while preventing raw database schema leaks.
class ErrorMessageMapper {
  ErrorMessageMapper._();

  /// Returns a user-friendly error message given a [BuildContext] and [error].
  static String getFriendlyMessage(
    BuildContext context,
    dynamic error, {
    String? contextTag,
    String? fallbackMessage,
  }) {
    final l10n = AppLocalizations.of(context);
    return getFriendlyMessageFromL10n(
      l10n,
      error,
      contextTag: contextTag,
      fallbackMessage: fallbackMessage,
    );
  }

  /// Convenience alias for [getFriendlyMessage] with optional [BuildContext].
  static String toUserFriendlyMessage(
    dynamic error, {
    BuildContext? context,
    String? contextTag,
    String? fallbackMessage,
  }) {
    final l10n = context != null ? AppLocalizations.of(context) : null;
    return getFriendlyMessageFromL10n(
      l10n,
      error,
      contextTag: contextTag,
      fallbackMessage: fallbackMessage,
    );
  }

  /// Returns a user-friendly error message given [AppLocalizations] and [error].
  static String getFriendlyMessageFromL10n(
    AppLocalizations? l10n,
    dynamic error, {
    String? contextTag,
    String? fallbackMessage,
  }) {
    if (kDebugMode) {
      debugPrint('[ErrorMessageMapper] Tag: $contextTag | Raw Error: $error');
    }

    if (error == null) {
      return fallbackMessage ?? l10n?.somethingWentWrong ?? 'Something went wrong. Please try again.';
    }

    // 1. Handle Postgrest / Supabase Database Exceptions
    if (error is PostgrestException) {
      final code = error.code?.trim();
      final rawMsg = error.message.toLowerCase();

      // 23505: Unique constraint violation (Duplicate key)
      if (code == '23505' || rawMsg.contains('unique constraint') || rawMsg.contains('duplicate key')) {
        if (rawMsg.contains('phone') || rawMsg.contains('idx_profiles_normalized_phone')) {
          return 'This mobile number is already registered with another account.';
        }
        if (contextTag == 'interest' || rawMsg.contains('shares') || rawMsg.contains('interest')) {
          return l10n?.alreadyExpressedInterest ?? 'You have already expressed interest in this profile.';
        }
        if (contextTag == 'shortlist' || rawMsg.contains('shortlist') || rawMsg.contains('bookmark')) {
          return l10n?.alreadyInShortlist ?? 'This profile is already in your shortlist.';
        }
        return l10n?.duplicateRecordError ?? 'This record already exists.';
      }

      // 42501: Insufficient privilege / RLS violation
      if (code == '42501' || rawMsg.contains('row-level security') || rawMsg.contains('permission denied')) {
        return l10n?.permissionDeniedError ?? 'You do not have permission to perform this action.';
      }

      // 23503: Foreign key violation / Not Found
      if (code == '23503' || rawMsg.contains('foreign key')) {
        return fallbackMessage ?? l10n?.somethingWentWrong ?? 'Requested item is no longer available.';
      }

      // PGRST116: 0 rows returned / Record not found
      if (code == 'PGRST116' || rawMsg.contains('0 rows')) {
        return fallbackMessage ?? l10n?.somethingWentWrong ?? 'Details could not be found.';
      }

      // PGRST301: JWT / Session Expired
      if (code == 'PGRST301' || rawMsg.contains('jwt expired')) {
        return 'Your session has expired. Please log in again.';
      }

      // Other Postgrest errors (never expose raw table/column names)
      return fallbackMessage ?? l10n?.somethingWentWrong ?? 'Unable to complete the request. Please try again.';
    }

    // 2. Handle Supabase Auth Exceptions
    if (error is AuthException) {
      final authCode = error.code?.toLowerCase();
      final authMsg = error.message.toLowerCase();

      if (authCode == 'user_already_exists' || authMsg.contains('already registered')) {
        return l10n?.alreadyHaveProfileLogin ?? 'An account with this information already exists.';
      }
      if (authCode == 'invalid_grant' || authMsg.contains('invalid login credentials')) {
        return l10n?.loginFailedRetry ?? 'Invalid login credentials. Please try again.';
      }
      if (authCode == 'email_not_confirmed') {
        return l10n?.emailVerification ?? 'Please verify your email address to continue.';
      }
      return error.message.isNotEmpty ? error.message : (fallbackMessage ?? l10n?.somethingWentWrong ?? 'Authentication failed.');
    }

    // 3. Handle Network & Connection Exceptions
    final errorString = error.toString().toLowerCase();
    if (error is SocketException ||
        error is TimeoutException ||
        errorString.contains('socketexception') ||
        errorString.contains('failed host lookup') ||
        errorString.contains('network is unreachable') ||
        errorString.contains('connection refused') ||
        errorString.contains('connection closed') ||
        errorString.contains('clientexception') ||
        errorString.contains('timeoutexception') ||
        errorString.contains('handshakeexception')) {
      return l10n?.networkErrorMessage ?? 'Please check your internet connection and try again.';
    }

    // 4. Handle specific domain string errors (including phone uniqueness and length)
    if (errorString.contains('invalid_phone') ||
        errorString.contains('10 digit') ||
        errorString.contains('10-digit')) {
      return l10n?.pleaseEnterAValid10DigitMobileNumber ?? 'Please enter a valid 10-digit mobile number';
    }

    if (errorString.contains('phone') &&
        (errorString.contains('already') ||
         errorString.contains('registered') ||
         errorString.contains('duplicate') ||
         errorString.contains('23505') ||
         errorString.contains('unique') ||
         errorString.contains('idx_profiles_normalized_phone'))) {
      return 'This mobile number is already registered with another account.';
    }

    // 5. Clean error string if it is a formatted String message without DB internals
    if (error is String && error.isNotEmpty) {
      if (!error.contains('PostgrestException') &&
          !error.contains('SocketException') &&
          !error.contains('Exception:') &&
          !error.contains('table') &&
          !error.contains('constraint')) {
        return error;
      }
    }

    // 6. Default Safe Fallback
    return fallbackMessage ?? l10n?.somethingWentWrong ?? 'Something went wrong. Please try again.';
  }
}
