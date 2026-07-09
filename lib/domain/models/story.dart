class Story {
  const Story({
    required this.id,
    required this.authorId,
    required this.authorName,
    required this.authorUsername,
    this.authorAvatarUrl,
    required this.mediaUrl,
    this.mediaType = 'image',
    this.thumbnailUrl,
    this.caption,
    this.durationSeconds,
    this.viewsCount = 0,
    this.reactionsCount = 0,
    required this.createdAt,
    this.expiresAt,
    this.isSeen = false,
    this.isVerified = false,
    this.originPostId,
    this.mediaWidth,
    this.mediaHeight,
  });

  final String id;
  final String authorId;
  final String authorName;
  final String authorUsername;
  final String? authorAvatarUrl;
  final String mediaUrl;
  final String mediaType; // 'image' | 'video'
  final String? thumbnailUrl;
  final String? caption;
  final int? durationSeconds;
  final int viewsCount;
  final int reactionsCount;
  final DateTime createdAt;
  final DateTime? expiresAt;
  final bool isSeen;
  final bool isVerified;
  final String? originPostId;

  /// Dimensões originais da mídia (disponíveis quando publicado pela web).
  /// Usadas para calcular o fit correto no viewer — evita corte indesejado
  /// em imagens landscape ou portrait extremo publicadas fora do app.
  final int? mediaWidth;
  final int? mediaHeight;

  /// Aspect ratio da mídia ou null se não disponível.
  double? get mediaAspectRatio {
    if (mediaWidth != null && mediaHeight != null && mediaHeight! > 0) {
      return mediaWidth! / mediaHeight!;
    }
    return null;
  }

  /// True se a mídia é claramente landscape (publicada via web/desktop).
  bool get isLandscape {
    final ar = mediaAspectRatio;
    return ar != null && ar > 1.2; // 1.2 = 6:5 — acima disso é landscape
  }

  /// True se é um story vertical nativo do app (9:16 é ≈ 0.5625).
  bool get isNativePortrait {
    final ar = mediaAspectRatio;
    return ar == null || ar <= 0.8; // inclui 1:1 e portrait
  }

  bool get isVideo => mediaType == 'video';

  bool get isExpired {
    if (expiresAt == null) return false;
    return DateTime.now().isAfter(expiresAt!);
  }

  String get timeAgo {
    final diff = DateTime.now().difference(createdAt);
    if (diff.inHours < 1) return '${diff.inMinutes}m';
    if (diff.inHours < 24) return '${diff.inHours}h';
    return '${diff.inDays}d';
  }

  Story copyWith({bool? isSeen}) => Story(
    id: id,
    authorId: authorId,
    authorName: authorName,
    authorUsername: authorUsername,
    authorAvatarUrl: authorAvatarUrl,
    mediaUrl: mediaUrl,
    mediaType: mediaType,
    thumbnailUrl: thumbnailUrl,
    caption: caption,
    durationSeconds: durationSeconds,
    viewsCount: viewsCount,
    reactionsCount: reactionsCount,
    createdAt: createdAt,
    expiresAt: expiresAt,
    isSeen: isSeen ?? this.isSeen,
    isVerified: isVerified,
    originPostId: originPostId,
    mediaWidth: mediaWidth,
    mediaHeight: mediaHeight,
  );
}

/// Agrupamento de stories por usuário (formato do backend /stories/feed).
class UserStoriesGroup {
  const UserStoriesGroup({
    required this.userId,
    this.displayName,
    this.username,
    this.avatarUrl,
    this.isVerified = false,
    this.hasUnviewed = false,
    this.isLive = false,
    this.liveRoomId,
    required this.stories,
  });

  final String userId;
  final String? displayName;
  final String? username;
  final String? avatarUrl;
  final bool isVerified;
  final bool hasUnviewed;
  final bool isLive;
  final String? liveRoomId;
  final List<Story> stories;
}

/// Item retornado por GET /stories/{id}/viewers
class StoryViewerInfo {
  const StoryViewerInfo({
    required this.userId,
    required this.name,
    required this.username,
    this.avatarUrl,
    this.isVerified = false,
    required this.viewedAt,
    this.reaction,
  });

  final String userId;
  final String name;
  final String username;
  final String? avatarUrl;
  final bool isVerified;
  final DateTime viewedAt;
  final String? reaction;

  factory StoryViewerInfo.fromJson(Map<String, dynamic> json) {
    return StoryViewerInfo(
      userId: (json['user_id'] ?? '') as String,
      name: (json['name'] ?? '') as String,
      username: (json['username'] ?? '') as String,
      avatarUrl: json['avatar_url'] as String?,
      isVerified: (json['is_verified'] ?? false) as bool,
      viewedAt:
          DateTime.tryParse((json['viewed_at'] ?? '') as String) ??
          DateTime.now(),
      reaction: json['reaction'] as String?,
    );
  }
}
