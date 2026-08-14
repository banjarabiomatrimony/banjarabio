import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:banjarabio/l10n/app_localizations.dart';
import 'package:banjarabio/core/app_export.dart';
import 'package:banjarabio/core/utils/tour_keys.dart';
import 'package:banjarabio/core/models/daily_reward_model.dart';
import 'package:banjarabio/notification/features/notification_bridge.dart';
import 'package:banjarabio/widgets/daily_reward_dialog.dart';
import 'package:banjarabio/core/constants/app_typography.dart';

/// The gradient AppBar header containing location selector,
/// notification bell, social icons, search bar, and filter button.
class HomeFeedHeader extends StatelessWidget {
  final String locationLabel;
  final VoidCallback onLocationTap;
  final VoidCallback onFilterTap;
  final TextEditingController searchController;
  final ValueChanged<String> onSearchChanged;
  final VoidCallback onSearchClear;
  final int activeFilterCount;
  final DailyRewardModel? dailyRewardStatus;
  final ValueChanged<DailyRewardModel?> onRewardUpdated;

  const HomeFeedHeader({
    super.key,
    required this.locationLabel,
    required this.onLocationTap,
    required this.onFilterTap,
    required this.searchController,
    required this.onSearchChanged,
    required this.onSearchClear,
    required this.activeFilterCount,
    this.dailyRewardStatus,
    required this.onRewardUpdated,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SliverAppBar(
      floating: true,
      snap: true,
      automaticallyImplyLeading: false,
      backgroundColor: theme.appBarTheme.backgroundColor,
      expandedHeight: 8.h + MediaQuery.of(context).padding.top,
      elevation: 0,
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                theme.colorScheme.primary,
                theme.colorScheme.primary.withValues(alpha: 0.8),
              ],
            ),
            borderRadius: const BorderRadius.vertical(bottom: Radius.circular(32)),
            boxShadow: [
              BoxShadow(
                color: theme.colorScheme.primary.withValues(alpha: 0.2),
                blurRadius: 15,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          padding: EdgeInsets.fromLTRB(4.w, 0, 4.w, 0.2.h),
          child: SafeArea(
            child: SingleChildScrollView(
              physics: const NeverScrollableScrollPhysics(),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  _buildLocationRow(context, theme),
                  SizedBox(height: 0.5.h),
                  _buildSearchRow(context, theme),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLocationRow(BuildContext context, ThemeData theme) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 0.1.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Branding + Location Stack
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'BanjaraBio',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: AppTypography.headingSmall,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 0.8,
                  shadows: [
                    Shadow(
                      color: Colors.black.withValues(alpha: 0.2),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 0.4.h),
              InkWell(
                key: TourKeys.locationKey,
                onTap: onLocationTap,
                borderRadius: BorderRadius.circular(20),
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 2.5.w, vertical: 0.4.h),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.location_on_rounded, color: Colors.amberAccent, size: 12),
                      SizedBox(width: 1.w),
                      Text(
                        locationLabel,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: AppTypography.labelMedium,
                        ),
                      ),
                      SizedBox(width: 0.5.w),
                      const Icon(Icons.keyboard_arrow_down_rounded, color: Colors.white, size: 12),
                    ],
                  ),
                ),
              ),
            ],
          ),
          // Actions + Social Glass Capsules Row
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Pill 1: Core App Utilities (Reward, Notifications, Chat)
              Container(
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
                ),
                padding: EdgeInsets.symmetric(horizontal: 1.5.w, vertical: 0.2.h),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Daily Reward
                    if (dailyRewardStatus != null) ...[
                      InkWell(
                        onTap: () async {
                          final updatedStatus = await DailyRewardDialog.show(context, dailyRewardStatus!);
                          onRewardUpdated(updatedStatus);
                        },
                        borderRadius: BorderRadius.circular(20),
                        child: Padding(
                          padding: EdgeInsets.all(0.6.h),
                          child: Stack(
                            clipBehavior: Clip.none,
                            children: [
                              Icon(
                                Icons.card_giftcard_rounded,
                                color: dailyRewardStatus!.isClaimedToday ? Colors.white54 : Colors.amberAccent,
                                size: 20,
                              ),
                              if (!dailyRewardStatus!.isClaimedToday)
                                Positioned(
                                  right: -1,
                                  top: -1,
                                  child: Container(
                                    width: 6,
                                    height: 6,
                                    decoration: const BoxDecoration(color: Colors.redAccent, shape: BoxShape.circle),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(width: 1.w),
                    ],
                    // Notification Bell
                    ListenableBuilder(
                      listenable: NotificationBridge().historyStore,
                      builder: (context, _) {
                        final unreadCount = NotificationBridge().historyStore.unreadCount;
                        return InkWell(
                          onTap: () => Navigator.pushNamed(context, AppRoutes.activityHub),
                          borderRadius: BorderRadius.circular(20),
                          child: Padding(
                            padding: EdgeInsets.all(0.6.h),
                            child: Stack(
                              clipBehavior: Clip.none,
                              children: [
                                const Icon(Icons.notifications_outlined, color: Colors.white, size: 20),
                                if (unreadCount > 0)
                                  Positioned(
                                    right: -2,
                                    top: -2,
                                    child: Container(
                                      padding: const EdgeInsets.all(3),
                                      decoration: const BoxDecoration(color: Colors.redAccent, shape: BoxShape.circle),
                                      constraints: const BoxConstraints(minWidth: 12, minHeight: 12),
                                      child: Text(
                                        unreadCount > 9 ? '9+' : unreadCount.toString(),
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 7,
                                          fontWeight: FontWeight.bold,
                                        ),
                                        textAlign: TextAlign.center,
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                    SizedBox(width: 1.w),
                    // Chat Icon
                    InkWell(
                      key: TourKeys.chatKey,
                      onTap: () => Navigator.of(context, rootNavigator: true).pushNamed(AppRoutes.conversationList),
                      borderRadius: BorderRadius.circular(20),
                      child: Padding(
                        padding: EdgeInsets.all(0.6.h),
                        child: Image.asset(
                          'assets/icons/chatting_icon.png',
                          width: 20,
                          height: 20,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(width: 2.w),
              // Pill 2: BVS Initiative & Social / Support (WhatsApp, Instagram)
              Container(
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
                ),
                padding: EdgeInsets.symmetric(horizontal: 1.5.w, vertical: 0.2.h),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // BVS Gateway Icon (Icon-only matching WhatsApp & Instagram)
                    InkWell(
                      onTap: () => Navigator.pushNamed(context, AppRoutes.bvsGateway),
                      borderRadius: BorderRadius.circular(20),
                      child: Padding(
                        padding: EdgeInsets.all(0.6.h),
                        child: Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.amberAccent, width: 1.2),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.25),
                                blurRadius: 4,
                              ),
                            ],
                          ),
                          child: ClipOval(
                            child: Image.asset(
                              'assets/images/bvs_logo_gold.png',
                              width: 18,
                              height: 18,
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: 1.w),
                    // WhatsApp Support
                    InkWell(
                      key: TourKeys.whatsappKey,
                      onTap: () async {
                        final Uri uri = Uri.parse('https://wa.me/8186050406');
                        if (await canLaunchUrl(uri)) {
                          await launchUrl(uri, mode: LaunchMode.externalApplication);
                        }
                      },
                      borderRadius: BorderRadius.circular(20),
                      child: Padding(
                        padding: EdgeInsets.all(0.6.h),
                        child: Image.asset(
                          'assets/icons/whatsapp_icon.png',
                          width: 18,
                          height: 18,
                        ),
                      ),
                    ),
                    SizedBox(width: 1.w),
                    // Instagram
                    InkWell(
                      key: TourKeys.instagramKey,
                      onTap: () async {
                        final Uri uri = Uri.parse('https://www.instagram.com/banjarabio.matrimony/');
                        if (await canLaunchUrl(uri)) {
                          await launchUrl(uri, mode: LaunchMode.externalApplication);
                        }
                      },
                      borderRadius: BorderRadius.circular(20),
                      child: Padding(
                        padding: EdgeInsets.all(0.6.h),
                        child: Image.asset(
                          'assets/icons/instagram_icon.png',
                          width: 18,
                          height: 18,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSearchRow(BuildContext context, ThemeData theme) {
    return Row(
      children: [
        Expanded(
          child: Container(
            key: TourKeys.searchKey,
            height: 4.h,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(30),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.25),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.08),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: SizedBox(
              width: double.infinity,
              child: TextField(
                controller: searchController,
                onChanged: onSearchChanged,
                textAlignVertical: TextAlignVertical.center,
                style: theme.textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                  fontSize: AppTypography.bodyMedium,
                ),
                cursorColor: Colors.white,
                decoration: InputDecoration(
                  hintText: AppLocalizations.of(context)?.searchProfiles ?? 'Search profiles...',
                  hintStyle: TextStyle(
                    color: Colors.white.withValues(alpha: 0.65),
                    fontSize: AppTypography.bodySmall,
                    fontWeight: FontWeight.w500,
                  ),
                  prefixIcon: Container(
                    margin: const EdgeInsets.only(left: 14, right: 8),
                    child: Icon(Icons.search_rounded, color: Colors.white.withValues(alpha: 0.85), size: 22),
                  ),
                  prefixIconConstraints: const BoxConstraints(
                    minWidth: 40,
                    minHeight: 24,
                  ),
                  suffixIconConstraints: const BoxConstraints(
                    minWidth: 36,
                    minHeight: 24,
                  ),
                  border: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  errorBorder: InputBorder.none,
                  filled: false,
                  isDense: true,
                  contentPadding: EdgeInsets.zero,
                  suffixIcon: searchController.text.isNotEmpty
                      ? Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: IconButton(
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                            icon: Icon(Icons.close_rounded, color: Colors.white.withValues(alpha: 0.8), size: 18),
                            onPressed: onSearchClear,
                          ),
                        )
                      : null,
                ),
              ),
            ),
          ),
        ),
        SizedBox(width: 3.w),
        // Filter Button
        InkWell(
          key: TourKeys.filterKey,
          onTap: onFilterTap,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            height: 4.h,
            width: 4.h,
            decoration: BoxDecoration(
              color: activeFilterCount > 0 ? theme.colorScheme.secondary : Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: Colors.white.withValues(alpha: activeFilterCount > 0 ? 0.3 : 0.25),
              ),
            ),
            child: Center(
              child: CustomIconWidget(
                iconName: 'tune',
                color: activeFilterCount > 0 ? theme.colorScheme.onSecondary : Colors.white,
                size: 20,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
