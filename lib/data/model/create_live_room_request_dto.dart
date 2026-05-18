/// Visibilidade de uma live.
/// - [public]: aberta para qualquer um descobrir/entrar.
/// - [followers]: apenas seguidores do streamer entram.
/// - [private]: apenas pessoas com link convidadas.
enum LiveVisibility {
  public,
  followers,
  private;

  String get apiValue => switch (this) {
        LiveVisibility.public => 'public',
        LiveVisibility.followers => 'followers',
        LiveVisibility.private => 'private',
      };

  String get label => switch (this) {
        LiveVisibility.public => 'Público',
        LiveVisibility.followers => 'Seguidores',
        LiveVisibility.private => 'Privada',
      };

  String get description => switch (this) {
        LiveVisibility.public => 'Qualquer pessoa pode entrar e descobrir',
        LiveVisibility.followers => 'Apenas quem te segue pode entrar',
        LiveVisibility.private => 'Apenas pessoas com link convidadas',
      };
}

class CreateLiveRoomRequestDto {
  const CreateLiveRoomRequestDto({
    required this.title,
    this.description,
    this.category,
    this.tags,
    this.visibility = LiveVisibility.public,
    this.liveType = 'solo',
    this.scheduledAt,
    this.chatEnabled = true,
    this.giftsEnabled = true,
    this.shoppingEnabled = true,
    this.notifyFollowers = true,
    this.thumbnailUrl,
  });

  final String title;
  final String? description;
  final String? category;
  final List<String>? tags;
  final LiveVisibility visibility;
  final String liveType;
  final DateTime? scheduledAt;
  final bool chatEnabled;
  final bool giftsEnabled;
  final bool shoppingEnabled;
  final bool notifyFollowers;
  final String? thumbnailUrl;

  /// Atalho legado: só verdadeiro quando visibility == private.
  bool get isPrivate => visibility == LiveVisibility.private;

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'description': description,
      'category': category,
      'tags': tags,
      'live_type': liveType,
      // Mantém `is_private` por compatibilidade e já envia `visibility`.
      'is_private': isPrivate,
      'visibility': visibility.apiValue,
      'scheduled_at': scheduledAt?.toUtc().toIso8601String(),
      'chat_enabled': chatEnabled,
      'gifts_enabled': giftsEnabled,
      'shopping_enabled': shoppingEnabled,
      'notify_followers': notifyFollowers,
      'thumbnail_url': thumbnailUrl,
    }..removeWhere((_, value) => value == null);
  }
}
