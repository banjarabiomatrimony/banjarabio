import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sizer/sizer.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:fluttertoast/fluttertoast.dart';

import 'package:banjarabio/core/app_export.dart';
import 'package:banjarabio/core/providers/profile_providers.dart';
import 'package:banjarabio/core/repositories/auth_repository.dart';
import 'package:banjarabio/core/models/profile_model.dart';
import 'package:banjarabio/core/models/subscription_model.dart';
import 'package:banjarabio/widgets/custom_app_bar.dart';
import 'package:banjarabio/widgets/app_logo_image.dart';
import 'package:banjarabio/l10n/app_localizations.dart';
import 'package:banjarabio/presentation/account_screen/marriage_reward_form_screen.dart';
import 'package:banjarabio/presentation/melava_screen/melava_screen.dart';
import 'package:banjarabio/presentation/my_profile_screen/widgets/vouch_share_modal.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:banjarabio/widgets/tactile/tactile_pressable.dart';

/// 👑 My Profile & Community Hub (Tab 4) - Ultra-Premium Edition
/// Exact same placements with luxury micro-interactions, spring physics, and royal finishes.
class AccountScreen extends ConsumerStatefulWidget {
  const AccountScreen({super.key});

  @override
  ConsumerState<AccountScreen> createState() => _AccountScreenState();
}

