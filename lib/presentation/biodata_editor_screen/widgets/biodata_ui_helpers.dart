import 'package:banjarabio/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:banjarabio/core/constants/app_typography.dart';

/// Global-grade theme for Customize Biodata: spacing, typography, inputs.
///
/// Uses app-bundled font families instead of runtime Google Fonts fetching.
/// Headings: Outfit, Body: PlusJakartaSans.
class BiodataTheme {
  BiodataTheme._();

  // ─── Colors ─────────────────────────────────────────────────────────────
  static const Color royalIvory = Color(0xFFFDFCF5);
  static const Color royalGold = Color(0xFFD4AF37);
  static const Color deepCharcoal = Color(0xFF1A1A1A);
  static const Color softGold = Color(0xFFF1E5AC);
  static const Color royalMaroon = Color(0xFF800000);
  static const Color surfaceWhite = Color(0xFFFFFFFF);
  static const Color surfaceLight = Color(0xFFF8F6F0);

  // ─── Spacing (logical px; scale via breakpoints in screen) ───────────────
  static const double spaceXs = 4.0;
  static const double spaceSm = 8.0;
  static const double spaceMd = 12.0;
  static const double spaceLg = 16.0;
  static const double spaceXl = 24.0;
  static const double radiusSm = 8.0;
  static const double radiusMd = 12.0;
  static const double radiusLg = 16.0;
  static const double radiusPill = 999.0;

  // ─── Gradients ──────────────────────────────────────────────────────────
  static const LinearGradient royalBackground = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFFFFFDF5),
      Color(0xFFF5F0E1),
    ],
  );

  static const LinearGradient goldGradient = LinearGradient(
    colors: [Color(0xFFD4AF37), Color(0xFFFFDF00), Color(0xFFD4AF37)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // ─── Typography ──────────────────────────────────────────────────────────
  static TextStyle get headerStyle => TextStyle(
        fontFamily: AppTheme.bodyFontFamily,
        fontSize: AppTypography.headingMedium,
        fontWeight: FontWeight.bold,
        color: deepCharcoal,
        letterSpacing: 1.2,
      );

  static TextStyle get subHeaderStyle => TextStyle(
        fontFamily: AppTheme.bodyFontFamily,
        fontSize: AppTypography.bodyMedium,
        fontWeight: FontWeight.w600,
        color: deepCharcoal.withValues(alpha: 0.85),
        letterSpacing: 0.5,
      );

  static TextStyle get bodyStyle => TextStyle(
        fontFamily: 'OpenSans',
        fontSize: AppTypography.bodyLarge,
        fontWeight: FontWeight.normal,
        color: deepCharcoal,
        height: 1.4,
      );

  static TextStyle get labelStyle => TextStyle(
        fontFamily: 'OpenSans',
        fontSize: AppTypography.bodySmall,
        fontWeight: FontWeight.w600,
        color: deepCharcoal.withValues(alpha: 0.65),
      );

  static TextStyle get captionStyle => TextStyle(
        fontFamily: 'OpenSans',
        fontSize: AppTypography.bodySmall,
        fontWeight: FontWeight.w500,
        color: deepCharcoal.withValues(alpha: 0.55),
      );

  // ─── Input decoration (global-level form fields) ──────────────────────────
  static InputDecoration inputDecoration({
    required String labelText,
    String? hintText,
    Widget? prefixIcon,
    bool filled = true,
  }) {
    return InputDecoration(
      labelText: labelText,
      hintText: hintText,
      prefixIcon: prefixIcon,
      filled: filled,
      fillColor: surfaceWhite,
      labelStyle: labelStyle,
      hintStyle: captionStyle,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(radiusMd),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(radiusMd),
        borderSide: BorderSide(color: deepCharcoal.withValues(alpha: 0.08)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(radiusMd),
        borderSide: const BorderSide(color: royalGold, width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(radiusMd),
        borderSide: BorderSide(color: Colors.red.shade400),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(radiusMd),
        borderSide: BorderSide(color: Colors.red.shade600, width: 1.5),
      ),
    );
  }

  // ─── Decorations ─────────────────────────────────────────────────────────
  static BoxDecoration get luxuryCardDecoration => BoxDecoration(
        color: surfaceWhite,
        borderRadius: BorderRadius.circular(radiusLg),
        boxShadow: [
          BoxShadow(
            color: deepCharcoal.withValues(alpha: 0.06),
            offset: const Offset(0, 4),
            blurRadius: 20,
          ),
          BoxShadow(
            color: royalGold.withValues(alpha: 0.08),
            offset: const Offset(0, 2),
            blurRadius: 8,
            spreadRadius: -2,
          ),
        ],
        border: Border.all(color: royalGold.withValues(alpha: 0.15)),
      );

  static BoxDecoration get glassEffect => BoxDecoration(
        color: surfaceWhite.withValues(alpha: 0.92),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 20,
            offset: const Offset(0, -4),
          ),
        ],
        border: Border(
          top: BorderSide(color: Colors.white.withValues(alpha: 0.6)),
        ),
      );

  /// Card for sections (e.g. expansion panels)
  static BoxDecoration sectionCardDecoration({bool elevated = true}) {
    return BoxDecoration(
      color: surfaceWhite,
      borderRadius: BorderRadius.circular(radiusMd),
      boxShadow: elevated
          ? [
              BoxShadow(
                color: deepCharcoal.withValues(alpha: 0.04),
                offset: const Offset(0, 2),
                blurRadius: 8,
              ),
            ]
          : null,
      border: Border.all(color: deepCharcoal.withValues(alpha: 0.06)),
    );
  }
}
