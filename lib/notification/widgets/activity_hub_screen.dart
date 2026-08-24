import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:banjarabio/l10n/app_localizations.dart';
import 'package:banjarabio/core/app_export.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:banjarabio/core/services/persistent_cache_manager.dart';
import 'package:banjarabio/notification/core/notification_history.dart';
import 'package:banjarabio/notification/core/notification_payload.dart';
import 'package:banjarabio/notification/features/notification_navigator.dart';
import 'package:banjarabio/widgets/skeleton_loaders.dart';
import 'package:banjarabio/widgets/state_orchestration/bespoke_state_container.dart';
import 'package:banjarabio/widgets/state_orchestration/empty_state_config.dart';
import 'package:banjarabio/widgets/custom_app_bar.dart';
import 'package:banjarabio/widgets/app_logo_image.dart';
import 'package:banjarabio/widgets/tactile/tactile_pressable.dart';

/// Activity Hub Screen — an in-app Notification Center.
///
/// Displays notification history grouped by category with:
/// - Filter tabs (All, Interests, Matches, Messages, Activity)
/// - Read/unread visual indicators
/// - "Mark all as read" action
/// - Empty state with illustration
class ActivityHubScreen extends StatefulWidget {
  const ActivityHubScreen({super.key});

  @override
  State<ActivityHubScreen> createState() => _ActivityHubScreenState();
}

class _ActivityHubScreenState extends State<ActivityHubScreen> {
  final NotificationHistoryStore _store = NotificationHistoryStore();
  String _selectedFilter = 'all';

  static const _filters = [
    ('all', 'All', Icons.notifications_rounded),
    ('interestReceived', '❤️ Interests', Icons.favorite_rounded),
    ('matchFound', '💍 Matches', Icons.celebration_rounded),
    ('chatMessage', '💬 Messages', Icons.chat_rounded),
    ('profileView', '👀 Views', Icons.visibility_rounded),
    ('staffTask', '📋 Staff', Icons.assignment_rounded),
    ('adminAlert', '🚨 Admin', Icons.admin_panel_settings_rounded),
    ('verificationReview', '✅ Verify', Icons.verified_user_rounded),
  ];

