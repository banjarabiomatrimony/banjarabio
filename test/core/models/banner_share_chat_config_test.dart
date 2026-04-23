import 'package:flutter_test/flutter_test.dart';
import 'package:banjarabio/core/models/banner_model.dart';
import 'package:banjarabio/core/config/share_config.dart';
import 'package:banjarabio/core/config/chat_config.dart';

void main() {
  // =========================================================================
  // BannerModel
  // =========================================================================
  group('BannerModel.fromJson', () {
    test('parses all fields correctly', () {
      final json = {
        'id': 'b-1',
        'title': 'Promo Banner',
        'image_url': 'https://example.com/img.png',
        'action_url': 'https://example.com/action',
        'target_gender': 'male',
        'target_plan': 'premium',
        'priority': 5,
        'is_active': true,
        'expires_at': '2026-12-31T23:59:59.000Z',
        'created_at': '2026-01-01T00:00:00.000Z',
      };

      final m = BannerModel.fromJson(json);
      expect(m.id, 'b-1');
      expect(m.title, 'Promo Banner');
      expect(m.imageUrl, 'https://example.com/img.png');
      expect(m.actionUrl, 'https://example.com/action');
      expect(m.targetGender, 'male');
      expect(m.targetPlan, 'premium');
      expect(m.priority, 5);
      expect(m.isActive, true);
      expect(m.expiresAt, isNotNull);
      expect(m.createdAt.year, 2026);
    });

    test('handles nullable fields', () {
      final json = {
        'id': 'b-2',
        'title': 'Simple',
        'image_url': 'https://img.png',
        'created_at': '2026-01-01T00:00:00.000Z',
      };

      final m = BannerModel.fromJson(json);
      expect(m.actionUrl, isNull);
      expect(m.targetGender, isNull);
      expect(m.targetPlan, isNull);
      expect(m.expiresAt, isNull);
      expect(m.priority, 0); // default
      expect(m.isActive, true); // default
    });
  });

  group('BannerModel.toJson', () {
    test('serializes all fields including nullable', () {
      final m = BannerModel(
        id: 'b-1',
        title: 'T',
        imageUrl: 'http://img',
        actionUrl: 'http://act',
        targetGender: 'female',
        targetPlan: 'free',
        priority: 3,
        isActive: false,
        expiresAt: DateTime.utc(2026, 6, 15),
        createdAt: DateTime.utc(2026),
      );

      final j = m.toJson();
      expect(j['id'], 'b-1');
      expect(j['title'], 'T');
      expect(j['image_url'], 'http://img');
      expect(j['action_url'], 'http://act');
      expect(j['target_gender'], 'female');
      expect(j['target_plan'], 'free');
      expect(j['priority'], 3);
      expect(j['is_active'], false);
      expect(j['expires_at'], contains('2026'));
      expect(j['created_at'], contains('2026'));
    });

    test('handles null expires_at', () {
      final m = BannerModel(
        id: 'b-2', title: 'T', imageUrl: 'x',
        createdAt: DateTime.utc(2026),
      );
      expect(m.toJson()['expires_at'], isNull);
    });
  });

  group('BannerModel equality (Equatable)', () {
    test('equal models have same props', () {
      final a = BannerModel(id: '1', title: 'T', imageUrl: 'u', createdAt: DateTime.utc(2026));
      final b = BannerModel(id: '1', title: 'T', imageUrl: 'u', createdAt: DateTime.utc(2026));
      expect(a, equals(b));
    });

    test('different id = different model', () {
      final a = BannerModel(id: '1', title: 'T', imageUrl: 'u', createdAt: DateTime.utc(2026));
      final b = BannerModel(id: '2', title: 'T', imageUrl: 'u', createdAt: DateTime.utc(2026));
      expect(a, isNot(equals(b)));
    });
  });

  group('BannerModel.fromJson round-trip', () {
    test('fromJson → toJson → fromJson preserves data', () {
      final original = BannerModel(
        id: 'rt', title: 'Round Trip', imageUrl: 'https://img',
        actionUrl: 'https://act', targetGender: 'male', targetPlan: 'gold',
        priority: 7,
        expiresAt: DateTime.utc(2027, 3, 15, 12),
        createdAt: DateTime.utc(2026),
      );
      final restored = BannerModel.fromJson(original.toJson());
      expect(restored.id, original.id);
      expect(restored.title, original.title);
      expect(restored.priority, original.priority);
    });
  });

  // =========================================================================
  // ShareConfig
  // =========================================================================
  group('ShareConfig.isValidStatus', () {
    test('accepts valid statuses', () {
      for (final s in ['pending', 'viewed', 'interested', 'rejected', 'new', 'matched']) {
        expect(ShareConfig.isValidStatus(s), true, reason: '$s should be valid');
      }
    });

    test('case insensitive', () {
      expect(ShareConfig.isValidStatus('PENDING'), true);
      expect(ShareConfig.isValidStatus('Matched'), true);
    });

    test('rejects invalid status', () {
      expect(ShareConfig.isValidStatus('blocked'), false);
      expect(ShareConfig.isValidStatus(''), false);
    });
  });

  group('ShareConfig.isValidSharingMethod', () {
    test('accepts valid methods', () {
      for (final m in ['whatsapp', 'in_app', 'link']) {
        expect(ShareConfig.isValidSharingMethod(m), true);
      }
    });

    test('case insensitive', () {
      expect(ShareConfig.isValidSharingMethod('WhatsApp'), true);
    });

    test('rejects invalid method', () {
      expect(ShareConfig.isValidSharingMethod('telegram'), false);
    });
  });

  group('ShareConfig constants', () {
    test('matchedStatus is matched', () {
      expect(ShareConfig.matchedStatus, 'matched');
    });
  });

  // =========================================================================
  // ChatConfig
  // =========================================================================
  group('ChatConfig constants', () {
    test('action constants are correct', () {
      expect(ChatConfig.actionGetOrCreateConversation, 'get_or_create_conversation');
      expect(ChatConfig.actionSendMessage, 'send_message');
      expect(ChatConfig.actionMarkAsRead, 'mark_as_read');
      expect(ChatConfig.actionTrackView, 'track_view');
    });

    test('payload keys are correct', () {
      expect(ChatConfig.payloadConversationId, 'conversation_id');
      expect(ChatConfig.payloadOtherUserId, 'other_user_id');
      expect(ChatConfig.payloadMessageText, 'message_text');
      expect(ChatConfig.payloadViewedId, 'viewed_id');
    });
  });
}
