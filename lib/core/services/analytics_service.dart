import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';

class AnalyticsService {
  static final AnalyticsService _instance = AnalyticsService._internal();
  factory AnalyticsService() => _instance;
  AnalyticsService._internal();

  @visibleForTesting
  FirebaseAnalytics? testAnalytics;

  FirebaseAnalytics? get _analyticsInstance {
    if (testAnalytics != null) return testAnalytics;
    try {
      if (Firebase.apps.isNotEmpty) {
        return FirebaseAnalytics.instance;
      }
    } catch (_) {}
    return null;
  }

  /// Log App Open
  static Future<void> logAppOpen() => _instance.instanceLogAppOpen();
  
  @visibleForTesting
  Future<void> instanceLogAppOpen() async {
    await _analyticsInstance?.logAppOpen();
    debugPrint('📊 Analytics: App Open');
  }

  /// Log Signup Start
  static Future<void> logSignUpStart(String method) => _instance.instanceLogSignUpStart(method);
  
  @visibleForTesting
  Future<void> instanceLogSignUpStart(String method) async {
    await _analyticsInstance?.logSignUp(signUpMethod: method);
    debugPrint('📊 Analytics: Signup Start ($method)');
  }

  /// Log Signup Success
  static Future<void> logSignUpSuccess(String userId) => _instance.instanceLogSignUpSuccess(userId);
  
  @visibleForTesting
  Future<void> instanceLogSignUpSuccess(String userId) async {
    await instanceLogEvent(
      'signup_complete',
      parameters: {'user_id': userId},
    );
    await instanceSetUserId(userId);
    debugPrint('📊 Analytics: Signup Complete ($userId)');
  }

  /// Log Login Success
  static Future<void> logLogin(String userId) => _instance.instanceLogLogin(userId);
  
  @visibleForTesting
  Future<void> instanceLogLogin(String userId) async {
    await _analyticsInstance?.logLogin(loginMethod: 'phone');
    await instanceSetUserId(userId);
    debugPrint('📊 Analytics: Login ($userId)');
  }

  /// Log Event
  static Future<void> logEvent(String name, {Map<String, dynamic>? parameters}) =>
      _instance.instanceLogEvent(name, parameters: parameters);

  @visibleForTesting
  Future<void> instanceLogEvent(String name, {Map<String, dynamic>? parameters}) async {
    await _analyticsInstance?.logEvent(
      name: name,
      parameters: parameters?.cast<String, Object>(),
    );
    debugPrint('📊 Analytics: Event ($name)');
  }

  /// Log Search
  static Future<void> logSearch(String searchTerm) => _instance.instanceLogSearch(searchTerm);
  
  @visibleForTesting
  Future<void> instanceLogSearch(String searchTerm) async {
    await instanceLogEvent('search', parameters: {'search_term': searchTerm});
  }

  /// Log Conversion
  static Future<void> logConversion(String type, {double? value}) =>
      _instance.instanceLogConversion(type, value: value);

  @visibleForTesting
  Future<void> instanceLogConversion(String type, {double? value}) async {
    await instanceLogEvent('conversion', parameters: {
      'type': type,
      if (value != null) 'value': value,
    });
  }

  /// Log Screen View
  static Future<void> logScreenView(String screenName) => _instance.instanceLogScreenView(screenName);
  
  @visibleForTesting
  Future<void> instanceLogScreenView(String screenName) async {
    await _analyticsInstance?.logScreenView(screenName: screenName);
    debugPrint('📊 Analytics: Screen View ($screenName)');
  }

  /// Set User ID
  static Future<void> setUserId(String userId) => _instance.instanceSetUserId(userId);
  
  @visibleForTesting
  Future<void> instanceSetUserId(String userId) async {
    await _analyticsInstance?.setUserId(id: userId);
    debugPrint('📊 Analytics: Set User ID ($userId)');
  }

  /// Set User Properties
  static Future<void> setUserProperties(Map<String, String> properties) =>
      _instance.instanceSetUserProperties(properties);

  @visibleForTesting
  Future<void> instanceSetUserProperties(Map<String, String> properties) async {
    for (final entry in properties.entries) {
      await _analyticsInstance?.setUserProperty(name: entry.key, value: entry.value);
    }
    debugPrint('📊 Analytics: Set User Properties');
  }

  @visibleForTesting
  void reset() {
    testAnalytics = null;
  }
}
