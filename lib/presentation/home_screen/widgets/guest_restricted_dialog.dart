import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';
import 'package:banjarabio/l10n/app_localizations.dart';
import 'package:banjarabio/core/constants/app_typography.dart';
import 'package:banjarabio/core/services/local_cache_service.dart';
import 'package:banjarabio/core/supabase_client.dart';
import 'package:banjarabio/routes/app_routes.dart';
import 'package:banjarabio/theme/app_colors.dart';
import 'package:banjarabio/widgets/smart_auth_gate.dart';
import 'package:banjarabio/widgets/tactile/tactile_pressable.dart';

/// 🛡️ Guest & Relative Restricted Dialog
///
/// Gating coordinator for high-value actions:
/// - Unauthenticated guest $\rightarrow$ SmartAuthGate (Google Sign-In modal sheet)
/// - Authenticated user in Relative Browse Mode $\rightarrow$ Animated Glassmorphic Create Biodata Dialog
class GuestRestrictedDialog {
  /// Shows the appropriate gate based on auth state:
  /// - **Unauthenticated guest**: SmartAuthGate bottom sheet (returns async result)
  /// - **Authenticated relative browse (no own profile)**: Animated Create Biodata / Change Options dialog
  ///
  /// Returns [SmartAuthResult.success] if user authenticated (caller should complete original action),
  /// [SmartAuthResult.cancelled] if dismissed.
  static Future<SmartAuthResult> show(
    BuildContext context, {
    SmartAuthIntent intent = SmartAuthIntent.generic,
    String? profileName,
  }) async {
    final isAuth = AppSupabaseClient.isAuthenticated;
    final isRelative = LocalCacheService().isRelativeBrowseMode();

    // 🌟 Unauthenticated Guest → SmartAuthGate (Google Sign-In bottom sheet)
    if (!isAuth) {
      return SmartAuthGate.show(
        context,
        intent: intent,
        profileName: profileName,
      );
    }

    // 🌟 Authenticated user in Relative Browse Mode (no own profile) → Animated dialog
    if (isRelative) {
      await showRelativeBrowseDialog(context);
      return SmartAuthResult.cancelled;
    }

    // Fallback (shouldn't reach here for properly gated calls)
    return SmartAuthResult.cancelled;
  }

  /// Displays the ultra-premium animated Create Biodata / Change Options dialog.
  static Future<void> showRelativeBrowseDialog(BuildContext context) {
    HapticFeedback.mediumImpact();
    return showGeneralDialog<void>(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'RelativeBrowsePromptDialog',
      barrierColor: Colors.black.withValues(alpha: AppColors.opacity70),
      transitionDuration: const Duration(milliseconds: 320),
      pageBuilder: (ctx, anim1, anim2) => const RelativeBrowsePromptDialog(),
      transitionBuilder: (ctx, anim1, anim2, child) {
        final curved = CurvedAnimation(
          parent: anim1,
          curve: Curves.easeOutBack,
        );
        return ScaleTransition(
          scale: Tween<double>(begin: 0.84, end: 1.0).animate(curved),
          child: FadeTransition(
            opacity: Tween<double>(begin: 0.0, end: 1.0).animate(anim1),
            child: child,
          ),
        );
      },
    );
  }
}

/// 💎 Ultra-Premium Animated Glassmorphic Dialog for Relative Browse Mode
class RelativeBrowsePromptDialog extends StatefulWidget {
  const RelativeBrowsePromptDialog({super.key});

  @override
  State<RelativeBrowsePromptDialog> createState() => _RelativeBrowsePromptDialogState();
}

