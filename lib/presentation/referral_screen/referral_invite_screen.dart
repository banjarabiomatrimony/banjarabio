import 'package:flutter/material.dart';
import 'package:banjarabio/l10n/app_localizations.dart';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';
import 'package:sizer/sizer.dart';

import 'package:banjarabio/core/models/referral_stats_model.dart';
import 'package:banjarabio/core/repositories/referral_repository.dart';

class ReferralInviteScreen extends StatefulWidget {
  const ReferralInviteScreen({super.key});

  @override
  State<ReferralInviteScreen> createState() => _ReferralInviteScreenState();
}

class _ReferralInviteScreenState extends State<ReferralInviteScreen> {
  final ReferralRepository _referralRepository = ReferralRepository();
  bool _isLoading = true;
  ReferralStatsModel? _stats;
  String? _referralLink;
  String? _referralCode;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);

    // Fetch Stats
    final statsRes = await _referralRepository.getReferralStats();
    // Fetch Code
    final codeRes = await _referralRepository.getMyReferralCode();

    if (mounted) {
      setState(() {
        _isLoading = false;
        statsRes.fold(
          onSuccess: (s) => _stats = s,
          onFailure: (e) => debugPrint('Stats error: $e'),
        );

        codeRes.fold(
          onSuccess: (code) {
            _referralCode = code;
            // _referralLink = "https://banjarabio.com/invite/$code";
            _referralLink =
                'https://play.google.com/store/apps/details?id=com.avishio.banjarabio&referrer=invite/$code';
          },
          onFailure: (e) => debugPrint('Code error: $e'),
        );
      });
    }
  }

  void _copyToClipboard() {
    if (_referralLink == null) return;
    Clipboard.setData(ClipboardData(text: _referralLink!));
    HapticFeedback.lightImpact();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(AppLocalizations.of(context)?.referralLinkCopiedToClipboard ?? 'Referral link copied to clipboard!')),
    );
  }

  void _shareInvite() {
    if (_referralLink == null) return;
    HapticFeedback.lightImpact();
    Share.share(
      AppLocalizations.of(context)?.referralInviteMessage(_referralLink!) ?? 'Join BanjaraBio, the most trusted matrimonial app for our community! Use my link to get started: $_referralLink',
      subject: AppLocalizations.of(context)?.referralInviteSubject ?? 'Invitation to Join BanjaraBio',
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(AppLocalizations.of(context)?.inviteARelative ?? 'Invite a Relative')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: EdgeInsets.all(20.sp),
              child: Column(
                children: [
                  _buildHeader(theme),
                  SizedBox(height: 30.sp),
                  _buildStatsCard(theme),
                  SizedBox(height: 30.sp),
                  _buildInviteCard(theme),
                  SizedBox(height: 40.sp),
                  _buildHowItWorks(theme),
                ],
              ),
            ),
    );
  }

  Widget _buildHeader(ThemeData theme) {
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

  Widget _buildStatsCard(ThemeData theme) {
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
          _buildStatItem(theme, AppLocalizations.of(context)?.referralsLabel ?? 'Referrals', '${_stats?.referralCount ?? 0}'),
          Container(height: 30.sp, width: 1, color: theme.dividerColor),
          _buildStatItem(theme, AppLocalizations.of(context)?.rewardsLabel ?? 'Rewards', '${_stats?.rewardsEarned ?? 0}'),
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

  Widget _buildReferralCodeDisplay(ThemeData theme) {
    if (_referralCode == null) return const SizedBox.shrink();

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
            _referralCode!,
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

  Widget _buildInviteCard(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(AppLocalizations.of(context)?.yourPersonalInviteLink ?? 'Your Personal Invite Link',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 12.sp),
        _buildReferralCodeDisplay(theme),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 16.sp, vertical: 12.sp),
          decoration: BoxDecoration(
            color: theme.colorScheme.surfaceContainerHighest.withAlpha(
              76,
            ), // 0.3 alpha
            borderRadius: BorderRadius.circular(12.sp),
            border: Border.all(color: theme.dividerColor),
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  _referralLink ?? '',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.bodyMedium,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.copy_rounded),
                onPressed: _copyToClipboard,
                color: theme.colorScheme.primary,
              ),
            ],
          ),
        ),
        SizedBox(height: 16.sp),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: _shareInvite,
            icon: const Icon(Icons.share_rounded, color: Colors.white),
            label: Text(AppLocalizations.of(context)?.shareLinkOnWhatsapp ?? 'Share Link on WhatsApp'),
          ),
        ),
      ],
    );
  }

  Widget _buildHowItWorks(ThemeData theme) {
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
