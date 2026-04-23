import 'package:flutter/foundation.dart';
import 'package:banjarabio/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:share_plus/share_plus.dart';
import 'package:sizer/sizer.dart';

import 'package:banjarabio/core/models/referral_stats_model.dart';
import 'package:banjarabio/features/referral/providers/referral_invite_notifier.dart';

/// Riverpod-based Referral Invite screen.
/// Parallel to [ReferralInviteScreen]; use until migration 100% validated.
class ReferralInviteScreenRiverpod extends ConsumerWidget {
  const ReferralInviteScreenRiverpod({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncState = ref.watch(referralInviteProvider);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: Text(AppLocalizations.of(context)?.inviteARelative ?? 'Invite a Relative')),
      body: asyncState.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => _buildError(context, theme, error, ref),
        data: (data) => _buildContent(context, ref, theme, data),
      ),
    );
  }

  Widget _buildError(
    BuildContext context,
    ThemeData theme,
    Object error,
    WidgetRef ref,
  ) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(20.sp),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 48.sp, color: theme.colorScheme.error),
            SizedBox(height: 16.sp),
            Text(AppLocalizations.of(context)?.failedToLoadReferralData ?? 'Failed to load referral data',
              style: theme.textTheme.titleMedium,
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 8.sp),
            Text(
              error.toString(),
              style: theme.textTheme.bodySmall,
              textAlign: TextAlign.center,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
            SizedBox(height: 24.sp),
            ElevatedButton.icon(
              onPressed: () =>
                  ref.read(referralInviteProvider.notifier).refresh(),
              icon: const Icon(Icons.refresh),
              label: Text(AppLocalizations.of(context)?.retry ?? 'Retry'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent(
    BuildContext context,
    WidgetRef ref,
    ThemeData theme,
    ReferralInviteData data,
  ) {
    return RefreshIndicator(
      onRefresh: () {
        if (kDebugMode) {
          debugPrint(
            '[REFERRAL] ReferralInviteScreenRiverpod > User pulled to refresh > Calling refresh',
          );
        }
        return ref.read(referralInviteProvider.notifier).refresh();
      },
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: EdgeInsets.all(20.sp),
        child: Column(
          children: [
            _buildHeader(context, theme),
            SizedBox(height: 30.sp),
            _buildStatsCard(context, theme, data.stats),
            SizedBox(height: 30.sp),
            _buildInviteCard(context, theme, data),
            SizedBox(height: 40.sp),
            _buildHowItWorks(context, theme),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, ThemeData theme) {
    return Column(
      children: [
        Icon(
          Icons.card_giftcard_rounded,
          size: 60.sp,
          color: theme.colorScheme.secondary,
        ),
        SizedBox(height: 16.sp),
        Text(AppLocalizations.of(context)?.refer3FriendsGet1MonthFree ?? 'Refer 3 Friends, Get 1 Month Free!',
          textAlign: TextAlign.center,
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.primary,
          ),
        ),
        SizedBox(height: 8.sp),
        Text(AppLocalizations.of(context)?.helpOurCommunityGrowAndUnlockPremiumRewa ?? 'Help our community grow and unlock Premium rewards for yourself.',
          textAlign: TextAlign.center,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
          ),
        ),
      ],
    );
  }

  Widget _buildStatsCard(BuildContext context, ThemeData theme, ReferralStatsModel? stats) {
    return Container(
      padding: EdgeInsets.all(20.sp),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(20.sp),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatItem(theme, AppLocalizations.of(context)?.referrals ?? 'Referrals', '${stats?.referralCount ?? 0}'),
          Container(height: 30.sp, width: 1, color: theme.dividerColor),
          _buildStatItem(theme, AppLocalizations.of(context)?.rewards ?? 'Rewards', '${stats?.rewardsEarned ?? 0}'),
        ],
      ),
    );
  }

  Widget _buildStatItem(ThemeData theme, String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: theme.textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.primary,
          ),
        ),
        Text(
          label,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
          ),
        ),
      ],
    );
  }

  Widget _buildReferralCodeDisplay(BuildContext context, ThemeData theme, String? code) {
    if (code == null || code.isEmpty) return const SizedBox.shrink();

    return Container(
      margin: EdgeInsets.only(bottom: 16.sp),
      padding: EdgeInsets.all(12.sp),
      decoration: BoxDecoration(
        color: theme.colorScheme.primary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: theme.colorScheme.primary, width: 2),
      ),
      child: Column(
        children: [
          Text(AppLocalizations.of(context)?.yourReferralCode ?? 'Your Referral Code',
            style: theme.textTheme.labelMedium?.copyWith(
              color: theme.colorScheme.primary,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 4.sp),
          SelectableText(
            code,
            style: theme.textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.bold,
              letterSpacing: 2,
              color: theme.colorScheme.primary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInviteCard(
    BuildContext context,
    ThemeData theme,
    ReferralInviteData data,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(AppLocalizations.of(context)?.yourPersonalInviteLink ?? 'Your Personal Invite Link',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 12.sp),
        _buildReferralCodeDisplay(context, theme, data.code),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 16.sp, vertical: 12.sp),
          decoration: BoxDecoration(
            color: theme.colorScheme.surfaceContainerHighest.withAlpha(76),
            borderRadius: BorderRadius.circular(12.sp),
            border: Border.all(color: theme.dividerColor),
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  data.link ?? '',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.bodyMedium,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.copy_rounded),
                onPressed: () => _copyToClipboard(context, data.link),
                color: theme.colorScheme.primary,
              ),
            ],
          ),
        ),
        SizedBox(height: 16.sp),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: () => _shareInvite(context, data.link),
            icon: const Icon(Icons.share_rounded, color: Colors.white),
            label: Text(AppLocalizations.of(context)?.shareLinkOnWhatsapp ?? 'Share Link on WhatsApp'),
          ),
        ),
      ],
    );
  }

  void _copyToClipboard(BuildContext context, String? link) {
    if (link == null || link.isEmpty) return;
    if (kDebugMode) {
      debugPrint(
        '[REFERRAL] ReferralInviteScreenRiverpod > User tapped Copy link > Clipboard set',
      );
    }
    Clipboard.setData(ClipboardData(text: link));
    HapticFeedback.lightImpact();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(AppLocalizations.of(context)?.referralLinkCopiedToClipboard ?? 'Referral link copied to clipboard!')),
    );
  }

  void _shareInvite(BuildContext context, String? link) {
    if (link == null || link.isEmpty) return;
    if (kDebugMode) {
      debugPrint(
        '[REFERRAL] ReferralInviteScreenRiverpod > User tapped Share Link > Opening share sheet',
      );
    }
    HapticFeedback.lightImpact();
    Share.share(
      AppLocalizations.of(context)?.referralShareMessage(link) ?? 'Join BanjaraBio, the most trusted matrimonial app for our community! Use my link to get started: $link',
      subject: AppLocalizations.of(context)?.referralShareSubject ?? 'Invitation to Join BanjaraBio',
    );
  }

  Widget _buildHowItWorks(BuildContext context, ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(AppLocalizations.of(context)?.howItWorks ?? 'How it works',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 16.sp),
        _buildStep(theme, 1, AppLocalizations.of(context)?.inviteStep1 ?? 'Share your unique invite link with relatives.'),
        _buildStep(theme, 2, AppLocalizations.of(context)?.inviteStep2 ?? 'They register and verify their profile.'),
        _buildStep(
          theme,
          3,
          AppLocalizations.of(context)?.inviteStep3 ?? 'You get 1 month of Premium after every 3 successful referrals!',
        ),
      ],
    );
  }

  Widget _buildStep(ThemeData theme, int number, String text) {
    return Padding(
      padding: EdgeInsets.only(bottom: 12.sp),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 10.sp,
            backgroundColor: theme.colorScheme.primary.withValues(alpha: 0.1),
            child: Text(
              '$number',
              style: TextStyle(
                fontSize: 10.sp,
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.primary,
              ),
            ),
          ),
          SizedBox(width: 12.sp),
          Expanded(
            child: Text(
              text,
              style: theme.textTheme.bodyMedium?.copyWith(height: 1.4),
            ),
          ),
        ],
      ),
    );
  }
}