class _RelativeBrowsePromptDialogState extends State<RelativeBrowsePromptDialog>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;
  late Animation<double> _glowAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.07).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _glowAnimation = Tween<double>(begin: 0.25, end: 0.65).animate(
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
          width: 88.w,
          margin: EdgeInsets.symmetric(horizontal: 5.w),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(28),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 3.2.h),
                decoration: BoxDecoration(
                  color: isDark
                      ? AppColors.surfaceDark.withValues(alpha: 0.94)
                      : AppColors.surfaceLight.withValues(alpha: 0.96),
                  borderRadius: BorderRadius.circular(28),
                  border: Border.all(
                    color: isDark
                        ? Colors.white.withValues(alpha: AppColors.opacity12)
                        : AppColors.primary.withValues(alpha: AppColors.opacity15),
                    width: 1.2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primaryDark.withValues(alpha: AppColors.opacity20),
                      blurRadius: 28,
                      offset: const Offset(0, 12),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // 🌟 Animated Hero Emblem with Pulsating Glow
                    AnimatedBuilder(
                      animation: _pulseController,
                      builder: (context, child) {
                        return Transform.scale(
                          scale: _pulseAnimation.value,
                          child: Container(
                            width: 20.w,
                            height: 20.w,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: const LinearGradient(
                                colors: [AppColors.primary, AppColors.primaryDark],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.primary.withValues(alpha: _glowAnimation.value),
                                  blurRadius: 22,
                                  spreadRadius: 2,
                                ),
                              ],
                            ),
                            child: const Center(
                              child: Icon(
                                Icons.assignment_ind_rounded,
                                color: Colors.white,
                                size: 36,
                              ),
                            ),
                          ),
                        );
                      },
                    ),

                    SizedBox(height: 2.2.h),

                    // 🏷️ Title
                    Text(
                      l10n?.createBiodata ?? 'Create Biodata',
                      textAlign: TextAlign.center,
                      style: AppTypography.headingStyle(
                        fontSize: AppTypography.headingMedium,
                        fontWeight: AppTypography.bold,
                        color: isDark ? Colors.white : AppColors.primaryDark,
                        letterSpacing: -0.2,
                      ),
                    ),

                    SizedBox(height: 1.2.h),

                    // 📝 Content / Subtitle
                    Text(
                      l10n?.guestRestrictedContent ??
                          'To view all details, save profiles, and communicate with matches, please create your biodata or change your search options.',
                      textAlign: TextAlign.center,
                      style: AppTypography.headingStyle(
                        fontSize: AppTypography.bodySmall,
                        fontWeight: AppTypography.regular,
                        color: isDark ? AppColors.neutral300 : AppColors.neutral700,
                        height: 1.45,
                      ),
                    ),

                    SizedBox(height: 2.2.h),

                    // 💎 Benefit Highlights Row
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.2.h),
                      decoration: BoxDecoration(
                        color: isDark
                            ? Colors.white.withValues(alpha: AppColors.opacity5)
                            : AppColors.primaryLight.withValues(alpha: 0.6),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: isDark
                              ? Colors.white.withValues(alpha: AppColors.opacity8)
                              : AppColors.primary.withValues(alpha: AppColors.opacity12),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _buildFeatureItem(
                            icon: Icons.visibility_rounded,
                            label: 'Full Details',
                            isDark: isDark,
                          ),
                          _buildFeatureItem(
                            icon: Icons.favorite_rounded,
                            label: 'Save Matches',
                            isDark: isDark,
                          ),
                          _buildFeatureItem(
                            icon: Icons.chat_bubble_rounded,
                            label: 'Direct Chat',
                            isDark: isDark,
                          ),
                        ],
                      ),
                    ),

                    SizedBox(height: 2.8.h),

                    // 🚀 Primary Action: Create Biodata ✨
                    TactilePressable(
                      onTap: () async {
                        HapticFeedback.mediumImpact();
                        await LocalCacheService().clearRelativeBrowseSession();
                        await LocalCacheService().setGuestMode(false);
                        if (context.mounted) {
                          Navigator.of(context).pop();
                          Navigator.of(context, rootNavigator: true).pushNamed(AppRoutes.biodataCreation);
                        }
                      },
                      child: Container(
                        width: double.infinity,
                        padding: EdgeInsets.symmetric(vertical: 1.6.h),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [AppColors.primary, AppColors.primaryDark],
                          ),
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.primary.withValues(alpha: AppColors.opacity35),
                              blurRadius: 14,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.auto_awesome_rounded, color: Colors.white, size: 20),
                            SizedBox(width: 2.w),
                            Text(
                              l10n?.createBiodataCta ?? 'Create Biodata ✨',
                              style: AppTypography.headingStyle(
                                fontSize: AppTypography.bodyMedium,
                                fontWeight: AppTypography.bold,
                                color: Colors.white,
                                letterSpacing: 0.3,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    SizedBox(height: 1.4.h),

                    // ✏️ Secondary Action: Change Options
                    TactilePressable(
                      onTap: () async {
                        HapticFeedback.lightImpact();
                        await LocalCacheService().clearRelativeBrowseSession();
                        if (context.mounted) {
                          Navigator.of(context).pop();
                          Navigator.of(context, rootNavigator: true).pushNamedAndRemoveUntil(
                            AppRoutes.userTypeSelection,
                            (route) => false,
                          );
                        }
                      },
                      child: Container(
                        width: double.infinity,
                        padding: EdgeInsets.symmetric(vertical: 1.5.h),
                        decoration: BoxDecoration(
                          color: isDark
                              ? Colors.white.withValues(alpha: AppColors.opacity8)
                              : AppColors.neutral100,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: isDark
                                ? Colors.white.withValues(alpha: AppColors.opacity15)
                                : AppColors.neutral300,
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.tune_rounded,
                              size: 18,
                              color: isDark ? Colors.white : AppColors.neutral800,
                            ),
                            SizedBox(width: 2.w),
                            Text(
                              l10n?.changeOptionsCta ?? 'Change Options ✏️',
                              style: AppTypography.headingStyle(
                                fontSize: AppTypography.bodyMedium,
                                fontWeight: AppTypography.semiBold,
                                color: isDark ? Colors.white : AppColors.neutral800,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    SizedBox(height: 1.h),

                    // ❌ Dismiss: Cancel
                    TextButton(
                      onPressed: () {
                        HapticFeedback.selectionClick();
                        Navigator.of(context).pop();
                      },
                      style: TextButton.styleFrom(
                        padding: EdgeInsets.symmetric(vertical: 0.8.h, horizontal: 4.w),
                        foregroundColor: isDark ? AppColors.neutral400 : AppColors.neutral600,
                      ),
                      child: Text(
                        l10n?.cancel ?? 'Cancel',
                        style: AppTypography.headingStyle(
                          fontSize: AppTypography.bodySmall,
                          fontWeight: AppTypography.medium,
                          color: isDark ? AppColors.neutral400 : AppColors.neutral600,
                        ),
                      ),
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

  Widget _buildFeatureItem({
    required IconData icon,
    required String label,
    required bool isDark,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          icon,
          size: 18,
          color: isDark ? AppColors.primaryLight : AppColors.primary,
        ),
        SizedBox(height: 0.4.h),
        Text(
          label,
          style: AppTypography.headingStyle(
            fontSize: 9.sp,
            fontWeight: AppTypography.medium,
            color: isDark ? AppColors.neutral300 : AppColors.neutral700,
          ),
        ),
      ],
    );
  }
}