class _AccountScreenState extends ConsumerState<AccountScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  final AuthRepository _authRepository = AuthRepository();

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _launchUrlExternal(String urlString) async {
    try {
      final Uri uri = Uri.parse(urlString);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        if (!mounted) return;
        Fluttertoast.showToast(msg: AppLocalizations.of(context)?.couldNotLaunchUrl ?? 'Could not launch URL');
      }
    } catch (_) {
      if (!mounted) return;
      Fluttertoast.showToast(msg: AppLocalizations.of(context)?.errorLaunchingLink ?? 'Error launching link');
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final l10n = AppLocalizations.of(context);
    final ownProfileAsync = ref.watch(ownProfileProvider);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: CustomAppBar(
        automaticallyImplyLeading: false,
        leadingWidth: 140,
        leading: Padding(
          padding: const EdgeInsets.only(left: 12),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              ClipOval(
                child: Container(
                  width: 26,
                  height: 26,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                  ),
                  child: const AppLogoImage(
                    width: 26,
                    height: 26,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              const SizedBox(width: 5),
              Image.asset(
                'assets/logo/brand_kit/wordmark.png',
                height: 22,
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) =>
                    const SizedBox.shrink(),
              ),
            ],
          ),
        ),
        titleWidget: Text(
          l10n?.account ?? 'Account',
          style: (theme.appBarTheme.titleTextStyle ?? theme.textTheme.titleMedium)?.copyWith(
            fontSize: AppTypography.headingMedium,
            fontWeight: AppTypography.semiBold,
            color: theme.appBarTheme.foregroundColor ?? Colors.white,
            letterSpacing: 0.2,
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: Center(
              child: TactilePressable(
                onTap: () {
                  HapticFeedback.lightImpact();
                  Navigator.pushNamed(context, AppRoutes.appPreferences);
                },
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 2.4.w, vertical: 0.4.h),
                  decoration: BoxDecoration(
                    color: (theme.appBarTheme.foregroundColor ?? Colors.white)
                        .withValues(alpha: isDark ? AppColors.opacity12 : AppColors.opacity15),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: (theme.appBarTheme.foregroundColor ?? Colors.white)
                          .withValues(alpha: isDark ? AppColors.opacity25 : AppColors.opacity35),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.settings_outlined,
                        color: theme.appBarTheme.foregroundColor ?? Colors.white,
                        size: 13,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'Settings',
                        style: TextStyle(
                          color: theme.appBarTheme.foregroundColor ?? Colors.white,
                          fontWeight: AppTypography.bold,
                          fontSize: AppTypography.labelSmall,
                          letterSpacing: 0.2,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.only(
          left: 4.w,
          right: 4.w,
          top: 1.5.h,
          bottom: 10.h, // Generous padding so bottom content & logout button are never obscured by floating bottom bar
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 👑 1. User Profile Hero Card
            _buildAnimatedItem(
              index: 0,
              child: ownProfileAsync.when(
                data: (profile) {
                  if (profile == null) {
                    return _buildGuestHeader(theme);
                  }
                  return _buildProfileHeader(context, theme, profile);
                },
                loading: () => _buildHeaderShimmer(theme),
                error: (err, stack) => _buildGuestHeader(theme),
              ),
            ),
            SizedBox(height: 2.2.h),

            // 💎 2. Matrimony Pro & Activity Grid (Premium, Who Viewed Me, Trust Score, Saved Profiles)
            _buildAnimatedItem(
              index: 1,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSectionHeader(
                    theme,
                    '💎 Matrimony Activity & Pro',
                    'Your visibility, saved profiles & trust badge',
                  ),
                  SizedBox(height: 1.2.h),
                  _buildMatrimonyStatsGrid(theme),
                ],
              ),
            ),
            SizedBox(height: 2.2.h),

            // 🛡️ 3. Social Proof (Vouches) Hero Card (New)
            _buildAnimatedItem(
              index: 2,
              child: ownProfileAsync.maybeWhen(
                data: (profile) =>
                    _buildSocialProofVouchesSection(theme, profile),
                orElse: () => const SizedBox.shrink(),
              ),
            ),
            SizedBox(height: 2.2.h),

            // 🏛️ 4. Community & Welfare Programs (Melavas & BVS Trust)
            _buildAnimatedItem(
              index: 3,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSectionHeader(
                    theme,
                    '🏛️ Community & Welfare Initiatives',
                    'Candidate meets, regional events & community trust subsidy',
                  ),
                  SizedBox(height: 1.2.h),
                  _buildCommunityCards(theme),
                ],
              ),
            ),
            SizedBox(height: 2.2.h),

            // 🎁 5. Rewards & Success Stories (Refer & Earn, Found Partner)
            _buildAnimatedItem(
              index: 4,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSectionHeader(
                    theme,
                    '🎁 Rewards & Stories',
                    'Earn cash rewards & claim free marriage gift packages',
                  ),
                  SizedBox(height: 1.2.h),
                  _buildRewardsGrid(theme),
                ],
              ),
            ),
            SizedBox(height: 2.2.h),

            // 📞 6. Official Channels & Helpline
            _buildAnimatedItem(
              index: 5,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSectionHeader(
                    theme,
                    '📞 Official Support & Connect',
                    'Direct WhatsApp helpline & social community',
                  ),
                  SizedBox(height: 1.2.h),
                  _buildOfficialChannels(theme),
                ],
              ),
            ),
            SizedBox(height: 2.2.h),

            // 🌟 7. Community Trust & Impact Grid (2x2) (New)
            _buildAnimatedItem(
              index: 6,
              child: _buildCommunityTrustImpactGrid(theme),
            ),
            SizedBox(height: 3.h),

            // 🚪 8. Logout Button
            _buildAnimatedItem(
              index: 7,
              child: _buildLogoutButton(context, theme),
            ),
            SizedBox(height: 3.h),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(ThemeData theme, String title, String subtitle) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: AppTypography.headingSmall,
            fontWeight: AppTypography.bold,
            color: theme.colorScheme.onSurface,
          ),
        ),
        SizedBox(height: 0.2.h),
        Text(
          subtitle,
          style: TextStyle(
            fontSize: AppTypography.labelSmall,
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }

  // 💎 2x2 Matrimony Pro & Activity Grid (Tactile & Luxurious with Dynamic Badges)
  // 💎 2x2 Matrimony Pro & Activity Grid (Tactile & Luxurious with _RewardAnimatedCard)
  Widget _buildMatrimonyStatsGrid(ThemeData theme) {
    final subscriptionAsync = ref.watch(ownSubscriptionProvider);
    final viewsCountAsync = ref.watch(whoViewedMeCountProvider);
    final trustScoreAsync = ref.watch(trustScoreProvider);
    final savedCountAsync = ref.watch(savedProfilesCountProvider);

    // 1. Subscription Plan Badge
    final isPaidPlan = subscriptionAsync.maybeWhen(
      data: (sub) => sub != null && sub.planType.isPaidPlan,
      orElse: () => false,
    );
    final planBadgeText = subscriptionAsync.maybeWhen(
      data: (sub) {
        if (sub != null && sub.planType.isPaidPlan) {
          return '👑 ${sub.planType.displayName.toUpperCase()}';
        }
        return 'FREE';
      },
      orElse: () => 'FREE',
    );

    // 2. Who Viewed Me Badge (e.g., "12 Views" or "0 Views")
    final viewsCount = viewsCountAsync.maybeWhen(
      data: (count) => count,
      orElse: () => 0,
    );
    final viewsBadgeText = '$viewsCount Views';

    // 3. Trust Score Badge (e.g., "85%", "100%", "0%")
    final trustScore = trustScoreAsync.maybeWhen(
      data: (score) => score,
      orElse: () => 0,
    );
    final trustBadgeText = '$trustScore%';

    // 4. Saved Profiles Badge (e.g., "3 Saved" or "0 Saved")
    final savedCount = savedCountAsync.maybeWhen(
      data: (count) => count,
      orElse: () => 0,
    );
    final savedBadgeText = '$savedCount Saved';

    return Column(
      children: [
        Row(
          children: [
            // 1. Premium Subscription
            Expanded(
              child: _RewardAnimatedCard(
                title: 'Premium Plan',
                subtitle: 'Unlock Contacts & Chat',
                badgeText: planBadgeText,
                badgeGradient: isPaidPlan
                    ? const LinearGradient(
                        colors: [AppColors.amber600, AppColors.orangeAmber700],
                      )
                    : null,
                badgeTextColor:
                    isPaidPlan ? Colors.white : AppColors.neutral700,
                icon: Icons.star_rounded,
                brandColor: AppColors.categoryVipDark,
                isLivePulsing: true,
                onTap: () =>
                    Navigator.pushNamed(context, AppRoutes.subscription),
              ),
            ),
            SizedBox(width: 3.w),

            // 2. Who Viewed Me
            Expanded(
              child: _RewardAnimatedCard(
                title: 'Who Viewed Me',
                subtitle: 'Profile Visitors',
                badgeText: viewsBadgeText,
                badgeGradient: const LinearGradient(
                  colors: [AppColors.materialBlueDark, AppColors.lightBlue400],
                ),
                badgeTextColor: Colors.white,
                icon: Icons.visibility_rounded,
                brandColor: AppColors.materialBlueDark,
                isLivePulsing: true,
                onTap: () =>
                    Navigator.pushNamed(context, AppRoutes.whoViewedMe),
              ),
            ),
          ],
        ),
        SizedBox(height: 1.5.h),
        Row(
          children: [
            // 3. Trust Score & Verification
            Expanded(
              child: _RewardAnimatedCard(
                title: 'Trust Score',
                subtitle: 'Verification Badge',
                badgeText: trustBadgeText,
                badgeGradient: const LinearGradient(
                  colors: [AppColors.success, AppColors.successDark],
                ),
                badgeTextColor: Colors.white,
                icon: Icons.verified_user_rounded,
                brandColor: AppColors.success,
                isLivePulsing: true,
                onTap: () =>
                    Navigator.pushNamed(context, AppRoutes.trustScore),
              ),
            ),
            SizedBox(width: 3.w),

            // 4. Saved Profiles
            Expanded(
              child: _RewardAnimatedCard(
                title: 'Saved Profiles',
                subtitle: 'Bookmarked Candidates',
                badgeText: savedBadgeText,
                badgeGradient: const LinearGradient(
                  colors: [AppColors.materialPurpleDark, AppColors.purple300],
                ),
                badgeTextColor: Colors.white,
                icon: Icons.bookmark_rounded,
                brandColor: AppColors.materialPurple,
                isLivePulsing: true,
                onTap: () =>
                    Navigator.pushNamed(context, AppRoutes.savedProfiles),
              ),
            ),
          ],
        ),
      ],
    );
  }

  // 🛡️ Social Proof (Vouches) Hero Section (New)
  Widget _buildSocialProofVouchesSection(
      ThemeData theme, ProfileModel? profile) {
    if (profile == null) return const SizedBox.shrink();

    final isTrusted = profile.isCommunityTrusted;
    final vouchCount = profile.vouchCount;
    final trustPercentage = ((vouchCount / 5) * 100).clamp(0, 100).toInt();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader(
          theme,
          '🛡️ Social Proof (Vouches)',
          'Get verified relatives to vouch for you & earn the Trust badge',
        ),
        SizedBox(height: 1.2.h),
        _TactileMenuCard(
          onTap: () => VouchShareModal.show(context, profile),
          child: Container(
            width: double.infinity,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              gradient: const LinearGradient(
                colors: [
                  AppColors.greenDeepForest,
                  AppColors.greenDeepForest,
                  AppColors.emerald,
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              border: Border.all(
                color: AppColors.greenBright.withValues(alpha: AppColors.opacity35),
                width: 1.2,
              ),
              boxShadow: [
                BoxShadow(
                  color: AppColors.greenDeepForest.withValues(alpha: AppColors.opacity35),
                  blurRadius: 14,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            padding: EdgeInsets.all(4.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top Header Row: Icon, Title & Status Badge
                Row(
                  children: [
                    Container(
                      padding: EdgeInsets.all(2.5.w),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: AppColors.opacity15),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.verified_user_rounded,
                        color: AppColors.greenBright,
                        size: 22,
                      ),
                    ),
                    SizedBox(width: 3.w),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Community Vouches',
                                style: TextStyle(
                                  fontSize: AppTypography.bodyLarge,
                                  fontWeight: AppTypography.bold,
                                  color: Colors.white,
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 3),
                                decoration: BoxDecoration(
                                  color: isTrusted
                                      ? AppColors.categoryVip
                                      : AppColors.greenBright
                                          .withValues(alpha: 0.22),
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(
                                    color: isTrusted
                                        ? AppColors.categoryVip
                                        : AppColors.greenBright,
                                    width: 0.8,
                                  ),
                                ),
                                child: Text(
                                  isTrusted
                                      ? '👑 TRUSTED'
                                      : '$vouchCount/5 VOUCHES',
                                  style: TextStyle(
                                    color: isTrusted
                                        ? AppColors.canvasDark
                                        : AppColors.greenBright,
                                    fontSize: AppTypography.labelTiny,
                                    fontWeight: AppTypography.black,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 0.3.h),
                          Text(
                            isTrusted
                                ? '🎉 You have earned the Community Trusted badge!'
                                : 'Get 5 vouches to earn the "Community Trusted" badge.',
                            style: TextStyle(
                              fontSize: AppTypography.labelSmall,
                              color: Colors.white.withValues(alpha: AppColors.opacity85),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 1.8.h),

                // Middle: Progress Indicator & Percent
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Trust Progress',
                      style: TextStyle(
                        fontSize: AppTypography.labelSmall,
                        fontWeight: AppTypography.semiBold,
                        color: Colors.white.withValues(alpha: AppColors.opacity80),
                      ),
                    ),
                    Text(
                      '$vouchCount of 5 Vouches ($trustPercentage%)',
                      style: TextStyle(
                        fontSize: AppTypography.labelSmall,
                        fontWeight: AppTypography.bold,
                        color: AppColors.greenBright,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 0.6.h),
                ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: LinearProgressIndicator(
                    value: (vouchCount / 5).clamp(0.0, 1.0),
                    minHeight: 6.5,
                    backgroundColor: Colors.white.withValues(alpha: AppColors.opacity15),
                    valueColor: const AlwaysStoppedAnimation<Color>(
                      AppColors.greenBright,
                    ),
                  ),
                ),
                SizedBox(height: 2.h),

                // Bottom Action Button: WhatsApp Vouch Invite
                SizedBox(
                  width: double.infinity,
                  height: 5.4.h,
                  child: ElevatedButton.icon(
                    onPressed: () =>
                        VouchShareModal.show(context, profile),
                    icon: const Icon(
                      FontAwesomeIcons.whatsapp,
                      color: Colors.white,
                      size: 17,
                    ),
                    label: Text(
                      AppLocalizations.of(context)?.inviteRelativesToVouch ??
                          'Invite Relatives to Vouch',
                      style: TextStyle(
                        fontWeight: AppTypography.extraBold,
                        fontSize: AppTypography.bodyMedium,
                        color: Colors.white,
                        letterSpacing: 0.3,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.whatsapp,
                      elevation: 3,
                      shadowColor:
                          AppColors.whatsapp.withValues(alpha: AppColors.opacity50),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // 🏛️ Community & Welfare Section (Melavas & BVS Trust with Animated Presentation)
  Widget _buildCommunityCards(ThemeData theme) {
    return Column(
      children: [
        // 🎟️ 1. Candidate Meets & Melavas
        _CommunityHeroCard(
          gradient: const LinearGradient(
            colors: [AppColors.canvasDeepDark, AppColors.deepIndigo, AppColors.materialPurpleDark],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          shadowColor: AppColors.deepIndigo,
          badgeText: '🎪 CANDIDATE MEETS • थेट मेळावा',
          badgeBg: AppColors.categoryVip.withValues(alpha: 0.22),
          badgeColor: AppColors.categoryVip,
          iconWidget: Container(
            padding: const EdgeInsets.all(2.0),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: AppColors.categoryVip,
                width: 1.8,
              ),
              boxShadow: [
                BoxShadow(
                  color: AppColors.categoryVip.withValues(alpha: AppColors.opacity35),
                  blurRadius: 8,
                  spreadRadius: 1,
                ),
              ],
            ),
            child: const ClipOval(
              child: AppLogoImage(
                width: 34,
                height: 34,
                fit: BoxFit.cover,
              ),
            ),
          ),
          title: 'Vadhu-Var Melava Events',
          subtitle: 'Upcoming regional candidate gatherings & entry passes.',
          actionText: 'View Meets',
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const MelavaScreen()),
            );
          },
        ),
        SizedBox(height: 1.6.h),

        // 🏛️ 2. BVS Trust Community Gateway
        _CommunityHeroCard(
          gradient: const LinearGradient(
            colors: [AppColors.maroonDarkest, AppColors.wineDark, AppColors.crimsonDeep],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          shadowColor: AppColors.wineDark,
          badgeText: '🏛️ BVS TRUST • 50% SUBSIDY',
          badgeBg: AppColors.categoryVip.withValues(alpha: 0.22),
          badgeColor: AppColors.categoryVip,
          iconWidget: Container(
            padding: const EdgeInsets.all(2.0),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: AppColors.categoryVip,
                width: 1.8,
              ),
              boxShadow: [
                BoxShadow(
                  color: AppColors.categoryVip.withValues(alpha: AppColors.opacity35),
                  blurRadius: 8,
                  spreadRadius: 1,
                ),
              ],
            ),
            child: ClipOval(
              child: Image.asset(
                'assets/images/bvs_logo_gold.png',
                width: 34,
                height: 34,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => const Icon(
                  Icons.shield_rounded,
                  color: Colors.amberAccent,
                  size: 30,
                ),
              ),
            ),
          ),
          title: 'बणजारा विरासत संघ (BVS)',
          subtitle: 'Cardholders get Annual Matrimony Plan at ₹200 only.',
          actionText: 'Explore BVS',
          onTap: () => Navigator.pushNamed(context, AppRoutes.bvsGateway),
        ),
      ],
    );
  }

  // 🎁 Rewards & Success Stories (Refer & Earn, Found Partner with Live Animations)
  Widget _buildRewardsGrid(ThemeData theme) {
    return Row(
      children: [
        // 💰 Refer & Earn
        Expanded(
          child: _RewardAnimatedCard(
            title: 'Refer & Earn',
            subtitle: 'Cash & Free Passes',
            badgeText: '₹500 / Ref',
            badgeGradient: const LinearGradient(
              colors: [AppColors.materialPink, AppColors.materialPink],
            ),
            badgeTextColor: Colors.white,
            icon: Icons.card_giftcard_rounded,
            brandColor: AppColors.materialPink,
            isLivePulsing: true,
            onTap: () =>
                Navigator.pushNamed(context, AppRoutes.referralInvite),
          ),
        ),
        SizedBox(width: 3.w),

        // 💍 Found Partner
        Expanded(
          child: _RewardAnimatedCard(
            title: 'Found Partner',
            subtitle: 'Claim Gift Package',
            badgeText: '🎁 Free Kit',
            badgeGradient: const LinearGradient(
              colors: [AppColors.materialPurpleDark, AppColors.purple300],
            ),
            badgeTextColor: Colors.white,
            icon: Icons.favorite_rounded,
            brandColor: AppColors.materialPurple,
            isLivePulsing: true,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const MarriageRewardFormScreen(),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  // 💬 Official Channels (WhatsApp & Instagram with Original Icons & Live Animations)
  Widget _buildOfficialChannels(ThemeData theme) {
    return Row(
      children: [
        // 🟢 WhatsApp Direct Help
        Expanded(
          child: _OfficialChannelAnimatedCard(
            title: 'WhatsApp Help',
            subtitle: '8186050406',
            iconAsset: 'assets/icons/whatsapp_icon.png',
            badgeText: 'Online',
            brandColor: AppColors.whatsapp,
            isLivePulsing: true,
            onTap: () => _launchUrlExternal('https://wa.me/8186050406'),
          ),
        ),
        SizedBox(width: 3.w),

        // 📸 Instagram Community Channel
        Expanded(
          child: _OfficialChannelAnimatedCard(
            title: 'Community',
            subtitle: '@banjarabio',
            iconAsset: 'assets/icons/instagram_icon.png',
            badgeText: '🌟 10K+',
            badgeGradient: const LinearGradient(
              colors: [
                AppColors.instagramPurple,
                AppColors.deepOrange600,
                AppColors.warningDark,
              ],
            ),
            badgeTextColor: Colors.white,
            brandColor: AppColors.roseBlushAccent,
            onTap: () => _launchUrlExternal(
                'https://www.instagram.com/banjarabio.matrimony/'),
          ),
        ),
      ],
    );
  }

  // 🌟 Community Trust & Impact Grid (2x2 with Live Animations & Gradient Badges)
  Widget _buildCommunityTrustImpactGrid(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader(
          theme,
          '🌟 Community Trust & Impact',
          'Verified community metrics & matrimony success milestones',
        ),
        SizedBox(height: 1.2.h),
        Column(
          children: [
            Row(
              children: [
                // 1. 1,200+ Successful Marriages
                Expanded(
                  child: _RewardAnimatedCard(
                    title: '1,200+ Marriages',
                    subtitle: 'Happy Banjara Couples',
                    badgeText: '💍 Success',
                    badgeGradient: const LinearGradient(
                      colors: [AppColors.materialPink, AppColors.materialPink],
                    ),
                    badgeTextColor: Colors.white,
                    icon: Icons.favorite_rounded,
                    brandColor: AppColors.materialPink,
                    isLivePulsing: true,
                    onTap: () {
                      Fluttertoast.showToast(
                        msg: '💍 Over 1,200+ Banjara marriages celebrated!',
                        toastLength: Toast.LENGTH_SHORT,
                      );
                    },
                  ),
                ),
                SizedBox(width: 3.w),

                // 2. 25,000+ Verified Profiles
                Expanded(
                  child: _RewardAnimatedCard(
                    title: '25,000+ Profiles',
                    subtitle: 'Active Candidates',
                    badgeText: '👥 Community',
                    badgeGradient: const LinearGradient(
                      colors: [AppColors.materialBlueDark, AppColors.lightBlue400],
                    ),
                    badgeTextColor: Colors.white,
                    icon: Icons.people_alt_rounded,
                    brandColor: AppColors.materialBlueDark,
                    isLivePulsing: true,
                    onTap: () {
                      Fluttertoast.showToast(
                        msg: '👥 Largest verified Banjara matrimony network',
                        toastLength: Toast.LENGTH_SHORT,
                      );
                    },
                  ),
                ),
              ],
            ),
            SizedBox(height: 1.5.h),
            Row(
              children: [
                // 3. 100% Gotra Compatibility Check
                Expanded(
                  child: _RewardAnimatedCard(
                    title: '100% Compatible',
                    subtitle: 'Gotra & Lineage Check',
                    badgeText: '🛡️ Verified',
                    badgeGradient: const LinearGradient(
                      colors: [AppColors.success, AppColors.successDark],
                    ),
                    badgeTextColor: Colors.white,
                    icon: Icons.verified_user_rounded,
                    brandColor: AppColors.success,
                    isLivePulsing: true,
                    onTap: () {
                      Fluttertoast.showToast(
                        msg: '🛡️ 100% traditional Gotra exogamy verified',
                        toastLength: Toast.LENGTH_SHORT,
                      );
                    },
                  ),
                ),
                SizedBox(width: 3.w),

                // 4. 4.8 / 5.0 Star Rating
                Expanded(
                  child: _RewardAnimatedCard(
                    title: '4.8 / 5.0 Rating',
                    subtitle: 'Loved by Families',
                    badgeText: '⭐ Top Rated',
                    badgeGradient: const LinearGradient(
                      colors: [AppColors.deepOrange, AppColors.categoryVipDark],
                    ),
                    badgeTextColor: Colors.white,
                    icon: Icons.star_rounded,
                    brandColor: AppColors.categoryVipDark,
                    isLivePulsing: true,
                    onTap: () => _launchUrlExternal(
                        'https://play.google.com/store/apps/details?id=com.avishio.banjarabio'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }



  Widget _buildAnimatedItem({required int index, required Widget child}) {
    final start = (index * 0.1).clamp(0.0, 1.0);
    final end = (0.6 + (index * 0.1)).clamp(0.0, 1.0);

    return SlideTransition(
      position: Tween<Offset>(begin: const Offset(0, 0.2), end: Offset.zero)
          .animate(CurvedAnimation(
              parent: _controller,
              curve: Interval(start, end, curve: Curves.easeOutCubic))),
      child: FadeTransition(
        opacity: Tween<double>(begin: 0.0, end: 1.0).animate(CurvedAnimation(
            parent: _controller,
            curve: Interval(start, end, curve: Curves.easeOut))),
        child: child,
      ),
    );
  }

  Widget _buildProfileHeader(
      BuildContext context, ThemeData theme, ProfileModel profile) {
    final subscriptionAsync = ref.watch(ownSubscriptionProvider);
    return _MenuProfileCard(
      profile: profile,
      subscription: subscriptionAsync.asData?.value,
      onTap: () => Navigator.pushNamed(context, AppRoutes.myProfile),
    );
  }

  Widget _buildGuestHeader(ThemeData theme) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: theme.colorScheme.primary.withValues(alpha: AppColors.opacity8),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.primary.withValues(alpha: 0.04),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.all(4.w),
        child: Column(
          children: [
            Container(
              padding: EdgeInsets.all(3.w),
              decoration: BoxDecoration(
                color: theme.colorScheme.primary.withValues(alpha: AppColors.opacity8),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.person_outline_rounded,
                color: theme.colorScheme.primary,
                size: 28.sp,
              ),
            ),
            SizedBox(height: 1.5.h),
            Text(
              'Join BanjaraBio Matrimony',
              style: TextStyle(
                fontWeight: AppTypography.bold,
                fontSize: AppTypography.bodyLarge,
                color: theme.colorScheme.onSurface,
              ),
            ),
            SizedBox(height: 0.5.h),
            Text(
              'Create your profile to find verified matches',
              style: TextStyle(
                color: theme.colorScheme.onSurface.withValues(alpha: AppColors.opacity60),
                fontSize: AppTypography.bodySmall,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 2.h),
            ElevatedButton(
              onPressed: () =>
                  Navigator.pushNamed(context, AppRoutes.authentication),
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 48),
                backgroundColor: theme.colorScheme.primary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: Text(
                'Login or Register',
                style: TextStyle(
                  fontSize: AppTypography.bodyMedium,
                  fontWeight: AppTypography.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderShimmer(ThemeData theme) {
    return Container(
      width: double.infinity,
      height: 18.h,
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: theme.colorScheme.primary.withValues(alpha: 0.04),
          width: 1.5,
        ),
      ),
      child: Padding(
        padding: EdgeInsets.all(4.w),
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  width: 14.w,
                  height: 14.w,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.onSurface.withValues(alpha: AppColors.opacity5),
                    shape: BoxShape.circle,
                  ),
                ),
                SizedBox(width: 4.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 40.w,
                        height: 2.h,
                        color:
                            theme.colorScheme.onSurface.withValues(alpha: AppColors.opacity5),
                      ),
                      SizedBox(height: 1.h),
                      Container(
                        width: 25.w,
                        height: 1.5.h,
                        color:
                            theme.colorScheme.onSurface.withValues(alpha: AppColors.opacity5),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const Spacer(),
            Container(
              width: double.infinity,
              height: 1.h,
              color: theme.colorScheme.onSurface.withValues(alpha: AppColors.opacity5),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLogoutButton(BuildContext context, ThemeData theme) {
    return _TactileMenuCard(
      onTap: () => _handleLogout(context),
      child: Container(
        width: double.infinity,
        height: 5.8.h,
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: theme.colorScheme.primary.withValues(alpha: AppColors.opacity35),
            width: 1.2,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.02),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.logout_rounded, color: theme.colorScheme.primary, size: 20),
            SizedBox(width: 2.w),
            Text(
              AppLocalizations.of(context)?.logout ?? 'Logout',
              style: TextStyle(
                color: theme.colorScheme.primary,
                fontWeight: AppTypography.bold,
                fontSize: AppTypography.bodyMedium,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _handleLogout(BuildContext context) async {
    final l10n = AppLocalizations.of(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: Text(
          'Logout Confirmation',
          style: TextStyle(
            fontSize: AppTypography.headingSmall,
            fontWeight: AppTypography.bold,
          ),
        ),
        content: Text(
          'Are you sure you want to log out of your account?',
          style: TextStyle(fontSize: AppTypography.bodyMedium),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(
              l10n?.cancel ?? 'Cancel',
              style: TextStyle(fontSize: AppTypography.bodySmall),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.primary,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(
              l10n?.logout ?? 'Logout',
              style: TextStyle(
                color: Colors.white,
                fontWeight: AppTypography.bold,
                fontSize: AppTypography.bodySmall,
              ),
            ),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      try {
        await _authRepository.signOut();
        ref.invalidate(ownProfileProvider);
        if (context.mounted) {
          Navigator.pushNamedAndRemoveUntil(
            context,
            AppRoutes.userTypeSelection,
            (route) => false,
          );
        }
      } catch (e) {
        if (context.mounted) {
          Fluttertoast.showToast(
            msg: 'Failed to logout. Please try again.',
            toastLength: Toast.LENGTH_LONG,
          );
        }
      }
    }
  }
}

/// 🎁 Animated Reward & Success Story Card (Refer & Earn, Found Partner)
class _RewardAnimatedCard extends StatefulWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final String badgeText;
  final Gradient? badgeGradient;
  final Color? badgeTextColor;
  final Color brandColor;
  final bool isLivePulsing;
  final VoidCallback onTap;

  const _RewardAnimatedCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.badgeText,
    this.badgeGradient,
    this.badgeTextColor,
    required this.brandColor,
    this.isLivePulsing = false,
    required this.onTap,
  });

  @override
  State<_RewardAnimatedCard> createState() => _RewardAnimatedCardState();
}

class _RewardAnimatedCardState extends State<_RewardAnimatedCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 0.92, end: 1.08).animate(
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
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return _TactileMenuCard(
      onTap: widget.onTap,
      child: Container(
        padding: EdgeInsets.all(3.6.w),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: widget.brandColor.withValues(alpha: isDark ? 0.35 : 0.22),
            width: 1.2,
          ),
          boxShadow: [
            BoxShadow(
              color: widget.brandColor.withValues(alpha: isDark ? 0.15 : 0.08),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.02),
              blurRadius: 4,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Row: Animated Icon Container & Badge
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                AnimatedBuilder(
                  animation: _pulseAnimation,
                  builder: (context, child) {
                    return Transform.scale(
                      scale: widget.isLivePulsing ? _pulseAnimation.value : 1.0,
                      child: Container(
                        width: 38,
                        height: 38,
                        decoration: BoxDecoration(
                          color: widget.brandColor.withValues(alpha: AppColors.opacity12),
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: widget.brandColor.withValues(alpha: AppColors.opacity25),
                          ),
                        ),
                        child: Icon(
                          widget.icon,
                          color: widget.brandColor,
                          size: 20,
                        ),
                      ),
                    );
                  },
                ),

                // Badge Container
                if (widget.badgeGradient != null)
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 7, vertical: 3),
                    decoration: BoxDecoration(
                      gradient: widget.badgeGradient,
                      borderRadius: BorderRadius.circular(8),
                      boxShadow: [
                        BoxShadow(
                          color: widget.brandColor.withValues(alpha: AppColors.opacity30),
                          blurRadius: 4,
                          offset: const Offset(0, 1),
                        ),
                      ],
                    ),
                    child: Text(
                      widget.badgeText,
                      style: TextStyle(
                        color: widget.badgeTextColor ?? Colors.white,
                        fontSize: AppTypography.labelTiny,
                        fontWeight: AppTypography.extraBold,
                      ),
                    ),
                  )
                else
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 7, vertical: 3),
                    decoration: BoxDecoration(
                      color: widget.brandColor.withValues(alpha: AppColors.opacity12),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: widget.brandColor.withValues(alpha: AppColors.opacity30),
                        width: 0.8,
                      ),
                    ),
                    child: Text(
                      widget.badgeText,
                      style: TextStyle(
                        color: widget.brandColor,
                        fontSize: AppTypography.labelTiny,
                        fontWeight: AppTypography.extraBold,
                      ),
                    ),
                  ),
              ],
            ),
            SizedBox(height: 1.4.h),

            // Title & Navigation Arrow
            Row(
              children: [
                Expanded(
                  child: Text(
                    widget.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: AppTypography.bodyMedium,
                      fontWeight: AppTypography.bold,
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 11,
                  color: widget.brandColor.withValues(alpha: AppColors.opacity70),
                ),
              ],
            ),
            SizedBox(height: 0.3.h),

            // Subtitle
            Text(
              widget.subtitle,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: AppTypography.labelSmall,
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// 🌟 Animated Official Channel Card (WhatsApp & Instagram)
class _OfficialChannelAnimatedCard extends StatefulWidget {
  final String title;
  final String subtitle;
  final String iconAsset;
  final String badgeText;
  final Gradient? badgeGradient;
  final Color? badgeTextColor;
  final Color brandColor;
  final bool isLivePulsing;
  final VoidCallback onTap;

  const _OfficialChannelAnimatedCard({
    required this.title,
    required this.subtitle,
    required this.iconAsset,
    required this.badgeText,
    this.badgeGradient,
    this.badgeTextColor,
    required this.brandColor,
    this.isLivePulsing = false,
    required this.onTap,
  });

  @override
  State<_OfficialChannelAnimatedCard> createState() =>
      _OfficialChannelAnimatedCardState();
}

class _OfficialChannelAnimatedCardState
    extends State<_OfficialChannelAnimatedCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1600),
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 0.88, end: 1.15).animate(
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
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return _TactileMenuCard(
      onTap: widget.onTap,
      child: Container(
        padding: EdgeInsets.all(3.6.w),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: widget.brandColor.withValues(alpha: isDark ? 0.35 : 0.22),
            width: 1.2,
          ),
          boxShadow: [
            BoxShadow(
              color: widget.brandColor.withValues(alpha: isDark ? 0.15 : 0.08),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.02),
              blurRadius: 4,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Row: Original App Icon with Ambient Glow & Animated Badge
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Original App Icon Container with Glow
                Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: widget.brandColor.withValues(alpha: AppColors.opacity10),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: widget.brandColor.withValues(alpha: AppColors.opacity25),
                    ),
                  ),
                  padding: const EdgeInsets.all(7),
                  child: Image.asset(
                    widget.iconAsset,
                    width: 24,
                    height: 24,
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) => Icon(
                      Icons.chat_rounded,
                      color: widget.brandColor,
                      size: 20,
                    ),
                  ),
                ),

                // Animated Badge (e.g. Pulsing Online or Instagram 10K+)
                if (widget.isLivePulsing)
                  Flexible(
                    child: AnimatedBuilder(
                      animation: _pulseAnimation,
                      builder: (context, child) {
                        return Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 7, vertical: 3),
                          decoration: BoxDecoration(
                            color: AppColors.greenLightBg,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color:
                                  AppColors.successDark.withValues(alpha: AppColors.opacity40),
                              width: 0.8,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Transform.scale(
                                scale: _pulseAnimation.value,
                                child: Container(
                                  width: 6,
                                  height: 6,
                                  decoration: BoxDecoration(
                                    color: AppColors.success,
                                    shape: BoxShape.circle,
                                    boxShadow: [
                                      BoxShadow(
                                        color: AppColors.successDark
                                            .withValues(alpha: AppColors.opacity60),
                                        blurRadius: 4,
                                        spreadRadius: 1,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              const SizedBox(width: 4),
                              Flexible(
                                child: Text(
                                  widget.badgeText,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    color: AppColors.success,
                                    fontSize: AppTypography.labelTiny,
                                    fontWeight: AppTypography.extraBold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  )
                else
                  Flexible(
                    child: Container(
                      padding:
                          const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                      decoration: BoxDecoration(
                        gradient: widget.badgeGradient,
                        color: widget.badgeGradient == null
                            ? AppColors.rose100
                            : null,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        widget.badgeText,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: widget.badgeTextColor ?? AppColors.materialPink700,
                          fontSize: AppTypography.labelTiny,
                          fontWeight: AppTypography.extraBold,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            SizedBox(height: 1.4.h),

            // Title & Navigation Arrow
            Row(
              children: [
                Expanded(
                  child: Text(
                    widget.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: AppTypography.bodyMedium,
                      fontWeight: AppTypography.bold,
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 11,
                  color: widget.brandColor.withValues(alpha: AppColors.opacity70),
                ),
              ],
            ),
            SizedBox(height: 0.3.h),

            // Subtitle
            Text(
              widget.subtitle,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: AppTypography.labelSmall,
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// 🎯 Tactile Micro-Interactive Card with Spring Physics on Tap
class _TactileMenuCard extends StatelessWidget {
  final Widget child;
  final VoidCallback onTap;

  const _TactileMenuCard({required this.child, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return TactilePressable(
      onTap: onTap,
      pressedScale: 0.965,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(18),
          onTap: onTap,
          child: child,
        ),
      ),
    );
  }
}

/// 🌟 PREMIUM ANIMATED MENU PROFILE CARD
class _MenuProfileCard extends StatefulWidget {
  final ProfileModel profile;
  final VoidCallback onTap;
  final SubscriptionModel? subscription;

  const _MenuProfileCard({
    required this.profile,
    required this.onTap,
    this.subscription,
  });

  @override
  State<_MenuProfileCard> createState() => _MenuProfileCardState();
}

class _MenuProfileCardState extends State<_MenuProfileCard>
    with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late AnimationController _progressController;
  late Animation<double> _progressAnimation;
  late Animation<double> _pulseAnimation;
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2400),
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 0.96, end: 1.04).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _progressController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    final targetProgress =
        (widget.profile.completionPercentage / 100.0).clamp(0.0, 1.0);
    _progressAnimation = Tween<double>(begin: 0.0, end: targetProgress).animate(
      CurvedAnimation(parent: _progressController, curve: Curves.easeOutCubic),
    );

    _progressController.forward();
  }

  @override
  void didUpdateWidget(covariant _MenuProfileCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.profile.completionPercentage !=
        widget.profile.completionPercentage) {
      final targetProgress =
          (widget.profile.completionPercentage / 100.0).clamp(0.0, 1.0);
      _progressAnimation = Tween<double>(
        begin: _progressAnimation.value,
        end: targetProgress,
      ).animate(
        CurvedAnimation(parent: _progressController, curve: Curves.easeOutCubic),
      );
      _progressController.forward(from: 0.0);
    }
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _progressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final primaryPhoto = widget.profile.photos.isNotEmpty
        ? widget.profile.photos.first.publicUrl
        : null;
    final isComplete = widget.profile.completionPercentage >= 100;
    final isPremium = widget.subscription?.planType.isPaidPlan ?? false;
    final planDisplayName = isPremium
        ? widget.subscription!.planType.displayName.toUpperCase()
        : 'FREE USER';

    return AnimatedScale(
      scale: _isPressed ? 0.98 : 1.0,
      duration: const Duration(milliseconds: 120),
      curve: Curves.easeOutCubic,
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(22),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: isDark
                ? [
                    theme.cardColor,
                    AppColors.surfaceDark28,
                  ]
                : [
                    theme.cardColor,
                    theme.cardColor.withValues(alpha: 0.96),
                  ],
          ),
          border: Border.all(
            color: isComplete
                ? AppColors.categoryLocation.withValues(alpha: AppColors.opacity35)
                : theme.colorScheme.primary.withValues(alpha: AppColors.opacity20),
            width: 1.2,
          ),
          boxShadow: [
            BoxShadow(
              color: isDark
                  ? Colors.black.withValues(alpha: AppColors.opacity30)
                  : theme.colorScheme.primary.withValues(alpha: 0.07),
              blurRadius: 18,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(22),
          child: Stack(
            children: [
              Positioned(
                top: -24,
                right: -24,
                child: Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        (isComplete
                                ? AppColors.categoryLocation
                                : theme.colorScheme.primary)
                            .withValues(alpha: isDark ? 0.2 : 0.08),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
              ),
              Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: widget.onTap,
                  onTapDown: (_) => setState(() => _isPressed = true),
                  onTapUp: (_) => setState(() => _isPressed = false),
                  onTapCancel: () => setState(() => _isPressed = false),
                  borderRadius: BorderRadius.circular(22),
                  splashColor:
                      theme.colorScheme.primary.withValues(alpha: AppColors.opacity8),
                  highlightColor: Colors.transparent,
                  child: Padding(
                    padding:
                        EdgeInsets.symmetric(horizontal: 3.5.w, vertical: 1.5.h),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            AnimatedBuilder(
                              animation: _pulseController,
                              builder: (context, child) {
                                return Stack(
                                  clipBehavior: Clip.none,
                                  alignment: Alignment.center,
                                  children: [
                                    Container(
                                      width: 14.5.w,
                                      height: 14.5.w,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        gradient: SweepGradient(
                                          colors: [
                                            AppColors.categoryVip,
                                            theme.colorScheme.primary,
                                            isComplete
                                                ? AppColors.categoryLocation
                                                : AppColors.orangeAmber700,
                                            AppColors.categoryVip,
                                          ],
                                          transform: GradientRotation(
                                              _pulseController.value * 6.28),
                                        ),
                                        boxShadow: [
                                          BoxShadow(
                                            color: (isComplete
                                                    ? AppColors.categoryLocation
                                                    : theme.colorScheme.primary)
                                                .withValues(
                                                    alpha: 0.25 *
                                                        _pulseAnimation.value),
                                            blurRadius: 8,
                                            spreadRadius: 1,
                                          ),
                                        ],
                                      ),
                                    ),
                                    Container(
                                      width: 13.w,
                                      height: 13.w,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: theme.scaffoldBackgroundColor,
                                        border: Border.all(
                                          color: theme.cardColor,
                                          width: 2.0,
                                        ),
                                      ),
                                      child: ClipOval(
                                        child: CustomImageWidget(
                                          imageUrl: primaryPhoto,
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                    ),
                                    if (widget.profile.isVerified)
                                      Positioned(
                                        bottom: -1,
                                        right: -1,
                                        child: Container(
                                          padding: const EdgeInsets.all(2.5),
                                          decoration: BoxDecoration(
                                            color: AppColors.categoryLocation,
                                            shape: BoxShape.circle,
                                            border: Border.all(
                                              color: theme.cardColor,
                                              width: 1.5,
                                            ),
                                            boxShadow: [
                                              BoxShadow(
                                                color: AppColors.categoryLocation
                                                    .withValues(alpha: AppColors.opacity40),
                                                blurRadius: 4,
                                              ),
                                            ],
                                          ),
                                          child: const Icon(
                                            Icons.check_rounded,
                                            color: Colors.white,
                                            size: 9,
                                          ),
                                        ),
                                      ),
                                  ],
                                );
                              },
                            ),
                            SizedBox(width: 3.w),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Flexible(
                                        child: Text(
                                          [
                                            widget.profile.fullName,
                                            if (widget.profile.gotra != null &&
                                                widget.profile.gotra!.isNotEmpty)
                                              '- ${widget.profile.gotra}',
                                          ].join(' '),
                                          style: TextStyle(
                                            fontWeight: AppTypography.black,
                                            fontSize: AppTypography.bodyLarge,
                                            color: theme.colorScheme.onSurface,
                                            letterSpacing: -0.2,
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                      if (widget.profile.isVerified) ...[
                                        SizedBox(width: 1.5.w),
                                        const Icon(
                                          Icons.verified_rounded,
                                          color: AppColors.categoryLocation,
                                          size: 16,
                                        ),
                                      ],
                                    ],
                                  ),
                                  SizedBox(height: 0.3.h),
                                  Wrap(
                                    spacing: 2.w,
                                    runSpacing: 0.3.h,
                                    crossAxisAlignment: WrapCrossAlignment.center,
                                    children: [
                                      InkWell(
                                        onTap: () {
                                          Clipboard.setData(ClipboardData(
                                              text: widget.profile.displayId));
                                          Fluttertoast.showToast(
                                            msg:
                                                'Profile ID copied: ${widget.profile.displayId}',
                                            toastLength: Toast.LENGTH_SHORT,
                                            gravity: ToastGravity.BOTTOM,
                                          );
                                        },
                                        borderRadius: BorderRadius.circular(6),
                                        child: Container(
                                          padding: EdgeInsets.symmetric(
                                              horizontal: 1.8.w,
                                              vertical: 0.2.h),
                                          decoration: BoxDecoration(
                                            color: theme.colorScheme.primary
                                                .withValues(alpha: AppColors.opacity8),
                                            borderRadius:
                                                BorderRadius.circular(6),
                                            border: Border.all(
                                              color: theme.colorScheme.primary
                                                  .withValues(alpha: AppColors.opacity20),
                                              width: 0.8,
                                            ),
                                          ),
                                          child: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Text(
                                                widget.profile.displayId,
                                                style: TextStyle(
                                                  fontWeight: AppTypography.bold,
                                                  fontSize: AppTypography.labelTiny,
                                                  color: theme
                                                      .colorScheme.primary,
                                                ),
                                              ),
                                              SizedBox(width: 1.w),
                                              Icon(
                                                Icons.copy_rounded,
                                                size: 10,
                                                color:
                                                    theme.colorScheme.primary,
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                      Container(
                                        padding: EdgeInsets.symmetric(
                                            horizontal: 1.8.w,
                                            vertical: 0.2.h),
                                        decoration: BoxDecoration(
                                          gradient: isPremium
                                              ? const LinearGradient(
                                                  colors: [
                                                    AppColors.amber600,
                                                    AppColors.orangeAmber700
                                                  ],
                                                )
                                              : null,
                                          color: isPremium
                                              ? null
                                              : AppColors.neutral100,
                                          borderRadius:
                                              BorderRadius.circular(6),
                                          border: isPremium
                                              ? null
                                              : Border.all(
                                                  color: Colors.grey
                                                      .withValues(alpha: AppColors.opacity30),
                                                  width: 0.8,
                                                ),
                                        ),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            if (isPremium) ...[
                                              const Icon(Icons.star_rounded,
                                                  color: Colors.white,
                                                  size: 11),
                                              SizedBox(width: 0.8.w),
                                            ],
                                            Text(
                                              isPremium
                                                  ? planDisplayName
                                                  : 'FREE USER',
                                              style: TextStyle(
                                                color: isPremium
                                                    ? Colors.white
                                                    : AppColors.neutral700,
                                                fontWeight: AppTypography.extraBold,
                                                fontSize: AppTypography.labelTiny,
                                                letterSpacing: 0.2,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              padding: EdgeInsets.all(2.w),
                              decoration: BoxDecoration(
                                color: theme.colorScheme.primary
                                    .withValues(alpha: AppColors.opacity8),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                Icons.arrow_forward_ios_rounded,
                                size: 14,
                                color: theme.colorScheme.primary,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 1.5.h),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              isComplete
                                  ? '🎉 Profile 100% Completed'
                                  : 'Profile Completion',
                              style: TextStyle(
                                fontSize: AppTypography.labelSmall,
                                fontWeight: AppTypography.bold,
                                color: isComplete
                                    ? AppColors.categoryLocation
                                    : theme.colorScheme.onSurfaceVariant,
                              ),
                            ),
                            Text(
                              '${widget.profile.completionPercentage}%',
                              style: TextStyle(
                                fontSize: AppTypography.labelSmall,
                                fontWeight: AppTypography.black,
                                color: isComplete
                                    ? AppColors.categoryLocation
                                    : theme.colorScheme.primary,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 0.6.h),
                        AnimatedBuilder(
                          animation: _progressAnimation,
                          builder: (context, child) {
                            return ClipRRect(
                              borderRadius: BorderRadius.circular(6),
                              child: LinearProgressIndicator(
                                value: _progressAnimation.value,
                                minHeight: 6,
                                backgroundColor: isDark
                                    ? Colors.white10
                                    : Colors.black.withValues(alpha: 0.06),
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  isComplete
                                      ? AppColors.categoryLocation
                                      : theme.colorScheme.primary,
                                ),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
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

/// 🏛️ Premium Animated Hero Card for Community & Welfare Initiatives
class _CommunityHeroCard extends StatefulWidget {
  final Gradient gradient;
  final Color shadowColor;
  final String badgeText;
  final Color badgeBg;
  final Color badgeColor;
  final Widget? iconWidget;
  final String title;
  final String subtitle;
  final String actionText;
  final VoidCallback onTap;

  const _CommunityHeroCard({
    required this.gradient,
    required this.shadowColor,
    required this.badgeText,
    required this.badgeBg,
    required this.badgeColor,
    this.iconWidget,
    required this.title,
    required this.subtitle,
    required this.actionText,
    required this.onTap,
  });

  @override
  State<_CommunityHeroCard> createState() => _CommunityHeroCardState();
}

class _CommunityHeroCardState extends State<_CommunityHeroCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 0.94, end: 1.06).animate(
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
    return _TactileMenuCard(
      onTap: widget.onTap,
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(22),
          gradient: widget.gradient,
          border: Border.all(
            color: AppColors.categoryVip.withValues(alpha: 0.38),
            width: 1.2,
          ),
          boxShadow: [
            BoxShadow(
              color: widget.shadowColor.withValues(alpha: AppColors.opacity40),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(22),
          child: Stack(
            children: [
              // Subtle Decorative Watermark Circles
              Positioned(
                right: -20,
                top: -20,
                child: Container(
                  width: 90,
                  height: 90,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withValues(alpha: 0.04),
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.all(4.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ── 1st Row: Left: Icon / Emblem | Right: Title ──
                    Row(
                      children: [
                        AnimatedBuilder(
                          animation: _pulseAnimation,
                          builder: (context, child) {
                            return Transform.scale(
                              scale: _pulseAnimation.value,
                              child: widget.iconWidget ??
                                  Container(
                                    padding: EdgeInsets.all(2.5.w),
                                    decoration: BoxDecoration(
                                      color:
                                          Colors.white.withValues(alpha: 0.16),
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                        color: AppColors.categoryVip
                                            .withValues(alpha: AppColors.opacity35),
                                      ),
                                    ),
                                    child: const Icon(
                                      Icons.groups_rounded,
                                      color: Colors.white,
                                      size: 22,
                                    ),
                                  ),
                            );
                          },
                        ),
                        SizedBox(width: 3.w),
                        Expanded(
                          child: Text(
                            widget.title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: AppTypography.headingSmall,
                              fontWeight: AppTypography.black,
                              color: Colors.white,
                              letterSpacing: -0.2,
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 1.4.h),

                    // ── 2nd Row: Left: Badge | Right: Action Button ──
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Left: Badge Tag
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: widget.badgeBg,
                            borderRadius: BorderRadius.circular(7),
                            border: Border.all(
                              color: widget.badgeColor.withValues(alpha: 0.45),
                              width: 0.9,
                            ),
                          ),
                          child: Text(
                            widget.badgeText,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: widget.badgeColor,
                              fontSize: AppTypography.labelTiny,
                              fontWeight: AppTypography.black,
                              letterSpacing: 0.3,
                            ),
                          ),
                        ),

                        // Right: Golden Action Button
                        Container(
                          padding: EdgeInsets.symmetric(
                              horizontal: 3.2.w, vertical: 0.8.h),
                          decoration: BoxDecoration(
                            color: AppColors.categoryVip,
                            borderRadius: BorderRadius.circular(11),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: AppColors.opacity25),
                                blurRadius: 8,
                                offset: const Offset(0, 3),
                              ),
                            ],
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                widget.actionText,
                                style: TextStyle(
                                  color: AppColors.canvasRichDark,
                                  fontSize: AppTypography.labelSmall,
                                  fontWeight: AppTypography.black,
                                ),
                              ),
                              const SizedBox(width: 4),
                              const Icon(
                                Icons.arrow_forward_rounded,
                                size: 13,
                                color: AppColors.canvasRichDark,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 1.2.h),

                    // ── 3rd Row: Subtitle matching full width below ──
                    Text(
                      widget.subtitle,
                      style: TextStyle(
                        fontSize: AppTypography.labelSmall,
                        height: 1.35,
                        color: Colors.white.withValues(alpha: AppColors.opacity90),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
