// test/helpers/test_data_factory.dart
// Centralized factory for all test model instances.
// Avoids repeating 50+ constructor args across every test file.

import 'package:banjarabio/core/models/profile_model.dart';
import 'package:banjarabio/core/models/subscription_model.dart';
import 'package:banjarabio/core/models/coupon_model.dart';
import 'package:banjarabio/core/models/daily_reward_model.dart';
import 'package:banjarabio/core/models/referral_model.dart';
import 'package:banjarabio/core/models/referral_stats_model.dart';
import 'package:banjarabio/core/models/filter_criteria.dart';

/// Centralized test data factory — call `TestData.xxx()` in any test file.
class TestData {
  TestData._();

  static final _now = DateTime(2025, 6, 15, 12);

  // ─── ProfileModel ─────────────────────────────────────────────────────

  /// Minimal valid ProfileModel with sensible defaults.
  static ProfileModel profile({
    String id = 'abc12345-1111-2222-3333-444444444444',
    String userId = 'user-uuid-001',
    String fullName = 'Rahul',
    String surname = 'Rathod',
    int age = 25,
    String gender = 'Male',
    String height = "5'10\"",
    String education = 'B.Tech',
    String profession = 'Engineer',
    String? state,
    String? district,
    String? taluka,
    String? village,
    String? phoneNumber,
    String? aboutSelf,
    String? fatherName,
    String? motherName,
    List<PhotoModel> photos = const [],
    bool isPremium = false,
    int trustScore = 0,
    PlanType planType = PlanType.free,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? dateOfBirth,
  }) {
    return ProfileModel(
      id: id,
      userId: userId,
      fullName: fullName,
      surname: surname,
      age: age,
      gender: gender,
      height: height,
      education: education,
      profession: profession,
      state: state,
      district: district,
      taluka: taluka,
      village: village,
      phoneNumber: phoneNumber,
      aboutSelf: aboutSelf,
      fatherName: fatherName,
      motherName: motherName,
      photos: photos,
      isPremium: isPremium,
      trustScore: trustScore,
      planType: planType,
      createdAt: createdAt ?? _now,
      updatedAt: updatedAt ?? _now,
      dateOfBirth: dateOfBirth,
    );
  }

  /// Raw JSON map that mirrors Supabase response for `fromJson` tests.
  static Map<String, dynamic> profileJson({
    String id = 'abc12345-1111-2222-3333-444444444444',
    String userId = 'user-uuid-001',
    String fullName = 'Rahul',
    String surname = 'Rathod',
    int age = 25,
    String gender = 'Male',
    String? state,
    String? district,
  }) {
    return {
      'id': id,
      'user_id': userId,
      'full_name': fullName,
      'surname': surname,
      'age': age,
      'gender': gender,
      'height': "5'10\"",
      'education': 'B.Tech',
      'profession': 'Engineer',
      'state': state,
      'district': district,
      'created_at': _now.toIso8601String(),
      'updated_at': _now.toIso8601String(),
    };
  }

  // ─── SubscriptionModel ─────────────────────────────────────────────────

  static SubscriptionModel subscription({
    String id = 'sub-001',
    String userId = 'user-uuid-001',
    PlanType planType = PlanType.gold,
    SubscriptionStatus status = SubscriptionStatus.active,
    DateTime? startedAt,
    DateTime? expiresAt,
    double? amountPaid,
  }) {
    return SubscriptionModel(
      id: id,
      userId: userId,
      planType: planType,
      status: status,
      startedAt: startedAt ?? _now,
      expiresAt: expiresAt ?? _now.add(const Duration(days: 180)),
      amountPaid: amountPaid ?? 6300,
      createdAt: _now,
      updatedAt: _now,
    );
  }

  // ─── CouponModel ──────────────────────────────────────────────────────

  static CouponModel coupon({
    String id = 'coupon-001',
    String code = 'SAVE20',
    int discountPercentage = 20,
    DateTime? validUntil,
    bool isActive = true,
  }) {
    return CouponModel(
      id: id,
      code: code,
      offerName: 'Test Offer',
      validUntil: validUntil ?? _now.add(const Duration(days: 30)),
      discountPercentage: discountPercentage,
      isActive: isActive,
      createdAt: _now,
      updatedAt: _now,
    );
  }

  // ─── DailyRewardModel ─────────────────────────────────────────────────

  static DailyRewardModel dailyReward({
    int streakCount = 3,
    bool isClaimedToday = false,
    RewardPayload? lastReward,
  }) {
    return DailyRewardModel(
      streakCount: streakCount,
      isClaimedToday: isClaimedToday,
      lastReward: lastReward,
    );
  }

  // ─── ReferralModel ────────────────────────────────────────────────────

  static ReferralModel referral({
    String id = 'ref-001',
    String referrerId = 'user-uuid-001',
    String? referredUserId,
    ReferralStatus status = ReferralStatus.pending,
  }) {
    return ReferralModel(
      id: id,
      referrerId: referrerId,
      referredUserId: referredUserId,
      status: status,
      createdAt: _now,
    );
  }

  // ─── ReferralStatsModel ───────────────────────────────────────────────

  static ReferralStatsModel referralStats({
    String userId = 'user-uuid-001',
    int referralCount = 5,
    int rewardsEarned = 3,
  }) {
    return ReferralStatsModel(
      userId: userId,
      referralCount: referralCount,
      rewardsEarned: rewardsEarned,
      updatedAt: _now,
    );
  }

  // ─── FilterCriteria ───────────────────────────────────────────────────

  static FilterCriteria filter({
    int? minAge,
    int? maxAge,
    String? gender,
    String? state,
  }) {
    return FilterCriteria(
      minAge: minAge,
      maxAge: maxAge,
      gender: gender,
      state: state,
    );
  }
}
