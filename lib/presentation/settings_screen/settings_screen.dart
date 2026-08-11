import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sizer/sizer.dart';

import 'package:banjarabio/core/app_export.dart';
import 'package:banjarabio/core/providers/locale_provider.dart';
import 'package:banjarabio/core/providers/profile_providers.dart';
import 'package:banjarabio/core/repositories/auth_repository.dart';
import 'package:banjarabio/core/models/profile_model.dart';
import 'package:banjarabio/widgets/custom_app_bar.dart';
import 'package:banjarabio/widgets/app_logo_image.dart';
import 'package:banjarabio/l10n/app_localizations.dart';
import 'package:banjarabio/presentation/settings_screen/marriage_reward_form_screen.dart';
import 'package:banjarabio/presentation/settings_screen/email_preferences_screen.dart';
import 'package:banjarabio/core/constants/app_typography.dart';

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
    final ownProfileAsync = ref.watch(ownProfileProvider);

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
            // 1. Profile / Account Header
            _buildAnimatedItem(
              index: 0,
              child: ownProfileAsync.when(
                data: (profile) {
                  if (profile == null) {
                    return _buildGuestHeader(theme);
                  }
                  return _buildProfileHeader(context, theme, profile);
                },
                loading: () => _buildHeaderShimmer(theme),
                error: (err, stack) => _buildGuestHeader(theme),
              ),
            ),
            SizedBox(height: 2.5.h),

            // 2. Promotional Banners
            _buildAnimatedItem(
              index: 1,
              child: Column(
                children: [
                  _buildReferralBanner(context, theme),
                  SizedBox(height: 2.h),
                  _buildMarriageRewardBanner(context, theme),
                ],
              ),
            ),
            SizedBox(height: 3.h),

            // 3. Premium Hub & Activity
            _buildAnimatedItem(
              index: 2,
              child: _buildSectionGroup(
                theme,
                title: 'Premium Hub & Activity',
                items: [
                  _SettingsItem(
                    icon: 'bookmark',
                    title: 'Saved Profiles',
                    onTap: () => Navigator.pushNamed(context, AppRoutes.savedProfiles),
                  ),
                  _SettingsItem(
                    icon: 'star',
                    title: 'Premium Subscription',
                    onTap: () => Navigator.pushNamed(context, AppRoutes.subscription),
                  ),
                  _SettingsItem(
                    icon: 'visibility',
                    title: 'Who Viewed Me',
                    onTap: () => Navigator.pushNamed(context, AppRoutes.whoViewedMe),
                  ),
                  _SettingsItem(
                    icon: 'verified_user',
                    title: 'Trust Score',
                    onTap: () => Navigator.pushNamed(context, AppRoutes.trustScore),
                  ),
                ],
              ),
            ),
            SizedBox(height: 3.h),

            // 4. Support & Help
            _buildAnimatedItem(
              index: 3,
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

            // 5. Notifications Preferences
            _buildAnimatedItem(
              index: 4,
              child: _buildSectionGroup(
                theme,
                title: 'Preferences',
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
            _buildAnimatedItem(index: 5, child: _buildLanguageSection(theme)),
            SizedBox(height: 3.h),

            // 6. Legal & Information
            _buildAnimatedItem(
              index: 6,
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

            // 7. Account Safety
            _buildAnimatedItem(
              index: 7,
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
            SizedBox(height: 4.h),

            // 8. Logout Outlined Button
            _buildAnimatedItem(index: 8, child: _buildLogoutButton(context, theme)),
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
              fontSize: AppTypography.bodyLarge,
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
                  fontSize: AppTypography.bodyLarge)),
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
                          fontSize: AppTypography.bodyLarge))),
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
            colors: [Color(0xFF961B33), Color(0xFFC2185B)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight),
        boxShadow: [
          BoxShadow(
              color: const Color(0xFF961B33).withValues(alpha: 0.3),
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
                              fontSize: AppTypography.headingSmall)),
                      SizedBox(height: 0.3.h),
                      Text(
                          AppLocalizations.of(context)?.inviteFriendsRewards ??
                              'Invite friends and unlock premium rewards!',
                          style: theme.textTheme.bodySmall?.copyWith(
                              color: Colors.white.withValues(alpha: 0.9),
                              fontSize: AppTypography.bodySmall)),
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
            colors: [Color(0xFFD4AF37), Color(0xFFE5C158)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight),
        boxShadow: [
          BoxShadow(
              color: const Color(0xFFD4AF37).withValues(alpha: 0.3),
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
                      color: const Color(0xFF3E2D00).withValues(alpha: 0.1),
                      shape: BoxShape.circle),
                  child:
                      const Icon(Icons.favorite, color: Color(0xFF3E2D00), size: 26),
                ),
                SizedBox(width: 3.5.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Found your Partner?',
                          style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: const Color(0xFF3E2D00),
                              fontSize: AppTypography.headingSmall)),
                      SizedBox(height: 0.3.h),
                      Text('Share marriage proof & get up to 35% Refund!',
                          style: theme.textTheme.bodySmall?.copyWith(
                              color: const Color(0xFF3E2D00).withValues(alpha: 0.9),
                              fontSize: AppTypography.bodySmall)),
                    ],
                  ),
                ),
                const Icon(Icons.arrow_forward_ios_rounded,
                    color: Color(0xFF3E2D00), size: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLogoutButton(BuildContext context, ThemeData theme) {
    return OutlinedButton.icon(
      onPressed: () => _handleLogout(context),
      icon: Icon(Icons.logout_rounded, color: theme.colorScheme.primary, size: 20),
      label: Text(
        AppLocalizations.of(context)?.logout ?? 'Logout',
        style: TextStyle(
          color: theme.colorScheme.primary,
          fontWeight: FontWeight.bold,
          fontSize: AppTypography.bodyMedium,
        ),
      ),
      style: OutlinedButton.styleFrom(
        side: BorderSide(color: theme.colorScheme.primary.withValues(alpha: 0.4), width: 1.5),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        minimumSize: Size(double.infinity, 6.0.h),
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
                .pushNamedAndRemoveUntil(AppRoutes.userTypeSelection, (route) => false);
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

  Widget _buildProfileHeader(BuildContext context, ThemeData theme, ProfileModel profile) {
    final primaryPhoto = profile.photos.isNotEmpty ? profile.photos.first.publicUrl : null;

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: theme.colorScheme.primary.withValues(alpha: 0.08),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.primary.withValues(alpha: 0.04),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => Navigator.pushNamed(context, AppRoutes.myProfile),
          borderRadius: BorderRadius.circular(24),
          child: Padding(
            padding: EdgeInsets.all(4.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    // Avatar
                    Container(
                      width: 16.w,
                      height: 16.w,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: theme.colorScheme.primary.withValues(alpha: 0.2),
                          width: 2.5,
                        ),
                      ),
                      child: ClipOval(
                        child: CustomImageWidget(
                          imageUrl: primaryPhoto,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    SizedBox(width: 4.w),
                    // Name & Details
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  '${profile.fullName} ${profile.surname}',
                                  style: theme.textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    fontSize: AppTypography.bodyLarge,
                                    color: theme.colorScheme.onSurface,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              if (profile.isVerified) ...[
                                SizedBox(width: 1.5.w),
                                Container(
                                  padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 0.5.h),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFE8F5E9),
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(color: const Color(0xFF81C784), width: 0.5),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(Icons.verified_rounded, color: const Color(0xFF2E7D32), size: 12.sp),
                                    ],
                                  ),
                                ),
                              ],
                            ],
                          ),
                          SizedBox(height: 0.5.h),
                          Text(
                            profile.displayId,
                            style: theme.textTheme.bodySmall?.copyWith(
                              fontWeight: FontWeight.w600,
                              color: theme.colorScheme.primary,
                              fontSize: AppTypography.bodySmall,
                            ),
                          ),
                          SizedBox(height: 0.3.h),
                          Text(
                            '${profile.age} yrs • ${profile.locationExcludingVillage}',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                              fontSize: AppTypography.bodySmall,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    Icon(
                      Icons.chevron_right_rounded,
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.4),
                      size: 24,
                    ),
                  ],
                ),
                SizedBox(height: 2.h),
                // Progress Bar
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Profile Completed: ${profile.completionPercentage}%',
                          style: theme.textTheme.bodySmall?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: theme.colorScheme.onSurface.withValues(alpha: 0.8),
                            fontSize: AppTypography.bodySmall,
                          ),
                        ),
                        if (profile.completionPercentage < 100)
                          Text(
                            'Complete Bio',
                            style: theme.textTheme.bodySmall?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: theme.colorScheme.primary,
                              fontSize: AppTypography.labelMedium,
                            ),
                          ),
                      ],
                    ),
                    SizedBox(height: 1.h),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: LinearProgressIndicator(
                        value: profile.completionPercentage / 100.0,
                        minHeight: 8,
                        backgroundColor: theme.colorScheme.primary.withValues(alpha: 0.08),
                        valueColor: AlwaysStoppedAnimation<Color>(theme.colorScheme.primary),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildGuestHeader(ThemeData theme) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: theme.colorScheme.primary.withValues(alpha: 0.08),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.primary.withValues(alpha: 0.04),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.all(4.w),
        child: Column(
          children: [
            Container(
              padding: EdgeInsets.all(3.w),
              decoration: BoxDecoration(
                color: theme.colorScheme.primary.withValues(alpha: 0.08),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.person_outline_rounded,
                color: theme.colorScheme.primary,
                size: 28.sp,
              ),
            ),
            SizedBox(height: 1.5.h),
            Text(
              'Join BanjaraBio Matrimony',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                fontSize: AppTypography.bodyLarge,
                color: theme.colorScheme.onSurface,
              ),
            ),
            SizedBox(height: 0.5.h),
            Text(
              'Create your profile to find verified matches',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                fontSize: AppTypography.bodySmall,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 2.h),
            ElevatedButton(
              onPressed: () => Navigator.pushNamed(context, AppRoutes.authentication),
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 48),
                backgroundColor: theme.colorScheme.primary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: Text(
                'Login or Register',
                style: TextStyle(
                  fontSize: AppTypography.bodyMedium,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderShimmer(ThemeData theme) {
    return Container(
      width: double.infinity,
      height: 18.h,
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: theme.colorScheme.primary.withValues(alpha: 0.04),
          width: 1.5,
        ),
      ),
      child: Padding(
        padding: EdgeInsets.all(4.w),
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  width: 14.w,
                  height: 14.w,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.05),
                    shape: BoxShape.circle,
                  ),
                ),
                SizedBox(width: 4.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 40.w,
                        height: 2.h,
                        color: theme.colorScheme.onSurface.withValues(alpha: 0.05),
                      ),
                      SizedBox(height: 1.h),
                      Container(
                        width: 25.w,
                        height: 1.5.h,
                        color: theme.colorScheme.onSurface.withValues(alpha: 0.05),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const Spacer(),
            Container(
              width: double.infinity,
              height: 1.h,
              color: theme.colorScheme.onSurface.withValues(alpha: 0.05),
            ),
          ],
        ),
      ),
    );
  }
}

class _SettingsItem {
  final String icon;
  final String title;
  final VoidCallback onTap;
  _SettingsItem({required this.icon, required this.title, required this.onTap});
}
