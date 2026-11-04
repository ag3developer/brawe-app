import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
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
    debugPrint('[MessagesService] listConversations status: ${response.statusCode}');
    debugPrint('[MessagesService] listConversations body: ${response.data}');
    final raw = response.data['data'];
    if (raw is! List) {
      debugPrint('[MessagesService] listConversations: "data" is not a List, got: ${raw.runtimeType} = $raw');
      return const <Conversation>[];
    }
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
    String? replyToMessageId,
    bool isForwarded = false,
  }) async {
    final body = <String, dynamic>{
      'content': content,
      'message_type': messageType,
      if (isForwarded) 'is_forwarded': true,
    };
    if (replyToMessageId != null && replyToMessageId.isNotEmpty) {
      body['reply_to_message_id'] = replyToMessageId;
    }
    final response = await _dio.post(
      '/messages/conversations/$conversationId',
      data: body,
    );
    final data = response.data['data'];
    final map = data is Map ? Map<String, dynamic>.from(data) : <String, dynamic>{};
    map['conversation_id'] ??= conversationId;
    return ChatMessage.fromApi(map, fallbackConversationId: conversationId);
  }

  /// `POST /messages/messages/{message_id}/react` — toggle reaction (emoji).
  /// Retorna o mapa completo de reações pós-toggle.
  Future<Map<String, List<String>>> reactMessage({
    required String messageId,
    required String emoji,
  }) async {
    final response = await _dio.post(
      '/messages/messages/$messageId/react',
      data: {'emoji': emoji},
    );
    final data = response.data['data'];
    final raw = data is Map ? data['reactions'] : null;
    final out = <String, List<String>>{};
    if (raw is Map) {
      raw.forEach((k, v) {
        if (v is List) {
          out[k.toString()] = v.map((e) => e.toString()).toList(growable: false);
        }
      });
    }
    return out;
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

  /// `POST /messages/conversations/{conversation_id}/upload` (multipart `file`).
  Future<ChatMessage> uploadImage({
    required String conversationId,
    required String filePath,
    bool viewOnce = false,
  }) async {
    final form = FormData.fromMap({
      'file': await MultipartFile.fromFile(filePath),
    });
    final response = await _dio.post(
      '/messages/conversations/$conversationId/upload',
      data: form,
      queryParameters: {'view_once': viewOnce},
    );
    final data = response.data['data'];
    final map = data is Map ? Map<String, dynamic>.from(data) : <String, dynamic>{};
    map['conversation_id'] ??= conversationId;
    return ChatMessage.fromApi(map, fallbackConversationId: conversationId);
  }

  /// `POST /messages/conversations/{id}/upload-file` (multipart `file`).
  Future<ChatMessage> uploadFile({
    required String conversationId,
    required String filePath,
    String? fileName,
  }) async {
    final form = FormData.fromMap({
      'file': await MultipartFile.fromFile(filePath, filename: fileName),
    });
    final response = await _dio.post(
      '/messages/conversations/$conversationId/upload-file',
      data: form,
    );
    return _messageFrom(response.data['data'], conversationId);
  }

  /// `PUT /messages/messages/{id}` — editar texto (até 15 min).
  Future<ChatMessage> editMessage(String messageId, String content) async {
    final response = await _dio.put(
      '/messages/messages/$messageId',
      data: {'content': content},
    );
    return _messageFrom(response.data['data'], '');
  }

  /// `POST /messages/messages/{id}/open-gift` — abrir o cofre do presente.
  Future<ChatMessage> openGift(String messageId) async {
    final response = await _dio.post('/messages/messages/$messageId/open-gift');
    return _messageFrom(response.data['data'], '');
  }

  /// `POST /messages/conversations/{id}/mute`.
  Future<bool> muteConversation(String conversationId, bool muted) async {
    final response = await _dio.post(
      '/messages/conversations/$conversationId/mute',
      data: {'muted': muted},
    );
    return response.data['is_muted'] == true;
  }

  /// `POST /messages/conversations/{id}/pin`.
  Future<bool> pinConversation(String conversationId, bool pinned) async {
    final response = await _dio.post(
      '/messages/conversations/$conversationId/pin',
      data: {'pinned': pinned},
    );
    return response.data['is_pinned'] == true;
  }

  /// `GET /messages/conversations/{id}/search?q=`.
  Future<List<ChatMessage>> searchMessages(
    String conversationId,
    String query,
  ) async {
    final response = await _dio.get(
      '/messages/conversations/$conversationId/search',
      queryParameters: {'q': query, 'limit': 50},
    );
    final raw = (response.data['data'] as List?) ?? const [];
    return raw
        .whereType<Map>()
        .map((m) => _messageFrom(m, conversationId))
        .toList();
  }

  ChatMessage _messageFrom(dynamic data, String conversationId) {
    final map =
        data is Map ? Map<String, dynamic>.from(data) : <String, dynamic>{};
    if (conversationId.isNotEmpty) map['conversation_id'] ??= conversationId;
    return ChatMessage.fromApi(map, fallbackConversationId: conversationId);
  }

  /// `POST /messages/conversations/{conversation_id}/upload-audio` (multipart `file`).
  Future<ChatMessage> uploadAudio({
    required String conversationId,
    required String filePath,
    int duration = 0,
  }) async {
    final form = FormData.fromMap({
      'file': await MultipartFile.fromFile(filePath),
    });
    final response = await _dio.post(
      '/messages/conversations/$conversationId/upload-audio',
      data: form,
      queryParameters: {'duration': duration},
    );
    final data = response.data['data'];
    final map = data is Map ? Map<String, dynamic>.from(data) : <String, dynamic>{};
    map['conversation_id'] ??= conversationId;
    return ChatMessage.fromApi(map, fallbackConversationId: conversationId);
  }

  /// `POST /messages/messages/{message_id}/burn`
  Future<void> burnMessage(String messageId) async {
    await _dio.post('/messages/messages/$messageId/burn');
  }

  /// `DELETE /messages/messages/{message_id}?for_everyone=true|false`
  Future<void> deleteMessage(String messageId, {bool forEveryone = false}) async {
    await _dio.delete(
      '/messages/messages/$messageId',
      queryParameters: {'for_everyone': forEveryone},
    );
  }

  /// `POST /messages/conversations/{conversation_id}/archive`
  Future<void> archiveConversation(String conversationId) async {
    await _dio.post('/messages/conversations/$conversationId/archive');
  }

  /// `POST /messages/conversations/{conversation_id}/unarchive`
  Future<void> unarchiveConversation(String conversationId) async {
    await _dio.post('/messages/conversations/$conversationId/unarchive');
  }

  /// `DELETE /messages/conversations/{conversation_id}`
  Future<void> deleteConversation(String conversationId) async {
    await _dio.delete('/messages/conversations/$conversationId');
  }

  // ────────────────────── Blocks ──────────────────────

  /// `POST /messages/blocks/{userId}` — bloqueia usuário.
  Future<void> blockUser(String userId) async {
    await _dio.post('/messages/blocks/$userId');
  }

  /// `DELETE /messages/blocks/{userId}` — desbloqueia usuário.
  Future<void> unblockUser(String userId) async {
    await _dio.delete('/messages/blocks/$userId');
  }

  /// `GET /messages/blocks` — lista IDs bloqueados.
  Future<List<String>> getBlockedUsers() async {
    final response = await _dio.get('/messages/blocks');
    final list = response.data['data'];
    if (list is! List) return const [];
    return list
        .whereType<Map>()
        .map((e) => e['blocked_id']?.toString() ?? '')
        .where((s) => s.isNotEmpty)
        .toList(growable: false);
  }

  // ────────────────────── Social (for DM search) ──────────────────────

  /// `GET /social/following` — retorna quem o usuário atual segue (para busca de nova conversa).
  Future<List<Map<String, dynamic>>> getFollowing({
    int page = 1,
    int limit = 50,
    String query = '',
  }) async {
    final response = await _dio.get(
      '/social/following',
      queryParameters: {'page': page, 'limit': limit},
    );
    final raw = response.data['data'];
    if (raw is! List) return const [];
    final all = raw.whereType<Map>().map((e) => Map<String, dynamic>.from(e)).toList();
    if (query.isEmpty) return all;
    final lower = query.toLowerCase();
    return all
        .where((u) =>
            (u['display_name'] as String? ?? '').toLowerCase().contains(lower) ||
            (u['username'] as String? ?? '').toLowerCase().contains(lower))
        .toList();
  }

  // ────────────────────── Status ──────────────────────

  /// `PUT /profile` — atualiza status de presença (online/away/offline via custom_status).
  Future<void> updatePresenceStatus(String status) async {
    // Encaminha para o profile endpoint do Connect
    await _dio.put('/profile', data: {'custom_status': status});
  }
}

class UserPresence {
  const UserPresence({required this.isOnline, this.lastSeen});
  final bool isOnline;
  final DateTime? lastSeen;
}
