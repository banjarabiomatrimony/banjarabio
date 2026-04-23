import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

/// Preloads biodata PDF fonts in the main isolate (where Flutter binding exists).
/// Avoids AssetManifest / rootBundle access in the PDF isolate, which causes
/// "Binding has not yet been initialized" and "Error loading AssetManifest.json".
///
/// Fonts are fetched from Google Fonts GitHub (reliable, no API key).
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
    poppinsRegular: '$_base/poppins/Poppins-Regular.ttf',
    poppinsBold: '$_base/poppins/Poppins-Bold.ttf',
    hindRegular: '$_base/hind/Hind-Regular.ttf',
    hindBold: '$_base/hind/Hind-Bold.ttf',
    // Variable fonts (Google Fonts no longer provides static Regular variants)
    notoSansTelugu: '$_base/notosanstelugu/NotoSansTelugu%5Bwdth%2Cwght%5D.ttf',
    notoSansKannada: '$_base/notosanskannada/NotoSansKannada%5Bwdth%2Cwght%5D.ttf',
  };

  /// Preloads all fonts needed for PDF generation. Call from main isolate before
  /// spawning the PDF isolate. Caches results for subsequent calls.
  static Future<Map<String, Uint8List>> loadAll() async {
    if (_cache.length == _urls.length) {
      return Map.from(_cache);
    }

    final results = <String, Uint8List>{};
    for (final entry in _urls.entries) {
      final key = entry.key;
      if (_cache.containsKey(key)) {
        results[key] = _cache[key]!;
        continue;
      }
      try {
        final res = await http.get(Uri.parse(entry.value)).timeout(const Duration(seconds: 10));
        if (res.statusCode == 200 && res.bodyBytes.isNotEmpty) {
          _cache[key] = res.bodyBytes;
          results[key] = res.bodyBytes;
        } else {
          debugPrint('[BiodataFontPreloader] Failed $key: ${res.statusCode}');
        }
      } catch (e) {
        debugPrint('[BiodataFontPreloader] Error $key: $e');
      }
    }

    if (results.length < _urls.length) {
      debugPrint(
        '[BiodataFontPreloader] Loaded ${results.length}/${_urls.length} fonts',
      );
    }
    return results;
  }

  /// Returns font bytes for isolate use. Must have called loadAll() first.
  static Map<String, Uint8List> getFontBytes() => Map.from(_cache);

  /// Clears cache (e.g. on low memory).
  static void clearCache() => _cache.clear();
}
