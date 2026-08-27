import 'package:flutter/material.dart';
import 'package:banjarabio/core/update_ecosystem/layer1_models/update_info.dart';
import 'package:banjarabio/core/update_ecosystem/layer6_ui/update_modal_theme.dart';

/// 🌤️ [SoftUpdateSheet]
///
/// Elegant, theme-adaptive bottom sheet prompting the user with an optional update.
class SoftUpdateSheet extends StatelessWidget {
  final UpdateInfo info;
  final UpdateModalTheme theme;
  final VoidCallback onUpdate;
  final VoidCallback onDismiss;

  const SoftUpdateSheet({
    super.key,
    required this.info,
    required this.theme,
    required this.onUpdate,
    required this.onDismiss,
  });

  @override
  Widget build(BuildContext context) {
    final primary = theme.getResolvedPrimary(context);
    final cardBg = theme.getResolvedCard(context);
    final titleColor = theme.getResolvedTitle(context);
    final bodyColor = theme.getResolvedBody(context);

    return Container(
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(theme.borderRadius),
        ),
      ),
      padding: EdgeInsets.only(
        left: 24,
        right: 24,
        top: 12,
        bottom: MediaQuery.of(context).padding.bottom + 20,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 1. Drag Handle
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 20),

            // 2. Icon / Logo
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: primary.withValues(alpha: 0.1),
                border: Border.all(
                  color: primary.withValues(alpha: 0.2),
                  width: 1.5,
                ),
              ),
              child: Center(
                child: theme.customLogo ??
                    Icon(
                      Icons.auto_awesome_rounded,
                      size: 32,
                      color: primary,
                    ),
              ),
            ),
            const SizedBox(height: 14),

            // 3. New Version Badge
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
              decoration: BoxDecoration(
                color: primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                'v${info.latestVersion}',
                style: TextStyle(
                  color: primary,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 10),

            // 4. Title
            Text(
              info.title,
              textAlign: TextAlign.center,
              style: theme.titleStyle ??
                  TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: titleColor,
                  ),
            ),
            const SizedBox(height: 8),

            // 5. Message
            Text(
              info.message,
              textAlign: TextAlign.center,
              style: theme.bodyStyle ??
                  TextStyle(
                    fontSize: 13,
                    color: bodyColor,
                    height: 1.4,
                  ),
            ),

            // 6. Release Notes (if present)
            if (info.releaseNotes.isNotEmpty) ...[
              const SizedBox(height: 16),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: primary.withValues(alpha: 0.04),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: primary.withValues(alpha: 0.08),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Highlights in this release:',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: titleColor,
                      ),
                    ),
                    const SizedBox(height: 6),
                    ...info.releaseNotes.map(
                      (note) => Padding(
                        padding: const EdgeInsets.only(bottom: 4),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '✨ ',
                              style: TextStyle(
                                fontSize: 11,
                                color: primary,
                              ),
                            ),
                            Expanded(
                              child: Text(
                                note,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: bodyColor,
                                  height: 1.3,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],

            const SizedBox(height: 24),

            // 7. Actions: Update Button & Maybe Later
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: onDismiss,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: bodyColor,
                      side: BorderSide(color: Colors.grey.withValues(alpha: 0.3)),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 13),
                    ),
                    child: const Text('Later'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  flex: 2,
                  child: ElevatedButton(
                    onPressed: onUpdate,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primary,
                      foregroundColor: Colors.white,
                      elevation: 1,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 13),
                    ),
                    child: const Text(
                      'Update Now',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
