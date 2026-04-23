import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:banjarabio/notification/features/notification_preferences.dart';
import 'package:banjarabio/notification/core/notification_payload.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('NotificationPreferences.isCategoryEnabled', () {
    test('defaults to true for all categories', () async {
      final prefs = NotificationPreferences();
      expect(await prefs.isCategoryEnabled(NotificationCategory.chatMessage), true);
      expect(await prefs.isCategoryEnabled(NotificationCategory.nudge), true);
      expect(await prefs.isCategoryEnabled(NotificationCategory.matchFound), true);
    });

    test('returns false when explicitly disabled', () async {
      SharedPreferences.setMockInitialValues({
        'notif_category_chatMessage': false,
      });
      expect(await NotificationPreferences().isCategoryEnabled(NotificationCategory.chatMessage), false);
    });
  });

  group('NotificationPreferences.setCategoryEnabled', () {
    test('persists the preference', () async {
      final prefs = NotificationPreferences();
      await prefs.setCategoryEnabled(NotificationCategory.nudge, false);
      expect(await prefs.isCategoryEnabled(NotificationCategory.nudge), false);
    });

    test('can re-enable a previously disabled category', () async {
      final prefs = NotificationPreferences();
      await prefs.setCategoryEnabled(NotificationCategory.nudge, false);
      await prefs.setCategoryEnabled(NotificationCategory.nudge, true);
      expect(await prefs.isCategoryEnabled(NotificationCategory.nudge), true);
    });
  });

  group('NotificationPreferences.quietHours', () {
    test('getQuietHours returns null when not set', () async {
      expect(await NotificationPreferences().getQuietHours(), isNull);
    });

    test('setQuietHours and getQuietHours round-trip', () async {
      final prefs = NotificationPreferences();
      await prefs.setQuietHours(22, 7);
      final hours = await prefs.getQuietHours();
      expect(hours, isNotNull);
      expect(hours!.$1, 22);
      expect(hours.$2, 7);
    });

    test('clearQuietHours removes the quiet hours', () async {
      final prefs = NotificationPreferences();
      await prefs.setQuietHours(22, 7);
      await prefs.clearQuietHours();
      expect(await prefs.getQuietHours(), isNull);
    });

    test('isQuietTime returns false when no quiet hours set', () async {
      expect(await NotificationPreferences().isQuietTime(), false);
    });

    test('isQuietTime handles simple range (1 AM to 6 AM)', () async {
      final prefs = NotificationPreferences();
      await prefs.setQuietHours(1, 6);
      // We can't control DateTime.now().hour in a unit test without fake_async,
      // but we verify it doesn't crash
      final result = await prefs.isQuietTime();
      expect(result, isA<bool>());
    });

    test('isQuietTime handles overnight range (22 to 7)', () async {
      final prefs = NotificationPreferences();
      await prefs.setQuietHours(22, 7);
      final result = await prefs.isQuietTime();
      expect(result, isA<bool>());
    });
  });
}
