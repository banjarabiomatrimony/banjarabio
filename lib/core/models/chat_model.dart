import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';
import 'package:banjarabio/core/session_manager.dart';

@immutable
class ConversationModel extends Equatable {
  final String id;
  final String participantOneId;
  final String participantTwoId;
  final String? lastMessageText;
  final DateTime lastMessageAt; // conversations_view / 15_chat; default NOW()
  final int unreadCountOne;
  final int unreadCountTwo;
  final DateTime createdAt;
  final DateTime updatedAt;

  // Participant Details (Injected via View/JSON)
  final String? otherParticipantName;
  final String? otherParticipantImageUrl;

  const ConversationModel({
    required this.id,
    required this.participantOneId,
    required this.participantTwoId,
    this.lastMessageText,
    required this.lastMessageAt,
    this.unreadCountOne = 0,
    this.unreadCountTwo = 0,
    required this.createdAt,
    required this.updatedAt,
    this.otherParticipantName,
    this.otherParticipantImageUrl,
  });

  String get otherParticipantId {
    final myId = SessionManager.instance.profileId;
    return participantOneId == myId ? participantTwoId : participantOneId;
  }

  factory ConversationModel.fromJson(Map<String, dynamic> json) {
    DateTime parseOrNow(dynamic v) =>
        v != null ? DateTime.tryParse(v.toString()) ?? DateTime.now() : DateTime.now();
    return ConversationModel(
      id: json['id']?.toString() ?? '',
      participantOneId: json['participant_one_id']?.toString() ?? '',
      participantTwoId: json['participant_two_id']?.toString() ?? '',
      lastMessageText: json['last_message_text']?.toString(),
      lastMessageAt: parseOrNow(json['last_message_at']),
      unreadCountOne: (json['unread_count_one'] as num?)?.toInt() ?? 0,
      unreadCountTwo: (json['unread_count_two'] as num?)?.toInt() ?? 0,
      createdAt: parseOrNow(json['created_at']),
      updatedAt: parseOrNow(json['updated_at']),
      otherParticipantName: json['other_participant_name']?.toString(),
      otherParticipantImageUrl: json['other_participant_image_url']?.toString(),
    );
  }

  @override
  List<Object?> get props => [
    id,
    lastMessageAt,
    unreadCountOne,
    unreadCountTwo,
    updatedAt,
  ];
}

@immutable
class MessageModel extends Equatable {
  final String id;
  final String conversationId;
  final String senderId;
  final String messageText;
  final bool isRead;
  final DateTime createdAt;

  const MessageModel({
    required this.id,
    required this.conversationId,
    required this.senderId,
    required this.messageText,
    this.isRead = false,
    required this.createdAt,
  });

  factory MessageModel.fromJson(Map<String, dynamic> json) {
    final createdAt = json['created_at'] != null
        ? DateTime.tryParse(json['created_at'].toString()) ?? DateTime.now()
        : DateTime.now();
    return MessageModel(
      id: json['id']?.toString() ?? '',
      conversationId: json['conversation_id']?.toString() ?? '',
      senderId: json['sender_id']?.toString() ?? '',
      messageText: json['message_text']?.toString() ?? '',
      isRead: json['is_read'] as bool? ?? false,
      createdAt: createdAt,
    );
  }

  @override
  List<Object?> get props => [id, createdAt, isRead];
}

@immutable
class ProfileViewModel extends Equatable {
  final String id;
  final String viewerId;
  final String viewedId;
  final int viewCount;
  final DateTime lastViewedAt;

  // Viewer Details
  final String? viewerName;
  final String? viewerImageUrl;

  const ProfileViewModel({
    required this.id,
    required this.viewerId,
    required this.viewedId,
    required this.viewCount,
    required this.lastViewedAt,
    this.viewerName,
    this.viewerImageUrl,
  });

  factory ProfileViewModel.fromJson(Map<String, dynamic> json) {
    return ProfileViewModel(
      id: json['id']?.toString() ?? '',
      viewerId: json['viewer_id']?.toString() ?? '',
      viewedId: json['viewed_id']?.toString() ?? '',
      viewCount: (json['view_count'] as num?)?.toInt() ?? 1,
      lastViewedAt: json['last_viewed_at'] != null
          ? DateTime.tryParse(json['last_viewed_at'].toString()) ?? DateTime.now()
          : DateTime.now(),
      viewerName: json['viewer_name']?.toString(),
      viewerImageUrl: json['viewer_image_url']?.toString(),
    );
  }

  @override
  List<Object?> get props => [id, viewCount, lastViewedAt];
}
