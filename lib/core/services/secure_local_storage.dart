import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

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
    final session = await _storage.read(key: supabasePersistSessionKey);
    return session != null;
  }

  @override
  Future<String?> accessToken() async {
    return await _storage.read(key: supabasePersistSessionKey);
  }

  @override
  Future<void> removePersistedSession() async {
    await _storage.delete(key: supabasePersistSessionKey);
  }

  @override
  Future<void> persistSession(String persistSessionString) async {
    await _storage.write(
      key: supabasePersistSessionKey,
      value: persistSessionString,
    );
  }
}
