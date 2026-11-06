/// Ator de uma notificação agrupada (quem curtiu/comentou/seguiu…).
class NotifActor {
  final String id;
  final String name;
  final String? avatar;
  const NotifActor({required this.id, required this.name, this.avatar});

  factory NotifActor.fromJson(Map<String, dynamic> json) => NotifActor(
    id: (json['id'] ?? '').toString(),
    name: (json['name'] ?? json['display_name'] ?? '').toString(),
    avatar: (json['avatar'] ?? json['avatar_url']) as String?,
  );
}

/// Notification domain model. Mirrors brawe-connect GET /notifications response.
///
/// Campos de agrupamento (`group_key`, `actors`, `actors_count`, …) são
/// opcionais: um backend antigo continua funcionando (1 ator = `actor_*`).
class AppNotification {
  final String id;
  final String type;
  final String title;
  final String message;
  final Map<String, dynamic>? data;
  final bool isRead;
  final String? actorId;
  final String? actorName;
  final String? actorAvatar;
  final String? linkUrl;
  final DateTime? createdAt;
  final bool actorIsVerified;

  /// Chave de agregação (`like:{post}`, `follow:{user}:{dia}`, `gift:{room}`…).
  final String? groupKey;

  /// Últimos atores (até 3), mais recente primeiro.
  final List<NotifActor> actors;

  /// Total de atores distintos do grupo (>= actors.length).
  final int actorsCount;

  /// Valor acumulado do grupo (ex.: diamantes dos presentes).
  final int groupValue;

  /// Miniatura do alvo (capa do post).
  final String? thumbnailUrl;

  const AppNotification({
    required this.id,
    required this.type,
    required this.title,
    required this.message,
    this.data,
    required this.isRead,
    this.actorId,
    this.actorName,
    this.actorAvatar,
    this.linkUrl,
    this.createdAt,
    this.actorIsVerified = false,
    this.groupKey,
    this.actors = const [],
    this.actorsCount = 0,
    this.groupValue = 0,
    this.thumbnailUrl,
  });

  factory AppNotification.fromJson(Map<String, dynamic> json) {
    final rawActors = (json['actors'] as List?)
        ?.whereType<Map>()
        .map((m) => NotifActor.fromJson(Map<String, dynamic>.from(m)))
        .where((a) => a.id.isNotEmpty)
        .toList();
    final actorId = json['actor_id'] as String?;
    final actors =
        rawActors ??
        [
          if (actorId != null && actorId.isNotEmpty)
            NotifActor(
              id: actorId,
              name: (json['actor_name'] ?? '').toString(),
              avatar: json['actor_avatar'] as String?,
            ),
        ];
    final count = (json['actors_count'] as num?)?.toInt() ?? actors.length;
    return AppNotification(
      id: (json['id'] ?? '').toString(),
      type: (json['type'] ?? 'system').toString(),
      title: (json['title'] ?? '').toString(),
      message: (json['message'] ?? '').toString(),
      data: json['data'] is Map<String, dynamic>
          ? json['data'] as Map<String, dynamic>
          : null,
      isRead: json['is_read'] as bool? ?? false,
      actorId: json['actor_id'] as String?,
      actorName: json['actor_name'] as String?,
      actorAvatar: json['actor_avatar'] as String?,
      linkUrl: json['link_url'] as String?,
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'] as String)
          : null,
      actorIsVerified: json['actor_is_verified'] == true,
      groupKey: json['group_key'] as String?,
      actors: actors,
      actorsCount: count < actors.length ? actors.length : count,
      groupValue: (json['group_value'] as num?)?.toInt() ?? 0,
      thumbnailUrl: json['thumbnail_url'] as String?,
    );
  }

  /// Notificação agrupada de verdade (mais de um evento/ator ou com chave).
  bool get isGrouped => groupKey != null && groupKey!.isNotEmpty;

  AppNotification copyWith({bool? isRead}) {
    return AppNotification(
      id: id,
      type: type,
      title: title,
      message: message,
      data: data,
      isRead: isRead ?? this.isRead,
      actorId: actorId,
      actorName: actorName,
      actorAvatar: actorAvatar,
      linkUrl: linkUrl,
      createdAt: createdAt,
      actorIsVerified: actorIsVerified,
      groupKey: groupKey,
      actors: actors,
      actorsCount: actorsCount,
      groupValue: groupValue,
      thumbnailUrl: thumbnailUrl,
    );
  }
}

class NotificationsPage {
  final List<AppNotification> items;
  final int total;
  final int unreadCount;

  const NotificationsPage({
    required this.items,
    required this.total,
    required this.unreadCount,
  });

  factory NotificationsPage.fromJson(Map<String, dynamic> json) {
    final raw = (json['data'] as List?) ?? const [];
    return NotificationsPage(
      items: raw
          .whereType<Map<String, dynamic>>()
          .map(AppNotification.fromJson)
          .toList(),
      total: (json['total'] as num?)?.toInt() ?? 0,
      unreadCount: (json['unread_count'] as num?)?.toInt() ?? 0,
    );
  }
}
