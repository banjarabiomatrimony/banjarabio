import 'package:flutter/material.dart';
import 'package:banjarabio/l10n/app_localizations.dart';
import 'package:banjarabio/core/constants/app_typography.dart';
import 'package:banjarabio/core/services/local_cache_service.dart';
import 'package:banjarabio/core/supabase_client.dart';
import 'package:banjarabio/routes/app_routes.dart';
import 'package:banjarabio/widgets/smart_auth_gate.dart';

class GuestRestrictedDialog {
  /// Shows the appropriate gate based on auth state:
  /// - **Unauthenticated guest**: SmartAuthGate bottom sheet (returns async result)
  /// - **Authenticated relative browse (no own profile)**: Existing Create Biodata / Change Options dialog
  ///
  /// Returns [SmartAuthResult.success] if user authenticated (caller should complete original action),
  /// [SmartAuthResult.cancelled] if dismissed.
  static Future<SmartAuthResult> show(
    BuildContext context, {
    SmartAuthIntent intent = SmartAuthIntent.generic,
    String? profileName,
  }) async {
    final isAuth = AppSupabaseClient.isAuthenticated;
    final isRelative = LocalCacheService().isRelativeBrowseMode();

    // 🌟 Unauthenticated Guest → SmartAuthGate (Google Sign-In bottom sheet)
    if (!isAuth) {
      return SmartAuthGate.show(
        context,
        intent: intent,
        profileName: profileName,
      );
    }

    // 🌟 Authenticated user in Relative Browse Mode (no own profile) → existing dialog
    if (isRelative) {
      await _showRelativeBrowseDialog(context);
      return SmartAuthResult.cancelled;
    }

    // Fallback (shouldn't reach here for properly gated calls)
    return SmartAuthResult.cancelled;
  }

  /// The original dialog for authenticated relative browse users.
  /// Offers: Cancel / Change Options / Create Biodata.
  static Future<void> _showRelativeBrowseDialog(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);

    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Text(
            l10n?.createBiodata ?? 'बायोडेटा आवश्यक आहे',
            style: TextStyle(fontSize: AppTypography.bodyLarge, fontWeight: AppTypography.bold),
          ),
          content: Text(
            l10n?.guestRestrictedContent ??
                'To view all details, save profiles, and communicate with matches, please create your biodata or change your search options.',
            style: TextStyle(fontSize: AppTypography.bodySmall),
          ),
          actionsOverflowDirection: VerticalDirection.up,
          actions: <Widget>[
            TextButton(
              child: Text(l10n?.cancel ?? 'Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            OutlinedButton(
              style: OutlinedButton.styleFrom(
                side: BorderSide(color: theme.colorScheme.primary),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: Text(l10n?.changeOptionsCta ?? 'Change Options ✏️'),
              onPressed: () async {
                await LocalCacheService().clearRelativeBrowseSession();
                if (context.mounted) {
                  Navigator.of(context).pop();
                  Navigator.of(context, rootNavigator: true).pushNamedAndRemoveUntil(
                    AppRoutes.userTypeSelection,
                    (route) => false,
                  );
                }
              },
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: theme.colorScheme.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: Text(l10n?.createBiodataCta ?? 'Create Biodata ✨'),
              onPressed: () async {
                await LocalCacheService().clearRelativeBrowseSession();
                await LocalCacheService().setGuestMode(false);
                if (context.mounted) {
                  Navigator.of(context).pop();
                  Navigator.of(context, rootNavigator: true).pushNamed(AppRoutes.biodataCreation);
                }
              },
            ),
          ],
        );
      },
    );
  }
}
