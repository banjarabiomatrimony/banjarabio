import 'package:flutter/material.dart';

/// Centralized brand gradient constants used across the app.
/// Import this file anywhere you need consistent gradient styling.
class AppGradients {
  AppGradients._(); // Prevent instantiation

  // ── Primary Crimson ──────────────────────────────────────────
  static const LinearGradient primary = LinearGradient(
    colors: [Color(0xFF961B33), Color(0xFF731224)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // ── Romance / CTA ────────────────────────────────────────────
  static const LinearGradient romance = LinearGradient(
    colors: [Color(0xFF880E4F), Color(0xFF961B33)], // Deep Rose to Crimson
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // ── Love / Interest ──────────────────────────────────────────
  static const LinearGradient love = LinearGradient(
    colors: [Color(0xFFE91E63), Color(0xFFC2185B)], // Pink 500 to Pink 700
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // ── Gold / Premium ───────────────────────────────────────────
  static const LinearGradient gold = LinearGradient(
    colors: [Color(0xFFD4AF37), Color(0xFFB8941F)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // ── Trust / Verified ─────────────────────────────────────────
  static const LinearGradient trust = LinearGradient(
    colors: [Color(0xFF4CAF50), Color(0xFF2E7D32)],
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
          Color(0x22FFFFFF),
          Colors.transparent,
        ],
        stops: [
          (position - 0.3).clamp(0.0, 1.0),
          position,
          (position + 0.3).clamp(0.0, 1.0),
        ],
      );
}
