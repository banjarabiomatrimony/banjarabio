import 'package:shared_preferences/shared_preferences.dart';
import 'package:banjarabio/notification/core/notification_payload.dart';

/// Manages user-facing notification preferences:
/// - Quiet hours (DND)
/// - Per-category opt-in/opt-out
/// - Delivery timing preferences
class NotificationPreferences {
  static final NotificationPreferences _instance =
      NotificationPreferences._internal();
  factory NotificationPreferences() => _instance;
  NotificationPreferences._internal();

  static const _prefKeyQuietStart = 'notif_quiet_start_hour';
  static const _prefKeyQuietEnd = 'notif_quiet_end_hour';
  static const _prefKeyPrefix = 'notif_category_';

  /// Check if a given category is enabled by the user.
  /// All categories default to enabled.
  Future<bool> isCategoryEnabled(NotificationCategory category) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('$_prefKeyPrefix${category.name}') ?? true;
  }

  /// Toggle a notification category on or off.
  Future<void> setCategoryEnabled(
      NotificationCategory category, bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('$_prefKeyPrefix${category.name}', enabled);
  }

  /// Set quiet hours. [startHour] and [endHour] are in 24-hour format (0-23).
  /// E.g., startHour=22, endHour=7 means DND from 10 PM to 7 AM.
  Future<void> setQuietHours(int startHour, int endHour) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_prefKeyQuietStart, startHour);
    await prefs.setInt(_prefKeyQuietEnd, endHour);
  }

  /// Get quiet hours as a pair [startHour, endHour].
  /// Returns null if not set (no quiet hours configured).
  Future<(int, int)?> getQuietHours() async {
    final prefs = await SharedPreferences.getInstance();
    final start = prefs.getInt(_prefKeyQuietStart);
    final end = prefs.getInt(_prefKeyQuietEnd);
    if (start == null || end == null) return null;
    return (start, end);
  }

  /// Whether the current time falls within quiet hours.
  Future<bool> isQuietTime() async {
    final hours = await getQuietHours();
    if (hours == null) return false;

    final now = DateTime.now().hour;
    final (start, end) = hours;

    if (start <= end) {
      // Simple range, e.g., 1 AM to 6 AM
      return now >= start && now < end;
    } else {
      // Overnight range, e.g., 10 PM to 7 AM
      return now >= start || now < end;
    }
  }

  /// Disable quiet hours.
  Future<void> clearQuietHours() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_prefKeyQuietStart);
    await prefs.remove(_prefKeyQuietEnd);
  }
}
