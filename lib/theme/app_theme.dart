import 'package:flutter/material.dart';
import 'package:banjarabio/core/constants/app_typography.dart';
import 'package:banjarabio/theme/app_category_theme.dart';
import 'package:banjarabio/theme/app_color_scheme.dart';
import 'package:banjarabio/theme/app_colors.dart';

/// A class that contains all theme configurations for the Banjara matrimonial application.
/// Implements Cultural Minimalism design style with Warm Trust Palette colors.
class AppTheme {
  AppTheme._();

  // Typography definitions — delegates to AppTypography as single source of truth
  static const String headingFontFamily = AppTypography.headingFontFamily;
  static const String bodyFontFamily = AppTypography.bodyFontFamily;

  // Primary color palette - Royal Crimson & Champagne Gold
  static const Color primaryLight = AppColors.primary; // Royal Crimson (Sacred/Love)
  static const Color primaryVariantLight = AppColors.primaryDark; // Deeper Maroon/Crimson
  static const Color secondaryLight = AppColors.gold; // Champagne Gold (Tradition/Warmth)
  static const Color secondaryVariantLight = AppColors.goldDark; // Darker Gold
  static const Color backgroundLight = AppColors.canvasLight; // Soft Warm Ivory
  static const Color surfaceLight = AppColors.surfaceLight; // Pure white
  static const Color errorLight = AppColors.error; // Refined Material error
  static const Color successLight = AppColors.success; // Standard success green
  static const Color successVariantLight = AppColors.success; // Deeper success green
  static const Color warningLight = AppColors.warning; // Warm orange
  static const Color onPrimaryLight = AppColors.surfaceLight; // White on Crimson
  static const Color onSecondaryLight = AppColors.canvasNearBlack; // Dark on Gold
  static const Color onBackgroundLight = AppColors.warmDarkText; // Warm dark-gray for reading
  static const Color onSurfaceLight = AppColors.warmDarkText;
  static const Color onErrorLight = AppColors.surfaceLight;

  // Dark theme colors
  static const Color primaryDark = AppColors.primaryDarkContrast; // Soft pinkish-crimson for Dark Mode contrast
  static const Color primaryVariantDark = AppColors.crimson700; // Deeper Crimson
  static const Color secondaryDark = AppColors.goldDarkContrast; // Soft Champagne Gold
  static const Color secondaryVariantDark = AppColors.darkGoldenrod; // Deeper Gold
  static const Color backgroundDark = AppColors.canvasDark; // Deep Warm Charcoal/Dark Mahogany
  static const Color surfaceDark = AppColors.surfaceDark; // Elevated warm dark surface
  static const Color errorDark = AppColors.errorDark;
  static const Color successDark = AppColors.successDark;
  static const Color warningDark = AppColors.warningDark;
  static const Color onPrimaryDark = AppColors.primaryDark;
  static const Color onSecondaryDark = AppColors.goldDark;
  static const Color onBackgroundDark = AppColors.neutral50;
  static const Color onSurfaceDark = AppColors.neutral50;
  static const Color onErrorDark = AppColors.wineDark;

  // Card and dialog colors
  static const Color cardLight = AppColors.surfaceLight;
  static const Color cardDark = AppColors.cardDark;
  static const Color dialogLight = AppColors.surfaceLight;
  static const Color dialogDark = AppColors.cardDark;

  // Shadow colors - Minimal elevation strategy
  static const Color shadowLight = AppColors.shadowLight;
  static const Color shadowDark = AppColors.shadowDark;

  // Divider colors - Structural clarity
  static const Color dividerLight = AppColors.neutral300;
  static const Color dividerDark = AppColors.neutral800;

  // Text colors with cultural sensitivity
  static const Color textPrimaryLight = AppColors.cardDark;
  static const Color textSecondaryLight = AppColors.textSecondary;
  static const Color textDisabledLight = AppColors.neutral500;

  static const Color textPrimaryDark = AppColors.neutral50;
  static const Color textSecondaryDark = AppColors.textSecondaryDark;
  static const Color textDisabledDark = AppColors.neutral600;

