import 'dart:typed_data';

import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

import 'package:banjarabio/core/services/pdf/biodata_font_preloader.dart';

class BiodataFontManager {
  /// Uses pre-loaded font bytes (from main isolate). Safe for PDF isolate -
  /// avoids PdfGoogleFonts which triggers AssetManifest in isolate.
  static pw.Font getFontForLanguageFromBytes(
    Map<String, Uint8List> fontBytes,
    String language, {
    bool bold = false,
  }) {
    pw.Font fromKey(String key) {
      final bytes = fontBytes[key];
      if (bytes == null || bytes.isEmpty) {
        throw StateError('Font not loaded: $key');
      }
      return pw.Font.ttf(bytes.buffer.asByteData(
        bytes.offsetInBytes,
        bytes.length,
      ));
    }

    switch (language) {
      case 'Hindi':
      case 'Marathi':
        return bold
            ? fromKey(BiodataFontPreloader.hindBold)
            : fromKey(BiodataFontPreloader.hindRegular);
      case 'Telugu':
        return fromKey(BiodataFontPreloader.notoSansTelugu);
      case 'Kannada':
        return fromKey(BiodataFontPreloader.notoSansKannada);
      default:
        return bold
            ? fromKey(BiodataFontPreloader.poppinsBold)
            : fromKey(BiodataFontPreloader.poppinsRegular);
    }
  }

  static pw.Font getMantraFontFromBytes(Map<String, Uint8List> fontBytes) {
    return getFontForLanguageFromBytes(
      fontBytes,
      'Hindi',
    );
  }

  static Future<pw.Font> getFontForLanguage(
    String language, {
    bool bold = false,
  }) async {
    switch (language) {
      case 'Hindi':
      case 'Marathi':
        return bold
            ? await PdfGoogleFonts.hindBold()
            : await PdfGoogleFonts.hindRegular();
      case 'Telugu':
        // Noto Sans Telugu doesn't have a specific bold variant in PdfGoogleFonts sometimes,
        // falling back to regular if bold not available or specific method missing
        return await PdfGoogleFonts.notoSansTeluguRegular();
      case 'Kannada':
        return await PdfGoogleFonts.notoSansKannadaRegular();
      default:
        return bold
            ? await PdfGoogleFonts.poppinsBold()
            : await PdfGoogleFonts.poppinsRegular();
    }
  }

  static Future<pw.Font> getMantraFont() async {
    // Specifically for "॥ श्री गणेशाय नमः ॥" which requires Devanagari support
    return await PdfGoogleFonts.hindRegular();
  }
}
