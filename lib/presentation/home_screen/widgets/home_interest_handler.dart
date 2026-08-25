import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:banjarabio/l10n/app_localizations.dart';
import 'package:banjarabio/core/models/profile_model.dart';
import 'package:banjarabio/core/repositories/share_repository.dart';
import 'package:banjarabio/core/repositories/usage_repository.dart';
import 'package:banjarabio/core/services/local_cache_service.dart';
import 'package:banjarabio/core/utils/app_feedback_service.dart';
import 'package:banjarabio/widgets/upgrade_dialog.dart';
import 'package:banjarabio/presentation/home_screen/widgets/guest_restricted_dialog.dart';
import 'package:banjarabio/widgets/smart_auth_gate.dart';

/// Interest confirmation dialog + execution logic extracted from
/// HomeScreen._handleInterest / _executeInterest.
class HomeInterestHandler {
  HomeInterestHandler._();

  /// Shows the interest confirmation dialog.
  static Future<void> show({
    required BuildContext context,
    required ProfileModel profile,
    required ShareRepository shareRepository,
    required UsageRepository usageRepository,
  }) async {
    if (LocalCacheService().isGuestMode()) {
      final result = await GuestRestrictedDialog.show(context, intent: SmartAuthIntent.expressInterest, profileName: profile.fullName);
      if (result != SmartAuthResult.success) return;
      if (!context.mounted) return;
    }

    HapticFeedback.mediumImpact();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(AppLocalizations.of(context)?.interestConfirmationTitle ?? 'Express Interest?'),
        content: Text(
          AppLocalizations.of(context)?.interestConfirmationMessage(profile.fullName) ??
              'This will share your profile with ${profile.fullName} and allow them to connect with you. Are you sure?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(AppLocalizations.of(context)?.cancel ?? 'Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              _execute(
                context: context,
                profile: profile,
                shareRepository: shareRepository,
                usageRepository: usageRepository,
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.primary,
              foregroundColor: Theme.of(context).colorScheme.onPrimary,
            ),
            child: Text(AppLocalizations.of(context)?.confirm ?? 'Confirm'),
          ),
        ],
      ),
    );
  }

  static Future<void> _execute({
    required BuildContext context,
    required ProfileModel profile,
    required ShareRepository shareRepository,
    required UsageRepository usageRepository,
  }) async {
    try {
      final canShareRes = await usageRepository.canShareProfile();

      await canShareRes.fold(
        onSuccess: (canShare) async {
          if (!canShare) {
            final remainingRes = await usageRepository.getRemainingShares();
            remainingRes.fold(
              onSuccess: (remaining) {
                if (context.mounted) {
                  UpgradeDialog.showShareLimit(context, remaining);
                }
              },
              onFailure: (error) => debugPrint('Error fetching remaining shares: $error'),
            );
            return;
          }

          final shareResponse = await shareRepository.shareProfile(
            sharedProfileId: profile.id,
            sharingMethod: 'in_app',
            recipientName: profile.fullName,
            recipientRelation: 'Interest',
            profileName: profile.fullName,
          );

          shareResponse.fold(
            onSuccess: (_) {
              if (context.mounted) {
                AppFeedback.showSuccess(
                  context,
                  AppLocalizations.of(context)?.interestShared(profile.fullName) ?? 'Interest shared with ${profile.fullName}!',
                );
              }
            },
            onFailure: (error) {
              if (context.mounted) {
                AppFeedback.showError(
                  context,
                  error,
                  contextTag: 'interest',
                );
              }
            },
          );
        },
        onFailure: (error) {
          if (context.mounted) {
            AppFeedback.showError(
              context,
              error,
              contextTag: 'interest',
            );
          }
        },
      );
    } catch (e) {
      if (context.mounted) {
        AppFeedback.showError(
          context,
          e,
          contextTag: 'interest',
        );
      }
    }
  }
}
