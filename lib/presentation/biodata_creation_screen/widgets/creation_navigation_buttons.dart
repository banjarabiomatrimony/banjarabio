import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import 'package:banjarabio/l10n/app_localizations.dart';

/// Bottom navigation buttons (Previous / Next / Save) for the creation flow.
/// Extracted from BiodataCreationScreen._buildNavigationButtons.
class CreationNavigationButtons extends StatelessWidget {
  final int currentStep;
  final int totalSteps;
  final bool isLoading;
  final bool isEditMode;
  final bool isLite;
  final VoidCallback onPrevious;
  final VoidCallback onNext;
  final VoidCallback onSave;

  const CreationNavigationButtons({
    super.key,
    required this.currentStep,
    required this.totalSteps,
    required this.isLoading,
    required this.isEditMode,
    this.isLite = false,
    required this.onPrevious,
    required this.onNext,
    required this.onSave,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: theme.shadowColor.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            if (currentStep > 0)
              Expanded(
                child: OutlinedButton(
                  onPressed: onPrevious,
                  child: Text(AppLocalizations.of(context)?.previous ?? 'Previous'),
                ),
              ),
            if (currentStep > 0) SizedBox(width: 3.w),
            Expanded(
              child: ElevatedButton(
                onPressed: isLoading
                    ? null
                    : (currentStep < totalSteps - 1 ? onNext : onSave),
                child: isLoading
                    ? SizedBox(
                        height: 2.5.h,
                        width: 2.5.h,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: theme.colorScheme.onPrimary,
                        ),
                      )
                    : Text(
                        currentStep < totalSteps - 1
                            ? (AppLocalizations.of(context)?.next ?? 'Next')
                            : isLite
                                ? 'Find Matches 💍'
                                : (isEditMode
                                    ? (AppLocalizations.of(context)?.updateProfile ?? 'Update Profile')
                                    : (AppLocalizations.of(context)?.saveBiodata ?? 'Save Biodata')),
                        style: TextStyle(
                          color: theme.colorScheme.onPrimary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
