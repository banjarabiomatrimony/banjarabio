import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:banjarabio/l10n/app_localizations.dart';
import 'package:banjarabio/core/constants/app_typography.dart';
import 'package:banjarabio/theme/app_colors.dart';
import 'package:banjarabio/widgets/custom_app_bar.dart';
import 'package:banjarabio/widgets/app_logo_image.dart';
import 'package:banjarabio/widgets/tactile/tactile_pressable.dart';

class ContactUsScreen extends StatefulWidget {
  const ContactUsScreen({super.key});

  @override
  State<ContactUsScreen> createState() => _ContactUsScreenState();
}

class _ContactUsScreenState extends State<ContactUsScreen>
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
          l10n?.contactUs ?? 'Contact Us',
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
            // 📞 Top Header Hero Card
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
                        Icons.headset_mic_rounded,
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
                            l10n?.getInTouchWithUs ?? 'Dedicated Matrimony Support',
                            style: TextStyle(
                              fontFamily: AppTypography.headingFontFamily,
                              fontWeight: AppTypography.bold,
                              fontSize: AppTypography.bodyLarge,
                              color: theme.colorScheme.onSurface,
                            ),
                          ),
                          SizedBox(height: 0.3.h),
                          Text(
                            'Our executive relationship managers are available Monday to Saturday, 9 AM – 7 PM IST.',
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

            // ⚡ Direct Contact Channels Section
            _buildAnimatedItem(
              index: 1,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: EdgeInsets.only(left: 1.w),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Direct Channels',
                          style: TextStyle(
                            fontFamily: AppTypography.headingFontFamily,
                            fontWeight: AppTypography.bold,
                            fontSize: AppTypography.bodyLarge,
                            color: theme.colorScheme.onSurface,
                          ),
                        ),
                        SizedBox(height: 0.2.h),
                        Text(
                          'Instant assistance over WhatsApp, phone call or official email',
                          style: TextStyle(
                            color: theme.colorScheme.onSurfaceVariant,
                            fontSize: AppTypography.labelSmall,
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 1.2.h),

                  // 🟢 WhatsApp Support Tile
                  _buildContactCard(
                    theme: theme,
                    isDark: isDark,
                    icon: Icons.chat_rounded,
                    iconColor: const Color(0xFF25D366),
                    tag: 'Recommended • Instant Reply',
                    tagColor: const Color(0xFF25D366),
                    title: l10n?.whatsappSupport ?? 'WhatsApp Executive Assistance',
                    subtitle: 'Chat directly with our support helpdesk on WhatsApp',
                    actionLabel: 'Chat on WhatsApp',
                    onTap: () {
                      HapticFeedback.mediumImpact();
                      _launchWhatsApp('+919876543210');
                    },
                  ),
                  SizedBox(height: 1.5.h),

                  // 📞 Phone Support Tile
                  _buildContactCard(
                    theme: theme,
                    isDark: isDark,
                    icon: Icons.phone_in_talk_rounded,
                    iconColor: const Color(0xFF1E88E5),
                    tag: 'Mon - Sat • 9 AM - 7 PM',
                    tagColor: const Color(0xFF1E88E5),
                    title: l10n?.phoneSupport ?? 'Toll-Free Phone Support',
                    subtitle: '+91 98765 43210 (Toll Free / Direct Line)',
                    actionLabel: 'Call Now',
                    onTap: () {
                      HapticFeedback.mediumImpact();
                      _launchPhone('+919876543210');
                    },
                  ),
                  SizedBox(height: 1.5.h),

                  // ✉️ Email Support Tile
                  _buildContactCard(
                    theme: theme,
                    isDark: isDark,
                    icon: Icons.email_rounded,
                    iconColor: const Color(0xFFE5A93C),
                    tag: 'Response within 4 hours',
                    tagColor: const Color(0xFFE5A93C),
                    title: l10n?.emailSupport ?? 'Official Email Helpdesk',
                    subtitle: 'support@banjarabio.com',
                    actionLabel: 'Send Email',
                    onTap: () {
                      HapticFeedback.mediumImpact();
                      _launchEmail('support@banjarabio.com');
                    },
                  ),
                ],
              ),
            ),
            SizedBox(height: 2.5.h),

            // 🏢 3. Office Headquarters Section
            _buildAnimatedItem(
              index: 2,
              child: Container(
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
                padding: EdgeInsets.all(4.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
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
                            Icons.business_rounded,
                            color: theme.colorScheme.primary,
                            size: 20,
                          ),
                        ),
                        SizedBox(width: 3.w),
                        Text(
                          l10n?.officeAddress ?? 'Registered Corporate Office',
                          style: TextStyle(
                            fontFamily: AppTypography.headingFontFamily,
                            fontWeight: AppTypography.bold,
                            fontSize: AppTypography.bodyLarge,
                            color: theme.colorScheme.onSurface,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 1.2.h),
                    Text(
                      'BanjaraBio Matrimony Headquarters\n123, Banjara Towers, Pride Silicon Valley,\nShivaji Nagar, Pune, Maharashtra 411005, India',
                      style: TextStyle(
                        color: theme.colorScheme.onSurfaceVariant,
                        fontSize: AppTypography.bodySmall,
                        height: 1.4,
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

  Widget _buildContactCard({
    required ThemeData theme,
    required bool isDark,
    required IconData icon,
    required Color iconColor,
    required String tag,
    required Color tagColor,
    required String title,
    required String subtitle,
    required String actionLabel,
    required VoidCallback onTap,
  }) {
    return TactilePressable(
      onTap: onTap,
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
              color: isDark
                  ? Colors.black.withValues(alpha: 0.25)
                  : theme.colorScheme.primary.withValues(alpha: 0.04),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                // 🎨 Colored Icon Badge
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: iconColor.withValues(
                      alpha: isDark ? AppColors.opacity20 : AppColors.opacity10,
                    ),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    icon,
                    color: iconColor,
                    size: 22,
                  ),
                ),
                SizedBox(width: 3.5.w),

                // 🏷️ Title and Subtitle
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Tag Badge
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 0.2.h),
                        decoration: BoxDecoration(
                          color: tagColor.withValues(
                            alpha: isDark ? AppColors.opacity15 : AppColors.opacity10,
                          ),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          tag,
                          style: TextStyle(
                            color: tagColor,
                            fontSize: AppTypography.labelSmall,
                            fontWeight: AppTypography.semiBold,
                          ),
                        ),
                      ),
                      SizedBox(height: 0.4.h),
                      Text(
                        title,
                        style: TextStyle(
                          fontFamily: AppTypography.headingFontFamily,
                          fontWeight: AppTypography.bold,
                          fontSize: AppTypography.bodyMedium,
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
                SizedBox(width: 2.w),

                // 🚀 Action Arrow Button
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary.withValues(
                      alpha: isDark ? AppColors.opacity15 : AppColors.opacity8,
                    ),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.arrow_forward_ios_rounded,
                    color: theme.colorScheme.primary,
                    size: 14,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _launchEmail(String email) async {
    final Uri uri = Uri.parse('mailto:$email?subject=BanjaraBio%20Support%20Enquiry');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  Future<void> _launchPhone(String phone) async {
    final Uri uri = Uri.parse('tel:$phone');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  Future<void> _launchWhatsApp(String phone) async {
    final Uri uri = Uri.parse(
      'https://wa.me/${phone.replaceAll('+', '').replaceAll(' ', '')}?text=Hello%20BanjaraBio%20Support,%20I%20need%20assistance%20with%20my%20account.',
    );
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }
}

