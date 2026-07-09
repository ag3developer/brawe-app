/// Usuário que curtiu uma mídia (post/vídeo/foto).
/// Espelha o item de `data.likes[]` em `GET /interactions/{id}/likes`.
class PostLiker {
  final String userId;
  final String displayName;
  final String? avatarUrl;
  final bool isVerified;

  /// Tipo de reação: like, love, fire, laugh, wow, sad.
  final String reactionType;
  final DateTime? createdAt;

  const PostLiker({
    required this.userId,
    required this.displayName,
    this.avatarUrl,
    this.isVerified = false,
    this.reactionType = 'like',
    this.createdAt,
  });

  factory PostLiker.fromJson(Map<String, dynamic> json) => PostLiker(
    userId: (json['user_id'] ?? '').toString(),
    displayName: (json['display_name'] ?? '').toString(),
    avatarUrl: json['avatar_url'] as String?,
    isVerified: (json['is_verified'] as bool?) ?? false,
    reactionType: (json['reaction_type'] as String?) ?? 'like',
    createdAt: DateTime.tryParse((json['created_at'] ?? '').toString()),
  );
}

/// Resposta agregada de `GET /interactions/{id}/likes`.
class PostLikesPage {
  final List<PostLiker> likers;

  /// Mapa reactionType → count (ex.: {"like": 42, "fire": 12}).
  final Map<String, int> reactionsBreakdown;
  final int total;
  final bool hasMore;

  const PostLikesPage({
    required this.likers,
    required this.reactionsBreakdown,
    required this.total,
    required this.hasMore,
  });

  factory PostLikesPage.fromJson(Map<String, dynamic> json) {
    // Suporta resposta direta: { likes: [], reactions: {}, total: N, has_more: bool }
    final rawLikes = (json['likes'] as List?) ?? const [];
    final rawReactions =
        (json['reactions'] as Map<String, dynamic>?) ?? const {};
    final total = (json['total'] as num?)?.toInt() ?? rawLikes.length;
    final hasMore = (json['has_more'] as bool?) ?? false;
    return PostLikesPage(
      likers: rawLikes
          .whereType<Map<String, dynamic>>()
          .map(PostLiker.fromJson)
          .toList(),
      reactionsBreakdown: rawReactions.map(
        (k, v) => MapEntry(k, (v as num?)?.toInt() ?? 0),
      ),
      total: total,
      hasMore: hasMore,
    );
  }
}
