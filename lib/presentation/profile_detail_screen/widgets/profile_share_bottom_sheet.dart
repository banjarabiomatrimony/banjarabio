import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import 'package:banjarabio/l10n/app_localizations.dart';
import 'package:banjarabio/core/app_export.dart';
import 'package:banjarabio/core/models/profile_model.dart';
import 'package:banjarabio/core/models/profile_share_model.dart';
import 'package:banjarabio/core/repositories/share_repository.dart';
import 'package:banjarabio/core/services/share_service.dart';

/// Share profile bottom sheet extracted from ProfileDetailScreen._handleShare.
class ProfileShareBottomSheet {
  ProfileShareBottomSheet._();

  /// Shows the share bottom sheet and handles all share actions.
  static void show({
    required BuildContext context,
    required Map<String, dynamic> profile,
    required ShareRepository shareRepository,
    required void Function(BackendResponse<ProfileShare> res, String method, String profileName) onShareResult,
  }) {
    final theme = Theme.of(context);
    final profileId = profile['id']?.toString() ?? '';
    final profileName = profile['name']?.toString() ?? 'User';

    showModalBottomSheet(
      context: context,
      useRootNavigator: true,
      backgroundColor: theme.colorScheme.surface,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => Container(
        padding: EdgeInsets.fromLTRB(4.w, 1.5.h, 4.w, 3.h),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 12.w,
                height: 5,
                decoration: BoxDecoration(
                  color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(2.5),
                ),
              ),
            ),
            SizedBox(height: 3.h),
            Text(
              AppLocalizations.of(context)?.shareProfile ?? 'Share Profile',
              style: theme.textTheme.headlineSmall?.copyWith(
                color: theme.colorScheme.onSurface,
                fontWeight: AppTypography.black,
                letterSpacing: -0.5,
              ),
            ),
            SizedBox(height: 2.h),
            Text(
              AppLocalizations.of(context)?.recommendToOthers ?? 'RECOMMEND TO OTHERS',
              style: theme.textTheme.labelMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
                fontWeight: AppTypography.extraBold,
                letterSpacing: 1.2,
              ),
            ),
            SizedBox(height: 1.h),
            _ShareOptionTile(
              title: AppLocalizations.of(context)?.whatsAppRishtaCardTitle ?? '🚩 WhatsApp Rishta Card (Image + QR)',
              subtitle: AppLocalizations.of(context)?.whatsAppRishtaCardSubtitle ?? 'Share premium biodata image card with QR code on WhatsApp',
              iconName: 'share',
              onTap: () async {
                Navigator.pop(ctx);
                try {
                  final profileModel = ProfileModel.fromJson(profile);
                  if (context.mounted) {
                    await ShareService().shareProfileToCandidateWhatsApp(context, profileModel);
                  }
                } catch (_) {
                  // Fallback to text link if model parsing fails
                  if (!context.mounted) return;
                  final res = await shareRepository.shareProfile(
                    sharedProfileId: profileId,
                    sharingMethod: 'whatsapp',
                    recipientName: AppLocalizations.of(context)?.whatsAppContact ?? 'WhatsApp Contact',
                    recipientRelation: 'External',
                    profileName: profileName,
                  );
                  onShareResult(res, 'WhatsApp', profileName);
                }
              },
            ),
            SizedBox(height: 1.h),
            _ShareOptionTile(
              title: AppLocalizations.of(context)?.whatsApp ?? 'WhatsApp Text Link',
              subtitle: AppLocalizations.of(context)?.whatsappShareSubtitle(profileName) ?? 'Share $profileName details with family or friends',
              iconName: 'share',
              onTap: () async {
                Navigator.pop(ctx);
                final res = await shareRepository.shareProfile(
                  sharedProfileId: profileId,
                  sharingMethod: 'whatsapp',
                  recipientName: AppLocalizations.of(context)?.whatsAppContact ?? 'WhatsApp Contact',
                  recipientRelation: 'External',
                  profileName: profileName,
                );
                onShareResult(res, 'WhatsApp', profileName);
              },
            ),
            SizedBox(height: 1.h),
            _ShareOptionTile(
              title: AppLocalizations.of(context)?.copyLink ?? 'Copy Profile Link',
              subtitle: AppLocalizations.of(context)?.copyLinkSubtitle(profileName) ?? 'Copy a link to $profileName profile',
              iconName: 'link',
              onTap: () async {
                Navigator.pop(ctx);
                final res = await shareRepository.shareProfile(
                  sharedProfileId: profileId,
                  sharingMethod: 'link',
                  recipientName: AppLocalizations.of(context)?.linkShare ?? 'Link Share',
                  recipientRelation: 'External',
                  profileName: profileName,
                );
                onShareResult(res, 'link', profileName);
              },
            ),
            SizedBox(height: 2.h),
          ],
        ),
      ),
    );
  }
}

class _ShareOptionTile extends StatelessWidget {
  final String title;
  final String subtitle;
  final String iconName;
  final VoidCallback onTap;

  const _ShareOptionTile({
    required this.title,
    required this.subtitle,
    required this.iconName,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: EdgeInsets.all(4.w),
        margin: EdgeInsets.symmetric(vertical: 0.5.h),
        decoration: BoxDecoration(
          color: Colors.transparent,
          border: Border.all(
            color: theme.colorScheme.outline.withValues(alpha: 0.15),
          ),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(2.5.w),
              decoration: BoxDecoration(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(12),
              ),
              child: CustomIconWidget(
                iconName: iconName,
                color: theme.colorScheme.onSurface,
              ),
            ),
            SizedBox(width: 4.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: AppTypography.extraBold,
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                  SizedBox(height: 0.2.h),
                  Text(
                    subtitle,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                      fontWeight: AppTypography.medium,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right,
              color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.2),
            ),
          ],
        ),
      ),
    );
  }
}
