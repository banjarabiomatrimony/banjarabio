import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import 'package:banjarabio/l10n/app_localizations.dart';
import 'package:banjarabio/presentation/biodata_editor_screen/widgets/biodata_ui_helpers.dart';
import 'package:banjarabio/core/constants/app_typography.dart';

/// Loading and error state widgets for the Biodata Editor screen.
/// Extracted from BiodataEditorScreen._buildLoadingState and _buildErrorState.
class EditorLoadingStateWidget extends StatelessWidget {
  final String message;

  const EditorLoadingStateWidget({
    super.key,
    required this.message,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: 6.h,
          height: 6.h,
          child: const CircularProgressIndicator(
            color: BiodataTheme.royalGold,
            strokeWidth: 2.5,
          ),
        ),
        SizedBox(height: 2.h),
        Text(
          message,
          style: BiodataTheme.bodyStyle.copyWith(
            fontSize: AppTypography.bodyLarge,
            color: BiodataTheme.deepCharcoal.withValues(alpha: 0.8),
          ),
        ),
      ],
    );
  }
}

class EditorErrorStateWidget extends StatelessWidget {
  final String? errorMessage;
  final VoidCallback onRetry;

  const EditorErrorStateWidget({
    super.key,
    required this.errorMessage,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 5.h),
      decoration: BiodataTheme.sectionCardDecoration(),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.error_outline_rounded,
            color: Colors.red.shade400,
            size: 56.sp,
          ),
          SizedBox(height: 2.h),
          Text(
            AppLocalizations.of(context)?.somethingWentWrong ?? 'Something went wrong',
            style: BiodataTheme.subHeaderStyle.copyWith(
              fontSize: AppTypography.headingSmall,
              color: BiodataTheme.deepCharcoal,
            ),
          ),
          SizedBox(height: 0.8.h),
          Text(
            errorMessage ?? (AppLocalizations.of(context)?.couldNotLoadProfile ?? 'We couldn\'t load your profile. Please try again.'),
            style: BiodataTheme.bodyStyle.copyWith(
              fontSize: AppTypography.bodyLarge,
              color: BiodataTheme.deepCharcoal.withValues(alpha: 0.75),
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 2.5.h),
          SizedBox(
            height: 6.h,
            child: FilledButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh_rounded, size: 20),
              label: Text(AppLocalizations.of(context)?.tryAgain ?? 'Try again'),
              style: FilledButton.styleFrom(
                backgroundColor: BiodataTheme.royalGold,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(horizontal: 5.w),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
