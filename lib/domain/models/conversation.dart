import 'dart:convert';

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
    this.participantIsVerified = false,
    this.isMuted = false,
    this.isPinned = false,
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
  final bool participantIsVerified;

  /// Silenciada por mim (sem push dessa conversa).
  final bool isMuted;

  /// Fixada no topo da lista (por mim).
  final bool isPinned;

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
    bool? participantIsVerified,
    bool? isMuted,
    bool? isPinned,
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
      participantIsVerified:
          participantIsVerified ?? this.participantIsVerified,
      isMuted: isMuted ?? this.isMuted,
      isPinned: isPinned ?? this.isPinned,
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
      participantIsVerified: json['other_user_is_verified'] == true,
      isMuted: json['is_muted'] == true,
      isPinned: json['is_pinned'] == true,
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
    this.replyToMessageId,
    this.replyTo,
    this.reactions = const {},
    this.audioDuration,
    this.editedAt,
    this.isForwarded = false,
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

  /// ID da mensagem citada (reply) — null se a mensagem não é resposta.
  final String? replyToMessageId;

  /// Preview denormalizado da mensagem citada (sender_id, content truncado, type).
  final ReplyPreview? replyTo;

  /// Reações por emoji: { "❤️": ["userId1", "userId2"], "🔥": ["userId3"] }
  final Map<String, List<String>> reactions;

  /// Duração em segundos (apenas para messageType == 'audio').
  final int? audioDuration;

  /// Quando foi editada (null = nunca).
  final DateTime? editedAt;

  /// Encaminhada de outra conversa.
  final bool isForwarded;

  /// Tipos cujo `content` é um JSON (cartões ricos).
  static const richTypes = {
    'live_invite',
    'story_reaction',
    'story_reply',
    'story_gift',
    'location',
    'file',
  };

  /// `content` decodificado quando a mensagem é de um tipo rico.
  Map<String, dynamic>? get payload {
    if (!richTypes.contains(messageType)) return null;
    try {
      final v = jsonDecode(content);
      return v is Map ? Map<String, dynamic>.from(v) : null;
    } catch (_) {
      return null;
    }
  }

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
    String? replyToMessageId,
    ReplyPreview? replyTo,
    Map<String, List<String>>? reactions,
    int? audioDuration,
    DateTime? editedAt,
    bool? isForwarded,
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
      replyToMessageId: replyToMessageId ?? this.replyToMessageId,
      replyTo: replyTo ?? this.replyTo,
      reactions: reactions ?? this.reactions,
      audioDuration: audioDuration ?? this.audioDuration,
      editedAt: editedAt ?? this.editedAt,
      isForwarded: isForwarded ?? this.isForwarded,
    );
  }

  /// Parse a partir de `GET /messages/conversations/{id}` ou socket `new_message`.
  factory ChatMessage.fromApi(
    Map<String, dynamic> json, {
    String? fallbackConversationId,
  }) {
    // reactions: backend retorna {"❤️": ["uid1", "uid2"], ...}
    final rawReactions = json['reactions'];
    final reactions = <String, List<String>>{};
    if (rawReactions is Map) {
      rawReactions.forEach((k, v) {
        if (v is List) {
          reactions[k.toString()] =
              v.map((e) => e.toString()).toList(growable: false);
        }
      });
    }

    // replyTo preview (opcional)
    ReplyPreview? replyTo;
    final rawReply = json['reply_to'];
    if (rawReply is Map) {
      replyTo = ReplyPreview.fromApi(Map<String, dynamic>.from(rawReply));
    }

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
      replyToMessageId: json['reply_to_message_id']?.toString(),
      replyTo: replyTo,
      reactions: reactions,
      audioDuration: json['audio_duration'] is int ? json['audio_duration'] as int : int.tryParse(json['audio_duration']?.toString() ?? ''),
      editedAt: _parseDateTime(json['edited_at']),
      isForwarded: json['is_forwarded'] == true,
    );
  }
}

/// Preview denormalizado da mensagem citada (retornada pelo backend).
class ReplyPreview {
  const ReplyPreview({
    required this.id,
    required this.senderId,
    required this.content,
    required this.messageType,
    this.isBurned = false,
  });

  final String id;
  final String senderId;
  final String content;
  final String messageType;
  final bool isBurned;

  factory ReplyPreview.fromApi(Map<String, dynamic> json) {
    return ReplyPreview(
      id: json['id']?.toString() ?? '',
      senderId: json['sender_id']?.toString() ?? '',
      content: json['content']?.toString() ?? '',
      messageType: json['message_type']?.toString() ?? 'text',
      isBurned: json['is_burned'] == true,
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
