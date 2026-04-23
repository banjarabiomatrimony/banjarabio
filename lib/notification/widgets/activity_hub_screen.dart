import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:banjarabio/notification/core/notification_history.dart';
import 'package:banjarabio/notification/core/notification_payload.dart';
import 'package:banjarabio/notification/features/notification_navigator.dart';

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
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        title: const Text(
          'Activity',
          style: TextStyle(fontWeight: FontWeight.w700, fontSize: 20),
        ),
        centerTitle: false,
        actions: [
          if (_store.unreadCount > 0)
            TextButton.icon(
              onPressed: () {
                setState(() => _store.markAllAsRead());
              },
              icon: const Icon(Icons.done_all_rounded, size: 18),
              label: const Text('Read All'),
              style: TextButton.styleFrom(
                foregroundColor: const Color(0xFFC94B4B),
              ),
            ),
        ],
      ),
      body: Column(
        children: [
          // Filter chips
          _buildFilterBar(),

          const SizedBox(height: 4),

          // Notification list
          Expanded(
            child: _filteredItems.isEmpty
                ? _buildEmptyState()
                : ListView.separated(
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
            label: Text(label),
            onSelected: (_) => setState(() => _selectedFilter = value),
            selectedColor: const Color(0xFFC94B4B).withValues(alpha: 0.15),
            checkmarkColor: const Color(0xFFC94B4B),
            labelStyle: TextStyle(
              fontSize: 12.5,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
              color: isSelected
                  ? const Color(0xFFC94B4B)
                  : Colors.grey.shade700,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            side: BorderSide(
              color: isSelected
                  ? const Color(0xFFC94B4B).withValues(alpha: 0.3)
                  : Colors.grey.shade300,
            ),
          );
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: const Color(0xFFC94B4B).withValues(alpha: 0.08),
                shape: BoxShape.circle,
              ),
              child: const Center(
                child: Text('🔔', style: TextStyle(fontSize: 36)),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              _selectedFilter == 'all'
                  ? 'No notifications yet'
                  : 'No notifications in this category',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Color(0xFF333333),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'When someone shows interest or sends a message,\nyou\'ll see it here.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13,
                color: Colors.grey.shade500,
                height: 1.4,
              ),
            ),
          ],
        ),
      ),
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
      color: item.isRead ? Colors.white : const Color(0xFFFFF3F3),
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
                  : const Color(0xFFC94B4B).withValues(alpha: 0.15),
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
                                  ? FontWeight.w500
                                  : FontWeight.w700,
                              fontSize: 14,
                              color: const Color(0xFF1A1A1A),
                            ),
                          ),
                        ),
                        if (!item.isRead)
                          Container(
                            width: 8,
                            height: 8,
                            margin: const EdgeInsets.only(left: 8),
                            decoration: const BoxDecoration(
                              color: Color(0xFFC94B4B),
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
                        fontSize: 12.5,
                        color: Colors.grey.shade600,
                        height: 1.3,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      _formatTime(item.createdAt),
                      style: TextStyle(
                        fontSize: 11,
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
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Center(
        child: Text(icon, style: const TextStyle(fontSize: 22)),
      ),
    );
  }

  (String, Color) _categoryVisuals() {
    switch (item.category) {
      case 'interestReceived':
        return ('❤️', const Color(0xFFC94B4B));
      case 'matchFound':
        return ('💍', const Color(0xFF4CAF50));
      case 'chatMessage':
        return ('💬', const Color(0xFF2196F3));
      case 'profileView':
        return ('👀', const Color(0xFFFF9800));
      case 'nudge':
        return ('⭐', const Color(0xFFFFC107));
      case 'staffTask':
        return ('📋', const Color(0xFF2196F3));
      case 'adminAlert':
        return ('🚨', const Color(0xFFFF5722));
      case 'verificationReview':
        return ('✅', const Color(0xFF4CAF50));
      default:
        return ('🔔', const Color(0xFF9E9E9E));
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
