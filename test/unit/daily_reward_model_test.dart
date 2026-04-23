import 'package:flutter_test/flutter_test.dart';
import 'package:banjarabio/core/models/daily_reward_model.dart';

void main() {
  group('DailyRewardModel.fromJson', () {
    test('parses all fields', () {
      final json = {
        'streak_count': 5,
        'is_claimed_today': true,
        'reward': {
          'type': 'views',
          'amount': 10,
          'name': 'Extra Views',
        },
      };

      final model = DailyRewardModel.fromJson(json);
      expect(model.streakCount, 5);
      expect(model.isClaimedToday, true);
      expect(model.lastReward, isNotNull);
      expect(model.lastReward!.type, 'views');
      expect(model.lastReward!.amount, 10);
      expect(model.lastReward!.name, 'Extra Views');
    });

    test('handles null/missing fields with defaults', () {
      final model = DailyRewardModel.fromJson({});
      expect(model.streakCount, 1);
      expect(model.isClaimedToday, false);
      expect(model.lastReward, isNull);
    });
  });

  group('DailyRewardModel.copyWith', () {
    test('overrides specific fields', () {
      final original = const DailyRewardModel(
        streakCount: 3,
        isClaimedToday: false,
      );
      final modified = original.copyWith(isClaimedToday: true);

      expect(modified.streakCount, 3);
      expect(modified.isClaimedToday, true);
    });
  });

  group('DailyRewardModel Equatable', () {
    test('equal when same props', () {
      const a = DailyRewardModel(streakCount: 3, isClaimedToday: false);
      const b = DailyRewardModel(streakCount: 3, isClaimedToday: false);
      expect(a, equals(b));
    });

    test('not equal when different props', () {
      const a = DailyRewardModel(streakCount: 3, isClaimedToday: false);
      const b = DailyRewardModel(streakCount: 5, isClaimedToday: false);
      expect(a, isNot(equals(b)));
    });
  });

  group('RewardPayload.fromJson', () {
    test('parses all fields', () {
      final payload = RewardPayload.fromJson({
        'type': 'bookmarks',
        'amount': 5,
        'name': 'Extra Bookmarks',
      });
      expect(payload.type, 'bookmarks');
      expect(payload.amount, 5);
      expect(payload.name, 'Extra Bookmarks');
    });

    test('defaults for missing fields', () {
      final payload = RewardPayload.fromJson({});
      expect(payload.type, 'unknown');
      expect(payload.amount, 0);
      expect(payload.name, 'Reward');
    });
  });

  group('RewardPayload Equatable', () {
    test('equal when same props', () {
      const a = RewardPayload(type: 'views', amount: 10, name: 'Views');
      const b = RewardPayload(type: 'views', amount: 10, name: 'Views');
      expect(a, equals(b));
    });
  });
}
