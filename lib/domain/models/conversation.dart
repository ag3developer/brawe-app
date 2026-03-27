class Conversation {
  const Conversation({
    required this.id,
    required this.participantId,
    required this.participantName,
    this.participantAvatarUrl,
    this.lastMessage,
    this.unreadCount = 0,
    required this.updatedAt,
  });

  final String id;
  final String participantId;
  final String participantName;
  final String? participantAvatarUrl;
  final ChatMessage? lastMessage;
  final int unreadCount;
  final DateTime updatedAt;

  Conversation copyWith({
    String? id,
    String? participantId,
    String? participantName,
    String? participantAvatarUrl,
    ChatMessage? lastMessage,
    int? unreadCount,
    DateTime? updatedAt,
  }) {
    return Conversation(
      id: id ?? this.id,
      participantId: participantId ?? this.participantId,
      participantName: participantName ?? this.participantName,
      participantAvatarUrl: participantAvatarUrl ?? this.participantAvatarUrl,
      lastMessage: lastMessage ?? this.lastMessage,
      unreadCount: unreadCount ?? this.unreadCount,
      updatedAt: updatedAt ?? this.updatedAt,
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
  });

  final String id;
  final String conversationId;
  final String senderId;
  final String content;
  final DateTime timestamp;
  final bool isRead;
  final bool isPending;

  ChatMessage copyWith({
    String? id,
    String? conversationId,
    String? senderId,
    String? content,
    DateTime? timestamp,
    bool? isRead,
    bool? isPending,
  }) {
    return ChatMessage(
      id: id ?? this.id,
      conversationId: conversationId ?? this.conversationId,
      senderId: senderId ?? this.senderId,
      content: content ?? this.content,
      timestamp: timestamp ?? this.timestamp,
      isRead: isRead ?? this.isRead,
      isPending: isPending ?? this.isPending,
    );
  }
}
