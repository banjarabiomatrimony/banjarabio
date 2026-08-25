import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';
import 'package:banjarabio/core/utils/app_feedback_service.dart';

import 'package:banjarabio/core/constants/app_typography.dart';
import 'package:banjarabio/core/repositories/auth_repository.dart';
import 'package:banjarabio/core/repositories/profile_repository.dart';
import 'package:banjarabio/core/session_manager.dart';
import 'package:banjarabio/core/services/local_cache_service.dart';
import 'package:banjarabio/core/services/app_logger.dart';
import 'package:banjarabio/core/supabase_client.dart';
import 'package:banjarabio/theme/app_colors.dart';
import 'package:banjarabio/widgets/tactile/tactile_pressable.dart';

/// The intent context that triggered the auth gate.
/// Determines the title, subtitle, and benefit bullets shown.
enum SmartAuthIntent {
  viewContact,
  expressInterest,
  createBiodata,
  saveProfile,
  openChat,
  downloadBiodata,
  generic,
}

/// Result of the SmartAuthGate interaction.
enum SmartAuthResult {
  /// User authenticated successfully.
  success,
  /// User cancelled or dismissed the sheet.
  cancelled,
  /// Sign-in failed with an error.
  failed,
}

/// 🛡️ Smart Auth Gate — Context-Aware Google Sign-In Bottom Sheet
///
/// A reusable bottom sheet that gates high-value actions behind Google Sign-In.
/// Shows context-specific messaging based on the [SmartAuthIntent].
///
/// Design follows the app's existing premium glassmorphic bottom sheet patterns
/// (see LogoutConfirmationDialog, DirectNoteBottomSheet).
///
/// Returns [SmartAuthResult] so callers can complete the original action on success.
class SmartAuthGate extends StatefulWidget {
  final SmartAuthIntent intent;
  final String? profileName;

  const SmartAuthGate({
    super.key,
    required this.intent,
    this.profileName,
  });

  /// Shows the Smart Auth Gate as a modal bottom sheet.
  /// Returns [SmartAuthResult.success] if user authenticated,
  /// [SmartAuthResult.cancelled] if dismissed, [SmartAuthResult.failed] on error.
  static Future<SmartAuthResult> show(
    BuildContext context, {
    required SmartAuthIntent intent,
    String? profileName,
  }) async {
    // If already authenticated, no gate needed
    if (AppSupabaseClient.isAuthenticated) {
      return SmartAuthResult.success;
    }

    final result = await showModalBottomSheet<SmartAuthResult>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withValues(alpha: 0.75),
      builder: (ctx) => SmartAuthGate(
        intent: intent,
        profileName: profileName,
      ),
    );

    return result ?? SmartAuthResult.cancelled;
  }

  @override
  State<SmartAuthGate> createState() => _SmartAuthGateState();
}

