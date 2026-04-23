import 'package:equatable/equatable.dart';

class BannerModel extends Equatable {
  final String id;
  final String title;
  final String imageUrl;
  final String? actionUrl;
  final String? targetGender;
  final String? targetPlan;
  final int priority;
  final bool isActive;
  final DateTime? expiresAt;
  final DateTime createdAt;

  const BannerModel({
    required this.id,
    required this.title,
    required this.imageUrl,
    this.actionUrl,
    this.targetGender,
    this.targetPlan,
    this.priority = 0,
    this.isActive = true,
    this.expiresAt,
    required this.createdAt,
  });

  factory BannerModel.fromJson(Map<String, dynamic> json) {
    return BannerModel(
      id: json['id'] as String,
      title: json['title'] as String,
      imageUrl: json['image_url'] as String,
      actionUrl: json['action_url'] as String?,
      targetGender: json['target_gender'] as String?,
      targetPlan: json['target_plan'] as String?,
      priority: (json['priority'] as num?)?.toInt() ?? 0,
      isActive: json['is_active'] as bool? ?? true,
      expiresAt: json['expires_at'] != null ? DateTime.parse(json['expires_at'] as String) : null,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'image_url': imageUrl,
      'action_url': actionUrl,
      'target_gender': targetGender,
      'target_plan': targetPlan,
      'priority': priority,
      'is_active': isActive,
      'expires_at': expiresAt?.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
    };
  }

  @override
  List<Object?> get props => [
        id,
        title,
        imageUrl,
        actionUrl,
        targetGender,
        targetPlan,
        priority,
        isActive,
        expiresAt,
        createdAt,
      ];
}
