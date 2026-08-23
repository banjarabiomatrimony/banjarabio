import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';

import 'package:banjarabio/l10n/app_localizations.dart';
import 'package:banjarabio/core/constants/app_typography.dart';
import 'package:banjarabio/theme/app_colors.dart';
import 'package:banjarabio/routes/app_routes.dart';
import 'package:banjarabio/widgets/custom_app_bar.dart';
import 'package:banjarabio/widgets/app_logo_image.dart';
import 'package:banjarabio/widgets/tactile/tactile_pressable.dart';
import 'package:banjarabio/core/repositories/auth_repository.dart';

/// ⚠️ Permanent Account Deletion Screen — Ultra-Premium Guard Edition
/// Features staggered entrance physics, warning consequence cards, explicit consent checkbox, and irreversible action safeguards.
class AccountDeletionScreen extends StatefulWidget {
  const AccountDeletionScreen({super.key});

  @override
  State<AccountDeletionScreen> createState() => _AccountDeletionScreenState();
}

class _AccountDeletionScreenState extends State<AccountDeletionScreen>
    with SingleTickerProviderStateMixin {
  AnimationController? _controller;
  bool _isConfirmed = false;
  bool _isLoading = false;

  AnimationController get _animController {
    _controller ??= AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 650),
    )..forward();
    return _controller!;
  }

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 650),
    );
    _controller!.forward();
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  Widget _buildAnimatedItem({required int index, required Widget child}) {
    final start = (index * 0.1).clamp(0.0, 1.0);
    final end = (0.55 + (index * 0.1)).clamp(0.0, 1.0);

    return SlideTransition(
      position: Tween<Offset>(
        begin: const Offset(0, 0.15),
        end: Offset.zero,
      ).animate(
        CurvedAnimation(
          parent: _animController,
          curve: Interval(start, end, curve: Curves.easeOutCubic),
        ),
      ),
      child: FadeTransition(
        opacity: Tween<double>(begin: 0.0, end: 1.0).animate(
          CurvedAnimation(
            parent: _animController,
            curve: Interval(start, end, curve: Curves.easeOut),
          ),
        ),
        child: child,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final l10n = AppLocalizations.of(context);

    final consequences = [
      'All your matrimonial biodata, photos, and family records will be erased permanently from the system.',
      'Active Premium memberships and unused contact unlocks will be cancelled without refund.',
      'All active chats, mutual match histories, and bookmark links will be permanently severed.',
      'This action cannot be reversed. If you wish to take a temporary break, try Logging Out instead.',
    ];

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: CustomAppBar(
        automaticallyImplyLeading: false,
        leadingWidth: 155,
        leading: Padding(
          padding: const EdgeInsets.only(left: 8),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              // ⬅️ Tactile Back Button
              TactilePressable(
                onTap: () {
                  HapticFeedback.lightImpact();
                  Navigator.maybePop(context);
                },
                child: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: (theme.appBarTheme.foregroundColor ?? Colors.white)
                        .withValues(alpha: isDark ? AppColors.opacity12 : AppColors.opacity15),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.arrow_back_ios_new_rounded,
                    color: theme.appBarTheme.foregroundColor ?? Colors.white,
                    size: 15,
                  ),
                ),
              ),
              const SizedBox(width: 8),

              // 👑 App Logo
              ClipOval(
                child: Container(
                  width: 24,
                  height: 24,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                  ),
                  child: const AppLogoImage(
                    width: 24,
                    height: 24,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              const SizedBox(width: 5),

              // 🏷️ Wordmark
              Image.asset(
                'assets/logo/brand_kit/wordmark.png',
                height: 20,
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) =>
                    const SizedBox.shrink(),
              ),
            ],
          ),
        ),
        titleWidget: Text(
          l10n?.deleteAccount ?? 'Delete Account',
          style: (theme.appBarTheme.titleTextStyle ?? theme.textTheme.titleMedium)?.copyWith(
            fontSize: AppTypography.headingMedium,
            fontWeight: AppTypography.semiBold,
            color: theme.appBarTheme.foregroundColor ?? Colors.white,
            letterSpacing: 0.2,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ⚠️ Danger Zone Hero Banner
            _buildAnimatedItem(
              index: 0,
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 4.5.w, vertical: 2.2.h),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      theme.colorScheme.error.withValues(
                        alpha: isDark ? AppColors.opacity20 : AppColors.opacity10,
                      ),
                      theme.colorScheme.surface,
                    ],
                  ),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: theme.colorScheme.error.withValues(
                      alpha: isDark ? AppColors.opacity40 : AppColors.opacity25,
                    ),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: isDark
                          ? Colors.black.withValues(alpha: 0.2)
                          : theme.colorScheme.error.withValues(alpha: 0.05),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.error,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: theme.colorScheme.error.withValues(
                              alpha: AppColors.opacity40,
                            ),
                            blurRadius: 8,
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.warning_amber_rounded,
                        color: Colors.white,
                        size: 26,
                      ),
                    ),
                    SizedBox(width: 4.w),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            l10n?.areYouSureYouWantToDeleteYourAccount ??
                                'Permanent Account Termination',
                            style: TextStyle(
                              fontFamily: AppTypography.headingFontFamily,
                              fontWeight: AppTypography.bold,
                              fontSize: AppTypography.bodyLarge,
                              color: theme.colorScheme.onSurface,
                            ),
                          ),
                          SizedBox(height: 0.3.h),
                          Text(
                            'Please review what happens when you purge your BanjaraBio profile.',
                            style: TextStyle(
                              color: theme.colorScheme.onSurfaceVariant,
                              fontSize: AppTypography.labelSmall,
                              height: 1.3,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 2.2.h),

            // 📜 Consequence Checklist Card
            _buildAnimatedItem(
              index: 1,
              child: Container(
                padding: EdgeInsets.all(4.w),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surface,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(
                    color: isDark
                        ? theme.colorScheme.outlineVariant.withValues(alpha: AppColors.opacity20)
                        : theme.colorScheme.outlineVariant.withValues(alpha: AppColors.opacity40),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.03),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.error_outline_rounded,
                          color: theme.colorScheme.error,
                          size: 20,
                        ),
                        SizedBox(width: 2.5.w),
                        Flexible(
                          child: Text(
                            l10n?.deletingYourAccountWillResultIn ??
                                'Deleting your account will result in:',
                            style: TextStyle(
                              fontFamily: AppTypography.headingFontFamily,
                              fontWeight: AppTypography.bold,
                              fontSize: AppTypography.bodyMedium,
                              color: theme.colorScheme.onSurface,
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 1.5.h),
                    for (int i = 0; i < consequences.length; i++)
                      Padding(
                        padding: EdgeInsets.only(bottom: 1.2.h),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              margin: EdgeInsets.only(top: 0.6.h, right: 3.w),
                              width: 6,
                              height: 6,
                              decoration: BoxDecoration(
                                color: theme.colorScheme.error,
                                shape: BoxShape.circle,
                              ),
                            ),
                            Expanded(
                              child: Text(
                                consequences[i],
                                style: TextStyle(
                                  color: theme.colorScheme.onSurface.withValues(
                                    alpha: isDark ? AppColors.opacity90 : AppColors.opacity80,
                                  ),
                                  fontSize: AppTypography.bodySmall,
                                  height: 1.4,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 2.5.h),

            // ☑️ Explicit Consent Checkbox
            _buildAnimatedItem(
              index: 2,
              child: TactilePressable(
                onTap: () {
                  HapticFeedback.selectionClick();
                  setState(() {
                    _isConfirmed = !_isConfirmed;
                  });
                },
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.2.h),
                  decoration: BoxDecoration(
                    color: _isConfirmed
                        ? theme.colorScheme.error.withValues(
                            alpha: isDark ? AppColors.opacity15 : AppColors.opacity8,
                          )
                        : theme.colorScheme.surface,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: _isConfirmed
                          ? theme.colorScheme.error.withValues(
                              alpha: isDark ? AppColors.opacity50 : AppColors.opacity40,
                            )
                          : isDark
                              ? theme.colorScheme.outlineVariant.withValues(alpha: AppColors.opacity20)
                              : theme.colorScheme.outlineVariant.withValues(alpha: AppColors.opacity40),
                    ),
                  ),
                  child: Row(
                    children: [
                      Checkbox(
                        value: _isConfirmed,
                        activeColor: theme.colorScheme.error,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(4),
                        ),
                        onChanged: (val) {
                          HapticFeedback.selectionClick();
                          setState(() {
                            _isConfirmed = val ?? false;
                          });
                        },
                      ),
                      SizedBox(width: 2.w),
                      Expanded(
                        child: Text(
                          l10n?.iUnderstandThatThisActionCannotBeUndone ??
                              'I understand that this action is permanent and cannot be undone.',
                          style: TextStyle(
                            fontFamily: AppTypography.headingFontFamily,
                            fontWeight: _isConfirmed
                                ? AppTypography.bold
                                : AppTypography.medium,
                            fontSize: AppTypography.labelSmall,
                            color: _isConfirmed
                                ? theme.colorScheme.error
                                : theme.colorScheme.onSurface,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            SizedBox(height: 3.h),

            // 🚀 Destructive Action Button
            _buildAnimatedItem(
              index: 3,
              child: TactilePressable(
                onTap: _isConfirmed && !_isLoading ? _handleDelete : null,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 240),
                  width: double.infinity,
                  padding: EdgeInsets.symmetric(vertical: 1.6.h),
                  decoration: BoxDecoration(
                    color: _isConfirmed
                        ? theme.colorScheme.error
                        : theme.colorScheme.onSurface.withValues(
                            alpha: isDark ? AppColors.opacity12 : AppColors.opacity8,
                          ),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: _isConfirmed
                        ? [
                            BoxShadow(
                              color: theme.colorScheme.error.withValues(
                                alpha: AppColors.opacity40,
                              ),
                              blurRadius: 14,
                              offset: const Offset(0, 4),
                            ),
                          ]
                        : null,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (_isLoading)
                        SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.2,
                            color: _isConfirmed
                                ? Colors.white
                                : theme.colorScheme.onSurfaceVariant,
                          ),
                        )
                      else ...[
                        Icon(
                          Icons.delete_forever_rounded,
                          color: _isConfirmed
                              ? Colors.white
                              : theme.colorScheme.onSurfaceVariant.withValues(
                                  alpha: AppColors.opacity60,
                                ),
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          l10n?.deleteMyAccount ?? 'Permanently Delete My Account',
                          style: TextStyle(
                            fontFamily: AppTypography.headingFontFamily,
                            fontWeight: AppTypography.bold,
                            fontSize: AppTypography.bodyMedium,
                            color: _isConfirmed
                                ? Colors.white
                                : theme.colorScheme.onSurfaceVariant.withValues(
                                    alpha: AppColors.opacity60,
                                  ),
                            letterSpacing: 0.3,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
            SizedBox(height: 4.h),
          ],
        ),
      ),
    );
  }

  Future<void> _handleDelete() async {
    HapticFeedback.heavyImpact();
    setState(() => _isLoading = true);

    try {
      final authRepository = AuthRepository();
      final result = await authRepository.deleteAccount();

      if (!mounted) return;

      await result.fold(
        onSuccess: (_) {
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                AppLocalizations.of(context)?.accountAndAllDataDeletedSuccessfully ??
                    'Account and all data deleted successfully.',
              ),
              backgroundColor: Colors.green,
            ),
          );
          // Navigate to splash/login and clear stack
          Navigator.pushNamedAndRemoveUntil(
            context,
            AppRoutes.splash,
            (route) => false,
          );
        },
        onFailure: (error) {
          if (!mounted) return;
          setState(() => _isLoading = false);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                AppLocalizations.of(context)?.failedToDeleteAccount(error) ??
                    'Failed to delete account: $error',
              ),
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
          );
        },
      );
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              AppLocalizations.of(context)?.failedToDeleteAccount(e.toString()) ??
                  'Failed to delete account: ${e.toString()}',
            ),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    }
  }
}

