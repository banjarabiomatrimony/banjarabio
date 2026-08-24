import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';
import 'package:banjarabio/core/app_export.dart';
import 'package:banjarabio/widgets/skeleton_loaders.dart';
import 'package:banjarabio/widgets/tactile/tactile_pressable.dart';
import 'package:banjarabio/widgets/state_orchestration/empty_state_config.dart';

/// ─────────────────────────────────────────────────────────────────────────────
/// 🏛️ BESPOKE STATE CONTAINER (Universal 3-Phase Lifecycle Orchestrator)
/// ─────────────────────────────────────────────────────────────────────────────
/// Enforces Strict Lifecycle Preservation across every screen in BanjaraBio:
/// 1. Initial Loading ➔ Clean Screen-Specific Bespoke Skeleton Only
/// 2. Real Data (Count > 0) ➔ Direct 60FPS UI Cards (No frosted barrier)
/// 3. Empty State (Count == 0) ➔ Pulsing Breathing Skeleton + Frosted Barrier + Details Card
class BespokeStateContainer extends StatelessWidget {
  final bool isLoading;
  final bool isEmpty;
  final String? errorMessage;
  final VoidCallback? onRetry;
  final Widget skeleton;
  final WidgetBuilder contentBuilder;
  final EmptyStateConfig emptyConfig;

  const BespokeStateContainer({
    super.key,
    required this.isLoading,
    required this.isEmpty,
    required this.skeleton,
    required this.contentBuilder,
    required this.emptyConfig,
    this.errorMessage,
    this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    // 1. Initial Loading ➔ Clean Skeleton Loader Only
    if (isLoading) {
      return skeleton;
    }

    // 2. Error State
    if (errorMessage != null && errorMessage!.isNotEmpty) {
      return Center(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 4.h),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: theme.colorScheme.error.withValues(alpha: isDark ? 0.18 : 0.10),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.error_outline_rounded,
                  color: theme.colorScheme.error,
                  size: 36,
                ),
              ),
              const SizedBox(height: 14),
              Text(
                'Something went wrong',
                style: TextStyle(
                  fontSize: AppTypography.bodyLarge,
                  fontWeight: AppTypography.black,
                  color: isDark ? Colors.white : AppColors.slate900,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 6),
              Text(
                errorMessage!,
                style: TextStyle(
                  fontSize: AppTypography.bodySmall,
                  color: isDark ? Colors.white70 : AppColors.slate600,
                ),
                textAlign: TextAlign.center,
              ),
              if (onRetry != null) ...[
                const SizedBox(height: 16),
                TactilePressable(
                  onTap: () {
                    HapticFeedback.lightImpact();
                    onRetry!();
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    decoration: BoxDecoration(
                      color: AppColors.crimsonRose,
                      borderRadius: BorderRadius.circular(14),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.crimsonRose.withValues(alpha: AppColors.opacity30),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Text(
                      'Retry',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: AppTypography.labelMedium,
                        fontWeight: AppTypography.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      );
    }

    // 3. Empty State ➔ Pulsing Breathing Skeleton + Frosted Barrier + Details Card
    if (isEmpty) {
      return PulsingEmptyStateOverlay(
        isDark: isDark,
        skeleton: skeleton,
        card: _BespokeEmptyDetailsCard(config: emptyConfig, isDark: isDark),
      );
    }

    // 4. Real Data (Count > 0) ➔ Direct UI Content
    return contentBuilder(context);
  }
}

/// ─────────────────────────────────────────────────────────────────────────────
/// 🏛️ SLIVER BESPOKE STATE CONTAINER (For CustomScrollViews)
/// ─────────────────────────────────────────────────────────────────────────────
class SliverBespokeStateContainer extends StatelessWidget {
  final bool isLoading;
  final bool isEmpty;
  final Widget skeleton;
  final Widget content;
  final EmptyStateConfig emptyConfig;

  const SliverBespokeStateContainer({
    super.key,
    required this.isLoading,
    required this.isEmpty,
    required this.skeleton,
    required this.content,
    required this.emptyConfig,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (isLoading) {
      return SliverToBoxAdapter(child: skeleton);
    }

    if (isEmpty) {
      return SliverFillRemaining(
        hasScrollBody: false,
        child: PulsingEmptyStateOverlay(
          isDark: isDark,
          skeleton: skeleton,
          card: _BespokeEmptyDetailsCard(config: emptyConfig, isDark: isDark),
        ),
      );
    }

    return content;
  }
}

/// ─────────────────────────────────────────────────────────────────────────────
/// 💎 BESPOKE EMPTY DETAILS CARD
/// ─────────────────────────────────────────────────────────────────────────────
class _BespokeEmptyDetailsCard extends StatelessWidget {
  final EmptyStateConfig config;
  final bool isDark;

  const _BespokeEmptyDetailsCard({
    required this.config,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final Color accentColor = config.accentColor ?? AppColors.crimsonRose;
    final LinearGradient iconGradient = config.iconGradient ??
        const LinearGradient(
          colors: [AppColors.crimsonRose, AppColors.crimsonBlush],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 5.w, vertical: 2.4.h),
      decoration: BoxDecoration(
        color: isDark ? AppColors.canvasCharcoal : Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: isDark
              ? Colors.white.withValues(alpha: AppColors.opacity12)
              : accentColor.withValues(alpha: AppColors.opacity25),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.35 : 0.08),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
          BoxShadow(
            color: accentColor.withValues(alpha: isDark ? 0.18 : 0.10),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Glowing Category Icon Ring
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: iconGradient,
              boxShadow: [
                BoxShadow(
                  color: accentColor.withValues(alpha: AppColors.opacity40),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Icon(config.icon, size: 30, color: Colors.white),
          ),
          const SizedBox(height: 12),

          // Category Pill Badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
            decoration: BoxDecoration(
              color: accentColor.withValues(alpha: isDark ? 0.18 : 0.10),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: accentColor.withValues(alpha: isDark ? 0.45 : 0.30),
                width: 0.9,
              ),
            ),
            child: Text(
              config.badgeText,
              style: TextStyle(
                fontSize: AppTypography.labelTiny,
                fontWeight: AppTypography.black,
                color: isDark ? Colors.white : accentColor,
                letterSpacing: 0.5,
              ),
            ),
          ),
          const SizedBox(height: 10),

          // Title
          Text(
            config.title,
            style: TextStyle(
              fontSize: AppTypography.bodyLarge,
              fontWeight: AppTypography.black,
              color: isDark ? Colors.white : AppColors.slate900,
              letterSpacing: 0.2,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 6),

          // Description
          Text(
            config.description,
            style: TextStyle(
              fontSize: AppTypography.bodySmall,
              color: isDark ? Colors.white70 : AppColors.slate600,
              height: 1.45,
            ),
            textAlign: TextAlign.center,
          ),

          // Custom Content / Reusable Sub-Widgets (if any)
          if (config.customContent != null) ...[
            const SizedBox(height: 14),
            config.customContent!,
          ],

          if (config.onCtaTap != null) ...[
            const SizedBox(height: 18),
            TactilePressable(
              onTap: config.onCtaTap!,
              child: Container(
                width: double.infinity,
                padding: EdgeInsets.symmetric(vertical: 1.3.h),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [AppColors.crimsonRose, AppColors.crimsonBlush],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.crimsonRose.withValues(alpha: AppColors.opacity35),
                      blurRadius: 10,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Center(
                  child: Text(
                    config.ctaText,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: AppTypography.labelMedium,
                      fontWeight: AppTypography.black,
                      letterSpacing: 0.3,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
