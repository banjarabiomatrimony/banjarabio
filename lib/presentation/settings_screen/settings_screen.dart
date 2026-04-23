import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sizer/sizer.dart';

import 'package:banjarabio/core/app_export.dart';
import 'package:banjarabio/core/providers/locale_provider.dart';
import 'package:banjarabio/core/repositories/auth_repository.dart';
import 'package:banjarabio/widgets/custom_app_bar.dart';
import 'package:banjarabio/widgets/app_logo_image.dart';
import 'package:banjarabio/l10n/app_localizations.dart';
import 'package:banjarabio/presentation/settings_screen/marriage_reward_form_screen.dart';
import 'package:banjarabio/presentation/settings_screen/email_preferences_screen.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  final AuthRepository _authRepository = AuthRepository();

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 800));
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: CustomAppBar(
        title: l10n?.settingsAndMenu ?? 'Settings & Menu',
        automaticallyImplyLeading: false,
        leading: Padding(
            padding: EdgeInsets.all(1.h), child: AppLogoImage(height: 3.5.h)),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
        child: Column(
          children: [
            _buildAnimatedItem(
                index: 0, child: _buildReferralBanner(context, theme)),
            SizedBox(height: 2.h),
            _buildMarriageRewardBanner(context, theme),
            SizedBox(height: 3.h),
            _buildAnimatedItem(
              index: 1,
              child: _buildSectionGroup(
                theme,
                title: l10n?.supportAndHelp ?? 'Support & Help',
                items: [
                  _SettingsItem(
                      icon: 'contact_support',
                      title: l10n?.contactUs ?? 'Contact Us',
                      onTap: () =>
                          Navigator.pushNamed(context, AppRoutes.contactUs)),
                  _SettingsItem(
                      icon: 'help_outline',
                      title: l10n?.faqs ?? 'FAQs',
                      onTap: () => Navigator.pushNamed(context, AppRoutes.faq)),
                ],
              ),
            ),
            SizedBox(height: 3.h),
            _buildAnimatedItem(
              index: 2,
              child: _buildSectionGroup(
                theme,
                title: l10n?.legalAndInformation ?? 'Legal & Information',
                items: [
                  _SettingsItem(
                      icon: 'description',
                      title: l10n?.termsAndConditions ?? 'Terms & Conditions',
                      onTap: () => Navigator.pushNamed(
                          context, AppRoutes.termsConditions)),
                  _SettingsItem(
                      icon: 'privacy_tip',
                      title: l10n?.privacyPolicy ?? 'Privacy Policy',
                      onTap: () => Navigator.pushNamed(
                          context, AppRoutes.privacyPolicy)),
                ],
              ),
            ),
            SizedBox(height: 3.h),
            _buildAnimatedItem(
              index: 2,
              child: _buildSectionGroup(
                theme,
                title: 'Notifications',
                items: [
                  _SettingsItem(
                    icon: 'notifications_none',
                    title: 'Email Notifications',
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const EmailPreferencesScreen()),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 3.h),
            _buildAnimatedItem(index: 3, child: _buildLanguageSection(theme)),
            SizedBox(height: 3.h),
            _buildAnimatedItem(
              index: 4,
              child: _buildSectionGroup(
                theme,
                title: l10n?.account ?? 'Account',
                items: [
                  _SettingsItem(
                      icon: 'delete_forever',
                      title: l10n?.deleteMyAccount ?? 'Delete My Account',
                      onTap: () => Navigator.pushNamed(
                          context, AppRoutes.accountDeletion)),
                ],
              ),
            ),
            SizedBox(height: 3.h),
            _buildAnimatedItem(index: 5, child: _buildLogoutButton(context, theme)),
            SizedBox(height: 10.h),
          ],
        ),
      ),
    );
  }

  static const _languages = [
    {'code': 'en', 'label': 'English', 'native': 'English'},
    {'code': 'mr', 'label': 'Marathi', 'native': 'मराठी'},
    {'code': 'hi', 'label': 'Hindi', 'native': 'हिंदी'},
    {'code': 'te', 'label': 'Telugu', 'native': 'తెలుగు'},
    {'code': 'kn', 'label': 'Kannada', 'native': 'ಕನ್ನಡ'},
  ];

  Widget _buildLanguageSection(ThemeData theme) {
    final currentLocale = ref.watch(localeProvider);
    final activeCode = currentLocale?.languageCode ??
        WidgetsBinding.instance.platformDispatcher.locale.languageCode;
    final activeLabel = _languages.firstWhere((l) => l['code'] == activeCode,
        orElse: () => _languages.first)['native']!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.only(left: 2.w, bottom: 1.h),
          child: Text(
            AppLocalizations.of(context)?.language ?? 'Language',
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
              fontSize: 13.sp,
            ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: theme.cardColor,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 4))
            ],
          ),
          child: ListTile(
            contentPadding:
                EdgeInsets.symmetric(horizontal: 4.w, vertical: 0.5.h),
            leading: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: theme.colorScheme.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(Icons.language_rounded,
                  color: theme.colorScheme.primary, size: 20),
            ),
            title: Text(
                AppLocalizations.of(context)?.changeLanguage ??
                    'Change Language',
                style: theme.textTheme.bodyMedium
                    ?.copyWith(fontWeight: FontWeight.w600)),
            subtitle: Text(activeLabel,
                style: theme.textTheme.bodySmall
                    ?.copyWith(color: theme.colorScheme.primary)),
            trailing: Icon(Icons.chevron_right_rounded,
                color: theme.colorScheme.onSurface.withValues(alpha: 0.4)),
            onTap: () => _showLanguagePicker(theme, activeCode),
          ),
        ),
      ],
    );
  }

  void _showLanguagePicker(ThemeData theme, String activeCode) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 2.h),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                  width: 10.w,
                  height: 0.5.h,
                  margin: EdgeInsets.only(bottom: 2.h),
                  decoration: BoxDecoration(
                      color: theme.dividerColor,
                      borderRadius: BorderRadius.circular(4))),
              Text(
                  AppLocalizations.of(context)?.changeLanguage ??
                      'Change Language',
                  style: theme.textTheme.titleMedium
                      ?.copyWith(fontWeight: FontWeight.bold)),
              SizedBox(height: 1.h),
              ..._languages.map((lang) {
                final isSelected = lang['code'] == activeCode;
                return ListTile(
                  leading: Text(lang['native']!,
                      style: theme.textTheme.titleSmall?.copyWith(
                          fontSize: 18,
                          color: isSelected
                              ? theme.colorScheme.primary
                              : theme.colorScheme.onSurface)),
                  title: Text(lang['label']!,
                      style: theme.textTheme.bodyMedium?.copyWith(
                          color: isSelected ? theme.colorScheme.primary : null,
                          fontWeight:
                              isSelected ? FontWeight.bold : FontWeight.normal)),
                  trailing: isSelected
                      ? Icon(Icons.check_rounded,
                          color: theme.colorScheme.primary)
                      : null,
                  onTap: () {
                    Navigator.pop(ctx);
                    ref
                        .read(localeProvider.notifier)
                        .setLocale(Locale(lang['code']!));
                  },
                );
              }),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAnimatedItem({required int index, required Widget child}) {
    final start = (index * 0.1).clamp(0.0, 1.0);
    final end = (0.6 + (index * 0.1)).clamp(0.0, 1.0);

    return SlideTransition(
      position: Tween<Offset>(begin: const Offset(0, 0.2), end: Offset.zero)
          .animate(CurvedAnimation(
              parent: _controller,
              curve: Interval(start, end, curve: Curves.easeOutCubic))),
      child: FadeTransition(
        opacity: Tween<double>(begin: 0.0, end: 1.0).animate(CurvedAnimation(
            parent: _controller,
            curve: Interval(start, end, curve: Curves.easeOut))),
        child: child,
      ),
    );
  }

  Widget _buildSectionGroup(ThemeData theme,
      {required String title, required List<_SettingsItem> items}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.only(left: 2.w, bottom: 1.h),
          child: Text(title,
              style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                  fontSize: 13.sp)),
        ),
        Container(
          decoration: BoxDecoration(
            color: theme.cardColor,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 4))
            ],
          ),
          child: Column(
            children: List.generate(items.length, (index) {
              final item = items[index];
              return Column(
                children: [
                  _buildListTile(context, theme, item),
                  if (index != items.length - 1)
                    Divider(
                        height: 1,
                        indent: 14.w,
                        color: theme.dividerColor.withValues(alpha: 0.5)),
                ],
              );
            }),
          ),
        ),
      ],
    );
  }

  Widget _buildListTile(
      BuildContext context, ThemeData theme, _SettingsItem item) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: item.onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.8.h),
          child: Row(
            children: [
              Container(
                padding: EdgeInsets.all(2.w),
                decoration: BoxDecoration(
                    color: theme.colorScheme.primary.withValues(alpha: 0.1),
                    shape: BoxShape.circle),
                child: CustomIconWidget(
                    iconName: item.icon,
                    color: theme.colorScheme.primary,
                    size: 22),
              ),
              SizedBox(width: 3.5.w),
              Expanded(
                  child: Text(item.title,
                      style: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w500,
                          color: theme.colorScheme.onSurface,
                          fontSize: 13.sp))),
              CustomIconWidget(
                  iconName: 'chevron_right',
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.4),
                  size: 18),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildReferralBanner(BuildContext context, ThemeData theme) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: const LinearGradient(
            colors: [Color(0xFF6A11CB), Color(0xFF2575FC)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight),
        boxShadow: [
          BoxShadow(
              color: const Color(0xFF2575FC).withValues(alpha: 0.3),
              blurRadius: 15,
              offset: const Offset(0, 8))
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => Navigator.pushNamed(context, AppRoutes.referralInvite),
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: EdgeInsets.all(4.w),
            child: Row(
              children: [
                Container(
                  padding: EdgeInsets.all(2.5.w),
                  decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      shape: BoxShape.circle),
                  child: const CustomIconWidget(
                      iconName: 'redeem', color: Colors.white, size: 26),
                ),
                SizedBox(width: 3.5.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                          AppLocalizations.of(context)?.referAndEarn ??
                              'Refer & Earn',
                          style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              fontSize: 15.sp)),
                      SizedBox(height: 0.3.h),
                      Text(
                          AppLocalizations.of(context)?.inviteFriendsRewards ??
                              'Invite friends and unlock premium rewards!',
                          style: theme.textTheme.bodySmall?.copyWith(
                              color: Colors.white.withValues(alpha: 0.9),
                              fontSize: 10.sp)),
                    ],
                  ),
                ),
                const Icon(Icons.arrow_forward_ios_rounded,
                    color: Colors.white, size: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMarriageRewardBanner(BuildContext context, ThemeData theme) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: const LinearGradient(
            colors: [Color(0xFFFF4081), Color(0xFFFF80AB)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight),
        boxShadow: [
          BoxShadow(
              color: const Color(0xFFFF4081).withValues(alpha: 0.3),
              blurRadius: 15,
              offset: const Offset(0, 8))
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => const MarriageRewardFormScreen())),
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: EdgeInsets.all(4.w),
            child: Row(
              children: [
                Container(
                  padding: EdgeInsets.all(2.5.w),
                  decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      shape: BoxShape.circle),
                  child:
                      const Icon(Icons.favorite, color: Colors.white, size: 26),
                ),
                SizedBox(width: 3.5.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Found your Partner?',
                          style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              fontSize: 15.sp)),
                      SizedBox(height: 0.3.h),
                      Text('Share marriage proof & get up to 35% Refund!',
                          style: theme.textTheme.bodySmall?.copyWith(
                              color: Colors.white.withValues(alpha: 0.9),
                              fontSize: 10.sp)),
                    ],
                  ),
                ),
                const Icon(Icons.arrow_forward_ios_rounded,
                    color: Colors.white, size: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLogoutButton(BuildContext context, ThemeData theme) {
    return Container(
      width: double.infinity,
      height: 6.0.h,
      decoration: BoxDecoration(
        color: theme.colorScheme.primary,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
              color: theme.colorScheme.primary.withValues(alpha: 0.3),
              blurRadius: 12,
              offset: const Offset(0, 4))
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _handleLogout(context),
          borderRadius: BorderRadius.circular(16),
          child: Center(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.logout, color: Colors.white, size: 22),
                SizedBox(width: 2.w),
                Text(
                  AppLocalizations.of(context)?.logout ?? 'Logout',
                  style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      fontSize: 14.sp),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _handleLogout(BuildContext context) async {
    final l10n = AppLocalizations.of(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n?.logout ?? 'Logout'),
        content: Text(l10n?.areYouSureLogout ?? 'Are you sure you want to logout?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: Text(l10n?.cancel ?? 'Cancel')),
          ElevatedButton(
              onPressed: () => Navigator.pop(context, true),
              child: Text(l10n?.logout ?? 'Logout')),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      final response = await _authRepository.signOut();
      await response.fold(
        onSuccess: (_) {
          if (context.mounted) {
            Navigator.of(context, rootNavigator: true)
                .pushReplacementNamed(AppRoutes.authentication);
          }
        },
        onFailure: (error) {
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                content: Text(l10n?.failedToLogout(error.toString()) ??
                    'Failed to logout: $error')));
          }
        },
      );
    }
  }
}

class _SettingsItem {
  final String icon;
  final String title;
  final VoidCallback onTap;
  _SettingsItem({required this.icon, required this.title, required this.onTap});
}
