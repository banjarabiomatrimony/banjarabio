import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:share_plus/share_plus.dart';
import 'package:sizer/sizer.dart';

import 'package:banjarabio/l10n/app_localizations.dart';
import 'package:banjarabio/core/models/referral_stats_model.dart';
import 'package:banjarabio/features/referral/providers/referral_invite_notifier.dart';
import 'package:banjarabio/core/constants/app_typography.dart';
import 'package:banjarabio/core/utils/error_message_mapper.dart';
import 'package:banjarabio/core/utils/app_feedback_service.dart';
import 'package:banjarabio/presentation/referral_screen/widgets/referral_tier_card.dart';
import 'package:banjarabio/widgets/custom_app_bar.dart';
import 'package:banjarabio/widgets/app_logo_image.dart';
import 'package:banjarabio/widgets/tactile/tactile_pressable.dart';
import 'package:banjarabio/widgets/tactile/tactile_category_card.dart';
import 'package:banjarabio/widgets/shimmer_widget.dart';
import 'package:banjarabio/theme/app_category_theme.dart';
import 'package:banjarabio/theme/app_colors.dart';

/// 🎁 Refer & Earn (Invite a Relative) Screen - Ultra-Premium Tactile Edition
/// Features:
/// ✨ Celebration Hero Banner with Pulsating Rings & Rich Amethyst Gradient
/// 📊 Live Referral Metrics Stats Card with Dynamic Theming
/// 👑 Tier Milestone Timeline Card
/// 🔗 Easy One-Tap Code/Link Copy & Instant WhatsApp Share
/// 🛣️ 3-Step "How It Works" Journey
/// 🔘 Tactile Action Buttons with Haptics
class ReferralInviteScreen extends ConsumerStatefulWidget {
  const ReferralInviteScreen({super.key});

  @override
  ConsumerState<ReferralInviteScreen> createState() => _ReferralInviteScreenState();
}

