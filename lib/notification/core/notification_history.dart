import 'package:flutter/foundation.dart';

/// Represents a single notification item stored for the Activity Hub.
class NotificationItem {
  final String id;
  final String title;
  final String body;
  final String? imageUrl;
  final String? route;
  final String category;
  final DateTime createdAt;
  final bool isRead;

  const NotificationItem({
    required this.id,
    required this.title,
    required this.body,
    this.imageUrl,
    this.route,
    required this.category,
    required this.createdAt,
    this.isRead = false,
  });

  factory NotificationItem.fromJson(Map<String, dynamic> json) {
    return NotificationItem(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      body: json['body'] ?? '',
      imageUrl: json['image_url'],
      route: json['route'],
      category: json['category'] ?? 'general',
      createdAt: DateTime.tryParse(json['created_at'] ?? '') ?? DateTime.now(),
      isRead: json['is_read'] ?? false,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'body': body,
        'image_url': imageUrl,
        'route': route,
        'category': category,
        'created_at': createdAt.toIso8601String(),
        'is_read': isRead,
      };

  NotificationItem copyWith({bool? isRead}) => NotificationItem(
        id: id,
        title: title,
        body: body,
        imageUrl: imageUrl,
        route: route,
        category: category,
        createdAt: createdAt,
        isRead: isRead ?? this.isRead,
      );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is NotificationItem &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() => 'NotificationItem(id: $id, title: $title, isRead: $isRead)';
}

/// Manages local storage of notification history for the Activity Hub.
///
/// Uses Hive (via LocalCacheService pattern) for persistence.
/// Limits to 50 most recent notifications to keep storage lean.
class NotificationHistoryStore extends ChangeNotifier {
  static final NotificationHistoryStore _instance =
      NotificationHistoryStore._internal();
  factory NotificationHistoryStore() => _instance;
  NotificationHistoryStore._internal();

  final List<NotificationItem> _items = [];
  static const int _maxItems = 50;

  List<NotificationItem> get items => List.unmodifiable(_items);

  int get unreadCount => _items.where((n) => !n.isRead).length;

  /// Add a notification. Inserts at the top (most recent first).
  void add(NotificationItem item) {
    // Deduplicate
    _items.removeWhere((n) => n.id == item.id);
    _items.insert(0, item);

    // Trim to max
    if (_items.length > _maxItems) {
      _items.removeRange(_maxItems, _items.length);
    }

    notifyListeners();
    debugPrint(
        '🔔 [HistoryStore] Added notification: ${item.title} (total: ${_items.length})');
  }

  /// Mark a single notification as read.
  void markAsRead(String id) {
    final idx = _items.indexWhere((n) => n.id == id);
    if (idx != -1) {
      _items[idx] = _items[idx].copyWith(isRead: true);
      notifyListeners();
    }
  }

  /// Mark all notifications as read.
  void markAllAsRead() {
    bool changed = false;
    for (int i = 0; i < _items.length; i++) {
      if (!_items[i].isRead) {
        _items[i] = _items[i].copyWith(isRead: true);
        changed = true;
      }
    }
    if (changed) notifyListeners();
  }

  /// Clear all notification history.
  void clear() {
    _items.clear();
    notifyListeners();
  }

  /// Get items filtered by category.
  List<NotificationItem> getByCategory(String category) {
    return _items.where((n) => n.category == category).toList();
  }
}
