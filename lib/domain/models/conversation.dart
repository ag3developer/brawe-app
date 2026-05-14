class Conversation {
  const Conversation({
    required this.id,
    required this.participantId,
    required this.participantName,
    this.participantUsername,
    this.participantAvatarUrl,
    this.lastMessage,
    this.unreadCount = 0,
    required this.updatedAt,
    this.isArchived = false,
    this.isOnline = false,
    this.lastSeen,
  });

  final String id;
  final String participantId;
  final String participantName;
  final String? participantUsername;
  final String? participantAvatarUrl;
  final ChatMessage? lastMessage;
  final int unreadCount;
  final DateTime updatedAt;
  final bool isArchived;
  final bool isOnline;
  final DateTime? lastSeen;

  Conversation copyWith({
    String? id,
    String? participantId,
    String? participantName,
    String? participantUsername,
    String? participantAvatarUrl,
    ChatMessage? lastMessage,
    int? unreadCount,
    DateTime? updatedAt,
    bool? isArchived,
    bool? isOnline,
    DateTime? lastSeen,
  }) {
    return Conversation(
      id: id ?? this.id,
      participantId: participantId ?? this.participantId,
      participantName: participantName ?? this.participantName,
      participantUsername: participantUsername ?? this.participantUsername,
      participantAvatarUrl: participantAvatarUrl ?? this.participantAvatarUrl,
      lastMessage: lastMessage ?? this.lastMessage,
      unreadCount: unreadCount ?? this.unreadCount,
      updatedAt: updatedAt ?? this.updatedAt,
      isArchived: isArchived ?? this.isArchived,
      isOnline: isOnline ?? this.isOnline,
      lastSeen: lastSeen ?? this.lastSeen,
    );
  }

  /// Parse de um item retornado por `GET /messages/conversations`.
  factory Conversation.fromApi(Map<String, dynamic> json) {
    final lastMessageText = json['last_message_text']?.toString();
    final lastMessageAt = _parseDateTime(json['last_message_at']);
    final otherUserId = json['other_user_id']?.toString() ?? '';
    final convId = json['id']?.toString() ?? '';

    ChatMessage? last;
    if (lastMessageText != null && lastMessageText.isNotEmpty) {
      last = ChatMessage(
        id: 'last-$convId',
        conversationId: convId,
        senderId: '',
        content: lastMessageText,
        timestamp: lastMessageAt ?? DateTime.now(),
      );
    }

    return Conversation(
      id: convId,
      participantId: otherUserId,
      participantName: json['other_user_name']?.toString() ?? 'User',
      participantUsername: json['other_username']?.toString(),
      participantAvatarUrl: json['other_user_avatar']?.toString(),
      lastMessage: last,
      unreadCount: _parseInt(json['unread_count']),
      updatedAt: lastMessageAt ?? _parseDateTime(json['created_at']) ?? DateTime.now(),
      isArchived: json['is_archived'] == true,
      isOnline: json['is_online'] == true,
      lastSeen: _parseDateTime(json['last_seen']),
    );
  }
}

class ChatMessage {
  const ChatMessage({
    required this.id,
    required this.conversationId,
    required this.senderId,
    required this.content,
    required this.timestamp,
    this.isRead = false,
    this.isPending = false,
    this.messageType = 'text',
    this.isViewOnce = false,
    this.isBurned = false,
    this.viewedAt,
  });

  final String id;
  final String conversationId;
  final String senderId;
  final String content;
  final DateTime timestamp;
  final bool isRead;
  final bool isPending;
  final String messageType;
  final bool isViewOnce;
  final bool isBurned;
  final DateTime? viewedAt;

  ChatMessage copyWith({
    String? id,
    String? conversationId,
    String? senderId,
    String? content,
    DateTime? timestamp,
    bool? isRead,
    bool? isPending,
    String? messageType,
    bool? isViewOnce,
    bool? isBurned,
    DateTime? viewedAt,
  }) {
    return ChatMessage(
      id: id ?? this.id,
      conversationId: conversationId ?? this.conversationId,
      senderId: senderId ?? this.senderId,
      content: content ?? this.content,
      timestamp: timestamp ?? this.timestamp,
      isRead: isRead ?? this.isRead,
      isPending: isPending ?? this.isPending,
      messageType: messageType ?? this.messageType,
      isViewOnce: isViewOnce ?? this.isViewOnce,
      isBurned: isBurned ?? this.isBurned,
      viewedAt: viewedAt ?? this.viewedAt,
    );
  }

  /// Parse a partir de `GET /messages/conversations/{id}` ou socket `new_message`.
  factory ChatMessage.fromApi(
    Map<String, dynamic> json, {
    String? fallbackConversationId,
  }) {
    return ChatMessage(
      id: json['id']?.toString() ??
          DateTime.now().microsecondsSinceEpoch.toString(),
      conversationId: json['conversation_id']?.toString() ??
          fallbackConversationId ??
          '',
      senderId: json['sender_id']?.toString() ?? '',
      content: json['content']?.toString() ?? '',
      timestamp:
          _parseDateTime(json['created_at']) ?? DateTime.now(),
      isRead: json['is_read'] == true,
      messageType: json['message_type']?.toString() ?? 'text',
      isViewOnce: json['is_view_once'] == true,
      isBurned: json['is_burned'] == true,
      viewedAt: _parseDateTime(json['viewed_at']),
    );
  }
}

DateTime? _parseDateTime(dynamic value) {
  if (value == null) return null;
  final s = value.toString();
  if (s.isEmpty) return null;
  return DateTime.tryParse(s)?.toLocal();
}

int _parseInt(dynamic value) {
  if (value is int) return value;
  if (value is num) return value.toInt();
  return int.tryParse(value?.toString() ?? '') ?? 0;
}
