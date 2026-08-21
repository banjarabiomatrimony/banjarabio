import 'package:flutter/material.dart';
import 'package:banjarabio/l10n/app_localizations.dart';
import 'package:sizer/sizer.dart';

import 'package:banjarabio/routes/app_routes.dart';
import 'package:banjarabio/core/constants/app_typography.dart';
import 'package:banjarabio/theme/app_colors.dart';

// custom_error_widget.dart

class CustomErrorWidget extends StatelessWidget {
  final FlutterErrorDetails? errorDetails;
  final String? errorMessage;

  const CustomErrorWidget({super.key, this.errorDetails, this.errorMessage});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: AppColors.neutral50,
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.sentiment_dissatisfied_rounded,
                  size: 48,
                  color: theme.colorScheme.error.withValues(alpha: AppColors.opacity70),
                ),
                SizedBox(height: 1.h),
                Text(AppLocalizations.of(context)?.somethingWentWrong ?? 'Something went wrong',
                  style: TextStyle(
                    fontSize: AppTypography.headingMedium,
                    fontWeight: AppTypography.medium,
                    color: AppColors.surfaceDark,
                  ),
                ),
                SizedBox(height: 0.5.h),
                SizedBox(
                  child: Text(AppLocalizations.of(context)?.weEncounteredAnUnexpectedErrorWhileProce ?? 'We encountered an unexpected error while processing your request.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: AppTypography.bodyMedium,
                      color: AppColors.slate600, // neutral-600
                    ),
                  ),
                ),
                SizedBox(height: 3.h),
                ElevatedButton.icon(
                  onPressed: () {
                    final bool canBeBack = Navigator.canPop(context);
                    if (canBeBack) {
                      Navigator.of(context).pop();
                    } else {
                      Navigator.pushNamed(context, AppRoutes.initial);
                    }
                  },
                  icon: const Icon(
                    Icons.arrow_back,
                    size: 18,
                    color: Colors.white,
                  ),
                  label: Text(AppLocalizations.of(context)?.back ?? 'Back'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: theme.primaryColor,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 10,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
