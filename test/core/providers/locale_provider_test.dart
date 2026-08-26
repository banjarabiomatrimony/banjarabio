import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:banjarabio/core/providers/locale_provider.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('LocaleProvider Tests', () {
    setUp(() {
      SharedPreferences.setMockInitialValues({});
    });

    test('supported locales list contains English, Marathi, Hindi, Telugu, Kannada', () {
      expect(appSupportedLocales, contains(const Locale('en')));
      expect(appSupportedLocales, contains(const Locale('mr')));
      expect(appSupportedLocales, contains(const Locale('hi')));
      expect(appSupportedLocales, contains(const Locale('te')));
      expect(appSupportedLocales, contains(const Locale('kn')));
    });

    test('setLocale and resetToSystem update state and SharedPreferences', () async {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final notifier = container.read(localeProvider.notifier);
      await notifier.setLocale(const Locale('mr'));
      expect(container.read(localeProvider), equals(const Locale('mr')));

      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getString('selected_locale'), equals('mr'));

      await notifier.resetToSystem();
      expect(container.read(localeProvider), isNull);
      expect(prefs.getString('selected_locale'), isNull);
    });
  });
}