class _ReferralInviteScreenState extends ConsumerState<ReferralInviteScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.06).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final asyncState = ref.watch(referralInviteProvider);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: CustomAppBar(
        automaticallyImplyLeading: false,
        leadingWidth: 175,
        leading: Padding(
          padding: const EdgeInsets.only(left: 10),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              // ⬅️ Tactile Back Button
              TactilePressable(
                onTap: () {
                  HapticFeedback.lightImpact();
                  Navigator.maybePop(context);
                },
                child: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: (theme.appBarTheme.foregroundColor ?? Colors.white)
                        .withValues(alpha: isDark ? AppColors.opacity12 : AppColors.opacity15),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.arrow_back_ios_new_rounded,
                    color: theme.appBarTheme.foregroundColor ?? Colors.white,
                    size: 15,
                  ),
                ),
              ),
              const SizedBox(width: 8),

              // 👑 App Logo
              ClipOval(
                child: Container(
                  width: 24,
                  height: 24,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                  ),
                  child: const AppLogoImage(
                    width: 24,
                    height: 24,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              const SizedBox(width: 5),

              // 🏷️ Wordmark
              Image.asset(
                'assets/logo/brand_kit/wordmark.png',
                height: 20,
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) =>
                    const SizedBox.shrink(),
              ),
            ],
          ),
        ),
        titleWidget: FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            l10n?.inviteARelative ?? 'Refer & Earn',
            maxLines: 1,
            style: (theme.appBarTheme.titleTextStyle ?? theme.textTheme.titleMedium)?.copyWith(
              fontSize: AppTypography.headingSmall,
              fontWeight: AppTypography.bold,
              color: theme.appBarTheme.foregroundColor ?? Colors.white,
              letterSpacing: 0.1,
            ),
          ),
        ),
      ),
      body: asyncState.when(
        loading: () => SingleChildScrollView(
          physics: const NeverScrollableScrollPhysics(),
          padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
          child: Column(
            children: [
              ShimmerWidget.rectangular(
                height: 22.h,
                shapeBorder: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              ),
              SizedBox(height: 2.h),
              ShimmerWidget.rectangular(
                height: 12.h,
                shapeBorder: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
              SizedBox(height: 2.h),
              ShimmerWidget.rectangular(
                height: 26.h,
                shapeBorder: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
            ],
          ),
        ),
        error: (error, _) => _buildError(context, theme, error),
        data: (data) => _buildContent(context, theme, data, l10n),
      ),
    );
  }

  Widget _buildError(
    BuildContext context,
    ThemeData theme,
    Object error,
  ) {
    final l10n = AppLocalizations.of(context);
    return Center(
      child: Padding(
        padding: EdgeInsets.all(5.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 48, color: theme.colorScheme.error),
            SizedBox(height: 2.h),
            Text(
              l10n?.failedToLoadReferralData ?? 'Failed to load referral data',
              style: theme.textTheme.titleMedium?.copyWith(fontWeight: AppTypography.bold),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 1.h),
            Text(
              ErrorMessageMapper.toUserFriendlyMessage(
                error,
                context: context,
                contextTag: 'referral',
              ),
              style: theme.textTheme.bodySmall,
              textAlign: TextAlign.center,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
            SizedBox(height: 3.h),
            TactilePressable(
              onTap: () => ref.read(referralInviteProvider.notifier).refresh(),
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 1.2.h),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.refresh_rounded, color: Colors.white, size: 18),
                    SizedBox(width: 2.w),
                    Text(
                      l10n?.retry ?? 'Retry',
                      style: const TextStyle(color: Colors.white, fontWeight: AppTypography.bold),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent(
    BuildContext context,
    ThemeData theme,
    ReferralInviteData data,
    AppLocalizations? l10n,
  ) {
    return RefreshIndicator(
      onRefresh: () {
        if (kDebugMode) {
          debugPrint(
            '[REFERRAL] ReferralInviteScreen > User pulled to refresh > Calling refresh',
          );
        }
        return ref.read(referralInviteProvider.notifier).refresh();
      },
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.2.h),
        child: Column(
          children: [
            // 🎊 1. Celebration Hero Banner
            _buildCelebrationHeroBanner(theme, l10n),
            SizedBox(height: 2.h),

            // 📊 2. Live Metrics Stats Card
            _buildStatsCard(context, theme, data.stats, l10n),
            SizedBox(height: 2.h),

            // 👑 3. Tier Milestone Timeline Card
            ReferralTierCard(currentReferrals: data.stats?.referralCount ?? 0),
            SizedBox(height: 2.h),

            // 🔗 4. Invite Code, Link & Instant Sharing
            _buildInviteCard(context, theme, data, l10n),
            SizedBox(height: 2.h),

            // 🛣️ 5. Simple 3-Step Journey
            _buildHowItWorks(context, theme, l10n),
            SizedBox(height: 3.h),
          ],
        ),
      ),
    );
  }

  Widget _buildCelebrationHeroBanner(ThemeData theme, AppLocalizations? l10n) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(4.5.w),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        gradient: const LinearGradient(
          colors: [
            AppColors.primaryDark,
            AppColors.primary,
            AppColors.deepOrange,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: AppColors.opacity35),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          AnimatedBuilder(
            animation: _pulseAnimation,
            builder: (context, child) {
              return Transform.scale(
                scale: _pulseAnimation.value,
                child: Container(
                  padding: EdgeInsets.all(3.w),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: AppColors.opacity20),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Colors.white.withValues(alpha: AppColors.opacity40),
                      width: 1.2,
                    ),
                  ),
                  child: const Icon(
                    Icons.card_giftcard_rounded,
                    color: AppColors.categoryVip,
                    size: 32,
                  ),
                ),
              );
            },
          ),
          SizedBox(width: 3.5.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n?.refer3FriendsGet1MonthFree ?? 'Refer Friends, Earn Free Premium! 🎁',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: AppTypography.headingSmall,
                    fontWeight: AppTypography.black,
                    letterSpacing: 0.3,
                  ),
                ),
                SizedBox(height: 0.4.h),
                Text(
                  l10n?.helpOurCommunityGrowAndUnlockPremiumRewa ??
                      'Help relatives find matches & unlock free Premium months + VIP passes for yourself.',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: AppColors.opacity90),
                    fontSize: AppTypography.bodySmall,
                    height: 1.35,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsCard(
    BuildContext context,
    ThemeData theme,
    ReferralStatsModel? stats,
    AppLocalizations? l10n,
  ) {
    return TactileCategoryCard(
      categoryType: CategoryType.trustScore,
      title: 'Your Referral Summary',
      icon: Icons.insights_rounded,
      margin: EdgeInsets.zero,
      padding: EdgeInsets.all(3.5.w),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatItem(
            theme,
            l10n?.referrals ?? 'Total Referrals',
            '${stats?.referralCount ?? 0}',
            Icons.people_alt_rounded,
            AppColors.teal,
          ),
          Container(
            height: 38,
            width: 1.2,
            color: theme.colorScheme.outlineVariant.withValues(alpha: AppColors.opacity30),
          ),
          _buildStatItem(
            theme,
            l10n?.rewards ?? 'Free Months',
            '${stats?.rewardsEarned ?? 0}',
            Icons.military_tech_rounded,
            AppColors.categoryAstroDark,
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(
    ThemeData theme,
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return Column(
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(width: 6),
            Text(
              value,
              style: TextStyle(
                fontSize: AppTypography.headingLarge,
                fontWeight: AppTypography.black,
                color: theme.colorScheme.onSurface,
              ),
            ),
          ],
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: TextStyle(
            fontSize: AppTypography.bodySmall,
            fontWeight: AppTypography.semiBold,
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }

  Widget _buildInviteCard(
    BuildContext context,
    ThemeData theme,
    ReferralInviteData data,
    AppLocalizations? l10n,
  ) {
    final isDark = theme.brightness == Brightness.dark;

    return TactileCategoryCard(
      categoryType: CategoryType.career,
      title: l10n?.yourPersonalInviteLink ?? 'Personal Invite Code & Link',
      icon: Icons.link_rounded,
      margin: EdgeInsets.zero,
      padding: EdgeInsets.all(3.8.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 🏷️ Referral Code Box
          if (data.code != null && data.code!.isNotEmpty) ...[
            Container(
              padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.4.h),
              decoration: BoxDecoration(
                color: isDark
                    ? AppColors.surfaceDark
                    : AppColors.categoryPersonalBg,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: AppColors.categoryPersonal.withValues(alpha: AppColors.opacity40),
                  width: 1.4,
                ),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.categoryPersonal.withValues(alpha: AppColors.opacity15),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.qr_code_2_rounded, color: AppColors.categoryPersonal, size: 22),
                  ),
                  SizedBox(width: 3.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          l10n?.yourReferralCode ?? 'Your Referral Code',
                          style: TextStyle(
                            fontSize: AppTypography.labelSmall,
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                        const SizedBox(height: 2),
                        SelectableText(
                          data.code!,
                          style: TextStyle(
                            fontWeight: AppTypography.black,
                            fontSize: AppTypography.bodyLarge,
                            letterSpacing: 1.5,
                            color: AppColors.primary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  TactilePressable(
                    onTap: () => _copyToClipboard(context, data.code),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: AppColors.opacity12),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.copy_rounded, color: AppColors.primary, size: 14),
                          const SizedBox(width: 4),
                          Text(
                            'Copy',
                            style: TextStyle(
                              fontSize: AppTypography.bodySmall,
                              fontWeight: AppTypography.bold,
                              color: AppColors.primary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 1.5.h),
          ],

          // 🔗 Link Preview Box
          Container(
            padding: EdgeInsets.symmetric(horizontal: 3.5.w, vertical: 1.h),
            decoration: BoxDecoration(
              color: isDark
                  ? Colors.white.withValues(alpha: 0.04)
                  : theme.colorScheme.surfaceContainerHighest.withValues(alpha: AppColors.opacity35),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: theme.colorScheme.outlineVariant.withValues(alpha: AppColors.opacity30),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    data.link ?? 'https://banjarabio.com/invite',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: AppTypography.bodySmall,
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
                TactilePressable(
                  onTap: () => _copyToClipboard(context, data.link),
                  child: Padding(
                    padding: const EdgeInsets.all(4),
                    child: Icon(Icons.copy_rounded, color: theme.colorScheme.primary, size: 20),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 2.h),

          // 💬 WhatsApp Share Action (Prominent)
          TactilePressable(
            onTap: () => _shareInvite(context, data.link),
            pressedScale: 0.96,
            child: Container(
              width: double.infinity,
              height: 50,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppColors.whatsapp, AppColors.whatsappDark],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.whatsapp.withValues(alpha: AppColors.opacity30),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.send_rounded, color: Colors.white, size: 20),
                    SizedBox(width: 2.w),
                    Text(
                      l10n?.shareLinkOnWhatsapp ?? 'Share on WhatsApp & Relatives',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: AppTypography.black,
                        fontSize: AppTypography.headingSmall,
                        letterSpacing: 0.3,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _copyToClipboard(BuildContext context, String? text) {
    if (text == null || text.isEmpty) return;
    if (kDebugMode) {
      debugPrint(
        '[REFERRAL] ReferralInviteScreen > User tapped Copy > Clipboard set',
      );
    }
    Clipboard.setData(ClipboardData(text: text));
    HapticFeedback.lightImpact();
    AppFeedback.showSuccess(
      context,
      AppLocalizations.of(context)?.referralLinkCopiedToClipboard ??
          '🎉 Copied to clipboard!',
    );
  }

  void _shareInvite(BuildContext context, String? link) {
    if (link == null || link.isEmpty) return;
    if (kDebugMode) {
      debugPrint(
        '[REFERRAL] ReferralInviteScreen > User tapped Share Link > Opening share sheet',
      );
    }
    HapticFeedback.lightImpact();
    Share.share(
      AppLocalizations.of(context)?.referralShareMessage(link) ??
          'Join BanjaraBio, the most trusted matrimonial app for our community! Use my link to get started: $link',
      subject: AppLocalizations.of(context)?.referralShareSubject ??
          'Invitation to Join BanjaraBio',
    );
  }

  Widget _buildHowItWorks(
    BuildContext context,
    ThemeData theme,
    AppLocalizations? l10n,
  ) {
    return TactileCategoryCard(
      categoryType: CategoryType.personal,
      title: l10n?.howItWorks ?? 'How it works',
      icon: Icons.auto_awesome_rounded,
      margin: EdgeInsets.zero,
      padding: EdgeInsets.all(3.8.w),
      child: Column(
        children: [
          _buildStep(
            theme,
            1,
            'Share Your Code',
            l10n?.inviteStep1 ?? 'Share your unique invite link with relatives & friends on WhatsApp.',
            Icons.share_rounded,
          ),
          SizedBox(height: 1.2.h),
          _buildStep(
            theme,
            2,
            'They Register & Verify',
            l10n?.inviteStep2 ?? 'Relative registers and verifies their matrimony profile.',
            Icons.verified_user_rounded,
          ),
          SizedBox(height: 1.2.h),
          _buildStep(
            theme,
            3,
            'Earn Free Premium',
            l10n?.inviteStep3 ?? 'You get 1 month of Premium after every 3 successful referrals!',
            Icons.military_tech_rounded,
          ),
        ],
      ),
    );
  }

  Widget _buildStep(
    ThemeData theme,
    int number,
    String title,
    String text,
    IconData icon,
  ) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: theme.colorScheme.primary.withValues(alpha: AppColors.opacity12),
            shape: BoxShape.circle,
            border: Border.all(
              color: theme.colorScheme.primary.withValues(alpha: AppColors.opacity30),
              width: 1.2,
            ),
          ),
          child: Center(
            child: Text(
              '$number',
              style: TextStyle(
                fontSize: AppTypography.labelMedium,
                fontWeight: AppTypography.bold,
                color: theme.colorScheme.primary,
              ),
            ),
          ),
        ),
        SizedBox(width: 3.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: AppTypography.labelMedium,
                  fontWeight: AppTypography.bold,
                  color: theme.colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                text,
                style: TextStyle(
                  fontSize: AppTypography.labelSmall,
                  color: theme.colorScheme.onSurfaceVariant,
                  height: 1.35,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
