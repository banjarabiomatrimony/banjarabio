import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:banjarabio/core/services/isolate_manager.dart';
import 'package:banjarabio/core/models/profile_model.dart';
import 'package:banjarabio/core/models/sibling_model.dart';
import 'package:banjarabio/core/services/app_logger.dart';

/// [SessionManager]
///
/// A robust, singleton-based wrapper around [SharedPreferences].
///
/// 🏆 10/10 Architecture Highlights:
/// 1. **Singleton Pattern**: Ensures only one instance of SharedPreferences is open.
/// 2. **Initialization Guard**: Throws clear errors if accessed before init().
/// 3. **Isolate Offloading**: Heavy JSON serialization runs on a background thread.
/// 4. **Parallel Clearing**: Clears session keys concurrently for speed.
/// 5. **Static Compatibility**: Bridges static calls to the singleton instance.
class SessionManager {
  // ---------------------------------------------------------------------------
  // 1. Singleton Pattern
  // ---------------------------------------------------------------------------
  // Private constructor prevents external instantiation.
  SessionManager._();

  // The single instance of the class.
  static final SessionManager _instance = SessionManager._();

  // Public accessor to get the instance.
  static SessionManager get instance => _instance;

  // ---------------------------------------------------------------------------
  // 2. Constants (Keys)
  // ---------------------------------------------------------------------------
  static const String _isLoggedInKey = 'is_logged_in';
  static const String _userIdKey = 'user_id';
  static const String _profileIdKey = 'profile_id';
  static const String _emailKey = 'email';
  static const String _userTokenKey = 'user_token';
  static const String _isFirstTimeKey = 'is_first_time';
  static const String _isBiometricEnabledKey = 'is_biometric_enabled';
  static const String _lastLoginTimeKey = 'last_login_time';
  static const String _biodataDraftKey = 'biodata_draft';
  static const String _hasNotifiedInstallKey = 'has_notified_install';
  static const String _isPremiumKey = 'is_premium';

  // ---------------------------------------------------------------------------
  // 3. Initialization Logic
  // ---------------------------------------------------------------------------
  SharedPreferences? _prefs;
  ProfileModel? _currentProfile;

  /// Gets the currently cached profile
  ProfileModel? get currentProfile => _currentProfile;

  /// Sets the current profile
  void setCurrentProfile(ProfileModel? profile) {
    _currentProfile = profile;
  }

  @visibleForTesting
  SharedPreferences? testPrefs;

  /// Resets the singleton state for testing.
  @visibleForTesting
  void reset() {
    _prefs = null;
    testPrefs = null;
  }

  /// Initializes the SessionManager.
  /// ⚠️ MUST be called in `main()` before `runApp()`.
  Future<void> init() async {
    // Prevent re-initialization if already done
    if (_prefs != null) return;

    try {
      _prefs = await SharedPreferences.getInstance();
      AppLogger.debug('SessionManager', '✅ SessionManager Initialized');
    } catch (e) {
      // Critical failure: App cannot store data.
      AppLogger.error('SessionManager', '❌ SessionManager Init Error: $e');
      // In a real app, you might want to report this to Crashlytics
    }
  }

  /// Internal safe getter.
  /// Throws a helpful error message instead of a generic NullPointerException
  /// if the developer forgets to call init().
  SharedPreferences get _safePrefs {
    if (testPrefs != null) return testPrefs!;
    if (_prefs == null) {
      throw Exception(
        'SessionManager is not initialized! \n'
        '👉 Call `await SessionManager.instance.init();` in your main.dart',
      );
    }
    return _prefs!;
  }

  // ---------------------------------------------------------------------------
  // 4. Getters & Setters (Type Safe)
  // ---------------------------------------------------------------------------

  /// Login Status
  bool get isLoggedIn => _safePrefs.getBool(_isLoggedInKey) ?? false;
  Future<void> setLoggedIn(bool value) =>
      _safePrefs.setBool(_isLoggedInKey, value);

  /// User ID
  String? get userId => _safePrefs.getString(_userIdKey);
  Future<void> setUserId(String value) =>
      _safePrefs.setString(_userIdKey, value);

  /// Profile ID (Separate from User ID for multi-profile apps)
  String? get profileId => _safePrefs.getString(_profileIdKey);
  Future<void> setProfileId(String value) =>
      _safePrefs.setString(_profileIdKey, value);

  /// User Email
  String? get email => _safePrefs.getString(_emailKey);
  Future<void> setEmail(String value) => _safePrefs.setString(_emailKey, value);

  /// Auth Token
  String? get userToken => _safePrefs.getString(_userTokenKey);
  Future<void> setUserToken(String value) =>
      _safePrefs.setString(_userTokenKey, value);

  /// First Time Launch Flag (Onboarding)
  bool get isFirstTime => _safePrefs.getBool(_isFirstTimeKey) ?? true;
  Future<void> setFirstTime(bool value) =>
      _safePrefs.setBool(_isFirstTimeKey, value);

  /// Biometric Preference
  bool get isBiometricEnabled =>
      _safePrefs.getBool(_isBiometricEnabledKey) ?? false;
  Future<void> setBiometricEnabled(bool value) =>
      _safePrefs.setBool(_isBiometricEnabledKey, value);

