import 'package:flutter_test/flutter_test.dart';
import 'package:banjarabio/core/models/creator_model.dart';

void main() {
  final now = DateTime(2025, 1, 15, 10, 30);
  final sampleJson = {
    'id': 'creator-123',
    'name': 'Ravi Kumar',
    'promo_code': 'RAVI2025',
    'commission_pct': 15.5,
    'instagram_handle': '@ravikumar',
    'total_referrals': 42,
    'total_conversions': 10,
    'total_commission_earned': 5250.75,
    'is_active': true,
    'created_at': now.toIso8601String(),
    'updated_at': now.toIso8601String(),
  };

  group('Creator', () {
    test('fromJson parses all fields correctly', () {
      final creator = Creator.fromJson(sampleJson);
      expect(creator.id, 'creator-123');
      expect(creator.name, 'Ravi Kumar');
      expect(creator.promoCode, 'RAVI2025');
      expect(creator.commissionPct, 15.5);
      expect(creator.instagramHandle, '@ravikumar');
      expect(creator.totalReferrals, 42);
      expect(creator.totalConversions, 10);
      expect(creator.totalCommissionEarned, 5250.75);
      expect(creator.isActive, true);
      expect(creator.createdAt, now);
      expect(creator.updatedAt, now);
    });

    test('fromJson handles nullable and default fields', () {
      final minimalJson = {
        'id': 'c-1',
        'name': 'Test',
        'promo_code': 'TEST',
        'commission_pct': 10,
        'created_at': now.toIso8601String(),
        'updated_at': now.toIso8601String(),
      };
      final creator = Creator.fromJson(minimalJson);
      expect(creator.instagramHandle, isNull);
      expect(creator.totalReferrals, 0);
      expect(creator.totalConversions, 0);
      expect(creator.totalCommissionEarned, 0);
      expect(creator.isActive, true);
    });

    test('toJson produces correct map', () {
      final creator = Creator.fromJson(sampleJson);
      final json = creator.toJson();
      expect(json['id'], 'creator-123');
      expect(json['name'], 'Ravi Kumar');
      expect(json['promo_code'], 'RAVI2025');
      expect(json['commission_pct'], 15.5);
      expect(json['instagram_handle'], '@ravikumar');
      expect(json['total_referrals'], 42);
      expect(json['total_conversions'], 10);
      expect(json['total_commission_earned'], 5250.75);
      expect(json['is_active'], true);
    });

    test('roundtrip fromJson -> toJson preserves data', () {
      final creator = Creator.fromJson(sampleJson);
      final json = creator.toJson();
      final recreated = Creator.fromJson(json);
      expect(recreated.id, creator.id);
      expect(recreated.name, creator.name);
      expect(recreated.promoCode, creator.promoCode);
      expect(recreated.commissionPct, creator.commissionPct);
      expect(recreated.totalReferrals, creator.totalReferrals);
    });

    test('constructor defaults work correctly', () {
      final creator = Creator(
        id: 'c-2',
        name: 'Default',
        promoCode: 'DEF',
        commissionPct: 5.0,
        createdAt: now,
        updatedAt: now,
      );
      expect(creator.totalReferrals, 0);
      expect(creator.totalConversions, 0);
      expect(creator.totalCommissionEarned, 0);
      expect(creator.isActive, true);
      expect(creator.instagramHandle, isNull);
    });
  });
}
