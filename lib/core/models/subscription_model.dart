import 'package:meta/meta.dart';

/// Subscription plan types
enum PlanType {
  free,
  // Self-Service plans
  standard,
  silver,
  gold,
  platinum,
  eternal,
  // VIP Matchmaker plans
  elite,
  royal,
  // ignore: constant_identifier_names
  eternal_elite,
  // Legacy / Special
  // ignore: constant_identifier_names
  biodata_unlock,
  basic,
  premium,
  vip,
  unknown;

  String get displayName {
    switch (this) {
      case PlanType.free:
        return 'Free';
      case PlanType.standard:
        return 'Standard';
      case PlanType.silver:
        return 'Silver';
      case PlanType.gold:
        return 'Gold';
      case PlanType.platinum:
        return 'Platinum';
      case PlanType.eternal:
        return 'Eternal';
      case PlanType.elite:
        return 'Elite';
      case PlanType.royal:
        return 'Royal';
      case PlanType.eternal_elite:
        return 'Eternal Elite';
      case PlanType.biodata_unlock:
        return 'Biodata Premium';
      case PlanType.basic:
        return 'Basic';
      case PlanType.premium:
        return 'Premium';
      case PlanType.vip:
        return 'VIP';
      case PlanType.unknown:
        return 'Free';
    }
  }

  /// Whether this is a VIP Matchmaker plan
  bool get isVipPlan {
    return this == PlanType.elite ||
        this == PlanType.royal ||
        this == PlanType.eternal_elite;
  }

  /// Whether this is a Self-Service paid plan
  bool get isSelfServicePlan {
    return this == PlanType.standard ||
        this == PlanType.silver ||
        this == PlanType.gold ||
        this == PlanType.platinum ||
        this == PlanType.eternal;
  }

  /// Whether this is any paid plan (Self-Service or VIP)
  bool get isPaidPlan => isSelfServicePlan || isVipPlan;

  static PlanType fromString(String value) {
    switch (value.toLowerCase()) {
      case 'standard':
        return PlanType.standard;
      case 'silver':
        return PlanType.silver;
      case 'gold':
        return PlanType.gold;
      case 'platinum':
        return PlanType.platinum;
      case 'eternal':
        return PlanType.eternal;
      case 'elite':
        return PlanType.elite;
      case 'royal':
        return PlanType.royal;
      case 'eternal_elite':
        return PlanType.eternal_elite;
      case 'biodata_unlock':
        return PlanType.biodata_unlock;
      case 'basic':
        return PlanType.basic;
      case 'premium':
        return PlanType.premium;
      case 'vip':
        return PlanType.vip;
      default:
        return PlanType.free;
    }
  }
}

/// Subscription status
enum SubscriptionStatus {
  active,
  expired,
  cancelled,
  pending;

  static SubscriptionStatus fromString(String value) {
    switch (value.toLowerCase()) {
      case 'active':
        return SubscriptionStatus.active;
      case 'expired':
        return SubscriptionStatus.expired;
      case 'cancelled':
        return SubscriptionStatus.cancelled;
      default:
        return SubscriptionStatus.pending;
    }
  }
}

/// Subscription model
@immutable
class SubscriptionModel {
  final String id;
  final String userId;
  final PlanType planType;
  final SubscriptionStatus status;
  final DateTime startedAt;
  final DateTime? expiresAt;
  final String? razorpaySubscriptionId;
  final bool autoRenew;
  final double? amountPaid;
  final DateTime createdAt;
  final DateTime updatedAt;

  const SubscriptionModel({
    required this.id,
    required this.userId,
    required this.planType,
    required this.status,
    required this.startedAt,
    this.expiresAt,
    this.razorpaySubscriptionId,
    this.autoRenew = false,
    this.amountPaid,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Check if subscription is currently active
  bool get isActive {
    if (status != SubscriptionStatus.active) return false;
    if (expiresAt == null) return true; // Eternal plans
    return expiresAt!.isAfter(DateTime.now());
  }

  /// Check if user has premium access (any paid plan)
  bool get isPremium {
    return isActive && planType.isPaidPlan;
  }

  /// Check if user is on a VIP plan
  bool get isVip {
    return isActive && planType.isVipPlan;
  }

  /// Days remaining until expiry
  int? get daysRemaining {
    if (expiresAt == null) return null; // Eternal = no expiry
    return expiresAt!.difference(DateTime.now()).inDays;
  }

  factory SubscriptionModel.fromJson(Map<String, dynamic> json) {
    DateTime parseOrNow(dynamic v) =>
        v != null ? DateTime.tryParse(v.toString()) ?? DateTime.now() : DateTime.now();
    return SubscriptionModel(
      id: json['id']?.toString() ?? '',
      userId: json['user_id']?.toString() ?? '',
      planType: PlanType.fromString(json['plan_type']?.toString() ?? 'free'),
      status: SubscriptionStatus.fromString(
        json['status']?.toString() ?? 'active',
      ),
      startedAt: parseOrNow(json['started_at']),
      expiresAt: json['expires_at'] != null
          ? DateTime.tryParse(json['expires_at'].toString())
          : null,
      razorpaySubscriptionId: json['razorpay_subscription_id']?.toString(),
      autoRenew: json['auto_renew'] as bool? ?? false,
      amountPaid: (json['amount_paid'] as num?)?.toDouble(),
      createdAt: parseOrNow(json['createdAt']),
      updatedAt: parseOrNow(json['updatedAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'plan_type': planType.name,
      'status': status.name,
      'started_at': startedAt.toIso8601String(),
      'expires_at': expiresAt?.toIso8601String(),
      'razorpay_subscription_id': razorpaySubscriptionId,
      'auto_renew': autoRenew,
      'amount_paid': amountPaid,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  SubscriptionModel copyWith({
    String? id,
    String? userId,
    PlanType? planType,
    SubscriptionStatus? status,
    DateTime? startedAt,
    DateTime? expiresAt,
    String? razorpaySubscriptionId,
    bool? autoRenew,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return SubscriptionModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      planType: planType ?? this.planType,
      status: status ?? this.status,
      startedAt: startedAt ?? this.startedAt,
      expiresAt: expiresAt ?? this.expiresAt,
      razorpaySubscriptionId:
          razorpaySubscriptionId ?? this.razorpaySubscriptionId,
      autoRenew: autoRenew ?? this.autoRenew,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  String toString() {
    return 'SubscriptionModel(planType: $planType, status: $status, isPremium: $isPremium, isVip: $isVip)';
  }
}
