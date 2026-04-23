import 'package:flutter_test/flutter_test.dart';
import 'package:banjarabio/core/models/profile_share_model.dart';

void main() {
  group('ProfileShare.fromJson', () {
    test('parses all flat fields', () {
      final s = ProfileShare.fromJson({
        'id': 's1', 'sharer_id': 'u1', 'recipient_id': 'u2',
        'recipient_name': 'Priya', 'recipient_relation': 'Sister',
        'sharer_name': 'Rahul', 'recipient_profile_name': 'Priya P',
        'shared_profile_id': 'p1', 'shared_profile_name': 'Amit',
        'shared_profile_age': 25, 'sharing_method': 'whatsapp',
        'status': 'viewed', 'view_count': 3, 'created_at': '2025-06-01T00:00:00Z',
        'viewed_at': '2025-06-02T00:00:00Z',
      });
      expect(s.id, 's1');
      expect(s.sharedProfileName, 'Amit');
      expect(s.sharedProfileAge, 25);
      expect(s.sharingMethod, 'whatsapp');
      expect(s.viewCount, 3);
      expect(s.viewedAt, isNotNull);
    });

    test('parses nested shared_profile', () {
      final s = ProfileShare.fromJson({
        'sharer_id': 'u1', 'shared_profile_id': 'p1',
        'sharing_method': 'link', 'status': 'pending', 'view_count': 0,
        'created_at': '2025-01-01T00:00:00Z',
        'shared_profile': {'full_name': 'Nested', 'age': 28, 'education': 'MBA'},
      });
      expect(s.sharedProfileName, 'Nested');
      expect(s.sharedProfileAge, 28);
      expect(s.education, 'MBA');
    });

    test('defaults for missing fields', () {
      final s = ProfileShare.fromJson({
        'sharer_id': 'u1', 'shared_profile_id': 'p1', 'created_at': '2025-01-01T00:00:00Z',
      });
      expect(s.sharingMethod, 'in_app');
      expect(s.status, 'pending');
      expect(s.viewCount, 0);
    });
  });

  group('ProfileShare.toDisplayMap', () {
    ProfileShare makeShare() => ProfileShare.fromJson({
      'id': 's1', 'sharer_id': 'u1', 'sharer_name': 'Rahul',
      'recipient_profile_name': 'Priya', 'shared_profile_id': 'p1',
      'shared_profile_name': 'Amit', 'shared_profile_age': 25,
      'sharing_method': 'whatsapp', 'status': 'viewed', 'view_count': 3,
      'created_at': '2025-01-01T00:00:00Z',
    });

    test('isSharedByMe includes recipientName', () {
      final map = makeShare().toDisplayMap(isSharedByMe: true);
      expect(map['recipientName'], 'Priya');
      expect(map['sharingMethod'], 'WhatsApp');
      expect(map['status'], 'Viewed');
    });

    test('not isSharedByMe includes senderName', () {
      final map = makeShare().toDisplayMap(isSharedByMe: false);
      expect(map['senderName'], 'Rahul');
    });
  });

  group('ProfileShare.otherPersonName', () {
    test('returns recipient when I am sharer', () {
      final s = ProfileShare.fromJson({
        'sharer_id': 'me', 'recipient_profile_name': 'Priya', 'sharer_name': 'Rahul',
        'shared_profile_id': 'p1', 'sharing_method': 'in_app', 'status': 'p', 'view_count': 0,
        'created_at': '2025-01-01T00:00:00Z',
      });
      expect(s.otherPersonName('me'), 'Priya');
    });

    test('returns sharer when I am not sharer', () {
      final s = ProfileShare.fromJson({
        'sharer_id': 'other', 'sharer_name': 'Rahul',
        'shared_profile_id': 'p1', 'sharing_method': 'in_app', 'status': 'p', 'view_count': 0,
        'created_at': '2025-01-01T00:00:00Z',
      });
      expect(s.otherPersonName('me'), 'Rahul');
    });
  });

  group('ProfileShare.toJson', () {
    test('returns essential fields', () {
      final json = ProfileShare.fromJson({
        'id': 's1', 'sharer_id': 'u1', 'shared_profile_id': 'p1',
        'sharing_method': 'whatsapp', 'status': 'viewed', 'view_count': 3,
        'created_at': '2025-01-01T00:00:00Z',
      }).toJson();
      expect(json['id'], 's1');
      expect(json['sharing_method'], 'whatsapp');
    });
  });
}
