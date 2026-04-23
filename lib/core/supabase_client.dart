import 'dart:convert';
import 'package:banjarabio/core/services/secure_local_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Supabase client singleton for app-wide access
class AppSupabaseClient {
  static AppSupabaseClient? _instance;

  // Private constructor
  AppSupabaseClient._();

  static String? _razorpayKeyId;
  static String? _razorpayKeySecret;

  /// Get singleton instance
  static AppSupabaseClient get instance {
    _instance ??= AppSupabaseClient._();
    return _instance!;
  }

  static bool _isInitialized = false;

  /// Check if Supabase is initialized
  static bool get isInitialized => _isInitialized;

  /// Initialize Supabase with environment configuration
  static Future<void> initialize() async {
    if (_isInitialized || testAuth != null || testClient != null) {
      _isInitialized = true;
      return; 
    } // Prevent double init or real init in tests

    try {
      // Load environment configuration from assets folder
      final String envString = await rootBundle.loadString('assets/env.json');
      final Map<String, dynamic> env = json.decode(envString);

      final String supabaseUrl = env['SUPABASE_URL'] ?? '';
      final String supabaseAnonKey = env['SUPABASE_ANON_KEY'] ?? '';

      _razorpayKeyId = env['RAZORPAY_KEY_ID'];
      _razorpayKeySecret = env['RAZORPAY_KEY_SECRET'];

      // Validate configuration
      if (supabaseUrl.isEmpty || supabaseAnonKey.isEmpty) {
        throw Exception(
          'Supabase configuration missing. Please update env.json',
        );
      }

      // Initialize Supabase
      await Supabase.initialize(
        url: supabaseUrl,
        anonKey: supabaseAnonKey,
        authOptions: FlutterAuthClientOptions(
          localStorage: SecureLocalStorage(),
        ),
      );

      _isInitialized = true;
    } catch (e) {
      debugPrint('Supabase Init Error: $e');
      // Do NOT swallow the error completely in dev, but allow app to survive
      rethrow;
    }
  }

  /// 🧪 TEST-ONLY: Inject a mock client.
  @visibleForTesting
  static SupabaseClient? testClient;

  /// 🧪 TEST-ONLY: Inject a mock auth.
  @visibleForTesting
  static GoTrueClient? testAuth;

  /// Get SupabaseClient shorthand
  static SupabaseClient get client {
    if (testClient != null) return testClient!;
    if (!_isInitialized) {
      throw Exception('Supabase not initialized. Call initialize() first.');
    }
    return Supabase.instance.client;
  }

  /// Get Auth client shorthand
  static GoTrueClient get auth {
    if (testAuth != null) return testAuth!;
    if (!_isInitialized) {
      throw Exception('Supabase not initialized. Call initialize() first.');
    }
    return Supabase.instance.client.auth;
  }

  /// Get Storage client shorthand
  static SupabaseStorageClient get storage {
    if (testClient != null) return testClient!.storage;
    if (!_isInitialized) {
      throw Exception('Supabase not initialized. Call initialize() first.');
    }
    return Supabase.instance.client.storage;
  }

  /// Get current user
  static User? get currentUser {
    if (testAuth != null) return testAuth!.currentUser;
    if (!_isInitialized) return null;
    return auth.currentUser;
  }

  /// Check if user is authenticated
  static bool get isAuthenticated => currentUser != null;

  /// Get current user ID
  static String? get currentUserId => currentUser?.id;

  /// Get Razorpay Key ID
  static String get razorpayKeyId {
    if (_razorpayKeyId == null || _razorpayKeyId!.isEmpty) {
      debugPrint('WARNING: RAZORPAY_KEY_ID not found in env.json');
      return '';
    }
    return _razorpayKeyId!;
  }

  /// Get Razorpay Key Secret
  static String get razorpayKeySecret {
    if (_razorpayKeySecret == null || _razorpayKeySecret!.isEmpty) {
      debugPrint('WARNING: RAZORPAY_KEY_SECRET not found in env.json');
      return '';
    }
    return _razorpayKeySecret!;
  }
}
