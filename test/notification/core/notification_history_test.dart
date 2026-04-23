import 'package:flutter_test/flutter_test.dart';
import 'package:banjarabio/notification/core/notification_history.dart';

void main() {
  late NotificationHistoryStore store;

  setUp(() {
    store = NotificationHistoryStore();
    store.clear(); // Reset singleton state
  });

  tearDown(() {
    store.clear();
  });

  NotificationItem makeItem({
    String id = 'n1',
    String title = 'Test',
    String body = 'Body',
    String category = 'general',
    bool isRead = false,
  }) {
    return NotificationItem(
      id: id,
      title: title,
      body: body,
      category: category,
      createdAt: DateTime(2025, 6, 15),
      isRead: isRead,
    );
  }

  group('NotificationItem', () {
    test('fromJson parses all fields', () {
      final item = NotificationItem.fromJson({
        'id': 'i1',
        'title': 'Hello',
        'body': 'World',
        'image_url': 'https://img.com/a.jpg',
        'route': '/profile/1',
        'category': 'matchFound',
        'created_at': '2025-06-15T10:00:00.000',
        'is_read': true,
      });

      expect(item.id, 'i1');
      expect(item.title, 'Hello');
      expect(item.body, 'World');
      expect(item.imageUrl, 'https://img.com/a.jpg');
      expect(item.route, '/profile/1');
      expect(item.category, 'matchFound');
      expect(item.isRead, true);
    });

    test('fromJson handles missing fields with defaults', () {
      final item = NotificationItem.fromJson({});

      expect(item.id, '');
      expect(item.title, '');
      expect(item.body, '');
      expect(item.isRead, false);
      expect(item.category, 'general');
    });

    test('toJson produces correct map', () {
      final item = makeItem();
      final json = item.toJson();

      expect(json['id'], 'n1');
      expect(json['title'], 'Test');
      expect(json['body'], 'Body');
      expect(json['category'], 'general');
      expect(json['is_read'], false);
      expect(json['created_at'], isA<String>());
    });

    test('toJson/fromJson round-trip preserves data', () {
      final original = makeItem(id: 'rt1', title: 'Round Trip', isRead: true);
      final restored = NotificationItem.fromJson(original.toJson());

      expect(restored.id, 'rt1');
      expect(restored.title, 'Round Trip');
      expect(restored.isRead, true);
    });

    test('copyWith overrides isRead', () {
      final item = makeItem();
      final copy = item.copyWith(isRead: true);

      expect(copy.isRead, true);
      expect(copy.id, item.id);
      expect(copy.title, item.title);
    });

    test('equality is based on id', () {
      final a = makeItem(id: 'same', title: 'A');
      final b = makeItem(id: 'same', title: 'B');

      expect(a, equals(b));
    });

    test('different ids are not equal', () {
      final a = makeItem(id: 'a');
      final b = makeItem(id: 'b');

      expect(a, isNot(equals(b)));
    });

    test('hashCode is based on id', () {
      final a = makeItem(id: 'same');
      final b = makeItem(id: 'same');

      expect(a.hashCode, b.hashCode);
    });
  });

  group('NotificationHistoryStore', () {
    test('is a singleton', () {
      final a = NotificationHistoryStore();
      final b = NotificationHistoryStore();
      expect(identical(a, b), true);
    });

    test('starts empty after clear', () {
      expect(store.items, isEmpty);
      expect(store.unreadCount, 0);
    });

    test('add inserts item at top', () {
      store.add(makeItem(id: 'first'));
      store.add(makeItem(id: 'second'));

      expect(store.items.length, 2);
      expect(store.items.first.id, 'second');
    });

    test('add deduplicates by id', () {
      store.add(makeItem(id: 'dup', title: 'Original'));
      store.add(makeItem(id: 'dup', title: 'Updated'));

      expect(store.items.length, 1);
      expect(store.items.first.title, 'Updated');
    });

    test('add trims to max 50 items', () {
      for (int i = 0; i < 55; i++) {
        store.add(makeItem(id: 'item_$i'));
      }

      expect(store.items.length, 50);
      // Most recent should be at top
      expect(store.items.first.id, 'item_54');
    });

    test('add notifies listeners', () {
      int notifyCount = 0;
      store.addListener(() => notifyCount++);

      store.add(makeItem());

      expect(notifyCount, 1);
    });

    test('unreadCount counts unread items', () {
      store.add(makeItem(id: 'a'));
      store.add(makeItem(id: 'b'));
      store.add(makeItem(id: 'c', isRead: true));

      expect(store.unreadCount, 2);
    });

    test('markAsRead marks specific item', () {
      store.add(makeItem(id: 'a'));
      store.add(makeItem(id: 'b'));

      store.markAsRead('a');

      expect(store.items.firstWhere((n) => n.id == 'a').isRead, true);
      expect(store.items.firstWhere((n) => n.id == 'b').isRead, false);
      expect(store.unreadCount, 1);
    });

    test('markAsRead does nothing for non-existent id', () {
      store.add(makeItem(id: 'a'));

      int notifyCount = 0;
      store.addListener(() => notifyCount++);

      store.markAsRead('nonexistent');

      expect(notifyCount, 0);
    });

    test('markAllAsRead marks all items', () {
      store.add(makeItem(id: 'a'));
      store.add(makeItem(id: 'b'));

      store.markAllAsRead();

      expect(store.unreadCount, 0);
      expect(store.items.every((n) => n.isRead), true);
    });

    test('markAllAsRead does not notify when all already read', () {
      store.add(makeItem(id: 'a', isRead: true));

      int notifyCount = 0;
      store.addListener(() => notifyCount++);

      store.markAllAsRead();

      expect(notifyCount, 0);
    });

    test('clear removes all items and notifies', () {
      store.add(makeItem(id: 'a'));
      store.add(makeItem(id: 'b'));

      int notifyCount = 0;
      store.addListener(() => notifyCount++);

      store.clear();

      expect(store.items, isEmpty);
      expect(notifyCount, 1);
    });

    test('getByCategory filters correctly', () {
      store.add(makeItem(id: 'a', category: 'matchFound'));
      store.add(makeItem(id: 'b', category: 'chatMessage'));
      store.add(makeItem(id: 'c', category: 'matchFound'));

      final matches = store.getByCategory('matchFound');
      expect(matches.length, 2);
      expect(matches.every((n) => n.category == 'matchFound'), true);
    });

    test('getByCategory returns empty for unknown category', () {
      store.add(makeItem(id: 'a', category: 'matchFound'));

      expect(store.getByCategory('unknown'), isEmpty);
    });

    test('items returns unmodifiable list', () {
      store.add(makeItem());

      expect(() => (store.items as List).add(makeItem(id: 'hack')),
          throwsUnsupportedError);
    });
  });
}
