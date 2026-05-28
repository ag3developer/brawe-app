// ============================================================================
// GIFTER SUMMARY MODELS — Histórico social agrupado por pessoa (TikTok-style)
// ----------------------------------------------------------------------------
// Substituem a lista linear de `WalletTransaction` na tela de extrato:
// agrupa por contraparte (sender/receiver) e devolve card resumido com top
// gifts + ações (chat / seguir).
//
//   • [GifterSummary]        — card resumido na lista
//   • [GifterTopGift]        — preview de gift no card (top 3 por valor)
//   • [GifterGiftBreakdown]  — linha completa do detalhe
//   • [GifterDetails]        — payload de /credits/gifters/{user_id}
// ============================================================================

/// Preview de um gift no card resumido (top 3 por valor).
class GifterTopGift {
  final String slug;
  final String name;
  final String iconUrl;
  final String tier;
  final int quantity;
  final int totalCredits;

  const GifterTopGift({
    required this.slug,
    required this.name,
    required this.iconUrl,
    required this.tier,
    required this.quantity,
    required this.totalCredits,
  });

  /// Caminho do asset local (mesma estrutura usada em gifts_overlay).
  String get assetPath => 'assets/images/gifts/$tier/$slug.png';

  factory GifterTopGift.fromJson(Map<String, dynamic> json) {
    return GifterTopGift(
      slug: (json['slug'] ?? '').toString(),
      name: (json['name'] ?? '').toString(),
      iconUrl: (json['icon_url'] ?? '').toString(),
      tier: (json['tier'] ?? 'common').toString(),
      quantity: (json['quantity'] as num?)?.toInt() ?? 0,
      totalCredits: (json['total_credits'] as num?)?.toInt() ?? 0,
    );
  }
}

/// Card resumido de uma pessoa que enviou/recebeu gifts.
class GifterSummary {
  final String userId;
  final String username;
  final String displayName;
  final String? avatarUrl;
  final String? rank; // "Bronze", "Prata", ...
  final bool isFollowing;
  final bool isFollower;
  final int totalCredits;
  final int giftCount;
  final int liveCount;
  final DateTime? lastGiftAt;
  final List<GifterTopGift> topGifts;

  const GifterSummary({
    required this.userId,
    required this.username,
    required this.displayName,
    this.avatarUrl,
    this.rank,
    required this.isFollowing,
    required this.isFollower,
    required this.totalCredits,
    required this.giftCount,
    required this.liveCount,
    this.lastGiftAt,
    this.topGifts = const [],
  });

  GifterSummary copyWith({bool? isFollowing}) => GifterSummary(
        userId: userId,
        username: username,
        displayName: displayName,
        avatarUrl: avatarUrl,
        rank: rank,
        isFollowing: isFollowing ?? this.isFollowing,
        isFollower: isFollower,
        totalCredits: totalCredits,
        giftCount: giftCount,
        liveCount: liveCount,
        lastGiftAt: lastGiftAt,
        topGifts: topGifts,
      );

  factory GifterSummary.fromJson(Map<String, dynamic> json) {
    return GifterSummary(
      userId: (json['user_id'] ?? '').toString(),
      username: (json['username'] ?? '').toString(),
      displayName: (json['display_name'] ?? '').toString(),
      avatarUrl: json['avatar_url']?.toString(),
      rank: json['rank']?.toString(),
      isFollowing: json['is_following'] == true,
      isFollower: json['is_follower'] == true,
      totalCredits: (json['total_credits'] as num?)?.toInt() ?? 0,
      giftCount: (json['gift_count'] as num?)?.toInt() ?? 0,
      liveCount: (json['live_count'] as num?)?.toInt() ?? 0,
      lastGiftAt:
          DateTime.tryParse((json['last_gift_at'] ?? '').toString()),
      topGifts: (json['top_gifts'] as List? ?? [])
          .whereType<Map<String, dynamic>>()
          .map(GifterTopGift.fromJson)
          .toList(),
    );
  }
}

/// Linha do breakdown completo no bottom sheet de detalhe.
class GifterGiftBreakdown {
  final String slug;
  final String name;
  final String iconUrl;
  final String tier;
  final int quantity;
  final int totalCredits;
  final DateTime? lastAt;

  const GifterGiftBreakdown({
    required this.slug,
    required this.name,
    required this.iconUrl,
    required this.tier,
    required this.quantity,
    required this.totalCredits,
    this.lastAt,
  });

  String get assetPath => 'assets/images/gifts/$tier/$slug.png';

  factory GifterGiftBreakdown.fromJson(Map<String, dynamic> json) {
    return GifterGiftBreakdown(
      slug: (json['slug'] ?? '').toString(),
      name: (json['name'] ?? '').toString(),
      iconUrl: (json['icon_url'] ?? '').toString(),
      tier: (json['tier'] ?? 'common').toString(),
      quantity: (json['quantity'] as num?)?.toInt() ?? 0,
      totalCredits: (json['total_credits'] as num?)?.toInt() ?? 0,
      lastAt: DateTime.tryParse((json['last_at'] ?? '').toString()),
    );
  }
}

/// Resposta de /credits/gifters/{user_id}.
class GifterDetails {
  final GifterSummary user;
  final List<GifterGiftBreakdown> gifts;

  const GifterDetails({required this.user, required this.gifts});

  factory GifterDetails.fromJson(Map<String, dynamic> json) {
    return GifterDetails(
      user: GifterSummary.fromJson(
          (json['user'] as Map?)?.cast<String, dynamic>() ?? const {}),
      gifts: (json['gifts'] as List? ?? [])
          .whereType<Map<String, dynamic>>()
          .map(GifterGiftBreakdown.fromJson)
          .toList(),
    );
  }
}
