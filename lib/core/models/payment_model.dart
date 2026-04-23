import 'package:meta/meta.dart';

/// Payment status
enum PaymentStatus {
  created,
  authorized,
  captured,
  failed,
  refunded;

  static PaymentStatus fromString(String value) {
    switch (value.toLowerCase()) {
      case 'authorized':
        return PaymentStatus.authorized;
      case 'captured':
        return PaymentStatus.captured;
      case 'failed':
        return PaymentStatus.failed;
      case 'refunded':
        return PaymentStatus.refunded;
      default:
        return PaymentStatus.created;
    }
  }
}

/// Payment model
@immutable
class PaymentModel {
  final String id;
  final String userId;
  final String? subscriptionId;
  final int amount; // in paise
  final String currency;
  final PaymentStatus status;
  final String? razorpayOrderId;
  final String? razorpayPaymentId;
  final String? razorpaySignature;
  final String planType;
  final int? planDuration; // in months
  final String? appSlug;
  final Map<String, dynamic>? metadata;
  final String? notes;
  final DateTime createdAt;
  final DateTime updatedAt;

  const PaymentModel({
    required this.id,
    required this.userId,
    this.subscriptionId,
    required this.amount,
    this.currency = 'INR',
    required this.status,
    this.razorpayOrderId,
    this.razorpayPaymentId,
    this.razorpaySignature,
    required this.planType,
    this.planDuration,
    this.appSlug,
    this.metadata,
    this.notes,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Get amount in rupees
  double get amountInRupees => amount / 100.0;

  /// Check if payment is successful
  bool get isSuccessful =>
      status == PaymentStatus.captured || status == PaymentStatus.authorized;

  factory PaymentModel.fromJson(Map<String, dynamic> json) {
    DateTime parseOrNow(dynamic v) =>
        v != null ? DateTime.tryParse(v.toString()) ?? DateTime.now() : DateTime.now();
    return PaymentModel(
      id: json['id']?.toString() ?? '',
      userId: json['user_id']?.toString() ?? '',
      subscriptionId: json['subscription_id']?.toString(),
      amount: (json['amount'] as num?)?.toInt() ?? 0,
      currency: json['currency']?.toString() ?? 'INR',
      status: PaymentStatus.fromString(json['status']?.toString() ?? 'created'),
      razorpayOrderId: json['razorpay_order_id']?.toString(),
      razorpayPaymentId: json['razorpay_payment_id']?.toString(),
      razorpaySignature: json['razorpay_signature']?.toString(),
      planType: json['plan_type']?.toString() ?? 'free',
      planDuration: (json['plan_duration'] as num?)?.toInt(),
      appSlug: json['app_slug']?.toString(),
      metadata: json['metadata'] != null
          ? Map<String, dynamic>.from(json['metadata'] as Map)
          : null,
      notes: json['notes']?.toString(),
      createdAt: parseOrNow(json['created_at']),
      updatedAt: parseOrNow(json['updated_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'subscription_id': subscriptionId,
      'amount': amount,
      'currency': currency,
      'status': status.name,
      'razorpay_order_id': razorpayOrderId,
      'razorpay_payment_id': razorpayPaymentId,
      'razorpay_signature': razorpaySignature,
      'plan_type': planType,
      'plan_duration': planDuration,
      'app_slug': appSlug,
      'metadata': metadata,
      'notes': notes,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  PaymentModel copyWith({
    String? id,
    String? userId,
    String? subscriptionId,
    int? amount,
    String? currency,
    PaymentStatus? status,
    String? razorpayOrderId,
    String? razorpayPaymentId,
    String? razorpaySignature,
    String? planType,
    int? planDuration,
    String? appSlug,
    Map<String, dynamic>? metadata,
    String? notes,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return PaymentModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      subscriptionId: subscriptionId ?? this.subscriptionId,
      amount: amount ?? this.amount,
      currency: currency ?? this.currency,
      status: status ?? this.status,
      razorpayOrderId: razorpayOrderId ?? this.razorpayOrderId,
      razorpayPaymentId: razorpayPaymentId ?? this.razorpayPaymentId,
      razorpaySignature: razorpaySignature ?? this.razorpaySignature,
      planType: planType ?? this.planType,
      planDuration: planDuration ?? this.planDuration,
      appSlug: appSlug ?? this.appSlug,
      metadata: metadata ?? this.metadata,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  String toString() {
    return 'PaymentModel(amount: ₹$amountInRupees, status: $status, planType: $planType)';
  }
}
