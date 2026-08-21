import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';

import 'package:banjarabio/l10n/app_localizations.dart';
import 'package:banjarabio/core/constants/app_typography.dart';
import 'package:banjarabio/theme/app_colors.dart';

/// Bottom navigation buttons (Previous / Next / Save / Quick Update) with animations and haptic feedback.
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
    final isLastStep = currentStep >= totalSteps - 1;

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.2.h),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        border: Border(
          top: BorderSide(
            color: theme.colorScheme.outline.withValues(alpha: AppColors.opacity8),
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, -3),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            // Previous Step Button
            if (currentStep > 0) ...[
              Expanded(
                child: OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    padding: EdgeInsets.symmetric(vertical: 1.4.h),
                    side: BorderSide(
                      color: theme.colorScheme.outline.withValues(alpha: AppColors.opacity25),
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  icon: const Icon(Icons.arrow_back_rounded, size: 18),
                  label: Text(
                    AppLocalizations.of(context)?.previous ?? 'Back',
                    style: TextStyle(
                      fontSize: AppTypography.bodyMedium,
                      fontWeight: AppTypography.bold,
                    ),
                  ),
                  onPressed: () {
                    HapticFeedback.lightImpact();
                    onPrevious();
                  },
                ),
              ),
              SizedBox(width: 3.w),
            ],

            // In Edit Mode (if not on last step), allow direct Quick Update
            if (isEditMode && !isLastStep) ...[
              Expanded(
                child: OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.categoryLocation,
                    side: const BorderSide(
                      color: AppColors.categoryLocation,
                      width: 1.2,
                    ),
                    padding: EdgeInsets.symmetric(vertical: 1.4.h),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  icon: const Icon(Icons.save_rounded, size: 18),
                  label: Text(
                    'Save All',
                    style: TextStyle(
                      fontSize: AppTypography.bodyMedium,
                      fontWeight: AppTypography.bold,
                    ),
                  ),
                  onPressed: isLoading
                      ? null
                      : () {
                          HapticFeedback.mediumImpact();
                          onSave();
                        },
                ),
              ),
              SizedBox(width: 3.w),
            ],

            // Primary Next / Save Button
            Expanded(
              flex: 2,
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: theme.colorScheme.primary.withValues(alpha: AppColors.opacity30),
                      blurRadius: 10,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: theme.colorScheme.primary,
                    foregroundColor: theme.colorScheme.onPrimary,
                    padding: EdgeInsets.symmetric(vertical: 1.4.h),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 0,
                  ),
                  onPressed: isLoading
                      ? null
                      : () {
                          HapticFeedback.lightImpact();
                          if (isLastStep) {
                            onSave();
                          } else {
                            onNext();
                          }
                        },
                  child: isLoading
                      ? SizedBox(
                          height: 2.4.h,
                          width: 2.4.h,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.2,
                            color: theme.colorScheme.onPrimary,
                          ),
                        )
                      : Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              isLastStep
                                  ? (isLite
                                      ? 'Find Matches 💍'
                                      : (isEditMode
                                          ? (AppLocalizations.of(context)?.updateProfile ?? 'Update Profile')
                                          : (AppLocalizations.of(context)?.saveBiodata ?? 'Save Biodata')))
                                  : (AppLocalizations.of(context)?.next ?? 'Next Section'),
                              style: TextStyle(
                                color: theme.colorScheme.onPrimary,
                                fontWeight: AppTypography.extraBold,
                                fontSize: AppTypography.bodyMedium,
                              ),
                            ),
                            SizedBox(width: 1.5.w),
                            Icon(
                              isLastStep
                                  ? Icons.check_circle_rounded
                                  : Icons.arrow_forward_rounded,
                              size: 18,
                              color: theme.colorScheme.onPrimary,
                            ),
                          ],
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
