import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';
import 'package:banjarabio/l10n/app_localizations.dart';
import 'package:banjarabio/core/constants/app_typography.dart';
import 'package:banjarabio/widgets/tactile/tactile_pressable.dart';
import 'package:banjarabio/theme/app_colors.dart';

/// 🚪 Ultra-Premium Animated Logout Confirmation Dialog
/// Features:
/// ✨ Fluid Spring Entrance Animation (Scale + Fade via showGeneralDialog)
/// 💎 Glassmorphic Frosted Surface with Ambient Glow & Gradient Border
/// 🌟 Pulsating Logout Radar Emblem with Dual-Pass Glow
/// 🔒 Security Assurance Note ('Your biodata & messages remain secure')
/// 🔘 Tactile Spring-Physics Action Buttons (Cancel / Log Out)
class LogoutConfirmationDialog extends StatefulWidget {
  const LogoutConfirmationDialog({super.key});

  /// Displays the animated logout confirmation dialog with custom backdrop transition
  static Future<bool?> show(BuildContext context) {
    HapticFeedback.mediumImpact();
    return showGeneralDialog<bool>(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'LogoutConfirmationDialog',
      barrierColor: Colors.black.withValues(alpha: 0.65),
      transitionDuration: const Duration(milliseconds: 320),
      pageBuilder: (ctx, anim1, anim2) => const LogoutConfirmationDialog(),
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
  State<LogoutConfirmationDialog> createState() => _LogoutConfirmationDialogState();
}

class _LogoutConfirmationDialogState extends State<LogoutConfirmationDialog>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;
  late Animation<double> _glowAnimation;

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

    _glowAnimation = Tween<double>(begin: 0.25, end: 0.55).animate(
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
                        : AppColors.softRed.withValues(alpha: AppColors.opacity15),
                    width: 1.2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.softRed.withValues(alpha: isDark ? 0.35 : 0.18),
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
                      animation: _pulseController,
                      builder: (context, child) {
                        return Transform.scale(
                          scale: _pulseAnimation.value,
                          child: Container(
                            width: 68,
                            height: 68,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: const LinearGradient(
                                colors: [AppColors.softRed, AppColors.crimsonMaroon],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.softRed.withValues(alpha: _glowAnimation.value),
                                  blurRadius: 18,
                                  spreadRadius: 2,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: const Center(
                              child: Icon(
                                Icons.logout_rounded,
                                color: Colors.white,
                                size: 30,
                              ),
                            ),
                          ),
                        );
                      },
                    ),

                    SizedBox(height: 2.2.h),

                    // 🏷️ Dialog Title
                    Text(
                      l10n?.logout ?? 'Logout Confirmation',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: AppTypography.headingMedium,
                        fontWeight: AppTypography.extraBold,
                        color: isDark ? Colors.white : AppColors.neutral800,
                        letterSpacing: -0.3,
                      ),
                    ),

                    SizedBox(height: 1.0.h),

                    // 💬 Prompt Description
                    Text(
                      l10n?.areYouSureLogout ?? 'Are you sure you want to log out of your account?',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: AppTypography.bodySmall,
                        fontWeight: AppTypography.regular,
                        color: isDark
                            ? Colors.white.withValues(alpha: 0.72)
                            : AppColors.textSecondary,
                        height: 1.4,
                      ),
                    ),

                    SizedBox(height: 1.6.h),

                    // 🔒 Security reassurance badge
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 3.2.w, vertical: 0.8.h),
                      decoration: BoxDecoration(
                        color: isDark
                            ? Colors.white.withValues(alpha: 0.05)
                            : AppColors.softRed.withValues(alpha: 0.06),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: isDark
                              ? Colors.white12
                              : AppColors.softRed.withValues(alpha: 0.15),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.lock_outline_rounded,
                            size: 14,
                            color: isDark ? AppColors.gold : AppColors.softRed,
                          ),
                          SizedBox(width: 1.5.w),
                          Flexible(
                            child: Text(
                              'Your biodata and conversations remain safe.',
                              style: TextStyle(
                                fontSize: AppTypography.labelSmall,
                                fontWeight: AppTypography.medium,
                                color: isDark
                                    ? Colors.white.withValues(alpha: 0.85)
                                    : AppColors.textSecondary,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    SizedBox(height: 2.8.h),

                    // 🔘 Action Buttons Row
                    Row(
                      children: [
                        // ❌ Cancel Button
                        Expanded(
                          child: TactilePressable(
                            onTap: () {
                              HapticFeedback.selectionClick();
                              Navigator.of(context).pop(false);
                            },
                            child: Container(
                              height: 5.2.h,
                              decoration: BoxDecoration(
                                color: isDark
                                    ? Colors.white.withValues(alpha: 0.08)
                                    : AppColors.slate100,
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: isDark
                                      ? Colors.white.withValues(alpha: 0.12)
                                      : AppColors.slate200,
                                ),
                              ),
                              alignment: Alignment.center,
                              child: Text(
                                l10n?.cancel ?? 'Cancel',
                                style: TextStyle(
                                  fontSize: AppTypography.bodySmall,
                                  fontWeight: AppTypography.bold,
                                  color: isDark
                                      ? Colors.white.withValues(alpha: 0.85)
                                      : AppColors.neutral800,
                                ),
                              ),
                            ),
                          ),
                        ),

                        SizedBox(width: 3.5.w),

                        // 🚪 Confirm Log Out Button
                        Expanded(
                          child: TactilePressable(
                            onTap: () {
                              HapticFeedback.heavyImpact();
                              Navigator.of(context).pop(true);
                            },
                            child: Container(
                              height: 5.2.h,
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  colors: [AppColors.softRed, AppColors.crimsonMaroon],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                                borderRadius: BorderRadius.circular(16),
                                boxShadow: [
                                  BoxShadow(
                                    color: AppColors.softRed.withValues(alpha: AppColors.opacity40),
                                    blurRadius: 12,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              alignment: Alignment.center,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(
                                    Icons.logout_rounded,
                                    size: 16,
                                    color: Colors.white,
                                  ),
                                  SizedBox(width: 1.5.w),
                                  Text(
                                    l10n?.logout ?? 'Log Out',
                                    style: TextStyle(
                                      fontSize: AppTypography.bodySmall,
                                      fontWeight: AppTypography.extraBold,
                                      color: Colors.white,
                                    ),
                                  ),
                                ],
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
