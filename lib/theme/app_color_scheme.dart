import 'package:flutter/material.dart';
import 'package:banjarabio/theme/app_colors.dart';

/// 🎨 Semantic Color Scheme — Auto-resolves light/dark via ThemeExtension.
///
/// Usage:
/// ```dart
/// final colors = context.colors;
/// color: colors.canvas,       // auto light/dark
/// color: colors.textPrimary,  // auto light/dark
/// ```
class AppColorScheme extends ThemeExtension<AppColorScheme> {
  // ─── Surfaces ───
  /// Main page/scaffold background
  final Color canvas;

  /// Card, sheet, dialog background
  final Color surface;

  /// Elevated card background (slightly lighter than surface in dark)
  final Color surfaceElevated;

  /// Text field / input fill
  final Color inputFill;

  // ─── Text ───
  /// Primary body text
  final Color textPrimary;

  /// Secondary/subtitle text
  final Color textSecondary;

  /// Disabled / placeholder text
  final Color textDisabled;

  /// Text on primary-colored backgrounds
  final Color textOnPrimary;

  /// Text on secondary-colored backgrounds
  final Color textOnSecondary;

  // ─── Brand ───
  /// Brand primary (Royal Crimson / soft pink-crimson)
  final Color primary;

  /// Deeper brand primary variant
  final Color primaryDeep;

  /// Brand secondary (Champagne Gold)
  final Color secondary;

  /// Deeper gold variant
  final Color secondaryDeep;

  // ─── Semantic Status ───
  /// Success accent
  final Color success;

  /// Success tinted background
  final Color successBg;

  /// Warning accent
  final Color warning;

  /// Warning tinted background
  final Color warningBg;

  /// Error accent
  final Color error;

  /// Error tinted background
  final Color errorBg;

  // ─── Structure ───
  /// Divider lines
  final Color divider;

  /// Card/input borders
  final Color border;

  /// Shadow color
  final Color shadow;

  // ─── Shimmer / Skeleton ───
  /// Skeleton loader base
  final Color shimmerBase;

  /// Skeleton loader highlight
  final Color shimmerHighlight;

  // ─── Cultural Accent ───
  /// Crimson accent (CTA, active)
  final Color crimsonAccent;

  /// Crimson tinted background
  final Color crimsonBg;

  /// Gold accent
  final Color goldAccent;

  /// Gold tinted background
  final Color goldBg;

  const AppColorScheme({
    required this.canvas,
    required this.surface,
    required this.surfaceElevated,
    required this.inputFill,
    required this.textPrimary,
    required this.textSecondary,
    required this.textDisabled,
    required this.textOnPrimary,
    required this.textOnSecondary,
    required this.primary,
    required this.primaryDeep,
    required this.secondary,
    required this.secondaryDeep,
    required this.success,
    required this.successBg,
    required this.warning,
    required this.warningBg,
    required this.error,
    required this.errorBg,
    required this.divider,
    required this.border,
    required this.shadow,
    required this.shimmerBase,
    required this.shimmerHighlight,
    required this.crimsonAccent,
    required this.crimsonBg,
    required this.goldAccent,
    required this.goldBg,
  });

  // ═══════════════════════════════════════════════════════════
  // LIGHT THEME
  // ═══════════════════════════════════════════════════════════
  factory AppColorScheme.light() => const AppColorScheme(
        canvas: AppColors.canvasLight,
        surface: AppColors.surfaceLight,
        surfaceElevated: AppColors.surfaceLight,
        inputFill: AppColors.neutral100,
        textPrimary: AppColors.cardDark,
        textSecondary: AppColors.textSecondary,
        textDisabled: AppColors.neutral500,
        textOnPrimary: AppColors.surfaceLight,
        textOnSecondary: AppColors.canvasNearBlack,
        primary: AppColors.primary,
        primaryDeep: AppColors.primaryDark,
        secondary: AppColors.gold,
        secondaryDeep: AppColors.goldDark,
        success: AppColors.success,
        successBg: AppColors.successLight,
        warning: AppColors.deepOrange, // WCAG fix: deepOrange (3.5:1) vs warning (2.6:1) on warningBg
        warningBg: AppColors.warningLight,
        error: AppColors.error,
        errorBg: AppColors.primaryLight,
        divider: AppColors.neutral300,
        border: AppColors.slate200,
        shadow: AppColors.shadowLight,
        shimmerBase: AppColors.slate200,
        shimmerHighlight: AppColors.slate100,
        crimsonAccent: AppColors.crimsonRose,
        crimsonBg: AppColors.primaryLight,
        goldAccent: AppColors.gold,
        goldBg: AppColors.goldLight,
      );

  // ═══════════════════════════════════════════════════════════
  // DARK THEME
  // ═══════════════════════════════════════════════════════════
  factory AppColorScheme.dark() => const AppColorScheme(
        canvas: AppColors.canvasDark,
        surface: AppColors.surfaceDark,
        surfaceElevated: AppColors.cardDark,
        inputFill: AppColors.surfaceDark,
        textPrimary: AppColors.neutral50,
        textSecondary: AppColors.textSecondaryDark,
        textDisabled: AppColors.neutral600,
        textOnPrimary: AppColors.primaryDark,
        textOnSecondary: AppColors.canvasNearBlack, // WCAG fix: 9.8:1 vs goldDark's 1.7:1 on goldDarkContrast
        primary: AppColors.primaryDarkContrast,
        primaryDeep: AppColors.crimson700,
        secondary: AppColors.goldDarkContrast,
        secondaryDeep: AppColors.darkGoldenrod,
        success: AppColors.successDark,
        successBg: AppColors.darkForest1,
        warning: AppColors.warningDark,
        warningBg: AppColors.amberBrownBg,
        error: AppColors.errorDark,
        errorBg: AppColors.bloodRedBg,
        divider: AppColors.neutral800,
        border: AppColors.slate700,
        shadow: AppColors.shadowDark,
        shimmerBase: AppColors.slate800,
        shimmerHighlight: AppColors.slate700,
        crimsonAccent: AppColors.crimsonBlush,
        crimsonBg: AppColors.crimsonBlack,
        goldAccent: AppColors.goldDarkContrast,
        goldBg: AppColors.amberBrownBg,
      );

