import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sizer/sizer.dart';
import 'package:banjarabio/theme/app_theme.dart';
import 'package:banjarabio/core/providers/home_tab_provider.dart';
import 'package:banjarabio/core/constants/app_typography.dart';

/// A premium, brand-aligned empty state widget designed to drive conversion loop.
/// Instead of a generic "No data" message, it displays a beautiful glowing
/// gradient illustration with high-impact micro-animations and a prominent
/// Call-to-Action button that routes users back to matching/discovery feed.
class BrandedEmptyState extends ConsumerWidget {
  final IconData icon;
  final String title;
  final String description;
  final String ctaText;
  final Color? iconColor;
  final Color? glowColor;
  final VoidCallback? onCtaPressed;

  const BrandedEmptyState({
    super.key,
    required this.icon,
    required this.title,
    required this.description,
    required this.ctaText,
    this.iconColor,
    this.glowColor,
    this.onCtaPressed,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final primaryColor = theme.colorScheme.primary;
    final fallbackGlowColor = glowColor ?? primaryColor;

    return Center(
      child: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // ── Premium Glowing Icon Container ──
            TweenAnimationBuilder<double>(
              tween: Tween(begin: 0.0, end: 1.0),
              duration: const Duration(milliseconds: 800),
              curve: Curves.easeOutBack,
              builder: (context, value, child) {
                return Transform.scale(
                  scale: 0.8 + (0.2 * value),
                  child: child,
                );
              },
              child: Container(
                width: 36.w,
                height: 36.w,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      fallbackGlowColor.withValues(alpha: 0.18),
                      fallbackGlowColor.withValues(alpha: 0.04),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: fallbackGlowColor.withValues(alpha: 0.08),
                      blurRadius: 30,
                      spreadRadius: 8,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Center(
                  child: Icon(
                    icon,
                    size: 16.w,
                    color: iconColor ?? primaryColor,
                  ),
                ),
              ),
            ),

            SizedBox(height: 4.h),

            // ── Premium Typography Title ──
            Text(
              title,
              style: TextStyle(
                fontFamily: AppTheme.headingFontFamily,
                fontSize: AppTypography.headingMedium,
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.onSurface,
                letterSpacing: 0.5,
              ),
              textAlign: TextAlign.center,
            ),

            SizedBox(height: 1.5.h),

            // ── High-density descriptive text ──
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 2.w),
              child: Text(
                description,
                style: TextStyle(
                  fontFamily: AppTheme.bodyFontFamily,
                  fontSize: AppTypography.bodySmall,
                  color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.9),
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),
            ),

            SizedBox(height: 4.h),

            // ── Call to Action Button (Routing back to discovery/match loop) ──
            TweenAnimationBuilder<double>(
              tween: Tween(begin: 0.0, end: 1.0),
              duration: const Duration(milliseconds: 600),
              curve: Curves.easeIn,
              builder: (context, value, child) {
                return Opacity(
                  opacity: value,
                  child: child,
                );
              },
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(30),
                  boxShadow: [
                    BoxShadow(
                      color: primaryColor.withValues(alpha: 0.3),
                      blurRadius: 16,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: ElevatedButton.icon(
                  onPressed: onCtaPressed ?? () {
                    // Default behavior: Reset to Home Tab (index 0) and Pop back to HomeScreen
                    ref.read(homeTabProvider.notifier).state = 0;
                    Navigator.of(context).popUntil((route) => route.isFirst);
                  },
                  icon: const Icon(
                    Icons.explore_rounded,
                    color: Colors.white,
                    size: 22,
                  ),
                  label: Text(
                    ctaText,
                    style: TextStyle(
                      fontFamily: AppTheme.headingFontFamily,
                      fontSize: AppTypography.bodyMedium,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryColor,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    padding: EdgeInsets.symmetric(
                      horizontal: 8.w,
                      vertical: 1.8.h,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
