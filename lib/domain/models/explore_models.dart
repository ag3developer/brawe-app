/// Modelos simples para a tela Explorar.
/// Os endpoints retornam shapes diferentes — usamos classes leves.
library;

class TrendingLive {
  final String roomId;
  final String? slug;
  final String title;
  final String? streamerName;
  final String? streamerAvatar;
  final String? category;
  final int viewerCount;
  final String? thumbnailUrl;

  const TrendingLive({
    required this.roomId,
    this.slug,
    required this.title,
    this.streamerName,
    this.streamerAvatar,
    this.category,
    this.viewerCount = 0,
    this.thumbnailUrl,
  });

  factory TrendingLive.fromJson(Map<String, dynamic> j) => TrendingLive(
    roomId: (j['room_id'] ?? '').toString(),
    slug: j['slug'] as String?,
    title: (j['title'] ?? '') as String,
    streamerName: j['streamer_name'] as String?,
    streamerAvatar: j['streamer_avatar'] as String?,
    category: j['category'] as String?,
    viewerCount: (j['viewer_count'] ?? 0) as int,
    thumbnailUrl: j['thumbnail_url'] as String?,
  );
}

class TrendingStreamer {
  final String userId;
  final String displayName;
  final String? avatarUrl;
  final bool isLive;
  final int viewerCount;
  final int followerCount;

  const TrendingStreamer({
    required this.userId,
    required this.displayName,
    this.avatarUrl,
    this.isLive = false,
    this.viewerCount = 0,
    this.followerCount = 0,
  });

  factory TrendingStreamer.fromJson(Map<String, dynamic> j) => TrendingStreamer(
    userId: (j['user_id'] ?? '') as String,
    displayName: (j['display_name'] ?? 'User') as String,
    avatarUrl: j['avatar_url'] as String?,
    isLive: (j['is_live'] ?? false) as bool,
    viewerCount: (j['viewer_count'] ?? 0) as int,
    followerCount: (j['follower_count'] ?? 0) as int,
  );
}

class ExploreCategory {
  final String name;
  final String slug;
  final int liveCount;
  final int totalViewers;

  const ExploreCategory({
    required this.name,
    required this.slug,
    this.liveCount = 0,
    this.totalViewers = 0,
  });

  factory ExploreCategory.fromJson(Map<String, dynamic> j) => ExploreCategory(
    name: (j['name'] ?? '') as String,
    slug: (j['slug'] ?? '') as String,
    liveCount: (j['live_count'] ?? 0) as int,
    totalViewers: (j['total_viewers'] ?? 0) as int,
  );
}

/// Resultado unificado da busca (streamer ou live).
class SearchResult {
  final String type; // 'streamer' | 'live'
  final String id;
  final String title;
  final String? subtitle;
  final String? thumbnail;
  final Map<String, dynamic> metadata;

  const SearchResult({
    required this.type,
    required this.id,
    required this.title,
    this.subtitle,
    this.thumbnail,
    this.metadata = const {},
  });

  factory SearchResult.fromJson(Map<String, dynamic> j) => SearchResult(
    type: (j['type'] ?? '') as String,
    id: (j['id'] ?? '').toString(),
    title: (j['title'] ?? '') as String,
    subtitle: j['subtitle'] as String?,
    thumbnail: j['thumbnail'] as String?,
    metadata: (j['metadata'] is Map)
        ? Map<String, dynamic>.from(j['metadata'] as Map)
        : const {},
  );
}

class TrendingData {
  final List<TrendingLive> lives;
  final List<TrendingStreamer> streamers;
  const TrendingData({this.lives = const [], this.streamers = const []});

  factory TrendingData.fromJson(Map<String, dynamic> j) => TrendingData(
    lives: ((j['lives'] as List<dynamic>?) ?? [])
        .map((e) => TrendingLive.fromJson(Map<String, dynamic>.from(e as Map)))
        .toList(),
    streamers: ((j['streamers'] as List<dynamic>?) ?? [])
        .map(
          (e) => TrendingStreamer.fromJson(Map<String, dynamic>.from(e as Map)),
        )
        .toList(),
  );
}
