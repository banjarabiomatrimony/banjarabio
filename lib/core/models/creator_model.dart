class Creator {
  final String id;
  final String name;
  final String promoCode;
  final double commissionPct;
  final String? instagramHandle;
  final String? phoneNumber;
  final int totalReferrals;
  final int totalConversions;
  final double totalCommissionEarned;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;

  Creator({
    required this.id,
    required this.name,
    required this.promoCode,
    required this.commissionPct,
    this.instagramHandle,
    this.phoneNumber,
    this.totalReferrals = 0,
    this.totalConversions = 0,
    this.totalCommissionEarned = 0,
    this.isActive = true,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Creator.fromJson(Map<String, dynamic> json) => Creator(
        id: json['id'] as String,
        name: json['name'] as String,
        promoCode: json['promo_code'] as String,
        commissionPct: (json['commission_pct'] as num).toDouble(),
        instagramHandle: json['instagram_handle'] as String?,
        phoneNumber: json['phone_number'] as String?,
        totalReferrals: (json['total_referrals'] as num?)?.toInt() ?? 0,
        totalConversions: (json['total_conversions'] as num?)?.toInt() ?? 0,
        totalCommissionEarned: (json['total_commission_earned'] as num?)?.toDouble() ?? 0,
        isActive: json['is_active'] as bool? ?? true,
        createdAt: DateTime.parse(json['created_at'] as String),
        updatedAt: DateTime.parse(json['updated_at'] as String),
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'promo_code': promoCode,
        'commission_pct': commissionPct,
        'instagram_handle': instagramHandle,
        'phone_number': phoneNumber,
        'total_referrals': totalReferrals,
        'total_conversions': totalConversions,
        'total_commission_earned': totalCommissionEarned,
        'is_active': isActive,
        'created_at': createdAt.toIso8601String(),
        'updated_at': updatedAt.toIso8601String(),
      };
}
