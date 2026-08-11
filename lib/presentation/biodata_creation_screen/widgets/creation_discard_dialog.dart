import 'package:flutter/material.dart';

import 'package:banjarabio/l10n/app_localizations.dart';
import 'package:banjarabio/core/app_export.dart';

/// Discard changes confirmation dialog for the biodata creation flow.
/// Extracted from BiodataCreationScreen PopScope logic.
class CreationDiscardDialog {
  CreationDiscardDialog._();

  /// Shows the discard confirmation and returns true if user wants to exit.
  static Future<bool> show({
    required BuildContext context,
    required bool isEditMode,
    required bool isAdminEdit,
  }) async {
    final theme = Theme.of(context);

    final bool? shouldExit = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(AppLocalizations.of(context)?.discardChanges ?? 'Discard Changes?'),
        content: Text(
          AppLocalizations.of(context)?.discardChangesBody ?? 'Are you sure you want to go back? Your progress is saved as a draft.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(AppLocalizations.of(context)?.stay ?? 'Stay'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: theme.colorScheme.error,
              foregroundColor: Colors.white,
            ),
            child: Text(AppLocalizations.of(context)?.discard ?? 'Discard'),
          ),
        ],
      ),
    );

    if (shouldExit ?? false) {
      if (context.mounted) {
        if (isAdminEdit) {
          Navigator.of(context).pop();
        } else if (isEditMode) {
          Navigator.of(context).pushNamedAndRemoveUntil(AppRoutes.home, (route) => false);
        } else {
          Navigator.of(context).pushReplacementNamed(AppRoutes.onboardingSelection);
        }
      }
      return true;
    }
    return false;
  }
}
