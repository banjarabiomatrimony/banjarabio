import 'package:flutter_test/flutter_test.dart';
import 'package:banjarabio/core/models/referral_model.dart';
import '../helpers/test_data_factory.dart';

void main() {
  group('ReferralStatus.fromString', () {
    test('maps known statuses', () {
      expect(ReferralStatus.fromString('completed'), ReferralStatus.completed);
      expect(ReferralStatus.fromString('pending'), ReferralStatus.pending);
    });

    test('unknown defaults to pending', () {
      expect(ReferralStatus.fromString('garbage'), ReferralStatus.pending);
      expect(ReferralStatus.fromString(''), ReferralStatus.pending);
    });

    test('is case insensitive', () {
      expect(ReferralStatus.fromString('COMPLETED'), ReferralStatus.completed);
    });
  });

  group('ReferralModel.fromJson', () {
    test('parses all fields', () {
      final json = {
        'id': 'ref-001',
        'referrer_id': 'user-001',
        'referred_user_id': 'user-002',
        'status': 'completed',
        'created_at': '2025-06-15T12:00:00.000Z',
      };

      final model = ReferralModel.fromJson(json);
      expect(model.id, 'ref-001');
      expect(model.referrerId, 'user-001');
      expect(model.referredUserId, 'user-002');
      expect(model.status, ReferralStatus.completed);
    });

    test('handles null/missing fields', () {
      final model = ReferralModel.fromJson({});
      expect(model.id, '');
      expect(model.referrerId, '');
      expect(model.referredUserId, isNull);
      expect(model.status, ReferralStatus.pending);
    });
  });

  group('ReferralModel.toJson', () {
    test('round-trip preserves data', () {
      final original = TestData.referral(
        referredUserId: 'user-002',
        status: ReferralStatus.completed,
      );
      final json = original.toJson();

      expect(json['id'], 'ref-001');
      expect(json['referrer_id'], 'user-uuid-001');
      expect(json['referred_user_id'], 'user-002');
      expect(json['status'], 'completed');
    });
  });
}