  List<NotificationItem> get _filteredItems {
    if (_selectedFilter == 'all') return _store.items;
    return _store.getByCategory(_selectedFilter);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

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
            AppLocalizations.of(context)?.activity ?? 'Notifications',
            maxLines: 1,
            style: (theme.appBarTheme.titleTextStyle ?? theme.textTheme.titleMedium)?.copyWith(
              fontSize: AppTypography.headingSmall,
              fontWeight: AppTypography.bold,
              color: theme.appBarTheme.foregroundColor ?? Colors.white,
              letterSpacing: 0.1,
            ),
          ),
        ),
        actions: [
          if (_store.unreadCount > 0)
            Padding(
              padding: const EdgeInsets.only(right: 12),
              child: Center(
                child: TactilePressable(
                  onTap: () {
                    HapticFeedback.selectionClick();
                    setState(() => _store.markAllAsRead());
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: (theme.appBarTheme.foregroundColor ?? Colors.white)
                          .withValues(alpha: isDark ? AppColors.opacity12 : AppColors.opacity15),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: (theme.appBarTheme.foregroundColor ?? Colors.white)
                            .withValues(alpha: isDark ? 0.20 : 0.30),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.done_all_rounded,
                          size: 14,
                          color: theme.appBarTheme.foregroundColor ?? Colors.white,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          AppLocalizations.of(context)?.readAll ?? 'Read All',
                          style: TextStyle(
                            fontSize: AppTypography.labelSmall,
                            fontWeight: AppTypography.bold,
                            color: theme.appBarTheme.foregroundColor ?? Colors.white,
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
      body: Column(
        children: [
          // Filter chips
          _buildFilterBar(),

          const SizedBox(height: 4),

          // Notification list with Bespoke State Orchestration
          Expanded(
            child: BespokeStateContainer(
              isLoading: false,
              isEmpty: _filteredItems.isEmpty,
              skeleton: const NotificationsScreenSkeleton(),
              emptyConfig: _getEmptyConfig(context),
              contentBuilder: (context) {
                return ListView.separated(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 12, vertical: 8),
                  itemCount: _filteredItems.length,
                  separatorBuilder: (context2, index2) => const SizedBox(height: 8),
                  itemBuilder: (context, index) {
                    final item = _filteredItems[index];
                    return _NotificationCard(
                      item: item,
                      onTap: () {
                        setState(() => _store.markAsRead(item.id));
                        if (item.route != null) {
                          final uri = Uri.tryParse(item.route!);
                          if (uri != null) {
                            NotificationNavigator().handleNotificationTap(
                              NotificationPayload(
                                id: item.id,
                                route: item.route,
                                data: {'profile_id': item.route},
                              ),
                            );
                          }
                        }
                      },
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterBar() {
    return SizedBox(
      height: 46,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        separatorBuilder: (context2, index2) => const SizedBox(width: 8),
        itemCount: _filters.length,
        itemBuilder: (context, index) {
          final (value, label, _) = _filters[index];
          final isSelected = _selectedFilter == value;
          return FilterChip(
            selected: isSelected,
            showCheckmark: false,
            label: Text(label),
            onSelected: (_) {
              setState(() => _selectedFilter = value);
            },
            backgroundColor: Colors.white,
            selectedColor: AppColors.softRed.withValues(alpha: AppColors.opacity12),
            labelStyle: TextStyle(
              fontSize: AppTypography.bodyMedium,
              fontWeight: isSelected ? AppTypography.semiBold : AppTypography.regular,
              color: isSelected
                  ? AppColors.softRed
                  : Colors.grey.shade700,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            side: BorderSide(
              color: isSelected
                  ? AppColors.softRed.withValues(alpha: AppColors.opacity30)
                  : Colors.grey.shade300,
            ),
          );
        },
      ),
    );
  }

  EmptyStateConfig _getEmptyConfig(BuildContext context) {
    final (icon, badge, title, desc, color) = switch (_selectedFilter) {
      'interestReceived' => (
        Icons.favorite_rounded,
        'INTERESTS',
        'No Interests Received Yet ❤️',
        'When members express interest in your profile, notifications will show here.',
        AppColors.crimsonRose,
      ),
      'matchFound' => (
        Icons.celebration_rounded,
        'MATCH ALERTS',
        'No New Match Alerts Yet 💍',
        'When compatible community matches are found, you\'ll receive instant alerts here.',
        AppColors.categoryAstro,
      ),
      'chatMessage' => (
        Icons.chat_rounded,
        'MESSAGES',
        'No New Messages 💬',
        'Unread conversation alerts and replies from connections will arrive here.',
        AppColors.crimsonBlush,
      ),
      'profileView' => (
        Icons.visibility_rounded,
        'PROFILE VIEWS',
        'No Recent Profile Views 👀',
        'Discover who visited your profile and viewed your matrimonial biodata.',
        AppColors.categoryCareerDark,
      ),
      _ => (
        Icons.notifications_active_rounded,
        'ALL CAUGHT UP',
        'No Notifications Yet 🔔',
        'When someone shows interest, sends a message, or views your profile, you\'ll see it here.',
        AppColors.crimsonRose,
      ),
    };

    return EmptyStateConfig(
      icon: icon,
      badgeText: badge,
      title: title,
      description: desc,
      accentColor: color,
      iconGradient: LinearGradient(
        colors: [color, color.withValues(alpha: 0.8)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      ctaText: '✨ Explore Profiles on Home',
      onCtaTap: () {
        HapticFeedback.selectionClick();
        Navigator.pushNamedAndRemoveUntil(context, AppRoutes.home, (route) => false);
      },
    );
  }
}

/// Individual notification card widget.
class _NotificationCard extends StatelessWidget {
  final NotificationItem item;
  final VoidCallback onTap;

  const _NotificationCard({required this.item, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: item.isRead ? Colors.white : AppColors.primaryLight,
      borderRadius: BorderRadius.circular(14),
      elevation: item.isRead ? 0 : 1,
      shadowColor: Colors.black12,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: item.isRead
                  ? Colors.grey.shade200
                  : AppColors.softRed.withValues(alpha: AppColors.opacity15),
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Leading: Image or category icon
              _buildLeading(),
              const SizedBox(width: 12),

              // Content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            item.title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontWeight: item.isRead
                                  ? AppTypography.medium
                                  : AppTypography.bold,
                              fontSize: AppTypography.bodyLarge,
                              color: AppColors.canvasDark,
                            ),
                          ),
                        ),
                        if (!item.isRead)
                          Container(
                            width: 8,
                            height: 8,
                            margin: const EdgeInsets.only(left: 8),
                            decoration: const BoxDecoration(
                              color: AppColors.softRed,
                              shape: BoxShape.circle,
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      item.body,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: AppTypography.bodyMedium,
                        color: Colors.grey.shade600,
                        height: 1.3,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      _formatTime(item.createdAt),
                      style: TextStyle(
                        fontSize: AppTypography.bodySmall,
                        color: Colors.grey.shade400,
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

  Widget _buildLeading() {
    if (item.imageUrl != null && item.imageUrl!.isNotEmpty) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: CachedNetworkImage(
          imageUrl: item.imageUrl!,
          width: 48,
          height: 48,
          fit: BoxFit.cover,
          cacheManager: PersistentCacheManager.instance,
          cacheKey: PersistentCacheManager.stableKeyFor(item.imageUrl!),
          placeholder: (context2, url) => _placeholder(),
          errorWidget: (context2, url, error) => _placeholder(),
        ),
      );
    }
    return _placeholder();
  }

  Widget _placeholder() {
    final (icon, color) = _categoryVisuals();
    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        color: color.withValues(alpha: AppColors.opacity12),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Center(
        child: Text(icon, style: TextStyle(fontSize: AppTypography.headingLarge)),
      ),
    );
  }

  (String, Color) _categoryVisuals() {
    switch (item.category) {
      case 'interestReceived':
        return ('❤️', AppColors.softRed);
      case 'matchFound':
        return ('💍', AppColors.successDark);
      case 'chatMessage':
        return ('💬', AppColors.materialBlue);
      case 'profileView':
        return ('👀', AppColors.materialOrange);
      case 'nudge':
        return ('⭐', AppColors.categoryAstro);
      case 'staffTask':
        return ('📋', AppColors.materialBlue);
      case 'adminAlert':
        return ('🚨', AppColors.deepOrange);
      case 'verificationReview':
        return ('✅', AppColors.successDark);
      default:
        return ('🔔', AppColors.neutral500);
    }
  }

  String _formatTime(DateTime time) {
    final now = DateTime.now();
    final diff = now.difference(time);

    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    return '${time.day}/${time.month}/${time.year}';
  }
}
