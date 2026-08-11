import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import 'package:banjarabio/l10n/app_localizations.dart';
import 'package:banjarabio/core/services/local_cache_service.dart';
import 'package:banjarabio/routes/app_routes.dart';

class GuestRestrictedDialog {
  static void show(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        final l10n = AppLocalizations.of(context);
        final theme = Theme.of(context);
        final isRelative = LocalCacheService().isRelativeBrowseMode();

        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Text(
            isRelative ? 'उमेदवार माहिती पहाण्यासाठी लॉग इन आवश्यक' : (l10n?.signInRequired ?? 'Sign In Required'),
            style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.bold),
          ),
          content: Text(
            isRelative
                ? 'संपर्क साधण्यासाठी व संपूर्ण माहिती पहाण्यासाठी लॉग इन करा किंवा शोध पर्याय बदला.'
                : (l10n?.signInRequiredContent ?? 'Please sign in or create an account to perform this action.'),
            style: TextStyle(fontSize: 10.sp),
          ),
          actionsOverflowDirection: VerticalDirection.up,
          actions: <Widget>[
            TextButton(
              child: Text(l10n?.cancel ?? 'रद्द करा'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            if (isRelative)
              OutlinedButton(
                style: OutlinedButton.styleFrom(
                  side: BorderSide(color: theme.colorScheme.primary),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text('पर्याय बदला ✏️'),
                onPressed: () async {
                  await LocalCacheService().clearRelativeBrowseSession();
                  if (context.mounted) {
                    Navigator.of(context).pop();
                    Navigator.of(context).pushNamedAndRemoveUntil(
                      AppRoutes.onboardingSelection,
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
              child: Text(l10n?.signIn ?? 'लॉग इन करा'),
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.of(context).pushReplacementNamed(AppRoutes.authentication);
              },
            ),
          ],
        );
      },
    );
  }
}