  /// Light theme with Cultural Minimalism design
  static ThemeData lightTheme = ThemeData(
    brightness: Brightness.light,
    useMaterial3: true,
    colorScheme: const ColorScheme(
      brightness: Brightness.light,
      primary: primaryLight,
      onPrimary: onPrimaryLight,
      primaryContainer: primaryVariantLight,
      onPrimaryContainer: onPrimaryLight,
      secondary: secondaryLight,
      onSecondary: onSecondaryLight,
      secondaryContainer: secondaryVariantLight,
      onSecondaryContainer: onSecondaryLight,
      tertiary: secondaryLight,
      onTertiary: onSecondaryLight,
      tertiaryContainer: secondaryVariantLight,
      onTertiaryContainer: onSecondaryLight,
      error: errorLight,
      onError: onErrorLight,
      surface: surfaceLight,
      onSurface: onSurfaceLight,
      onSurfaceVariant: textSecondaryLight,
      outline: dividerLight,
      outlineVariant: dividerLight,
      shadow: shadowLight,
      scrim: shadowLight,
      inverseSurface: surfaceDark,
      onInverseSurface: onSurfaceDark,
      inversePrimary: primaryDark,
    ),
    scaffoldBackgroundColor: backgroundLight,
    cardColor: cardLight,
    // Provide a native scroll feel for high-end devices and Web
    platform: TargetPlatform.iOS,
    dividerColor: dividerLight,

    // AppBar theme with premium Amethyst profile
    appBarTheme: AppBarThemeData(
      backgroundColor: primaryLight, // Amethyst AppBar for premium identity
      foregroundColor: onPrimaryLight,
      elevation: 0,
      centerTitle: true,
      titleTextStyle: TextStyle(fontFamily: headingFontFamily,
        fontSize: AppTypography.headingMedium,
        fontWeight: FontWeight.w700,
        color: onPrimaryLight,
        letterSpacing: 0.5,
      ),
      iconTheme: const IconThemeData(color: onPrimaryLight, size: 24),
    ),

    // Card theme with premium Amethyst shadows
    cardTheme: CardThemeData(
      color: cardLight,
      elevation: 12, // More pronounced premium elevation
      shadowColor: primaryLight.withValues(alpha: 0.12), // Amethyst-tinted shadow
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(28.0), // Even softer radius
        side: BorderSide(
          color: primaryLight.withValues(alpha: 0.05),
          width: 0.5,
        ), // Ultra-subtle border
      ),
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    ),