  // ═══════════════════════════════════════════════════════════
  // ThemeExtension overrides
  // ═══════════════════════════════════════════════════════════
  @override
  AppColorScheme copyWith({
    Color? canvas,
    Color? surface,
    Color? surfaceElevated,
    Color? inputFill,
    Color? textPrimary,
    Color? textSecondary,
    Color? textDisabled,
    Color? textOnPrimary,
    Color? textOnSecondary,
    Color? primary,
    Color? primaryDeep,
    Color? secondary,
    Color? secondaryDeep,
    Color? success,
    Color? successBg,
    Color? warning,
    Color? warningBg,
    Color? error,
    Color? errorBg,
    Color? divider,
    Color? border,
    Color? shadow,
    Color? shimmerBase,
    Color? shimmerHighlight,
    Color? crimsonAccent,
    Color? crimsonBg,
    Color? goldAccent,
    Color? goldBg,
  }) {
    return AppColorScheme(
      canvas: canvas ?? this.canvas,
      surface: surface ?? this.surface,
      surfaceElevated: surfaceElevated ?? this.surfaceElevated,
      inputFill: inputFill ?? this.inputFill,
      textPrimary: textPrimary ?? this.textPrimary,
      textSecondary: textSecondary ?? this.textSecondary,
      textDisabled: textDisabled ?? this.textDisabled,
      textOnPrimary: textOnPrimary ?? this.textOnPrimary,
      textOnSecondary: textOnSecondary ?? this.textOnSecondary,
      primary: primary ?? this.primary,
      primaryDeep: primaryDeep ?? this.primaryDeep,
      secondary: secondary ?? this.secondary,
      secondaryDeep: secondaryDeep ?? this.secondaryDeep,
      success: success ?? this.success,
      successBg: successBg ?? this.successBg,
      warning: warning ?? this.warning,
      warningBg: warningBg ?? this.warningBg,
      error: error ?? this.error,
      errorBg: errorBg ?? this.errorBg,
      divider: divider ?? this.divider,
      border: border ?? this.border,
      shadow: shadow ?? this.shadow,
      shimmerBase: shimmerBase ?? this.shimmerBase,
      shimmerHighlight: shimmerHighlight ?? this.shimmerHighlight,
      crimsonAccent: crimsonAccent ?? this.crimsonAccent,
      crimsonBg: crimsonBg ?? this.crimsonBg,
      goldAccent: goldAccent ?? this.goldAccent,
      goldBg: goldBg ?? this.goldBg,
    );
  }

  @override
  AppColorScheme lerp(covariant AppColorScheme? other, double t) {
    if (other == null) return this;
    return AppColorScheme(
      canvas: Color.lerp(canvas, other.canvas, t)!,
      surface: Color.lerp(surface, other.surface, t)!,
      surfaceElevated: Color.lerp(surfaceElevated, other.surfaceElevated, t)!,
      inputFill: Color.lerp(inputFill, other.inputFill, t)!,
      textPrimary: Color.lerp(textPrimary, other.textPrimary, t)!,
      textSecondary: Color.lerp(textSecondary, other.textSecondary, t)!,
      textDisabled: Color.lerp(textDisabled, other.textDisabled, t)!,
      textOnPrimary: Color.lerp(textOnPrimary, other.textOnPrimary, t)!,
      textOnSecondary: Color.lerp(textOnSecondary, other.textOnSecondary, t)!,
      primary: Color.lerp(primary, other.primary, t)!,
      primaryDeep: Color.lerp(primaryDeep, other.primaryDeep, t)!,
      secondary: Color.lerp(secondary, other.secondary, t)!,
      secondaryDeep: Color.lerp(secondaryDeep, other.secondaryDeep, t)!,
      success: Color.lerp(success, other.success, t)!,
      successBg: Color.lerp(successBg, other.successBg, t)!,
      warning: Color.lerp(warning, other.warning, t)!,
      warningBg: Color.lerp(warningBg, other.warningBg, t)!,
      error: Color.lerp(error, other.error, t)!,
      errorBg: Color.lerp(errorBg, other.errorBg, t)!,
      divider: Color.lerp(divider, other.divider, t)!,
      border: Color.lerp(border, other.border, t)!,
      shadow: Color.lerp(shadow, other.shadow, t)!,
      shimmerBase: Color.lerp(shimmerBase, other.shimmerBase, t)!,
      shimmerHighlight: Color.lerp(shimmerHighlight, other.shimmerHighlight, t)!,
      crimsonAccent: Color.lerp(crimsonAccent, other.crimsonAccent, t)!,
      crimsonBg: Color.lerp(crimsonBg, other.crimsonBg, t)!,
      goldAccent: Color.lerp(goldAccent, other.goldAccent, t)!,
      goldBg: Color.lerp(goldBg, other.goldBg, t)!,
    );
  }
}

/// Convenience extension for quick access via `context.colors`
extension AppColorSchemeX on BuildContext {
  /// Access the current theme's [AppColorScheme].
  ///
  /// ```dart
  /// final colors = context.colors;
  /// Container(color: colors.canvas);
  /// Text('Hello', style: TextStyle(color: colors.textPrimary));
  /// ```
  AppColorScheme get colors =>
      Theme.of(this).extension<AppColorScheme>()!;
}
