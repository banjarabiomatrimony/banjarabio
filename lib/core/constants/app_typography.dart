import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

/// 🔤 CENTRALIZED TYPOGRAPHY DESIGN SYSTEM FOR BANJARABIO
///
/// Single source of truth for all typography scales, font families, font weights,
/// line heights, letter spacings, and text style generators across the whole app.
///
/// Design Principles & Guidelines:
/// - Minimum user-facing readable font size: 11sp (never smaller than 10sp)
/// - Indic-script body text readability: 13–15sp with comfortable line height (1.35–1.5)
/// - Primary Content & Profile details: 14–16sp
/// - Card Titles & Section Headings: 16–18sp
/// - Screen & AppBar Titles: 20–24sp
/// - Hero Metrics & Large Badges: 28–32sp
/// - Heading Font Family: `Outfit` (Cultural, Elegant, Modern)
/// - Body Font Family: `PlusJakartaSans` (Clean, Legible across scripts)
class AppTypography {
  AppTypography._();

  // ---------------------------------------------------------------------------
  // 🏷️ FONT FAMILIES
  // ---------------------------------------------------------------------------
  static const String headingFontFamily = 'Outfit';
  static const String bodyFontFamily = 'PlusJakartaSans';

  // ---------------------------------------------------------------------------
  // ⚖️ FONT WEIGHTS
  // ---------------------------------------------------------------------------
  static const FontWeight light = FontWeight.w300;
  static const FontWeight regular = FontWeight.w400;
  static const FontWeight medium = FontWeight.w500;
  static const FontWeight semiBold = FontWeight.w600;
  static const FontWeight bold = FontWeight.w700;
  static const FontWeight extraBold = FontWeight.w800;
  static const FontWeight black = FontWeight.w900;

  // ---------------------------------------------------------------------------
  // 📐 LINE HEIGHTS
  // ---------------------------------------------------------------------------
  static const double lineHeightTight = 1.15;
  static const double lineHeightStandard = 1.35;
  static const double lineHeightRelaxed = 1.5;
  static const double lineHeightLoose = 1.65;

  // ---------------------------------------------------------------------------
  // ↔️ LETTER SPACINGS
  // ---------------------------------------------------------------------------
  static const double letterSpacingTight = -0.5;
  static const double letterSpacingNormal = 0.0;
  static const double letterSpacingWide = 0.4;
  static const double letterSpacingExtraWide = 1.25;

  // ---------------------------------------------------------------------------
  // 🛡️ SIZER RESILIENCE HELPER
  // ---------------------------------------------------------------------------
  static double _safeSp(num spVal, double fallback) {
    try {
      return spVal.sp;
    } catch (_) {
      return fallback;
    }
  }

  // ---------------------------------------------------------------------------
  // 🌟 RESPONSIVE DISPLAY SCALE (Sizer Scaled with Safe Fallback)
  // ---------------------------------------------------------------------------

  /// Hero banners, welcome splash screens, celebration numbers. (32sp)
  static double get displayLarge => _safeSp(32, displayLargeFixed);

  /// Secondary display headers, featured count indicators. (28sp)
  static double get displayMedium => _safeSp(28, displayMediumFixed);

  /// Compact display badges, highlight banners. (26sp)
  static double get displaySmall => _safeSp(26, displaySmallFixed);

  // ---------------------------------------------------------------------------
  // 🏛️ HEADINGS SCALE (Sizer Scaled with Safe Fallback)
  // ---------------------------------------------------------------------------

  /// Primary screen titles, custom app bar titles. (24sp)
  static double get headingLarge => _safeSp(24, headingLargeFixed);

  /// Main section headings, modal dialog titles, featured card headers. (18sp)
  static double get headingMedium => _safeSp(18, headingMediumFixed);

  /// Sub-section headers, card titles, category section headers. (16sp)
  static double get headingSmall => _safeSp(16, headingSmallFixed);

  // ---------------------------------------------------------------------------
  // 📌 TITLES SCALE (Sizer Scaled with Safe Fallback)
  // ---------------------------------------------------------------------------

  /// Large card titles, profile screen headline. (20sp)
  static double get titleLarge => _safeSp(20, titleLargeFixed);

  /// Standard section titles, list group titles. (16sp)
  static double get titleMedium => _safeSp(16, titleMediumFixed);

  /// Minor group headers, input field titles. (14sp)
  static double get titleSmall => _safeSp(14, titleSmallFixed);

  // ---------------------------------------------------------------------------
  // 📄 BODY SCALE (Sizer Scaled with Safe Fallback)
  // ---------------------------------------------------------------------------

  /// Primary body content, profile names, bios, description text. (16sp)
  static double get bodyLarge => _safeSp(16, bodyLargeFixed);

  /// Standard body text, form input content, secondary subtitles. (14sp)
  static double get bodyMedium => _safeSp(14, bodyMediumFixed);

  /// Secondary information, captions, helper info, timestamp text. (12sp)
  static double get bodySmall => _safeSp(12, bodySmallFixed);

  /// Compact helper text, footnote captions. Minimum readable baseline. (11sp)
  static double get bodyExtraSmall => _safeSp(11, bodyExtraSmallFixed);

  // ---------------------------------------------------------------------------
  // 🏷️ LABELS, BUTTONS & ACTIONS SCALE (Sizer Scaled with Safe Fallback)
  // ---------------------------------------------------------------------------

