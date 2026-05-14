import 'package:dio/dio.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../core/constants/app_constants.dart';
import '../../core/network/live_dio_provider.dart';
import '../../domain/models/conversation.dart';

part 'messages_service.g.dart';

@riverpod
MessagesService messagesService(Ref ref) {
  return MessagesService(ref.watch(liveDioProvider));
}

/// Wraps REST endpoints declared in `brawe-connect/backend/app/api/v1/messages.py`.
class MessagesService {
  final Dio _dio;

  MessagesService(this._dio);

  /// `GET /messages/conversations`
  Future<List<Conversation>> listConversations({
    int page = 1,
    int limit = AppConstants.conversationsPageLimit,
    bool archived = false,
  }) async {
    final response = await _dio.get(
      '/messages/conversations',
      queryParameters: {
        'page': page,
        'limit': limit,
        'archived': archived,
      },
    );
    final raw = response.data['data'];
    if (raw is! List) return const <Conversation>[];
    return raw
        .whereType<Map>()
        .map((e) => Conversation.fromApi(Map<String, dynamic>.from(e)))
        .toList(growable: false);
  }

  /// `GET /messages/conversations/{conversation_id}`
  Future<List<ChatMessage>> getMessages(
    String conversationId, {
    int page = 1,
    int limit = AppConstants.chatPageLimit,
  }) async {
    final response = await _dio.get(
      '/messages/conversations/$conversationId',
      queryParameters: {'page': page, 'limit': limit},
    );
    final raw = response.data['data'];
    if (raw is! List) return const <ChatMessage>[];
    return raw
        .whereType<Map>()
        .map((e) => ChatMessage.fromApi(
              Map<String, dynamic>.from(e),
              fallbackConversationId: conversationId,
            ))
        .toList(growable: false);
  }

  /// `POST /messages/conversations/{conversation_id}`
  Future<ChatMessage> sendMessage({
    required String conversationId,
    required String content,
    String messageType = 'text',
  }) async {
    final response = await _dio.post(
      '/messages/conversations/$conversationId',
      data: {'content': content, 'message_type': messageType},
    );
    final data = response.data['data'];
    final map = data is Map ? Map<String, dynamic>.from(data) : <String, dynamic>{};
    map['conversation_id'] ??= conversationId;
    return ChatMessage.fromApi(map, fallbackConversationId: conversationId);
  }

  /// `PUT /messages/conversations/{conversation_id}/read`
  Future<void> markAsRead(String conversationId) async {
    await _dio.put('/messages/conversations/$conversationId/read');
  }

  /// `GET /messages/unread-count`
  Future<int> getUnreadCount() async {
    final response = await _dio.get('/messages/unread-count');
    final value = response.data['unread_count'];
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse(value?.toString() ?? '0') ?? 0;
  }

  /// `POST /messages/conversations` — inicia/retorna conversa por user_id (UUID ou username).
  Future<String> startConversation(String userIdOrUsername) async {
    final response = await _dio.post(
      '/messages/conversations',
      data: {'user_id': userIdOrUsername},
    );
    final data = response.data['data'];
    final id = (data is Map ? data['id'] : null)?.toString();
    if (id == null || id.isEmpty) {
      throw DioException(
        requestOptions: response.requestOptions,
        response: response,
        error: 'Conversa sem id no response',
      );
    }
    return id;
  }

  /// `GET /messages/conversations/by-user/{slug}` — resolve username/UUID e cria conversa.
  Future<({String conversationId, String otherUserId})> getOrCreateByUser(
    String slug,
  ) async {
    final response = await _dio.get('/messages/conversations/by-user/$slug');
    final data = response.data['data'];
    final map = data is Map ? Map<String, dynamic>.from(data) : <String, dynamic>{};
    return (
      conversationId: map['id']?.toString() ?? '',
      otherUserId: map['other_user_id']?.toString() ?? '',
    );
  }

  /// `GET /messages/presence?user_ids=...` — retorna mapa userId -> {isOnline, lastSeen}.
  Future<Map<String, UserPresence>> getPresence(List<String> userIds) async {
    if (userIds.isEmpty) return const {};
    final response = await _dio.get(
      '/messages/presence',
      queryParameters: {'user_ids': userIds.join(',')},
    );
    final raw = response.data['data'];
    if (raw is! Map) return const {};
    final out = <String, UserPresence>{};
    raw.forEach((key, value) {
      if (value is! Map) return;
      final lastSeenRaw = value['last_seen']?.toString();
      out[key.toString()] = UserPresence(
        isOnline: value['is_online'] == true,
        lastSeen: lastSeenRaw == null || lastSeenRaw.isEmpty
            ? null
            : DateTime.tryParse(lastSeenRaw)?.toLocal(),
      );
    });
    return out;
  }
}

class UserPresence {
  const UserPresence({required this.isOnline, this.lastSeen});
  final bool isOnline;
  final DateTime? lastSeen;
}
