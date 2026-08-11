import 'package:sizer/sizer.dart';

/// Centralized typographic sizing constants for the application.
/// Provides responsive `.sp` metrics to ensure consistent visual hierarchy.
///
/// 9-tier type scale aligned with Material Design 3:
///   displayLarge  → hero/display numbers
///   headingLarge  → screen titles, primary headings
///   headingMedium → section headings, card titles
///   headingSmall  → sub-section headings, emphasis text
///   bodyLarge     → primary body text, descriptions
///   bodyMedium    → standard body, form fields, subtitles
///   bodySmall     → secondary text, captions, helper text
///   labelMedium   → compact labels, tab text, small badges
///   labelSmall    → micro labels, admin badges, grid cells
class AppTypography {
  AppTypography._();

  // Display
  static double get displayLarge => 36.sp;

  // Headings (Outfit font family)
  static double get headingLarge => 24.sp;
  static double get headingMedium => 18.sp;
  static double get headingSmall => 15.sp;

  // Body Text (Plus Jakarta Sans font family)
  static double get bodyLarge => 13.5.sp;
  static double get bodyMedium => 12.sp;
  static double get bodySmall => 10.5.sp;

  // Labels
  static double get labelMedium => 9.sp;
  static double get labelSmall => 7.5.sp;
}
