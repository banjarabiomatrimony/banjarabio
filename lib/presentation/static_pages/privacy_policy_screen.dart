import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';

import 'package:banjarabio/l10n/app_localizations.dart';
import 'package:banjarabio/core/constants/app_typography.dart';
import 'package:banjarabio/theme/app_colors.dart';
import 'package:banjarabio/widgets/custom_app_bar.dart';
import 'package:banjarabio/widgets/app_logo_image.dart';
import 'package:banjarabio/widgets/tactile/tactile_pressable.dart';

/// 🔒 Privacy Policy Screen — Ultra-Premium Edition
/// Features staggered entrance physics, glassmorphic card elevations, Indic typography, and security badge formatting.
class PrivacyPolicyScreen extends StatefulWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  State<PrivacyPolicyScreen> createState() => _PrivacyPolicyScreenState();
}

class _PrivacyPolicyScreenState extends State<PrivacyPolicyScreen>
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
      _PrivacySection(
        number: '01',
        title: l10n?.privacyS1Title ?? 'Information We Collect',
        icon: Icons.fingerprint_rounded,
        iconColor: const Color(0xFF1E88E5),
        bulletPoints: [
          'Personal Biodata: Name, age, gender, gotra / sub-caste, education, occupation, and family background.',
          'Contact Details: Phone number and email address (strictly encrypted & gated).',
          'Media & Photos: User-uploaded profile and family album photographs.',
          'Device & Safety Logs: Device ID and IP address for session security and spam prevention.',
          'Location Context: Approximate city and district to recommend nearby community matches.',
        ],
      ),
      _PrivacySection(
        number: '02',
        title: l10n?.privacyS2Title ?? 'Purpose of Data Collection',
        icon: Icons.shield_rounded,
        iconColor: const Color(0xFF43A047),
        bulletPoints: [
          'Matchmaking Functionality: Creating your profile and displaying relevant candidate suggestions.',
          'Identity Verification: Community trust screening and fraudulent profile prevention.',
          'Performance & Analytics: Optimizing app responsiveness using Firebase monitoring.',
          'Local Matches: Optional "Near Me" district search based on user consent.',
        ],
      ),
      _PrivacySection(
        number: '03',
        title: l10n?.privacyS3Title ?? 'Device Permissions & Usage',
        icon: Icons.perm_device_information_rounded,
        iconColor: const Color(0xFFFB8C00),
        bulletPoints: [
          'Camera & Photos: Required only when uploading or updating your biodata photos.',
          'Location Access: Optional permission used to auto-fill native district and nearest melavas.',
          'Push Notifications: Timely alerts for mutual matches, direct messages, and biodata views.',
        ],
      ),
      _PrivacySection(
        number: '04',
        title: l10n?.privacyS4Title ?? 'Disclosure & Third Parties',
        icon: Icons.hub_rounded,
        iconColor: const Color(0xFF8E24AA),
        bulletPoints: [
          'Registered Members: Verified users can view public profile details (contact info remains hidden unless mutually shared).',
          'Database Infrastructure: Supabase backend hosting with strict row-level encryption.',
          'Zero Ad-Selling Policy: We never sell, rent, or monetize your personal information to third-party ad networks.',
        ],
      ),
      _PrivacySection(
        number: '05',
        title: l10n?.privacyS5Title ?? 'Data Security & Account Deletion',
        icon: Icons.lock_reset_rounded,
        iconColor: const Color(0xFFE53935),
        bulletPoints: [
          'End-to-End Security: Industry-standard TLS encryption protects all in-flight network data.',
          'Instant Purge: Request permanent account deletion via Account > Legal > Account Deletion to erase all photos and biodata forever.',
        ],
      ),
      _PrivacySection(
        number: '06',
        title: l10n?.privacyS6Title ?? 'Governing Law & Legal Rights',
        icon: Icons.balance_rounded,
        iconColor: const Color(0xFF00ACC1),
        bulletPoints: [
          'This Privacy Policy is governed by the Information Technology Act and laws of India.',
          'Any legal disputes are subject to the exclusive jurisdiction of the competent courts in Maharashtra, India.',
        ],
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
          l10n?.privacyPolicy ?? 'Privacy Policy',
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
            // 🔒 Top Header Hero Card
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
                        Icons.verified_user_rounded,
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
                            l10n?.privacyPolicy ?? 'Privacy & Data Safety',
                            style: TextStyle(
                              fontFamily: AppTypography.headingFontFamily,
                              fontWeight: AppTypography.bold,
                              fontSize: AppTypography.bodyLarge,
                              color: theme.colorScheme.onSurface,
                            ),
                          ),
                          SizedBox(height: 0.3.h),
                          Text(
                            'Your trust matters. Read how we protect, encrypt, and handle your biodata.',
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

            // 📜 Privacy Clauses
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
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: sections[i].bulletPoints.map((point) {
                          return Padding(
                            padding: EdgeInsets.only(bottom: 0.8.h),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  margin: EdgeInsets.only(top: 0.8.h, right: 2.5.w),
                                  width: 5,
                                  height: 5,
                                  decoration: BoxDecoration(
                                    color: sections[i].iconColor,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                Expanded(
                                  child: Text(
                                    point,
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
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                ),
              ),

            // 🛡️ Data Guarantee Footer
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
                      Icons.shield_outlined,
                      size: 18,
                      color: theme.colorScheme.primary,
                    ),
                    SizedBox(width: 3.w),
                    Expanded(
                      child: Text(
                        '100% Verified Community. Your biodata is protected under strict Indian Privacy Standards.',
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

class _PrivacySection {
  final String number;
  final String title;
  final IconData icon;
  final Color iconColor;
  final List<String> bulletPoints;

  const _PrivacySection({
    required this.number,
    required this.title,
    required this.icon,
    required this.iconColor,
    required this.bulletPoints,
  });
}

