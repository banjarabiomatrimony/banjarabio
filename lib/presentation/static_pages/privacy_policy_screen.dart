import 'package:flutter/material.dart';
import 'package:banjarabio/l10n/app_localizations.dart';
import 'package:sizer/sizer.dart';

import 'package:banjarabio/core/app_export.dart';
import 'package:banjarabio/widgets/custom_icon_widget.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)?.privacyPolicy ?? 'Privacy Policy'),
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
            Text(AppLocalizations.of(context)?.privacyPolicy ?? 'Privacy Policy',
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: AppTypography.bold,
              ),
            ),
            SizedBox(height: 1.h),
            Text(AppLocalizations.of(context)?.lastUpdatedJanuary2026 ?? 'Last updated: January 2026',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            SizedBox(height: 3.h),
            _buildSection(
              theme,
              AppLocalizations.of(context)?.privacyS1Title ?? '1. Information We Collect',
              AppLocalizations.of(context)?.privacyS1Content ?? '• Personal Data: Name, age, gender, caste, education, profession, family details.\n• Contact Data: Phone number, email address.\n• Media: Photos uploaded to your profile.\n• Device Data: Device ID, IP address (for security & analytics).\n• Location Data: Approximate location (City/District) to suggest nearby matches.',
            ),
            _buildSection(
              theme,
              AppLocalizations.of(context)?.privacyS2Title ?? '2. Purpose of Collection (Data Safety)',
              AppLocalizations.of(context)?.privacyS2Content ?? '• App Functionality: To create your profile and match-making.\n• Account Management: Identity verification and fraud prevention.\n• Analytics: To improve app performance (using Firebase).\n• Location: To show "Near Me" matches (Optional).',
            ),
            _buildSection(
              theme,
              AppLocalizations.of(context)?.privacyS3Title ?? '3. Device Permissions',
              AppLocalizations.of(context)?.privacyS3Content ?? '• Camera & Gallery: For profile photos.\n• Location: To auto-fill city/district.\n• Notifications: For match alerts.',
            ),
            _buildSection(
              theme,
              AppLocalizations.of(context)?.privacyS4Title ?? '4. Disclosure & Third Parties',
              AppLocalizations.of(context)?.privacyS4Content ?? '• Other Users: Registered members can see your profile details (excluding contact info unless shared).\n• Service Providers: We use Supabase (Database) and Firebase (Analytics/Notifications) to run the app. They process data under strict security standards.',
            ),
            _buildSection(
              theme,
              AppLocalizations.of(context)?.privacyS5Title ?? '5. Data Security & Deletion',
              AppLocalizations.of(context)?.privacyS5Content ?? 'We use encryption to protect your data. You can delete your account and all associated data at any time via Settings > Delete Account.',
            ),
            _buildSection(
              theme,
              AppLocalizations.of(context)?.privacyS6Title ?? '6. Governing Law',
              AppLocalizations.of(context)?.privacyS6Content ?? 'This policy is governed by the laws of India. Any disputes are subject to the jurisdiction of the courts in Maharashtra.',
            ),
            SizedBox(height: 4.h),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(ThemeData theme, String title, String content) {
    return Padding(
      padding: EdgeInsets.only(bottom: 3.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: AppTypography.bold,
              color: theme.colorScheme.primary,
            ),
          ),
          SizedBox(height: 1.h),
          Text(
            content,
            style: theme.textTheme.bodyMedium?.copyWith(height: 1.5),
          ),
        ],
      ),
    );
  }
}
