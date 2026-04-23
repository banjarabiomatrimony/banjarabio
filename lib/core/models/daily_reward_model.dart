import 'package:equatable/equatable.dart';

class DailyRewardModel extends Equatable {
  final int streakCount;
  final bool isClaimedToday;
  final RewardPayload? lastReward;

  const DailyRewardModel({
    required this.streakCount,
    required this.isClaimedToday,
    this.lastReward,
  });

  factory DailyRewardModel.fromJson(Map<String, dynamic> json) {
    return DailyRewardModel(
      streakCount: json['streak_count'] as int? ?? 1,
      isClaimedToday: json['is_claimed_today'] as bool? ?? false,
      lastReward: json['reward'] != null 
          ? RewardPayload.fromJson(json['reward']) 
          : null,
    );
  }

  DailyRewardModel copyWith({
    int? streakCount,
    bool? isClaimedToday,
    RewardPayload? lastReward,
  }) {
    return DailyRewardModel(
      streakCount: streakCount ?? this.streakCount,
      isClaimedToday: isClaimedToday ?? this.isClaimedToday,
      lastReward: lastReward ?? this.lastReward,
    );
  }

  @override
  List<Object?> get props => [streakCount, isClaimedToday, lastReward];
}

class RewardPayload extends Equatable {
  final String type; // 'views', 'bookmarks', 'messages'
  final int amount;
  final String name;

  const RewardPayload({
    required this.type,
    required this.amount,
    required this.name,
  });

  factory RewardPayload.fromJson(Map<String, dynamic> json) {
    return RewardPayload(
      type: json['type'] as String? ?? 'unknown',
      amount: json['amount'] as int? ?? 0,
      name: json['name'] as String? ?? 'Reward',
    );
  }

  @override
  List<Object?> get props => [type, amount, name];
}
