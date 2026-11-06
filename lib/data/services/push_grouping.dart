/// Regras puras de agrupamento de notificações push (testáveis).
///
/// Várias mensagens da mesma conversa usam a MESMA tag/id local, então a
/// notificação nova substitui a anterior em vez de empilhar.
class PushGrouping {
  const PushGrouping._();

  /// `conversation_id` do payload (aceita snake_case e camelCase).
  static String? conversationId(Map<String, dynamic> data) {
    final v = data['conversation_id'] ?? data['conversationId'];
    final s = v?.toString();
    return (s == null || s.isEmpty) ? null : s;
  }

  static bool isMessage(Map<String, dynamic> data) =>
      (data['type'] ?? data['notification_type'])?.toString().toLowerCase() ==
          'new_message' ||
      conversationId(data) != null;

  /// Chave de agregação enviada pelo backend (`like:{post}`, `follow:…`,
  /// `gift:{room}`…) — a mesma usada como tag/collapse-id/thread-id no push.
  static String? aggregationKey(Map<String, dynamic> data) {
    final v = data['groupKey'] ?? data['group_key'];
    final s = v?.toString();
    return (s == null || s.isEmpty) ? null : s;
  }

  /// Tag Android / thread-id iOS do grupo (a conversa ou a chave de
  /// agregação), ou `null`.
  static String? groupKey(Map<String, dynamic> data) =>
      isMessage(data) ? conversationId(data) : aggregationKey(data);

  /// Id numérico estável (31-bit) para `flutter_local_notifications.show/cancel`.
  static int notificationId(String key) {
    var h = 0;
    for (final c in key.codeUnits) {
      h = (h * 31 + c) & 0x7fffffff;
    }
    return h;
  }

  /// Não mostrar banner se o usuário já está olhando essa conversa.
  static bool shouldSuppress(Map<String, dynamic> data, String? activeConv) {
    final conv = groupKey(data);
    return conv != null && activeConv != null && conv == activeConv;
  }
}