  /// Last Login Timestamp
  DateTime? get lastLoginTime {
    final timestamp = _safePrefs.getInt(_lastLoginTimeKey);
    return timestamp != null
        ? DateTime.fromMillisecondsSinceEpoch(timestamp)
        : null;
  }

  Future<void> setLastLoginTime(DateTime value) =>
      _safePrefs.setInt(_lastLoginTimeKey, value.millisecondsSinceEpoch);

  /// Install Notification Flag (one-time)
  bool get hasNotifiedInstall =>
      _safePrefs.getBool(_hasNotifiedInstallKey) ?? false;
  Future<void> setHasNotifiedInstall(bool value) =>
      _safePrefs.setBool(_hasNotifiedInstallKey, value);

  /// Premium Status
  bool get isPremium => _safePrefs.getBool(_isPremiumKey) ?? false;
  Future<void> setPremium(bool value) =>
      _safePrefs.setBool(_isPremiumKey, value);

  // ---------------------------------------------------------------------------
  // 5. Session Management
  // ---------------------------------------------------------------------------

  /// Clears critical user session data (Logout).
  ///
  /// 🚀 **Optimization**: Uses `Future.wait` to execute all remove operations
  /// in parallel, rather than waiting for them one by one.
  Future<void> clearSession() async {
    await Future.wait([
      _safePrefs.remove(_isLoggedInKey),
      _safePrefs.remove(_userIdKey),
      _safePrefs.remove(_profileIdKey),
      _safePrefs.remove(_userTokenKey),
      _safePrefs.remove(_emailKey),
      _safePrefs.remove(_lastLoginTimeKey),
      _safePrefs.remove(_biodataDraftKey),
    ]);
    // Note: We deliberately KEEP `isFirstTime` and `isBiometricEnabled`
    // so the user experience persists across logouts.
  }

  /// Completely resets the app state (Debug / Hard Reset).
  Future<void> clearAll() async {
    await _safePrefs.clear();
  }

  // ---------------------------------------------------------------------------
  // 6. Heavy Operations (Offloaded to Isolate)
  // ---------------------------------------------------------------------------

  /// Saves a large Biodata form draft.
  ///
  /// 🚀 **Optimization**: JSON encoding can be slow for large maps.
  /// We offload this to the [IsolateManager] to prevent UI jank.
  Future<void> saveBiodataDraft(Map<String, dynamic> data) async {
    try {
      // 1. Offload the heavy serialization to a background thread
      final jsonString = await IsolateManager.compute(
        _encodeJsonSafe,
        data,
        debugLabel: 'BiodataDraftEncode',
      );

      // 2. Save the string quickly on the main thread
      await _safePrefs.setString(_biodataDraftKey, jsonString);
    } catch (e) {
      AppLogger.error('SessionManager', 'Error saving biodata draft: $e');
    }
  }

  /// Retrieves and parses the Biodata form draft.
  ///
  /// 🚀 **Optimization**: Uses [IsolateManager.jsonDecode] to parse on a
  /// background thread, ensuring smooth screen transitions.
  Future<Map<String, dynamic>?> getBiodataDraft() async {
    try {
      final jsonString = _safePrefs.getString(_biodataDraftKey);
      if (jsonString == null) return null;

      // 1. Offload parsing to background thread
      final decoded = await IsolateManager.instance.jsonDecode(jsonString);

      return decoded as Map<String, dynamic>;
    } catch (e) {
      AppLogger.error('SessionManager', 'Error getting biodata draft: $e');
      return null;
    }
  }

  Future<void> clearBiodataDraft() => _safePrefs.remove(_biodataDraftKey);

  // ---------------------------------------------------------------------------
  // 7. Static Compatibility Layer (Bridge to Singleton)
  // ---------------------------------------------------------------------------

  // Note: Dart forbids static/instance member name conflicts.
  // We explicitly keep `initialize` as a bridge because it differs from `init`.
  // All other accessors must be migrated to `SessionManager.instance.X`.

  static Future<void> initialize() => instance.init();
}

// -----------------------------------------------------------------------------
// 8. Helper Functions (Must be top-level for Isolate communication)
// -----------------------------------------------------------------------------

/// Deep recursive JSON sanitizer that ensures all models, DateTime objects,
/// Enums, Lists, and Sets are converted to primitive JSON encodable structures.
dynamic _sanitizeForJson(dynamic value) {
  if (value == null) return null;
  if (value is num || value is bool || value is String) return value;
  if (value is DateTime) return value.toIso8601String();
  if (value is SiblingModel) return value.toJson();
  if (value is Enum) return value.name;
  if (value is List) {
    return value.map(_sanitizeForJson).toList();
  }
  if (value is Set) {
    return value.map(_sanitizeForJson).toList();
  }
  if (value is Map) {
    final map = <String, dynamic>{};
    value.forEach((k, v) {
      map[k.toString()] = _sanitizeForJson(v);
    });
    return map;
  }
  try {
    return (value as dynamic).toJson();
  } catch (_) {
    return value.toString();
  }
}

/// Safe JSON Encoder.
///
/// Handles `DateTime`, `SiblingModel`, and custom objects which standard `jsonEncode` crashes on.
/// This runs inside the Isolate/Background Worker.
String _encodeJsonSafe(Map<String, dynamic> data) {
  final sanitized = _sanitizeForJson(data) as Map<String, dynamic>;
  return jsonEncode(sanitized);
}
