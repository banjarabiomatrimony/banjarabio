import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:sizer/sizer.dart';

import 'package:banjarabio/l10n/app_localizations.dart';
import 'package:banjarabio/core/app_export.dart';
import 'package:banjarabio/core/models/profile_model.dart';
import 'package:banjarabio/core/repositories/share_repository.dart';
import 'package:banjarabio/core/repositories/usage_repository.dart';
import 'package:banjarabio/core/services/share_service.dart';
import 'package:banjarabio/core/services/local_cache_service.dart';
import 'package:banjarabio/widgets/upgrade_dialog.dart';
import 'package:banjarabio/presentation/home_screen/widgets/guest_restricted_dialog.dart';
import 'package:banjarabio/core/services/app_logger.dart';

/// Shows the profile sharing bottom sheet with WhatsApp, Link, and Status Card options.
class HomeSharingSheet {
  HomeSharingSheet._();

  static void show(
    BuildContext context, {
    required ProfileModel profile,
    required ShareRepository shareRepository,
    required UsageRepository usageRepository,
  }) {
    if (LocalCacheService().isGuestMode()) {
      GuestRestrictedDialog.show(context);
      return;
    }

    HapticFeedback.selectionClick();
    Future.microtask(() {
      if (!context.mounted) return;
      final theme = Theme.of(context);

      showModalBottomSheet(
        context: context,
        useRootNavigator: true,
        backgroundColor: Colors.transparent,
        builder: (ctx) => Container(
          padding: EdgeInsets.all(4.w),
          decoration: BoxDecoration(
            color: theme.bottomSheetTheme.backgroundColor ?? theme.cardColor,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                margin: EdgeInsets.only(bottom: 2.h),
                decoration: BoxDecoration(
                  color: theme.dividerColor,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Text(
                AppLocalizations.of(context)?.shareProfile ?? 'Share Profile',
                style: theme.textTheme.titleLarge?.copyWith(fontWeight: AppTypography.bold),
              ),
              SizedBox(height: 2.h),
              if (LocalCacheService().isRelativeBrowseMode()) ...[
                _ShareOptionTile(
                  ctx: ctx,
                  title: AppLocalizations.of(context)?.sendToCandidateWhatsApp ?? 'Send to Bride/Groom on WhatsApp 🚩',
                  icon: 'share',
                  profile: profile,
                  method: 'relative_candidate_whatsapp',
                  shareRepository: shareRepository,
                  usageRepository: usageRepository,
                ),
                SizedBox(height: 1.h),
              ],
              _ShareOptionTile(
                ctx: ctx,
                title: AppLocalizations.of(context)?.whatsAppStatusCardPremium ?? 'WhatsApp Status Card (Premium)',
                icon: 'share',
                profile: profile,
                method: 'whatsapp_status_card',
                shareRepository: shareRepository,
                usageRepository: usageRepository,
              ),
              _ShareOptionTile(
                ctx: ctx,
                title: AppLocalizations.of(context)?.whatsApp ?? 'WhatsApp',
                icon: 'share',
                profile: profile,
                method: 'whatsapp',
                shareRepository: shareRepository,
                usageRepository: usageRepository,
              ),
              _ShareOptionTile(
                ctx: ctx,
                title: AppLocalizations.of(context)?.copyLink ?? 'Copy Link',
                icon: 'link',
                profile: profile,
                method: 'link',
                shareRepository: shareRepository,
                usageRepository: usageRepository,
              ),
              SizedBox(height: 2.h),
            ],
          ),
        ),
      );
    });
  }
}

class _ShareOptionTile extends StatelessWidget {
  final BuildContext ctx;
  final String title;
  final String icon;
  final ProfileModel profile;
  final String method;
  final ShareRepository shareRepository;
  final UsageRepository usageRepository;

  const _ShareOptionTile({
    required this.ctx,
    required this.title,
    required this.icon,
    required this.profile,
    required this.method,
    required this.shareRepository,
    required this.usageRepository,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ListTile(
      leading: Container(
        padding: EdgeInsets.all(1.2.h),
        decoration: BoxDecoration(
          color: theme.colorScheme.primary.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: CustomIconWidget(iconName: icon, color: theme.colorScheme.primary),
      ),
      title: Text(title, style: theme.textTheme.bodyLarge),
      trailing: CustomIconWidget(
        iconName: 'chevron_right',
        color: theme.colorScheme.onSurfaceVariant,
        size: 20,
      ),
      onTap: () async {
        Navigator.pop(ctx);
        try {
          final canShareRes = await usageRepository.canShareProfile();
          canShareRes.fold(
            onSuccess: (canShare) async {
              if (!canShare) {
                final remainingRes = await usageRepository.getRemainingShares();
                remainingRes.fold(
                  onSuccess: (remaining) {
                    if (context.mounted) UpgradeDialog.showShareLimit(context, remaining);
                  },
                  onFailure: (error) => AppLogger.error('HomeSharingSheet', 'Error fetching remaining shares: $error'),
                );
                return;
              }

              if (method == 'relative_candidate_whatsapp') {
                if (context.mounted) {
                  await ShareService().shareProfileToCandidateWhatsApp(context, profile);
                }
                return;
              }

              if (method == 'whatsapp_status_card') {
                if (context.mounted) await ShareService().shareProfileStatus(context, profile);
                return;
              }

              final shareResponse = await shareRepository.shareProfile(
                sharedProfileId: profile.id,
                sharingMethod: method,
                recipientName: '$title Contact',
                recipientRelation: 'Contact',
                profileName: profile.fullName,
              );

              shareResponse.fold(
                onSuccess: (_) {
                  if (context.mounted) {
                    final l10n = AppLocalizations.of(context);
                    String successMsg = l10n?.profileSharedVia(profile.fullName, title) ??
                        'Shared ${profile.fullName} via $title';
                    if (method == 'link') {
                      successMsg = l10n?.profileLinkCopied ?? 'Profile link copied to clipboard!';
                    }
                    if (method == 'in_app') {
                      successMsg = l10n?.profileSharedWith(profile.fullName) ??
                          'Profile shared with ${profile.fullName}';
                    }
                    Fluttertoast.showToast(
                      msg: successMsg,
                      backgroundColor: Colors.green,
                      textColor: Colors.white,
                    );
                  }
                },
                onFailure: (error) {
                  if (context.mounted) {
                    Fluttertoast.showToast(
                      msg: AppLocalizations.of(context)?.shareFailed(error.toString()) ??
                          'Share failed: $error',
                      backgroundColor: Theme.of(context).colorScheme.error,
                      textColor: Colors.white,
                    );
                  }
                },
              );
            },
            onFailure: (error) {
              if (context.mounted) {
                Fluttertoast.showToast(
                  msg: AppLocalizations.of(context)?.errorCheckingShareLimits(error.toString()) ??
                      'Error checking share limits: $error',
                  backgroundColor: Theme.of(context).colorScheme.error,
                  textColor: Colors.white,
                );
              }
            },
          );
        } catch (e) {
          AppLogger.error('HomeSharingSheet', 'Share error: $e');
          if (context.mounted) {
            Fluttertoast.showToast(
              msg: e.toString().replaceAll('Exception: ', ''),
              backgroundColor: Theme.of(context).colorScheme.error,
              textColor: Colors.white,
            );
          }
        }
      },
    );
  }
}
