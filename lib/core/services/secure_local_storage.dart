import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:banjarabio/core/services/app_logger.dart';

/// A custom [LocalStorage] implementation that uses [FlutterSecureStorage] 
/// to persist Supabase authentication state.
/// 
/// 🚨 MOTOROLA/VIVO FIX: The default Hive storage can be cleared or lost 
/// during aggressive background termination on Android 15. Secure storage 
/// provides a more robust and secure alternative for PKCE code verifiers.
class SecureLocalStorage extends LocalStorage {
  final FlutterSecureStorage _storage;

  SecureLocalStorage({FlutterSecureStorage? storage})
      : _storage = storage ??
            const FlutterSecureStorage(
              aOptions: AndroidOptions(
                encryptedSharedPreferences: true,
              ),
            );

  @override
  Future<void> initialize() async {
    // No specific initialization needed for flutter_secure_storage
  }

  @override
  Future<bool> hasAccessToken() async {
    try {
      final session = await _storage.read(key: supabasePersistSessionKey);
      return session != null;
    } catch (e, stack) {
      AppLogger.error('SecureLocalStorage', 'KeyStore/decryption read failure in hasAccessToken: $e', null, stack);
      await _handleCorruptedStorage();
      return false;
    }
  }

  @override
  Future<String?> accessToken() async {
    try {
      return await _storage.read(key: supabasePersistSessionKey);
    } catch (e, stack) {
      AppLogger.error('SecureLocalStorage', 'KeyStore/decryption read failure in accessToken: $e', null, stack);
      await _handleCorruptedStorage();
      return null;
    }
  }

  @override
  Future<void> removePersistedSession() async {
    try {
      await _storage.delete(key: supabasePersistSessionKey);
    } catch (e, stack) {
      AppLogger.error('SecureLocalStorage', 'KeyStore/decryption delete failure in removePersistedSession: $e', null, stack);
      await _handleCorruptedStorage();
    }
  }

  @override
  Future<void> persistSession(String persistSessionString) async {
    try {
      await _storage.write(
        key: supabasePersistSessionKey,
        value: persistSessionString,
      );
    } catch (e, stack) {
      AppLogger.error('SecureLocalStorage', 'KeyStore/decryption write failure in persistSession: $e', null, stack);
      await _handleCorruptedStorage();
    }
  }

  Future<void> _handleCorruptedStorage() async {
    try {
      AppLogger.warn('SecureLocalStorage', 'Attempting to clear corrupted secure storage to restore state...');
      await _storage.deleteAll();
      AppLogger.warn('SecureLocalStorage', 'Corrupted secure storage cleared successfully.');
    } catch (e) {
      AppLogger.error('SecureLocalStorage', 'Failed to clear secure storage: $e');
    }
  }
}

