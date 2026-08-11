import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import 'package:banjarabio/l10n/app_localizations.dart';
import 'package:banjarabio/core/models/profile_model.dart';
import 'package:banjarabio/presentation/biodata_creation_screen/models/creation_step_config.dart';

/// Progress indicator with step markers and profile strength badge.
/// Extracted from BiodataCreationScreen._buildProgressIndicator.
class CreationProgressIndicator extends StatelessWidget {
  final int currentStep;
  final List<CreationStep> activeSteps;
  final Map<String, dynamic> formData;
  final Map<String, bool> sectionValidation;
  final bool isLite;

  const CreationProgressIndicator({
    super.key,
    required this.currentStep,
    required this.activeSteps,
    required this.formData,
    required this.sectionValidation,
    this.isLite = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final percentage = ProfileModel.calculateScore(formData);
    final totalSteps = activeSteps.length;

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.5.h),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: theme.shadowColor.withValues(alpha: 0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                AppLocalizations.of(context)?.stepNOfTotal((currentStep + 1).toString(), totalSteps.toString()) ?? 'Step ${currentStep + 1} of $totalSteps',
                style: theme.textTheme.labelMedium?.copyWith(
                  color: theme.colorScheme.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
              // Hide completion % during lite signup — low scores feel punishing
              if (!isLite)
                Text(
                  AppLocalizations.of(context)?.percentComplete(percentage) ?? '$percentage% Complete',
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
            ],
          ),
          SizedBox(height: 1.h),
          Row(
            children: List.generate(totalSteps, (index) {
              final isCurrent = index == currentStep;
              final step = activeSteps[index];
              final isSectionValid = sectionValidation[step.validationKey] ?? false;

              return Expanded(
                child: Column(
                  children: [
                    Container(
                      height: 0.6.h,
                      margin: EdgeInsets.symmetric(horizontal: 0.5.w),
                      decoration: BoxDecoration(
                        color: isSectionValid || isCurrent
                            ? theme.colorScheme.primary
                            : theme.colorScheme.outline.withValues(alpha: 0.3),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    if (isSectionValid && !isCurrent)
                      Padding(
                        padding: const EdgeInsets.only(top: 2),
                        child: Icon(
                          Icons.check_circle,
                          size: 10,
                          color: theme.colorScheme.primary,
                        ),
                      ),
                  ],
                ),
              );
            }),
          ),
          SizedBox(height: 1.h),
          // Hide profile strength badge during lite signup
          if (!isLite)
            _buildProfileStrengthBadge(context, theme, percentage),
        ],
      ),
    );
  }

  Widget _buildProfileStrengthBadge(BuildContext context, ThemeData theme, int percentage) {
    String badgeText;
    Color badgeColor;
    IconData badgeIcon;

    if (percentage < 40) {
      badgeText = AppLocalizations.of(context)?.bronze ?? 'Bronze';
      badgeColor = Colors.brown;
      badgeIcon = Icons.stars_outlined;
    } else if (percentage < 80) {
      badgeText = AppLocalizations.of(context)?.silver ?? 'Silver';
      badgeColor = Colors.grey;
      badgeIcon = Icons.stars;
    } else {
      badgeText = AppLocalizations.of(context)?.gold ?? 'Gold';
      badgeColor = Colors.orange;
      badgeIcon = Icons.stars;
    }

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 0.5.h),
      decoration: BoxDecoration(
        color: badgeColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: badgeColor.withValues(alpha: 0.5)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(badgeIcon, size: 14, color: badgeColor),
          SizedBox(width: 1.5.w),
          Text(
            AppLocalizations.of(context)?.profileStrengthLabel(badgeText) ?? 'Profile Strength: $badgeText',
            style: theme.textTheme.labelSmall?.copyWith(
              color: badgeColor,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
