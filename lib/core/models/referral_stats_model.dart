import 'package:flutter/foundation.dart';

/// Matches 13_referrals_and_rewards: referral_stats table.
/// Note: pending_count not in SQL; kept for UI compat, defaults to 0.
@immutable
class ReferralStatsModel {
  final String userId;
  final int referralCount;
  final int rewardsEarned;
  final DateTime? lastRewardAt;
  final DateTime updatedAt;

  const ReferralStatsModel({
    required this.userId,
    required this.referralCount,
    required this.rewardsEarned,
    this.lastRewardAt,
    required this.updatedAt,
  });

  factory ReferralStatsModel.fromJson(Map<String, dynamic> json) {
    return ReferralStatsModel(
      userId: json['user_id']?.toString() ?? '',
      referralCount: (json['referral_count'] as num?)?.toInt() ?? 0,
      rewardsEarned: (json['rewards_earned'] as num?)?.toInt() ?? 0,
      lastRewardAt: json['last_reward_at'] != null
          ? DateTime.tryParse(json['last_reward_at'].toString())
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.tryParse(json['updated_at'].toString()) ?? DateTime.now()
          : DateTime.now(),
    );
  }

  factory ReferralStatsModel.empty(String userId) {
    return ReferralStatsModel(
      userId: userId,
      referralCount: 0,
      rewardsEarned: 0,
      updatedAt: DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'referral_count': referralCount,
      'rewards_earned': rewardsEarned,
      'last_reward_at': lastRewardAt?.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}
