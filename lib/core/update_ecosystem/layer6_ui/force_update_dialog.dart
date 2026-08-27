import 'package:flutter/material.dart';
import 'package:banjarabio/core/update_ecosystem/layer1_models/update_info.dart';
import 'package:banjarabio/core/update_ecosystem/layer6_ui/update_modal_theme.dart';

/// 🚨 [ForceUpdateDialog]
///
/// Un-dismissible full-screen modal enforcing mandatory application updates.
class ForceUpdateDialog extends StatelessWidget {
  final UpdateInfo info;
  final UpdateModalTheme theme;
  final VoidCallback onUpdate;

  const ForceUpdateDialog({
    super.key,
    required this.info,
    required this.theme,
    required this.onUpdate,
  });

  @override
  Widget build(BuildContext context) {
    final primary = theme.getResolvedPrimary(context);
    final cardBg = theme.getResolvedCard(context);
    final titleColor = theme.getResolvedTitle(context);
    final bodyColor = theme.getResolvedBody(context);

    return PopScope(
      canPop: false, // Prevent hardware back button dismissal
      child: Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(theme.borderRadius),
        ),
        backgroundColor: cardBg,
        elevation: 16,
        insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // 1. Logo / Header Badge
              Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: primary.withValues(alpha: 0.12),
                  border: Border.all(
                    color: primary.withValues(alpha: 0.25),
                    width: 2,
                  ),
                ),
                child: Center(
                  child: theme.customLogo ??
                      Icon(
                        Icons.system_update_rounded,
                        size: 36,
                        color: primary,
                      ),
                ),
              ),
              const SizedBox(height: 16),

              // 2. Critical Badge
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.red.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text(
                  'CRITICAL UPDATE',
                  style: TextStyle(
                    color: Colors.red,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.8,
                  ),
                ),
              ),
              const SizedBox(height: 12),

              // 3. Title
              Text(
                info.title,
                textAlign: TextAlign.center,
                style: theme.titleStyle ??
                    TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: titleColor,
                    ),
              ),
              const SizedBox(height: 8),

              // 4. Version comparison subtitle
              Text(
                'Current: v${info.currentVersion}  •  Required: v${info.minRequiredVersion}',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: bodyColor.withValues(alpha: 0.7),
                ),
              ),
              const SizedBox(height: 14),

              // 5. Message
              Text(
                info.message,
                textAlign: TextAlign.center,
                style: theme.bodyStyle ??
                    TextStyle(
                      fontSize: 14,
                      color: bodyColor,
                      height: 1.4,
                    ),
              ),

              // 6. Release Notes (if present)
              if (info.releaseNotes.isNotEmpty) ...[
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: primary.withValues(alpha: 0.04),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: primary.withValues(alpha: 0.08),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'What\'s in this update:',
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
                                '• ',
                                style: TextStyle(
                                  color: primary,
                                  fontWeight: FontWeight.bold,
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

              // 7. Update CTA Button
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: onUpdate,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    elevation: 2,
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.download_rounded, size: 20),
                      SizedBox(width: 8),
                      Text(
                        'Update Now',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
