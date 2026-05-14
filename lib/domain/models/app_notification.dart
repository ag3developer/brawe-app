/// Notification domain model. Mirrors brawe-connect GET /notifications response.
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
  });

  factory AppNotification.fromJson(Map<String, dynamic> json) {
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
    );
  }

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
