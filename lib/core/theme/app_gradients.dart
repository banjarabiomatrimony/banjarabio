import 'package:flutter/material.dart';
import 'package:banjarabio/theme/app_colors.dart';

/// Centralized brand gradient constants used across the app.
/// Import this file anywhere you need consistent gradient styling.
class AppGradients {
  AppGradients._(); // Prevent instantiation

  // ── Primary Crimson ──────────────────────────────────────────
  static const LinearGradient primary = LinearGradient(
    colors: [AppColors.primary, AppColors.primaryDark],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // ── Romance / CTA ────────────────────────────────────────────
  static const LinearGradient romance = LinearGradient(
    colors: [AppColors.primaryDark, AppColors.primary], // Deep Rose to Crimson
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // ── Love / Interest ──────────────────────────────────────────
  static const LinearGradient love = LinearGradient(
    colors: [AppColors.materialPink, AppColors.materialPink700], // Pink 500 to Pink 700
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // ── Gold / Premium ───────────────────────────────────────────
  static const LinearGradient gold = LinearGradient(
    colors: [AppColors.gold, AppColors.goldDark],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // ── Trust / Verified ─────────────────────────────────────────
  static const LinearGradient trust = LinearGradient(
    colors: [AppColors.successDark, AppColors.success],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // ── Subtle surface overlay (dark tint) ───────────────────────
  static LinearGradient surfaceOverlay({double opacity = 0.7}) =>
      LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [Colors.transparent, Colors.black.withValues(alpha: opacity)],
      );

  // ── Card shimmer highlight ───────────────────────────────────
  static LinearGradient shimmer({required double position}) => LinearGradient(
        colors: const [
          Colors.transparent,
          AppColors.shadowDark,
          Colors.transparent,
        ],
        stops: [
          (position - 0.3).clamp(0.0, 1.0),
          position,
          (position + 0.3).clamp(0.0, 1.0),
        ],
      );
}
