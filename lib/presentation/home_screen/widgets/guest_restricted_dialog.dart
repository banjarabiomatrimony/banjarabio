import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import 'package:banjarabio/l10n/app_localizations.dart';
import 'package:banjarabio/core/services/local_cache_service.dart';
import 'package:banjarabio/core/supabase_client.dart';
import 'package:banjarabio/routes/app_routes.dart';

class GuestRestrictedDialog {
  static void show(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        final l10n = AppLocalizations.of(context);
        final theme = Theme.of(context);
        final isAuth = AppSupabaseClient.isAuthenticated;
        final isRelative = LocalCacheService().isRelativeBrowseMode();

        // 🌟 Logged-in user without a completed profile (Relative Browse / Incomplete Profile)
        if (isAuth || isRelative) {
          return AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            title: Text(
              l10n?.createBiodata ?? 'बायोडेटा आवश्यक आहे',
              style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.bold),
            ),
            content: Text(
              'इतर सर्व माहिती पाहण्यासाठी, स्थळे सेव्ह करण्यासाठी आणि संपर्क साधण्यासाठी तुमचा बायोडेटा तयार करा किंवा शोध पर्याय बदला.',
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
                child: const Text('बायोडेटा बनवा ✨'),
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
        }

        // 🌟 Unauthenticated Guest (Explore as Guest)
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Text(
            l10n?.signInRequired ?? 'Sign In Required',
            style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.bold),
          ),
          content: Text(
            l10n?.signInRequiredContent ?? 'Please sign in or create an account to perform this action.',
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
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: theme.colorScheme.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: Text(l10n?.signIn ?? 'लॉग इन करा'),
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.of(context, rootNavigator: true).pushNamedAndRemoveUntil(
                  AppRoutes.userTypeSelection,
                  (route) => false,
                );
              },
            ),
          ],
        );
      },
    );
  }
}
