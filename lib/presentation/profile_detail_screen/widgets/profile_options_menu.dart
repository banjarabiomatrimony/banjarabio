import 'package:flutter/material.dart';

import 'package:banjarabio/l10n/app_localizations.dart';
import 'package:banjarabio/core/repositories/profile_repository.dart';
import 'package:banjarabio/core/services/app_logger.dart';
import 'package:banjarabio/core/utils/app_feedback_service.dart';

/// Options menu (Block / Report) extracted from ProfileDetailScreen.
/// Handles _showOptionsMenu, _confirmBlock, _executeBlock,
/// _showReportDialog, and _executeReport.
class ProfileOptionsMenu {
  ProfileOptionsMenu._();

  /// Shows the bottom sheet with Block / Report options.
  static void show({
    required BuildContext context,
    required Map<String, dynamic>? profileData,
  }) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        final theme = Theme.of(context);
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: Icon(Icons.block, color: theme.colorScheme.error),
                title: Text(AppLocalizations.of(context)?.blockUser ?? 'Block User'),
                subtitle: Text(AppLocalizations.of(context)?.youWillNoLongerSeeThisProfile ?? 'You will no longer see this profile'),
                onTap: () {
                  Navigator.pop(context);
                  _confirmBlock(context: context, profileData: profileData);
                },
              ),
              ListTile(
                leading: const Icon(Icons.report, color: Colors.orange),
                title: Text(AppLocalizations.of(context)?.reportUser ?? 'Report User'),
                subtitle: Text(AppLocalizations.of(context)?.inappropriateContentOrFakeProfile ?? 'Inappropriate content or fake profile'),
                onTap: () {
                  Navigator.pop(context);
                  _showReportDialog(context: context, profileData: profileData);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  static void _confirmBlock({
    required BuildContext context,
    required Map<String, dynamic>? profileData,
  }) {
    showDialog(
      context: context,
      builder: (context) {
        final theme = Theme.of(context);
        return AlertDialog(
          title: Text(AppLocalizations.of(context)?.blockUser ?? 'Block User?'),
          content: Text(
            AppLocalizations.of(context)?.areYouSureYouWantToBlockThisUserYouWillN ??
                'Are you sure you want to block this user? You will not be able to see their profile again.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(AppLocalizations.of(context)?.cancel ?? 'Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                _executeBlock(context: context, profileData: profileData);
              },
              style: ElevatedButton.styleFrom(backgroundColor: theme.colorScheme.error),
              child: Text(AppLocalizations.of(context)?.block ?? 'Block'),
            ),
          ],
        );
      },
    );
  }

  static Future<void> _executeBlock({
    required BuildContext context,
    required Map<String, dynamic>? profileData,
  }) async {
    try {
      final userId = profileData?['userId'] ?? profileData?['user_id'];
      if (userId == null) return;

      final res = await ProfileRepository().blockUser(userId.toString());
      await res.fold(
        onSuccess: (_) async {
          if (context.mounted) {
            Navigator.pop(context); // Close profile detail
            AppFeedback.showSuccess(
              context,
              AppLocalizations.of(context)?.userBlockedSuccessfully ?? 'User blocked successfully',
            );
          }
        },
        onFailure: (error) async {
          if (context.mounted) {
            AppFeedback.showError(
              context,
              error,
              contextTag: 'block',
              fallbackMessage: AppLocalizations.of(context)?.failedToBlockUser(''),
            );
          }
        },
      );
    } catch (e) {
      if (context.mounted) {
        AppFeedback.showError(
          context,
          e,
          contextTag: 'block',
          fallbackMessage: AppLocalizations.of(context)?.failedToBlockUser(''),
        );
      }
    }
  }

  static void _showReportDialog({
    required BuildContext context,
    required Map<String, dynamic>? profileData,
  }) {
    final reasons = [
      AppLocalizations.of(context)?.fakeProfile ?? 'Fake Profile',
      AppLocalizations.of(context)?.inappropriatePhotos ?? 'Inappropriate Photos',
      AppLocalizations.of(context)?.abusiveBehavior ?? 'Abusive Behavior',
      AppLocalizations.of(context)?.solicitingMoney ?? 'Soliciting Money',
      AppLocalizations.of(context)?.other ?? 'Other',
    ];

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(AppLocalizations.of(context)?.reportUser ?? 'Report User'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: reasons
              .map(
                (reason) => ListTile(
                  title: Text(reason),
                  onTap: () {
                    Navigator.pop(context);
                    _executeReport(context: context, profileData: profileData, reason: reason);
                  },
                ),
              )
              .toList(),
        ),
      ),
    );
  }

  static Future<void> _executeReport({
    required BuildContext context,
    required Map<String, dynamic>? profileData,
    required String reason,
  }) async {
    try {
      final userId = profileData?['userId'] ?? profileData?['user_id'];
      if (userId == null) return;

      final res = await ProfileRepository().reportUser(
        reportedUserId: userId.toString(),
        reason: reason,
      );

      await res.fold(
        onSuccess: (_) async {
          if (context.mounted) {
            AppFeedback.showSuccess(
              context,
              AppLocalizations.of(context)?.reportSubmittedReview ?? 'Report submitted. Our team will review it within 24 hours.',
            );
          }
        },
        onFailure: (error) async {
          if (context.mounted) {
            AppFeedback.showError(
              context,
              error,
              contextTag: 'report',
              fallbackMessage: AppLocalizations.of(context)?.failedToSubmitReport(''),
            );
          }
        },
      );
    } catch (e) {
      AppLogger.error('ProfileOptionsMenu', 'Error reporting user: $e');
      if (context.mounted) {
        AppFeedback.showError(
          context,
          e,
          contextTag: 'report',
          fallbackMessage: AppLocalizations.of(context)?.failedToSubmitReport(''),
        );
      }
    }
  }
}
