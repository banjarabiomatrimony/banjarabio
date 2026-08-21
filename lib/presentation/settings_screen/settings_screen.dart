import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sizer/sizer.dart';
import 'package:fluttertoast/fluttertoast.dart';

import 'package:banjarabio/core/repositories/auth_repository.dart';
import 'package:banjarabio/core/providers/profile_providers.dart';
import 'package:banjarabio/core/constants/app_typography.dart';
import 'package:banjarabio/core/providers/locale_provider.dart';
import 'package:banjarabio/l10n/app_localizations.dart';
import 'package:banjarabio/routes/app_routes.dart';
import 'package:banjarabio/widgets/custom_app_bar.dart';
import 'package:banjarabio/presentation/account_screen/email_preferences_screen.dart';
import 'package:banjarabio/theme/app_colors.dart';
import 'package:banjarabio/widgets/tactile/tactile_pressable.dart';
import 'package:banjarabio/widgets/app_logo_image.dart';

/// ⚙️ Dedicated App Settings Screen — Ultra-Premium Edition
/// Features staggered entrance physics, glassmorphic card elevations, tactile spring touch, and Indic typography.
class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen>
    with SingleTickerProviderStateMixin {
  AnimationController? _controller;

  AnimationController get _animController {
    _controller ??= AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 650),
    )..forward();
    return _controller!;
  }

  static const _languages = [
    {'code': 'en', 'label': 'English', 'native': 'English'},
    {'code': 'mr', 'label': 'Marathi', 'native': 'मराठी'},
    {'code': 'hi', 'label': 'Hindi', 'native': 'हिंदी'},
    {'code': 'te', 'label': 'Telugu', 'native': 'తెలుగు'},
    {'code': 'kn', 'label': 'Kannada', 'native': 'ಕನ್ನಡ'},
  ];

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
    final start = (index * 0.12).clamp(0.0, 1.0);
    final end = (0.55 + (index * 0.12)).clamp(0.0, 1.0);

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
    final currentLocale = ref.watch(localeProvider);
    final activeCode =
        currentLocale?.languageCode ??
        WidgetsBinding.instance.platformDispatcher.locale.languageCode;
    final activeLang = _languages.firstWhere(
      (l) => l['code'] == activeCode,
      orElse: () => _languages.first,
    );

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
          'Settings',
          style: (theme.appBarTheme.titleTextStyle ?? theme.textTheme.titleMedium)?.copyWith(
            fontSize: AppTypography.headingMedium,
            fontWeight: AppTypography.semiBold,
            color: theme.appBarTheme.foregroundColor ?? Colors.white,
            letterSpacing: 0.2,
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: Center(
              child: TactilePressable(
                onTap: () {
                  HapticFeedback.lightImpact();
                  _showLanguagePicker(theme, activeCode);
                },
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 2.5.w, vertical: 0.4.h),
                  decoration: BoxDecoration(
                    color: (theme.appBarTheme.foregroundColor ?? Colors.white)
                        .withValues(alpha: isDark ? AppColors.opacity12 : AppColors.opacity15),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: (theme.appBarTheme.foregroundColor ?? Colors.white)
                          .withValues(alpha: isDark ? AppColors.opacity25 : AppColors.opacity35),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.language_rounded,
                        color: theme.appBarTheme.foregroundColor ?? Colors.white,
                        size: 14,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        activeLang['native']!,
                        style: TextStyle(
                          color: theme.appBarTheme.foregroundColor ?? Colors.white,
                          fontWeight: AppTypography.bold,
                          fontSize: AppTypography.labelSmall,
                          letterSpacing: 0.2,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.only(
          left: 4.w,
          right: 4.w,
          top: 1.5.h,
          bottom: 6.h,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 🌐 1. Language Preferences
            _buildAnimatedItem(
              index: 0,
              child: _buildLanguageSection(theme),
            ),
            SizedBox(height: 2.2.h),

            // 🔔 2. Notification Preferences
            _buildAnimatedItem(
              index: 1,
              child: _buildSectionGroup(
                theme,
                title: 'Preferences',
                subtitle: 'Communication, alerts & message notifications',
                items: [
                  _PreferenceItem(
                    icon: Icons.mark_email_unread_outlined,
                    title: 'Email Notifications',
                    subtitle: 'Manage email updates, match digests & alerts',
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const EmailPreferencesScreen(),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 2.2.h),

            // ❓ 3. Support & Help
            _buildAnimatedItem(
              index: 2,
              child: _buildSectionGroup(
                theme,
                title: l10n?.supportAndHelp ?? 'Support & Help',
                subtitle: 'Help center, FAQs & direct executive assistance',
                items: [
                  _PreferenceItem(
                    icon: Icons.headset_mic_outlined,
                    title: l10n?.contactUs ?? 'Contact Us',
                    subtitle: 'Get in touch with dedicated support team',
                    onTap: () =>
                        Navigator.pushNamed(context, AppRoutes.contactUs),
                  ),
                  _PreferenceItem(
                    icon: Icons.quiz_outlined,
                    title: l10n?.faqs ?? 'FAQs & Knowledge Base',
                    subtitle: 'Frequently asked questions & app walkthroughs',
                    onTap: () => Navigator.pushNamed(context, AppRoutes.faq),
                  ),
                ],
              ),
            ),
            SizedBox(height: 2.2.h),

            // 📄 4. Legal & Information
            _buildAnimatedItem(
              index: 3,
              child: _buildSectionGroup(
                theme,
                title: l10n?.legalAndInformation ?? 'Legal & Compliance',
                subtitle: 'Terms of service, community privacy & policies',
                items: [
                  _PreferenceItem(
                    icon: Icons.gavel_rounded,
                    title: l10n?.termsAndConditions ?? 'Terms & Conditions',
                    subtitle: 'Platform terms & community guidelines',
                    onTap: () =>
                        Navigator.pushNamed(context, AppRoutes.termsConditions),
                  ),
                  _PreferenceItem(
                    icon: Icons.shield_outlined,
                    title: l10n?.privacyPolicy ?? 'Privacy Policy',
                    subtitle: 'Data protection, DPDP Act & security safeguards',
                    onTap: () =>
                        Navigator.pushNamed(context, AppRoutes.privacyPolicy),
                  ),
                ],
              ),
            ),
            SizedBox(height: 2.2.h),

            // 🚪 5. Account & Security (Logout & Deletion)
            _buildAnimatedItem(
              index: 4,
              child: _buildSectionGroup(
                theme,
                title: 'Account & Security',
                subtitle: 'Session access & permanent account controls',
                items: [
                  _PreferenceItem(
                    icon: Icons.logout_rounded,
                    title: l10n?.logout ?? 'Logout',
                    subtitle: 'Sign out of your account on this device',
                    iconColor: theme.colorScheme.primary,
                    onTap: () => _handleLogout(context),
                  ),
                  _PreferenceItem(
                    icon: Icons.delete_forever_rounded,
                    title: l10n?.deleteAccount ?? 'Delete My Account',
                    subtitle: 'Permanently purge your matrimony profile and data',
                    iconColor: theme.colorScheme.error,
                    textColor: theme.colorScheme.error,
                    onTap: () =>
                        Navigator.pushNamed(context, AppRoutes.accountDeletion),
                  ),
                ],
              ),
            ),
            SizedBox(height: 2.h),

            // ℹ️ App Version Badge
            _buildAnimatedItem(
              index: 5,
              child: Center(
                child: Column(
                  children: [
                    Text(
                      'BanjaraBio Matrimony • v2.0.0',
                      style: TextStyle(
                        fontFamily: AppTypography.bodyFontFamily,
                        fontSize: AppTypography.labelSmall,
                        fontWeight: AppTypography.medium,
                        color: theme.colorScheme.onSurfaceVariant.withValues(
                          alpha: AppColors.opacity60,
                        ),
                        letterSpacing: 0.3,
                      ),
                    ),
                    SizedBox(height: 0.3.h),
                    Text(
                      'Crafted with pride for the global Gor Banjara community',
                      style: TextStyle(
                        fontSize: 9.sp,
                        color: theme.colorScheme.onSurfaceVariant.withValues(
                          alpha: AppColors.opacity40,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _handleLogout(BuildContext context) async {
    final l10n = AppLocalizations.of(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: Text(
          'Logout Confirmation',
          style: TextStyle(
            fontSize: AppTypography.headingSmall,
            fontWeight: AppTypography.bold,
          ),
        ),
        content: Text(
          'Are you sure you want to log out of your account?',
          style: TextStyle(fontSize: AppTypography.bodyMedium),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(
              l10n?.cancel ?? 'Cancel',
              style: TextStyle(fontSize: AppTypography.bodySmall),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.primary,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(
              l10n?.logout ?? 'Logout',
              style: TextStyle(
                color: Colors.white,
                fontWeight: AppTypography.bold,
                fontSize: AppTypography.bodySmall,
              ),
            ),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      try {
        await AuthRepository().signOut();
        ref.invalidate(ownProfileProvider);
        if (context.mounted) {
          Navigator.pushNamedAndRemoveUntil(
            context,
            AppRoutes.authentication,
            (route) => false,
          );
        }
      } catch (e) {
        if (context.mounted) {
          Fluttertoast.showToast(
            msg: 'Failed to logout. Please try again.',
            toastLength: Toast.LENGTH_LONG,
          );
        }
      }
    }
  }

  Widget _buildLanguageSection(ThemeData theme) {
    final isDark = theme.brightness == Brightness.dark;
    final currentLocale = ref.watch(localeProvider);
    final activeCode =
        currentLocale?.languageCode ??
        WidgetsBinding.instance.platformDispatcher.locale.languageCode;
    final activeLang = _languages.firstWhere(
      (l) => l['code'] == activeCode,
      orElse: () => _languages.first,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader(
          theme,
          title: AppLocalizations.of(context)?.language ?? 'Language & Region',
          subtitle: 'Choose your preferred language for biodata and navigation',
        ),
        SizedBox(height: 1.2.h),
        TactilePressable(
          onTap: () {
            HapticFeedback.lightImpact();
            _showLanguagePicker(theme, activeCode);
          },
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.6.h),
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isDark
                    ? theme.colorScheme.outlineVariant.withValues(alpha: AppColors.opacity20)
                    : theme.colorScheme.outlineVariant.withValues(alpha: AppColors.opacity40),
              ),
              boxShadow: [
                BoxShadow(
                  color: isDark
                      ? Colors.black.withValues(alpha: 0.25)
                      : theme.colorScheme.primary.withValues(alpha: 0.04),
                  blurRadius: 10,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary.withValues(
                      alpha: isDark ? AppColors.opacity20 : AppColors.opacity10,
                    ),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.translate_rounded,
                    color: theme.colorScheme.primary,
                    size: 20,
                  ),
                ),
                SizedBox(width: 3.5.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        AppLocalizations.of(context)?.changeLanguage ??
                            'App Language',
                        style: TextStyle(
                          fontFamily: AppTypography.headingFontFamily,
                          fontWeight: AppTypography.bold,
                          fontSize: AppTypography.bodyMedium,
                          color: theme.colorScheme.onSurface,
                        ),
                      ),
                      SizedBox(height: 0.3.h),
                      Row(
                        children: [
                          Container(
                            padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 0.2.h),
                            decoration: BoxDecoration(
                              color: theme.colorScheme.primary.withValues(
                                alpha: isDark ? AppColors.opacity20 : AppColors.opacity8,
                              ),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              activeLang['native']!,
                              style: TextStyle(
                                fontFamily: AppTypography.headingFontFamily,
                                fontWeight: AppTypography.bold,
                                color: theme.colorScheme.primary,
                                fontSize: AppTypography.labelSmall,
                              ),
                            ),
                          ),
                          SizedBox(width: 2.w),
                          Text(
                            activeLang['label']!,
                            style: TextStyle(
                              color: theme.colorScheme.onSurfaceVariant,
                              fontSize: AppTypography.labelSmall,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.onSurface.withValues(
                      alpha: isDark ? AppColors.opacity8 : AppColors.opacity5,
                    ),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.chevron_right_rounded,
                    color: theme.colorScheme.onSurfaceVariant,
                    size: 18,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  void _showLanguagePicker(ThemeData theme, String activeCode) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => _AnimatedLanguageModal(
        languages: _languages,
        activeCode: activeCode,
        onLanguageSelected: (code) {
          ref.read(localeProvider.notifier).setLocale(Locale(code));
        },
      ),
    );
  }

  Widget _buildSectionHeader(
    ThemeData theme, {
    required String title,
    required String subtitle,
  }) {
    return Padding(
      padding: EdgeInsets.only(left: 1.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontFamily: AppTypography.headingFontFamily,
              fontWeight: AppTypography.bold,
              color: theme.colorScheme.onSurface,
              fontSize: AppTypography.bodyLarge,
            ),
          ),
          SizedBox(height: 0.2.h),
          Text(
            subtitle,
            style: TextStyle(
              color: theme.colorScheme.onSurfaceVariant,
              fontSize: AppTypography.labelSmall,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionGroup(
    ThemeData theme, {
    required String title,
    required String subtitle,
    required List<_PreferenceItem> items,
  }) {
    final isDark = theme.brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader(theme, title: title, subtitle: subtitle),
        SizedBox(height: 1.2.h),
        Container(
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isDark
                  ? theme.colorScheme.outlineVariant.withValues(alpha: AppColors.opacity20)
                  : theme.colorScheme.outlineVariant.withValues(alpha: AppColors.opacity40),
            ),
            boxShadow: [
              BoxShadow(
                color: isDark
                    ? Colors.black.withValues(alpha: 0.25)
                    : theme.colorScheme.primary.withValues(alpha: 0.04),
                blurRadius: 10,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Column(
            children: List.generate(items.length, (index) {
              final item = items[index];
              return Column(
                children: [
                  TactilePressable(
                    onTap: () {
                      HapticFeedback.lightImpact();
                      item.onTap();
                    },
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: 4.w,
                        vertical: 1.5.h,
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(9),
                            decoration: BoxDecoration(
                              color: (item.iconColor ?? theme.colorScheme.primary)
                                  .withValues(
                                    alpha: isDark ? AppColors.opacity20 : AppColors.opacity10,
                                  ),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              item.icon,
                              color: item.iconColor ?? theme.colorScheme.primary,
                              size: 19,
                            ),
                          ),
                          SizedBox(width: 3.5.w),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  item.title,
                                  style: TextStyle(
                                    fontFamily: AppTypography.headingFontFamily,
                                    color: item.textColor ?? theme.colorScheme.onSurface,
                                    fontWeight: AppTypography.semiBold,
                                    fontSize: AppTypography.bodyMedium,
                                  ),
                                ),
                                if (item.subtitle != null) ...[
                                  SizedBox(height: 0.2.h),
                                  Text(
                                    item.subtitle!,
                                    style: TextStyle(
                                      color: theme.colorScheme.onSurfaceVariant,
                                      fontSize: AppTypography.labelSmall,
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: theme.colorScheme.onSurface.withValues(
                                alpha: isDark ? AppColors.opacity8 : AppColors.opacity5,
                              ),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.chevron_right_rounded,
                              color: theme.colorScheme.onSurfaceVariant,
                              size: 16,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  if (index != items.length - 1)
                    Divider(
                      height: 1,
                      indent: 14.w,
                      color: isDark
                          ? theme.dividerColor.withValues(alpha: AppColors.opacity20)
                          : theme.dividerColor.withValues(alpha: AppColors.opacity50),
                    ),
                ],
              );
            }),
          ),
        ),
      ],
    );
  }
}

class _PreferenceItem {
  final IconData icon;
  final String title;
  final String? subtitle;
  final VoidCallback onTap;
  final Color? iconColor;
  final Color? textColor;

  const _PreferenceItem({
    required this.icon,
    required this.title,
    this.subtitle,
    required this.onTap,
    this.iconColor,
    this.textColor,
  });
}

/// 🌐 Ultra-Premium Animated Language Picker Modal
class _AnimatedLanguageModal extends StatefulWidget {
  final List<Map<String, String>> languages;
  final String activeCode;
  final ValueChanged<String> onLanguageSelected;

  const _AnimatedLanguageModal({
    required this.languages,
    required this.activeCode,
    required this.onLanguageSelected,
  });

  @override
  State<_AnimatedLanguageModal> createState() => _AnimatedLanguageModalState();
}

class _AnimatedLanguageModalState extends State<_AnimatedLanguageModal>
    with SingleTickerProviderStateMixin {
  late AnimationController _sheetController;
  late String _selectedCode;

  @override
  void initState() {
    super.initState();
    _selectedCode = widget.activeCode;
    _sheetController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    )..forward();
  }

  @override
  void dispose() {
    _sheetController.dispose();
    super.dispose();
  }

  Widget _buildLanguageTile({
    required ThemeData theme,
    required bool isDark,
    required Map<String, String> lang,
    required int index,
  }) {
    final isSelected = lang['code'] == _selectedCode;
    final start = (index * 0.1).clamp(0.0, 1.0);
    final end = (0.5 + (index * 0.1)).clamp(0.0, 1.0);

    return SlideTransition(
      position: Tween<Offset>(
        begin: const Offset(0, 0.25),
        end: Offset.zero,
      ).animate(
        CurvedAnimation(
          parent: _sheetController,
          curve: Interval(start, end, curve: Curves.easeOutCubic),
        ),
      ),
      child: FadeTransition(
        opacity: Tween<double>(begin: 0.0, end: 1.0).animate(
          CurvedAnimation(
            parent: _sheetController,
            curve: Interval(start, end, curve: Curves.easeOut),
          ),
        ),
        child: Padding(
          padding: EdgeInsets.only(bottom: 1.2.h),
          child: TactilePressable(
            onTap: () {
              HapticFeedback.selectionClick();
              final nav = Navigator.of(context);
              setState(() {
                _selectedCode = lang['code']!;
              });
              Future.delayed(const Duration(milliseconds: 180), () {
                if (mounted) {
                  nav.pop();
                  widget.onLanguageSelected(lang['code']!);
                }
              });
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 220),
              curve: Curves.easeOut,
              padding: EdgeInsets.symmetric(
                horizontal: 4.w,
                vertical: 1.5.h,
              ),
              decoration: BoxDecoration(
                color: isSelected
                    ? theme.colorScheme.primary.withValues(
                        alpha: isDark ? AppColors.opacity20 : AppColors.opacity8,
                      )
                    : theme.colorScheme.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isSelected
                      ? theme.colorScheme.primary
                      : theme.colorScheme.outlineVariant.withValues(
                          alpha: isDark ? AppColors.opacity20 : AppColors.opacity40,
                        ),
                  width: isSelected ? 1.8 : 1,
                ),
                boxShadow: isSelected
                    ? [
                        BoxShadow(
                          color: theme.colorScheme.primary.withValues(
                            alpha: isDark ? AppColors.opacity25 : AppColors.opacity15,
                          ),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ]
                    : null,
              ),
              child: Row(
                children: [
                  // 🔤 Indic First Letter Badge
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 220),
                    width: 40,
                    height: 40,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: isSelected
                          ? theme.colorScheme.primary
                          : theme.colorScheme.onSurface.withValues(
                              alpha: isDark ? AppColors.opacity12 : AppColors.opacity8,
                            ),
                      shape: BoxShape.circle,
                    ),
                    child: Text(
                      lang['native']!.substring(0, 1),
                      style: TextStyle(
                        fontWeight: AppTypography.bold,
                        fontSize: AppTypography.bodyLarge,
                        color: isSelected
                            ? Colors.white
                            : theme.colorScheme.onSurface,
                      ),
                    ),
                  ),
                  SizedBox(width: 4.w),

                  // 🏷️ Localized and Latin Labels
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          lang['native']!,
                          style: TextStyle(
                            fontFamily: AppTypography.headingFontFamily,
                            fontSize: AppTypography.bodyLarge,
                            fontWeight: isSelected
                                ? AppTypography.bold
                                : AppTypography.semiBold,
                            color: isSelected
                                ? theme.colorScheme.primary
                                : theme.colorScheme.onSurface,
                          ),
                        ),
                        SizedBox(height: 0.2.h),
                        Text(
                          lang['label']!,
                          style: TextStyle(
                            color: theme.colorScheme.onSurfaceVariant,
                            fontSize: AppTypography.labelSmall,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // ✨ Animated Checkmark Badge
                  AnimatedScale(
                    duration: const Duration(milliseconds: 200),
                    scale: isSelected ? 1.0 : 0.0,
                    child: Container(
                      padding: const EdgeInsets.all(5),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primary,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: theme.colorScheme.primary.withValues(
                              alpha: AppColors.opacity30,
                            ),
                            blurRadius: 6,
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.check_rounded,
                        color: Colors.white,
                        size: 16,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.5 : 0.2),
            blurRadius: 28,
            offset: const Offset(0, -6),
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 5.w, vertical: 2.h),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // 🔘 Top Drag Pill
              Container(
                width: 12.w,
                height: 4,
                margin: EdgeInsets.only(bottom: 2.h),
                decoration: BoxDecoration(
                  color: theme.dividerColor.withValues(alpha: AppColors.opacity80),
                  borderRadius: BorderRadius.circular(4),
                ),
              ),

              // 🏷️ Header with Globe Badge
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primary.withValues(
                        alpha: isDark ? AppColors.opacity20 : AppColors.opacity10,
                      ),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.translate_rounded,
                      color: theme.colorScheme.primary,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    AppLocalizations.of(context)?.changeLanguage ??
                        'Choose Preferred Language',
                    style: TextStyle(
                      fontFamily: AppTypography.headingFontFamily,
                      fontWeight: AppTypography.bold,
                      fontSize: AppTypography.headingSmall,
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 0.6.h),
              Text(
                'Select language for biodata cards, chat & app UI',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: theme.colorScheme.onSurfaceVariant,
                  fontSize: AppTypography.labelSmall,
                ),
              ),
              SizedBox(height: 2.2.h),

              // 📜 Staggered Language Cards
              for (int i = 0; i < widget.languages.length; i++)
                _buildLanguageTile(
                  theme: theme,
                  isDark: isDark,
                  lang: widget.languages[i],
                  index: i,
                ),

              SizedBox(height: 1.h),
            ],
          ),
        ),
      ),
    );
  }
}
