import 'package:flutter/foundation.dart';

/// Mensagem fixada no chat da live (`chat_pinned.pin` / `GET room.pinned`).
@immutable
class ChatPin {
  const ChatPin({
    required this.text,
    required this.authorName,
    this.authorId,
    this.pinnedBy,
    this.pinnedByName,
    this.messageId,
    this.at,
  });

  final String text;
  final String authorName;
  final String? authorId;
  final String? pinnedBy;
  final String? pinnedByName;
  final String? messageId;
  final DateTime? at;

  /// `null` quando o payload não é um pin válido (ou é o `null` de "sem pin").
  static ChatPin? tryParse(dynamic raw) {
    if (raw is! Map) return null;
    final text = _s(raw['text']);
    if (text == null) return null;
    return ChatPin(
      text: text,
      authorName: _s(raw['author_name']) ?? _s(raw['pinned_by_name']) ?? '',
      authorId: _s(raw['author_id']),
      pinnedBy: _s(raw['pinned_by']),
      pinnedByName: _s(raw['pinned_by_name']),
      messageId: _s(raw['message_id']),
      at: DateTime.tryParse(_s(raw['at']) ?? '')?.toLocal(),
    );
  }

  @override
  bool operator ==(Object other) =>
      other is ChatPin &&
      other.text == text &&
      other.authorName == authorName &&
      other.messageId == messageId &&
      other.at == at;

  @override
  int get hashCode => Object.hash(text, authorName, messageId, at);
}

/// Motivos de rejeição de uma mensagem (`chat_error.code`).
enum ChatErrorKind { blockedWord, link, phone, muted, slowMode, unknown }

/// Rejeição enviada só a quem escreveu (`chat_error`).
@immutable
class ChatError {
  const ChatError({
    required this.kind,
    this.serverMessage,
    this.until,
    required this.at,
  });

  final ChatErrorKind kind;

  /// Texto em pt do servidor — NÃO exibir; a UI localiza pelo [kind].
  final String? serverMessage;

  /// `muted`: fim do silêncio (ausente = até o fim da live).
  /// `slow_mode`: quando poderá enviar de novo.
  final DateTime? until;

  /// Instante em que o erro chegou (identifica um erro novo para a UI).
  final DateTime at;

  static ChatErrorKind kindFromCode(String? code) => switch (code) {
    'blocked_word' => ChatErrorKind.blockedWord,
    'link' => ChatErrorKind.link,
    'phone' => ChatErrorKind.phone,
    'muted' => ChatErrorKind.muted,
    'slow_mode' => ChatErrorKind.slowMode,
    _ => ChatErrorKind.unknown,
  };

  static ChatError? tryParse(dynamic raw, {DateTime? now}) {
    if (raw is! Map) return null;
    return ChatError(
      kind: kindFromCode(_s(raw['code'])),
      serverMessage: _s(raw['message']),
      until: DateTime.tryParse(_s(raw['until']) ?? '')?.toLocal(),
      at: now ?? DateTime.now(),
    );
  }
}

/// `chat_muted`: o servidor avisa quem foi silenciado/liberado na hora.
@immutable
class ChatMuteNotice {
  const ChatMuteNotice({required this.muted, this.until});

  /// `false` quando o silêncio foi removido.
  final bool muted;
  final DateTime? until;

  static ChatMuteNotice? tryParse(dynamic raw) {
    if (raw is! Map) return null;
    final unmuted = raw['muted'] == false;
    return ChatMuteNotice(
      muted: !unmuted,
      until: unmuted ? null : DateTime.tryParse(_s(raw['until']) ?? '')?.toLocal(),
    );
  }
}

/// Intervalo do modo lento em segundos (`slow_mode.interval_s`); 0 = desligado.
int? parseSlowModeInterval(dynamic raw) {
  if (raw is! Map) return null;
  final v = raw['interval_s'] ?? raw['slow_mode_s'];
  final n = v is num ? v.toInt() : int.tryParse('${v ?? ''}');
  if (n == null) return null;
  return n < 0 ? 0 : n;
}

/// Moderador do criador (`GET /live/moderators`).
@immutable
class LiveModerator {
  const LiveModerator({
    required this.userId,
    required this.name,
    this.username,
    this.avatarUrl,
  });

  final String userId;
  final String name;
  final String? username;
  final String? avatarUrl;

  static LiveModerator? tryParse(dynamic raw) {
    if (raw is! Map) return null;
    final id = _s(raw['user_id']);
    if (id == null) return null;
    return LiveModerator(
      userId: id,
      name: _s(raw['name']) ?? _s(raw['username']) ?? '',
      username: _s(raw['username']),
      avatarUrl: _s(raw['avatar_url']),
    );
  }

  static List<LiveModerator> parseList(dynamic raw) {
    final list = raw is Map ? raw['data'] : raw;
    if (list is! List) return const [];
    return [
      for (final e in list)
        if (tryParse(e) case final m?) m,
    ];
  }
}

/// Estado de moderação de UMA sala, só o que a UI do chat precisa.
@immutable
class LiveModerationState {
  const LiveModerationState({
    this.pin,
    this.slowModeS = 0,
    this.error,
    this.isModerator = false,
    this.mutedUntil,
    this.muted = false,
  });

  final ChatPin? pin;
  final int slowModeS;

  /// Último `chat_error` (some sozinho após alguns segundos).
  final ChatError? error;

  /// Eu sou moderador desta sala (aprendido do eco do meu chat/entrada).
  final bool isModerator;

  /// Estou silenciado (via `chat_muted`); [mutedUntil] nulo = até o fim.
  final bool muted;
  final DateTime? mutedUntil;

  LiveModerationState copyWith({
    ChatPin? pin,
    bool clearPin = false,
    int? slowModeS,
    ChatError? error,
    bool clearError = false,
    bool? isModerator,
    bool? muted,
    DateTime? mutedUntil,
    bool clearMutedUntil = false,
  }) {
    return LiveModerationState(
      pin: clearPin ? null : pin ?? this.pin,
      slowModeS: slowModeS ?? this.slowModeS,
      error: clearError ? null : error ?? this.error,
      isModerator: isModerator ?? this.isModerator,
      muted: muted ?? this.muted,
      mutedUntil: clearMutedUntil ? null : mutedUntil ?? this.mutedUntil,
    );
  }
}

String? _s(dynamic v) {
  final s = v?.toString().trim();
  return (s == null || s.isEmpty || s == 'null') ? null : s;
}
