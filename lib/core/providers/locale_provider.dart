import 'dart:ui';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// The key used to persist the selected locale in SharedPreferences.
const String _kLocaleKey = 'selected_locale';

/// Supported locales for BanjaraBio.
const List<Locale> appSupportedLocales = [
  Locale('en'), // English
  Locale('mr'), // Marathi
  Locale('hi'), // Hindi
  Locale('te'), // Telugu
  Locale('kn'), // Kannada
];

/// StateNotifier that manages the app locale.
class LocaleNotifier extends StateNotifier<Locale?> {
  LocaleNotifier() : super(null) {
    _loadSavedLocale();
  }

  /// Loads the persisted locale, or keeps null (= system locale).
  Future<void> _loadSavedLocale() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getString(_kLocaleKey);
    if (saved != null && saved.isNotEmpty) {
      state = Locale(saved);
    }
  }

  /// Sets a specific locale and persists it.
  Future<void> setLocale(Locale locale) async {
    state = locale;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kLocaleKey, locale.languageCode);
  }

  /// Resets to system locale (auto-detect).
  Future<void> resetToSystem() async {
    state = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_kLocaleKey);
  }
}

/// Global provider for the current app locale.
/// - null  → follow device language (auto-detect)
/// - non-null → overridden in-app locale
final localeProvider = StateNotifierProvider<LocaleNotifier, Locale?>(
  (ref) => LocaleNotifier(),
);
