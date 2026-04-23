import 'package:flutter_test/flutter_test.dart';
import 'package:banjarabio/core/models/daily_reward_model.dart';

void main() {
  group('RewardPayload', () {
    test('fromJson parses all fields', () {
      final json = {'type': 'views', 'amount': 5, 'name': 'Daily Views'};
      final payload = RewardPayload.fromJson(json);

      expect(payload.type, 'views');
      expect(payload.amount, 5);
      expect(payload.name, 'Daily Views');
    });

    test('fromJson handles defaults for missing fields', () {
      final payload = RewardPayload.fromJson({});

      expect(payload.type, 'unknown');
      expect(payload.amount, 0);
      expect(payload.name, 'Reward');
    });

    test('Equatable: identical payloads are equal', () {
      const a = RewardPayload(type: 'views', amount: 5, name: 'Daily Views');
      const b = RewardPayload(type: 'views', amount: 5, name: 'Daily Views');

      expect(a, equals(b));
    });

    test('Equatable: different payloads are not equal', () {
      const a = RewardPayload(type: 'views', amount: 5, name: 'Daily Views');
      const b = RewardPayload(type: 'bookmarks', amount: 3, name: 'Bookmarks');

      expect(a, isNot(equals(b)));
    });
  });

  group('DailyRewardModel', () {
    test('fromJson parses all fields including reward', () {
      final json = {
        'streak_count': 7,
        'is_claimed_today': true,
        'reward': {'type': 'messages', 'amount': 3, 'name': 'Chat Bonus'},
      };
      final model = DailyRewardModel.fromJson(json);

      expect(model.streakCount, 7);
      expect(model.isClaimedToday, true);
      expect(model.lastReward, isNotNull);
      expect(model.lastReward!.type, 'messages');
      expect(model.lastReward!.amount, 3);
    });

    test('fromJson handles defaults', () {
      final model = DailyRewardModel.fromJson({});

      expect(model.streakCount, 1);
      expect(model.isClaimedToday, false);
      expect(model.lastReward, isNull);
    });

    test('fromJson handles null reward', () {
      final model = DailyRewardModel.fromJson({
        'streak_count': 3,
        'is_claimed_today': false,
        'reward': null,
      });

      expect(model.lastReward, isNull);
    });

    test('copyWith overrides specified fields', () {
      const original = DailyRewardModel(
        streakCount: 5,
        isClaimedToday: false,
      );
      final copy = original.copyWith(isClaimedToday: true);

      expect(copy.streakCount, 5);
      expect(copy.isClaimedToday, true);
    });

    test('copyWith preserves all fields when no overrides', () {
      const reward = RewardPayload(type: 'views', amount: 2, name: 'Views');
      const original = DailyRewardModel(
        streakCount: 3,
        isClaimedToday: true,
        lastReward: reward,
      );
      final copy = original.copyWith();

      expect(copy.streakCount, 3);
      expect(copy.isClaimedToday, true);
      expect(copy.lastReward, reward);
    });

    test('Equatable: identical models are equal', () {
      const a = DailyRewardModel(streakCount: 5, isClaimedToday: true);
      const b = DailyRewardModel(streakCount: 5, isClaimedToday: true);

      expect(a, equals(b));
    });
  });
}
