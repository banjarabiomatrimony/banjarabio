import 'package:flutter/material.dart';
import 'package:banjarabio/l10n/app_localizations.dart';
import 'package:sizer/sizer.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:banjarabio/core/app_export.dart';
import 'package:banjarabio/widgets/custom_icon_widget.dart';

class ContactUsScreen extends StatelessWidget {
  const ContactUsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)?.contactUs ?? 'Contact Us'),
        leading: IconButton(
          icon: CustomIconWidget(
            iconName: 'arrow_back',
            color: theme.appBarTheme.foregroundColor ?? theme.colorScheme.onSurface,
          ),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(6.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: CustomIconWidget(
                iconName: 'contact_support',
                color: theme.colorScheme.primary,
                size: 64,
              ),
            ),
            SizedBox(height: 4.h),
            Text(AppLocalizations.of(context)?.getInTouchWithUs ?? 'Get in touch with us',
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 1.h),
            Text(AppLocalizations.of(context)?.haveQuestionsOrNeedAssistanceOurTeamIsHe ?? 'Have questions or need assistance? Our team is here to help you find your perfect match.',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            SizedBox(height: 4.h),
            _buildContactItem(
              theme,
              icon: 'email',
              title: AppLocalizations.of(context)?.emailSupport ?? 'Email Support',
              subtitle: AppLocalizations.of(context)?.supportBanjarabioApp ?? 'support@banjarabio.com',
              onTap: () => _launchEmail('support@banjarabio.com'),
            ),
            SizedBox(height: 2.h),
            _buildContactItem(
              theme,
              icon: 'call',
              title: AppLocalizations.of(context)?.phoneSupport ?? 'Phone Support',
              subtitle: AppLocalizations.of(context)?.num919876543210 ?? '+91 98765 43210',
              onTap: () => _launchPhone('+919876543210'),
            ),
            SizedBox(height: 2.h),
            _buildContactItem(
              theme,
              icon: 'chat',
              title: AppLocalizations.of(context)?.whatsappSupport ?? 'WhatsApp Support',
              subtitle: AppLocalizations.of(context)?.messageUsOnWhatsapp ?? 'Message us on WhatsApp',
              onTap: () => _launchWhatsApp('+919876543210'),
            ),
            SizedBox(height: 6.h),
            const Divider(),
            SizedBox(height: 4.h),
            Text(AppLocalizations.of(context)?.officeAddress ?? 'Office Address',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 1.h),
            Text(AppLocalizations.of(context)?.num123BanjaraTowersPrideSiliconValleynsh ?? '123, Banjara Towers, Pride Silicon Valley,\nShivaji Nagar, Pune, Maharashtra 411005',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContactItem(
    ThemeData theme, {
    required String icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: EdgeInsets.all(4.w),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: theme.colorScheme.outlineVariant),
        ),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(1.2.h),
              decoration: BoxDecoration(
                color: theme.colorScheme.primary.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: CustomIconWidget(
                iconName: icon,
                color: theme.colorScheme.primary,
              ),
            ),
            SizedBox(width: 4.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            CustomIconWidget(
              iconName: 'open_in_new',
              color: theme.colorScheme.primary.withValues(alpha: 0.5),
              size: 18,
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _launchEmail(String email) async {
    final Uri uri = Uri.parse('mailto:$email');
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
    final Uri uri = Uri.parse('https://wa.me/$phone');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }
}
