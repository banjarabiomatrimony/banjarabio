import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';

import 'package:banjarabio/l10n/app_localizations.dart';
import 'package:banjarabio/core/constants/app_typography.dart';
import 'package:banjarabio/theme/app_colors.dart';
import 'package:banjarabio/widgets/custom_app_bar.dart';
import 'package:banjarabio/widgets/app_logo_image.dart';
import 'package:banjarabio/widgets/tactile/tactile_pressable.dart';

/// 📜 Terms & Conditions Screen — Ultra-Premium Edition
/// Features staggered entrance physics, glassmorphic card elevations, Indic typography, and legal badge formatting.
class TermsConditionsScreen extends StatefulWidget {
  const TermsConditionsScreen({super.key});

  @override
  State<TermsConditionsScreen> createState() => _TermsConditionsScreenState();
}

class _TermsConditionsScreenState extends State<TermsConditionsScreen>
    with SingleTickerProviderStateMixin {
  AnimationController? _controller;

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
    final start = (index * 0.08).clamp(0.0, 1.0);
    final end = (0.5 + (index * 0.08)).clamp(0.0, 1.0);

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

    final sections = [
      _TermsSection(
        number: '01',
        title: l10n?.termsS1Title ?? 'Acceptance of Terms',
        content: l10n?.termsS1Content ??
            'By accessing or using the BanjaraBio application, you agree to be bound by these Terms and Conditions. If you do not agree, please do not use the service.',
        icon: Icons.gavel_rounded,
        iconColor: const Color(0xFF1E88E5),
      ),
      _TermsSection(
        number: '02',
        title: l10n?.termsS2Title ?? 'Matrimonial Eligibility',
        content: l10n?.termsS2Content ??
            'You must be at least 18 years old (for females) or 21 years old (for males) to register on this platform. The platform is strictly for lawful matrimonial matchmaking purposes within the community.',
        icon: Icons.verified_user_rounded,
        iconColor: const Color(0xFF43A047),
      ),
      _TermsSection(
        number: '03',
        title: l10n?.termsS3Title ?? 'User Account & Security',
        content: l10n?.termsS3Content ??
            'You are responsible for maintaining the confidentiality of your account credentials. All information provided during registration must be authentic, accurate, and truthful.',
        icon: Icons.lock_person_rounded,
        iconColor: const Color(0xFFFB8C00),
      ),
      _TermsSection(
        number: '04',
        title: l10n?.termsS4Title ?? 'Prohibited Activities & Safety',
        content: l10n?.termsS4Content ??
            'Users are strictly prohibited from commercial solicitation, abusive behavior, harassment, spreading defamatory content, or sharing fraudulent biodatas. Violation results in instant profile termination.',
        icon: Icons.block_rounded,
        iconColor: const Color(0xFFE53935),
      ),
      _TermsSection(
        number: '05',
        title: l10n?.termsS5Title ?? 'Account Deletion & Data Purge',
        content: l10n?.termsS5Content ??
            'You may request account deletion at any time through the "Delete Account" section in your profile settings. Deletion permanently erases your profile photos, preferences, and personal biodata.',
        icon: Icons.delete_forever_rounded,
        iconColor: const Color(0xFF8E24AA),
      ),
      _TermsSection(
        number: '06',
        title: l10n?.termsS6Title ?? 'Limitation of Liability',
        content: l10n?.termsS6Content ??
            'BanjaraBio is a matrimonial facilitation platform. While we perform verification checks, members and families are strongly encouraged to perform their independent due diligence prior to matrimonial commitments.',
        icon: Icons.shield_outlined,
        iconColor: const Color(0xFF00ACC1),
      ),
      _TermsSection(
        number: '07',
        title: l10n?.termsS7Title ?? 'Governing Law & Jurisdiction',
        content: l10n?.termsS7Content ??
            'These terms shall be governed by and construed in accordance with the laws of India. Any disputes arising shall be subject to the exclusive jurisdiction of the competent courts in Maharashtra, India.',
        icon: Icons.balance_rounded,
        iconColor: const Color(0xFFE5A93C),
      ),
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
          l10n?.termsConditions ?? 'Terms & Policies',
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
            // 📜 Top Header Hero Card
            _buildAnimatedItem(
              index: 0,
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 4.5.w, vertical: 2.h),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      theme.colorScheme.primary.withValues(
                        alpha: isDark ? AppColors.opacity20 : AppColors.opacity10,
                      ),
                      theme.colorScheme.surface,
                    ],
                  ),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: theme.colorScheme.primary.withValues(
                      alpha: isDark ? AppColors.opacity30 : AppColors.opacity20,
                    ),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: isDark
                          ? Colors.black.withValues(alpha: 0.2)
                          : theme.colorScheme.primary.withValues(alpha: 0.05),
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
                        color: theme.colorScheme.primary,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: theme.colorScheme.primary.withValues(
                              alpha: AppColors.opacity40,
                            ),
                            blurRadius: 8,
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.description_rounded,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                    SizedBox(width: 4.w),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            l10n?.termsOfService ?? 'Terms of Service',
                            style: TextStyle(
                              fontFamily: AppTypography.headingFontFamily,
                              fontWeight: AppTypography.bold,
                              fontSize: AppTypography.bodyLarge,
                              color: theme.colorScheme.onSurface,
                            ),
                          ),
                          SizedBox(height: 0.3.h),
                          Text(
                            l10n?.lastUpdatedJanuary2026 ?? 'Official Community Guidelines • Updated 2026',
                            style: TextStyle(
                              color: theme.colorScheme.onSurfaceVariant,
                              fontSize: AppTypography.labelSmall,
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

            // 📜 Terms Clauses
            for (int i = 0; i < sections.length; i++)
              _buildAnimatedItem(
                index: 1 + i,
                child: Container(
                  margin: EdgeInsets.only(bottom: 1.5.h),
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
                          // Clause Number Pill
                          Container(
                            padding: EdgeInsets.symmetric(horizontal: 2.5.w, vertical: 0.3.h),
                            decoration: BoxDecoration(
                              color: sections[i].iconColor.withValues(
                                alpha: isDark ? AppColors.opacity20 : AppColors.opacity10,
                              ),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              '§ ${sections[i].number}',
                              style: TextStyle(
                                fontFamily: AppTypography.headingFontFamily,
                                fontWeight: AppTypography.bold,
                                color: sections[i].iconColor,
                                fontSize: AppTypography.labelSmall,
                              ),
                            ),
                          ),
                          SizedBox(width: 3.w),

                          // Section Title
                          Expanded(
                            child: Text(
                              sections[i].title,
                              style: TextStyle(
                                fontFamily: AppTypography.headingFontFamily,
                                fontWeight: AppTypography.bold,
                                fontSize: AppTypography.bodyMedium,
                                color: theme.colorScheme.onSurface,
                              ),
                            ),
                          ),

                          // Section Icon
                          Icon(
                            sections[i].icon,
                            color: sections[i].iconColor,
                            size: 20,
                          ),
                        ],
                      ),
                      SizedBox(height: 1.2.h),
                      Text(
                        sections[i].content,
                        style: TextStyle(
                          color: theme.colorScheme.onSurface.withValues(
                            alpha: isDark ? AppColors.opacity90 : AppColors.opacity80,
                          ),
                          fontSize: AppTypography.bodySmall,
                          height: 1.45,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

            // 🛡️ Legal Acknowledgement Footer
            _buildAnimatedItem(
              index: sections.length + 1,
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.5.h),
                decoration: BoxDecoration(
                  color: theme.colorScheme.onSurface.withValues(
                    alpha: isDark ? AppColors.opacity5 : AppColors.opacity5,
                  ),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.verified_rounded,
                      size: 18,
                      color: theme.colorScheme.primary,
                    ),
                    SizedBox(width: 3.w),
                    Expanded(
                      child: Text(
                        'By using BanjaraBio, you confirm agreement to the terms stated above.',
                        style: TextStyle(
                          color: theme.colorScheme.onSurfaceVariant,
                          fontSize: AppTypography.labelSmall,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 4.h),
          ],
        ),
      ),
    );
  }
}

class _TermsSection {
  final String number;
  final String title;
  final String content;
  final IconData icon;
  final Color iconColor;

  const _TermsSection({
    required this.number,
    required this.title,
    required this.content,
    required this.icon,
    required this.iconColor,
  });
}

