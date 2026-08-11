import 'package:flutter/material.dart';
import 'package:banjarabio/l10n/app_localizations.dart';
import 'package:sizer/sizer.dart';

import 'package:banjarabio/core/app_export.dart';
import 'package:banjarabio/widgets/custom_icon_widget.dart';

class TermsConditionsScreen extends StatelessWidget {
  const TermsConditionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)?.termsConditions ?? 'Terms & Conditions'),
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
            Text(AppLocalizations.of(context)?.termsOfService ?? 'Terms of Service',
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
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
              AppLocalizations.of(context)?.termsS1Title ?? '1. Acceptance of Terms',
              AppLocalizations.of(context)?.termsS1Content ?? 'By accessing or using the BanjaraBio application, you agree to be bound by these Terms and Conditions. If you do not agree, please do not use the service.',
            ),
            _buildSection(
              theme,
              AppLocalizations.of(context)?.termsS2Title ?? '2. Eligibility',
              AppLocalizations.of(context)?.termsS2Content ?? 'You must be at least 18 years old (for females) or 21 years old (for males) to register on this platform. The platform is strictly for matrimonial purposes.',
            ),
            _buildSection(
              theme,
              AppLocalizations.of(context)?.termsS3Title ?? '3. User Account',
              AppLocalizations.of(context)?.termsS3Content ?? 'You are responsible for maintaining the confidentiality of your account credentials. All information provided during registration must be accurate and truthful.',
            ),
            _buildSection(
              theme,
              AppLocalizations.of(context)?.termsS4Title ?? '4. Prohibited Activities',
              AppLocalizations.of(context)?.termsS4Content ?? 'Users are prohibited from using the platform for commercial purposes, harassment, spreading hate speech, or sharing fraudulent information.',
            ),
            _buildSection(
              theme,
              AppLocalizations.of(context)?.termsS5Title ?? '5. Account Deletion',
              AppLocalizations.of(context)?.termsS5Content ?? 'You may request account deletion at any time through the "Delete Account" section in your profile settings.',
            ),
            _buildSection(
              theme,
              AppLocalizations.of(context)?.termsS6Title ?? '6. Limitation of Liability',
              AppLocalizations.of(context)?.termsS6Content ?? 'BanjaraBio is a platform for finding matches. We do not guarantee successful matches or verify the character of users beyond basic checks. Users are encouraged to perform their own due diligence.',
            ),
            _buildSection(
              theme,
              AppLocalizations.of(context)?.termsS7Title ?? '7. Governing Law',
              AppLocalizations.of(context)?.termsS7Content ?? 'These terms shall be governed by and construed in accordance with the laws of India. Any disputes shall be subject to the exclusive jurisdiction of the courts in Maharashtra.',
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
              fontWeight: FontWeight.bold,
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
