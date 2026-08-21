import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';

import 'package:banjarabio/widgets/custom_app_bar.dart';
import 'package:banjarabio/widgets/app_logo_image.dart';
import 'package:banjarabio/widgets/tactile/tactile_pressable.dart';
import 'package:banjarabio/core/repositories/email_repository.dart';
import 'package:banjarabio/core/constants/app_typography.dart';
import 'package:banjarabio/theme/app_colors.dart';

class EmailAlertsScreen extends StatefulWidget {
  const EmailAlertsScreen({super.key});

  @override
  State<EmailAlertsScreen> createState() => _EmailAlertsScreenState();
}

class _EmailAlertsScreenState extends State<EmailAlertsScreen>
    with SingleTickerProviderStateMixin {
  final EmailRepository _repository = EmailRepository();
  AnimationController? _controller;

  AnimationController get _animController {
    _controller ??= AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 650),
    )..forward();
    return _controller!;
  }

  Map<String, dynamic> _prefs = {
    'daily_recommendations': true,
    'weekly_digest': true,
    'monthly_digest': true,
    'match_alerts': true,
    'interest_alerts': true,
    'local_profiles': true,
    'offers': true,
  };
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 650),
    );
    _loadPreferences();
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  Future<void> _loadPreferences() async {
    final prefs = await _repository.getPreferences();
    if (mounted) {
      setState(() {
        if (prefs.isNotEmpty) {
          _prefs = prefs;
        }
        _isLoading = false;
      });
      _controller?.forward();
    }
  }

  Future<void> _togglePreference(String column, bool value) async {
    HapticFeedback.lightImpact();
    setState(() {
      _prefs[column] = value;
    });
    await _repository.updatePreference(column, value);
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
          'Email Alerts',
          style: (theme.appBarTheme.titleTextStyle ?? theme.textTheme.titleMedium)?.copyWith(
            fontSize: AppTypography.headingMedium,
            fontWeight: AppTypography.semiBold,
            color: theme.appBarTheme.foregroundColor ?? Colors.white,
            letterSpacing: 0.2,
          ),
        ),
      ),
      body: _isLoading
          ? Center(
              child: CircularProgressIndicator(
                color: theme.colorScheme.primary,
              ),
            )
          : SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 💌 Top Header Hero Card
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
                              Icons.mark_email_read_rounded,
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
                                  'Smart Inbox Dispatch',
                                  style: TextStyle(
                                    fontFamily: AppTypography.headingFontFamily,
                                    fontWeight: AppTypography.bold,
                                    fontSize: AppTypography.bodyLarge,
                                    color: theme.colorScheme.onSurface,
                                  ),
                                ),
                                SizedBox(height: 0.3.h),
                                Text(
                                  'Choose exactly which matchmaking events send instant alerts to your email address.',
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
                  SizedBox(height: 2.5.h),

                  // 💍 1. Engagement & Matches Group
                  _buildAnimatedItem(
                    index: 1,
                    child: _buildGroupContainer(
                      theme: theme,
                      isDark: isDark,
                      title: 'Matchmaking & Activity',
                      subtitle: 'Direct member connections, daily recommendations & alerts',
                      items: const [
                        _ToggleData(
                          key: 'daily_recommendations',
                          title: 'Daily Match Picks',
                          subtitle: 'Handpicked verified biodata matches tailored for you every morning.',
                          icon: Icons.auto_awesome_rounded,
                          iconColor: Color(0xFFE5A93C),
                        ),
                        _ToggleData(
                          key: 'match_alerts',
                          title: 'Mutual Match Alerts',
                          subtitle: 'Instant alert when a profile accepts or mutually connects with you.',
                          icon: Icons.favorite_rounded,
                          iconColor: Color(0xFFE53935),
                        ),
                        _ToggleData(
                          key: 'interest_alerts',
                          title: 'Bookmark & Interest Notifications',
                          subtitle: 'Emails when a verified family saves or expresses interest in your biodata.',
                          icon: Icons.bookmark_added_rounded,
                          iconColor: Color(0xFF8E24AA),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 2.5.h),

                  // 🌐 2. Community & Reports Group
                  _buildAnimatedItem(
                    index: 2,
                    child: _buildGroupContainer(
                      theme: theme,
                      isDark: isDark,
                      title: 'Community & Regional Insights',
                      subtitle: 'District updates, weekly wraps & exclusive opportunities',
                      items: const [
                        _ToggleData(
                          key: 'local_profiles',
                          title: 'New District & Regional Members',
                          subtitle: 'Get notified when new profiles from your native district join BanjaraBio.',
                          icon: Icons.location_on_rounded,
                          iconColor: Color(0xFF43A047),
                        ),
                        _ToggleData(
                          key: 'weekly_digest',
                          title: 'Weekly Community Digest',
                          subtitle: 'A clean Saturday summary of community activity, matches and new melavas.',
                          icon: Icons.newspaper_rounded,
                          iconColor: Color(0xFF1E88E5),
                        ),
                        _ToggleData(
                          key: 'monthly_digest',
                          title: 'Monthly Matrimony Report',
                          subtitle: 'Your 30-day overview with profile view stats and match compatibility trends.',
                          icon: Icons.calendar_month_rounded,
                          iconColor: Color(0xFF00ACC1),
                        ),
                        _ToggleData(
                          key: 'offers',
                          title: 'Special Membership Offers',
                          subtitle: 'Exclusive discounts on Premium and assisted matchmaking plans.',
                          icon: Icons.card_giftcard_rounded,
                          iconColor: Color(0xFFFB8C00),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 3.h),

                  // 🛡️ Privacy Guarantee Footer
                  _buildAnimatedItem(
                    index: 3,
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
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                          SizedBox(width: 3.w),
                          Expanded(
                            child: Text(
                              'Zero Spam Policy: We only send relevant alerts. You can adjust your preferences at any time.',
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

  Widget _buildGroupContainer({
    required ThemeData theme,
    required bool isDark,
    required String title,
    required String subtitle,
    required List<_ToggleData> items,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.only(left: 1.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontFamily: AppTypography.headingFontFamily,
                  fontWeight: AppTypography.bold,
                  fontSize: AppTypography.bodyLarge,
                  color: theme.colorScheme.onSurface,
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
        ),
        SizedBox(height: 1.2.h),
        Container(
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
              final isEnabled = _prefs[item.key] ?? true;

              return Column(
                children: [
                  Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: 4.w,
                      vertical: 1.4.h,
                    ),
                    child: Row(
                      children: [
                        // 🎨 Category Colored Icon Badge
                        Container(
                          padding: const EdgeInsets.all(9),
                          decoration: BoxDecoration(
                            color: item.iconColor.withValues(
                              alpha: isDark ? AppColors.opacity20 : AppColors.opacity10,
                            ),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            item.icon,
                            color: item.iconColor,
                            size: 20,
                          ),
                        ),
                        SizedBox(width: 3.5.w),

                        // 🏷️ Title & Subtitle
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                item.title,
                                style: TextStyle(
                                  fontFamily: AppTypography.headingFontFamily,
                                  fontWeight: AppTypography.semiBold,
                                  fontSize: AppTypography.bodyMedium,
                                  color: theme.colorScheme.onSurface,
                                ),
                              ),
                              SizedBox(height: 0.2.h),
                              Text(
                                item.subtitle,
                                style: TextStyle(
                                  color: theme.colorScheme.onSurfaceVariant,
                                  fontSize: AppTypography.labelSmall,
                                  height: 1.25,
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(width: 2.w),

                        // ⚡ Animated Switch
                        Switch.adaptive(
                          value: isEnabled,
                          activeThumbColor: theme.colorScheme.primary,
                          activeTrackColor: theme.colorScheme.primary.withValues(
                            alpha: isDark ? AppColors.opacity40 : AppColors.opacity30,
                          ),
                          onChanged: (val) => _togglePreference(item.key, val),
                        ),
                      ],
                    ),
                  ),
                  if (index != items.length - 1)
                    Divider(
                      height: 1,
                      indent: 15.w,
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

class _ToggleData {
  final String key;
  final String title;
  final String subtitle;
  final IconData icon;
  final Color iconColor;

  const _ToggleData({
    required this.key,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.iconColor,
  });
}
