import 'package:flutter_test/flutter_test.dart';
import 'package:banjarabio/core/models/banner_model.dart';

void main() {
  final now = DateTime(2025, 6, 15, 10, 30);
  final sampleJson = {
    'id': 'b1',
    'title': 'Summer Offer',
    'image_url': 'https://example.com/banner.jpg',
    'action_url': 'https://example.com/offer',
    'target_gender': 'Male',
    'target_plan': 'premium',
    'priority': 5,
    'is_active': true,
    'expires_at': '2025-12-31T23:59:59.000',
    'created_at': now.toIso8601String(),
  };

  group('BannerModel - fromJson', () {
    test('fromJson parses all fields correctly', () {
      final model = BannerModel.fromJson(sampleJson);

      expect(model.id, 'b1');
      expect(model.title, 'Summer Offer');
      expect(model.imageUrl, 'https://example.com/banner.jpg');
      expect(model.actionUrl, 'https://example.com/offer');
      expect(model.targetGender, 'Male');
      expect(model.targetPlan, 'premium');
      expect(model.priority, 5);
      expect(model.isActive, true);
      expect(model.expiresAt, isNotNull);
      expect(model.createdAt, now);
    });

    test('fromJson handles null optional fields', () {
      final json = {
        'id': 'b2',
        'title': 'Basic',
        'image_url': 'https://example.com/img.jpg',
        'created_at': now.toIso8601String(),
      };
      final model = BannerModel.fromJson(json);

      expect(model.actionUrl, isNull);
      expect(model.targetGender, isNull);
      expect(model.targetPlan, isNull);
      expect(model.priority, 0);
      expect(model.isActive, true);
      expect(model.expiresAt, isNull);
    });
  });

  group('BannerModel - toJson', () {
    test('toJson produces correct map', () {
      final model = BannerModel.fromJson(sampleJson);
      final json = model.toJson();

      expect(json['id'], 'b1');
      expect(json['title'], 'Summer Offer');
      expect(json['image_url'], 'https://example.com/banner.jpg');
      expect(json['action_url'], 'https://example.com/offer');
      expect(json['priority'], 5);
      expect(json['is_active'], true);
    });

    test('toJson round-trip preserves data', () {
      final model = BannerModel.fromJson(sampleJson);
      final json = model.toJson();
      final roundTripped = BannerModel.fromJson(json);

      expect(roundTripped.id, model.id);
      expect(roundTripped.title, model.title);
      expect(roundTripped.imageUrl, model.imageUrl);
      expect(roundTripped.priority, model.priority);
    });
  });

  group('BannerModel - Equatable', () {
    test('identical models are equal', () {
      final a = BannerModel.fromJson(sampleJson);
      final b = BannerModel.fromJson(sampleJson);

      expect(a, equals(b));
    });

    test('models with different ids are not equal', () {
      final a = BannerModel.fromJson(sampleJson);
      final b = BannerModel.fromJson({...sampleJson, 'id': 'b2'});

      expect(a, isNot(equals(b)));
    });
  });
}
