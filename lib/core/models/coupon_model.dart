import 'package:intl/intl.dart';

class CouponModel {
  final String id;
  final String code;
  final String offerName;
  final String? description;
  final DateTime validUntil;
  final int discountPercentage;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String? bannerUrl;
  final Map<String, dynamic>? targetFilters;

  CouponModel({
    required this.id,
    required this.code,
    required this.offerName,
    this.description,
    required this.validUntil,
    required this.discountPercentage,
    this.isActive = true,
    required this.createdAt,
    required this.updatedAt,
    this.bannerUrl,
    this.targetFilters,
  });

  factory CouponModel.fromJson(Map<String, dynamic> json) => CouponModel(
        id: json['id'] as String,
        code: json['code'] as String,
        offerName: json['offer_name'] as String,
        description: json['description'] as String?,
        validUntil: DateTime.parse(json['valid_until'] as String),
        discountPercentage: (json['discount_percentage'] as num).toInt(),
        isActive: json['is_active'] as bool? ?? true,
        createdAt: DateTime.parse(json['created_at'] as String),
        updatedAt: DateTime.parse(json['updated_at'] as String),
        bannerUrl: json['banner_url'] as String?,
        targetFilters: json['target_filters'] != null
            ? Map<String, dynamic>.from(json['target_filters'] as Map)
            : null,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'code': code,
        'offer_name': offerName,
        'description': description,
        'valid_until': DateFormat('yyyy-MM-dd').format(validUntil),
        'discount_percentage': discountPercentage,
        'is_active': isActive,
        'created_at': createdAt.toIso8601String(),
        'updated_at': updatedAt.toIso8601String(),
        'banner_url': bannerUrl,
        'target_filters': targetFilters,
      };

  bool get isExpired {
    final now = DateTime.now();
    return validUntil.isBefore(DateTime(now.year, now.month, now.day));
  }

  bool get isValidToday {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final couponDate = DateTime(validUntil.year, validUntil.month, validUntil.day);
    return couponDate.isAtSameMomentAs(today) && isActive;
  }
}
