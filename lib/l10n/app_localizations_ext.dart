import 'package:flutter/widgets.dart';
import 'package:banjarabio/l10n/app_localizations.dart';
import 'package:banjarabio/l10n/app_localizations_en.dart';

/// Safe, non-null localization accessor for BuildContext.
///
/// Returns the real [AppLocalizations] if the delegate loaded correctly,
/// otherwise falls back to [AppLocalizationsEn] and logs a debug warning.
///
/// ## Usage (recommended for all new code)
/// ```dart
/// // Instead of:
/// Text(AppLocalizations.of(context)?.saveBiodata ?? 'Save Biodata')
///
/// // Use:
/// Text(context.l10n.saveBiodata)
/// ```
///
/// Existing callsites using `AppLocalizations.of(context)?.xxx ?? 'fallback'`
/// remain valid and do NOT need to be migrated retroactively.
extension AppLocalizationsX on BuildContext {
  /// Non-null localization accessor with automatic English fallback.
  AppLocalizations get l10n {
    final instance = AppLocalizations.of(this);
    if (instance != null) return instance;

    // Debug-mode alert for missing delegate
    assert(() {
      debugPrint('⚠️ AppLocalizations.of(context) returned null. '
          'Falling back to English. Ensure MaterialApp has '
          'AppLocalizations.delegate in localizationsDelegates.');
      return true;
    }());

    return AppLocalizationsEn();
  }
}
