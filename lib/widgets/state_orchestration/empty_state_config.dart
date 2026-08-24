import 'package:flutter/material.dart';
import 'package:banjarabio/core/app_export.dart';

/// Configuration data model defining the rich empty state details card
class EmptyStateConfig {
  final IconData icon;
  final String badgeText;
  final String title;
  final String description;
  final Color? accentColor;
  final LinearGradient? iconGradient;
  final String ctaText;
  final VoidCallback? onCtaTap;
  final Widget? customContent;

  const EmptyStateConfig({
    required this.icon,
    required this.badgeText,
    required this.title,
    required this.description,
    required this.ctaText,
    this.accentColor,
    this.iconGradient,
    this.onCtaTap,
    this.customContent,
  });

  /// Factory helper for standard Crimson Rose themed empty state
  factory EmptyStateConfig.standard({
    required IconData icon,
    required String badgeText,
    required String title,
    required String description,
    required String ctaText,
    VoidCallback? onCtaTap,
    Widget? customContent,
  }) {
    return EmptyStateConfig(
      icon: icon,
      badgeText: badgeText,
      title: title,
      description: description,
      ctaText: ctaText,
      accentColor: AppColors.crimsonRose,
      iconGradient: const LinearGradient(
        colors: [AppColors.crimsonRose, AppColors.crimsonBlush],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      onCtaTap: onCtaTap,
      customContent: customContent,
    );
  }
}
