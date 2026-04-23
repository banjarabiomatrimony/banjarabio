import 'package:meta/meta.dart';

/// Model for a profile share record
@immutable
class ProfileShare {
  final String id;
  final String sharerId; // User who shared
  final String? recipientId; // User who received (nullable for external shares)
  final String? recipientName; // Name if shared externally (metadata)
  final String? recipientRelation; // Relationship (Friend, Family, etc.)
  final String? sharerName; // Sharer's profile name (from view)
  final String? recipientProfileName; // Recipient's profile name when in-app (from view)
  final String sharedProfileId; // Profile that was shared
  final String? sharedProfileName;
  final int? sharedProfileAge;
  final String? sharedProfileImage;
  final String? education;
  final String? job;
  final String? height;
  final String? maritalStatus;
  final String? surname;
  final bool? isVerified;
  final bool? isPremium;
  final String sharingMethod; // 'whatsapp', 'in_app', 'link'
  final String status; // 'pending', 'viewed', 'interested', 'rejected', 'new', 'matched'
  final int viewCount;
  final DateTime createdAt;
  final DateTime? viewedAt;

  const ProfileShare({
    required this.id,
    required this.sharerId,
    this.recipientId,
    this.recipientName,
    this.recipientRelation,
    this.sharerName,
    this.recipientProfileName,
    required this.sharedProfileId,
    this.sharedProfileName,
    this.sharedProfileAge,
    this.sharedProfileImage,
    this.education,
    this.job,
    this.height,
    this.maritalStatus,
    this.surname,
    this.isVerified,
    this.isPremium,
    required this.sharingMethod,
    required this.status,
    required this.viewCount,
    required this.createdAt,
    this.viewedAt,
  });

  factory ProfileShare.fromJson(Map<String, dynamic> json) {
    // Handle nested profile data, view columns (shared_profile_*), or flat fallbacks (full_name, age, image_url)
    final sharedProfile = json['shared_profile'] as Map<String, dynamic>?;

    return ProfileShare(
      id: (json['id'] ?? json['share_id'])?.toString() ?? '',
      sharerId: json['sharer_id']?.toString() ?? '',
      recipientId: json['recipient_id']?.toString(),
      recipientName: json['recipient_name']?.toString(),
      recipientRelation: json['recipient_relation']?.toString(),
      sharerName: json['sharer_name']?.toString(),
      recipientProfileName: json['recipient_profile_name']?.toString(),
      sharedProfileId: json['shared_profile_id']?.toString() ?? '',
      sharedProfileName:
          json['shared_profile_name']?.toString() ??
          json['full_name']?.toString() ??
          sharedProfile?['full_name']?.toString(),
      sharedProfileAge:
          (json['shared_profile_age'] as num?)?.toInt() ??
          (json['age'] as num?)?.toInt() ??
          (sharedProfile?['age'] as num?)?.toInt(),
      sharedProfileImage:
          json['shared_profile_image']?.toString() ??
          json['image_url']?.toString() ??
          sharedProfile?['public_url']?.toString(),
      education:
          (json['shared_profile_education'] ??
                  json['education'] ??
                  sharedProfile?['education'])
              ?.toString(),
      job: (json['shared_profile_job'] ??
              json['profession'] ??
              sharedProfile?['job'])
          ?.toString(),
      height: (json['shared_profile_height'] ?? json['height'] ?? sharedProfile?['height'])
          ?.toString(),
      maritalStatus:
          (json['shared_profile_marital_status'] ??
                  json['marital_status'] ??
                  sharedProfile?['marital_status'])
              ?.toString(),
      surname: (json['shared_profile_surname'] ??
              json['surname'] ??
              sharedProfile?['surname'])
          ?.toString(),
      isVerified:
          (json['shared_profile_is_verified'] ??
                  json['is_verified'] ??
                  sharedProfile?['is_verified']) as bool?,
      isPremium:
          (json['shared_profile_is_premium'] ??
                  json['is_premium'] ??
                  sharedProfile?['is_premium']) as bool?,
      sharingMethod: json['sharing_method']?.toString() ?? 'in_app',
      status: json['status']?.toString() ?? 'pending',
      viewCount: (json['view_count'] as num?)?.toInt() ?? 0,
      createdAt: (json['share_created_at'] ?? json['created_at']) != null
          ? DateTime.parse(
              (json['share_created_at'] ?? json['created_at']).toString(),
            )
          : DateTime.now(),
      viewedAt: json['viewed_at'] != null
          ? DateTime.parse(json['viewed_at'].toString())
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'sharer_id': sharerId,
    'recipient_id': recipientId,
    'recipient_name': recipientName,
    'recipient_relation': recipientRelation,
    'shared_profile_id': sharedProfileId,
    'sharing_method': sharingMethod,
    'status': status,
    'view_count': viewCount,
  };

  /// Convert to map for UI widgets (backward compatible)
  Map<String, dynamic> toDisplayMap({required bool isSharedByMe}) {
    final base = {
      'id': id,
      'sharedProfileName': sharedProfileName ?? 'Unknown',
      'sharedProfileAge': sharedProfileAge ?? 0,
      'sharedProfileImage': sharedProfileImage,
      'education': education ?? 'N/A',
      'job': job ?? 'N/A',
      'height': height ?? 'N/A',
      'maritalStatus': maritalStatus ?? 'N/A',
      'surname': surname ?? 'N/A',
      'isVerified': isVerified ?? false,
      'isPremium': isPremium ?? false,
      'timestamp': createdAt,
      'sharingMethod': _formatSharingMethod(sharingMethod),
      'status': _formatStatus(status),
      'viewCount': viewCount,
      'sharedProfileId': sharedProfileId,
    };

    if (isSharedByMe) {
      base['recipientName'] =
          recipientProfileName ?? recipientName ?? 'Unknown';
      base['recipientRelation'] = recipientRelation ?? 'Contact';
    } else {
      base['senderName'] = sharerName ?? recipientName ?? 'Unknown';
      base['senderRelation'] = recipientRelation ?? 'Contact';
    }
    return base;
  }

  String _formatSharingMethod(String method) {
    switch (method.toLowerCase()) {
      case 'whatsapp':
        return 'WhatsApp';
      case 'in_app':
        return 'In-App';
      case 'link':
        return 'Link';
      default:
        return method;
    }
  }

  /// For matched tab: returns the other person's display name
  String? otherPersonName(String? myProfileId) {
    if (myProfileId == null) {
      return sharerName ?? recipientProfileName ?? recipientName;
    }
    return sharerId == myProfileId
        ? (recipientProfileName ?? recipientName)
        : sharerName;
  }

  String _formatStatus(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return 'Pending';
      case 'viewed':
        return 'Viewed';
      case 'interested':
        return 'Interested';
      case 'rejected':
        return 'Rejected';
      case 'new':
        return 'New';
      case 'matched':
        return 'Matched';
      default:
        return status;
    }
  }
}
