/// Status compacto de stories ativos de um usuário.
///
/// Usado para pintar o anel colorido em avatares espalhados pela UI
/// (comentários, header de posts, lista de chats, seguidores, etc.)
/// sem precisar fazer 1 request por usuário.
class StoryActiveStatus {
  const StoryActiveStatus({
    required this.hasStories,
    required this.hasUnviewed,
  });

  /// Não tem stories ativos no momento.
  static const empty = StoryActiveStatus(
    hasStories: false,
    hasUnviewed: false,
  );

  /// Tem ao menos 1 story ativo (visto ou não).
  final bool hasStories;

  /// Tem ao menos 1 story ativo que o usuário atual ainda NÃO viu.
  /// Implica `hasStories == true`.
  final bool hasUnviewed;

  factory StoryActiveStatus.fromJson(Map<String, dynamic> json) {
    return StoryActiveStatus(
      hasStories: (json['has_stories'] ?? false) as bool,
      hasUnviewed: (json['has_unviewed'] ?? false) as bool,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is StoryActiveStatus &&
          other.hasStories == hasStories &&
          other.hasUnviewed == hasUnviewed);

  @override
  int get hashCode => Object.hash(hasStories, hasUnviewed);

  @override
  String toString() =>
      'StoryActiveStatus(hasStories: $hasStories, hasUnviewed: $hasUnviewed)';
}
