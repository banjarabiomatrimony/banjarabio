import 'package:flutter/material.dart';
import 'package:banjarabio/l10n/app_localizations.dart';
import 'package:banjarabio/routes/app_routes.dart';

class GuestRestrictedDialog {
  static void show(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        final l10n = AppLocalizations.of(context);
        return AlertDialog(
          title: Text(l10n?.signInRequired ?? ''),
          content: Text(l10n?.signInRequiredContent ?? ''),
          actions: <Widget>[
            TextButton(
              child: Text(l10n?.cancel ?? ''),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.primary,
                foregroundColor: Colors.white,
              ),
              child: Text(l10n?.signIn ?? ''),
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.of(context)
                    .pushReplacementNamed(AppRoutes.authentication);
              },
            ),
          ],
        );
      },
    );
  }
}