  /// Prominent CTA button text, primary tab labels. (14sp)
  static double get labelLarge => _safeSp(14, labelLargeFixed);

  /// Standard buttons, filter chips, action pills, badges. (12sp)
  static double get labelMedium => _safeSp(12, labelMediumFixed);

  /// Compact tags, trust score badges, status pills, count badges. (11sp)
  static double get labelSmall => _safeSp(11, labelSmallFixed);

  /// Micro chips, timestamp badges, super-compact indicators. (10sp)
  static double get labelTiny => _safeSp(10, labelTinyFixed);

  // ---------------------------------------------------------------------------
  // 📏 FIXED SIZES (Fallback for Canvas, PDF Painters & Pre-Sizer contexts)
  // ---------------------------------------------------------------------------
  static const double displayLargeFixed = 32.0;
  static const double displayMediumFixed = 28.0;
  static const double displaySmallFixed = 26.0;

  static const double headingLargeFixed = 24.0;
  static const double headingMediumFixed = 18.0;
  static const double headingSmallFixed = 16.0;

  static const double titleLargeFixed = 20.0;
  static const double titleMediumFixed = 16.0;
  static const double titleSmallFixed = 14.0;

  static const double bodyLargeFixed = 16.0;
  static const double bodyMediumFixed = 14.0;
  static const double bodySmallFixed = 12.0;
  static const double bodyExtraSmallFixed = 11.0;

  static const double labelLargeFixed = 14.0;
  static const double labelMediumFixed = 12.0;
  static const double labelSmallFixed = 11.0;
  static const double labelTinyFixed = 10.0;

  // ---------------------------------------------------------------------------
  // 🎨 READY-TO-USE TEXTSTYLE BUILDERS
  // ---------------------------------------------------------------------------

  /// Creates a styled display headline text style with `Outfit` font family.
  static TextStyle displayStyle({
    Color? color,
    FontWeight fontWeight = FontWeight.w900,
    double? fontSize,
    double? height,
    double? letterSpacing,
    List<Shadow>? shadows,
  }) {
    return TextStyle(
      fontFamily: headingFontFamily,
      fontSize: fontSize ?? displayLarge,
      fontWeight: fontWeight,
      color: color,
      height: height,
      letterSpacing: letterSpacing,
      shadows: shadows,
    );
  }

  /// Creates a styled primary heading text style with `Outfit` font family.
  static TextStyle headingStyle({
    Color? color,
    FontWeight fontWeight = FontWeight.w800,
    double? fontSize,
    double? height,
    double? letterSpacing,
    List<Shadow>? shadows,
  }) {
    return TextStyle(
      fontFamily: headingFontFamily,
      fontSize: fontSize ?? headingLarge,
      fontWeight: fontWeight,
      color: color,
      height: height,
      letterSpacing: letterSpacing,
      shadows: shadows,
    );
  }

  /// Creates a styled section title text style with `Outfit` font family.
  static TextStyle titleStyle({
    Color? color,
    FontWeight fontWeight = FontWeight.w700,
    double? fontSize,
    double? height,
    double? letterSpacing,
  }) {
    return TextStyle(
      fontFamily: headingFontFamily,
      fontSize: fontSize ?? titleMedium,
      fontWeight: fontWeight,
      color: color,
      height: height,
      letterSpacing: letterSpacing,
    );
  }

  /// Creates a styled body text style with `PlusJakartaSans` font family.
  static TextStyle bodyStyle({
    Color? color,
    FontWeight fontWeight = FontWeight.w400,
    double? fontSize,
    double? height,
    double? letterSpacing,
    TextDecoration? decoration,
  }) {
    return TextStyle(
      fontFamily: bodyFontFamily,
      fontSize: fontSize ?? bodyMedium,
      fontWeight: fontWeight,
      color: color,
      height: height,
      letterSpacing: letterSpacing,
      decoration: decoration,
    );
  }

  /// Creates a styled label/button text style with `PlusJakartaSans` font family.
  static TextStyle labelStyle({
    Color? color,
    FontWeight fontWeight = FontWeight.w700,
    double? fontSize,
    double? height,
    double? letterSpacing,
  }) {
    return TextStyle(
      fontFamily: bodyFontFamily,
      fontSize: fontSize ?? labelMedium,
      fontWeight: fontWeight,
      color: color,
      height: height,
      letterSpacing: letterSpacing,
    );
  }

  /// Creates a styled caption/helper text style with `PlusJakartaSans` font family.
  static TextStyle captionStyle({
    Color? color,
    FontWeight fontWeight = FontWeight.w500,
    double? fontSize,
    double? height,
    double? letterSpacing,
  }) {
    return TextStyle(
      fontFamily: bodyFontFamily,
      fontSize: fontSize ?? bodySmall,
      fontWeight: fontWeight,
      color: color,
      height: height,
      letterSpacing: letterSpacing,
    );
  }

  /// Creates a styled button CTA text style with `PlusJakartaSans` font family.
  static TextStyle buttonStyle({
    Color color = Colors.white,
    FontWeight fontWeight = FontWeight.w800,
    double? fontSize,
    double? letterSpacing,
  }) {
    return TextStyle(
      fontFamily: bodyFontFamily,
      fontSize: fontSize ?? labelLarge,
      fontWeight: fontWeight,
      color: color,
      letterSpacing: letterSpacing,
    );
  }
}
