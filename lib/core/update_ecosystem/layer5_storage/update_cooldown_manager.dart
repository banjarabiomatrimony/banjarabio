import 'package:shared_preferences/shared_preferences.dart';

/// ⏳ [UpdateCooldownManager]
///
/// Prevents user fatigue by throttling soft/optional update prompts.
/// Hard/Force updates bypass this manager completely.
class UpdateCooldownManager {
  static const String _keyLastDismissed = 'update_ecosystem_last_dismissed_timestamp';

  final SharedPreferences? _prefs;

  const UpdateCooldownManager([this._prefs]);

  Future<SharedPreferences> get _instance async => _prefs ?? await SharedPreferences.getInstance();

  /// Checks if enough time has elapsed since the user last dismissed a soft update.
  Future<bool> shouldPromptSoftUpdate(Duration cooldown) async {
    try {
      final prefs = await _instance;
      final lastDismissedMs = prefs.getInt(_keyLastDismissed);

      if (lastDismissedMs == null) return true; // First time, prompt allowed

      final lastDismissedTime = DateTime.fromMillisecondsSinceEpoch(lastDismissedMs);
      final difference = DateTime.now().difference(lastDismissedTime);

      return difference >= cooldown;
    } catch (_) {
      return true; // Fallback: allow prompt if storage read fails
    }
  }

  /// Records that the user dismissed the soft update prompt at the current timestamp.
  Future<void> recordSoftUpdateDismissed() async {
    try {
      final prefs = await _instance;
      await prefs.setInt(_keyLastDismissed, DateTime.now().millisecondsSinceEpoch);
    } catch (_) {}
  }

  /// Resets the cooldown timer (useful after a new release is detected or for debugging).
  Future<void> resetCooldown() async {
    try {
      final prefs = await _instance;
      await prefs.remove(_keyLastDismissed);
    } catch (_) {}
  }
}
