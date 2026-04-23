import 'package:flutter_test/flutter_test.dart';
import 'package:banjarabio/core/models/profile_share_model.dart';

void main() {
  group('ProfileShare', () {
    final sampleJson = {
      'id': 'share1',
      'sharer_id': 'u1',
      'recipient_id': 'u2',
      'recipient_name': 'Family Member',
      'recipient_relation': 'Mother',
      'sharer_name': 'John',
      'recipient_profile_name': 'Jane',
      'shared_profile_id': 'p1',
      'shared_profile_name': 'Candidate',
      'shared_profile_age': 25,
      'shared_profile_image': 'https://img.url',
      'sharing_method': 'whatsapp',
      'status': 'viewed',
      'view_count': 3,
      'created_at': '2025-01-15T10:00:00Z',
      'viewed_at': '2025-01-15T12:00:00Z',
    };

    test('fromJson parses all fields', () {
      final model = ProfileShare.fromJson(sampleJson);

      expect(model.id, 'share1');
      expect(model.sharerId, 'u1');
      expect(model.recipientId, 'u2');
      expect(model.recipientName, 'Family Member');
      expect(model.recipientRelation, 'Mother');
      expect(model.sharerName, 'John');
      expect(model.sharedProfileId, 'p1');
      expect(model.sharedProfileName, 'Candidate');
      expect(model.sharedProfileAge, 25);
      expect(model.sharingMethod, 'whatsapp');
      expect(model.status, 'viewed');
      expect(model.viewCount, 3);
      expect(model.viewedAt, isNotNull);
    });

    test('fromJson handles nested shared_profile', () {
      final json = {
        'id': 's1', 'sharer_id': 'u1', 'shared_profile_id': 'p1',
        'sharing_method': 'in_app', 'status': 'pending', 'view_count': 0,
        'created_at': '2025-01-01T00:00:00Z',
        'shared_profile': {
          'full_name': 'Nested Name', 'age': 30, 'public_url': 'url',
          'education': 'MBA', 'job': 'Manager',
        }
      };
      final model = ProfileShare.fromJson(json);
      expect(model.sharedProfileName, 'Nested Name');
      expect(model.sharedProfileAge, 30);
      expect(model.education, 'MBA');
      expect(model.job, 'Manager');
    });

    test('fromJson handles flat fallback fields', () {
      final json = {
        'id': 's1', 'sharer_id': 'u1', 'shared_profile_id': 'p1',
        'full_name': 'Flat Name', 'age': 28, 'image_url': 'flat_url',
        'sharing_method': 'link', 'status': 'new', 'view_count': 1,
        'created_at': '2025-01-01T00:00:00Z',
      };
      final model = ProfileShare.fromJson(json);
      expect(model.sharedProfileName, 'Flat Name');
      expect(model.sharedProfileAge, 28);
      expect(model.sharedProfileImage, 'flat_url');
    });

    test('fromJson handles share_id and share_created_at', () {
      final json = {
        'share_id': 'alt-id', 'sharer_id': 'u1', 'shared_profile_id': 'p1',
        'sharing_method': 'in_app', 'status': 'pending', 'view_count': 0,
        'share_created_at': '2025-06-01T00:00:00Z',
      };
      final model = ProfileShare.fromJson(json);
      expect(model.id, 'alt-id');
      expect(model.createdAt.year, 2025);
      expect(model.createdAt.month, 6);
    });

    test('fromJson handles null/missing fields', () {
      final model = ProfileShare.fromJson({
        'sharing_method': 'in_app', 'status': 'pending', 'view_count': 0,
        'created_at': '2025-01-01T00:00:00Z',
      });

      expect(model.id, '');
      expect(model.sharerId, '');
      expect(model.recipientId, isNull);
      expect(model.sharedProfileName, isNull);
      expect(model.viewedAt, isNull);
    });

    test('toJson returns correct map', () {
      final model = ProfileShare.fromJson(sampleJson);
      final json = model.toJson();

      expect(json['id'], 'share1');
      expect(json['sharer_id'], 'u1');
      expect(json['sharing_method'], 'whatsapp');
      expect(json['status'], 'viewed');
    });

    test('toDisplayMap for sharedByMe', () {
      final model = ProfileShare.fromJson(sampleJson);
      final display = model.toDisplayMap(isSharedByMe: true);

      expect(display['sharedProfileName'], 'Candidate');
      expect(display['recipientName'], 'Jane');
      expect(display['recipientRelation'], 'Mother');
      expect(display['sharingMethod'], 'WhatsApp');
      expect(display['status'], 'Viewed');
    });

    test('toDisplayMap for receivedByMe', () {
      final model = ProfileShare.fromJson(sampleJson);
      final display = model.toDisplayMap(isSharedByMe: false);

      expect(display['senderName'], 'John');
      expect(display.containsKey('recipientName'), false);
    });

    test('otherPersonName returns correct name', () {
      final model = ProfileShare.fromJson(sampleJson);

      expect(model.otherPersonName('u1'), 'Jane'); // I am sharer
      expect(model.otherPersonName('u2'), 'John'); // I am recipient
      expect(model.otherPersonName(null), isNotNull); // fallback
    });
  });
}
