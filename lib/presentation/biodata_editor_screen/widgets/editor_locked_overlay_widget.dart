import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import 'package:banjarabio/l10n/app_localizations.dart';
import 'package:banjarabio/core/models/subscription_model.dart';
import 'package:banjarabio/presentation/biodata_editor_screen/widgets/biodata_ui_helpers.dart';
import 'package:banjarabio/core/constants/app_typography.dart';

/// Locked overlay shown when a premium template is not unlocked.
/// Extracted from BiodataEditorScreen._buildLockedOverlay.
class EditorLockedOverlayWidget extends StatelessWidget {
  final bool isProcessingPayment;
  final ValueChanged<PlanType> onUpgrade;

  const EditorLockedOverlayWidget({
    super.key,
    required this.isProcessingPayment,
    required this.onUpgrade,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: Container(
        decoration: BoxDecoration(
          color: BiodataTheme.deepCharcoal.withValues(alpha: 0.4),
        ),
        child: Center(
          child: Container(
            margin: EdgeInsets.symmetric(horizontal: 8.w),
            padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 4.h),
            decoration: BoxDecoration(
              color: BiodataTheme.surfaceWhite,
              borderRadius: BorderRadius.circular(BiodataTheme.radiusLg),
              boxShadow: const [
                BoxShadow(
                  color: Color.fromRGBO(0, 0, 0, 0.15),
                  blurRadius: 24,
                  offset: Offset(0, 8),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.lock_rounded,
                  color: BiodataTheme.royalGold,
                  size: 80,
                ),
                SizedBox(height: 1.5.h),
                Text(
                  AppLocalizations.of(context)?.premiumTemplate ?? 'Premium Template',
                  style: BiodataTheme.subHeaderStyle.copyWith(
                    fontSize: AppTypography.headingSmall,
                    color: BiodataTheme.deepCharcoal,
                  ),
                ),
                SizedBox(height: 0.6.h),
                Text(
                  AppLocalizations.of(context)?.unlockToDownload ?? 'Unlock to download and share this template in 5+ languages.',
                  textAlign: TextAlign.center,
                  style: BiodataTheme.bodyStyle.copyWith(
                    fontSize: AppTypography.bodyLarge,
                    color: BiodataTheme.deepCharcoal.withValues(alpha: 0.65),
                  ),
                ),
                SizedBox(height: 2.h),
                SizedBox(
                  height: 6.h,
                  child: FilledButton(
                    onPressed: isProcessingPayment
                        ? null
                        : () => onUpgrade(PlanType.biodata_unlock),
                    style: FilledButton.styleFrom(
                      backgroundColor: BiodataTheme.royalGold,
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(horizontal: 6.w),
                    ),
                    child: isProcessingPayment
                        ? SizedBox(
                            height: 2.5.h,
                            width: 2.5.h,
                            child: const CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : Text(AppLocalizations.of(context)?.unlockNow ?? 'Unlock now'),
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