class _SmartAuthGateState extends State<SmartAuthGate>
    with SingleTickerProviderStateMixin {
  final AuthRepository _authRepository = AuthRepository();
  bool _isLoading = false;
  String? _errorMessage;

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

    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.06).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _glowAnimation = Tween<double>(begin: 0.20, end: 0.50).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  // ─── Intent-Specific Content ────────────────────────────────────────

  _IntentContent get _content {
    final name = widget.profileName ?? '';
    switch (widget.intent) {
      case SmartAuthIntent.viewContact:
        return _IntentContent(
          icon: Icons.phone_rounded,
          title: 'Sign in to view contact',
          subtitle: name.isNotEmpty
              ? 'Sign in to view phone number and WhatsApp of $name\'s family'
              : 'Sign in to view contact details of this family',
          benefits: [
            '📞 View phone number & WhatsApp',
            '💬 Send direct messages',
            '⭐ Save & shortlist profiles',
          ],
        );
      case SmartAuthIntent.expressInterest:
        return _IntentContent(
          icon: Icons.favorite_rounded,
          title: 'Sign in to express interest',
          subtitle: name.isNotEmpty
              ? 'Sign in to send your interest to $name\'s family'
              : 'Sign in to send your interest to this family',
          benefits: [
            '❤️ Express interest to families',
            '📩 Get notified on acceptance',
            '💬 Start conversations',
          ],
        );
      case SmartAuthIntent.createBiodata:
        return const _IntentContent(
          icon: Icons.description_rounded,
          title: 'Create Your Free Biodata',
          subtitle: 'Sign in with Google to create your verified BanjaraBio matrimony profile — 100% free, ready in 2 minutes',
          benefits: [
            '✨ Create Beautiful PDF Biodata',
            '📲 Share on WhatsApp with Families',
            '✅ Get Verified Community Badge',
          ],
        );
      case SmartAuthIntent.saveProfile:
        return const _IntentContent(
          icon: Icons.bookmark_rounded,
          title: 'Sign in to save profile',
          subtitle: 'Sign in to shortlist and save profiles for later',
          benefits: [
            '🔖 Save & organize profiles',
            '🔔 Get updates on saved profiles',
            '📊 Track your interests',
          ],
        );
      case SmartAuthIntent.openChat:
        return _IntentContent(
          icon: Icons.chat_bubble_rounded,
          title: 'Sign in to start chat',
          subtitle: name.isNotEmpty
              ? 'Sign in to message $name\'s family directly'
              : 'Sign in to start a conversation',
          benefits: [
            '💬 Direct messaging',
            '📸 Share photos securely',
            '🔒 Private & encrypted',
          ],
        );
      case SmartAuthIntent.downloadBiodata:
        return const _IntentContent(
          icon: Icons.download_rounded,
          title: 'Sign in to download',
          subtitle: 'Sign in to download biodata PDF for sharing with family',
          benefits: [
            '📄 Download PDF biodata',
            '📲 Share via WhatsApp',
            '🖨️ Print for family review',
          ],
        );
      case SmartAuthIntent.generic:
        return const _IntentContent(
          icon: Icons.lock_open_rounded,
          title: 'Sign In Required',
          subtitle: 'Sign in with your Google account to continue',
          benefits: [
            '🔓 Unlock all features',
            '📞 View contact details',
            '❤️ Express interest & chat',
          ],
        );
    }
  }

  // ─── Google Sign-In Handler ─────────────────────────────────────────

  Future<void> _handleGoogleSignIn() async {
    if (_isLoading) return;

    HapticFeedback.heavyImpact();
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final result = await _authRepository.signInWithGoogle();

      if (!mounted) return;

      await result.fold(
        onSuccess: (success) async {
          if (success) {
            // Mark session for Smart Tab Resolver
            await SessionManager.instance.setHasPreviouslyLoggedIn(true);
            await LocalCacheService().setGuestMode(false);

            // Clear stale feed cache for fresh auth context
            ProfileRepository().clearCache();

            AppLogger.debug('SmartAuthGate', '✅ Google Sign-In success via SmartAuthGate');

            if (mounted) {
              // 🎉 Celebratory toast
              AppFeedback.showSuccess(
                context,
                '✅ Welcome! You\'re signed in',
              );

              Navigator.of(context).pop(SmartAuthResult.success);
            }
          } else {
            // User cancelled Google dialog
            setState(() {
              _isLoading = false;
            });
          }
        },
        onFailure: (error) async {
          AppLogger.error('SmartAuthGate', 'Google Sign-In failed: $error');
          if (mounted) {
            setState(() {
              _isLoading = false;
              _errorMessage = 'Sign in failed. Please try again.';
            });
          }
        },
      );
    } catch (e) {
      AppLogger.error('SmartAuthGate', 'Unexpected sign-in error: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
          _errorMessage = 'Something went wrong. Please try again.';
        });
      }
    }
  }

  // ─── Build ──────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final content = _content;

    return Container(
      constraints: BoxConstraints(maxHeight: 75.h),
      child: ClipRRect(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
          child: Container(
            padding: EdgeInsets.fromLTRB(5.5.w, 1.5.h, 5.5.w, 3.h),
            decoration: BoxDecoration(
              color: isDark
                  ? AppColors.canvasNearBlack.withValues(alpha: 0.94)
                  : Colors.white.withValues(alpha: 0.96),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
              border: Border.all(
                color: isDark
                    ? Colors.white.withValues(alpha: 0.16)
                    : AppColors.categoryAstro.withValues(alpha: 0.25),
                width: 1.2,
              ),
              boxShadow: [
                BoxShadow(
                  color: AppColors.categoryAstro.withValues(alpha: isDark ? 0.30 : 0.15),
                  blurRadius: 30,
                  offset: const Offset(0, -8),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // ── Handle Pill ──
                Center(
                  child: Container(
                    width: 42,
                    height: 4.5,
                    decoration: BoxDecoration(
                      color: isDark ? Colors.white24 : AppColors.slate300,
                      borderRadius: BorderRadius.circular(3),
                    ),
                  ),
                ),
                SizedBox(height: 2.5.h),

                // ── Pulsating Emblem ──
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
                            colors: [AppColors.categoryAstro, AppColors.categoryAstroDark],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.categoryAstro.withValues(alpha: _glowAnimation.value),
                              blurRadius: 18,
                              spreadRadius: 2,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Center(
                          child: Icon(
                            content.icon,
                            color: Colors.white,
                            size: 30,
                          ),
                        ),
                      ),
                    );
                  },
                ),

                SizedBox(height: 2.2.h),

                // ── Title ──
                Text(
                  content.title,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: AppTypography.headingFontFamily,
                    fontSize: AppTypography.headingMedium,
                    fontWeight: AppTypography.extraBold,
                    color: isDark ? Colors.white : AppColors.neutral800,
                    letterSpacing: -0.3,
                  ),
                ),

                SizedBox(height: 1.0.h),

                // ── Subtitle ──
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 2.w),
                  child: Text(
                    content.subtitle,
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
                ),

                SizedBox(height: 2.5.h),

                // ── Google Sign-In Button ──
                TactilePressable(
                  onTap: _isLoading ? null : _handleGoogleSignIn,
                  child: Container(
                    height: 5.8.h,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [AppColors.categoryAstro, AppColors.categoryAstroDark],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.categoryAstro.withValues(alpha: AppColors.opacity40),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    alignment: Alignment.center,
                    child: _isLoading
                        ? const SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(
                              strokeWidth: 2.5,
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                        : Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(
                                Icons.g_mobiledata_rounded,
                                size: 26,
                                color: Colors.white,
                              ),
                              SizedBox(width: 1.5.w),
                              Text(
                                'Sign in with Google',
                                style: TextStyle(
                                  fontSize: AppTypography.bodyMedium,
                                  fontWeight: AppTypography.extraBold,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                  ),
                ),

                // ── Error Message ──
                if (_errorMessage != null) ...[
                  SizedBox(height: 1.2.h),
                  Text(
                    _errorMessage!,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: AppTypography.labelSmall,
                      color: AppColors.softRed,
                    ),
                  ),
                ],

                SizedBox(height: 2.2.h),

                // ── Benefits List ──
                ...content.benefits.map((benefit) => Padding(
                  padding: EdgeInsets.only(bottom: 0.8.h),
                  child: Row(
                    children: [
                      SizedBox(width: 2.w),
                      Expanded(
                        child: Text(
                          benefit,
                          style: TextStyle(
                            fontSize: AppTypography.bodySmall,
                            fontWeight: AppTypography.medium,
                            color: isDark
                                ? Colors.white.withValues(alpha: 0.85)
                                : AppColors.neutral800,
                          ),
                        ),
                      ),
                    ],
                  ),
                )),

                SizedBox(height: 1.5.h),

                // ── Trust Badge ──
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 3.2.w, vertical: 0.8.h),
                  decoration: BoxDecoration(
                    color: isDark
                        ? Colors.white.withValues(alpha: 0.05)
                        : AppColors.categoryAstro.withValues(alpha: 0.06),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: isDark
                          ? Colors.white12
                          : AppColors.categoryAstro.withValues(alpha: 0.15),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.lock_outline_rounded,
                        size: 14,
                        color: isDark ? AppColors.gold : AppColors.categoryAstroDark,
                      ),
                      SizedBox(width: 1.5.w),
                      Flexible(
                        child: Text(
                          '🔒 Your data is 100% safe · No spam · No charges',
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

                SizedBox(height: 1.h),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Internal data class for intent-specific content.
class _IntentContent {
  final IconData icon;
  final String title;
  final String subtitle;
  final List<String> benefits;

  const _IntentContent({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.benefits,
  });
}
