import 'package:banjarabio/core/constants/app_typography.dart';
import 'package:flutter/material.dart';
import 'package:banjarabio/l10n/app_localizations.dart';
import 'package:sizer/sizer.dart';
import 'package:banjarabio/widgets/custom_icon_widget.dart';

/// FAQ Screen displaying frequently asked questions
class FAQScreen extends StatelessWidget {
  const FAQScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final faqs = [
      {
        'question': AppLocalizations.of(context)?.faqQ1 ?? 'How do I create a biodata?',
        'answer': AppLocalizations.of(context)?.faqA1 ?? 'Go to the Profile tab and click on "Create Biodata" or edit your existing profile. Follow the multi-step form to fill in your personal, family, and professional details.',
      },
      {
        'question': AppLocalizations.of(context)?.faqQ2 ?? 'Is my data secure?',
        'answer': AppLocalizations.of(context)?.faqA2 ?? 'Yes, we take privacy seriously. Your contact details are only shown to verified users and respect our community safety guidelines.',
      },
      {
        'question': AppLocalizations.of(context)?.faqQ3 ?? 'How can I filter profiles?',
        'answer': AppLocalizations.of(context)?.faqA3 ?? 'On the home screen, use the "Filters" button to narrow down profiles by age, location, education, and profession.',
      },
      {
        'question': AppLocalizations.of(context)?.faqQ4 ?? 'What are the benefits of Premium?',
        'answer': AppLocalizations.of(context)?.faqA4 ?? 'Premium users get unlimited profile views, early access to new biodatas, and enhanced visibility in search results.',
      },
      {
        'question': AppLocalizations.of(context)?.faqQ5 ?? 'How do I delete my account?',
        'answer': AppLocalizations.of(context)?.faqA5 ?? 'Go to My Profile > Legal & Information > Account Deletion to permanently remove your profile and data from our system.',
      },
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)?.faqs ?? 'FAQs'),
        leading: IconButton(
          icon: const CustomIconWidget(iconName: 'arrow_back'),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: ListView.separated(
        padding: EdgeInsets.all(4.w),
        itemCount: faqs.length,
        separatorBuilder: (context, index) => SizedBox(height: 2.h),
        itemBuilder: (context, index) {
          return Container(
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: theme.dividerColor),
            ),
            child: ExpansionTile(
              title: Text(
                faqs[index]['question']!,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: AppTypography.bold,
                  color: theme.colorScheme.primary,
                ),
              ),
              children: [
                Padding(
                  padding: EdgeInsets.fromLTRB(4.w, 0, 4.w, 4.w),
                  child: Text(
                    faqs[index]['answer']!,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurface,
                      height: 1.5,
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
