import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:banjarabio/core/services/app_logger.dart';

/// Preloads biodata PDF fonts in the main isolate (where Flutter binding exists).
/// Avoids AssetManifest / rootBundle access in the PDF isolate, which causes
/// "Binding has not yet been initialized" and "Error loading AssetManifest.json".
///
/// ⚡ High-Performance Architecture:
/// 1. Local Asset First: Loads Poppins Regular & Bold directly from bundled app assets (0ms, 100% offline).
/// 2. Parallel Remote Fetch: Fetches regional fonts in parallel (Future.wait) with a 3s timeout.
/// 3. Zero-Crash Fallback: Always populates font keys with fallback font bytes so PDF Isolate never throws or stalls.
class BiodataFontPreloader {
  static const String _base =
      'https://github.com/google/fonts/raw/main/ofl';

  static final Map<String, Uint8List> _cache = {};

  /// Font keys matching BiodataFontManager usage
  static const String poppinsRegular = 'poppins_regular';
  static const String poppinsBold = 'poppins_bold';
  static const String hindRegular = 'hind_regular';
  static const String hindBold = 'hind_bold';
  static const String notoSansTelugu = 'notosanstelugu_regular';
  static const String notoSansKannada = 'notosanskannada_regular';
  static const String mantra = 'mantra'; // same as hind_regular

  static const Map<String, String> _urls = {
    hindRegular: '$_base/hind/Hind-Regular.ttf',
    hindBold: '$_base/hind/Hind-Bold.ttf',
    notoSansTelugu: '$_base/notosanstelugu/NotoSansTelugu%5Bwdth%2Cwght%5D.ttf',
    notoSansKannada: '$_base/notosanskannada/NotoSansKannada%5Bwdth%2Cwght%5D.ttf',
  };

  /// Preloads all fonts needed for PDF generation.
  /// Poppins loads instantly from local assets; regional fonts load in parallel.
  static Future<Map<String, Uint8List>> loadAll() async {
    // 1. ⚡ Load Local Bundled Poppins Fonts First (0ms - 100% offline)
    if (!_cache.containsKey(poppinsRegular) || _cache[poppinsRegular]!.isEmpty) {
      try {
        final data = await rootBundle.load('assets/fonts/Poppins/Poppins-Regular.ttf');
        _cache[poppinsRegular] = data.buffer.asUint8List();
      } catch (e) {
        AppLogger.error('BiodataFontPreloader', 'Error loading local Poppins-Regular: $e');
      }
    }
    if (!_cache.containsKey(poppinsBold) || _cache[poppinsBold]!.isEmpty) {
      try {
        final data = await rootBundle.load('assets/fonts/Poppins/Poppins-Bold.ttf');
        _cache[poppinsBold] = data.buffer.asUint8List();
      } catch (e) {
        AppLogger.error('BiodataFontPreloader', 'Error loading local Poppins-Bold: $e');
      }
    }

    // 2. 🌐 Fetch missing regional fonts in PARALLEL with 3s timeout
    final missingEntries = _urls.entries
        .where((e) => !_cache.containsKey(e.key) || _cache[e.key]!.isEmpty)
        .toList();

    if (missingEntries.isNotEmpty) {
      await Future.wait(
        missingEntries.map((entry) async {
          try {
            final res = await http
                .get(Uri.parse(entry.value))
                .timeout(const Duration(seconds: 3));
            if (res.statusCode == 200 && res.bodyBytes.isNotEmpty) {
              _cache[entry.key] = res.bodyBytes;
            }
          } catch (e) {
            AppLogger.warn('BiodataFontPreloader', 'Regional font ${entry.key} download skipped: $e');
          }
        }),
      );
    }

    // 3. 🛡️ Bulletproof Fallback: ensure every key is populated so PDF Isolate never throws
    final fallbackRegular = _cache[poppinsRegular] ?? Uint8List(0);
    final fallbackBold = _cache[poppinsBold] ?? fallbackRegular;

    for (final key in [
      poppinsRegular,
      poppinsBold,
      hindRegular,
      hindBold,
      notoSansTelugu,
      notoSansKannada,
      mantra,
    ]) {
      if (!_cache.containsKey(key) || _cache[key]!.isEmpty) {
        _cache[key] = key.contains('bold') ? fallbackBold : fallbackRegular;
      }
    }

    return Map.from(_cache);
  }

  /// Returns font bytes for isolate use. Must have called loadAll() first.
  static Map<String, Uint8List> getFontBytes() => Map.from(_cache);

  /// Clears cache (e.g. on low memory).
  static void clearCache() => _cache.clear();
}
