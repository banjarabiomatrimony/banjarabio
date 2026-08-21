import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';
import 'package:banjarabio/l10n/app_localizations.dart';
import 'package:banjarabio/core/constants/app_typography.dart';
import 'package:banjarabio/widgets/tactile/tactile_pressable.dart';
import 'package:banjarabio/theme/app_colors.dart';

/// 🚪 Ultra-Premium Animated Exit Confirmation Dialog
/// Features:
/// ✨ Fluid Spring Entrance Animation (Scale + Fade)
/// 💎 Glassmorphic Frosted Surface with Gradient Border
/// 🌟 Pulsating Heart/Wave Emblem
/// 🔘 Tactile Spring-Physics Action Buttons (Yes / No)
class ExitConfirmationDialog extends StatefulWidget {
  const ExitConfirmationDialog({super.key});

  /// Displays the animated exit dialog with custom backdrop transition
  static Future<bool?> show(BuildContext context) {
    return showGeneralDialog<bool>(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'ExitDialog',
      barrierColor: Colors.black.withValues(alpha: 0.65),
      transitionDuration: const Duration(milliseconds: 320),
      pageBuilder: (ctx, anim1, anim2) => const ExitConfirmationDialog(),
      transitionBuilder: (ctx, anim1, anim2, child) {
        final curved = CurvedAnimation(
          parent: anim1,
          curve: Curves.easeOutBack,
        );
        return ScaleTransition(
          scale: Tween<double>(begin: 0.82, end: 1.0).animate(curved),
          child: FadeTransition(
            opacity: Tween<double>(begin: 0.0, end: 1.0).animate(anim1),
            child: child,
          ),
        );
      },
    );
  }

  @override
  State<ExitConfirmationDialog> createState() => _ExitConfirmationDialogState();
}

class _ExitConfirmationDialogState extends State<ExitConfirmationDialog>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.08).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final l10n = AppLocalizations.of(context);

    return Center(
      child: Material(
        color: Colors.transparent,
        child: Container(
          width: 86.w,
          margin: EdgeInsets.symmetric(horizontal: 6.w),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(28),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 5.5.w, vertical: 3.h),
                decoration: BoxDecoration(
                  color: isDark
                      ? AppColors.canvasNearBlack.withValues(alpha: 0.94)
                      : Colors.white.withValues(alpha: 0.96),
                  borderRadius: BorderRadius.circular(28),
                  border: Border.all(
                    color: isDark
                        ? Colors.white.withValues(alpha: 0.16)
                        : AppColors.primary.withValues(alpha: AppColors.opacity12),
                    width: 1.2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: isDark ? 0.35 : 0.18),
                      blurRadius: 30,
                      offset: const Offset(0, 10),
                    ),
                    BoxShadow(
                      color: Colors.black.withValues(alpha: isDark ? 0.5 : 0.12),
                      blurRadius: 20,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // 🌟 Animated Pulsating Glowing Emblem
                    AnimatedBuilder(
                      animation: _pulseAnimation,
                      builder: (context, child) {
                        return Transform.scale(
                          scale: _pulseAnimation.value,
                          child: Container(
                            width: 68,
                            height: 68,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: const LinearGradient(
                                colors: [AppColors.primary, AppColors.materialPink700],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.primary.withValues(alpha: AppColors.opacity50),
                                  blurRadius: 16,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: const Center(
                              child: Icon(
                                Icons.waving_hand_rounded,
                                color: Colors.white,
                                size: 32,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                    SizedBox(height: 2.2.h),

                    // 🏷️ Title
                    Text(
                      l10n?.exitApp ?? 'Close Application?',
                      textAlign: TextAlign.center,
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: AppTypography.black,
                        fontSize: AppTypography.headingMedium,
                        letterSpacing: 0.2,
                      ),
                    ),
                    SizedBox(height: 1.h),

                    // 💬 Message
                    Text(
                      l10n?.areYouSureExit ?? 'Are you sure you want to close this app?',
                      textAlign: TextAlign.center,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                        fontSize: AppTypography.bodyMedium,
                        height: 1.45,
                      ),
                    ),
                    SizedBox(height: 3.h),

                    // 🔘 Tactile Action Buttons Row
                    Row(
                      children: [
                        // 1. "No" (Dismiss & Stay in App) - Primary Highlight
                        Expanded(
                          flex: 5,
                          child: TactilePressable(
                            onTap: () {
                              HapticFeedback.lightImpact();
                              Navigator.of(context).pop(false);
                            },
                            pressedScale: 0.95,
                            child: Container(
                              height: 48,
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  colors: [AppColors.primary, AppColors.crimsonRose],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                                borderRadius: BorderRadius.circular(16),
                                boxShadow: [
                                  BoxShadow(
                                    color: AppColors.primary.withValues(alpha: AppColors.opacity40),
                                    blurRadius: 10,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: Center(
                                child: Text(
                                  l10n?.cancel ?? 'No, Stay',
                                  style:                                   AppTypography.headingStyle(
                                    color: Colors.white,
                                    fontSize: AppTypography.headingSmall,
                                    letterSpacing: 0.3,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                        SizedBox(width: 3.w),

                        // 2. "Yes" (Confirm Exit) - Elegant Subtle Action
                        Expanded(
                          flex: 4,
                          child: TactilePressable(
                            onTap: () {
                              HapticFeedback.mediumImpact();
                              Navigator.of(context).pop(true);
                            },
                            pressedScale: 0.95,
                            child: Container(
                              height: 48,
                              decoration: BoxDecoration(
                                color: isDark
                                    ? Colors.white.withValues(alpha: AppColors.opacity8)
                                    : Colors.black.withValues(alpha: AppColors.opacity5),
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: isDark
                                      ? Colors.white.withValues(alpha: AppColors.opacity15)
                                      : Colors.black.withValues(alpha: AppColors.opacity10),
                                  width: 1.1,
                                ),
                              ),
                              child: Center(
                                child: Text(
                                  l10n?.exit ?? 'Yes, Exit',
                                  style: TextStyle(
                                    color: isDark
                                        ? Colors.white.withValues(alpha: AppColors.opacity85)
                                        : AppColors.neutral800,
                                    fontWeight: AppTypography.bold,
                                    fontSize: AppTypography.bodyMedium,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
