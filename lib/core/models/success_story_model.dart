

enum MarriageRewardStatus {
  pending,
  approved,
  visited,
  rejected,
}

enum MarriageRewardType {
  digital25,
  fullInvitation35,
}

class SuccessStoryModel {
  final String id;
  final String userId;
  final String? partnerName;
  final String? storyText;
  final String? instagramLink;
  final String? invitationCardUrl;
  final List<String> photoUrls;
  final DateTime weddingDate;
  final double subscriptionAmount;
  final MarriageRewardType type;
  final MarriageRewardStatus status;
  final DateTime createdAt;

  SuccessStoryModel({
    required this.id,
    required this.userId,
    this.partnerName,
    this.storyText,
    this.instagramLink,
    this.invitationCardUrl,
    this.photoUrls = const [],
    required this.weddingDate,
    required this.subscriptionAmount,
    required this.type,
    this.status = MarriageRewardStatus.pending,
    required this.createdAt,
  });

  factory SuccessStoryModel.fromJson(Map<String, dynamic> json) {
    return SuccessStoryModel(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      partnerName: json['partner_name'] as String?,
      storyText: json['story_text'] as String?,
      instagramLink: json['instagram_link'] as String?,
      invitationCardUrl: json['invitation_card_url'] as String?,
      photoUrls: (json['photo_urls'] as List<dynamic>?)?.map((e) => e as String).toList() ?? [],
      weddingDate: DateTime.parse(json['wedding_date'] as String),
      subscriptionAmount: (json['subscription_amount'] as num).toDouble(),
      type: MarriageRewardType.values.firstWhere(
        (e) => e.toString().split('.').last == json['reward_type'],
        orElse: () => MarriageRewardType.digital25,
      ),
      status: MarriageRewardStatus.values.firstWhere(
        (e) => e.toString().split('.').last == json['status'],
        orElse: () => MarriageRewardStatus.pending,
      ),
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'partner_name': partnerName,
      'story_text': storyText,
      'instagram_link': instagramLink,
      'invitation_card_url': invitationCardUrl,
      'photo_urls': photoUrls,
      'wedding_date': weddingDate.toIso8601String(),
      'subscription_amount': subscriptionAmount,
      'reward_type': type.toString().split('.').last,
      'status': status.toString().split('.').last,
    };
  }

  double calculateRefundAmount() {
    final percentage = type == MarriageRewardType.digital25 ? 0.25 : 0.35;
    return subscriptionAmount * percentage;
  }
}
