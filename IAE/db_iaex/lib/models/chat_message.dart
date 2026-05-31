/// Chat message model with message type support
class ChatMessage {
  final int id;
  final int? senderId;
  final String senderName;
  final String? senderImage;
  final int? receiverId;
  final int? groupId;
  final String message;
  final String type; // text, activity_invite, event_reminder
  final int? linkedActivityId;
  final String? linkedActivityTitle;
  final String? time;
  final String? createdAt;
  final bool isMe;

  const ChatMessage({
    required this.id,
    this.senderId,
    required this.senderName,
    this.senderImage,
    this.receiverId,
    this.groupId,
    required this.message,
    this.type = 'text',
    this.linkedActivityId,
    this.linkedActivityTitle,
    this.time,
    this.createdAt,
    this.isMe = false,
  });

  factory ChatMessage.fromJson(Map<String, dynamic> json, {int? currentUserId}) {
    final senderId = json['sender_id'] as int?;
    return ChatMessage(
      id: json['id'] as int,
      senderId: senderId,
      senderName: json['sender_name'] as String? ?? '',
      senderImage: json['sender_image'] as String?,
      receiverId: json['receiver_id'] as int?,
      groupId: json['group_id'] as int?,
      message: json['message'] as String? ?? '',
      type: json['type'] as String? ?? 'text',
      linkedActivityId: json['linked_activity_id'] as int?,
      linkedActivityTitle: json['linked_activity_title'] as String?,
      time: json['time'] as String?,
      createdAt: json['created_at'] as String?,
      isMe: json['is_me'] as bool? ?? (currentUserId != null && senderId != null && senderId == currentUserId),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id, 'sender_id': senderId, 'receiver_id': receiverId,
        'group_id': groupId, 'message': message, 'type': type,
        'linked_activity_id': linkedActivityId,
      };
}

/// Chat conversation preview (for list screen)
class ChatConversation {
  final int id;
  final String name;
  final String? image;
  final String? lastMessage;
  final String? lastMessageTime;
  final int unreadCount;
  final bool isGroup;

  const ChatConversation({
    required this.id,
    required this.name,
    this.image,
    this.lastMessage,
    this.lastMessageTime,
    this.unreadCount = 0,
    this.isGroup = false,
  });

  factory ChatConversation.fromJson(Map<String, dynamic> json) {
    return ChatConversation(
      id: json['id'] as int,
      name: json['name'] as String? ?? '',
      image: json['image'] as String?,
      lastMessage: json['last_message'] as String?,
      lastMessageTime: json['time'] as String?,
      unreadCount: json['unread_count'] as int? ?? 0,
      isGroup: json['is_group'] as bool? ?? false,
    );
  }
}
