import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';

import 'package:banjarabio/core/utils/error_message_mapper.dart';

/// Centralized UI Feedback Service for BanjaraBio.
/// Provides consistent, polished, haptic-enabled Toasts and Snackbars across all screens.
class AppFeedback {
  AppFeedback._();

  /// Displays a localized, user-friendly error message from any raw exception.
  /// Haptics: medium impact.
  static void showError(
    BuildContext context,
    dynamic error, {
    String? contextTag,
    String? fallbackMessage,
    ToastGravity gravity = ToastGravity.BOTTOM,
    Toast toastLength = Toast.LENGTH_LONG,
  }) {
    final message = ErrorMessageMapper.getFriendlyMessage(
      context,
      error,
      contextTag: contextTag,
      fallbackMessage: fallbackMessage,
    );

    HapticFeedback.mediumImpact();

    final theme = Theme.of(context);
    Fluttertoast.showToast(
      msg: message,
      toastLength: toastLength,
      gravity: gravity,
      backgroundColor: theme.colorScheme.error,
      textColor: theme.colorScheme.onError,
      fontSize: 14.0,
    );
  }

  /// Displays a positive success toast.
  /// Haptics: light impact.
  static void showSuccess(
    BuildContext context,
    String message, {
    ToastGravity gravity = ToastGravity.BOTTOM,
    Toast toastLength = Toast.LENGTH_SHORT,
  }) {
    HapticFeedback.lightImpact();

    Fluttertoast.showToast(
      msg: message,
      toastLength: toastLength,
      gravity: gravity,
      backgroundColor: const Color(0xFF2E7D32), // Forest Green
      textColor: Colors.white,
      fontSize: 14.0,
    );
  }

  /// Displays a neutral/informative toast.
  /// Haptics: selection click.
  static void showInfo(
    BuildContext context,
    String message, {
    ToastGravity gravity = ToastGravity.BOTTOM,
    Toast toastLength = Toast.LENGTH_SHORT,
  }) {
    HapticFeedback.selectionClick();

    final theme = Theme.of(context);
    Fluttertoast.showToast(
      msg: message,
      toastLength: toastLength,
      gravity: gravity,
      backgroundColor: theme.colorScheme.inverseSurface,
      textColor: theme.colorScheme.onInverseSurface,
      fontSize: 14.0,
    );
  }

  /// Displays an alert/warning toast.
  /// Haptics: selection click.
  static void showWarning(
    BuildContext context,
    String message, {
    ToastGravity gravity = ToastGravity.BOTTOM,
    Toast toastLength = Toast.LENGTH_SHORT,
  }) {
    HapticFeedback.selectionClick();

    Fluttertoast.showToast(
      msg: message,
      toastLength: toastLength,
      gravity: gravity,
      backgroundColor: const Color(0xFFE65100), // Vibrant Amber
      textColor: Colors.white,
      fontSize: 14.0,
    );
  }
}