    // Bottom navigation with thumb-reach optimization
    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      backgroundColor: surfaceLight,
      selectedItemColor: primaryLight,
      unselectedItemColor: textSecondaryLight,
      selectedLabelStyle: TextStyle(
        fontFamily: bodyFontFamily,
        fontSize: AppTypography.bodyMedium,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.4,
      ),
      unselectedLabelStyle: TextStyle(
        fontFamily: bodyFontFamily,
        fontSize: AppTypography.bodyMedium,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.4,
      ),
      type: BottomNavigationBarType.fixed,
      elevation: 0, // Remove default elevation, rely on container shadow
    ),

    // FAB theme for contextual actions
    floatingActionButtonTheme: FloatingActionButtonThemeData(
      backgroundColor: secondaryLight,
      foregroundColor: onSecondaryLight,
      elevation: 4.0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.0)),
    ),

    // Button themes with cultural appropriateness
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        foregroundColor: onPrimaryLight,
        backgroundColor: primaryLight,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        elevation: 0, // Flat premium design
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.0), // Consistent radius
        ),
        textStyle: TextStyle(fontFamily: bodyFontFamily,
          fontSize: AppTypography.bodyLarge,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.5,
        ),
        minimumSize: const Size(88, 52),
      ),
    ),

    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: primaryLight,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        side: const BorderSide(color: primaryLight, width: 1.5),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.0),
        ),
        textStyle: TextStyle(fontFamily: bodyFontFamily,
          fontSize: AppTypography.bodyLarge,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.5,
        ),
        minimumSize: const Size(88, 52),
      ),
    ),

    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: primaryLight,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.0),
        ),
        textStyle: TextStyle(fontFamily: bodyFontFamily,
          fontSize: AppTypography.bodyLarge,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.5,
        ),
        minimumSize: const Size(88, 52),
      ),
    ),

    // Text theme with Outfit for headings and PlusJakartaSans for body
    textTheme: _buildTextTheme(isLight: true),

    // Input decoration with cultural sensitivity - Modernized
    inputDecorationTheme: InputDecorationThemeData(
      fillColor: AppColors.neutral100, // Very soft grey/blue tint
      filled: true,
      contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16.0),
        borderSide: BorderSide.none, // Clean look
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16.0),
        borderSide: const BorderSide(color: Colors.transparent, width: 0),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16.0),
        borderSide: const BorderSide(color: primaryLight, width: 2.0),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16.0),
        borderSide: const BorderSide(color: errorLight),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16.0),
        borderSide: const BorderSide(color: errorLight, width: 2.0),
      ),
      labelStyle: TextStyle(
        fontFamily: bodyFontFamily,
        fontSize: AppTypography.bodyLarge,
        fontWeight: FontWeight.w500,
        color: textSecondaryLight,
      ),
      hintStyle: TextStyle(
        fontFamily: bodyFontFamily,
        fontSize: AppTypography.bodyLarge,
        fontWeight: FontWeight.w400,
        color: textDisabledLight,
      ),
      errorStyle: TextStyle(
        fontFamily: bodyFontFamily,
        fontSize: AppTypography.bodyMedium,
        fontWeight: FontWeight.w500,
        color: errorLight,
        letterSpacing: 0.4,
      ),
    ),

    // Switch theme
    switchTheme: SwitchThemeData(
      thumbColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return primaryLight;
        }
        return textDisabledLight;
      }),
      trackColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return primaryLight.withValues(alpha: 0.5);
        }
        return textDisabledLight.withValues(alpha: 0.3);
      }),
    ),

    // Checkbox theme
    checkboxTheme: CheckboxThemeData(
      fillColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return primaryLight;
        }
        return Colors.transparent;
      }),
      checkColor: WidgetStateProperty.all(onPrimaryLight),
      side: const BorderSide(color: dividerLight, width: 2.0),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4.0)),
    ),

    // Radio theme
    radioTheme: RadioThemeData(
      fillColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return primaryLight;
        }
        return textSecondaryLight;
      }),
    ),

    // Progress indicator theme
    progressIndicatorTheme: const ProgressIndicatorThemeData(
      color: primaryLight,
      linearTrackColor: dividerLight,
    ),

    // Slider theme
    sliderTheme: SliderThemeData(
      activeTrackColor: primaryLight,
      thumbColor: primaryLight,
      overlayColor: primaryLight.withValues(alpha: 0.2),
      inactiveTrackColor: dividerLight,
      valueIndicatorColor: primaryLight,
      valueIndicatorTextStyle: TextStyle(
        fontFamily: bodyFontFamily,
        fontSize: AppTypography.bodyMedium,
        fontWeight: FontWeight.w500,
        color: onPrimaryLight,
      ),
    ),

    // Tab bar theme
    tabBarTheme: TabBarThemeData(
      labelColor: primaryLight,
      unselectedLabelColor: textSecondaryLight,
      indicatorColor: primaryLight,
      indicatorSize: TabBarIndicatorSize.label,
      labelStyle: TextStyle(
        fontFamily: bodyFontFamily,
        fontSize: AppTypography.bodyLarge,
        fontWeight: FontWeight.w500,
        letterSpacing: 1.25,
      ),
      unselectedLabelStyle: TextStyle(
        fontFamily: bodyFontFamily,
        fontSize: AppTypography.bodyLarge,
        fontWeight: FontWeight.w400,
        letterSpacing: 1.25,
      ),
    ),

    // Tooltip theme
    tooltipTheme: TooltipThemeData(
      decoration: BoxDecoration(
        color: textPrimaryLight.withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(4),
      ),
      textStyle: TextStyle(
        fontFamily: bodyFontFamily,
        fontSize: AppTypography.bodyMedium,
        fontWeight: FontWeight.w400,
        color: surfaceLight,
        letterSpacing: 0.4,
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
    ),

    // SnackBar theme
    snackBarTheme: SnackBarThemeData(
      backgroundColor: textPrimaryLight,
      contentTextStyle: TextStyle(
        fontFamily: bodyFontFamily,
        fontSize: AppTypography.bodyLarge,
        fontWeight: FontWeight.w400,
        color: surfaceLight,
        letterSpacing: 0.25,
      ),
      actionTextColor: secondaryLight,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
      elevation: 4.0,
    ),

    // Bottom sheet theme
    bottomSheetTheme: const BottomSheetThemeData(
      backgroundColor: surfaceLight,
      elevation: 8.0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16.0)),
      ),
    ),

    // Dialog theme
    dialogTheme: DialogThemeData(
      backgroundColor: dialogLight,
      elevation: 4.0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
      titleTextStyle: TextStyle(fontFamily: headingFontFamily,
        fontSize: AppTypography.headingMedium,
        fontWeight: FontWeight.w600,
        color: textPrimaryLight,
        letterSpacing: 0.15,
      ),
      contentTextStyle: TextStyle(
        fontFamily: bodyFontFamily,
        fontSize: AppTypography.bodyLarge,
        fontWeight: FontWeight.w400,
        color: textPrimaryLight,
        letterSpacing: 0.5,
      ),
    ),

    // Chip theme
    chipTheme: ChipThemeData(
      backgroundColor: surfaceLight,
      selectedColor: primaryLight.withValues(alpha: 0.2),
      disabledColor: dividerLight,
      labelStyle: TextStyle(
        fontFamily: bodyFontFamily,
        fontSize: AppTypography.bodyLarge,
        fontWeight: FontWeight.w400,
        color: textPrimaryLight,
        letterSpacing: 0.25,
      ),
      secondaryLabelStyle: TextStyle(
        fontFamily: bodyFontFamily,
        fontSize: AppTypography.bodyLarge,
        fontWeight: FontWeight.w400,
        color: textSecondaryLight,
        letterSpacing: 0.25,
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8.0),
        side: const BorderSide(color: dividerLight),
      ),
    ),
    extensions: [
      AppCategoryTheme.light(),
      AppColorScheme.light(),
    ],
  );

  /// Dark theme with Cultural Minimalism design
  static ThemeData darkTheme = ThemeData(
    brightness: Brightness.dark,
    useMaterial3: true,
    colorScheme: const ColorScheme(
      brightness: Brightness.dark,
      primary: primaryDark,
      onPrimary: onPrimaryDark,
      primaryContainer: primaryVariantDark,
      onPrimaryContainer: onPrimaryDark,
      secondary: secondaryDark,
      onSecondary: onSecondaryDark,
      secondaryContainer: secondaryVariantDark,
      onSecondaryContainer: onSecondaryDark,
      tertiary: secondaryDark,
      onTertiary: onSecondaryDark,
      tertiaryContainer: secondaryVariantDark,
      onTertiaryContainer: onSecondaryDark,
      error: errorDark,
      onError: onErrorDark,
      surface: surfaceDark,
      onSurface: onSurfaceDark,
      onSurfaceVariant: textSecondaryDark,
      outline: dividerDark,
      outlineVariant: dividerDark,
      shadow: shadowDark,
      scrim: shadowDark,
      inverseSurface: surfaceLight,
      onInverseSurface: onSurfaceLight,
      inversePrimary: primaryLight,
    ),
    scaffoldBackgroundColor: backgroundDark,
    cardColor: cardDark,
    // Provide a native scroll feel for high-end devices and Web
    platform: TargetPlatform.iOS,
    dividerColor: dividerDark,

    appBarTheme: AppBarThemeData(
      backgroundColor: surfaceDark,
      foregroundColor: textPrimaryDark,
      elevation: 0,
      centerTitle: true,
      titleTextStyle: TextStyle(fontFamily: headingFontFamily,
        fontSize: AppTypography.headingMedium,
        fontWeight: FontWeight.w700,
        color: textPrimaryDark,
        letterSpacing: 0.5,
      ),
      iconTheme: const IconThemeData(color: textPrimaryDark, size: 24),
    ),

    cardTheme: CardThemeData(
      color: cardDark,
      elevation: 8.0,
      shadowColor: primaryDark.withValues(alpha: 0.15),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24.0),
        side: BorderSide(color: dividerDark.withValues(alpha: 0.5)),
      ),
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    ),

    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      backgroundColor: surfaceDark,
      selectedItemColor: primaryDark,
      unselectedItemColor: textSecondaryDark,
      selectedLabelStyle: TextStyle(
        fontFamily: bodyFontFamily,
        fontSize: AppTypography.bodyMedium,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.4,
      ),
      unselectedLabelStyle: TextStyle(
        fontFamily: bodyFontFamily,
        fontSize: AppTypography.bodyMedium,
        fontWeight: FontWeight.w400,
        letterSpacing: 0.4,
      ),
      type: BottomNavigationBarType.fixed,
      elevation: 8.0,
    ),

    floatingActionButtonTheme: FloatingActionButtonThemeData(
      backgroundColor: secondaryDark,
      foregroundColor: onSecondaryDark,
      elevation: 4.0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.0)),
    ),

    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        foregroundColor: onPrimaryDark,
        backgroundColor: primaryDark,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.0),
        ),
        textStyle: TextStyle(
          fontFamily: bodyFontFamily,
          fontSize: AppTypography.bodyLarge,
          fontWeight: FontWeight.bold,
          letterSpacing: 0.5,
        ),
        minimumSize: const Size(88, 52),
      ),
    ),

    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: primaryDark,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        side: const BorderSide(color: primaryDark, width: 1.5),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.0),
        ),
        textStyle: TextStyle(
          fontFamily: bodyFontFamily,
          fontSize: AppTypography.bodyLarge,
          fontWeight: FontWeight.bold,
          letterSpacing: 0.5,
        ),
        minimumSize: const Size(88, 52),
      ),
    ),

    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: primaryDark,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.0),
        ),
        textStyle: TextStyle(
          fontFamily: bodyFontFamily,
          fontSize: AppTypography.bodyLarge,
          fontWeight: FontWeight.bold,
          letterSpacing: 0.5,
        ),
        minimumSize: const Size(88, 52),
      ),
    ),

    textTheme: _buildTextTheme(isLight: false),

    inputDecorationTheme: InputDecorationThemeData(
      fillColor: AppColors.surfaceDark, // Slightly lighter than background
      filled: true,
      contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16.0),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16.0),
        borderSide: const BorderSide(color: Colors.transparent, width: 0),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16.0),
        borderSide: const BorderSide(color: primaryDark, width: 2.0),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16.0),
        borderSide: const BorderSide(color: errorDark),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16.0),
        borderSide: const BorderSide(color: errorDark, width: 2.0),
      ),
      labelStyle: TextStyle(
        fontFamily: bodyFontFamily,
        fontSize: AppTypography.bodyLarge,
        fontWeight: FontWeight.w400,
        color: textSecondaryDark,
        letterSpacing: 0.15,
      ),
      hintStyle: TextStyle(
        fontFamily: bodyFontFamily,
        fontSize: AppTypography.bodyLarge,
        fontWeight: FontWeight.w400,
        color: textDisabledDark,
        letterSpacing: 0.15,
      ),
      errorStyle: TextStyle(
        fontFamily: bodyFontFamily,
        fontSize: AppTypography.bodyMedium,
        fontWeight: FontWeight.w500,
        color: errorDark,
        letterSpacing: 0.4,
      ),
    ),

    switchTheme: SwitchThemeData(
      thumbColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return primaryDark;
        }
        return textDisabledDark;
      }),
      trackColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return primaryDark.withValues(alpha: 0.5);
        }
        return textDisabledDark.withValues(alpha: 0.3);
      }),
    ),

    checkboxTheme: CheckboxThemeData(
      fillColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return primaryDark;
        }
        return Colors.transparent;
      }),
      checkColor: WidgetStateProperty.all(onPrimaryDark),
      side: const BorderSide(color: dividerDark, width: 2.0),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4.0)),
    ),

    radioTheme: RadioThemeData(
      fillColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return primaryDark;
        }
        return textSecondaryDark;
      }),
    ),

    progressIndicatorTheme: const ProgressIndicatorThemeData(
      color: primaryDark,
      linearTrackColor: dividerDark,
    ),

    sliderTheme: SliderThemeData(
      activeTrackColor: primaryDark,
      thumbColor: primaryDark,
      overlayColor: primaryDark.withValues(alpha: 0.2),
      inactiveTrackColor: dividerDark,
      valueIndicatorColor: primaryDark,
      valueIndicatorTextStyle: TextStyle(
        fontFamily: bodyFontFamily,
        fontSize: AppTypography.bodyMedium,
        fontWeight: FontWeight.w500,
        color: onPrimaryDark,
      ),
    ),

    tabBarTheme: TabBarThemeData(
      labelColor: primaryDark,
      unselectedLabelColor: textSecondaryDark,
      indicatorColor: primaryDark,
      indicatorSize: TabBarIndicatorSize.label,
      labelStyle: TextStyle(
        fontFamily: bodyFontFamily,
        fontSize: AppTypography.bodyLarge,
        fontWeight: FontWeight.w500,
        letterSpacing: 1.25,
      ),
      unselectedLabelStyle: TextStyle(
        fontFamily: bodyFontFamily,
        fontSize: AppTypography.bodyLarge,
        fontWeight: FontWeight.w400,
        letterSpacing: 1.25,
      ),
    ),

    tooltipTheme: TooltipThemeData(
      decoration: BoxDecoration(
        color: textPrimaryDark.withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(4),
      ),
      textStyle: TextStyle(
        fontFamily: bodyFontFamily,
        fontSize: AppTypography.bodyMedium,
        fontWeight: FontWeight.w400,
        color: surfaceDark,
        letterSpacing: 0.4,
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
    ),

    snackBarTheme: SnackBarThemeData(
      backgroundColor: textPrimaryDark,
      contentTextStyle: TextStyle(
        fontFamily: bodyFontFamily,
        fontSize: AppTypography.bodyLarge,
        fontWeight: FontWeight.w400,
        color: surfaceDark,
        letterSpacing: 0.25,
      ),
      actionTextColor: secondaryDark,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
      elevation: 4.0,
    ),

    bottomSheetTheme: const BottomSheetThemeData(
      backgroundColor: surfaceDark,
      elevation: 8.0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16.0)),
      ),
    ),

    dialogTheme: DialogThemeData(
      backgroundColor: dialogDark,
      elevation: 4.0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
      titleTextStyle: TextStyle(fontFamily: headingFontFamily,
        fontSize: AppTypography.headingMedium,
        fontWeight: FontWeight.w600,
        color: textPrimaryDark,
        letterSpacing: 0.15,
      ),
      contentTextStyle: TextStyle(
        fontFamily: bodyFontFamily,
        fontSize: AppTypography.bodyLarge,
        fontWeight: FontWeight.w400,
        color: textPrimaryDark,
        letterSpacing: 0.5,
      ),
    ),

    chipTheme: ChipThemeData(
      backgroundColor: surfaceDark,
      selectedColor: primaryDark.withValues(alpha: 0.2),
      disabledColor: dividerDark,
      labelStyle: TextStyle(
        fontFamily: bodyFontFamily,
        fontSize: AppTypography.bodyLarge,
        fontWeight: FontWeight.w400,
        color: textPrimaryDark,
        letterSpacing: 0.25,
      ),
      secondaryLabelStyle: TextStyle(
        fontFamily: bodyFontFamily,
        fontSize: AppTypography.bodyLarge,
        fontWeight: FontWeight.w400,
        color: textSecondaryDark,
        letterSpacing: 0.25,
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8.0),
        side: const BorderSide(color: dividerDark),
      ),
    ),
    extensions: [
      AppCategoryTheme.dark(),
      AppColorScheme.dark(),
    ],
  );

  /// Helper method to build text theme based on brightness
  /// Uses Outfit for headings and PlusJakartaSans for body text
  static TextTheme _buildTextTheme({required bool isLight}) {
    final Color textPrimary = isLight ? textPrimaryLight : textPrimaryDark;

    return TextTheme(
      // Display styles - Outfit for prominent headers
      displayLarge: TextStyle(
        fontFamily: headingFontFamily,
        fontSize: AppTypography.displayLarge,
        fontWeight: FontWeight.w400,
        color: textPrimary,
        letterSpacing: -0.25,
      ),
      displayMedium: TextStyle(
        fontFamily: headingFontFamily,
        fontSize: AppTypography.displayMedium,
        fontWeight: FontWeight.w400,
        color: textPrimary,
      ),
      displaySmall: TextStyle(
        fontFamily: headingFontFamily,
        fontSize: AppTypography.displaySmall,
        fontWeight: FontWeight.w400,
        color: textPrimary,
      ),

      // Headline styles - Outfit for headings
      headlineLarge: TextStyle(
        fontFamily: headingFontFamily,
        fontSize: AppTypography.headingLarge,
        fontWeight: FontWeight.w700,
        color: textPrimary,
        letterSpacing: -0.5,
        height: 1.2,
      ),
      headlineMedium: TextStyle(
        fontFamily: headingFontFamily,
        fontSize: AppTypography.headingMedium,
        fontWeight: FontWeight.w700,
        color: textPrimary,
        letterSpacing: -0.3,
        height: 1.2,
      ),
      headlineSmall: TextStyle(
        fontFamily: headingFontFamily,
        fontSize: AppTypography.headingSmall,
        fontWeight: FontWeight.w600,
        color: textPrimary,
        letterSpacing: -0.2,
        height: 1.2,
      ),

      // Title styles - PlusJakartaSans for body titles & category cards
      titleLarge: TextStyle(
        fontFamily: bodyFontFamily,
        fontSize: AppTypography.titleLarge,
        fontWeight: FontWeight.w700,
        color: textPrimary,
        letterSpacing: -0.2,
      ),
      titleMedium: TextStyle(
        fontFamily: bodyFontFamily,
        fontSize: AppTypography.titleMedium,
        fontWeight: FontWeight.w600,
        color: textPrimary,
        letterSpacing: 0.15,
      ),
      titleSmall: TextStyle(
        fontFamily: bodyFontFamily,
        fontSize: AppTypography.titleSmall,
        fontWeight: FontWeight.w600,
        color: textPrimary,
        letterSpacing: 0.1,
      ),

      // Body styles - PlusJakartaSans for content & description
      bodyLarge: TextStyle(
        fontFamily: bodyFontFamily,
        fontSize: AppTypography.bodyLarge,
        fontWeight: FontWeight.w400,
        color: textPrimary,
        letterSpacing: 0.3,
      ),
      bodyMedium: TextStyle(
        fontFamily: bodyFontFamily,
        fontSize: AppTypography.bodyMedium,
        fontWeight: FontWeight.w400,
        color: textPrimary,
        letterSpacing: 0.2,
      ),
      bodySmall: TextStyle(
        fontFamily: bodyFontFamily,
        fontSize: AppTypography.bodySmall,
        fontWeight: FontWeight.w400,
        color: textPrimary,
        letterSpacing: 0.3,
      ),

      // Label styles - PlusJakartaSans for UI labels, chips & action buttons
      labelLarge: TextStyle(
        fontFamily: bodyFontFamily,
        fontSize: AppTypography.labelLarge,
        fontWeight: FontWeight.w700,
        color: textPrimary,
        letterSpacing: 0.1,
      ),
      labelMedium: TextStyle(
        fontFamily: bodyFontFamily,
        fontSize: AppTypography.labelMedium,
        fontWeight: FontWeight.w600,
        color: textPrimary,
        letterSpacing: 0.3,
      ),
      labelSmall: TextStyle(
        fontFamily: bodyFontFamily,
        fontSize: AppTypography.labelSmall,
        fontWeight: FontWeight.w600,
        color: textPrimary,
        letterSpacing: 0.4,
      ),
    );
  }
}
