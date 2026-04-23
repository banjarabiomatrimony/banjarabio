import 'package:meta/meta.dart';

/// Referral status
enum ReferralStatus {
  pending,
  completed;

  static ReferralStatus fromString(String value) {
    switch (value.toLowerCase()) {
      case 'completed':
        return ReferralStatus.completed;
      default:
        return ReferralStatus.pending;
    }
  }
}

/// Referral model
@immutable
class ReferralModel {
  final String id;
  final String referrerId;
  final String? referredUserId;
  final ReferralStatus status;
  final DateTime createdAt;

  const ReferralModel({
    required this.id,
    required this.referrerId,
    this.referredUserId,
    required this.status,
    required this.createdAt,
  });

  factory ReferralModel.fromJson(Map<String, dynamic> json) {
    return ReferralModel(
      id: json['id']?.toString() ?? '',
      referrerId: json['referrer_id']?.toString() ?? '',
      referredUserId: json['referred_user_id']?.toString(),
      status: ReferralStatus.fromString(
        json['status']?.toString() ?? 'pending',
      ),
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'].toString()) ?? DateTime.now()
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'referrer_id': referrerId,
      'referred_user_id': referredUserId,
      'status': status.name,
      'created_at': createdAt.toIso8601String(),
    };
  }
}
