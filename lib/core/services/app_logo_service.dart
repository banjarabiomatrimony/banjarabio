import 'package:flutter/services.dart';

/// Global cache for the app logo. Load once at startup, use everywhere.
/// No compression — asset is used as-is for instant display and PDF.
class AppLogoService {
  AppLogoService._();
  static final AppLogoService _instance = AppLogoService._();
  static AppLogoService get instance => _instance;

  Uint8List? _bytes;
  bool _loading = false;

  /// Cached logo bytes. Null until [warmUp] has been called and completed.
  Uint8List? get logoBytes => _bytes;

  /// True if logo is ready to use.
  bool get isReady => _bytes != null;

  /// Load logo once; safe to call multiple times (idempotent).
  Future<void> warmUp() async {
    if (_bytes != null || _loading) return;
    _loading = true;
    try {
      final data = await rootBundle.load('assets/logo/BanjaraBio.png');
      _bytes = data.buffer.asUint8List();
    } catch (e) {
      // Ignore; logo is optional
    } finally {
      _loading = false;
    }
  }

  /// Ensure logo is loaded; returns bytes or null on failure.
  Future<Uint8List?> getLogoBytes() async {
    if (_bytes != null) return _bytes;
    await warmUp();
    return _bytes;
  }
}
