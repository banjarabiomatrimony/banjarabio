import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import 'package:banjarabio/l10n/app_localizations.dart';
import 'package:banjarabio/core/constants/app_typography.dart';
import 'package:banjarabio/theme/app_colors.dart';


/// Bottom action bar with Print, Download, Share buttons.
/// Extracted from BiodataEditorScreen._buildBottomActionBar.
class EditorBottomActionBar extends StatelessWidget {
  final bool canAct;
  final VoidCallback? onPrint;
  final VoidCallback? onDownload;
  final VoidCallback? onShare;

  const EditorBottomActionBar({
    super.key,
    required this.canAct,
    this.onPrint,
    this.onDownload,
    this.onShare,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.2.h),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: AppColors.opacity8),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _EditorActionButton(
              icon: Icons.print_rounded,
              label: AppLocalizations.of(context)?.printBtn ?? 'Print',
              onTap: canAct ? onPrint : null,
            ),
            _EditorActionButton(
              icon: Icons.download_rounded,
              label: AppLocalizations.of(context)?.downloadBtn ?? 'Download',
              onTap: canAct ? onDownload : null,
            ),
            _EditorActionButton(
              icon: Icons.share_rounded,
              label: AppLocalizations.of(context)?.shareBtn ?? 'Share',
              onTap: canAct ? onShare : null,
            ),
          ],
        ),
      ),
    );
  }
}

class _EditorActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback? onTap;

  const _EditorActionButton({
    required this.icon,
    required this.label,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final disabled = onTap == null;

    return Semantics(
      button: true,
      enabled: !disabled,
      label: label,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  icon,
                  color: disabled
                      ? theme.colorScheme.onSurface.withValues(alpha: AppColors.opacity40)
                      : theme.colorScheme.primary,
                  size: 24,
                ),
                SizedBox(height: 0.4.h),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: AppTypography.bodySmall,
                    fontWeight: AppTypography.semiBold,
                    color: disabled
                        ? theme.colorScheme.onSurface.withValues(alpha: AppColors.opacity40)
                        : theme.colorScheme.onSurface,
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
